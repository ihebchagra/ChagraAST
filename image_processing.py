#
# # 
# Copyright (C) 2025 Iheb Chagra
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# 
#

import os
import uuid
import logging
import numpy as np
import imageio
import astimp
import repo
from boites import pseudo_1
from disks import disk_dictionnary

logger = logging.getLogger(__name__)

# If True we delete the cropped/original files when an early error occurs
DELETE_ON_ERROR = True

astimp.config.Inhibition_minPelletIntensity = 160


def normalize_for_cv(
    img,
    *,
    prefer_color=True,
    force_color_if_gray=False,
    force_grayscale=False,
    force_float32=False,
):
    """
    Normalize an input image so it satisfies the asserts used by the Cython
    numpy_opencv_conversion helpers:
      - Grayscale: 2D array
      - Color: (H,W,3)
      - Dtype: uint8 (or float32 if force_float32=True)
    """
    if not isinstance(img, np.ndarray):
        img = np.asarray(img)

    # Channel handling
    if img.ndim == 3:
        h, w, ch = img.shape
        if ch == 4:        # drop alpha
            img = img[..., :3]
        elif ch == 1:      # squeeze singleton
            img = img[..., 0]
        elif ch > 4:       # keep first three
            img = img[..., :3]
    elif img.ndim > 3:
        img = img[..., 0]
        if img.ndim > 3:
            raise ValueError(f"Cannot normalize image with shape {img.shape}")

    # Grayscale vs color decisions
    if force_grayscale:
        if img.ndim == 3:
            img = img.mean(axis=2)
    else:
        if img.ndim == 2 and prefer_color and force_color_if_gray:
            img = np.stack([img, img, img], axis=2)

    # Dtype conversion
    orig_dtype = img.dtype
    if force_float32:
        if np.issubdtype(orig_dtype, np.floating):
            img = img.astype(np.float32, copy=False)
            if img.size and img.max() > 1.0:
                maxv = img.max()
                if maxv > 0:
                    img = img / maxv
        else:
            if np.issubdtype(orig_dtype, np.integer):
                info = np.iinfo(orig_dtype)
                img = (img.astype(np.float32) / info.max)
            else:
                img = img.astype(np.float32)
    else:
        # Force to uint8
        if img.dtype == np.uint8:
            pass
        elif np.issubdtype(img.dtype, np.integer):
            if img.dtype.itemsize > 1:
                max_possible = np.iinfo(img.dtype).max
                if max_possible == 65535:
                    img = (img >> 8).astype(np.uint8)
                else:
                    img = (img.astype(np.float64) * (255.0 / max_possible)).round().astype(np.uint8)
            else:
                img = img.astype(np.uint8)
        elif np.issubdtype(img.dtype, np.floating):
            maxv = img.max() if img.size else 0
            if maxv <= 1.0:
                img = (img * 255.0).round().clip(0, 255).astype(np.uint8)
            else:
                img = np.clip(img, 0, 255).round().astype(np.uint8)
        else:
            img = img.astype(np.uint8)

    img = np.ascontiguousarray(img)

    if img.ndim == 3 and img.shape[2] != 3:
        raise ValueError(f"Post-normalization color image must have 3 channels, got shape {img.shape}")
    if img.ndim not in (2, 3):
        raise ValueError(f"Post-normalization image must be 2D or 3D, got shape {img.shape}")

    return img


def _extract_positive_px_per_mm(ast_obj):
    """
    Return a strictly positive float px_per_mm or None if not available/invalid.
    """
    raw = getattr(ast_obj, "px_per_mm", None)
    if raw is None:
        return None
    try:
        val = float(raw)
    except Exception:
        return None
    if val > 0:
        return val
    return None


def process_plate(
    db,
    upload_file,
    upload_dir,
    prelevement_id,
    isolat_id,
    boite_type,
    *,
    force_grayscale=False,
    force_float32=False,
    force_color_if_gray=False,
    prefer_color=True,
):
    """
    Process a plate image. Changes from earlier version:

    - If no disks (circles) are detected: raise an error immediately
      (user must retry with a better image).
    - If px_per_mm cannot be computed (missing or <= 0): raise an error.
    - No fallback scale is inserted.
    """
    if not upload_file:
        raise ValueError("Aucune image fournie.")

    _, ext = os.path.splitext(upload_file.filename or "")
    token = uuid.uuid4().hex
    base = f"pre{prelevement_id}_iso{isolat_id}_{token}"
    original = os.path.join(upload_dir, f"{base}{ext}")
    cropped_name = f"{base}_cropped_{ext}"
    cropped = os.path.join(upload_dir, cropped_name)

    upload_file.save(original)

    cleanup_paths = [original, cropped]

    try:
        # Read & normalize
        img = imageio.imread(original)
        img = normalize_for_cv(
            img,
            prefer_color=prefer_color,
            force_color_if_gray=force_color_if_gray,
            force_grayscale=force_grayscale,
            force_float32=force_float32
        )

        # AST processing
        ast_obj = astimp.AST(img)

        # Check for disks immediately
        circles = getattr(ast_obj, "circles", [])
        if not circles:
            logger.error(
                "No disks detected; rejecting image. context=file=%s prelevement=%s isolat=%s",
                cropped_name, prelevement_id, isolat_id
            )
            raise ValueError(
                "Aucun disque détecté. Veuillez reprendre la photo (bonne netteté, lumière uniforme) et réessayer."
            )

        # Extract scale; must be positive
        px_per_mm = _extract_positive_px_per_mm(ast_obj)
        if px_per_mm is None:
            logger.error(
                "px_per_mm could not be calculated (no valid scale). context=file=%s prelevement=%s isolat=%s",
                cropped_name, prelevement_id, isolat_id
            )
            raise ValueError(
                "Échec du calcul de l'échelle (px/mm). Reprenez la photo (inclure une pastille/référence nette) et réessayez."
            )

        logger.info(
            "px_per_mm computed successfully value=%s context=file=%s prelevement=%s isolat=%s",
            px_per_mm, cropped_name, prelevement_id, isolat_id
        )

        # Crop normalization if provided
        crop_img = getattr(ast_obj, "crop", None)
        if crop_img is None:
            crop_img = img
        else:
            crop_img = normalize_for_cv(
                crop_img,
                prefer_color=prefer_color,
                force_color_if_gray=force_color_if_gray,
                force_grayscale=force_grayscale,
                force_float32=force_float32
            )

        imageio.imwrite(cropped, crop_img)

        # Insert diffusion image record
        image_id = repo.insert_diffusion_image(db, isolat_id, cropped_name, px_per_mm)

        # Assign disks
        mode = (boite_type or "").strip().lower()
        if mode == "pseudomonas 1":
            grid = pseudo_1
            _assign_manual(db, ast_obj, image_id, grid)
        else:
            _assign_auto(db, ast_obj, image_id)

        db.commit()
        return image_id

    except Exception:
        # Cleanup on failure if desired
        if DELETE_ON_ERROR:
            for p in cleanup_paths:
                try:
                    if os.path.exists(p):
                        os.remove(p)
                except OSError:
                    pass
        # Re-raise to propagate the error to caller
        raise


def _assign_manual(db, ast_obj, image_id, grid):
    circles = getattr(ast_obj, "circles", [])
    centers = np.array([c.center for c in circles], dtype=float)
    if centers.size == 0:
        return
    xs, ys = centers[:, 0], centers[:, 1]
    row_targets, row_assign = _derive_targets(ys)
    col_targets, col_assign = _derive_targets(xs)
    row_gate = _gate(row_targets)
    col_gate = _gate(col_targets)
    cell_map = {}
    for i, (x, y) in enumerate(centers):
        r = row_assign[i]
        c = col_assign[i]
        if not (0 <= r < 4 and 0 <= c < 4):
            continue
        if abs(y - row_targets[r]) > row_gate or abs(x - col_targets[c]) > col_gate:
            continue
        key = (r, c)
        if key in cell_map:
            prev = cell_map[key]
            pd = abs(centers[prev, 0] - col_targets[c]) + abs(centers[prev, 1] - row_targets[r])
            nd = abs(x - col_targets[c]) + abs(y - row_targets[r])
            if nd < pd:
                cell_map[key] = i
        else:
            cell_map[key] = i
    inhibitions = getattr(ast_obj, "inhibitions", [])
    for (r, c), idx in cell_map.items():
        if r >= len(grid) or c >= len(grid[r]):
            continue
        label = grid[r][c]
        if not label:
            continue
        diameter = 0
        if idx < len(inhibitions):
            d = getattr(inhibitions[idx], "diameter", 0) or 0
            try:
                diameter = int(d)
            except Exception:
                diameter = 0
        if diameter <= 0:
            diameter = int(getattr(circles[idx], "radius", 0) * 2)
        x, y = circles[idx].center
        repo.insert_disk(db, image_id, label, disk_dictionnary[label], x, y, diameter)


def _assign_auto(db, ast_obj, image_id):
    circles = getattr(ast_obj, "circles", [])
    inhibitions = getattr(ast_obj, "inhibitions", [])
    for i, circle in enumerate(circles):
        diameter = 0
        if i < len(inhibitions):
            d = getattr(inhibitions[i], "diameter", 0) or 0
            try:
                diameter = int(d)
            except Exception:
                diameter = 0
        if diameter <= 0:
            diameter = int(getattr(circle, "radius", 0) * 2)
        x, y = circle.center
        repo.insert_disk(db, image_id, "", "", x, y, diameter)


def _derive_targets(values):
    v = np.array(values, dtype=float)
    n = len(v)
    if n == 0:
        return np.linspace(0, 1, 4), np.array([], dtype=int)
    if n >= 4:
        centers = np.linspace(v.min(), v.max(), 4)
        assign = np.array([np.argmin(np.abs(centers - val)) for val in v])
    else:
        centers_small = np.linspace(v.min(), v.max(), n)
        if centers_small[-1] - centers_small[0] < 1e-6:
            centers = np.array([centers_small[0]] * 4)
        else:
            centers = np.linspace(centers_small[0], centers_small[-1], 4)
        assign = np.array([np.argmin(np.abs(centers - val)) for val in v])
    ordered = np.sort(centers)
    mapping = {c: i for i, c in enumerate(ordered)}
    assign_final = np.array([mapping[c] for c in centers[assign]], dtype=int)
    return ordered, assign_final


def _gate(t):
    diffs = np.diff(np.sort(t))
    diffs = diffs[diffs > 0]
    m = np.median(diffs) if len(diffs) else 0
    return max(5.0, 0.6 * m) if m > 0 else 99999

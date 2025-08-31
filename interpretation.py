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

"""
Interpretation logic for diffusion disks and extra (manual) disks.

This module encapsulates the logic previously embedded in the POST
/interpretative route so it can be reused and unit tested.
"""

from typing import Iterable, List, Dict, Tuple, Any
import repo
from seuils import get_cutoffs
from disks import get_antibiotic_order
from bottle import request

# Tuple index constants for elements returned by repo.list_diffusion_disks(...)
# Adjust these if the schema in repo changes.
DISK_ID_IDX = 0           # (guessing; not used here)
IMAGE_ID_IDX = 1          # (guessing; not used here)
DISK_LABEL_IDX = 2
ANTIBIOTIC_NAME_IDX = 3
# indexes 4,5 unknown
DIAMETER_IDX = 6

# For extra disks returned by repo.list_extra_disks(isolat_id)
# Based on your usage: (id, antibiotique, diameter, cmi, interpretation, is_cmi)
EXTRA_ID_IDX = 0
EXTRA_ANTIBIOTIC_IDX = 1
EXTRA_DIAMETER_IDX = 2
EXTRA_CMI_IDX = 3
EXTRA_INTERP_IDX = 4
EXTRA_IS_CMI_IDX = 5


def _select_best_disks(disks: Iterable[Tuple[Any, ...]]) -> List[Tuple[Any, ...]]:
    """
    From a list of raw disk tuples (possibly multiple per label),
    keep only the disk with the largest diameter for each disk label.
    Preserve deterministic ordering using antibiotic order then original enumeration index.
    """
    # Sort with stable fallback to original enumeration
    disks_sorted = sorted(
        enumerate(disks),
        key=lambda t: (get_antibiotic_order(t[1][DISK_LABEL_IDX]), t[0])
    )
    ordered_disks = [d for _, d in disks_sorted]

    best_by_label: Dict[str, Tuple[Any, ...]] = {}
    for disk in ordered_disks:
        label = disk[DISK_LABEL_IDX]
        diametre = disk[DIAMETER_IDX]
        current = best_by_label.get(label)
        if current is None or diametre > current[DIAMETER_IDX]:
            best_by_label[label] = disk

    # Return sorted by antibiotic order
    return sorted(
        best_by_label.values(),
        key=lambda d: get_antibiotic_order(d[DISK_LABEL_IDX])
    )


def _interpret_single_disk(disk, cutoffs_for_isolat: Dict[str, Dict[str, int]]):
    """
    Produce (antibiotique, diametre, interpretation, text_cutoffs) for a single kept disk.
    """
    label = disk[DISK_LABEL_IDX]
    antibiotique = disk[ANTIBIOTIC_NAME_IDX]
    diametre = disk[DIAMETER_IDX]

    if label in cutoffs_for_isolat:
        cfs = cutoffs_for_isolat[label]
        text_cutoffs = f'{cfs["seuil_R"]} - {cfs["seuil_S"]}'
        if diametre == 50 and cfs['seuil_S'] == 50:
            interpretation = 'Sensible à forte posologie'
        elif diametre >= cfs['seuil_S']:
            interpretation = 'Sensible'
        elif diametre < cfs['seuil_R']:
            interpretation = 'Résistant'
        else:
            interpretation = 'Sensible à forte posologie'
        return antibiotique, diametre, interpretation, text_cutoffs
    else:
        return antibiotique, diametre, 'Non interprétable', None


def interpret_and_persist(db, isolat_id: int):
    """
    Main orchestration:
      - Clears previous lectures for the isolat.
      - Builds lectures from diffusion disks (keeping best diameter per label).
      - Appends manual (extra) disks.
      - Initializes commentaire row (empty) if needed.

    Returns:
        count_inserted (int): total number of lectures inserted.
    """
    # Clear previous
    repo.delete_lectures_by_isolat(db, isolat_id)

    # Retrieve data
    diffusion_disks = repo.list_diffusion_disks(db, isolat_id)
    isolat_name = repo.get_isolat_name(db, isolat_id)
    cutoffs = get_cutoffs(isolat_name)

    # Filter best disks
    kept_disks = _select_best_disks(diffusion_disks)

    order = 0
    inserted = 0

    # Insert interpreted diffusion disks
    for disk in kept_disks:
        order += 1
        antibiotique, diametre, interpretation, text_cutoffs = _interpret_single_disk(disk, cutoffs)
        # cmi: None for diffusion disk, is_cmi: 0, extra_flag: 0
        repo.insert_lecture(
            db,
            antibiotique,
            isolat_id,
            0,          # extra_flag
            0,          # is_cmi
            interpretation,
            0,
            order,
            diametre,
            text_cutoffs,
            None        # cmi
        )
        inserted += 1

    # Manual / extra disks
    extra_disks = repo.list_extra_disks(db, isolat_id)
    for extra in extra_disks:
        order += 1
        antibiotique = extra[EXTRA_ANTIBIOTIC_IDX]
        diameter = extra[EXTRA_DIAMETER_IDX]
        cmi = extra[EXTRA_CMI_IDX]
        interpretation = extra[EXTRA_INTERP_IDX]
        is_cmi = extra[EXTRA_IS_CMI_IDX]
        repo.insert_lecture(
            db,
            antibiotique,
            isolat_id,
            1,          # extra_flag
            is_cmi,
            interpretation,
            0,
            order,
            diameter,
            None,       # text cutoffs not applicable
            cmi
        )
        inserted += 1

    # Initialize commentaire blank (idempotent: you may want to guard in repo)
    repo.init_commentaire(db, isolat_id, commentaire="")

    return inserted


# --------- Helper to process interpretative form (shared by save + print) ---------
def process_interpretative_form(db, prelevement_id, isolat_id):
    if not repo.prelevement_exists(db, prelevement_id):
        raise HTTPError(404)
    if repo.get_isolat_name(db, isolat_id) is None:
        raise HTTPError(404)

    raw_ids = (request.forms.get("lecture_ids") or "").strip()
    if not raw_ids:
        return template("error.tpl", code=400, message="Aucune ligne à mettre à jour")

    updates = []
    for part in raw_ids.split(","):
        part = part.strip()
        if not part:
            continue
        if not part.isdigit():
            return template("error.tpl", code=400, message=f"Identifiant de lecture invalide: {part}")
        lecture_id = int(part)

        antibiotique = request.forms.getunicode(f"antibiotique_{lecture_id}") or ""
        interpretation = request.forms.getunicode(f"interpretation_{lecture_id}") or ""
        is_masked_raw = request.forms.get(f"is_masked_{lecture_id}")
        is_masked = 1 if is_masked_raw == "1" else 0
        display_order_raw = request.forms.get(f"display_order_{lecture_id}") or ""
        try:
            display_order = int(display_order_raw)
        except ValueError:
            display_order = 999999

        updates.append({
            "lecture_id": lecture_id,
            "antibiotique": antibiotique,
            "interpretation": interpretation,
            "is_masked": is_masked,
            "display_order": display_order,
        })

    repo.bulk_update_lectures(db, isolat_id, updates)

    commentaire_text = request.forms.getunicode("commentaire") or ""
    existing_comment = repo.get_commentaire(db, isolat_id)
    if existing_comment:
        repo.update_commentaire(db, isolat_id, commentaire_text)
    else:
        repo.init_commentaire(db, isolat_id, commentaire_text)
        db.commit()

    # Return refreshed data
    lectures = repo.list_lectures(db, isolat_id)
    commentaire = repo.get_commentaire(db, isolat_id)
    isolat_name = repo.get_isolat_name(db, isolat_id)
    return lectures, commentaire, isolat_name

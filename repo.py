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

from disks import disk_dictionnary

def get_prelevement(db, prelevement_id):
    return db.execute("SELECT * FROM prelevements WHERE prelevement_id = ?", (prelevement_id,)).fetchone()

def prelevement_exists(db, prelevement_id):
    return get_prelevement(db, prelevement_id) is not None

def create_prelevement(db, prelevement_id, matricule_patient, nom, prenom, service, type_prelevement, date):
    db.execute(
        "INSERT INTO prelevements (prelevement_id, matricule_patient, nom, prenom, service, type_prelevement, date) "
        "VALUES (?, ?, ?, ?, ?, ?, ?)",
        (prelevement_id, matricule_patient, nom, prenom, service, type_prelevement, date),
    )
    db.commit()

def update_prelevement(db, prelevement_id, matricule_patient, nom, prenom, service, type_prelevement, date):
    db.execute(
        "UPDATE prelevements SET matricule_patient=?, nom=?, prenom=?, service=?, type_prelevement=?, date=? "
        "WHERE prelevement_id=?",
        (matricule_patient, nom, prenom, service, type_prelevement, date, prelevement_id),
    )
    db.commit()

def list_isolats_with_status(db, prelevement_id):
    return db.execute(
        """
        SELECT i.id, i.name,
               EXISTS(SELECT 1 FROM lectures l WHERE l.isolat_id = i.id) AS has_lectures
        FROM isolats i
        WHERE i.prelevement_id = ?
        """,
        (prelevement_id,),
    ).fetchall()

def create_isolat(db, name, prelevement_id):
    c = db.execute("INSERT INTO isolats (name, prelevement_id) VALUES (?, ?)", (name, prelevement_id))
    db.commit()
    return c.lastrowid

def delete_isolat(db, prelevement_id, isolat_id):
    db.execute("DELETE FROM isolats WHERE prelevement_id = ? AND id = ?", (prelevement_id, isolat_id))
    db.commit()

def get_isolat_name(db, isolat_id):
    row = db.execute("SELECT name FROM isolats WHERE id = ?", (isolat_id,)).fetchone()
    return row["name"] if row else None

def list_diffusion_images(db, isolat_id):
    return [dict(r) for r in db.execute(
        "SELECT image_id, path, px_per_mm FROM diffusion_images WHERE isolat_id = ?",
        (isolat_id,),
    ).fetchall()]

def list_disks_by_isolat(db, isolat_id):
    rows = db.execute(
        """
        SELECT di.image_id, dd.disk_id, dd.disk_label, dd.disk_full_name,
               dd.position_x, dd.position_y, dd.diameter
        FROM diffusion_images di
        LEFT JOIN diffusion_disks dd ON di.image_id = dd.image_id
        WHERE di.isolat_id = ? AND dd.disk_id IS NOT NULL
        """,
        (isolat_id,),
    ).fetchall()
    grouped = {}
    for r in rows:
        grouped.setdefault(r["image_id"], []).append(dict(r))
    return grouped

def list_diffusion_disks(db, isolat_id):
    rows = db.execute(
        """
        SELECT di.image_id, dd.disk_id, dd.disk_label, dd.disk_full_name,
               dd.position_x, dd.position_y, dd.diameter
        FROM diffusion_images di
        LEFT JOIN diffusion_disks dd ON di.image_id = dd.image_id
        WHERE di.isolat_id = ? AND dd.disk_id IS NOT NULL
        """,
        (isolat_id,),
    ).fetchall()
    return rows

def list_extra_disks(db, isolat_id):
    return db.execute(
        "SELECT disk_id, disk_full_name, diameter, cmi, interpretation, is_cmi FROM extra_disks WHERE isolat_id = ?",
        (isolat_id,),
    ).fetchall()

def get_image_path(db, image_id):
    row = db.execute("SELECT path FROM diffusion_images WHERE image_id = ?", (image_id,)).fetchone()
    return row["path"] if row else None

def insert_diffusion_image(db, isolat_id, path, px_per_mm):
    c = db.execute(
        "INSERT INTO diffusion_images (isolat_id, path, px_per_mm) VALUES (?, ?, ?)",
        (isolat_id, path, px_per_mm),
    )
    return c.lastrowid

def insert_disk(db, image_id, disk_label, disk_full_name, x, y, diameter):
    db.execute(
        "INSERT INTO diffusion_disks (image_id, disk_label, disk_full_name, position_x, position_y, diameter) "
        "VALUES (?, ?, ?, ?, ?, ?)",
        (image_id, disk_label, disk_full_name, int(x), int(y), int(diameter)),
    )

def delete_disks_by_image_id(db, image_id):
    db.execute("DELETE FROM diffusion_disks WHERE image_id = ?", (image_id,))

def save_disks_for_image(db, image_id, disks):
    delete_disks_by_image_id(db, image_id)
    for disk in disks:
        label = disk.get("disk_label")
        full_name = disk_dictionnary.get(label, "INCONNU")
        db.execute(
            "INSERT INTO diffusion_disks (image_id, disk_label, disk_full_name, position_x, position_y, diameter) "
            "VALUES (?, ?, ?, ?, ?, ?)",
            (
                image_id,
                label,
                full_name,
                disk.get("position_x"),
                disk.get("position_y"),
                disk.get("diameter"),
            ),
        )
    db.commit()

def delete_image_and_disks(db, image_id):
    db.execute("DELETE FROM diffusion_disks WHERE image_id = ?", (image_id,))
    db.execute("DELETE FROM diffusion_images WHERE image_id = ?", (image_id,))
    db.commit()

def insert_extra_disk_cmi(db, isolat_id, antibiotique, valeur_cmi, interpretation):
    db.execute(
        "INSERT INTO extra_disks (isolat_id, disk_full_name, cmi, is_cmi, interpretation) "
        "VALUES (?, ?, ?, 1, ?)",
        (isolat_id, antibiotique, valeur_cmi, interpretation),
    )

def insert_extra_disk_diametre(db, isolat_id, antibiotique, valeur_diametre, interpretation):
    db.execute(
        "INSERT INTO extra_disks (isolat_id, disk_full_name, diametre, is_cmi, interpretation) "
        "VALUES (?, ?, ?, 0, ?)",
        (isolat_id, antibiotique, valeur_diametre, interpretation),
    )

def delete_extra_disk(db, disk_id):
    db.execute("DELETE FROM extra_disks WHERE disk_id = ?", (disk_id,))
    db.commit()

def delete_lectures_by_isolat(db, isolat_id):
    db.execute("DELETE FROM lectures WHERE isolat_id = ?", (isolat_id,))
    db.commit()

def insert_lecture(db, antibiotique, isolat_id, is_extra_disk, is_cmi, interpretation, is_masked, display_order, diametre, cutoffs, cmi):
    db.execute(
        "INSERT INTO lectures (antibiotique, isolat_id, is_extra_disk, is_cmi, interpretation, is_masked, display_order, diametre, cutoffs, cmi)"
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        (antibiotique, isolat_id, is_extra_disk, is_cmi, interpretation, is_masked, display_order, diametre, cutoffs, cmi),
    )

def init_commentaire(db, isolat_id, commentaire):
    db.execute(
        "INSERT INTO commentaires (isolat_id, commentaire)"
        "VALUES (?, ?)",
        (isolat_id, commentaire),
    )

def list_lectures(db, isolat_id):
    return db.execute("SELECT * FROM lectures WHERE isolat_id = ? ORDER BY display_order", (isolat_id,)).fetchall()

def get_commentaire(db, isolat_id):
    return db.execute(
        "SELECT * FROM commentaires WHERE isolat_id = ?",(isolat_id,),
    ).fetchone()

def update_commentaire(db, isolat_id, commentaire):
    db.execute(
        "UPDATE commentaires SET commentaire = ? WHERE isolat_id = ?",(commentaire, isolat_id,),
    )

def update_lecture(db, lecture_id, isolat_id, antibiotique, interpretation, is_masked, display_order):
    """
    Update a single lecture row. Constrains by isolat_id for safety.
    """
    db.execute(
        """
        UPDATE lectures
        SET antibiotique = ?, interpretation = ?, is_masked = ?, display_order = ?
        WHERE lecture_id = ? AND isolat_id = ?
        """,
        (antibiotique, interpretation, is_masked, display_order, lecture_id, isolat_id),
    )

def bulk_update_lectures(db, isolat_id, updates):
    """
    updates: iterable of dicts with keys:
      lecture_id, antibiotique, interpretation, is_masked, display_order
    Executes in a single transaction/commit.
    """
    for u in updates:
        update_lecture(
            db,
            u["lecture_id"],
            isolat_id,
            u["antibiotique"],
            u["interpretation"],
            u["is_masked"],
            u["display_order"],
        )
    db.commit()

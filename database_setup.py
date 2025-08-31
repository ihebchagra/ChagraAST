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

import sqlite3

conn = sqlite3.connect('chagra.db')
c = conn.cursor()

# Create prelevements table
c.execute('''
    CREATE TABLE IF NOT EXISTS prelevements (
        prelevement_id TEXT NOT NULL PRIMARY KEY,
        matricule_patient TEXT NOT NULL,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        service TEXT NOT NULL,
        type_prelevement TEXT NOT NULL,
        date TEXT NOT NULL
    )
''')

c.execute('''
    CREATE TABLE IF NOT EXISTS isolats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        prelevement_id TEXT NOT NULL,
        FOREIGN KEY (prelevement_id) REFERENCES prelevements(prelevement_id)
    );
''')

# Create diffusion_images table
c.execute('''
    CREATE TABLE IF NOT EXISTS diffusion_images (
        image_id INTEGER PRIMARY KEY AUTOINCREMENT,
        isolat_id INTEGER NOT NULL,
        path TEXT NOT NULL,
        px_per_mm REAL NOT NULL,
        FOREIGN KEY (isolat_id) REFERENCES isolats (id)
    )
''')

# Create diffusion_disks table
c.execute('''
    CREATE TABLE IF NOT EXISTS diffusion_disks (
        disk_id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_id INTEGER NOT NULL,
        disk_label TEXT NOT NULL,
        disk_full_name TEXT,
        position_x REAL NOT NULL,
        position_y REAL NOT NULL,
        diameter REAL NOT NULL,
        FOREIGN KEY (image_id) REFERENCES diffusion_images (image_id)
    )
''')

# Create extra_disks table
c.execute('''
    CREATE TABLE IF NOT EXISTS extra_disks (
        disk_id INTEGER PRIMARY KEY AUTOINCREMENT,
        isolat_id INTEGER NOT NULL,
        disk_full_name TEXT NOT NULL,
        diameter REAL,
        cmi REAL,
        is_cmi INT NOT NULL,
        interpretation TEXT NOT NULL,
        FOREIGN KEY (isolat_id) REFERENCES isolats (id)
    )
''')

# Create lectures table
c.execute('''
    CREATE TABLE IF NOT EXISTS lectures (
        lecture_id INTEGER PRIMARY KEY AUTOINCREMENT,
        antibiotique TEXT NOT NULL,
        isolat_id INTEGER NOT NULL,
        is_extra_disk BOOLEAN NOT NULL,
        is_cmi BOOLEAN NOT NULL,
        interpretation TEXT NOT NULL,
        is_masked BOOLEAN NOT NULL,
        diametre INT,
        cmi REAL,
        display_order INTEGER NOT NULL,
        cutoffs TEXT,
        FOREIGN KEY (isolat_id) REFERENCES isolats (id)
    )
''')

c.execute('''
    CREATE TABLE IF NOT EXISTS commentaires (
        commentaire_id INTEGER PRIMARY KEY AUTOINCREMENT,
        commentaire TEXT,
        isolat_id INTEGER NOT NULL,
        FOREIGN KEY (isolat_id) REFERENCES isolats (id)
    )
''')


conn.commit()
conn.close()

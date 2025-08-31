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
import json
from bottle import Bottle, run, template, static_file, TEMPLATE_PATH, request, redirect, HTTPError, response
import bottle_sqlite

from constants import BACTERIA_LIST
import repo
from image_processing import process_plate
from seuils import get_cutoffs
from boites import get_boite_types
from disks import get_antibiotic_order
from interpretation import interpret_and_persist, process_interpretative_form
import datetime

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
TEMPLATE_DIR = os.path.join(BASE_DIR, "templates")
STATIC_DIR = os.path.join(BASE_DIR, "static")
UPLOAD_DIR = os.path.join(STATIC_DIR, "upload")
os.makedirs(UPLOAD_DIR, exist_ok=True)
if TEMPLATE_DIR not in TEMPLATE_PATH:
    TEMPLATE_PATH.insert(0, TEMPLATE_DIR)

response.content_type = 'text/html; charset=UTF-8'

app = Bottle()
app.install(bottle_sqlite.Plugin(dbfile="chagra.db"))

@app.error(404)
def e404(_):
    return template("error.tpl", code=404, message="Introuvable")

@app.error(500)
def e500(err):
    return template("error.tpl", code=500, message="Erreur interne")

@app.get("/static/<filepath:path>")
def static_(filepath):
    return static_file(filepath, root=STATIC_DIR)

@app.get("/")
def home():
    return template("index.tpl")

@app.get("/ajouter_prelevement")
def ajouter_prelevement_form():
    return template("ajouter_prelevement.tpl")

@app.post("/ajouter_prelevement")
def ajouter_prelevement_submit(db):
    pid = (request.forms.get("prelevement_id") or "").strip()
    if not pid:
        return template("error.tpl", code=400, message="ID prélèvement manquant")
    if repo.prelevement_exists(db, pid):
        redirect(f"/prelevement/{pid}")
    else:
        redirect(f"/nouveau_prelevement/{pid}")

@app.get("/nouveau_prelevement/<prelevement_id>")
def nouveau_prelevement_form(prelevement_id):
    return template("nouveau_prelevement.tpl", prelevement_id=prelevement_id)

@app.post("/nouveau_prelevement/<prelevement_id>")
def nouveau_prelevement_submit(db, prelevement_id):
    if repo.prelevement_exists(db, prelevement_id):
        return template("error.tpl", code=409, message="Existe déjà")
    f = request.forms
    repo.create_prelevement(
        db,
        prelevement_id,
        f.get("matricule_patient"),
        f.get("nom"),
        f.get("prenom"),
        f.get("service"),
        f.get("type_prelevement"),
        f.get("date"),
    )
    redirect(f"/prelevement/{prelevement_id}")

@app.get("/prelevement/<prelevement_id>")
def prelevement_detail(prelevement_id, db):
    p = repo.get_prelevement(db, prelevement_id)
    if not p:
        raise HTTPError(404)
    isolats = repo.list_isolats_with_status(db, prelevement_id)
    return template("prelevement.tpl", prelevement=p, isolats=isolats)

@app.get("/modifier_prelevement/<prelevement_id>")
def modifier_prelevement_get(prelevement_id, db):
    p = repo.get_prelevement(db, prelevement_id)
    if not p:
        raise HTTPError(404)
    return template("modifier_prelevement.tpl", prelevement=p)

@app.post("/modifier_prelevement/<prelevement_id>")
def modifier_prelevement_post(prelevement_id, db):
    if not repo.prelevement_exists(db, prelevement_id):
        raise HTTPError(404)
    f = request.forms
    repo.update_prelevement(
        db,
        prelevement_id,
        f.get("matricule_patient"),
        f.get("nom"),
        f.get("prenom"),
        f.get("service"),
        f.get("type_prelevement"),
        f.get("date"),
    )
    redirect(f"/prelevement/{prelevement_id}")

@app.get("/prelevement/<prelevement_id>/ajouter_isolat")
def ajouter_isolat_form(prelevement_id, db):
    if not repo.prelevement_exists(db, prelevement_id):
        raise HTTPError(404)
    return template("ajouter_isolat.tpl", prelevement_id=prelevement_id, bacteria_list=BACTERIA_LIST)

@app.post("/prelevement/<prelevement_id>/ajouter_isolat")
def ajouter_isolat_submit(prelevement_id, db):
    if not repo.prelevement_exists(db, prelevement_id):
        raise HTTPError(404)
    name = (request.forms.get("isolat_name") or "").strip()
    if not name:
        return template("error.tpl", code=400, message="Nom isolat requis")
    isolat_id = repo.create_isolat(db, name, prelevement_id)
    redirect(f"/prelevement/{prelevement_id}/isolat/{isolat_id}/brute")

@app.post("/prelevement/<prelevement_id>/delete_isolat/<isolat_id:int>")
def delete_isolat(prelevement_id, isolat_id, db):
    if not repo.prelevement_exists(db, prelevement_id):
        raise HTTPError(404)
    repo.delete_isolat(db, prelevement_id, isolat_id)
    redirect(f"/prelevement/{prelevement_id}")

@app.get("/prelevement/<prelevement_id>/isolat/<isolat_id:int>/brute")
def brute_get(prelevement_id, isolat_id, db):
    if not repo.prelevement_exists(db, prelevement_id):
        raise HTTPError(404)
    isolat_name = repo.get_isolat_name(db, isolat_id)
    if isolat_name is None:
        raise HTTPError(404)
    images = repo.list_diffusion_images(db, isolat_id)
    disks = repo.list_disks_by_isolat(db, isolat_id)
    disks_json = {img_id: json.dumps(v) for img_id, v in disks.items()}
    extra = repo.list_extra_disks(db, isolat_id)
    antibiotics_json = json.dumps(get_cutoffs(isolat_name))
    boite_types = get_boite_types(isolat_name)
    return template(
        "brute.tpl",
        prelevement_id=prelevement_id,
        isolat_id=isolat_id,
        isolat_name=isolat_name,
        images=images,
        diffusion_disks_json=disks_json,
        extra_disks=extra,
        antibiotics_json=antibiotics_json,
        boite_types=boite_types
    )

@app.post("/prelevement/<prelevement_id:int>/isolat/<isolat_id:int>/add_boite")
def add_boite(prelevement_id, isolat_id, db):
    if not repo.prelevement_exists(db, prelevement_id):
        raise HTTPError(404)
    if repo.get_isolat_name(db, isolat_id) is None:
        raise HTTPError(404)
    upload = request.files.get("diffusion_image")
    boite_type = (request.forms.get("boite_type") or "").strip()
    try:
        process_plate(db, upload, UPLOAD_DIR, prelevement_id, isolat_id, boite_type)
    except Exception as e:
        return template("error.tpl", code=400, message=str(e))
    redirect(f"/prelevement/{prelevement_id}/isolat/{isolat_id}/brute")

@app.post("/prelevement/<prelevement_id>/isolat/<isolat_id:int>/delete_image")
def delete_image(prelevement_id, isolat_id, db):
    if not repo.prelevement_exists(db, prelevement_id):
        raise HTTPError(404)
    if repo.get_isolat_name(db, isolat_id) is None:
        raise HTTPError(404)
    image_id_raw = (request.forms.get("image_id") or "").strip()
    if not image_id_raw.isdigit():
        return template("error.tpl", code=400, message="ID image invalide")
    image_id = int(image_id_raw)
    path = repo.get_image_path(db, image_id)
    if not path:
        return template("error.tpl", code=404, message="Image absente")
    fp = os.path.join(UPLOAD_DIR, path)
    try:
        if os.path.exists(fp):
            os.remove(fp)
    except OSError:
        pass
    repo.delete_image_and_disks(db, image_id)
    redirect(f"/prelevement/{prelevement_id}/isolat/{isolat_id}/brute")

@app.post("/prelevement/<prelevement_id>/isolat/<isolat_id:int>/enregistrer_disques")
def enregistrer_disques(prelevement_id, isolat_id, db):
    if not repo.prelevement_exists(db, prelevement_id):
        raise HTTPError(404)
    if repo.get_isolat_name(db, isolat_id) is None:
        raise HTTPError(404)

    for key, value in request.forms.items():
        if key.startswith("disks-"):
            image_id = int(key.split("-")[1])
            disks_data = json.loads(value)
            repo.save_disks_for_image(db, image_id, disks_data)

    redirect(f"/prelevement/{prelevement_id}/isolat/{isolat_id}/brute")

@app.post("/prelevement/<prelevement_id>/isolat/<isolat_id:int>/save_then_add_boite")
def save_then_add(prelevement_id, isolat_id, db):
    if not repo.prelevement_exists(db, prelevement_id):
        raise HTTPError(404)
    if repo.get_isolat_name(db, isolat_id) is None:
        raise HTTPError(404)

    for key, value in request.forms.items():
        if key.startswith("disks-"):
            image_id = int(key.split("-")[1])
            disks_data = json.loads(value)
            repo.save_disks_for_image(db, image_id, disks_data)

    upload = request.files.get("diffusion_image")
    boite_type = (request.forms.get("boite_type") or "").strip()
    try:
        process_plate(db, upload, UPLOAD_DIR, prelevement_id, isolat_id, boite_type)
    except Exception as e:
        return template("error.tpl", code=400, message=str(e))

    redirect(f"/prelevement/{prelevement_id}/isolat/{isolat_id}/brute")

@app.post("/prelevement/<prelevement_id>/isolat/<isolat_id:int>/add_extra_disk")
def add_extra_disk(prelevement_id, isolat_id, db):
    if not repo.prelevement_exists(db, prelevement_id):
        raise HTTPError(404)
    if repo.get_isolat_name(db, isolat_id) is None:
        raise HTTPError(404)

    antibiotique = request.forms.getunicode("nom_antibiotique")
    type_mesure = request.forms.get("type_mesure")
    valeur_cmi = request.forms.get("valeur_cmi")
    valeur_diametre = request.forms.get("valeur_diametre")
    interpretation = request.forms.getunicode("interpretation")

    if type_mesure == "cmi":
        repo.insert_extra_disk_cmi(db, isolat_id, antibiotique, valeur_cmi, interpretation)
    elif type_mesure == "diametre":
        repo.insert_extra_disk_diametre(db, isolat_id, antibiotique, valeur_diametre, interpretation)

    redirect(f"/prelevement/{prelevement_id}/isolat/{isolat_id}/brute")

@app.post("/prelevement/<prelevement_id>/isolat/<isolat_id:int>/delete_extra_disk/<disk_id:int>")
def delete_extra_disk(prelevement_id, isolat_id, disk_id, db):
    if not repo.prelevement_exists(db, prelevement_id):
        raise HTTPError(404)
    if repo.get_isolat_name(db, isolat_id) is None:
        raise HTTPError(404)
    try:
        repo.delete_extra_disk(db, disk_id)
    except Exception as e:
        return template("error.tpl", code=400, message=str(e))

    redirect(f"/prelevement/{prelevement_id}/isolat/{isolat_id}/brute")

@app.post("/prelevement/<prelevement_id>/isolat/<isolat_id:int>/interpretative")
def interpret_disks_route(prelevement_id, isolat_id, db):
    # Delegate to the refactored logic
    interpret_and_persist(db, isolat_id)
    redirect(f"/prelevement/{prelevement_id}/isolat/{isolat_id}/interpretative")

@app.get("/prelevement/<prelevement_id>/isolat/<isolat_id:int>/interpretative")
def lecture_interpretative(prelevement_id, isolat_id, db):
    lectures = repo.list_lectures(db, isolat_id)
    isolat_name = repo.get_isolat_name(db, isolat_id)
    commentaire = repo.get_commentaire(db, isolat_id)
    return template(
        "interpretative.tpl",
        prelevement_id=prelevement_id,
        isolat_id=isolat_id,
        isolat_name=isolat_name,
        lectures=lectures,
        commentaire=commentaire
    )

@app.post("/prelevement/<prelevement_id>/isolat/<isolat_id:int>/reinterpret")
def reinterpret_update(prelevement_id, isolat_id, db):
    result = process_interpretative_form(db, prelevement_id, isolat_id)
    if isinstance(result, str):  # error template returned
        return result
    # redirect after successful save
    redirect(f"/prelevement/{prelevement_id}/isolat/{isolat_id}/interpretative")

@app.post("/prelevement/<prelevement_id>/isolat/<isolat_id:int>/print")
def print_interpretative(prelevement_id, isolat_id, db):
    result = process_interpretative_form(db, prelevement_id, isolat_id)
    if isinstance(result, str):  # error template returned
        return result
    lectures, commentaire, isolat_name = result
    prelevement = repo.get_prelevement(db, prelevement_id)
    return template(
        "print.tpl",
        prelevement=prelevement,
        isolat_id=isolat_id,
        isolat_name=isolat_name,
        lectures=lectures,
        commentaire=commentaire,
        datetime = datetime
    )

@app.get("/license")
def license_page():
    return template("license.tpl")

@app.get("/README")
def readme_page():
    return static_file("README.md", root=BASE_DIR)

if __name__ == "__main__":
    run(app, host="0.0.0.0", port=6420, debug=False)

<!--
  
  Copyright (C) 2025 Iheb Chagra
  
  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
  
-->

% rebase('layout.tpl', title='Lecture Brute')

<h1>Lecture Brute : <i>{{isolat_name}}</i></h1>
<p>
  <a href="/prelevement/{{prelevement_id}}">&larr; Retour au prélèvement</a>
</p>

% if images:
<!-- ===================== Lecture des boîtes ===================== -->
<form action="/prelevement/{{prelevement_id}}/isolat/{{isolat_id}}/enregistrer_disques" method="post" id="lecture-brute-form">
  <fieldset>
    <legend><h2>Lecture des boites</h2></legend>

    % for image in images:
    <hr>
    <div class="image-wrapper">
      <img id="img-{{image['image_id']}}"
           src="/static/upload/{{image['path']}}"
           alt="Boite #{{image['image_id']}}">
      <canvas id="canvas-{{image['image_id']}}"
              data-px-per-mm="{{image['px_per_mm']}}"></canvas>
    </div>

    <!-- Delete button uses formaction; no nested form -->
    <button type="submit"
            formnovalidate
            formmethod="post"
            formaction="/prelevement/{{prelevement_id}}/isolat/{{isolat_id}}/delete_image"
            name="image_id"
            value="{{image['image_id']}}"
            onclick="return confirm('Êtes-vous sûr de vouloir supprimer définitivement cette boîte et toutes ses données ?');">
      Supprimer cette boîte
    </button>

    <!-- Data for this image -->
    <script id="disks-data-{{image['image_id']}}" type="application/json">
      {{!diffusion_disks_json.get(image['image_id'], '[]')}}
    </script>
    <input type="hidden" name="disks-{{image['image_id']}}" id="disks-input-{{image['image_id']}}">
    % end

    <hr>
    <button type="submit" id="save-disks-btn">Enregistrer</button>
  </fieldset>
</form>
% end

<!-- ===================== Ajouter une boîte ===================== -->
<fieldset>
  <legend><h2>Ajouter une Boite</h2></legend>
  <form
        action={{f"/prelevement/{prelevement_id}/isolat/{isolat_id}/add_boite" if not images else f"/prelevement/{prelevement_id}/isolat/{isolat_id}/save_then_add_boite" }}
        method="post"
        enctype="multipart/form-data">
    <label for="boite_type">Type de boîte :</label>
    <select id="boite_type" name="boite_type" required>
    % for boite_type in boite_types:
      <option value="{{boite_type}}" selected>{{boite_type}}</option>
    % end
      <option value="automatic">Détection Automatique</option>
    </select>

    <label for="diffusion_image">Choisir une image :</label>
    <input type="file" id="diffusion_image" name="diffusion_image" accept="image/*" required />

    % for image in images:
        <input type="hidden" name="disks-{{image['image_id']}}" id="disks-input-for-save-{{image['image_id']}}">
    % end

    <button type="submit">
        % if images:
            Ajouter la boîte et enregistrer
        % else:
            Ajouter
        % end
    </button>
  </form>
</fieldset>

<!-- ===================== Custom Context Menu ===================== -->
<div id="custom-context-menu" class="context-menu">
  <ul>
    <li id="context-add">Ajouter une zone d'inhibition</li>
    <li id="context-rename">Renommer ce disque</li>
    <li id="context-delete">Supprimer cette zone</li>
  </ul>
</div>

<!-- ===================== Tableau des disques supplémentaires ===================== -->
% if extra_disks :
<fieldset>
    <legend><h2>Antibiotiques supplémentaires</h2></legend>
    <table>
        <thead>
            <tr>
                <th>Antibiotique</th>
                <th>CMI</th>
                <th>Diamètre</th>
                <th>Interprétation</th>
                <th>Supprimer</th>
            </tr>
        </thead>
        <tbody>
            % for extra_disk in extra_disks:
            <tr>
                <td>{{extra_disk[1]}}</td>
                <td>{{extra_disk[3] if extra_disk[3] else '-'}}</td>
                <td>{{extra_disk[2] if extra_disk[2] else '-'}}</td>
                <td>{{extra_disk[4]}}</td>
                <td>
                    <form action="/prelevement/{{prelevement_id}}/isolat/{{isolat_id}}/delete_extra_disk/{{extra_disk[0]}}" method="post" onclick="return confirm('Êtes-vous sûr de vouloir supprimer définitivement cette boîte et toutes ses données ?');">
                        <button type="submit">Supprimer</button>
                    </form>
                </td>
            </tr>
            % end
        </tbody>
    </table>
</fieldset>
% end

<!-- ===================== Antibiotiques supplémentaires ===================== -->
<fieldset>
    <legend><h2>Ajouter un antibiotique</h2></legend>
    <form action="/prelevement/{{prelevement_id}}/isolat/{{isolat_id}}/add_extra_disk" method="post">

        <label>Antibiotique :
        <input type="text" name="nom_antibiotique" placeholder="ex : Colistine" autocomplete="off" required/>
        </label>
        <br>
        <label>
          <input type="radio" name="type_mesure" value="cmi" checked required />
          CMI
        </label>
        <label>
          <input type="radio" name="type_mesure" value="diametre" required />
          Diamètre d'inhibition
        </label>

        <br>
        <div id="cmi-container">
          <label for="valeur_cmi">Valeur CMI (mg/l) :</label>
          <input type="number" id="valeur_cmi" name="valeur_cmi" step="any" autocomplete="off" placeholder="ex. 0.5" />
        </div>

        <div id="diametre-container" hidden>
          <label for="valeur_diametre">Diamètre d'inhibition (mm) :</label>
          <input type="number" id="valeur_diametre" name="valeur_diametre" step="1" min="6" max="50" autocomplete="off" placeholder="6–50" />
        </div>

        <label for="interpretation">Interprétation :</label>
        <select id="interpretation" name="interpretation" required>
          <option value="">— Sélectionnez —</option>
          <option value="Sensible">Sensible</option>
          <option value="Sensible à forte posologie">Sensible à forte posologie</option>
          <option value="Résistant">Résistant</option>
          <option value="Zone d'incertitude technique">Zone d'incertitude technique</option>
          <option value="Non interprétable">Non interprétable</option>
          <option value="Information uniquement">Information uniquement</option>
        </select>

        <button type="submit">Ajouter</button>
    </form>
</fieldset>

<!-- ===================== Lecture Interprétative ===================== -->
% if (extra_disks or diffusion_disks_json):
<fieldset id="interpretative-fieldset">
    <legend><h2>Lecture Interprétative</h2></legend>
    <p><b style="display:none;" id="interpretative-warning">NB :  
        Des modifications non enregistrées ont été détectées. Cliquez d'abord sur "Enregistrer".
    </b></p>
    <form action="/prelevement/{{prelevement_id}}/isolat/{{isolat_id}}/interpretative" method="post">
      <button type="submit" id="interpretative-btn">Passer à la lecture interprétative</button>
    </form>

</fieldset>
% end



<style>
  .image-wrapper {
    position: relative;
    display: inline-block;
    max-width: 100%;
    margin: 0 1rem 1.5rem 0;
    vertical-align: top;
  }
  .image-wrapper img {
    display: block;
    max-width: 100%;
    height: auto;
  }
  .image-wrapper canvas {
    position: absolute;
    top: 0;
    left: 0;
  }

  .context-menu {
    display: none;
    position: absolute;
    z-index: 1000;
    background: #fff;
    border: 1px solid #ccc;
    min-width: 220px;
    font-size: 14px;
    border-radius: 4px;
    padding: 4px 0;
    box-shadow: 0 4px 10px rgba(0,0,0,0.15);
  }
  .context-menu ul {
    list-style: none;
    margin: 0;
    padding: 0;
  }
  .context-menu li {
    padding: 8px 15px;
    cursor: pointer;
    user-select: none;
  }
  .context-menu li:hover {
    background-color: #f2f2f2;
  }

  #interpretative-btn[disabled] {
    opacity: .6;
    cursor: not-allowed;
  }
</style>

<!-- ===================== Antibiotics Rules Data ===================== -->
<script id="antibiotics-data" type="application/json">{{!antibiotics_json}}</script>

<script>
/*
  ================================================================
  Diffusion Disk Editor
  - Draws inhibition zones over images
  - Supports: add, drag, resize, rename, delete via context menu
  - Enhancement: any modification after initial load disables the
    "Passer à la lecture interprétative" button until save.
  ================================================================
*/
document.addEventListener('DOMContentLoaded', initDiffusionEditors);

let GLOBAL_DISKS_DIRTY = false;

function markDisksDirty() {
  if (GLOBAL_DISKS_DIRTY) return;
  GLOBAL_DISKS_DIRTY = true;
  const interpretBtn = document.getElementById('interpretative-btn');
  const warning = document.getElementById('interpretative-warning');
  if (interpretBtn) {
    interpretBtn.disabled = true;
    interpretBtn.title = 'Enregistrez vos modifications avant de continuer.';
  }
  if (warning) {
    warning.style.display = 'block';
  }
}

function resetDisksDirtyAfterSave() {
  GLOBAL_DISKS_DIRTY = false;
  const interpretBtn = document.getElementById('interpretative-btn');
  const warning = document.getElementById('interpretative-warning');
  if (interpretBtn) {
    interpretBtn.disabled = false;
    interpretBtn.title = '';
  }
  if (warning) {
    warning.style.display = 'none';
  }
}

function initDiffusionEditors() {
  const antibiotics = safeParseJSON(document.getElementById('antibiotics-data')?.textContent, {});
  const observer = new ResizeObserver(onImageResize);

  document.querySelectorAll('.image-wrapper img').forEach(img => observer.observe(img));

  function onImageResize(entries) {
    for (const entry of entries) {
      const img = entry.target;
      if (entry.contentRect.width > 0 && !img.dataset.canvasInitialized) {
        const imageId = img.id.split('-')[1];
        const canvas = document.getElementById('canvas-' + imageId);
        if (!canvas) continue;
        canvas.width = img.offsetWidth;
        canvas.height = img.offsetHeight;
        setupCanvas(canvas, imageId, img, antibiotics);
        img.dataset.canvasInitialized = 'true';
      }
    }
  }

  // When the main brute lecture form is submitted we consider we are saving
  const bruteForm = document.getElementById('lecture-brute-form');
  if (bruteForm) {
    bruteForm.addEventListener('submit', () => {
      // Allow navigation; server reload will reset state anyway.
      // We could set a flag to avoid disabling interpretative button mid-submit.
      resetDisksDirtyAfterSave();
    });
  }
}

/* -------------------- Utility Helpers -------------------- */
function safeParseJSON(raw, fallback) {
  try {
    return JSON.parse(raw);
  } catch (e) {
    console.warn('JSON parse error:', e);
    return fallback;
  }
}

/* ================================================================
   Canvas Setup Per Image
================================================================ */
function setupCanvas(canvas, imageId, imgElement, antibiotics) {
  /* --------------- Configuration Constants --------------- */
  const CONFIG = {
    MIN_DIAMETER_MM: 6,
    MAX_DIAMETER_MM: 50,
    DIAMETER_STROKE_WIDTH: 1,
    FONT_SIZE_LABEL: 14,
    FONT_SIZE_DIAMETER: 18,
    RESIZE_EDGE_TOLERANCE_PX: 8,
    COLORS: {
      S: '#18a715',
      I: '#ffc107',
      R: '#dc3545',
      default: '#cccccc'
    }
  };

  /* --------------- State --------------- */
  const ctx = canvas.getContext('2d');
  const disksInput = document.getElementById('disks-input-' + imageId);
  const disksInputForSave = document.getElementById('disks-input-for-save-' + imageId);
  const pxPerMm = parseFloat(canvas.dataset.pxPerMm);
  const scale = imgElement.offsetWidth / imgElement.naturalWidth;
  const PHYSICAL_DISK_RADIUS_PX = (CONFIG.MIN_DIAMETER_MM / 2) * pxPerMm * scale;

  const state = {
    circles: [],
    activeCircle: null,
    action: null
  };
  let contextTarget = { circle: null, pos: null };

  /* --------------- Initialization of Circles from Backend --------------- */
  const initialDisks = safeParseJSON(
    document.getElementById('disks-data-' + imageId)?.textContent || '[]',
    []
  );

  initialDisks.forEach(disk => {
    const diameter_mm = clampDiameter(Math.round(disk.diameter));
    state.circles.push(makeCircle({
      id: disk.disk_id,
      label: (disk.disk_label || '').toUpperCase(),
      x: disk.position_x * scale,
      y: disk.position_y * scale,
      diameter_mm
    }));
  });

  /* --------------- Context Menu Elements --------------- */
  const contextMenu = document.getElementById('custom-context-menu');
  const addOption = document.getElementById('context-add');
  const deleteOption = document.getElementById('context-delete');
  const renameOption = document.getElementById('context-rename');

  /* --------------- Circle Factory --------------- */
  function makeCircle({ id = null, label = '', x, y, diameter_mm }) {
    return {
      id,
      label: label.trim(),
      x,
      y,
      diameter_mm,
      get radius() {
        return (this.diameter_mm / 2) * pxPerMm * scale;
      },
      set radius(rPx) {
        const mmDiameter = ((rPx * 2) / scale) / pxPerMm;
        this.diameter_mm = clampDiameter(Math.round(mmDiameter));
      }
    };
  }

  /* --------------- Drawing --------------- */
  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    state.circles.forEach(circle => {
      const interpretation = getInterpretation(circle.label, circle.diameter_mm);
      const color = CONFIG.COLORS[interpretation.status] || CONFIG.COLORS.default;

      // Outer inhibition zone diameter
      ctx.beginPath();
      ctx.arc(circle.x, circle.y, circle.radius, 0, 2 * Math.PI);
      ctx.strokeStyle = color;
      ctx.lineWidth = CONFIG.DIAMETER_STROKE_WIDTH;
      ctx.stroke();

      // Physical disk (center)
      ctx.beginPath();
      ctx.arc(circle.x, circle.y, PHYSICAL_DISK_RADIUS_PX, 0, 2 * Math.PI);
      ctx.fillStyle = 'rgba(255, 255, 255, 0.25)';
      ctx.fill();
      ctx.strokeStyle = '#000';
      ctx.lineWidth = 1;
      ctx.stroke();

      // Label
      ctx.fillStyle = '#000';
      ctx.font = 'bold ' + CONFIG.FONT_SIZE_LABEL + 'px Arial';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      if (circle.label) {
        ctx.fillText(circle.label, circle.x, circle.y);
      }

      // Diameter (above)
      ctx.font = CONFIG.FONT_SIZE_DIAMETER + 'px Arial';
      ctx.fillStyle = color;
      let diameterTextY = circle.y - circle.radius - (CONFIG.FONT_SIZE_DIAMETER / 2);
      diameterTextY = Math.max(diameterTextY, CONFIG.FONT_SIZE_DIAMETER / 2 + 2);
      ctx.fillText(circle.diameter_mm + 'mm', circle.x, diameterTextY);
    });
  }

  /* --------------- Helpers --------------- */
  function clampDiameter(d) {
    return Math.max(CONFIG.MIN_DIAMETER_MM, Math.min(d, CONFIG.MAX_DIAMETER_MM));
  }

  function getInterpretation(label, diameter_mm) {
    const rules = antibiotics[label];
    if (!rules || rules.seuil_S === undefined || rules.seuil_R === undefined) {
      return { status: 'default' };
    }
    if (diameter_mm == 50 && rules.seuil_S == 50) return { status: 'I' };
    if (diameter_mm >= rules.seuil_S) return { status: 'S' };
    if (diameter_mm < rules.seuil_R) return { status: 'R' };
    return { status: 'I' };
  }

  function getMousePos(e) {
    const rect = canvas.getBoundingClientRect();
    return { x: e.clientX - rect.left, y: e.clientY - rect.top };
  }

  function getTarget(pos) {
    for (let i = state.circles.length - 1; i >= 0; i--) {
      const circle = state.circles[i];
      const dist = Math.hypot(pos.x - circle.x, pos.y - circle.y);
      if (dist <= PHYSICAL_DISK_RADIUS_PX) return { circle, part: 'body' };
      if (Math.abs(dist - circle.radius) <= CONFIG.RESIZE_EDGE_TOLERANCE_PX) {
        return { circle, part: 'edge' };
      }
    }
    return null;
  }

  function updateHiddenInput(markDirty = true) {
    const payload = state.circles.map(c => ({
      disk_id: c.id || null,
      disk_label: c.label,
      position_x: c.x / scale,
      position_y: c.y / scale,
      diameter: c.diameter_mm
    }));
    const serialized = JSON.stringify(payload);
    disksInput.value = serialized;
    if (disksInputForSave) {
      disksInputForSave.value = serialized;
    }

    // After initial load we stored initial value; if changed -> mark dirty
    if (markDirty && disksInput.dataset.initialValue !== undefined) {
      if (serialized !== disksInput.dataset.initialValue) {
        markDisksDirty();
      }
    }
  }

  function promptForLabel(defaultValue = '') {
    const value = prompt("Entrez le nom du disque (ex: AMC):", defaultValue);
    if (value === null) return null; // User cancelled
    const trimmed = value.trim().toUpperCase();
    return trimmed;
  }

  /* --------------- Context Menu Handlers --------------- */
  function onContextMenu(e) {
    e.preventDefault();
    const pos = getMousePos(e);
    const target = getTarget(pos);

    if (target && target.part === 'body') {
      contextTarget = { circle: target.circle, pos: null };
      addOption.style.display = 'none';
      deleteOption.style.display = 'block';
      renameOption.style.display = 'block';
    } else {
      contextTarget = { circle: null, pos: pos };
      addOption.style.display = 'block';
      deleteOption.style.display = 'none';
      renameOption.style.display = 'none';
    }

    contextMenu.style.left = e.pageX + 'px';
    contextMenu.style.top = e.pageY + 'px';
    contextMenu.style.display = 'block';

    const hide = () => (contextMenu.style.display = 'none');
    document.addEventListener('click', hide, { once: true });
    canvas.addEventListener('mousedown', hide, { once: true });
  }

  function addCircleFromContext() {
    if (!contextTarget.pos) return;
    const diameter_mm = CONFIG.MIN_DIAMETER_MM;
    state.circles.push(
      makeCircle({
        id: null,
        label: '',
        x: contextTarget.pos.x,
        y: contextTarget.pos.y,
        diameter_mm
      })
    );
    draw();
    updateHiddenInput();
  }

  function deleteCircle() {
    state.circles = state.circles.filter(c => c !== contextTarget.circle);
    draw();
    updateHiddenInput();
  }

  function renameCircle(circle = contextTarget.circle) {
    if (!circle) return;
    const newLabel = promptForLabel(circle.label || '');
    if (newLabel === null) return; // cancelled
    circle.label = newLabel.length === 0 ? '' : newLabel;
    draw();
    updateHiddenInput();
  }

  /* --------------- Mouse Interaction --------------- */
  function onMouseDown(e) {
    if (e.button !== 0) return; // left only
    const pos = getMousePos(e);
    const target = getTarget(pos);

    if (target) {
      if (target.part === 'body' && !target.circle.label.trim()) {
        renameCircle(target.circle);
        return;
      }

      state.activeCircle = target.circle;
      state.action = target.part === 'body' ? 'drag' : 'resize';
      canvas.style.cursor = state.action === 'drag' ? 'grabbing' : 'nwse-resize';

      document.addEventListener('mousemove', onMouseMove);
      document.addEventListener('mouseup', onMouseUp);
      draw();
    }
  }

  function onMouseMove(e) {
    const pos = getMousePos(e);

    if (!state.action) {
      const hoverTarget = getTarget(pos);
      if (hoverTarget) {
        canvas.style.cursor =
          hoverTarget.part === 'body'
            ? (hoverTarget.circle.label.trim() ? 'move' : 'pointer')
            : 'nwse-resize';
      } else {
        canvas.style.cursor = 'crosshair';
      }
      return;
    }

    if (state.action === 'drag') {
      state.activeCircle.x = pos.x;
      state.activeCircle.y = pos.y;
    } else if (state.action === 'resize') {
      const rPx = Math.hypot(pos.x - state.activeCircle.x, pos.y - state.activeCircle.y);
      state.activeCircle.radius = rPx;
    }
    draw();
  }

  function onMouseUp(e) {
    state.activeCircle = null;
    state.action = null;
    document.removeEventListener('mousemove', onMouseMove);
    document.removeEventListener('mouseup', onMouseUp);
    onMouseMove(e);
    draw();
    updateHiddenInput(); // triggers dirty detection
  }

  /* --------------- Event Wiring --------------- */
  canvas.addEventListener('mousedown', onMouseDown);
  canvas.addEventListener('mousemove', onMouseMove);
  canvas.addEventListener('contextmenu', onContextMenu);

  addOption.addEventListener('click', () => {
    addCircleFromContext();
    contextMenu.style.display = 'none';
  });
  deleteOption.addEventListener('click', () => {
    deleteCircle();
    contextMenu.style.display = 'none';
  });
  renameOption.addEventListener('click', () => {
    renameCircle();
    contextMenu.style.display = 'none';
  });

  /* --------------- Initial Render / Sync --------------- */
  draw();
  // Initial populate WITHOUT marking dirty
  updateHiddenInput(false);
  // Store initial serialized value to detect modifications later
  if (disksInput && disksInput.dataset.initialValue === undefined) {
    disksInput.dataset.initialValue = disksInput.value;
  }
  if (disksInputForSave && disksInputForSave.dataset.initialValue === undefined) {
    disksInputForSave.dataset.initialValue = disksInputForSave.value;
  }
}
</script>

<script>
/* --------------- Save scroll position on reload --------------- */
window.addEventListener('beforeunload', function () {
  sessionStorage.setItem('scrollY', String(window.scrollY || window.pageYOffset));
});
window.addEventListener('load', function () {
  const y = parseInt(sessionStorage.getItem('scrollY') || '0', 10);
  if (y) {
    requestAnimationFrame(function restore() {
      window.scrollTo(0, y);
      sessionStorage.removeItem('scrollY');
    });
  }
});
</script>

<script>
/* --------------- update Antibiotiques supplémentaires --------------- */
document.addEventListener('DOMContentLoaded', function() {
    const cmiRadio = document.querySelector('input[name="type_mesure"][value="cmi"]');
    const diametreRadio = document.querySelector('input[name="type_mesure"][value="diametre"]');
    const cmiContainer = document.getElementById('cmi-container');
    const diametreContainer = document.getElementById('diametre-container');
    const valeurCmi = document.getElementById('valeur_cmi');
    const valeurDiametre = document.getElementById('valeur_diametre');

    function updateInputs() {
        if (cmiRadio.checked) {
            cmiContainer.hidden = false;
            valeurCmi.disabled = false;
            valeurCmi.required = true;

            diametreContainer.hidden = true;
            valeurDiametre.disabled = true;
            valeurDiametre.required = false;
        } else if (diametreRadio.checked) {
            cmiContainer.hidden = true;
            valeurCmi.disabled = true;
            valeurCmi.required = false;

            diametreContainer.hidden = false;
            valeurDiametre.disabled = false;
            valeurDiametre.required = true;
        } 
    }

    cmiRadio.addEventListener('change', updateInputs);
    diametreRadio.addEventListener('change', updateInputs);

    // Initial state
    updateInputs();
});
</script>

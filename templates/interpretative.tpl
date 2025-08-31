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

% rebase('layout_big.tpl', title='Lecture interprétative')

<h1>Lecture Interprétative : <i>{{isolat_name}}</i></h1>
<a href="/prelevement/{{prelevement_id}}">&larr; Retour au prélèvement</a><br>
<a href="/prelevement/{{prelevement_id}}/isolat/{{isolat_id}}/brute">&larr; Retour à la lecture brute</a>
<br><br>

<fieldset>
  <legend><h2>Modifier la lecture interprétative</h2></legend>

  <!-- Toolbar réduite : uniquement Monter / Descendre -->
  <div id="reorder-toolbar" style="display:flex; align-items:center; gap:.5rem; flex-wrap:wrap; margin-bottom:.75rem;">
    <div style="display:flex; gap:.25rem;">
      <button type="button" id="btn-global-up"   title="Monter la ligne sélectionnée (Ctrl+↑)">▲ Monter</button>
      <button type="button" id="btn-global-down" title="Descendre la ligne sélectionnée (Ctrl+↓)">▼ Descendre</button>
    </div>
  </div>

  <form action="/prelevement/{{prelevement_id}}/isolat/{{isolat_id}}/reinterpret" method="post" id="lecture-form">
    <input type="hidden" name="lecture_ids" value="{{ ','.join(str(l[0]) for l in lectures) }}">

    <table id="lectures-table">
      <thead>
        <tr>
          <th style="width:4%;"></th>
          <th style="width:26%;">Antibiotique</th>
          <th style="width:10%;">Diamètre</th>
          <th style="width:10%;">Seuils</th>
          <th style="width:10%;">CMI</th>
          <th style="width:28%;">Interprétation</th>
          <th style="width:8%;">Masquer</th>
        </tr>
      </thead>
      <tbody id="lectures-tbody">
        % for lecture in lectures:
        %   lecture_id   = lecture[0]
        %   antibiotique = lecture[1]
        %   interpretation = lecture[5]
        %   is_masked = lecture[6]
        %   diametre = lecture[7]
        %   cmi = lecture[8]
        %   display_order = lecture[9]
        %   cutoffs = lecture[10]
        <tr data-lecture-id="{{lecture_id}}" draggable="true">
          <td class="drag-handle" title="Glisser pour réordonner" style="cursor:grab; text-align:center; user-select:none;">≡</td>

          <td>
            <input
              type="text"
              name="antibiotique_{{lecture_id}}"
              value="{{antibiotique}}"
              style="width:100%; box-sizing:border-box; margin:0; padding:4px;"
              required
            >
          </td>
          <td>{{ diametre if diametre is not None else '-' }}</td>
            <td>{{ cutoffs if cutoffs else '-' }}</td>
          <td>{{ cmi if cmi is not None else '-' }}</td>
          <td>
            <select
              name="interpretation_{{lecture_id}}"
              required
              style="width:100%; box-sizing:border-box; margin:0; padding:4px;"
            >
              <option value="Sensible" {{ 'selected' if interpretation=='Sensible' else '' }}>S E N S I B L E</option>
              <option value="Sensible à forte posologie" {{ 'selected' if interpretation=="Sensible à forte posologie" else '' }}>Sensible à forte posologie</option>
              <option value="Résistant" {{ 'selected' if interpretation=='Résistant' else '' }}>Résistant</option>
              <option value="Zone d'incertitude technique" {{ 'selected' if interpretation=="Zone d'incertitude technique" else '' }}>Zone d'incertitude technique</option>
              <option value="Non interprétable" {{ 'selected' if interpretation=='Non interprétable' else '' }}>Non interprétable</option>
              <option value="Information uniquement" {{ 'selected' if interpretation=='Information uniquement' else '' }}>Information uniquement</option>
            </select>
          </td>
          <td style="text-align:center;">
            <input type="hidden" name="is_masked_{{lecture_id}}" value="0">
            <input
              type="checkbox"
              name="is_masked_{{lecture_id}}"
              value="1"
              {{ 'checked' if is_masked else '' }}
              class="mask-checkbox"
              title="Masquer / afficher"
            >
          </td>

          <!-- Input d'ordre conservé (pour le backend) mais masqué -->
          <td style="display:none;">
            <input type="hidden" name="display_order_{{lecture_id}}" class="display-order-input" value="{{display_order}}">
          </td>
        </tr>
        % end
      </tbody>
    </table>

    <h3>Commentaires : </h3>
    <textarea name="commentaire" placeholder="Commentaires aux cliniciens">{{commentaire[1]}}</textarea>
    <button type="submit">Enregistrer</button>
    <button type="submit"
            formnovalidate
            formmethod="post"
            formaction="/prelevement/{{prelevement_id}}/isolat/{{isolat_id}}/print"
    >Imprimer</button>
  </form>
</fieldset>

<style>
  #lectures-table {
    border-collapse:collapse;
    width:100%;
  }
  #lectures-table th, #lectures-table td {
    border:1px solid #ddd;
    padding:4px 6px;
    vertical-align:middle;
  }
  #lectures-table tbody tr.selected {
    outline:2px solid #2b6cb0;
    background:#eef6ff;
  }
  #lectures-table tbody tr.dragging {
    opacity:.5;
  }
  .drag-placeholder {
    outline:2px dashed #888;
    height:38px;
  }
  .drag-handle {
    width:100%;
    font-size:16px;
  }
  #reorder-toolbar button {
    padding:4px 8px;
  }
  #reorder-toolbar button:disabled {
    opacity:.5;
    cursor:not-allowed;
  }
</style>

<script>
(function() {
  const tbody = document.getElementById('lectures-tbody');
  const btnUp   = document.getElementById('btn-global-up');
  const btnDown = document.getElementById('btn-global-down');

  let selectedRow = null;

  function refreshDisplayOrders() {
    const rows = Array.from(tbody.querySelectorAll('tr'));
    rows.forEach((row, idx) => {
      const hiddenInput = row.querySelector('.display-order-input');
      if (hiddenInput) hiddenInput.value = idx + 1;
    });
    updateToolbarState();
  }

  function selectRow(row) {
    if (selectedRow) selectedRow.classList.remove('selected');
    selectedRow = row;
    if (selectedRow) selectedRow.classList.add('selected');
    updateToolbarState();
  }

  function moveRow(row, direction) {
    if (!row) return;
    if (direction === 'up') {
      const prev = row.previousElementSibling;
      if (prev) tbody.insertBefore(row, prev);
    } else if (direction === 'down') {
      const next = row.nextElementSibling;
      if (next) tbody.insertBefore(next, row);
    }
    refreshDisplayOrders();
    selectRow(row);
    ensureRowVisible(row);
  }

  function ensureRowVisible(row) {
    const rect = row.getBoundingClientRect();
    if (rect.top < 0 || rect.bottom > window.innerHeight) {
      row.scrollIntoView({block:'center', behavior:'smooth'});
    }
  }

  function updateToolbarState() {
    if (!selectedRow) {
      btnUp.disabled = true;
      btnDown.disabled = true;
      return;
    }
    btnUp.disabled = !selectedRow.previousElementSibling;
    btnDown.disabled = !selectedRow.nextElementSibling;
  }

  // Sélection par clic
  tbody.addEventListener('click', (e) => {
    const row = e.target.closest('tr');
    if (row && tbody.contains(row)) {
      selectRow(row);
    }
  });

  // Double clic pour monter rapidement
  tbody.addEventListener('dblclick', (e) => {
    if (!e.target.closest('.drag-handle')) {
      e.preventDefault();
      return;
    }
    const row = e.target.closest('tr');
    if (row) {
      selectRow(row);
      moveRow(row, 'up');
    }
  });

  // Boutons
  btnUp.addEventListener('click', () => moveRow(selectedRow, 'up'));
  btnDown.addEventListener('click', () => moveRow(selectedRow, 'down'));

  // Raccourcis clavier
  document.addEventListener('keydown', (e) => {
    if (!selectedRow) return;
    if (e.ctrlKey && e.key === 'ArrowUp') {
      e.preventDefault();
      moveRow(selectedRow, 'up');
    } else if (e.ctrlKey && e.key === 'ArrowDown') {
      e.preventDefault();
      moveRow(selectedRow, 'down');
    }
  });

  // Drag & Drop (conservé)
  let dragRow = null;
  let placeholder = null;

  function createPlaceholder(height) {
    const ph = document.createElement('tr');
    ph.className = 'drag-placeholder';
    const td = document.createElement('td');
    td.colSpan = 7; // nombre de colonnes visibles
    td.style.padding = 0;
    td.style.height = height + 'px';
    ph.appendChild(td);
    return ph;
  }

  tbody.addEventListener('dragstart', (e) => {
    const row = e.target.closest('tr');
    if (!row) return;
    dragRow = row;
    row.classList.add('dragging');
    placeholder = createPlaceholder(row.getBoundingClientRect().height);
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', row.dataset.lectureId || '');
    selectRow(row);
  });

  tbody.addEventListener('dragover', (e) => {
    if (!dragRow) return;
    e.preventDefault();
    const overRow = e.target.closest('tr');
    if (!overRow || overRow === dragRow || overRow === placeholder) return;
    const rect = overRow.getBoundingClientRect();
    const after = (e.clientY - rect.top) > (rect.height / 2);
    if (after) {
      if (overRow.nextSibling !== placeholder) {
        overRow.parentNode.insertBefore(placeholder, overRow.nextSibling);
      }
    } else {
      if (overRow.previousSibling !== placeholder) {
        overRow.parentNode.insertBefore(placeholder, overRow);
      }
    }
  });

  tbody.addEventListener('drop', (e) => {
    e.preventDefault();
    if (dragRow && placeholder) {
      tbody.insertBefore(dragRow, placeholder);
    }
  });

  function cleanupDrag() {
    if (dragRow) dragRow.classList.remove('dragging');
    if (placeholder && placeholder.parentNode) {
      placeholder.parentNode.removeChild(placeholder);
    }
    dragRow = null;
    placeholder = null;
    refreshDisplayOrders();
  }

  tbody.addEventListener('dragend', cleanupDrag);
  tbody.addEventListener('mouseleave', () => {
    if (dragRow) cleanupDrag();
  });

  // Sélection via poignée
  tbody.addEventListener('mousedown', (e) => {
    if (e.target.closest('.drag-handle')) {
      const row = e.target.closest('tr');
      if (row) selectRow(row);
    }
  });

  // Init
  refreshDisplayOrders();
  const first = tbody.querySelector('tr');
  if (first) selectRow(first);
})();
</script>

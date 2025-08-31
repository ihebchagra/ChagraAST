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

<style>

@view-transition {
  navigation: auto;
}
  body {
    font-family: Arial, sans-serif;
    margin: 20px;
    background: #fff;
    color: #333;
  }

  h1 {
    text-align: center;
    border-bottom: 2px solid #444;
    padding-bottom: 5px;
    margin-bottom: 20px;
    font-size: 1.4em;
  }

  h2 {
    margin-top: 20px;
    font-size: 1.1em;
    border-left: 4px solid #444;
    padding-left: 8px;
    color: #222;
  }

  .info-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 6px 15px;
    margin: 10px 0 20px;
  }
  .info-item {
    font-size: 0.9em;
    border-bottom: 1px dotted #ccc;
    padding-bottom: 2px;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    margin: 10px 0 20px;
    font-size: 0.9em;
  }
  table th, table td {
    border: 1px solid #aaa;
    padding: 6px 10px;
    text-align: left;
  }
  table th {
    background: #f0f0f0;
    text-transform: uppercase;
    font-size: 0.85em;
  }

  .comment {
    border: 1px solid #ccc;
    padding: 8px;
    border-radius: 5px;
    background: #fafafa;
    font-size: 0.9em;
  }

  .signature {
    margin-top: 40px;
    text-align: right;
    font-size: 0.9em;
    font-style: italic;
  }

  .back-link {
    display: inline-block;
    margin-top: 20px;
    font-size: 0.9em;
  }

  /* Print rules */
  @media print {
    .back-link,
    .print-btn {
      display: none !important;
    }
    a[href]:after {
      content: none !important;
    }
    /* Optional: ensure page break before comments or signature if long */
    .comment {
      page-break-inside: avoid;
    }
    .signature {
      page-break-inside: avoid;
    }
  }

  .print-btn {
    position: fixed;
    top: 12px;
    right: 12px;
    background: #444;
    color: #fff;
    border: none;
    padding: 10px 14px;
    font-size: 0.85rem;
    border-radius: 6px;
    cursor: pointer;
    box-shadow: 0 2px 6px rgba(0,0,0,0.25);
    display: flex;
    align-items: center;
    gap: 6px;
    z-index: 1000;
    font-weight: 600;
  }
  .print-btn:hover {
    background: #222;
  }
  .print-btn:active {
    transform: translateY(1px);
  }
</style>

<button type="button"
        class="print-btn"
        onclick="window.print()"
        title="Imprimer ce compte rendu (Ctrl+P)">
  🖨️ Imprimer
</button>

<h1>Compte rendu de l'antibiogramme</h1>

<h2>Informations sur le prélèvement</h2>
<div class="info-grid">
  <div class="info-item">Numéro : {{prelevement[0]}}</div>
  <div class="info-item">Matricule patient : {{prelevement[1] or '-'}}</div>
  <div class="info-item">Nom : {{prelevement[2] or '-'}}</div>
  <div class="info-item">Prénom : {{prelevement[3] or '-'}}</div>
  <div class="info-item">Service : {{prelevement[4] or '-'}}</div>
  <div class="info-item">Type : {{prelevement[5] or '-'}}</div>
  <div class="info-item">Date : {{prelevement[6] or '-'}}</div>
</div>

<h2>Isolat</h2>
<div class="info-grid">
    <div class="info-item">Germe : <b><i>{{isolat_name}}</i></b></div>
  % for idx, isolat in enumerate(isolats):
    % if isolat[1] == isolat_name:
    <div class="info-item">Rang : {{idx + 1}} / {{len(isolats)}}</div>
    % end
  % end
</div>

<h2>Résultats</h2>
<table>
  <thead>
    <tr>
      <th>Antibiotique</th>
      <th>Interprétation</th>
      % if any(lec[8] for lec in lectures if not bool(lec[6])):
        <th>CMI</th>
      % end
    </tr>
  </thead>
  <tbody>
    % for lec in lectures:
      % if not bool(lec[6]):
      <tr>
        <td>{{!lec[1] if lec[5] == 'Sensible' else f'<b>{lec[1]}</b>'}}</td>
        <td>{{!'S E N S I B L E' if lec[5] == 'Sensible' else f'<b>{lec[5]}</b>'}}</td>
        % if any(lec[8] for lec in lectures if not bool(lec[6])):
          <td>{{ lec[8] if lec[10] else '-' }}</td>
        % end
      </tr>
      % end
    % end
  </tbody>
</table>

% if commentaire and commentaire[1]:
  <h2>Commentaires</h2>
  <div class="comment">{{commentaire[1]}}</div>
% end

<div class="signature">
  Validé - Le Biologiste 
</div>

<a href="/prelevement/{{prelevement[0]}}" class="back-link">← Retour au prélèvement</a><br>
<a href="/prelevement/{{prelevement[0]}}/isolat/{{isolat[0]}}/interpretative" class="back-link">← Retour à la lecture interprétative</a>

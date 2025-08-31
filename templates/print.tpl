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

% rebase('layout.tpl', title='Compte rendu – Lecture interprétative')

<!--
Variables attendues (à faire fournir par la route avant d'afficher ce template) :

prelevement      : ligne de la table prelevements (même structure que dans prelevement.tpl)
                   index: 0=id,1=matricule_patient,2=nom,3=prenom,4=service,5=type_prelevement,6=date
isolat_id        : id de l'isolat
isolat_name      : nom (espèce) de l'isolat
isolat_position  : rang (1-based) de l'isolat parmi ceux du prélèvement
isolat_count     : nombre total d'isolats pour ce prélèvement
lectures         : lignes de la table lectures (déjà triées par display_order)
commentaire      : ligne de la table commentaires ou None (commentaire[1] contient le texte)
-->

<h1>Compte rendu de l'antibiogramme</h1>

<h2>Informations sur le prélèvement</h2>
% if defined('prelevement') and prelevement:
<ul>
  <li>Numéro de prélèvement : {{prelevement[0]}}</li>
  <li>Matricule patient : {{prelevement[1] or '-'}}</li>
  <li>Nom : {{prelevement[2] or '-'}}</li>
  <li>Prénom : {{prelevement[3] or '-'}}</li>
  <li>Service : {{prelevement[4] or '-'}}</li>
  <li>Type de prélèvement : {{prelevement[5] or '-'}}</li>
  <li>Date : {{prelevement[6] or '-'}}</li>
</ul>
% else:
<p>(Informations prélèvement non fournies)</p>
% end

<h2>Isolat</h2>
<ul>
  <li>Rang de l'isolat : {{isolat_position if defined('isolat_position') else '?' }} / {{isolat_count if defined('isolat_count') else '?' }}</li>
  <li>Identifiant interne isolat : {{isolat_id}}</li>
  <li>Nom isolat : {{isolat_name}}</li>
</ul>

<h2>Résultats</h2>
<table>
  <thead>
    <tr>
          <th style="width:40%;">Antibiotique</th>
          <th style="width:40%;">Interprétation</th>
          <th style="width:20%;">CMI</th>
    </tr>
  </thead>
  <tbody>
    % for lec in lectures:
        % if not bool(lec[6]):
        <tr>
          <td>{{lec[1]}}</td>
          <td>{{lec[5]}}</td>
          <td>{{ lec[10] if lec[10] else '-' }}</td>
        </tr>
        % end
    % end
  </tbody>
</table>

<h2>Commentaires</h2>
% if commentaire and commentaire[1]:
    <p>{{commentaire[1]}}</p>
% end

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

% rebase('layout.tpl', title='Prélèvement')

<h1>Prélèvement n°{{prelevement[0]}}</h1>

<a href="/ajouter_prelevement">&larr; Retour aux prélèvements</a>

<fieldset>
    <legend><h2>Informations</h2></legend>

    <label for="matricule_patient">Matricule Patient</label>
    <input type="text" id="matricule_patient" name="matricule_patient" value="{{prelevement[1]}}" disabled>

    <label for="nom">Nom</label>
    <input type="text" id="nom" name="nom" value="{{prelevement[2]}}" disabled>

    <label for="prenom">Prénom</label>
    <input type="text" id="prenom" name="prenom" value="{{prelevement[3]}}" disabled>

    <label for="service">Service</label>
    <input type="text" id="service" name="service" value="{{prelevement[4]}}" disabled>

    <label for="type_prelevement">Type de Prélèvement</label>
    <input type="text" id="type_prelevement" name="type_prelevement" value="{{prelevement[5]}}" disabled>

    <label for="date">Date</label>
    <input type="text" id="date" name="date" value="{{prelevement[6]}}" disabled>

    <form action="/modifier_prelevement/{{prelevement[0]}}">
      <button type="submit">Modifier</button>
    </form>
</fieldset>

<fieldset>
    <legend><h2>Isolats</h2></legend>
    % for idx, isolat in enumerate(isolats):
    <details>
        <summary>{{idx + 1}}. <i>{{ isolat[1] }}</i></summary>
        <form action="/prelevement/{{ prelevement[0] }}/isolat/{{ isolat[0] }}/brute">
          <button type="submit">Lecture brute</button>
        </form>

        <form action="/prelevement/{{ prelevement[0] }}/isolat/{{ isolat[0] }}/interpretative">
          <button type="submit" {{'disabled' if not isolat[2] else ''}}>Lecture interprétative</button>
        </form>

        <form action="/prelevement/{{ prelevement[0] }}/isolat/{{ isolat[0] }}/print">
          <button type="submit" {{'disabled' if not isolat[2] else ''}}>Imprimer</button>
        </form>

        <form action="/prelevement/{{ prelevement[0] }}/delete_isolat/{{ isolat[0] }}" method="post" onsubmit="return confirm('Supprimer isolat n°{{idx + 1}} ({{ isolat[1] }}) ?');">
          <button type="submit">Supprimer</button>
        </form>


    </details>
    % end

    <form action="/prelevement/{{prelevement[0]}}/ajouter_isolat">
      <button type="submit">Ajouter un isolat</button>
    </form>
</fieldset>

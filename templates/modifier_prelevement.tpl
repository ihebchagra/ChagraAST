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

% rebase('layout.tpl', title='Modifier Prélèvement')

<h1>Prélèvement n° {{prelevement[0]}}</h1>

<a href="/prelevement/{{prelevement[0]}}">&larr; Retour</a>

<fieldset>
    <legend><h2>Modifier le Prélèvement</h2></legend>
    <form action="/modifier_prelevement/{{prelevement[0]}}" method="post">
        <label for="matricule_patient">ID Prélèvement</label>
        <input type="text" id="id_prelevement" name="matricule_patient" autocomplete="off" value="{{prelevement[0]}}" disabled>

        <label for="matricule_patient">Matricule Patient</label>
        <input type="text" id="matricule_patient" name="matricule_patient" value="{{prelevement[1]}}" required>

        <label for="nom">Nom</label>
        <input type="text" id="nom" name="nom" value="{{prelevement[2]}}" required>

        <label for="prenom">Prénom</label>
        <input type="text" id="prenom" name="prenom" value="{{prelevement[3]}}" required>

        <label for="service">Service</label>
        <input type="text" id="service" name="service" value="{{prelevement[4]}}" required>

        <label for="type_prelevement">Type de Prélèvement</label>
        <input type="text" id="type_prelevement" name="type_prelevement" value="{{prelevement[5]}}" required>

        <label for="date">Date</label>
        <input type="date" id="date" name="date" value="{{prelevement[6]}}" required>

        <button type="submit">Enregistrer les modifications</button>
    </form>
</fieldset>

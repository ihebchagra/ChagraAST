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

% rebase('layout.tpl', title='Ajouter Prélèvement')
<h1>Prélèvement n°{{prelevement_id}}</h1>
<a href="/ajouter_prelevement">&larr; Retour aux prélèvements</a>
<form action="/nouveau_prelevement/{{prelevement_id}}" method="post">
    <fieldset>
        <legend><h2>Ajouter un Prélèvement</h2></legend>

        <label for="matricule_patient">Matricule Patient</label>
        <input type="text" id="matricule_patient" name="matricule_patient" autocomplete="off" required>

        <label for="nom">Nom</label>
        <input type="text" id="nom" name="nom" autocomplete="off" required>

        <label for="prenom">Prénom</label>
        <input type="text" id="prenom" name="prenom" autocomplete="off" required>

        <label for="service">Service</label>
        <input type="text" id="service" name="service" autocomplete="off" required>

        <label for="type_prelevement">Type de Prélèvement</label>
        <input type="text" id="type_prelevement" name="type_prelevement" autocomplete="off" required>

        <label for="date">Date</label>
        <input type="date" id="date" name="date" autocomplete="off" required>

        <button type="submit">Ajouter</button>
    </fieldset>
</form>

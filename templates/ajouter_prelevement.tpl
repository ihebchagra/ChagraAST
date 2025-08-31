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

% rebase('layout.tpl', title="ChagraAST - Ajouter / Consulter un prélèvement") 

<h1>Ajouter / Consulter un prélèvement</h1>
<a href="/">&larr; Retour à l'accueil</a>
<form action="/ajouter_prelevement" method="post">
<br>
    <fieldset>
        <input
        name="prelevement_id"
        placeholder="ID prélèvement"
        autocomplete="off"
        required
        />

        <input
        type="submit"
        value="Ajouter / Consulter le prélèvement"
        />
    </fieldset>
</form>

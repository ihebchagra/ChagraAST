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

% rebase('layout.tpl', title='Ajouter Isolat')

<h1>Ajouter un Isolat</h1>
<a href="/prelevement/{{prelevement_id}}">&larr; Retour au prélèvement</a>
<br>
<br>
<form action="/prelevement/{{prelevement_id}}/ajouter_isolat" method="post">
    <fieldset>
    <label for="isolat_name">Nom de l'isolat</label>
    <select id="isolat_name" name="isolat_name" required>
        % for bacteria in bacteria_list:
        <option value="{{bacteria}}">{{bacteria}}</option>
        % end
    </select>

    <button type="submit">Ajouter</button>
    </fieldset>
</form>

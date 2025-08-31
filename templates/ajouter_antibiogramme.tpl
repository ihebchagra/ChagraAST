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

% rebase('layout.tpl', title='Ajouter Antibiogramme')

<section>
    <h1>Ajouter un Antibiogramme</h1>
    <form action="/prelevement/{{prelevement_id}}/isolat/{{isolat_id}}/ajouter_antibiogramme" method="post">
        <label for="antibiotic_name">Nom de l'antibiotique</label>
        <input type="text" id="antibiotic_name" name="antibiotic_name" required>

        <label for="result">Résultat (S/I/R)</label>
        <input type="text" id="result" name="result" required>

        <button type="submit">Ajouter</button>
    </form>
</section>

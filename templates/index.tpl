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

% rebase('layout.tpl', title="ChagraAST - Accueil")

<h1>Bienvenue sur ChagraAST</h1>
<p>
    ChagraAST est une application web complète pour la gestion et l'interprétation des antibiogrammes (ATB).
    Elle vise à simplifier et à standardiser le flux de travail du laboratoire, de l'enregistrement du prélèvement à la génération du rapport final.
</p>

<article>
    <h2>Comment ça marche ?</h2>
    <ol>
        <li><b>Enregistrez un prélèvement</b> : Commencez par entrer un numéro de prélèvement pour créer un nouveau dossier ou consulter un dossier existant.</li>
        <li><b>Ajoutez des isolats</b> : Pour chaque prélèvement, identifiez et ajoutez les souches bactériennes isolées.</li>
        <li><b>Analysez les antibiogrammes</b> : Prenez une photo de votre boîte de Petri et téléchargez-la. L'application détectera automatiquement les disques d'antibiotiques et mesurera les diamètres d'inhibition.</li>
        <li><b>Validez et interprétez</b> : Corrigez si nécessaire les mesures, ajoutez des informations complémentaires (comme les CMI) et lancez l'interprétation pour obtenir les statuts S/I/R.</li>
        <li><b>Générez le rapport</b> : Une fois la validation terminée, imprimez un compte-rendu clair à destination du clinicien.</li>
    </ol>
</article>

<form action="ajouter_prelevement">
  <button type="submit">Commencer : Ajouter ou Consulter un prélèvement</button>
</form>

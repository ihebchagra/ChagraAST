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

<!DOCTYPE html>
<html lang="fr" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta description="Outil de lecture et interprétation d'antibiogrammes">
    <title>{{ title }}</title>
    <link rel="stylesheet" href="/static/styles.css" />
    <link rel="icon" href="/static/favicon.ico" type="image/x-icon">
</head>
<body>
    <main>
        {{!base}}
    </main>
    <footer><center>&copy 2025 - Iheb Chagra | <a href="/license">Licence GPLv3</a></center></footer>
</body>
</html>

<script>
/* --------------- Save scroll position on reload --------------- */
window.addEventListener('beforeunload', function () {
  sessionStorage.setItem('scrollY', String(window.scrollY || window.pageYOffset));
});
window.addEventListener('load', function () {
  const y = parseInt(sessionStorage.getItem('scrollY') || '0', 10);
  if (y) {
    requestAnimationFrame(function restore() {
      window.scrollTo(0, y);
      sessionStorage.removeItem('scrollY');
    });
  }
});
</script>

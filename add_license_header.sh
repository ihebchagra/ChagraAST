#!/bin/bash

# License header text
LICENSE_HEADER_PY="""
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
"""

LICENSE_HEADER_TPL="""
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
"""

# Find all python and tpl files, excluding venv directory
FILES=$(find . \( -name "*.py" -o -name "*.tpl" \) -not -path "./venv/*")

for FILE in $FILES
do
  # Check if the license header already exists
  if ! grep -q "GNU General Public License" "$FILE"; then
    if [[ $FILE == *.py ]]; then
      # Prepend the license header for python files
      echo -e "#\n# $(echo "$LICENSE_HEADER_PY" | sed 's/^/# /')\n#\n\n$(cat "$FILE")" > "$FILE"
      echo "Added license header to $FILE"
    elif [[ $FILE == *.tpl ]]; then
      # Prepend the license header for tpl files
      echo -e "<!--\n$(echo "$LICENSE_HEADER_TPL" | sed 's/^/  /')\n-->\n\n$(cat "$FILE")" > "$FILE"
      echo "Added license header to $FILE"
    fi
  fi
done

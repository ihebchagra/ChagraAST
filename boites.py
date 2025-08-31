#
# # 
# Copyright (C) 2025 Iheb Chagra
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# 
#

pseudo_1 = [
    ["TIC", "TCC", "PIP", "TZP"],
    ["FEP",  "CAZ", "CZA", "AZT"],
    ["IMP", "MEM",  "CIP", "LEV"],
    ["AMK", "TOB", "FOS", None],
]

def get_boite_types(isolat_name: str) -> list:
    first_word = isolat_name.split(' ')[0]
    if first_word.lower() == "pseudomonas":
        return ['Pseudomonas 1']
    else:
        return []

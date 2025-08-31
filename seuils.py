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

from cutoffs.pseudo import get_pseudomonas_cutoffs

def ANTIBIOTICS_PLACEHOLDER(str, species: str) -> dict:
    return {}

def get_cutoffs(species_name: str):
    first_word = species_name.split(' ')[0]
    if first_word.lower() == "pseudomonas":
        return get_pseudomonas_cutoffs(species_name)
    else:
        return ANTIBIOTICS_PLACEHOLDER(species_name)

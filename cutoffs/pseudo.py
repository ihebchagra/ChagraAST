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

def get_pseudomonas_cutoffs(species: str = "Pseudomonas spp.") -> dict:
    ALL_CUTOFFS = {
        "TIC": {
            "Pseudomonas spp.": {"seuil_S": 50, "seuil_R": 18}
        },
        "TCC": {
            "Pseudomonas spp.": {"seuil_S": 50, "seuil_R": 18}
        },
        "PIP": {
            "Pseudomonas spp.": {"seuil_S": 18, "seuil_R": 18}
        },
        "TZP": {
            "Pseudomonas spp.": {"seuil_S": 50, "seuil_R": 18}
        },
        "FEP": {
            "Pseudomonas spp.": {"seuil_S": 21, "seuil_R": 19}
        },
        "FDC": {
            "Pseudomonas spp.": {"seuil_S": 27, "seuil_R": 27}
        },
        "CAZ": {
            "Pseudomonas spp.": {"seuil_S": 17, "seuil_R": 17}
        },
        "CZA": {
            "Pseudomonas spp.": {"seuil_S": 17, "seuil_R": 16}
        },
        "CTZ": {
            "Pseudomonas spp.": {"seuil_S": 23, "seuil_R": 23}
        },
        "AZT": {
            "Pseudomonas spp.": {"seuil_S": 23, "seuil_R": 18}
        },
        "IMP": {
            "Pseudomonas spp.": {"seuil_S": 22, "seuil_R": 20},
            "Pseudomonas aeruginosa": {"seuil_S": 22, "seuil_R": 20}
        },
        "IMR": {
            "Pseudomonas spp.": {"seuil_S": 22, "seuil_R": 20},
            "Pseudomonas aeruginosa": {"seuil_S": 22, "seuil_R": 20}
        },
        "MEM": {
            "Pseudomonas spp.": {"seuil_S": 24, "seuil_R": 18},
            "Pseudomonas aeruginosa": {"seuil_S": 24, "seuil_R": 18}
        },
        "MEV": {
            "Pseudomonas spp.": {"seuil_S": 14, "seuil_R": 14},
            "Pseudomonas aeruginosa": {"seuil_S": 14, "seuil_R": 14}
        },
        "CIP": {
            "Pseudomonas spp.": {"seuil_S": 26, "seuil_R": 22}
        },
        "LEV": {
            "Pseudomonas spp.": {"seuil_S": 22, "seuil_R": 22}
        },
        "AMK": {
            "Pseudomonas spp.": {"seuil_S": 18, "seuil_R": 15}
        },
        "TOB": {
            "Pseudomonas spp.": {"seuil_S": 18, "seuil_R": 18}
        },
        "FOS": {
            "Pseudomonas spp.": {"seuil_S": 12, "seuil_R": 12}
        }
    }

    normalized_species = "Pseudomonas spp."
    if species.lower() == "pseudomonas aeruginosa".lower():
        normalized_species = "Pseudomonas aeruginosa"

    result_cutoffs = {}
    for antibiotic_code, species_data in ALL_CUTOFFS.items():
        if normalized_species in species_data:
            result_cutoffs[antibiotic_code] = species_data[normalized_species]
        elif "Pseudomonas spp." in species_data:
            result_cutoffs[antibiotic_code] = species_data["Pseudomonas spp."]

    return result_cutoffs

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

disk_dictionnary = {
    # Pénicillines
    "AM": "Ampicilline",
    "AMP": "Ampicilline",
    "AMC": "Amoxicilline + acide clavulanique",
    "A/C'": "Amoxicilline + acide clavulanique",
    "AUG": "Amoxicilline + acide clavulanique",
    "XL": "Amoxicilline + acide clavulanique",
    "AML*": "Amoxicilline + acide clavulanique",
    "AMX": "Amoxicilline",
    "AMOX": "Amoxicilline",
    "AC": "Amoxicilline",
    "CB": "Carbénicilline",
    "ME": "Mécillinam",
    "MEC": "Mécillinam",
    "OXA": "Oxacilline",
    "P": "Pénicilline G",
    "PE": "Pénicilline G",
    "PIP": "Pipéracilline",
    "PIT": "Pipéracilline-Tazobactam",
    "TZP": "Pipéracilline-Tazobactam",
    "PPT": "Pipéracilline-Tazobactam",
    "TIC": "Ticarcilline",
    "TCC": "Ticarcilline acide clavulanique",

    # Céphalosporines
    "C3G": "Céphalosporine de 3ème génération (générique)",
    "C4G": "Céphalosporine de 4ème génération (générique)",
    "CAR": "Céfaloridine",
    "CAZ": "Ceftazidime",
    "TZ": "Ceftazidime",
    "CEC": "Céfaclor",
    "CCL": "Céfaclor",
    "Cfr": "Céfaclor",
    "FAC": "Céfaclor",
    "CF": "Céfalotine",
    "CEF": "Céfépime",
    "CXN": "Céfalexine",
    "Cpe": "Céfépime",
    "PM": "Céfépime",
    "CPM": "Céfépime",
    "FEP": "Céfépime",
    "CFM*": "Céfixime",
    "FIX": "Céfixime",
    "Cfe": "Céfixime",
    "IX": "Céfixime",
    "CFP": "Céfopérazone",
    "Cfp": "Céfopérazone",
    "CPZ": "Céfopérazone",
    "PER": "Céfopérazone",
    "FOP": "Céfopérazone",
    "CP": "Céfopérazone",
    "CFR": "Céfadroxil",
    "FAD*": "Céfadroxil",
    "CFS": "Céfatrizine",
    "CRO": "Ceftriaxone",
    "CTR": "Ceftriaxone",
    "FRX": "Ceftriaxone",
    "Cax": "Ceftriaxone",
    "AXO": "Ceftriaxone",
    "TX": "Ceftriaxone",
    "CTF": "Céfotiam",
    "CN*": "Céfalexine",
    "LEX": "Céfalexine",
    "CPD": "Cefpodoxime-proxétil",
    "Cpd": "Cefpodoxime-proxétil",
    "POD": "Cefpodoxime-proxétil",
    "PX": "Cefpodoxime-proxétil",
    "CPO": "Céfpirome",
    "CPR": "Céfpirome",
    "CR": "Céfpirome",
    "FOX": "Céfoxitine",
    "CTX": "Céfotaxime",
    "FOT": "Céfotaxime",
    "CEFOT": "Céfotaxime",
    "CED": "Céfradine",
    "CZA": "Ceftazidime-Avibactam",

    # Carbapénèmes
    "ETP": "Ertapénème",
    "ERT": "Ertapénème",
    "IPM": "Imipénème",
    "IMP": "Imipénème",
    "MEM": "Méropénème",
    "MER": "Méropénème",
    "DOR": "Doripénème",

    # Monobactames
    "ATM": "Aztréonam",
    "AZT": "Aztréonam",
    "AT": "Aztréonam",
    "AZM*": "Aztréonam",

    # Aminosides
    "AN": "Amikacine",
    "AK": "Amikacine",
    "AMI": "Amikacine",
    "AMK": "Amikacine",
    "GEN": "Gentamicine",
    "GM": "Gentamicine",
    "NET": "Nétilmicine",
    "TOB": "Tobramycine",
    "STR": "Streptomycine",
    "KAN": "Kanamycine",

    # Macrolides, Lincosamides, Streptogramines (MLS)
    "AZI": "Azithromycine",
    "AZ": "Azithromycine",
    "CLA": "Clarithromycine",
    "CLI": "Clindamycine",
    "CM": "Clindamycine",
    "CC": "Clindamycine",
    "CLN": "Clindamycine",
    "CD": "Clindamycine",
    "DA": "Clindamycine",
    "ERY": "Érythromycine",
    "PRI": "Pristinamycine",
    "QA": "Quinupristine/Dalfopristine",

    # Tétracyclines
    "TET": "Tétracycline",
    "DOX": "Doxycycline",
    "MIN": "Minocycline",
    "TIG": "Tigécycline",

    # Quinolones (Fluoroquinolones)
    "CIP": "Ciprofloxacine",
    "Cp": "Ciprofloxacine",
    "CI": "Ciprofloxacine",
    "LVX": "Lévofloxacine",
    "LEV": "Lévofloxacine",
    "MXF": "Moxifloxacine",
    "OFX": "Ofloxacine",
    "NAL": "Acide nalidixique",
    "PEF": "Péfloxacine",
    "NOR": "Norfloxacine",
    "GEM": "Gémifloxacine",
    "DLX": "Délafloxacine",

    # Phénicolés
    "C": "Chloramphénicol",
    "CHL": "Chloramphénicol",
    "CL*": "Chloramphénicol",

    # Sulfamides et Triméthoprime
    "COT": "Cotrimoxazole (Triméthoprime-Sulfaméthoxazole)",
    "SXT": "Cotrimoxazole (Triméthoprime-Sulfaméthoxazole)",
    "TMP": "Triméthoprime",
    "SMX": "Sulfaméthoxazole",

    # Glycopeptides et lipopeptides
    "VAN": "Vancomycine",
    "TEC": "Teicoplanine",
    "DAL": "Daptomycine",
    "ORV": "Oritavancine",
    "TEL": "Telavancine",

    # Oxazolidinones
    "LNZ": "Linézolide",
    "TED": "Tédizolide",

    # Divers
    "B": "Bacitracine",
    "BAC": "Bacitracine",
    "CL": "Colistine",
    "CS": "Colistine",
    "COL": "Colistine",
    "FOS": "Fosfomycine",
    "FUS": "Acide Fusidique",
    "MET": "Métronidazole",
    "NIT": "Nitrofurantoïne",
    "F": "Nitrofurantoïne",
    "NF": "Nitrofurantoïne",
    "RIF": "Rifampicine",
    "RD": "Rifampicine",
    "MUP": "Mupirocine",
    "CFX": "Céfazoline",
    "AZA": "Acide Azélaïque",
    "C/S": "Ceftolozane/Tazobactam",
    "FDC": "Fosfomycine-trométamol",
    "DAF": "Dalbavancine",
    "CFE": "Céfépime/Tazobactam",
}

# Pré-calcul d'un index d'ordre (clé -> position)
_code_order_index = {code: i for i, code in enumerate(disk_dictionnary.keys())}

def get_antibiotic_order(code: str) -> int:
    """
    Renvoie l'ordre d'affichage désiré pour un code d'antibiotique.
    Les codes inconnus reçoivent un grand index pour être placés en fin.
    """
    return _code_order_index.get(code, 10_000_000)

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
dev:
	docker run --rm -v "$(shell pwd)":/app chagra-ast python database_setup.py
	docker run --rm -v "$(shell pwd)":/app -p 6420:6420 chagra-ast

rebuild:
	docker build -f Dockerfile -t chagra-ast .

setupdb:
	docker run --rm -v "$(shell pwd)":/app chagra-ast python database_setup.py

backup:
	docker run --rm -v "$(shell pwd)":/app chagra-ast cp chagra.db backup.db

restore:
	docker run --rm -v "$(shell pwd)":/app chagra-ast cp backup.db chagra.db

nuke:
	docker run --rm -v "$(shell pwd)":/app chagra-ast rm chagra.db

matrix:
	docker run -it -v "$(shell pwd)":/app chagra-ast /bin/bash

add-license-headers:
	./add_license_header.sh

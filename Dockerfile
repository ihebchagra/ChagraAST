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
# Use the builder image which has the astimp library pre-installed
FROM astimp-builder

# Set the working directory inside the container
WORKDIR /app

# Copy and install the Python dependencies for the web app
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy the rest of the web application code
COPY . .

# Expose the port the web server will run on
EXPOSE 6420

# Command to run the web server on the specified port
CMD ["watchmedo", "auto-restart", "--patterns=*.py;*.tpl", "--recursive", "--", "python3", "app.py", "6420"]

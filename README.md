# MEDIS-BioD Project Tools

R and Python scripts for standardized biodiversity data management, database-driven workflows, and a graphical interface with QGIS, Qt, Python, R, and SQL for applied conservation.

---

## Important

To avoid conflicts between system libraries, Python, and QGIS, all installation should be done in a **dedicated Python virtual environment**.  

> Commands below are for **Linux (Debian-based distributions)**. Adjust for your OS if needed.

---

## Setup Instructions

```bash
python3 --version || { sudo apt-get update && sudo apt-get install -y python3.6; }

# Install pipx and virtualenv
pipx install virtualenv

# Create and activate virtual environment
python3 -m venv qgis_venv
source qgis_venv/bin/activate

# Install required packages inside the virtual environment
pip install appdirs==1.4.4 apturl==0.5.2 argcomplete==3.1.4 attrs==23.2.0 Babel==2.10.3 beautifulsoup4==4.12.3 blinker==1.7.0 Brlapi==0.8.5 Brotli==1.1.0 certifi==2023.11.17 chardet==5.2.0 click==8.1.6 colorama==0.4.6 PyQt5==5.15.10 GDAL==3.8.4 numpy==1.26.4 matplotlib==3.6.3 SciPy==1.11.4

# Launch QGIS
qgis


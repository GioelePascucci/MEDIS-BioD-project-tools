# Activate virtual environment
# source qgis-venv/bin/activate

# Import required modules
import PyQt5  # Graphic interface suite
from PyQt5.QtWidgets import QVBoxLayout, QHBoxLayout, QPushButton, QCheckBox, QLineEdit, QLabel, QDialog, QInputDialog, QMessageBox
from MySQLdb import _mysql
from MySQLdb.constants import FIELD_TYPE

# Conversion of output to integer for MySQL
my_conv = {FIELD_TYPE.LONG: int}

# Example usage of message boxes
QMessageBox.warning(None, "Warning", "Please add a report!")
QMessageBox.information(None, "Information", "Please add a report!")
QMessageBox.critical(None, "Critical", "Please add a report!")
QMessageBox.about(None, "About", "Please add a report!")
QMessageBox.aboutQt(None, "About Qt", "Please add a report!")

# Example input dialog
options = ["Alien island", "Native island", "Reference"]
response = QInputDialog.getItem(None, "Choose an option", "Select", options, 0, False)

# Connect to MySQL database
db = _mysql.connect(conv=my_conv, host="localhost", user="BiomeLab", password="IslandOfEurope", database="ESIBioD")

# Example query
db.query("""SELECT * FROM island WHERE area_km2 > 20000""")
r = db.store_result()
r.fetch_row()

###### GUI CODE #####

# Create a simple custom dialog window
dialog = QDialog()
dialog.setWindowTitle("Custom Window")

# Main layout
layout = QVBoxLayout(dialog)

# Row 1: Taxa selection
taxa_label = QLabel("Which taxa to consider?")
layout.addWidget(taxa_label)

# Checkboxes for taxa options
checkbox1 = QCheckBox("Option 1")
checkbox2 = QCheckBox("Option 2")
checkbox3 = QCheckBox("Option 3")
checkbox4 = QCheckBox("Option 4")
hbox_taxa = QHBoxLayout()
hbox_taxa.addWidget(checkbox1)
hbox_taxa.addWidget(checkbox2)
hbox_taxa.addWidget(checkbox3)
hbox_taxa.addWidget(checkbox4)
layout.addLayout(hbox_taxa)

# Row 2: Include biological forms?
include_bio_label = QLabel("Include biological forms?")
layout.addWidget(include_bio_label)
checkbox_yes_bio = QCheckBox("Yes")
checkbox_no_bio = QCheckBox("No")
hbox_bio = QHBoxLayout()
hbox_bio.addWidget(checkbox_yes_bio)
hbox_bio.addWidget(checkbox_no_bio)
layout.addLayout(hbox_bio)

# Row 3: Years selection
years_label = QLabel("Which years to consider?")
layout.addWidget(years_label)
year_start = QLineEdit()
year_start.setPlaceholderText("Start year")
year_end = QLineEdit()
year_end.setPlaceholderText("End year")
hbox_years = QHBoxLayout()
hbox_years.addWidget(year_start)
hbox_years.addWidget(year_end)
layout.addLayout(hbox_years)

# Row 4: Include island characteristics?
characteristics_label = QLabel("Include island characteristics?")
layout.addWidget(characteristics_label)
checkbox_char_yes = QCheckBox("Yes")
checkbox_char_no = QCheckBox("No")
hbox_char = QHBoxLayout()
hbox_char.addWidget(checkbox_char_yes)
hbox_char.addWidget(checkbox_char_no)
layout.addLayout(hbox_char)

# Confirm and Cancel buttons
confirm_button = QPushButton("Confirm")
cancel_button = QPushButton("Cancel")
layout.addWidget(confirm_button)
layout.addWidget(cancel_button)

# Function to process user selections
def analyze_responses():
    print("analyze_responses function called")  # Debug message
    selected_options = [
        checkbox1.text() if checkbox1.isChecked() else None,
        checkbox2.text() if checkbox2.isChecked() else None,
        checkbox3.text() if checkbox3.isChecked() else None,
        checkbox4.text() if checkbox4.isChecked() else None
    ]
    selected_options = [opt for opt in selected_options if opt]  # Remove None values
    bio_included = "Yes" if checkbox_yes_bio.isChecked() else "No"
    start_year = year_start.text() or "N/A"
    end_year = year_end.text() or "N/A"
    characteristics_included = "Yes" if checkbox_char_yes.isChecked() else "No"

    # Print selections to console
    print("Selected options:", ', '.join(selected_options))
    print("Include biological forms:", bio_included)
    print("Years:", start_year, "-", end_year)
    print("Include island characteristics:", characteristics_included)

# Connect buttons to actions
confirm_button.clicked.connect(analyze_responses)
cancel_button.clicked.connect(dialog.close)

# Show the dialog
dialog.exec_()


### The aim of this script is creating subsets of a national checklist using regional filters

install.packages("readxl")  # if not installed
install.packages("tidyverse")
install.packages("openxlsx")
install.packages("TR8", dependencies = TRUE)

library(tidyverse)
library(readxl)
library(openxlsx)
library(TR8)

# Load checklists
isibiod_list <- read_excel("/home/gioele/Documenti/ISIBIOD/checklist_SQL/occurences_FINAL3_SpainFrance.xlsx", sheet="sheet1")
regional_list <- read_excel("/home/gioele/Documenti/ISIBIOD/checklist_SQL/sardinia_corsica.xlsx")

isibiod_data <- as.data.frame(isibiod_list)
regional_data <- as.data.frame(regional_list) %>%
  filter(!is.na(time_co)) %>%
  distinct(taxon, .keep_all = TRUE)

# Add residence_time for Corsica
for (x in 1:nrow(isibiod_data)) {
  if (isibiod_data$region[x] == "Corsica" & isibiod_data$taxon[x] %in% regional_data$taxon) {
    y <- which(regional_data$taxon == isibiod_data$taxon[x])
    isibiod_data$residence_time[x] <- regional_data$time_co[y]
  }
}

count_check <- isibiod_data %>% count(residence_time) %>% arrange(residence_time)

# Regional alien presence for Italy
for (x in 1:nrow(isibiod_data)) {
  if (isibiod_data$country[x] == "Italy" & isibiod_data$taxon[x] %in% regional_data$Taxon) {
    idx <- which(regional_data$Taxon == isibiod_data$taxon[x])
    isibiod_data$regional_time[x] <- regional_data$Time[idx]
    switch(isibiod_data$region[x],
           "Apulia" = isibiod_data$regional_inv_check[x] <- regional_data$Apulia[idx],
           "Calabria" = isibiod_data$regional_inv_check[x] <- regional_data$Calabria[idx],
           "Campania" = isibiod_data$regional_inv_check[x] <- regional_data$Campania[idx],
           "Lazio" = isibiod_data$regional_inv_check[x] <- regional_data$Lazio[idx],
           "Liguria" = isibiod_data$regional_inv_check[x] <- regional_data$Liguria[idx],
           "Sardinia" = isibiod_data$regional_inv_check[x] <- regional_data$Sardinia[idx],
           "Sicily" = isibiod_data$regional_inv_check[x] <- regional_data$Sicily[idx],
           "Tuscany" = isibiod_data$regional_inv_check[x] <- regional_data$Tuscany[idx]
    )
  }
}

count_check <- isibiod_data %>% count(regional_inv_check) %>% arrange(regional_inv_check)

# Life form / functional traits for Spain + France
species_list <- read_excel("/home/gioele/Documenti/Thesis/FinalVersion/occurences_FINAL6_spainFrance.xlsx")
spain_list <- read_excel("/home/gioele/Documenti/Thesis/SimpleVersion/spainRegional_endemic_alien.xlsx")

species_data <- as.data.frame(species_list)
spain_data <- as.data.frame(spain_list)

for (x in 1:nrow(species_data)) {
  if (species_data$region[x] == "Valencian Community") {
    if (species_data$taxon[x] %in% spain_data$valencian_alien) species_data$regional_inv_check[x] <- "Alien"
    if (species_data$taxon[x] %in% spain_data$valencian_endemic) species_data$regionalEndemic[x] <- "YES"
  }
  if (species_data$region[x] == "Balearic Islands") {
    if (species_data$taxon[x] %in% spain_data$balearic_alien) species_data$regional_inv_check[x] <- "Alien"
    if (species_data$taxon[x] %in% spain_data$balearic_endemic) species_data$regionalEndemic[x] <- "YES"
  }
}

# Assign SQL IDs
occurrences_list <- read_excel("/home/gioele/Documenti/Thesis/FinalVersion/DEFINITIVE_all_countries _table_SQL.xlsx", sheet="occurrences")
status_list <- read_excel("/home/gioele/Documenti/Thesis/FinalVersion/DEFINITIVE_all_countries _table_SQL.xlsx", sheet="status")
reference_list <- read_excel("/home/gioele/Documenti/Thesis/FinalVersion/DEFINITIVE_all_countries _table_SQL.xlsx", sheet="reference")
lifeForm_list <- read_excel("/home/gioele/Documenti/Thesis/FinalVersion/DEFINITIVE_all_countries _table_SQL.xlsx", sheet="lifeForm")
island_list <- read_excel("/home/gioele/Documenti/Thesis/FinalVersion/DEFINITIVE_all_countries _table_SQL.xlsx", sheet="island")
taxa_list <- read_excel("/home/gioele/Documenti/Thesis/FinalVersion/DEFINITIVE_all_countries _table_SQL.xlsx", sheet="taxa")

occurrences <- as.data.frame(occurrences_list)
status <- as.data.frame(status_list)
reference <- as.data.frame(reference_list)
lifeForm <- as.data.frame(lifeForm_list)
island <- as.data.frame(island_list)
taxa <- as.data.frame(taxa_list)

# LifeForm IDs
for (x in 1:nrow(taxa)) {
  if (taxa$lifeForm[x] %in% lifeForm$lifeForm) {
    y <- which(lifeForm$lifeForm == taxa$lifeForm[x])
    taxa$lifeForm_ID[x] <- lifeForm$lifeForm_ID[y]
  }
}

# Status, Island, Occurrences IDs
for (x in 1:nrow(status)) {
  if (status$taxa[x] %in% taxa$taxa) status$taxa_ID[x] <- taxa$taxa_ID[which(taxa$taxa == status$taxa[x])]
  if (status$islandName[x] %in% island$island) status$island_ID[x] <- island$island_ID[which(island$island == status$islandName[x])]
}

for (x in 1:nrow(occurrences)) {
  if (occurrences$islandName[x] %in% island$island) occurrences$island_ID[x] <- island$island_ID[which(island$island == occurrences$islandName[x])]
  if (occurrences$taxon[x] %in% taxa$taxa) occurrences$taxon_ID[x] <- taxa$taxa_ID[which(taxa$taxa == occurrences$taxon[x])]
  if (occurrences$reference[x] %in% reference$reference_old) occurrences$reference_ID[x] <- reference$reference_ID[which(reference$reference_old == occurrences$reference[x])]
}

write.xlsx(species_area, "species_area_table.xlsx")

# SAR analysis
library(sars)
esibiod_list <- read_excel("/home/gioele/Documents/Thesis/FinalVersion/island_SQL.xlsx")
medis_list <- read_excel("/home/gioele/Documents/Thesis/FinalVersion/medis_data.xlsx")

esibiod <- as.data.frame(esibiod_list)
medis <- as.data.frame(medis_list)
names(medis)[1] <- "island_ID"

species_area <- merge(esibiod, medis, by="island_ID", all.x = TRUE)
species_area <- read_excel("/home/gioele/Documenti/species_area_table.xlsx")
species_area_alien <- species_area[species_area$Status == 'Alien', ]

table <- species_area_alien[, c("area_km2", "num_taxa")]
sar_model <- sar_power(table[table$area_km2 < 25, ])
plot(sar_model)
text(table$area_km2, table$num_taxa, labels = species_area_alien$Island, pos = 4)


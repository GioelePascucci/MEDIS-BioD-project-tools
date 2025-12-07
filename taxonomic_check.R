#this scripts aims to check and update species taxonomy assigning a match-score and consulting several database at the same time

install.packages("ritis") # uncomment if not already installed
install.packages("dplyr") # uncomment if not already installed
install.packages("taxize") # uncomment if not already installed
install.packages("readxl") # uncomment if not already installed
intsall.packages("tidyverse")
intsall.packages("rgbif")
install.packages("openxlsx")
install.packages("readxl")
install.packages("TNRS")

library(tidyverse)    # To do datascience
library(rgbif)        # To lookup names in the GBIF backbone taxonomy
library(readxl)
library(ritis)
library(taxize)
library(openxlsx)
library(TNRS)


### WITH TAXIZE ###

#read the species list to check from an excel file
taxa_checklist <-read_excel("/home/gioele/Documenti/ISIBioD_offline/taxa_checklist.xlsx")
#convert the check list to a data.frame
taxa_data<-as.data.frame(taxa_checklist)
#use the function "gnr_resolve" to query several databases
z<-gnr_resolve(sci = y$Name_submitted,http="post",resolve_once=TRUE, canonical=TRUE, with_canonical_ranks=TRUE)
#filter the result, excluding species with a match-score higher than 0.800
y<-x[x$score<0.800,]

### WITH GBIF BACKBONE ###
#read the species list to check from an excel file
taxa_checklist <-read_excel("/home/gioele/Documenti/ISIBIOD/checklist_SQL/occurences_FINAL_SQL.xlsx")
#convert the check list to a data.frame
taxa_data<-as.data.frame(taxa_checklist)
z<-name_backbone_checklist(y$Name_submitted)

#count how many occurrences for each rank
count_rank <- taxa_data %>% count(rank) %>% arrange(desc(n))
#count how many occurrences for each island
count_rank <- taxa_data %>% count(islandName) %>% arrange(desc(n))
#create a table subset with species and subspecies
occurences_species <- taxa_data %>%
  filter(rank == "SPECIES")
occurences_others <- taxa_data %>%
  filter(rank != "SPECIES")

write.xlsx2(occurences_others, "/home/gioele/occurences_others.xlsx", sheetName = "Sheet1",
  col.names = TRUE, row.names = TRUE, append = FALSE)

### WITH TNRS RESOLVE ###

#read the species list to check from an excel file
isibiod_list <-read_excel("/home/gioele/Documenti/Thesis/SimpleVersion/spainRegional_endemic_alien.xlsx")
#read the species list to check from an excel file
regional_list <-read_excel("/home/gioele/Documenti/ISIBIOD/checklist_SQL/regional_alien.xlsx", sheet="list_taxa")

#convert the check list to a data.frame
isibiod_data<-as.data.frame(isibiod_list)
regional_data<-as.data.frame(regional_list)
#Match taxonomic names using the Taxonomic Name Resolution Service (TNRS). Returns score of the matched name, and whether it was accepted or not.
x_isibiod<-TNRS(taxonomic_names = isibiod_data$valencian_endemic)
#filter the result, excluding species with an Overall_score < 1
y_isibiod<-x_isibiod[x_isibiod$Overall_score<1,]
#Analyse how many occurrences by rank
count_rank<-x_isibiod %>% count(Name_matched_rank) %>% arrange(Name_matched_rank)
#Filter ranks different from...
y_isibiod<- x_isibiod %>%
  filter(Name_matched_rank != "species")%>%
  filter(Name_matched_rank != "subspecies")
write.xlsx2(y, "/home/gioele/Documenti/ISIBIOD/checklist_SQL/da_cambiare_in_occurences_FINAL.xlsx", sheetName = "Sheet1",
  col.names = TRUE, row.names = TRUE, append = FALSE)
#Match taxonomic names using the Taxonomic Name Resolution Service (TNRS). Returns score of the matched name, and whether it was accepted or not.
x_regional<-TNRS(taxonomic_names = regional_data$Taxon)
#filter the result, excluding species with an Overall_score < 1
y_regional<-x_regional[x_regional$Overall_score<1,]
#Analyse how many occurrences by rank
count_rank<-x_regional %>% count(Name_matched_rank) %>% arrange(Name_matched_rank)
#Filter ranks different from...
y_regional<- x_regional %>%
  filter(Name_matched_rank!="species")%>%
  filter(Name_matched_rank!="subspecies")
write.xlsx2(y, "/home/gioele/Documenti/ISIBIOD/checklist_SQL/da_cambiare_in_regional_alien.xlsx", sheetName = "Sheet1",
  col.names = TRUE, row.names = TRUE, append = FALSE)

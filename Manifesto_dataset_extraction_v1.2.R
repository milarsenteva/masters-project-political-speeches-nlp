library(dplyr)
library(readxl)
library(openxlsx)

mpds <- read_excel("C:/Users/mila1/Music/Bocconi курсы/NLP/Final Project/MPDataset_MPDS2025a.xlsx")

data_corpus2025a <- readRDS("C:/Users/mila1/Music/Bocconi курсы/NLP/Final Project/data_corpus2025a.RDS")

corp <- mpds %>%
  mutate(
    edate = as.Date(edate),
    party = as.character(party),
    date = as.character(date),
    manifesto_id = paste0(party, "_", date)
  ) %>%
  filter(
    countryname %in% c("Italy", "United States", "Australia", "United Kingdom"),
    edate >= as.Date("1948-01-01")
  )

data_corpus2025a <- data_corpus2025a %>%
  mutate(
    party = as.character(party),
    date = as.character(date),
    manifesto_id = as.character(manifesto_id),
    cmp_code = as.character(cmp_code)
  )

merged_filtered <- data_corpus2025a %>%
  inner_join(corp, by = c("manifesto_id", "party", "date")) %>%
  filter(cmp_code %in% c("601.2", "602.2",
                         
                         # migration adjacent
                         "607.2", "608.2",
                         "607.1", "608.1",
                         "201.2",
                         
                         # war core
                         "104", "105",
                         
                         # war adjacent
                         "102", "106", "107", "109")) %>%
  filter(annotations == TRUE) %>%
  filter(is_primary_doc == TRUE | is.na(is_primary_doc)) %>%
  mutate(
    flag_contradiction = coalesce(may_contradict_core_dataset == TRUE, FALSE)
  )

write.xlsx(merged_filtered, "Manifesto_filtered_v1.2.xlsx")
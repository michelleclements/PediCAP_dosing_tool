library(tidyverse)

dosing_info <- read_csv("PediCAP_dosing_tool_app/dosing_info.csv")

input <- tibble(
  
  firstIVdate = as.Date("2021-03-21"), 
  firstOraldate = as.Date("2021-03-23"), 
  firstOraltimeperiod = "AM", 
  randomisedDrug = "Amoxicillin", 
  randomisedDuration = "5", 
  weight = 22
)


results <- tribble(
  ~ item, 
  "Days of IV taken",
  "Days of oral to take",
  "Weight band",
  "Number of tablets to take in the morning", 
  "Number of tablets to take in the evening", 
  "Number of oral doses required", 
  "Number of oral doses to dispense (including extra dose)", 
  "Number of tablets to dispense"
) %>% mutate(value = NA)

# fill in values
results$value[results$item == "Weight band"] <- ifelse(input$weight < 3, "Under 3kg - not eligible", 
                                                       ifelse(input$weight < 6, "3-<6kg",
                                                              ifelse(input$weight < 10, "6-<10kg",
                                                                     ifelse(input$weight < 14, "10-<14kg",
                                                                            ifelse(input$weight < 20, "14-<20kg",
                                                                                   ifelse(input$weight < 25, "20-<25kg",
                                                                                          ifelse(input$weight < 25, "25-<35kg",
                                                                                                 ifelse(input$weight >= 35 , "35kg+ - not eligible",
                                                                                                        "Enter weight"))))))))
results$value[results$item == "Number of tablets to take in the morning"] <- dosing_info$Tablets_AM[dosing_info$weightband == results$value[results$item == "Weight band"] & dosing_info$drug == input$randomisedDrug]
results$value[results$item == "Number of tablets to take in the evening"] <- dosing_info$Tablets_PM[dosing_info$weightband == results$value[results$item == "Weight band"] & dosing_info$drug == input$randomisedDrug]

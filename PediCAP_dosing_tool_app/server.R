#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    
    # bring in dosing info
    dosing_info <- read_csv("dosing_info.csv")
    

    output$ResultsTable <- renderTable({
        
        # set up empyty results tble
        results <- tribble(
            ~ item, 
            "Days of IV taken (D9)",
            "Days of oral antibiotics still to take (D10)",
            "Weight band",
            "Number of tablets to take in the morning (D13a)", 
            "Number of tablets to take in the evening (D13b)", 
            "Number of oral doses required", 
            "Number of oral doses to dispense (including extra dose)", 
            "Number of tablets to dispense (including extra dose)"
        ) %>% mutate(value = NA)
        
        if(!is.na(input$weight)){
            results$value[results$item == "Weight band"] <- ifelse(input$weight < 3, "Under 3kg - not eligible", 
                                                               ifelse(input$weight < 6, "3-<6kg",
                                                                      ifelse(input$weight < 10, "6-<10kg",
                                                                             ifelse(input$weight < 14, "10-<14kg",
                                                                                    ifelse(input$weight < 20, "14-<20kg",
                                                                                           ifelse(input$weight < 25, "20-<25kg",
                                                                                                  ifelse(input$weight < 25, "25-<35kg",
                                                                                                         ifelse(input$weight >= 35 , "35kg+ - not eligible"))))))))
        }

        if(!is.na(input$weight) & input$randomisedDrug != ""){
        results$value[results$item == "Number of tablets to take in the morning (D13a)"] <- dosing_info$Tablets_AM[dosing_info$weightband == results$value[results$item == "Weight band"] & dosing_info$drug == input$randomisedDrug]
        results$value[results$item == "Number of tablets to take in the evening (D13b)"] <- dosing_info$Tablets_PM[dosing_info$weightband == results$value[results$item == "Weight band"] & dosing_info$drug == input$randomisedDrug]
        
        }
        
        results
    

        
    })
    
})

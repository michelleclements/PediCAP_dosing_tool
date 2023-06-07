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
library(lubridate)

# Define server logic
shinyServer(function(input, output, session) {
    
    
    # bring in dosing info
    dosing_info <- read_csv("dosing_info.csv")
    
    
    output$DurationTable <- renderTable({
        
      firstIVhour <- ifelse(input$firstIVhour == 24, 0, as.numeric(input$firstIVhour))
      firstIVdate <-  ifelse(input$firstIVhour == 24, as.Date(input$firstIVdate + 1), as.Date(input$firstIVdate))

        # days of antibiotics taken
        taken <- ifelse(input$firstOraldate > firstIVdate & input$firstOraltimeperiod != "", 
                         input$firstOraldate - firstIVdate - (0.5 * as.numeric(firstIVhour >= 12)) + (0.5 * as.numeric(input$firstOraltimeperiod == "PM")), NA)
        # make NA if less than one
        taken <- ifelse(taken < 1, NA, taken)
        
        # days of antibioitcs still to take
        totake <- ifelse(!is.na(taken) & input$randomisedDuration != "", 
                         as.numeric(input$randomisedDuration) - taken, NA) 
                         
        # make zero if have already taken more than randomised to
        totake <- ifelse(totake <0, 0, totake)
        
        # make error if PediCAP-B not 6
        totake <- ifelse(input$randomisedDrug %in% c("Co-amoxiclav 4:1", "Co-amoxiclav 14:1") & !is.na(input$randomisedDuration) & input$randomisedDuration != 6, 
                         "Error: randomised duration in PediCAP-B must be 6 days", as.character(totake))
        
        # create a table
        duration <- tribble(
            ~ Duration, ~ value,
            "Days of IV taken (D9)", as.character(taken),
            "Days of oral antibiotics still to take (D10)", totake) 
    
        
        duration
        
    })
    
    

    output$DosingTable <- renderTable({
        
        
      firstIVhour <- ifelse(input$firstIVhour == 24, 0, as.numeric(input$firstIVhour))
      firstIVdate <-  ifelse(input$firstIVhour == 24, as.Date(input$firstIVdate + 1), as.Date(input$firstIVdate))
      
      # days of antibiotics taken
      taken <- ifelse(input$firstOraldate > firstIVdate & input$firstOraltimeperiod != "", 
                      input$firstOraldate - firstIVdate - (0.5 * as.numeric(firstIVhour >= 12)) + (0.5 * as.numeric(input$firstOraltimeperiod == "PM")), NA)
        
        # make NA if less than one
        taken <- ifelse(taken < 1, NA, taken)
        
        # days of antibioitcs still to take
        totake <- ifelse(!is.na(taken) & input$randomisedDuration != "", 
                         as.numeric(input$randomisedDuration) - taken, NA) 
        
        # make zero if have already taken more than randomised to
        totake <- ifelse(totake <0, 0, totake)
        
        # make error if PediCAP-B not 6
        totake <- ifelse(input$randomisedDrug %in% c("Co-amoxiclav 4:1", "Co-amoxiclav 14:1") & !is.na(input$randomisedDuration) & input$randomisedDuration != 6, NA, totake)
        
        
        # weight band
        weightband <- ifelse(is.na(input$weight), NA, 
                             ifelse(input$weight < 3, "Under 3kg - not eligible", 
                             ifelse(input$weight < 6, "3-<6kg",
                                    ifelse(input$weight < 10, "6-<10kg",
                                           ifelse(input$weight < 14, "10-<14kg",
                                                  ifelse(input$weight < 20, "14-<20kg",
                                                         ifelse(input$weight < 25, "20-<25kg",
                                                                ifelse(input$weight < 25, "25-<35kg",
                                                                       ifelse(input$weight >= 35 , "35kg+ - not eligible")))))))))
            
         # number of tabs to take in the morning
         ntabsmorning <-  ifelse(!is.na(weightband) & input$randomisedDrug != "",
                                dosing_info$Tablets_AM[dosing_info$weightband == weightband & dosing_info$drug == input$randomisedDrug], NA)

         # number of tabs to take in the evening
         ntabsevening <-  ifelse(!is.na(weightband) & input$randomisedDrug != "",
                                dosing_info$Tablets_PM[dosing_info$weightband == weightband & dosing_info$drug == input$randomisedDrug], NA)

         # number of oral doses
         ndoses <- totake * 2

         # number to dispense
         ndispense <- ifelse(ndoses ==0, 0, ndoses + 1)

         # ntablets - number of morning doses * morning tabs + number of evening doses * evening tabs + morning tab (for extra dose as always the bigger one)
         # if start oral in the morning then number of morning doses is ndoses/2 rounded up, and number of evening doses is ndoses/2 rounded down
         # if start oral in the evening then number of morning doses is ndoses/2 rounded down, and number of evening doses is ndoses/2 rounded up
         ntabstotal <- ifelse(ndispense == 0, 0, 
                              ifelse(!is.na(ntabsmorning) & !is.na(ntabsevening) & input$firstOraltimeperiod == "AM",
                                     ceiling(ndoses/2) * ntabsmorning + floor(ndoses/2) * ntabsevening + ntabsmorning,
                                     ifelse(!is.na(ntabsmorning) & !is.na(ntabsevening) & input$firstOraltimeperiod == "PM",
                                            floor(ndoses/2) * ntabsmorning + ceiling(ndoses/2) * ntabsevening + ntabsmorning, NA)))
        
        
        # set up dosing results tble
        dosing <- tribble(
            ~ Dosing, ~value,
            "Weight band", weightband,
            "Number of tablets to take in the morning (D13a)", as.character(ntabsmorning),
            "Number of tablets to take in the evening (D13b)", as.character(ntabsevening),
            "Number of oral doses required", as.character(ndoses),
            "Number of oral doses to dispense (including extra dose)", as.character(ndispense),
            "Number of tablets to dispense (including extra dose)", as.character(ntabstotal)
        ) 
        
        
        dosing
    
    })
    
})

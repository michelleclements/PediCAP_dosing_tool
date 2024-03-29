#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# PediCAP dosing tool

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("PediCAP dosing tool"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            
            # date of first IV dose
            dateInput("firstIVdate", "Date of first IV dose (D5a)", 
                      value = Sys.Date(),
                      min = Sys.Date()-10, max = Sys.Date()+10, format = "dd/mm/yyyy",
                      weekstart = 1),
            
            # hour of first IV dose
            selectInput("firstIVhour", "Hour of first IV dose in 24h clock (0-24; 0 is midnight at start of day, 24 is midnight at end of day))", 
                        choices = c("", as.character(seq(0, 24)))),
            
            
            # Date of first oral dose
            dateInput("firstOraldate", "Date of first oral dose (D14a; must be after date of first IV dose)", 
                      value = Sys.Date(),
                      min = Sys.Date()-10, max = Sys.Date()+30, format = "dd/mm/yyyy",
                      weekstart = 1),
            
            
            # time period of first oral dose
            selectInput("firstOraltimeperiod", "Time period of first oral dose", 
                        choices = c("", "AM", "PM")),
            
            # randomised formulation
            selectInput("randomisedDrug", "Randomised oral formulation (D7)", 
                        choices = c("", "Amoxicillin", "Co-amoxiclav 7:1", "Co-amoxiclav 4:1", "Co-amoxiclav 14:1")),
            
            # randomised days
            selectInput("randomisedDuration", "Total days of antibiotics randomised to (D8). Must be 6 for PediCAP-B", 
                        choices = c("", "4", "5", "6", "7", "8")),
            
            
            # weight at oral step-down
            numericInput("weight", "Weight at oral step-down (kg to one decimal place) (D12)", 
                         value = NA,
                        min = 3, max = 35, step = 0.1)
        ),

        # Show a plot of the generated distribution
        mainPanel(
            
            tableOutput("DurationTable"),
            
            tableOutput("DosingTable")
        )
    )
))

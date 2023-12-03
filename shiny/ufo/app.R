#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(tidyverse)

ufo_subset = read_csv("./data/ufo_subset.csv")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("UFO Sightings Map"),
    leafletOutput("map")
)

    
# Define server logic required to draw a histogram
server <- function(input, output) {

    output$map <- renderLeaflet({
      leaflet(ufo_subset) |>
        addTiles() |>
        addMarkers(~city_longitude, ~city_latitude, popup = ~as.character(city))
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

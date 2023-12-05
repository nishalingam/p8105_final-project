#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


# ## - map show
# library(ggplot2)
# library(tidyverse)
# library(dplyr)
# library(maps)
# usaMap <- map_data("state")
# 
# clean_df = read_csv("data/ufo_clean.csv") |>
#   drop_na() |>
#   group_by(state) |>
#   summarize(report_freq = n(), avg_duration = mean(duration_clean))
# 
# cen_df = read_csv("data/us_census.csv") |> 
#   select(abbrv, census_2010, census_2020) |> 
#   rename(state = abbrv)
# 
# clean_df_combined = left_join(clean_df, cen_df, by = c("state")) |>
#   mutate(report_freq_per_100k = (report_freq / census_2010)*100000) |>
#   rename(abbrev = state)
# 
# state_names = read_csv("data/table-data.csv") |> select(state, code) |>
#   rename(abbrev = code)
# 
# fin_clean_df = left_join(clean_df_combined, state_names, by = c("abbrev")) |> 
#   select("state", everything()) |>
#   mutate(census_2010 = census_2010 / 100)
# 
# 
# which_state <- function(mapData, long, lat) {
#   # This function decide the state being clicked. 
#   #
#   # Args:
#   #   mapData: The map data has a column "long" and a column "lat" to determine
#   #       state borders. 
#   #   long, lat: longitude and latitude of the clicked point. They are actually
#   #       input$clickMap$x and input$clickMap$y assuming click = "clickMap".
#   #
#   # Returns: 
#   #   The name of the state containing the point (long, lat).
#   
#   # calculate the difference in long and lat of the border with respect to this point
#   mapData$long_diff <- mapData$long - long
#   mapData$lat_diff <- mapData$lat - lat
#   
#   # only compare borders near the clicked point to save computing time
#   mapData <- mapData[abs(mapData$long_diff) < 20 & abs(mapData$lat_diff) < 15, ]
#   
#   # calculate the angle between the vector from this clicked point to border and c(1, 0)
#   vLong <- mapData$long_diff
#   vLat <- mapData$lat_diff
#   mapData$angle <- acos(vLong / sqrt(vLong^2 + vLat^2))
#   
#   # calculate range of the angle and select the state with largest range
#   rangeAngle <- tapply(mapData$angle, mapData$region, function(x) max(x) - min(x))
#   return(names(sort(rangeAngle, decreasing = TRUE))[1])
# }
# 
# # build the app
# library(shiny)
# 
# plotMap <- ggplot(usaMap, aes(x = long, y = lat, group = group)) + 
#   geom_polygon(fill = "white", color = "black")
# 
# plotReport_Duration <- ggplot(fin_clean_df, aes(x = report_freq_per_100k, y = avg_duration)) + 
#   geom_point(aes(size = census_2010, color = census_2010)) + 
#   scale_size(limits = c(1, 1000000))
# 
# # Define UI for application that draws a histogram
# ui <- shinyUI(fluidPage(
#   column(
#     width = 6,
#     plotOutput("map", click = "clickMap", width = 430, height = 275)
#   ),
#   column(
#     width = 6,
#     plotOutput("ufo", width = 430, height = 275)
#   )
#   
#   # # Application title
#   # titlePanel("Old Faithful Geyser Data"),
#   # 
#   # # Sidebar with a slider input for number of bins 
#   # sidebarLayout(
#   #     sidebarPanel(
#   #         sliderInput("bins",
#   #                     "Number of bins:",
#   #                     min = 1,
#   #                     max = 50,
#   #                     value = 30)
#   #     ),
#   # 
#   #     # Show a plot of the generated distribution
#   #     mainPanel(
#   #        plotOutput("distPlot")
#   #     )
#   # )
# ))
# 
# # Define server logic required to draw a histogram
# server <- shinyServer(function(input, output) {
#   # intital plots
#   output$map <- renderPlot({
#     plotMap
#     # coord_map(), do not use it. More discussion next section.
#   })
#   output$ufo <- renderPlot({
#     plotReport_Duration
#   })
#   
#   # plot after click
#   observeEvent(input$clickMap, {
#     xClick <- input$clickMap$x
#     yClick <- input$clickMap$y
#     state <- which_state(usaMap, xClick, yClick)
#     output$map <- renderPlot(
#       plotMap + 
#         geom_polygon(data = usaMap[usaMap$region == state,], fill = "yellow") +
#         annotate("text", x = xClick, y = yClick, label = state, color = "red")
#     )
#     output$ufo <- renderPlot({
#       plotReport_Duration +
#         geom_point(data = fin_clean_df[tolower(fin_clean_df$state) == state,],
#                    size = 6, shape = 2, color = "red")
#     })
#   })
# })
# 
# # output$distPlot <- renderPlot({
# #     # generate bins based on input$bins from ui.R
# #     x    <- faithful[, 2]
# #     bins <- seq(min(x), max(x), length.out = input$bins + 1)
# # 
# #     # draw the histogram with the specified number of bins
# #     hist(x, breaks = bins, col = 'darkgray', border = 'white',
# #          xlab = 'Waiting time to next eruption (in mins)',
# #          main = 'Histogram of waiting times')
# # })
# 
# 
# # Run the application 
# shinyApp(ui = ui, server = server)

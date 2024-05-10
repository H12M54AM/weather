library(shiny)
library(bslib)
library(httr)
library(jsonlite)
library(lubridate)

ui <- fluidPage(
  div(class = "intro",
    titlePanel("Dashboard - Weather Reports"),
    h4("Powered by ", 
       actionLink("website", "edwardcreates.ca", onclick = "window.open('https://www.edwardcreates.ca/', '_blank')")),
    
  ),
  actionButton("refresh", "Refresh", 
               icon = icon("arrows-rotate")),
  card(
    div(class = "k-hstack", 
        layout_columns(
          value_box(
            title = "Current Temp",
            value = "XX ˚C",
            showcase = bsicons::bs_icon("calendar-event"),
            theme = value_box_theme(bg = "#e6f2fd", fg = "#0B538E"),
            class = "value_box"
          ),
          
          value_box(
            title = "Lowest Temperature",
            value = textOutput("minTemp"),
            showcase = bsicons::bs_icon("thermometer-low"),
            theme = value_box_theme(bg = "#e6f2fd", fg = "#0B538E"),
            class = "value_box"
          ),
          
          value_box(
            title = "Highest Temperature",
            value = textOutput("maxTemp"),
            showcase = bsicons::bs_icon("thermometer-high"),
            theme = value_box_theme(bg = "#e6f2fd", fg = "#0B538E"),
            class = "value_box"
          ),
          
          value_box(
            title = "Average Temperature",
            value = textOutput("avgTemp"),
            showcase = bsicons::bs_icon("calendar3"),
            theme = value_box_theme(bg = "#e6f2fd", fg = "#0B538E"),
            class = "value_box"
          ),
        ), 
    ),
    tags$style(
      "
      .k-hstack {
        margin-top: 1rem;
        margin-bottom: 3rem;
      }
      .intro {
        margin-bottom: 4rem;
      }
      .value_box {
        width: 4/6;
      }
      "
    ),
  ),
  card(
    
    plotOutput("apiPlot")
  ),
  card(
    plotOutput("statPlot")
  )
)

server <- function(input, output) {
  observeEvent(input$refresh, {
    # Refresh the entire page
    session$reload()
  })
  
  # Must pull weather data from Vancouver
  fetchData <- function() {
    response <- GET("https://api.open-meteo.com/v1/forecast?latitude=49.2608724&longitude=-123.113952&hourly=temperature_2m&timeformat=unixtime&timezone=America%2FLos_Angeles&forecast_days=1")
    
    if (status_code(response) >= 200 && status_code(response) < 400) {
      data <- fromJSON(content(response, "text"))
      return(list(
        time = data$hourly$time, 
        temp = data$hourly$temperature_2m
      ))
    } 
    
    if (status_code(response) >= 400 && status_code(response) < 500) {
      return("API Failed due to Human Error")
    }
    
    if (status_code(response) >= 500 && status_code(response) < 600) {
      return("API Failed due to Server Side Error\n\nPlease review the server...")
    }
  }
  
  # Min Temperature today
  output$minTemp <- renderText({
    data <- fetchData()
    paste(round(min(data$temp, na.rm = TRUE), digits = 2), "°C")
  })
  
  # Max Temperature today
  output$maxTemp <- renderText({
    data <- fetchData()
    paste(round(max(data$temp, na.rm = TRUE), digits = 2), "°C")
  })
  
  # Avg Temperature today
  output$avgTemp <- renderText({
    data <- fetchData()
    paste(round(mean(data$temp, na.rm = TRUE), digits = 2), "°C")
  })
  
  # Line Chart of Hourly Changes in Temperature
  output$apiPlot <- renderPlot({
    data <- fetchData()
    chartTitle = "Todays Temperature in Vancouver per Hour"
    
    # Convert Unix timestamp to R-readable timestamp
    r_timestamp <- as.Date(as.POSIXct(as.numeric(data$time), origin = "1970-01-01"))
    
    # Used to show what the datetime info looks like before using the as.Date function
    unconverted <- as.POSIXct(as.numeric(data$time), origin = "1970-01-01")
    
    # Isolates the Time from the Datetime
    unconverted_hours <- format(unconverted, "%H:%M")
    
    
    plot(unconverted, data$temp, type = "b", col = "#0B538E", xlab = "Hours in PST", ylab = "Temperature (°C)", main = chartTitle,
         xlim = c(min(data$time), max(data$time)))
  })
  
  # Bar Chart of general Stats
  output$statPlot <- renderPlot({
    data <- fetchData()
    chartTitle = "Comparison of General Stats about Hourly Temps"
    xaxis = c(min(data$temp, na.rm = TRUE), mean(data$temp, na.rm = TRUE), IQR(data$temp, na.rm = TRUE), max(data$temp, na.rm = TRUE))
    xLabels = c("Min Temp", "Average Temp", "IQR", "Max Temp")
    
    barplot(xaxis, 
            xlab = "Stats",
            ylab = "Temperature ˚C",
            names.arg = xLabels,
            col = "#e6f2fd",
            main = chartTitle
    )
  })
}

shinyApp(ui = ui, server = server)

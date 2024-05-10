library(shiny)
library(bslib)
library(httr)
library(jsonlite)
library(lubridate)

ui <- fluidPage(
  div(
    class = "intro",
    titlePanel("Dashboard - Weather Reports"),
    h4(
      "Powered by ",
      actionLink("website", "edwardcreates.ca", onclick = "window.open('https://www.edwardcreates.ca/', '_blank')")
    ),
    actionButton("github", "", onclick = "window.open('https://github.com/H12M54AM/weather')", icon = icon("github")),
    actionButton(
      "linkedin",
      "",
      onclick = "window.open('https://www.linkedin.com/in/edward-naidoo-595ab5224/')",
      icon = icon("linkedin")
    ),
    actionButton("devto", "", onclick = "window.open('https://dev.to/edward_naidoo')", icon = icon("dev")),
  ),
  
  sidebarLayout(
    sidebarPanel(
      card(
        actionButton("van", "Vancouver", icon = icon("building")),
        actionButton("bur", "Burnaby", icon = icon("building")),
        actionButton("rich", "Richmond", icon = icon("building")),
        actionButton("sur", "Surrey", icon = icon("building")),
        actionButton("lang", "Langley", icon = icon("building")),
        actionButton("abby", "Abbotsford", icon = icon("building")),
      ),
    ),
    mainPanel(
      actionButton("refresh", "Refresh", icon = icon("arrows-rotate")),
      card(
        div(
          class = "k-hstack",
          layout_columns(
            value_box(
              title = "Current Temp - Comming Soon...",
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
      
      card(plotOutput("apiPlot")),
      card(plotOutput("statPlot")),
      card(plotOutput("boxPlot"))
    )
  )
)

server <- function(input, output) {
  observeEvent(input$refresh, {
    # Refresh the entire page
    session$reload()
  })
  
  # This function is a template used
  # to allow users to click on any
  # button and recieve different
  # data in that city.
  
  # For example; A user can click
  # the 'Vancouver' button and
  # recieve weather data from
  # vancity. If a user want to see
  # Surrey, they can click Surrey.
  dataDisplay <- function(api) {
    
    return(time)
  }
  
  # Must pull weather data from Vancouver
  fetchData <- function() {
    response <- GET(
      "https://api.open-meteo.com/v1/forecast?latitude=49.2497&longitude=-123.1193&hourly=temperature_2m&timeformat=unixtime&timezone=America%2FLos_Angeles&forecast_days=1"
    )
    
    if (status_code(response) >= 200 &&
        status_code(response) < 400) {
      data <- fromJSON(content(response, "text"))
      return(list(
        time = data$hourly$time,
        temp = data$hourly$temperature_2m
      ))
    }
    
    if (status_code(response) >= 400 &&
        status_code(response) < 500) {
      return("API Failed due to Human Error")
    }
    
    if (status_code(response) >= 500 &&
        status_code(response) < 600) {
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
    
    listOfHours <- c(
      "00:00",
      "01:00",
      "02:00",
      "03:00",
      "04:00",
      "05:00",
      "06:00",
      "07:00",
      "08:00",
      "09:00",
      "10:00",
      "11:00",
      "12:00",
      "13:00",
      "14:00",
      "15:00",
      "16:00",
      "17:00",
      "18:00",
      "19:00",
      "20:00",
      "21:00",
      "22:00",
      "23:00"
    )
    xLimits <- 1:length(listOfHours)
    plot(
      xLimits,
      data$temp,
      type = "b",
      col = "#0B538E",
      xlab = "Hours in PST",
      ylab = "Temperature (°C)",
      main = chartTitle,
      xlim = range(xLimits)
    )
    text(
      xLimits,
      data$temp,
      labels = as.character(data$temp),
      pos = 1,
      offset = 1.1
    )
  })
  
  # Box Plot of the Temp Data
  output$boxPlot <- renderPlot({
    data <- fetchData()
    boxplot(data$temp, main = "Boxplot of Todays Changing Weather", col = "#e6f2fd")
  })
  
  # Bar Chart of general Stats
  output$statPlot <- renderPlot({
    data <- fetchData()
    chartTitle = "Comparison of General Stats about Hourly Temps"
    yaxis = c(
      min(data$temp, na.rm = TRUE),
      mean(data$temp, na.rm = TRUE),
      IQR(data$temp, na.rm = TRUE),
      max(data$temp, na.rm = TRUE)
    )
    xLabels = c("Min Temp", "Average Temp", "IQR", "Max Temp")
    
    barplot(
      yaxis,
      xlab = "Stats",
      ylab = "Temperature ˚C",
      names.arg = xLabels,
      col = "#e6f2fd",
      main = chartTitle
    )
    text(
      x = xLabels,
      labels = yaxis,
      pos = 3,
      offset = yaxis + 1
    )
  })
}

shinyApp(ui = ui, server = server)

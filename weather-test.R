library(httr)
library(jsonlite)

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

# Get the temperature data
data <- fetchData()

# Print the temperature data
print(data$temp)

# Calculate and print the max, min, and average temperature
cat("Max: ",  max(as.numeric(data$temp)), "˚C")
cat("Min: ", min(as.numeric(data$temp)), "˚C")
cat("Average: ", mean(as.numeric(data$temp)), "˚C")
cat("IQR: ", IQR(data$temp, na.rm = TRUE))


# Example Unix timestamp
unix_timestamp <- 1683449760  # May 7, 2023 at 11:26 PM

# Convert Unix timestamp to R-readable timestamp
r_timestamp <- as.Date(as.POSIXct(as.numeric(data$time), origin = "1970-01-01"))

# Used to show what the datetime info looks like before using the as.Date function
unconverted <- as.POSIXct(as.numeric(data$time), origin = "1970-01-01")
print(unconverted)

# Isolates the Time from the Datetime
unconverted_hours <- format(unconverted, "%H:%M")
print(unconverted_hours)

# Converting from something to something else because "extra"
dateConverted <- as.Date(r_timestamp)
print(dateConverted)
print(r_timestamp)

# Extract the hour of the day
hour_of_day <- format(r_timestamp, "%Y-%m-%d %H:%M:%S")

# Print the hour of the day
print(paste("Hour of the day:", hour_of_day))

ySpacing = c(min(as.numeric(data$temp), na.rm = TRUE), max(as.numeric(data$temp), na.rm = TRUE))
plot(unconverted, data$temp, xlim = range(data$time), type = "b", main = "Hourly Changes in Temperature in Vancouver")

current_time <- Sys.time()
print(current_time)

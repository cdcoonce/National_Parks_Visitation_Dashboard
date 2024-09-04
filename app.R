
library(shiny)
library(DT)
library(ggplot2)
library(scales)
library(RColorBrewer)
library(dplyr)
library(readr)

# Load and preprocess data
csv_path <- "data/ParksVisitationData.csv"

# Check if the file exists
if (file.exists(csv_path)) {
  parks_data <- read_csv(csv_path)
  
  parks_data <- parks_data %>% 
    filter(Year != "Total") %>%  # Remove rows with non-numeric Year
    mutate(Year = as.numeric(Year)) %>%  # Convert Year to numeric
    filter(!is.na(Year))  # Remove rows where Year conversion resulted in NA
} else {
  stop(paste("Error: The file", csv_path, "does not exist. Please check the file path."))
}

# Define UI for the application
ui <- fluidPage(
  
  # Application title
  titlePanel("National Parks Visitation Dashboard"),
  
  # Sidebar layout with input and output definitions
  sidebarLayout(
    sidebarPanel(
      # Dropdown for selecting multiple parks
      selectInput("selectedPark", "Choose National Parks:", 
                  choices = unique(parks_data$Park),
                  selected = unique(parks_data$Park)[1],
                  multiple = TRUE),
      
      # Slider for selecting a range of years
      sliderInput("yearRange", "Select Year Range:",
                  min = min(parks_data$Year, na.rm = TRUE),
                  max = max(parks_data$Year, na.rm = TRUE),
                  value = c(min(parks_data$Year, na.rm = TRUE), max(parks_data$Year, na.rm = TRUE)),
                  step = 4, sep = ""),
      
      # Outputs to display region and state with spacing adjustments
      tags$div(
        style = "margin-top: px; margin-bottom: 2px;",
        textOutput("regionText")  # Output for region
      ),
      tags$div(
        style = "margin-bottom: 15px;",
        textOutput("stateText")   # Output for state
      ),
      
      # Legend for the data table colors
      tags$div(
        style = "margin-top: 10px;",
        h4("Legend for Visitor Colors"),
        tags$ul(
          tags$li(tags$span(style = "display:inline-block;width:15px;height:15px;background-color:#87bc45;"), " 0 - 100,000 Visitors"),
          tags$li(tags$span(style = "display:inline-block;width:15px;height:15px;background-color:#ede15b;"), " 100,001 - 500,000 Visitors"),
          tags$li(tags$span(style = "display:inline-block;width:15px;height:15px;background-color:#ef9b20;"), " 500,001 - 1,000,000 Visitors"),
          tags$li(tags$span(style = "display:inline-block;width:15px;height:15px;background-color:#ea5545;"), " > 1,000,000 Visitors")
        )
      )
    ),
    
    # Main panel for displaying outputs
    mainPanel(
      plotOutput("visitationPlot"),  # Plot for time-series data
      dataTableOutput("parkTable")   # Data table for detailed park data
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  # Reactive expression to filter data based on user input
  filteredData <- reactive({
    parks_data %>%
      filter(Park %in% input$selectedPark,
             Year >= input$yearRange[1], 
             Year <= input$yearRange[2])
  })
  
  # Extract unique regions and states for the selected parks
  selectedRegion <- reactive({
    unique(filteredData()$Region)
  })
  
  selectedState <- reactive({
    unique(filteredData()$State)
  })
  
  # Render the region and state text outputs
  output$stateText <- renderText({
    paste("State(s):", paste(selectedState(), collapse = ", "))
  })
  
  
  output$regionText <- renderText({
    paste("Region(s):", paste(selectedRegion(), collapse = ", "))
  })
  
  
  # Render the time-series plot
  output$visitationPlot <- renderPlot({
    park_data <- filteredData()
    
    ggplot(park_data, aes(x = Year, y = Visitors, color = Park, group = Park)) + 
      geom_line(size = 1.2) +
      geom_point(size = .5) +
      labs(title = "Visitation Numbers for Selected National Parks",
           x = "Year",
           y = "Number of Visitors",
           color = "Park") +  
      scale_y_continuous(labels = scales::comma) +
      scale_color_brewer(palette = "Set1") + 
      theme_minimal() +
      theme(
        plot.title = element_text(face = "bold", size = 14), 
        axis.title.x = element_text(face = "bold", size = 12), 
        axis.title.y = element_text(face = "bold", size = 12)
      )
  })
  
  # Render the data table with custom styles
  output$parkTable <- renderDataTable({
    park_data <- filteredData() %>% select(Park, Year, Visitors)
    datatable(park_data, options = list(pageLength = 10,
              search = list(placeholder = "Search by park, year, or visitors...") 
                                        )) %>%
      formatStyle('Visitors', 
                  fontWeight = 'bold',
                  `text-align` = 'right') %>%
      formatStyle('Visitors', 
                  backgroundColor = styleInterval(c(100000, 500000, 1000000), 
                                                  c('#87bc45', '#ede15b', '#ef9b20', '#ea5545'))) %>%
      formatStyle('Year',
                  fontSize = '12px', 
                  color = 'black', 
                  fontWeight = 'bold') %>%
      formatCurrency('Visitors',currency = "", interval = 3, mark = ",", digits=0)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

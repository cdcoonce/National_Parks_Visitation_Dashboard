# National Parks Visitation Dashboard

[This Shiny dashboard](https://iuq9gs-charles-coonce.shinyapps.io/visitation/) allows users to interactively explore visitation data for U.S. National Parks. It provides dynamic visualizations and an interactive data table to help users better understand visitation trends over time.

## Features

- **Interactive Filtering:**  
  - Select one or more national parks using a drop-down menu.
  - Adjust the year range with a slider to filter the data.
- **Dynamic Visualizations:**  
  - A time-series line chart displays visitation numbers by park.
  - The chart updates automatically based on user selections.
- **Interactive Data Table:**  
  - View detailed records including park name, year, and number of visitors.
  - Custom styling with color coding based on visitor counts.
- **Additional Information:**  
  - Displays the regions and states for the selected parks.
  - Includes a legend explaining the visitor count color scheme.

## How It Works

- **Data Loading & Preprocessing:**

  - The app reads the CSV file, filters out rows where the Year is “Total”, converts the Year column to numeric, and removes invalid rows.
- **User Interface (UI):**
  - The UI is built with Shiny’s fluidPage layout. It includes:
- A sidebar with filters (drop-down for parks, slider for year range) and text outputs for region and state information.
- A main panel that displays the visitation line chart and an interactive data table.
- Server Logic:
  - The server code uses reactive expressions to filter the data based on user input and renders the plot and table dynamically. The plot uses ggplot2 for visualizations, and the table is rendered with the DT package, complete with custom styles.

## Future Enhancements

- Additional visualizations and interactivity.
- More detailed filtering options.
- Export functionality for data or visualizations.
- UI/UX improvements.

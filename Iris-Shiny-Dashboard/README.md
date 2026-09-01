# Iris Explorer Shiny Dashboard

This project is an interactive R Shiny dashboard built with the built-in `iris` data set.

## Features

- Filters the dashboard by one or more Iris species.
- Lets the user select the X-axis and Y-axis used in the scatter plot.
- Lets the user select the measurement used in the box plot and histogram.
- Lets the user change the number of histogram bins.
- Displays three interactive Plotly visualizations:
  1. Scatter plot with trend lines
  2. Box plot by species
  3. Histogram by species
- Includes a searchable and filterable data table.
- Shows summary cards that update with the selected filters.

## Required packages

Install the packages below in RStudio if they are not already installed:

```r
install.packages(c("shiny", "shinydashboard", "ggplot2", "plotly", "DT"))
```

## Run the app

1. Download or clone this repository.
2. Open `app.R` in RStudio.
3. Click **Run App**.

Alternatively, run this command from the project folder:

```r
shiny::runApp()
```

## Data source

The app uses the `iris` data set included with R, so no external data file is required.

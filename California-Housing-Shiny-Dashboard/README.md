# California Housing Shiny Dashboard

This R Shiny project uses housing.csv to create an interactive dashboard for exploring the California housing data set.

## Visualizations

1. Number of housing records in NEAR BAY, <1H OCEAN, INLAND, NEAR OCEAN, and ISLAND
2. Population versus households
3. Total rooms versus total bedrooms

The sidebar allows users to filter the dashboard by ocean proximity, show or hide regression trend lines, and adjust the scatter-plot point size.

## Required packages

Install these packages in RStudio:

    install.packages(c(
      "shiny",
      "shinydashboard",
      "ggplot2",
      "plotly",
      "scales"
    ))

## Run the app

1. Download or clone the repository.
2. Keep app.R and housing.csv in the same folder.
3. Open app.R in RStudio.
4. Click **Run App**.

You can also run this command from the project folder:

    shiny::runApp()

## Data

The data contains 20,640 California census-block records.

| Ocean proximity | Records |
| --- | ---: |
| <1H OCEAN | 9,136 |
| INLAND | 6,551 |
| NEAR OCEAN | 2,658 |
| NEAR BAY | 2,290 |
| ISLAND | 5 |

Source: the California housing data set used in *Hands-On Machine Learning*.


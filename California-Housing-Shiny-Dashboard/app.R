library(shiny)
library(shinydashboard)
library(ggplot2)
library(plotly)
library(scales)

# Load the housing data from the same folder as this app.
housing <- read.csv("housing.csv", stringsAsFactors = FALSE, check.names = FALSE)

required_columns <- c(
  "ocean_proximity", "population", "households",
  "total_rooms", "total_bedrooms"
)

missing_columns <- setdiff(required_columns, names(housing))

if (length(missing_columns) > 0) {
  stop(paste(
    "The housing.csv file is missing these required columns:",
    paste(missing_columns, collapse = ", ")
  ))
}

ocean_levels <- c(
  "NEAR BAY", "<1H OCEAN", "INLAND", "NEAR OCEAN", "ISLAND"
)

housing$ocean_proximity <- factor(
  housing$ocean_proximity,
  levels = ocean_levels
)

ocean_colors <- c(
  "NEAR BAY" = "#277DA1",
  "<1H OCEAN" = "#43AA8B",
  "INLAND" = "#F9C74F",
  "NEAR OCEAN" = "#F9844A",
  "ISLAND" = "#9B5DE5"
)

ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(title = "California Housing"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Housing Dashboard", tabName = "dashboard", icon = icon("home")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    ),
    hr(),
    selectInput(
      "ocean_filter",
      "Ocean proximity",
      choices = ocean_levels,
      selected = ocean_levels,
      multiple = TRUE
    ),
    checkboxInput("trend_lines", "Show trend lines", value = TRUE),
    sliderInput(
      "point_size",
      "Scatter point size",
      min = 1,
      max = 5,
      value = 2,
      step = 0.5
    )
  ),
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .content-wrapper { background-color: #f4f6f9; }
        .box { border-radius: 8px; }
        .small-box { border-radius: 8px; }
      "))
    ),
    tabItems(
      tabItem(
        tabName = "dashboard",
        fluidRow(
          valueBoxOutput("home_count", width = 4),
          valueBoxOutput("population_total", width = 4),
          valueBoxOutput("household_total", width = 4)
        ),
        fluidRow(
          box(
            title = "1. Homes by Ocean Proximity",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            plotlyOutput("ocean_chart", height = "400px")
          )
        ),
        fluidRow(
          box(
            title = "2. Population vs Households",
            width = 6,
            status = "success",
            solidHeader = TRUE,
            plotlyOutput("population_chart", height = "430px")
          ),
          box(
            title = "3. Total Rooms vs Total Bedrooms",
            width = 6,
            status = "warning",
            solidHeader = TRUE,
            plotlyOutput("room_chart", height = "430px")
          )
        )
      ),
      tabItem(
        tabName = "about",
        box(
          title = "About This Dashboard",
          width = 12,
          status = "primary",
          solidHeader = TRUE,
          p(
            "This dashboard uses the California housing data set. ",
            "Use the sidebar to filter by ocean proximity, show or hide ",
            "trend lines, and change the scatter plot point size."
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  filtered_housing <- reactive({
    req(input$ocean_filter)
    housing[
      housing$ocean_proximity %in% input$ocean_filter,
      ,
      drop = FALSE
    ]
  })

  output$home_count <- renderValueBox({
    valueBox(
      value = comma(nrow(filtered_housing())),
      subtitle = "Housing records",
      icon = icon("home"),
      color = "aqua"
    )
  })

  output$population_total <- renderValueBox({
    valueBox(
      value = comma(sum(filtered_housing()$population, na.rm = TRUE)),
      subtitle = "Total population",
      icon = icon("users"),
      color = "green"
    )
  })

  output$household_total <- renderValueBox({
    valueBox(
      value = comma(sum(filtered_housing()$households, na.rm = TRUE)),
      subtitle = "Total households",
      icon = icon("building"),
      color = "yellow"
    )
  })

  output$ocean_chart <- renderPlotly({
    counts <- as.data.frame(
      table(filtered_housing()$ocean_proximity),
      stringsAsFactors = FALSE
    )
    names(counts) <- c("ocean_proximity", "homes")
    counts <- counts[counts$homes > 0, , drop = FALSE]

    chart <- ggplot(
      counts,
      aes(
        x = ocean_proximity,
        y = homes,
        fill = ocean_proximity,
        text = paste(
          "Location:", ocean_proximity,
          "<br>Homes:", comma(homes)
        )
      )
    ) +
      geom_col(width = 0.7) +
      geom_text(
        aes(label = comma(homes)),
        vjust = -0.4,
        color = "#333333",
        size = 4
      ) +
      scale_fill_manual(values = ocean_colors) +
      scale_y_continuous(
        labels = comma,
        expand = expansion(mult = c(0, 0.12))
      ) +
      labs(x = NULL, y = "Number of homes") +
      theme_minimal(base_size = 13) +
      theme(
        legend.position = "none",
        panel.grid.major.x = element_blank()
      )

    ggplotly(chart, tooltip = "text")
  })

  output$population_chart <- renderPlotly({
    chart <- ggplot(
      filtered_housing(),
      aes(
        x = households,
        y = population,
        color = ocean_proximity,
        text = paste(
          "Ocean proximity:", ocean_proximity,
          "<br>Households:", comma(households),
          "<br>Population:", comma(population)
        )
      )
    ) +
      geom_point(size = input$point_size, alpha = 0.5) +
      scale_color_manual(values = ocean_colors, drop = FALSE) +
      scale_x_continuous(labels = comma) +
      scale_y_continuous(labels = comma) +
      labs(
        x = "Households",
        y = "Population",
        color = "Ocean proximity"
      ) +
      theme_minimal(base_size = 12) +
      theme(legend.position = "bottom")

    if (isTRUE(input$trend_lines)) {
      chart <- chart +
        geom_smooth(method = "lm", se = FALSE, linewidth = 0.8)
    }

    ggplotly(chart, tooltip = "text")
  })

  output$room_chart <- renderPlotly({
    plot_data <- filtered_housing()
    plot_data <- plot_data[
      !is.na(plot_data$total_rooms) &
        !is.na(plot_data$total_bedrooms),
      ,
      drop = FALSE
    ]

    chart <- ggplot(
      plot_data,
      aes(
        x = total_rooms,
        y = total_bedrooms,
        color = ocean_proximity,
        text = paste(
          "Ocean proximity:", ocean_proximity,
          "<br>Total rooms:", comma(total_rooms),
          "<br>Total bedrooms:", comma(total_bedrooms)
        )
      )
    ) +
      geom_point(size = input$point_size, alpha = 0.5) +
      scale_color_manual(values = ocean_colors, drop = FALSE) +
      scale_x_continuous(labels = comma) +
      scale_y_continuous(labels = comma) +
      labs(
        x = "Total rooms",
        y = "Total bedrooms",
        color = "Ocean proximity"
      ) +
      theme_minimal(base_size = 12) +
      theme(legend.position = "bottom")

    if (isTRUE(input$trend_lines)) {
      chart <- chart +
        geom_smooth(method = "lm", se = FALSE, linewidth = 0.8)
    }

    ggplotly(chart, tooltip = "text")
  })
}

shinyApp(ui = ui, server = server)


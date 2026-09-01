library(shiny)
library(shinydashboard)
library(ggplot2)
library(plotly)
library(DT)

# Prepare the built-in Iris data set.
iris_data <- iris

numeric_columns <- names(iris_data)[vapply(iris_data, is.numeric, logical(1))]

species_colors <- c(
  "setosa" = "#2A9D8F",
  "versicolor" = "#E9C46A",
  "virginica" = "#E76F51"
)

ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(title = "Iris Explorer"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("chart-line")),
      menuItem("Data", tabName = "data", icon = icon("table"))
    ),
    hr(),
    selectInput(
      "species",
      "Species",
      choices = levels(iris_data$Species),
      selected = levels(iris_data$Species),
      multiple = TRUE
    ),
    selectInput(
      "x_variable",
      "Scatter plot X-axis",
      choices = numeric_columns,
      selected = "Sepal.Length"
    ),
    selectInput(
      "y_variable",
      "Scatter plot Y-axis",
      choices = numeric_columns,
      selected = "Petal.Length"
    ),
    selectInput(
      "distribution_variable",
      "Distribution variable",
      choices = numeric_columns,
      selected = "Sepal.Width"
    ),
    sliderInput(
      "bins",
      "Histogram bins",
      min = 5,
      max = 30,
      value = 15,
      step = 1
    )
  ),
  dashboardBody(
    tags$head(
      tags$style(HTML("\n+        .content-wrapper { background-color: #f4f6f9; }\n+        .small-box { border-radius: 8px; }\n+        .box { border-radius: 8px; }\n+      "))
    ),
    tabItems(
      tabItem(
        tabName = "dashboard",
        fluidRow(
          valueBoxOutput("row_count", width = 4),
          valueBoxOutput("species_count", width = 4),
          valueBoxOutput("avg_value", width = 4)
        ),
        fluidRow(
          box(
            title = "1. Relationship Between Measurements",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            plotlyOutput("scatter_plot", height = "430px")
          )
        ),
        fluidRow(
          box(
            title = "2. Measurement by Species",
            width = 6,
            status = "success",
            solidHeader = TRUE,
            plotlyOutput("box_plot", height = "380px")
          ),
          box(
            title = "3. Measurement Distribution",
            width = 6,
            status = "warning",
            solidHeader = TRUE,
            plotlyOutput("histogram", height = "380px")
          )
        )
      ),
      tabItem(
        tabName = "data",
        fluidRow(
          box(
            title = "Filtered Iris Data",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            DTOutput("iris_table")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  filtered_data <- reactive({
    req(input$species)
    iris_data[iris_data$Species %in% input$species, , drop = FALSE]
  })

  output$row_count <- renderValueBox({
    valueBox(
      value = nrow(filtered_data()),
      subtitle = "Flowers displayed",
      icon = icon("seedling"),
      color = "aqua"
    )
  })

  output$species_count <- renderValueBox({
    valueBox(
      value = length(unique(filtered_data()$Species)),
      subtitle = "Species selected",
      icon = icon("leaf"),
      color = "green"
    )
  })

  output$avg_value <- renderValueBox({
    average <- mean(filtered_data()[[input$distribution_variable]])
    valueBox(
      value = round(average, 2),
      subtitle = paste("Average", input$distribution_variable),
      icon = icon("calculator"),
      color = "yellow"
    )
  })

  output$scatter_plot <- renderPlotly({
    plot_data <- filtered_data()

    chart <- ggplot(
      plot_data,
      aes(
        x = .data[[input$x_variable]],
        y = .data[[input$y_variable]],
        color = Species,
        text = paste(
          "Species:", Species,
          "<br>", input$x_variable, ":", .data[[input$x_variable]],
          "<br>", input$y_variable, ":", .data[[input$y_variable]]
        )
      )
    ) +
      geom_point(size = 3, alpha = 0.8) +
      geom_smooth(method = "lm", se = FALSE, linewidth = 0.8) +
      scale_color_manual(values = species_colors) +
      labs(x = input$x_variable, y = input$y_variable, color = "Species") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "bottom")

    ggplotly(chart, tooltip = "text")
  })

  output$box_plot <- renderPlotly({
    chart <- ggplot(
      filtered_data(),
      aes(
        x = Species,
        y = .data[[input$distribution_variable]],
        fill = Species
      )
    ) +
      geom_boxplot(alpha = 0.85, outlier.alpha = 0.7) +
      scale_fill_manual(values = species_colors) +
      labs(x = NULL, y = input$distribution_variable) +
      theme_minimal(base_size = 12) +
      theme(legend.position = "none")

    ggplotly(chart)
  })

  output$histogram <- renderPlotly({
    chart <- ggplot(
      filtered_data(),
      aes(
        x = .data[[input$distribution_variable]],
        fill = Species
      )
    ) +
      geom_histogram(
        bins = input$bins,
        position = "identity",
        alpha = 0.6,
        color = "white"
      ) +
      scale_fill_manual(values = species_colors) +
      labs(x = input$distribution_variable, y = "Number of flowers", fill = "Species") +
      theme_minimal(base_size = 12) +
      theme(legend.position = "bottom")

    ggplotly(chart)
  })

  output$iris_table <- renderDT({
    datatable(
      filtered_data(),
      rownames = FALSE,
      filter = "top",
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })
}

shinyApp(ui = ui, server = server)

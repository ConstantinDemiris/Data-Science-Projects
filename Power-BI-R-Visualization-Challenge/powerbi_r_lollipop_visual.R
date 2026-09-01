# Power BI creates a data frame named "dataset" from fields
# added to the R visual's Values section.

library(ggplot2)

required_columns <- c("ocean_proximity", "Home Count")

missing_columns <- setdiff(required_columns, names(dataset))

if (length(missing_columns) > 0) {
  stop(
    paste(
      "Add these fields to the R visual before running this script:",
      paste(missing_columns, collapse = ", ")
    )
  )
}

ocean_order <- c(
  "NEAR BAY",
  "<1H OCEAN",
  "INLAND",
  "NEAR OCEAN",
  "ISLAND"
)

ocean_colors <- c(
  "NEAR BAY" = "#277DA1",
  "<1H OCEAN" = "#43AA8B",
  "INLAND" = "#F9C74F",
  "NEAR OCEAN" = "#F9844A",
  "ISLAND" = "#9B5DE5"
)

clean_data <- dataset[
  !is.na(dataset$ocean_proximity) &
    !is.na(dataset[["Home Count"]]) &
    dataset$ocean_proximity %in% ocean_order,
  ,
  drop = FALSE
]

home_counts <- aggregate(
  clean_data[["Home Count"]],
  by = list(ocean_proximity = clean_data$ocean_proximity),
  FUN = sum,
  na.rm = TRUE
)

names(home_counts)[2] <- "home_count"
home_counts <- home_counts[home_counts$home_count > 0, , drop = FALSE]

home_counts$ocean_proximity <- factor(
  home_counts$ocean_proximity,
  levels = rev(ocean_order)
)

home_counts$label <- format(
  home_counts$home_count,
  big.mark = ",",
  scientific = FALSE,
  trim = TRUE
)

ggplot(
  home_counts,
  aes(
    x = home_count,
    y = ocean_proximity,
    color = ocean_proximity
  )
) +
  geom_segment(
    aes(
      x = 0,
      xend = home_count,
      y = ocean_proximity,
      yend = ocean_proximity
    ),
    linewidth = 2,
    alpha = 0.45
  ) +
  geom_point(size = 8) +
  geom_text(
    aes(label = label),
    hjust = -0.35,
    color = "#333333",
    size = 4.5,
    fontface = "bold"
  ) +
  scale_color_manual(values = ocean_colors, drop = FALSE) +
  scale_x_continuous(
    labels = scales::comma,
    expand = expansion(mult = c(0, 0.18))
  ) +
  labs(
    title = "Homes by Ocean Proximity",
    subtitle = "Changed from a bar chart to a lollipop chart using R",
    x = "Number of housing records",
    y = NULL
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "none",
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(
      face = "bold",
      size = 17,
      color = "#1F2937"
    ),
    plot.subtitle = element_text(
      size = 11,
      color = "#6B7280"
    ),
    axis.text.y = element_text(
      face = "bold",
      color = "#374151"
    ),
    plot.margin = margin(15, 25, 15, 15)
  )

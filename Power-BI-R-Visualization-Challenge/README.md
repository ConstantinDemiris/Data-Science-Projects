# Power BI R Visualization Challenge

For this challenge, the original **Homes by Ocean Proximity** bar chart was redesigned as a horizontal lollipop chart using R in Power BI Desktop.

The visual displays the number of housing records in:

- NEAR BAY
- <1H OCEAN
- INLAND
- NEAR OCEAN
- ISLAND

Because the script uses the Power BI data frame named dataset, the result updates when Power BI filters or slicers change the data supplied to the R visual.

## Files

- powerbi_r_lollipop_visual.R - the R script used in the Power BI visual
- housing.csv - available in the California-Housing-Shiny-Dashboard folder of this repository

## Instructions for Power BI Desktop

1. Open Power BI Desktop.
2. Select **Get Data > Text/CSV**.
3. Import housing.csv from the California-Housing-Shiny-Dashboard project folder.
4. Create this DAX measure:

       Home Count = COUNTROWS(housing)

   If your imported table has a different name, replace housing with that table name.
5. Add an **R script visual** to the report canvas.
6. Drag ocean_proximity and the Home Count measure into the visual's **Values** section.
7. Make sure ocean_proximity is set to **Don't summarize**.
8. Open powerbi_r_lollipop_visual.R and copy the complete script.
9. Paste the script into the R script editor in Power BI.
10. Select **Run script**.

## Required R packages

Install these packages in R or RStudio before running the Power BI visual:

    install.packages(c("ggplot2", "scales"))

## What changed

The original chart used solid columns. The updated lollipop chart uses a line and a large endpoint marker for each category, making the category comparison more visually distinct while keeping the exact count labels.

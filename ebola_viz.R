
# Loading packages -----------------------------------------------------------------------------------------

pacman::p_load(
  rio,          # File import
  here,         # File locator
  gtsummary,    # summary statistics and tests
  rstatix,      # summary statistics and statistical tests
  janitor,      # adding totals and percents to tables
  tidyverse     # data management + ggplot2 graphics 
)

# Import data ----------------------------------------------------------------------------------------------

ebola <- import("ebola_cases.xlsx") %>% 
  # Remove space in variable names
  clean_names() 


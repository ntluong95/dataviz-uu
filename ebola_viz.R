
# Loading packages -----------------------------------------------------------------------------------------

pacman::p_load(
  rio,          # File import
  here,         # File locator
  gtsummary,    # summary statistics and tests
  rstatix,      # summary statistics and statistical tests
  janitor,      # adding totals and percents to tables
  gghighlight,  # highlight data in ggplot
  tidyverse     # data management + ggplot2 graphics 
)

# Import data ----------------------------------------------------------------------------------------------

ebola <- import("ebola_cleaned.xlsx") %>% 
  # convert date_onset to date format)
  mutate(date_onset = ymd(date_onset)) %>% 
  # drop NA value in age_cat variable
  drop_na(age_cat)


# Epicurve visualization -----------------------------------------------------------------------------------

# Define sequence of weekly breaks
weekly_breaks_central <- seq.Date(
  from = floor_date(min(ebola$date_onset, na.rm=T), "week", week_start = 1), # Monday before first case
  to   = ceiling_date(max(ebola$date_onset, na.rm=T), "week", week_start = 1), # Monday after last case
  by   = "week")    # bins are 7-days 

my_labels <- as_labeller(c(
  "0-4"   = "Ages 0-4",
  "5-9"   = "Ages 5-9",
  "10-14" = "Ages 10-14",
  "15-19" = "Ages 15-19",
  "20-29" = "Ages 20-29",
  "30-49" = "Ages 30-49",
  "50-69" = "Ages 50-69",
  "70+"   = "Over age 70"))

ggplot(ebola) + 
  # epicurves by group
  geom_histogram(aes(x = date_onset,
                     group = age_cat,
                     fill = age_cat), 
                 # color for the border of bars
                 color = "black",   
                 # histogram breaks
                 breaks = weekly_breaks_central, 
                 # count cases from start of breakpoint
                 closed = "left")+                
  
  #--------------------------------------
  # create sub-plots by age category
  facet_wrap(~age_cat,                          # each plot is one value of age_cat
             ncol = 4,                          # number of columns
             labeller = my_labels)+             # labeller defines above
  gghighlight()+
  
  # edit labels on x-axis
  scale_x_date(expand = c(0,0),                     # remove excess x-axis space below and after case bars
               date_breaks = "2 months",            # labels appear every 2 months
               date_minor_breaks = "1 month",       # vertical lines appear every 1 month 
               label = scales::label_date_short())+ # label formatting
  
  # y-axis
  scale_y_continuous(expand = c(0,0))+  # removes excess y-axis space below 0
  
  #--------------------------------------
  # aesthetic themes
  theme_minimal()+                                           # a set of themes to simplify plot
  theme(
    plot.caption = element_text(face = "italic", hjust = 0), # caption on left side in italics
    axis.title = element_text(face = "bold"),
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 14),
    strip.text = element_text(face = "bold", size = 10),
    strip.background = element_rect(fill = "white"))+        # axis titles in bold
  
  
  
  # labels
  labs(
    title    = "Weekly incidence of cases, by age category",
    fill     = "Age category",                                      # provide new title for legend
    x        = "Week of symptom onset",
    y        = "Weekly incident cases reported",
    caption  = stringr::str_glue("n = {nrow(ebola)} from a finctional Ebola dataset; Case onsets range from {format(min(ebola$date_onset, na.rm=T), format = '%a %d %b %Y')} to {format(max(ebola$date_onset, na.rm=T), format = '%a %d %b %Y')}\n{nrow(ebola %>% filter(is.na(date_onset)))} cases missing date of onset and not shown"))

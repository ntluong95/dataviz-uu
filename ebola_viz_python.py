#%% Load packages
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.dates import DateFormatter, MonthLocator
#%% Import data and clean data

# Loading the data
ebola = pd.read_excel('ebola_cleaned.xlsx')
# Convert the date_onset to a datetime
ebola['date_onset'] = pd.to_datetime(ebola['date_onset'])
ebola['week_of_year'] = ebola['date_onset'].dt.to_period('W')
ebola['date_onset'] = ebola['date_onset'].dt.to_period('W')
# Remove NaN records
ebola = ebola[~(ebola['hospital'] == 'Missing')]

#%% Plotting
# Setting style and colors for the plot
sns.set(style='whitegrid')
hospital_categories = sorted(ebola['hospital'].unique())
n_hospitals = len(hospital_categories)
palette = sns.color_palette('husl', n_hospitals)

cols = 3
rows = 2
dpi = 80

fig, axs = plt.subplots(rows, cols, figsize=(1000/dpi, 800/dpi))
axs = axs.ravel()

for index in range(n_hospitals):
    hospital_category = hospital_categories[index]
    subset = ebola[ebola['hospital'] == hospital_category]
    weekly_counts = subset.groupby('week_of_year').size()
    axs[index].plot(weekly_counts.index.start_time, weekly_counts.values, label = hospital_category, color = palette[index])
    # Legend
    axs[index].legend(title = 'Age category')
    # Format x-axis dates
    date_format = DateFormatter("%b '%y")
    axs[index].xaxis.set_major_locator(MonthLocator(interval = 2))
    axs[index].xaxis.set_major_formatter(date_format)
    axs[index].legend(title = '', loc = 'upper right', bbox_to_anchor = (1, 1))
    # Rotate the labels
    plt.setp(axs[index].xaxis.get_majorticklabels(), rotation = 45)

# Hide the unused subplot
if n_hospitals < rows*cols:
    for ax in axs[n_hospitals:]:
        ax.axis('off')

fig.text(0.5, 0.04, 'Week of symptom onset', ha='center', fontsize=12, fontweight='bold')
fig.text(0.04, 0.5, 'Weekly incident cases reported', va='center', fontweight='bold', rotation='vertical', fontsize=12)
fig.suptitle('Weekly incidence of cases for each hospital', fontsize=14, fontweight='bold')

# Adjust layout for better appearance
plt.tight_layout(rect=[0.04, 0.04, 1, 0.96])
plt.show()

fig.savefig('scientific_report_py.png', dpi=dpi)

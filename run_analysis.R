#PR Worts Course Project#

#Clear existing data and graphics #############################################
rm(list=ls())
graphics.off()
options(max.print=10000)        ## Increase max.print for data exploration
options(dplyr.print_max = 1e9)   # Print more rows in dplyr
options(scipen = 999) #Disable scientific notation
#setDTthreads(0)  # This will use the maximum number of available threads

library(RMySQL)
library(XML)
library(jsonlite)
library(readxl)
library(BiocManager)
library(rhdf5)
library(httr)
library(config)
library(sqldf)
library(stringr)
library(gdata)
library(stringr)
library(tidyverse)
library(data.table)
library(janitor)

#Download the File
url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dest_file = "gacdcp_download.zip"
download.file(url, dest_file, method = "curl")

#Review Zipped File contents
zip_contents = unzip("gacdcp_download.zip", list = TRUE)
print(zip_contents$Name)

# Folder name
folder_name = "UCI_HAR_Dataset"

# Check if the folder exists, if not, create it
if (!dir.exists(folder_name)) {
        dir.create(folder_name)
}

# Unzip the file to the specified folder
unzip(dest_file, exdir = folder_name)

# Folder name and path
folder_name = "UCI_HAR_Dataset"
folder_path = file.path("data", folder_name)

# Check if the folder exists within the "data" directory, if not, create it
if (!dir.exists(folder_path)) {
        dir.create(folder_path, recursive = TRUE)  # recursive=TRUE will create 'data' if it doesn't exist
}

#Merge Feature Data
X_train = read.table("UCI_HAR_Dataset/train/X_train.txt")
X_test = read.table("UCI_HAR_Dataset/test/X_test.txt")
X_data = rbind(X_train, X_test)

#Merge Activity Labels
y_train = read.table("UCI_HAR_Dataset/train/y_train.txt")
y_test = read.table("UCI_HAR_Dataset/test/y_test.txt")
y_data = rbind(y_train, y_test)

#Merge Subject Data
subject_train = read.table("UCI_HAR_Dataset/train/subject_train.txt")
subject_test = read.table("UCI_HAR_Dataset/test/subject_test.txt")
subject_data = rbind(subject_train, subject_test)

#Assign Column names
features = read.table("UCI_HAR_Dataset/features.txt")
features
colnames(X_data) = features$V2
colnames(y_data) = "activity"
colnames(subject_data) = "subject"

#Combine Feature, Activity, and Subject Data
combined_data = cbind(subject_data, y_data, X_data)

#Replace Activity numbers with names and convert to factor
combined_data$activity = as.numeric(combined_data$activity)
combined_data = base::merge(combined_data, activity_labels, by.x = "activity", by.y = "code", all.x = TRUE)
# Create a named vector from activity_labels
activity_names = setNames(activity_labels$activity_name, activity_labels$code)

# Map the activity codes to their names
combined_data$activity = activity_names[as.character(combined_data$activity)]

# Convert the new 'activity' column to a factor
combined_data$activity = as.factor(combined_data$activity)

#Explore Data
View(combined_data)
combined_data = clean_names(combined_data)
colnames(combined_data)

#Confirm activity status
unique(combined_data$activity)

#Calculate Mean & SD of entire column for each measurement
mean_values = apply(combined_data[, 3:563], 2, mean, na.rm = TRUE)
sd_values = apply(combined_data[, 3:563], 2, sd, na.rm = TRUE)

#Create data frame with the mean and sd for each measurement
avg_sd_df = data.frame(
        Feature = colnames(combined_data[, 3:563]),
        Mean = mean_values,
        Standard_Deviation = sd_values,
        row.names = 3:563
)

View(avg_sd_df)

#Prepare to export assignment for upload
write.table(avg_sd_df, file = "avg_sd_df", sep = "\t", row.names = FALSE)



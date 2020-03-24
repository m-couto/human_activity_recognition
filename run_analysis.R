# Getting and Cleaning Data Course Project

setwd("~/UCI HAR Dataset")



# Step 1: Reading and merging the data

library(data.table)
# I am using data.table for faster reading

train <- fread('./train/X_train.txt')
test <- fread('./test/X_test.txt')

# convert from data.table to data.frame
train <- as.data.frame(train)
test <- as.data.frame(test)

# merging both data frames:
# they both have 561 columns, measuring the same variables
# so we merge them by "writing one on top of the other"
DT <- rbind(train, test)


# the column on subject nr
trainsub <- read.table('./train/subject_train.txt')
testsub <- read.table('./test/subject_test.txt')
allsub <- rbind(trainsub,testsub)

names(allsub) <- 'subjects'

# the column on activity nr
trainactiv <- read.table('./train/y_train.txt')
testactiv <- read.table('./test/y_test.txt')
allactiv <- rbind(trainactiv,testactiv)

names(allactiv) <- 'activities'

# we add both these column to the data set
DT <- data.frame(allsub, allactiv, DT)



# Step 2: Extracting measurements on means and standard deviations only

# We focus solely on the variables regarding means and standard deviations,
# which will leave out many of the variables in DT.


# The variable names are listed in the following file, more specifically
# in the second column of the table there.

features <- read.table('features.txt')
features <- as.character(features[,2])

# We look for the variable names with the words "mean" or "std" (for
# standard deviation).

index <- grep('mean|std', features)
    # finds all variable names mentioning mean or std

# From our previous data set we subset the columns with those variable
# names, as well as the first two columns (on subject and activities).

DT <- DT[,c(1,2,index+2)]




# Step 4: Labelling the columns

# Having already labelled the first two columns (subjects and activities,
# respectively), we now label all other variables. These are precisely
# the entries of features with indeces in index.

names(DT)[3:ncol(DT)] <- features[index]




# Step 3: Decoding the activities

# We now replace the activity numbers by the activity names.
# The dictionary for this is contained in the following file.

dic <- read.table('activity_labels.txt')

# This file contains a 6x2 table, the first column being the activity
# numbers (1-6) and the second the activity names. We use this
# "dictionary" to replace the entries in the activity column of DT.

DT[,2] <- sapply( DT$activities, function(x) dic[x,2] )




# Step 5: Create a tidy data set with the average of each variable
# for each activity and each subject

# For a faster and easy to understand procedure, we use the dplyr package.

library(dplyr)

# We take the data set, group it by subjects, and then group that by activities,
# and lastly we take the mean of each group.

newdf <- DT %>% group_by(subjects, activities) %>% summarize_all(mean)

# The result is a table with 30x6 rows: the first 6 rows regarding the averages
# of all variables under the 6 different activities for subject 1, rows 7-12
# can be described similarly for subject 2, and so on.

# We write it into a file

write.table(newdf, './tidy_data.txt', row.names = FALSE, quote=FALSE)

# and we output this table

newdf
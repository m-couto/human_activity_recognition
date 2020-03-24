# Study design

This project consisted on cleaning data that had previously been collected from the accelerometers of the Samsung Galaxy S smartphone during an experiment on human activity recognition using smartphones data set.

This data can be accessed using the following link:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

Said experiment was carried out with 30 subjects (each identified by a subject number between 1 and 30), each of which performed six activities (laying, sitting, standing, walking, walking upstairs, walking downstairs) wearing a smartphone (Samsung Galaxy S II) on the waist. A full description of this experiment can be found at the following website:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

#  Code book

describes each variable and its units

This data contains the following variables:

1. subjects - a number between 1 and 30 that identifies each of the 30 subjects of the experiment;

2. activities - a number between 1 and 6 identifying each of the 6 activities the subjects performed. The correspondence can be found in activity_labels.txt.

3. Several other features: the raw data contains many variables which are statistical measurements of signals. A comprehensive list can be found in document features_info.txt. During my analysis I focused on the variables containing the words "mean" and "std" (aka standard deviation), totalling a number of 79 features.

Unfortunately I could not find information in the raw data, regarding the units of such features.

More info on these variables can be found in 'features_info.txt'.

# Data analysis summary

In this section I give a brief description of the analysis I have done on the raw data, together with the R code contained in file 'run\_analysis.R'. My analysis of the tidy data consisted on the following steps:

**Step 1.** Merge the training and the test sets to create one data set.

Once the experiment mentioned above was performed, the subjects were randomly divided into a training group (containing 21 subjects) and a test group (containing the remaining 9 subjects). The raw data is presented separately for these groups, in folders 'test' and 'train'.

	library(data.table)
	train <- fread('./train/X_train.txt')
	test <- fread('./test/X_test.txt')
	train <- as.data.frame(train)
	test <- as.data.frame(test)
	DT <- rbind(train, test)

I merged the training and test tables ('X\_test.txt' and 'X\_train.txt') containing the measurements of the features from point 3 of the code book. Moreover, I added two other columns to this merged data, one representing the subject the other the activity to which each observation belonged ('subject\_train.txt', 'y\_train.txt', 'subject\_test.txt', 'y\_test.txt').

	trainsub <- read.table('./train/subject_train.txt')
	testsub <- read.table('./test/subject_test.txt')
	allsub <- rbind(trainsub,testsub)
	names(allsub) <- 'subjects'

	trainactiv <- read.table('./train/y_train.txt')
	testactiv <- read.table('./test/y_test.txt')
	allactiv <- rbind(trainactiv,testactiv)
	names(allactiv) <- 'activities'

	DT <- data.frame(allsub, allactiv, DT)

This table (named DT in 'run\_analysis.R') contains all the data from the experiment.

**Step 2.** Extract only the measurements on the mean and standard deviation for each measurement.

I focussed only on the features of the previous data set whose names contained the expressions "mean" and "std" (that is, standard deviation); check 'features.txt' for feature names. These correspond to means and standard deviations of many measurements obtained during the experiments, and in some cases mean frequencies as well.

	features <- read.table('features.txt')
	features <- as.character(features[,2])
	
	index <- grep('mean|std', features)
	DT <- DT[,c(1,2,index+2)]

**Step 3.** Use descriptive activity names to name the activities in the data set

Next, rather than representing each activity by a number (1-6), we represent it by the activity name (walking, walking\_upstairs, walking\_downstairs, sitting, standing, laying, respectively); check 'activity\_labels.txt'. 

	dic <- read.table('activity_labels.txt')
	DT[,2] <- sapply( DT$activities, function(x) dic[x,2] )

	
**Step 4.** Appropriately label the data set with descriptive variable names.

Having already names the columns for the subject and the activities in step 1, I then named all other columns which correspond to the experiment features.

	names(DT)[3:ncol(DT)] <- features[index]


**Step 5.** From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

After cleaning the data set and focussing on the variables we wanted, I created a new data set that contained the average of each experiment feature for each subject and for each activity. Therefore, this new table contains 30 subjects x 6 activities = 180 rows and the same number of columns with the same labels as before.

	library(dplyr)
	
	newdf <- DT %>% group_by(subjects, activities) %>% summarize_all(mean)
	
	write.table(newdf, './tidy_data.txt', row.names = FALSE, quote=FALSE)
	newdf

Finally, I saved this new data set into a new file called 'tidy_data.txt'.
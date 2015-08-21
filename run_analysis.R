# This is an R script for the final project in the Coursera "Getting and Cleaning Data" course
# Author: Patrick Barta, patrickbarta (at) patrickbarta.com
# Aug 18, 2015
#
# I prefer a pipelined and cached workflow. Basically, this script caches intermediate
# results in a cache directgory.
# 
# To be sure, this reading/writing is not so efficient, but it makes it faster to develop
# because the intermediate results are cached, and it makes it easier to check the
# correctness of each step in the pipeline.
#
# The requirements are that it: 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the average
# of each variable for each activity and each subject.

#
# Begin utility functions
#

#
# create directories if not present
#
createDirectoriesIfNeeded <- function(dirnames) {
    for (dirname in dirnames) {		  
        dir <- file.path(".",dirname)
        if (!file.exists(dir)) {
           dir.create(dir)
	}
    }
}

#
# delete cached data, if present
#
deleteCachedData <- function() {
    for (dir in c("raw", "cache", "tidy")) {
        if (file.exists(dir)) {
            unlink(dir,recursive=TRUE)
        }
    }

}

                                      #
# get cached data if available, return TRUE if it is, FALSE otherwise
#
getCachedData <- function(cachedDataFilename) {
    fullPath <- file.path(".","cache",cachedDataFilename)
    if (file.exists(fullPath)) {
        load(fullPath)
        return(TRUE)
    } else {
        return(FALSE)
    }
}

#
# get tidy data if available, return TRUE if it is, FALSE otherwise
#
getTidyData <- function(tidyDataFilename) {
    fullPath <- file.path(".","tidy",tidyDataFilename)
    if (file.exists(fullPath)) {
        load(fullPath)
        return(TRUE)
    } else {
        return(FALSE)
    }
}

#
# load packages, installing if necessary
#
require.packages <- function (packages) {
    for (package in packages) {
        if (!require(package, character.only = TRUE)) {
            install.packages(package)
	    require(package)
	}
    }
}

#
# End utility functions
#

#
# Begin main script
#

# Set this to TRUE if you want to run program using cached files (good for development)
# Set this to FALSE if you want to run program without using old cached files (production)
#cache <- TRUE
cache <- FALSE

# If not using cached files, clean up old cached data before beginning
if (!cache) {
    deleteCachedData()
}

#
# Check to make sure that we have setwd() to the directory with this script in it.
#
if (!file.exists("run_analysis.R")) { # R is not executing in the proper directory.
   stop("You should setwd() in R to the directory where this script is before running it.")
}

#
# load libraries
#
require.packages(c("dplyr","reshape2"))


#
# create directories if not present
#
createDirectoriesIfNeeded(c("raw","cache","tidy"))

#
# Requirement 1
#

# Constants used for requirement 1
# where the raw data comes from
rawDataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# various directories used in processing
cacheDirectory <- file.path(".","cache")
rawDataDirectory <- file.path(".","raw")
tidyDataDirectory <- file.path(".","tidy")

# name of downloaded zip file
rawDataZipFile <- file.path(".","raw", "raw.zip")

# name of unzip directory
rawDataUnzipDirectory <- file.path(".","raw", "UCI HAR Dataset")

# file holding download time
rawDataDownloadTime <- file.path(".", "raw", "RawZipDownloadTime.txt")

# labels for both the test and training sets
activityLabelsFileName <- file.path(rawDataUnzipDirectory,"activity_labels.txt")
featureLabelsFileName <- file.path(rawDataUnzipDirectory,"features.txt")

# raw data, test set
testSubjectTestFileName <- file.path(rawDataUnzipDirectory,"test","subject_test.txt")
testXTestFileName <- file.path(rawDataUnzipDirectory,"test","X_test.txt")
testyTestFileName <- file.path(rawDataUnzipDirectory,"test","y_test.txt")

# raw data, training set
trainSubjectTestFileName <- file.path(rawDataUnzipDirectory,"train","subject_train.txt")
trainXTestFileName <- file.path(rawDataUnzipDirectory,"train","X_train.txt")
trainyTrainFileName <- file.path(rawDataUnzipDirectory,"train","y_train.txt")

# output of first requirement goes here
rawDataFrameFileName <- file.path(cacheDirectory, "rawDataFrame.Rda")

# Requirement 1
# Check to see if cached raw data exists. If so, we're done, otherwise compute it
if (!getCachedData("rawDataFrame.Rda")) {
    # Save time we downloaded zip file
    cat(date(), file=rawDataDownloadTime)
    
    # Download raw data zipfile
    download.file(rawDataURL, rawDataZipFile, method="curl", quiet=TRUE)

    # Unzip it
    unzip(rawDataZipFile, exdir=rawDataDirectory)

    # Stack features
    rawFeaturesDataFrame <- rbind(read.table(testXTestFileName),read.table(trainXTestFileName))

    # Name the features according to features.txt
    features <- read.table(featureLabelsFileName, as.is = TRUE) # don't need factor conversion.
    names(rawFeaturesDataFrame) <- features$V2  # second column has feature names, first column just an index

    # Stack subjects as factors
    subject <- rbind(read.table(testSubjectTestFileName), read.table(trainSubjectTestFileName))
    names(subject) <- "Subject"
    subject$Subject <- as.factor(subject$Subject)
        
    # Stack activities
    testyTest <- read.table(testyTestFileName)
    trainyTrain <- read.table(trainyTrainFileName)
    activity <- rbind(testyTest, trainyTrain)
    names(activity) <- "Activity"
    activity$Activity <- as.factor(activity$Activity)
 
    # Save whether training or test set
    set <- data.frame(Set=c(rep("Test", dim(testyTest)[1]), rep("Train", dim(trainyTrain)[1])))
    names(set) <- "Set"
    set$Set <- as.factor(set$Set)

    # cbind it
    rawDataFrame <- cbind(subject, activity, set, rawFeaturesDataFrame)

    # cache the work so far
     save(rawDataFrame, file=rawDataFrameFileName)
}

# output of second requirement goes here
meansAndSTDsFileName <- file.path(cacheDirectory, "meansAndSTDs.Rda")

# Requirement 2
# Check to see if cached raw data exists. If so, we're done, otherwise compute it
if (!getCachedData("meansAndSTDs.Rda")) {
   # extract those columns that have "Subject", "Activity", "Set" or "-mean()" or "-std()" as part of their names.
   meansAndSTDs <- rawDataFrame[ ,grepl("(-mean\\(\\))|(-std\\(\\))|Subject|Activity|Set", names(rawDataFrame))]

   # cache the work so far
   save(meansAndSTDs, file=meansAndSTDsFileName)
}

# where the activity labels come from
activityLabelsFileName <- file.path(rawDataUnzipDirectory,"activity_labels.txt")

# output of third requirement goes here
activitiesFileName <- file.path(cacheDirectory, "activities.Rda")

# Requirement 3
# Check to see if cached raw data exists. If so, we're done, otherwise compute it
if (!getCachedData("activities.Rda")) {
   activityLabels <- read.table(activityLabelsFileName, as.is=TRUE)
   activities <- meansAndSTDs
   levels(activities$Activity) <- activityLabels$V2  # second variable is name, first is index  

   # cache the work so far
   save(activities, file=activitiesFileName)
}

# output of fourth requirement goes here
tidyDatasetOneFileName <- file.path(tidyDataDirectory, "tidyDatasetOne.Rda")

# Requirement 4
# Check to see if cached raw data exists. If so, we're done, otherwise compute it
if (!getTidyData("tidyDatasetOne.Rda")) {
   # Start by getting the variable names, lower case them, and then do some substitutions
   newVariables <- names(activities)

   # Change ^f to frequency, ^t to time
   newVariables <- sub("^t", "Time", newVariables)
   newVariables <- sub("^f", "Frequency", newVariables)

   # Change Acc to Acceleration, Mag to Magnitude
   newVariables <- sub("Acc", "Acceleration", newVariables)
   newVariables <- sub("Mag", "Magnitude", newVariables)

   # This regular expression is a program in itself.
   # Basically, extract the substring "-mean()", delete it, and prepend "mean" to the feature name
   newVariables <- sub("([a-zA-Z0-9]*)-mean\\(\\)(-*[a-zA-Z0-9]*)", "mean\\1\\2", newVariables)
   # Basically, extract the substring "-std()", delete it, and prepend "StandardDeviation. to the feature name
   newVariables <- sub("([a-zA-Z0-9]*)-std\\(\\)(-*[a-zA-Z0-9]*)", "standardDeviation\\1\\2", newVariables)

   # Remove -'s
   newVariables <- sub("-", "", newVariables)

   # relabel
   labeledActivities<- activities
   names(labeledActivities) <- newVariables

   # melt (first three columns are Subject, Activity, Set)
   tidyDatasetOne <- melt(labeledActivities, id.vars=1:3)
   
   # cache the work so far
   save(tidyDatasetOne, file=tidyDatasetOneFileName)
}

# output of fifth requirement goes here
tidyDatasetTwoFileName <- file.path(tidyDataDirectory, "tidyDatasetTwo.Rda")

# Requirement 5
# Check to see if cached raw data exists. If so, we're done, otherwise compute it
if (!getTidyData("tidyDatasetTwo.Rda")) {
   tidyDatasetTwo <- tidyDatasetOne
   
    # get rid of Set factor
   tidyDatasetTwo$Set <- NULL

   # find mean
#   tidyDatasetTwo <- group_by(tidyDatasetTwo, Subject, Activity,variable) %>% summarize(mean=mean(value)) %>% arrange(Subject, Activity, variable)
   tidyDatasetTwo <- group_by(tidyDatasetTwo, Subject, Activity,variable) %>% summarize(mean=mean(value))
   # cache the work so far
   save(tidyDatasetTwo, file=tidyDatasetTwoFileName)
}

# output for uploading 
uploadFile <- file.path(".", "tidy.txt")

# Write out tidy.txt for upload to Coursera
write.table(tidyDatasetTwo, uploadFile, sep=",", row.names=FALSE, quote=FALSE)


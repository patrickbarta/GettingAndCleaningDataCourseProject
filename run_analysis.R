#
# This is an R script for the final project in the Coursera "Getting and Cleaning Data" course
# Author: Patrick Barta, patrickbarta (at) patrickbarta.com
# Aug 13, 2015
#
# For modularity this script defines several functions (including one called main()) and then just calls
# main() at the end.
# 
# In this script, functions are defined in alphabetical order by name for easy access
# 
# The requirements are that it: 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable
# for each activity and each subject.


###############################################################################################
# createTidyDataFrameOne: massages rawDataFrame into tidyDataFrameOne, 
# This accomplishes requirement 2, 3, and 4
###############################################################################################
createTidyDataFrameOne <- function (rawDataFrame, cacheDirectory, crosswalk) {
    # file path
    tidyDataFrameOneFile <- file.path(cacheDirectory,"tidyDataFrameOne.rda")
    
    # If tidyDataFrameFile exists already, just read it in.
    if (file.exists(tidyDataFrameOneFile)) {
        # Cached file exists. No computation necessary.
        cat("Loading cached tidy data frame one from ", tidyDataFrameOneFile, ".\n")
        load(tidyDataFrameOneFile)
    } else {
        # Cached file doesn't exist. Stack all the raw data into rawDataFrame
        cat("Creating tidy data frame one from raw data frame.\n")

        # Requirement 2 - Extract features' mean and standard deviation
        # Subsetting is done by getting column indexes from crosswalk.
        # The "+ 3" comes becomes because I added 3 columns--Subject, Activity, Set--to the left
        # side of the stacked features raw data frame
        index <- c(1:3, crosswalk$rawDatasetColumnIndex + 3)
        tidyDataFrameOne <- rawDataFrame[ , index]
        
        # Requirement 3 - Add labels for activities
        # This could be done by merging and so forth, but brute force looks easiest to me
        replace <- c("1"="Walking", "2"="WalkingUpstairs", "3"="WalkingDownstairs", "4"="Sitting", "5"="Standing","6"="Laying") 
        tidyDataFrameOne$Activity <- revalue(tidyDataFrameOne$Activity, replace)

        # Requirement 4 - label variables with tidy names
        newName <- c("Subject","Activity","Set",levels(crosswalk$tidyDatasetVariableName))
        names(tidyDataFrameOne) <- newName

        # cache the work
        cat("Caching tidy data frame one in ", tidyDataFrameOneFile, ".\n")
        save(tidyDataFrameOne, file=tidyDataFrameOneFile)
    }
    return(tidyDataFrameOne)
}

###############################################################################################
# createTidyDataFrameTwo: xxx
# This accomplishes requirement 5.
###############################################################################################
createTidyDataFrameTwo <- function (tidyDataFrameOne, cacheDirectory) {
    # file path
    tidyDataFrameTwoFile <- file.path(cacheDirectory,"tidyDataFrameTwo.rda")

    # If tidyDataFrameTwoFile exists already, just read it in.
    if (file.exists(tidyDataFrameTwoFile)) {
        # Cached file exists. No computation necessary.
        cat("Loading cached tidy data frame two from ", tidyDataFrameTwoFile, ".\n")
        load(tidyDataFrameTwoFile)
    } else {
        # Cached file doesn't exist. 
        cat("Creating tidy data frame two from tidy data frame one.\n")

        # Get rid of Set variable
        tidyDataFrameOne$Set <- NULL
        
        # Get average of all numerical columns by subject and activity
        tidyDataFrameTwo <- tidyDataFrameOne %>% group_by(Subject,Activity) %>% summarise_each(funs(mean))

        # I like the long form more than the wide form
        tidyDataFrameTwo <- melt(tidyDataFrameTwo, id.vars=1:2)
        
        # cache the work
        cat("Caching tidy data frame two in ", tidyDataFrameTwoFile, ".\n")
        save(tidyDataFrameTwo, file=tidyDataFrameTwoFile)
    }
    return(tidyDataFrameTwo)
}

###############################################################################################
# deleteCachedData: Delete all cached datafiles
###############################################################################################
deleteCachedData <- function (rawDataFile, rawDataDirectory, cacheDirectory) {
    if (file.exists(rawDataFile)) {
        file.remove(rawDataFile)
    }
    
    if (dir.exists(rawDataDirectory)) {
        unlink(rawDataDirectory,recursive=TRUE)
    }

    if (dir.exists(cacheDirectory)) {
        unlink(cacheDirectory, recursive=TRUE)
    }
}

###############################################################################################
# downloadAndExtractRawDataset: Downloads rawDataFile from rawDataURL and unzips it into rawDataDirectory
###############################################################################################
downloadAndExtractRawDataset <- function (rawDataURL, rawDataFile, rawDataDirectory) {
                                        #
                                        # See if raw data zip file exists.
                                        # If it isn't here, then download it from rawDataURL
                                        #
    if (!file.exists(rawDataFile)) {
        cat("Raw data file ", rawDataFile, " not found. Downloading it ....","\n")
        download.file(rawDataURL, destfile=rawDataFile, method="curl", quiet = TRUE) 
        cat("Download of ", rawDataFile, " complete.","\n")
    } else {
        cat("Using cached raw data file ", rawDataFile, "\n")
    }
    
                                        #
                                        # See if the unzipped directory of files in raw_data.zip exists.
                                        # If not, then unzip raw_data.zip into rawDataDirectory
                                        #
    if (!file.exists(rawDataDirectory)) {
        cat("Unzipping ", rawDataFile," into ", rawDataDirectory, "directory....","\n")
        unzip(rawDataFile, exdir=".") 
        cat("Unzip into ", rawDataDirectory, " complete.","\n")
    } else {
        cat("Using local copy of raw data directory  ", rawDataDirectory, ".\n")
    }        
}

###############################################################################################
# main: main function that does all the work.
# If production=TRUE, then all data processing is done de novo each time the script is run
# If production=FALSE, then intermediate files are cached for inspection, and to speed up processing time.
# In general, production=FALSE should only be used for development. No cached files should be modified outside
# this script.
###############################################################################################
main <- function (production=TRUE) {
    cat("Beginning preparation of tidy data sets.\n")
                                        #
                                        # load libraries
                                        #
    require.package("plyr")
    require.package("dplyr")
    require.package("reshape2")
    require.package("xlsx")
    
                                        #
                                        # file paths
                                        #
    cacheDirectory <- file.path(".","cache")
    crosswalkFile <- file.path(".","crosswalk.xlsx")
    rawDataDirectory <- file.path(".","UCI HAR Dataset")
    rawDataFile <- file.path(".", "getdata-projectfiles-UCI HAR Dataset.zip")
    rawDataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

    if (production == TRUE) {
                                        # Delete any cached data if present
        deleteCachedData(rawDataFile, rawDataDirectory, cacheDirectory)
    }
                                        # read crosswalk file
    crosswalk <- readCrosswalkFile(crosswalkFile)
    
                                        # download and extract raw dataset
    downloadAndExtractRawDataset(rawDataURL, rawDataFile, rawDataDirectory)
    
                                        # createRawDataFrame
    rawDataFrame <- mergeTrainingAndTestSets(rawDataDirectory, cacheDirectory)

                                        # createTidyDataFrameOne
    tidyDataFrameOne <- createTidyDataFrameOne(rawDataFrame, cacheDirectory, crosswalk)
    
                                        # createRawDataFrame
    tidyDataFrameTwo <- createTidyDataFrameTwo(tidyDataFrameOne, cacheDirectory)
    
    return(tidyDataFrameTwo)
}

###############################################################################################
# mergeTrainingAndTestSets: stack all the data in rawDataDirectory into one big data frame and return it.
# This accomplishes requirement 1.
###############################################################################################
mergeTrainingAndTestSets <- function (rawDataDirectory, cacheDirectory) {
    # file paths
    activityLabelsFile <- file.path(rawDataDirectory,"activity_labels.txt")
    rawDataFrameFile <- file.path(cacheDirectory, "rawDataFrame.rda")
    testSubjectTestFile <- file.path(rawDataDirectory,"test","subject_test.txt")
    testXTestFile <- file.path(rawDataDirectory,"test","X_test.txt")
    testyTestFile <- file.path(rawDataDirectory,"test","y_test.txt")
    trainSubjectTestFile <- file.path(rawDataDirectory,"train","subject_train.txt")
    trainXTestFile <- file.path(rawDataDirectory,"train","X_train.txt")
    trainyTrainFile <- file.path(rawDataDirectory,"train","y_train.txt")

    # if cache directory doesn't exist, create it
    if (!dir.exists(cacheDirectory)) {
        dir.create(cacheDirectory)
    }

    # If rawDataFrameFile exists already, just read it in.
    if (file.exists(rawDataFrameFile)) {
        # Cached file exists. No computation necessary.
        cat("Loading cached raw data frame from ", rawDataFrameFile, ".\n")
        load(rawDataFrameFile)
    } else {
        # Cached file doesn't exist. Stack all the raw data into rawDataFrame
        cat("Creating raw data frame by stacking data files from ", rawDataDirectory, ".\n")

        # Stack features
        rawDataFrame <- rbind(read.table(testXTestFile),read.table(trainXTestFile))

        # Stack subjects
        subject <- rbind(read.table(testSubjectTestFile), read.table(trainSubjectTestFile))
        names(subject) <- "Subject"
        subject$Subject <- as.factor(subject$Subject)
        
        # Stack activities
        testyTest <- read.table(testyTestFile)
        trainyTrain <- read.table(trainyTrainFile)
        activity <- rbind(testyTest, trainyTrain)
        names(activity) <- "Activity"
        activity$Activity <- as.factor(activity$Activity)
 
        # Save whether training or test set
        set <- data.frame(Set=c(rep("Test", dim(testyTest)[1]), rep("Train", dim(trainyTrain)[1])))
        names(set) <- "Set"
        set$Set <- as.factor(set$Set)

        # cbind it
        rawDataFrame <- cbind(subject, activity, set, rawDataFrame)

        # cache the work
        cat("Caching raw data frame in ", rawDataFrameFile, ".\n")
        save(rawDataFrame, file=rawDataFrameFile)
    }
    return(rawDataFrame)
}

###############################################################################################
# readCrosswalkFile: checks to make sure that crosswalk file exists, and returns a dataframe
# with the information mapping raw data file columns and names to tidy dataset variable names
###############################################################################################
readCrosswalkFile <- function (crosswalkFile) {
                                        #
                                        # This script requires the existence of the crosswalk.csv file,
                                        # so check to make sure it's there.
    if (!file.exists(crosswalkFile)) {
        stop(cat("This script requires ", crosswalkFile, " to be in the working directory. Please add this file and re-run."))
    } else {
        crosswalk <- read.xlsx(crosswalkFile, sheetIndex=1)
        cat("Crosswalk file ", crosswalkFile, " available.","\n")
        return(crosswalk)
    }
}

###############################################################################################
# require.package: load package, installing if necessary
###############################################################################################
require.package <- function (package) {
    if (!require(package, character.only = TRUE)) {
        install.packages(package)
        require(package)
    }
}

###############################################################################################
# This is where the script actually starts running
###############################################################################################

# courseraSubmission.txt is what gets submitted
submissionFile = file.path(".","courseraSubmission.txt")

###############################################################################################
# Used for debugging
# with the information mapping raw data file columns and names to tidy dataset variables
###############################################################################################
write.table(main(FALSE), file=submissionFile, quote=FALSE, row.names=FALSE)
cat("Finished writing out ", submissionFile, ".\n")
cat("Completed preparation of tidy data sets.\n")

###############################################################################################
# Used for production
# with the information mapping raw data file columns and names to tidy dataset variables
###############################################################################################
#write.table(main(), file=file.path(".","courseraSubmission.txt"), quote=FALSE, row.names=FALSE)
#cat("Finished writing out ", submissionFile, ".\n")
#cat("Completed preparation of tidy data sets.\n")



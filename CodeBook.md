# Codebook
## Experimental design
The tidy data are derived from raw data from the following study:

Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. A Public Domain Dataset for Human Activity Recognition Using Smartphones. 21th European Symposium on Artificial Neural Networks, Computational Intelligence and Machine Learning, ESANN 2013. Bruges, Belgium 24-26 April 2013,

A more complete description of this study can be found in the paper itself.

In brief, the investigators had 30 volunteers perform 6 activities (walking, walking upstairs, walking downstairs,
sitting, standing and laying. Each combination of a particular volunteer and a particular activity were
repeated about 50 times for each combination. Each repetition represented data from 2.56 seconds of the
activity.

During these activities, the volunteers carried a cellphone, which monitored acceleration and angular
velocity. The raw dataset contains all of these data.

For machine learning purposes, the investigators extracted a set of 561 features.
Details about these features can be found in

./raw/UCI HAR Dataset/features_info.txt**

after running the run_analysis script.

## Raw data
The raw data were obtained from the UCI machine learning repository at 
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones.

In particular the dataset 
http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI HAR Dataset.zip
was downloaded on Aug 21, 2015.

## Processing
Details about the processing can be found in the comments in run_analysis.R

The script is fairly straightforward, but I favor a cached approach for development,
so the script basically completes one of the requirements and writes out the intermediate
result to a cache file. This makes development faster. This feature can be switched on or
off depending on whether cache = TRUE or FALSE in lines 96 and 97.

After run_analysis.R executes, the following directory structure is created:

The raw directory contains the raw data.

 * **./raw/UCI HAR Dataset.zip**: zipped version of raw data file
 * **./raw/RawZipDownloadTime.txt**: text file containing time and date that raw zipfile was downloaded
 * **./raw/UCI HAR Dataset/**: directory containing unzipped data from UCI HAR Dataset.zip
 * **./raw/UCI HAR Dataset/activity_labels.txt**: file with text labels for activities
 * **./raw/UCI HAR Dataset/features.txt**: file with feature labels
 * **./raw/UCI HAR Dataset/features_info.txt**: file with more description of features
 * **./raw/UCI HAR Dataset/README.txt**: README file from original data set
 * **./raw/UCI HAR Dataset/test/**: directory with training set data
 * **./raw/UCI HAR Dataset/test/subject_test.txt**: file with subject #'s corresponding to features in X_test.txt
 * **./raw/UCI HAR Dataset/test/X_test.txt**: file with features values for subjects in subject_test.txt
 * **./raw/UCI HAR Dataset/test/y_test.txt**: file with activity values for subjects in subject_test.txt
 * **./raw/UCI HAR Dataset/test/Inertial Signals**: directory with raw data used to compute features in parent directory.
 * **./raw/UCI HAR Dataset/test/Inertial Signals/body_acc_x_test.txt**: computed body motion accelerometer data in x direction
 * **./raw/UCI HAR Dataset/test/Inertial Signals/body_acc_y_test.txt**: computed body motion accelerometer data in y direction
 * **./raw/UCI HAR Dataset/test/Inertial Signals/body_acc_z_test.txt**: computed body motion accelerometer data in z direction
 * **./raw/UCI HAR Dataset/test/Inertial Signals/body_gyro_x_test.txt**: computed body motion gyro data in x direction
 * **./raw/UCI HAR Dataset/test/Inertial Signals/body_gyro_y_test.txt**: computed body motion gyro data in y direction
 * **./raw/UCI HAR Dataset/test/Inertial Signals/body_gyro_z_test.txt**: computed body motion gyro data in z direction
 * **./raw/UCI HAR Dataset/test/Inertial Signals/total_acc_x_test.txt**: total acceleration data in x direction
 * **./raw/UCI HAR Dataset/test/Inertial Signals/total_acc_y_test.txt**: total acceleration data in y direction
 * **./raw/UCI HAR Dataset/test/Inertial Signals/total_acc_z_test.txt**: total acceleration data in z direction
 * **./raw/UCI HAR Dataset/train/**: directory with training set data
 * **./raw/UCI HAR Dataset/train/subject_train.txt**: file with subject #'s corresponding to features in X_train.txt
 * **./raw/UCI HAR Dataset/train/X_train.txt**: file with features values for subjects in subject_train.txt
 * **./raw/UCI HAR Dataset/train/y_train.txt**: file with activity values for subjects in subject_train.txt
 * **./raw/UCI HAR Dataset/train/Inertial Signals**: directory with raw data used to compute features in parent directory.
 * **./raw/UCI HAR Dataset/train/Inertial Signals/body_acc_x_train.txt**: computed body motion accelerometer data in x direction
 * **./raw/UCI HAR Dataset/train/Inertial Signals/body_acc_y_train.txt**: computed body motion accelerometer data in y direction
 * **./raw/UCI HAR Dataset/train/Inertial Signals/body_acc_z_train.txt**: computed body motion accelerometer data in z direction
 * **./raw/UCI HAR Dataset/train/Inertial Signals/body_gyro_x_train.txt**: computed body motion gyro data in x direction
 * **./raw/UCI HAR Dataset/train/Inertial Signals/body_gyro_y_train.txt**: computed body motion gyro data in y direction
 * **./raw/UCI HAR Dataset/train/Inertial Signals/body_gyro_z_train.txt**: computed body motion gyro data in z direction
 * **./raw/UCI HAR Dataset/train/Inertial Signals/total_acc_x_train.txt**: total acceleration data in x direction
 * **./raw/UCI HAR Dataset/train/Inertial Signals/total_acc_y_train.txt**: total acceleration data in y direction
 * **./raw/UCI HAR Dataset/train/Inertial Signals/total_acc_z_train.txt**: total acceleration data in z direction

The cache directory contains cached data.

 * **./cache/**: Directory of cached intermediate calculations used by run_analysis.R
 * **./cache/rawDataFrame.Rda**: output for requirement 1
 * **./cache/meansAndSTDs.Rda**: output for requirement 2
 * **./cache/activities.Rda**: output for requirement 3
 
## Tidy data
The tidy directory contains tidy data.

* **./tidy/**: directory containing tidy data
* **./tidy/tidyDataOne.Rda**: first tidy dataset, output for requirement 4
* **./tidy/tidyDataTwo.Rda**: second tidy dataset, output for requirement 5

The tidy.txt file is for upload to Coursera.

* **./tidy.txt**: output required to upload to github as part of requirements.

### Choices made
The instructions for which features to extract for the tidy data set were somewhat vague, so I arbitrarily
chose to extract only those containing "-mean()" or "-std()" as parts of their names.

I chose to use the author's names for the activities performed by the subject, rather than modifying them.

Some of the names in tidy dataset one were somewhat obscure. I chose to adopt a camelCase naming scheme like this:

(mean | standardDeviation) + (Time/Frequency) + (modified original variable name)

the modified original variable name consisted of the original name with the substring "-mean()" or "-std()"
removed--it was basically moved to the from middle of the string to the front--while "Acc" and "Mag" were
expanded to "Acceleration" and "Magnitude"

I chose to present the tidy dataset two information as a long, rather than wide, table, simple to make it
easier to read on GitHub.

### Units
According to the authors of the paper, all features were normalized to [-1,1] and hence, unitless.



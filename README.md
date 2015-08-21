# Getting And Cleaning Data Course Project
## Author : Patrick Barta patrickbarta (at) patrickbarta.com
## Date: Aug 18, 2015

## Overview
These files are submitted as part of the final project requirements for Coursera's
"Getting and Cleaning Data" course. The goal of the project was to generate 
two tidy data sets from a publicly available raw data set.
The raw data set contains cell-phone accelerometer and angular velocity
measurements from a group of people performing various activities such as walking up stairs.
From these cell-phone data, a set of features were calculated by the original investigators.
The first tidy dataset is a subset of feature information, formatted for easy use in R, with data
from all subjects and all activities but not all calculated features.
The second tidy dataset--the one submitted--is a summary containing the mean of the selected features
by subject and by activity.

## Contents
This git repository contains the following files:

 * **CodeBook.md**: Description of study and data-cleaning process for the project.
 * **README.md**: This file.
 * **run_analysis.R**: R script to tidy the data.
 * **tidy.txt** tidy dataset for Coursera submission

## Requirements
The script requires the dplyr and reshape2 packages. If it is not installed, this script attempts to install them.

You should setwd() to the directory with run_analysis.R in it before sourcing it.

The run_analysis.R script was tested on R version 3.2.2 (2015-08-14) -- "Fire Safety" running under Ubuntu 15.04.

This script creates a number of files in the directory in which the script runs. A more complete
description of the input, output, processing steps and decisions made can be found in **CodeBook.md**.


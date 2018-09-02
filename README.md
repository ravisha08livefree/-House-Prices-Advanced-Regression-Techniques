# House-Prices-Advanced-Regression-Techniques
Predicting the prices of houses in a locality using regression algorithms

## Problem Statement ::
For every house built the final price is decided on the basis of location, carpet area, living room area, Home style, building type etc.
1. Our main challenge is to predict the final price of homes when 72 explanatory variables are given.
2. We also have to keep in mind that not all variables are important while predicting, so importance also have to be calculated.
3. In the end to check the accuracy and performance of our model, calculate RMSE value. Lower the value, better the fit of model.

## Solution ::
Following steps are implemented to find the solution to above statement. However please check my detailed R code to analyse the solution properly.

1. Import the train and test data set. In test data set, Sale price is not available. This is what we have to predict.
2. Analyse the data using summary and str functions
3. Check the percentage of missing data in each data set - test and train.
4. Using exploratory data visualization using GGplot, analyze different relationships between variables in Train_dataset.
5. Remove the outliers which decreases the performance of our model.
6. Create a common flag in Train and test data set to distinguish later. and append these two. 
7. Divide the newly created data into 2 sub groups - where my class of variables is either character or interger/numeric. This will help me analyse and replace the missing values more easily.
8. For interger class type - replace the missing values with median.( Mean is sensitive to outliers and hence gives an incorrect values)
9. For Character Class type - replace missing values with "None"
10. Separate the data set in Test and train.
11. Using train_dataset, divide into two parts randomly to do a validation - RMSE
12. Train model using Random Forest.
13. Predict the sale price for test data.
14. Predict the sale price for Validate data.
15. Find RMSE

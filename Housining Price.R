setwd("C:/Course era/Assignments/KAGGLE Housing Price")
#setwd("C:/QV Apps/RStudio/Housing Price")
library(randomForest)
library(ggplot2)
library(dplyr)

###################################################################################

#Reading csv train and test data sets
price.train <- read.csv(file = "train.csv", stringsAsFactors = FALSE)
price.test <- read.csv(file = "test.csv", stringsAsFactors = FALSE)

####################################################################################

str(price.test)
dim(price.test)
str(price.train)

#SalePrice is missing from test data
price.test$SalePrice <- NA

#Count the number of character type data
sum(sapply(price.train[,1:81], typeof) == "character") #~~43 Columns

#Count the number of Interger type of data
sum(sapply(price.train[,1:81], typeof) == "integer") #~~38 Columns

#Percentage of data missing in train data set
sum(is.na(price.train))/ (nrow(price.train) * ncol(price.test)) # 5.8% data missing

#Checking duplicate data in train
nrow(price.train) - nrow(unique(price.train)) #~~No duplicate records

#Creating flag to distinguish test and train data sets
price.test$isTest <- TRUE
price.train$isTest <- FALSE



########################################################################################
#                            DATA VISUALIZATION                                   #
str(price.data)

chr_var <- names(price.train[which(sapply(price.train, typeof)=="character")])
int_var <- names(price.train[which(sapply(price.train, typeof)=="integer")])

price.train.chr <- price.train[chr_var]
price.train.int <- price.train[int_var]

#Plotting GrlivArea - Ground living area
png("GrLivArea vs SalePrice.png")
ggplot(price.train, aes(y=SalePrice , x= GrLivArea)) + geom_point() + ggtitle("Ground living area vs SalePrice") +theme_light() #Otliners are >3600
dev.off()
price.train <- price.train[price.train$GrLivArea <= 3500,]
sum(sapply(price.train[,"GrLivArea"], sum) > 3500)

png("LowQualFinSF vs SalePrice.png")
ggplot(price.train, aes(y=SalePrice , x= LowQualFinSF)) + geom_point() + theme_light()#Otliners are >0
dev.off()
sum(sapply(price.train[,"LowQualFinSF"], sum) > 0) # 25 observations are deviating
price.train <- price.train[price.train$LowQualFinSF == 0,]

#appending test and train data
price.data <- rbind(price.test, price.train)
tail(price.data,n=10)

#Filetring out missing columns so that we can clean and fill the missing values
price.missing <- price.data[which(colSums(sapply(price.data, is.na))>0)]

#Missing columns separated into 2 different var - chr and num
chr_var.a <- names(price.missing[which(sapply(price.missing, typeof)=="character")])
int_var.a <- names(price.missing[which(sapply(price.missing, typeof)=="integer")])

for( i in 1:length(chr_var.a)){
  price.missing[which(is.na(price.missing[,chr_var.a[i]])),chr_var.a[i]] <- "None"
  price.data[,chr_var.a[i]] <- price.missing[,chr_var.a[i]]  
}

#Now handling integer missing values
for( i in 1:length(int_var.a)){
  price.missing[which(is.na(price.missing[,int_var.a[i]])),int_var.a[i]] <- ceiling(median(price.missing[,int_var.a[i]], na.rm = TRUE))
  price.data[,int_var.a[i]] <- price.missing[,int_var.a[i]]  
}


#Converting into factor
for( i in 1:length(chr_var)){
    price.data[,chr_var[i]] <- as.factor(price.data[,chr_var[i]]) 
    
}

price.data[,"BsmtFullBath"] <- as.factor(price.data[,"BsmtFullBath"])
price.data[,"BsmtHalfBath"] <- as.factor(price.data[,"BsmtHalfBath"])
price.data[,"FullBath"] <- as.factor(price.data[,"FullBath"])
price.data[,"HalfBath"] <- as.factor(price.data[,"HalfBath"])
price.data[,"BedroomAbvGr"] <- as.factor(price.data[,"BedroomAbvGr"])
price.data[,"KitchenAbvGr"] <- as.factor(price.data[,"KitchenAbvGr"])
price.data[,"TotRmsAbvGrd"] <- as.factor(price.data[,"TotRmsAbvGrd"])
price.data[,"Fireplaces"] <- as.factor(price.data[,"Fireplaces"])
price.data[,"GarageCars"] <- as.factor(price.data[,"GarageCars"])
price.data[,"OverallQual"] <- as.factor(price.data[,"OverallQual"])
price.data[,"OverallCond"] <- as.factor(price.data[,"OverallCond"])

price.test <- price.data[price.data$isTest == TRUE,]
price.train <- price.data[price.data$isTest == FALSE,]

smp_size <- floor(0.75 * nrow(price.train))
set.seed(123)
train_ind <- sample(seq_len(nrow(price.train)), size = smp_size)
train_new <- price.train[train_ind, ]
validate <- price.train[-train_ind, ]

price.test$SalePrice <- NA

#Percentage of data missing in train data set
sum(is.na(price.train))/ (nrow(price.train) * ncol(price.test)) # 0 values missing

price.names <- select(price.train, -Id , -SalePrice , -isTest)
price.names <- names(price.names)
model.equation <- paste(price.names, collapse = " + ")
model.equation.new <- paste ("SalePrice ~ ", model.equation)
model.formula <- as.formula(model.equation.new)

model <- randomForest(formula = model.formula, data = train_new, ntree = 500, mtry= 4, nodesize = 0.01*nrow(price.train))

SalePrice <- predict(model, newdata = price.test)
Id <- price.test$Id
outputdf <- as.data.frame(Id)
outputdf$SalePrice <- SalePrice

importance    <- importance(model)
varImpPlot(model)

head(outputdf)
write.csv(file="House Pricing output.csv", outputdf, row.names = FALSE)


#################################################################################
#                       CALCULATING RMSE VALUE ON VALIDATE DATA

SalePrice_Validate <- predict(model, newdata = validate)

RMSE <- function(x,y){
  a <- sqrt(sum((log(y)-log(x))^2)/length(y))
  return(a)
}
RMSE1 <- RMSE(SalePrice_Validate, validate$SalePrice)
RMSE1 <- round(RMSE1, digits = 5)
RMSE1 # 0.13733 
# Lower values of RMSE indicate better fit

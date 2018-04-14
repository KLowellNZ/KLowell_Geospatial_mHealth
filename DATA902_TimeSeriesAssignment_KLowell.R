#################################################################
# K LOWELL: Time Series Assignment.  This is the R-Code used
# to complete the assigment.  Specifically, the following models were fit:
# 1)ARIMA, 2)Exponential Smoothing, and 3)Facebook Prophet.
#################################################################
# NOTE: Some code that was used for experimentation is commented out.
# The non-commented code is not necessarily the code used to produce
# the graphics in the accompanying document.
##################################################################
# Load appropriate libraries and data for ARIMA and SES models.
###################################################################
# Import libraries
library(tseries)
library(astsa)
library(forecast)
library(fpp2)
# Read csv file with dates and convert it to a timeseries. Note: Each
# record is a single "step".  Frequency = 1 is the number of steps per
# unit of time.
inpath='C:/Analytics/DATA902/DATA902_TimeSeries/TimeSeries_Assignment/'
# infile='Daily_Demand_Forecasting_UrgentOrders.csv'
infile='Daily_Demand_Forecasting_NonUrgentOrders.csv'
pathfile=paste(inpath,infile,sep='')
dftimeser <- read.csv(file=pathfile, header=TRUE, sep=",")
# sertim<-ts(dftimeser$UrgentOrder, frequency=1)
sertim<-ts(dftimeser$NonUrgentOrder, frequency=1)
#
# Split into train (54 obs -- 90%) and test (6 obs -- 10%)
train <- window(sertim,c(1),c(54))
test <- window(sertim,c(55),c(60))
##############################################################
# Now fit ARIMA model.
##############################################################
# Step 1 -- Visualise the data
opar=par(mfrow=c(1,1))
plot.ts(sertim)
abline(lm(sertim~time(sertim)))
#
# Step 2 -- Check for stationarity 
adf.test(train)
adf.test(diff(train))
#
# Step 3 -- Use ACF and PACF to hypothesise the model. Use auto.arima
# as a guide.
acf2(train)
acf2(diff(train))
auto.arima(train)
#Step 4 -- build the model exploring various alternatives.
fit_1 <- sarima(train,p=0,q=0,d=0,P=1,Q=1,D=1,S=4)
# fit_1 <- sarima(train,p=0,q=1,d=1)
# fit_1 <- sarima(sertim,p=0,q=0,d=0,P=1,Q=1,D=1,S=4)
# fit_3 <- sarima(rec,p=1,q=0,d=1)
# fit_4 <- sarima(rec,p=3,q=0,d=0)
# Examine significance of coefficients.
fit_1$ttable
# Explore AIC and BIC of models fit for comparison.
fit_1$AIC
fit_1$BIC
#
#Step 5
#Predicting final 6 instances for various models.
# sarima.for(train,n.ahead=6,p=0,q=0,d=0,P=1,Q=1,D=1,S=4)
sarima.for(train,n.ahead=6,p=0,q=1,d=1)
lines(test,col=4)
# The following gives RMSE of the model fit for the tran and test data sets.
# fit_1_fore<-Arima(train,order=c(0,0,0),seasonal=list(order=c(1,1,1),period=5))
fit_1_fore<-Arima(train,order=c(0,1,1))
forecast_fit=forecast(fit_1_fore,h=6)
accuracy(forecast_fit,test)
#
##############################################################
# Now fit SES (Exponential Smoothing) model. whereas the ARIMA
# model was fit using urgent and non-urgent orders (to find an
# interesting data set), SES work is done only on non-urgent
# orders.
##############################################################
# Steps 1 and 2 -- Visualise the data and assess trend and seasonality
# and whether or not seasonality is additive or multiplicative.
opar=par(mfrow=c(1,1))
plot.ts(sertim)
abline(lm(sertim~time(sertim)))
#
# Step 3a -- Build the exponential smoothing model by applying SES
# to the training data and forecast 6 periods.
fitses <- ses(train,h = 6)
summary(fitses)
autoplot(fitses) + autolayer(fitted(fitses))
forecast_fit <- forecast(fitses,h=6)
#
# Step 3b -- For comparison, build the model using Holt-Winter.
fitholt <- holt(train)
summary(fitholt)
autoplot(fitholt) + autolayer(fitted(fitholt))
forecast_fit <- forecast(fitholt,h=6)
#
# Now plot the model fitted.
plot(forecast_fit)
lines(test,col="red")
accuracy(forecast_fit,test)
#
#Step 4 -- Forecast and check residuals
#Ljung-Box test: Null Hypothesis: Residuals are auto-correlated (have a pattern)
checkresiduals(fitses)
checkresiduals(fitholt)
#
##############################################################
# Now use Prophet to fit a model to the non-urgent orders time series.
##############################################################
library(prophet)
inpath='C:/Analytics/DATA902/DATA902_TimeSeries/TimeSeries_Assignment/'
# infile='ProphetDaily_Demand_Forecasting_NonUrgentOrders.csv'
infile='ProphetNoWeekends_Forecasting_NonUrgentOrders.csv'
pathfile=paste(inpath,infile,sep='')
dftimeser <- read.csv(file=pathfile, header=TRUE, sep=",")
# #Split into test and train
train <- dftimeser[1:54,]
test <- dftimeser[55:60,]
# Develop the Prophet model on the training data
prophetimeser<-prophet(train,weekly.seasonality=FALSE)
# prophetimeser<-prophet(train,weekly.seasonality=TRUE)
# prophetimeser<-prophet(train, daily.seasonality=TRUE)
#
# Create prediction dataframe. Predict all data. Then get RMSE.
future <- make_future_dataframe(prophetimeser,periods=6)
forecast=predict(prophetimeser,future)
train$yhat <- forecast$yhat[1:54]
test$yhat <- forecast$yhat[55:60]
rmsetrain=round((sum((train$y-train$yhat)^2)/length(train$y))^0.5,2)
rmsetest=round((sum((test$y-test$yhat)^2)/length(test$y))^0.5,2)
rmsetrain
rmsetest
#
# Plot the forecast
plot(prophetimeser, forecast,xlabel='Date',ylabel='Non-urgent Sales')
#
# Now plot forecast components
prophet_plot_components(prophetimeser, forecast)


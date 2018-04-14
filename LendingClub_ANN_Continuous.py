# -*- coding: utf-8 -*-
"""
Created on Wed Mar 28 10:29:51 2018

@author: Kim Earl Lowell
"""

#%%
############### tominutes #######################
# Function tominutes converts time in seconds to minutes and seconds
def tominutes(timeinseconds):
#    minutes, seconds = divmod(timeinseconds, 60)
#    hours, minutes = divmod(minutes, 60)
    hours=int(timeinseconds/3600)
    minutes=int((timeinseconds- hours*3600)/60)
    seconds=int(timeinseconds-hours*3600-minutes*60)
    return hours,minutes,seconds
#################### RMSE #######################################
# This function gets the RMSE given two dfs of predicted and actual.
# Convert predictions and actual y to single dataframe abd get stats.
def biasRMSEt(testpred,testY):
    testy_testpred=pd.DataFrame(testY,columns=['y_actual'])
    dfypred=pd.DataFrame(testpred,columns=['y_pred'])
    yactual_ypred=testy_testpred.merge(dfypred,right_index=True,
            left_index=True)
# Now calculate the RMSE
    yactual_ypred['bias']=(yactual_ypred['y_actual']-yactual_ypred['y_pred'])
    yactual_ypred['diffsqrd']=(yactual_ypred['y_actual']-yactual_ypred['y_pred'])**2
    bias=yactual_ypred['bias'].mean()
    RMSE=(yactual_ypred['diffsqrd'].mean())**0.5
    t=bias/(RMSE/(testpred.shape[0]**0.5))
    return  bias, RMSE, t
########################  MAIN PART OF PROGRAM  ####################
# This code runs the neural network for the lending club assignment
from keras.models import Sequential
from keras.layers import Dense, Dropout
from keras import optimizers
from keras import regularizers
import pandas as pd
from sklearn.model_selection import train_test_split
import time
# Read the data. This is the file that has had log transformations
# calculated for certain highly skewed variables.
path = 'C:/Analytics/DATA903/DATA903_Assignments/lending-club_data/'
#infile='log_accepted_2007_to_2017Q3_PythonCleaned_Test.csv'
outfile='outlog_lendingclub_contiuous_Test.csv'
infile='log_accepted_2007_to_2017Q3_PythonCleaned.csv'
outfile='outlog_lendingclub_contiuous.csv'
# Set up output file and dataframe.
cols=['Model','Layers','Neurons','LearnRate','Batch','loss','BIAS_train',
      'RMSE_train','t_train','BIAS_test','RMSE_test','t_test',
      'BIAS_current','RMSE_current','t_current','time_secs']
dfout=pd.DataFrame(columns=cols)
# Read data file.
dfall=pd.read_csv(path+infile)
# Get rid of everything that does not have an acceptable loan_status.
print('\nRows prior to loan status drop:',dfall.shape[0])
dfall = dfall.drop(dfall[(dfall['loan_status'] != 'Current') &
                   (dfall['loan_status'] != 'Charged Off') & 
                   (dfall['loan_status'] != 'Fully Paid')].index)
print('Rows after loan status drop:',dfall.shape[0])
# Get column names and normalise. (Do not normalise on loan status.)
 collist=dfall.columns.values.tolist()
for col in collist:
    if col == 'loan_status':
        continue
    dfall[col]=(dfall[col]-dfall[col].min())/(dfall[col].max()-dfall[col].min())
# Create two dfs and then filter. One has the training data: Fully Paid and 
# Charged off loans.  The other has the current loans.
#dftest=dfall.drop(dfall[dfall['loan_status'] == 'Charged Off'].index)
dftrain = dfall.drop(dfall[dfall['loan_status'] == 'Current'].index)
dftest=dfall.drop(dfall[(dfall['loan_status'] == 'Charged Off') | 
                   (dfall['loan_status'] == 'Fully Paid')].index)
#Convert the file to a matrix (from a df) and set up X and Y matrices.
trainmatrix = dftrain.as_matrix()
testmatrix=dftest.as_matrix()
# Get the variables of interest.
trainX = trainmatrix[:,2:]
trainY = trainmatrix[:,1]
# notcurr contains Charged Off and Fully paid
notcurrXtr, notcurrXte, notcurrYtr, notcurrYte=train_test_split(trainX, trainY,
                        test_size=0.2, random_state=0)
# currX and currY contain information on Current loans
currX=testmatrix[:,2:]
currY=testmatrix[:,1]
#############################################################
# Now set up the hyperparameters to explore: Number of layers,
# number of neurons in each layer, learning rate, and batch size.
numepochs=25
modelnum=0
layers=[5,15,25]
neurons=[20,30,40]
learnrates=[0.01,0.025]
batches=[512,2048]
#layers=[5]
#neurons=[20]
#learnrates=[0.01]
#batches=[512]
# Store the number of columns/features in n_cols for the ANN.
n_cols = notcurrXtr.shape[1]
loop_start_time=time.time()
for learnrate in learnrates:
    for batch in batches:
            for neuron in neurons:
                for layer in layers:
                    print('***********  Starting model:',modelnum+1,layer,
                          neuron,batch,learnrate,'***********')
# Set up the model:
                    model=Sequential()
                    for i in range(layer):
# Add the desired number of layers. Use regularisers to eliminate dead neurons.
                        model.add(Dense(neuron, activation='relu', input_shape=(n_cols,),
                                kernel_regularizer=regularizers.l1(0.01),
                                bias_regularizer=regularizers.l1(0.01)))
                        model.add(Dropout(0.5))
# Now add the output layer (Default activation function for the output layer is
# Identity.)
                    model.add(Dense(1))
                    adam=optimizers.Adam(lr=learnrate,decay=0.0001)
                    model.compile(optimizer = adam, loss = 'mean_squared_error')
# To use sgd, activation function must be softmax.
#sgd = optimizers.SGD(lr=0.1)
#model.compile(optimizer = sgd, loss = 'mean_squared_error')
# Check time to run model.
                    model_start_time=time.time()
# Fitting the model
###### Continuous model: ##############
# Assigning the model to bigmodel creates a history object that allows the
# model mse to be accessed and printed.
                    bigmodel=model.fit(notcurrXtr, notcurrYtr,epochs=numepochs,
                                   batch_size=batch)
# Now get various RMSEs.
                    trainpred=model.predict(notcurrXtr)
                    trainBIAS,trainRMSE,traint=biasRMSEt(trainpred,notcurrYtr)
                    print('\nRMSE train data (Fully Paid & Charged Off):',trainRMSE)
                    testprednc = model.predict(notcurrXte)
                    testBIAS,testRMSE,testt=biasRMSEt(testprednc,notcurrYte)
                    print('RMSE test data (Fully Paid & Charged Off):',testRMSE)
                    testpred=model.predict(currX)
                    currBIAS,currRMSE,currt=biasRMSEt(testpred,currY)
                    print('RMSE test data (Current Loans):',currRMSE,'\n\n')
# Print time progress
                    currenttime=time.time()
                    totelapsedtime=currenttime-loop_start_time
                    hours,mins,seconds=tominutes(totelapsedtime)
                    print('\nTotal Elapsed time(h.m.s):',int(hours),':',
                          int(mins),':',round(seconds))
                    modelapsedtime=currenttime-model_start_time
                    hours,mins,seconds=tominutes(modelapsedtime)
                    print('Model Elapsed time(h.m.s):',int(hours),':',
                          int(mins),':',round(seconds),'\n')
# Make the output dataframe and then append.
                    modelnum=modelnum+1
                    df2ad=pd.DataFrame([[modelnum,layer,neuron,learnrate,batch,
                                   bigmodel.history['loss'][numepochs-1],
                            round(trainBIAS,4),round(trainRMSE,4),round(traint,3),
                            round(testBIAS,4),round(testRMSE,4),round(testt,3),
                            round(currBIAS,4),round(currRMSE,4),round(currt,3),
                            round(modelapsedtime,0)]],columns=cols)
                    dfout=dfout.append(df2ad)

dfout.to_csv(path_or_buf=path+outfile, index=False)

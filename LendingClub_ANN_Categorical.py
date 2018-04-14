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
#################### ACCURACY#####################################
# This function gets the ACCURACY statistics given two dfs of
# predicted and actual.
def ACCURACY(pred,actual):
    pred=(pred>0.5).astype(int)
    temppred=pred[:,0]
    tempactual=actual[:,0]
    acc=accuracy_score(temppred,tempactual)
    prec=precision_score(temppred,tempactual)
    rec=recall_score(temppred,tempactual)
    confmatrix=confusion_matrix(temppred,tempactual)
    return acc, prec,rec, confmatrix
########################  MAIN PART OF PROGRAM  ####################
# This code runs the neural network for the lending club assignment
from keras.models import Sequential
from keras.layers import Dense, Dropout
from keras import optimizers, regularizers
import numpy as np
import pandas as pd
from keras.utils import to_categorical
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_score, recall_score, \
            confusion_matrix
import time
# Read the data. This is the file that has had log transformations
# calculated for certain highly skewed variables.
path = 'C:/Analytics/DATA903/DATA903_Assignments/lending-club_data/'
#infile='log_accepted_2007_to_2017Q3_PythonCleaned_Test.csv'
#infile='log_accepted_PythonCleaned_Test_v2.csv'
outfile='outlog_lendingclub_categorical_Test.csv'
infile='log_accepted_2007_to_2017Q3_PythonCleaned.csv'
#outfile='outlog_lendingclub_categorical.csv'
#infile='log_accepted_2007_to_2017Q3_PythonCleaned_MoreRobust.csv'
#outfile='outlog_lendingclub_categorical_MoreRobust.csv'
#infile='log_accepted_2007_to_2017Q3_PythonCleaned_SparseVars.csv'
#outfile='outlog_lendingclub_categorical_SparseVars .csv'
# Set up output file and dataframe.
cols=['Model','Layers','Neurons','LearnRate','Batch','loss','acctrain',
      'prectrain','recltrain','acctest','prectest','recltest',
      'actlpctchrgdoff','predpctchrgdoff','time_secs']
dfout=pd.DataFrame(columns=cols)
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
    try:
        dfall[col]=(dfall[col]-dfall[col].min())/(dfall[col].max()-dfall[col].min())*100
    except:
        continue                 
    # Create two dfs and then filter. One has the training data: Fully Paid and 
# Charged off loans.  The other has the current loans.
dftrain = dfall.drop(dfall[dfall['loan_status'] == 'Current'].index)
dfcurr=dfall.drop(dfall[(dfall['loan_status'] == 'Charged Off') | 
                   (dfall['loan_status'] == 'Fully Paid')].index)
#Convert the file to a matrix (from a df) and set up X and Y matrices.
trainmatrix = dftrain.as_matrix()
currmatrix=dfcurr.as_matrix()
# Get the variables of interest. Making column 0 Y is for predicting
# loan status.  All other variables (including int_rate) are used as
# predictors.
trainX = trainmatrix[:,1:]
trainY = trainmatrix[:,0]
factorY = pd.factorize (trainY)[0]
facY_cat = to_categorical (factorY)
# notcurr contains Charged Off and Fully paid
notcurrXtr, notcurrXte, notcurrYtr, notcurrYte=train_test_split(trainX, facY_cat,
                        test_size=0.2)
# currX and currY contain information on Current loans
currX=currmatrix[:,1:]
currY=currmatrix[:,0]
faccurrY=pd.factorize(currY)[0]
currY_cat = to_categorical (faccurrY)
#############################################################
# Now set up the hyperparameters to explore: Number of layers,
# number of neurons in each layer, learning rate, and batch size.
#layers=[5,15,25]
#neurons=[20,30,40]
#learnrates=[0.01,0.025]
#batches=[512,2048]
numepochs=15
modelnum=0
layers=[5]
neurons=[30]
learnrates=[0.001]
batches=[512]

# Store the number of columns/features in n_cols for the ANN.
n_cols = notcurrXtr.shape[1]
loop_start_time=time.time()
for learnrate in learnrates:
    for batch in batches:
            for neuron in neurons:
                for layer in layers:
                    print('****************  Starting model:',modelnum+1,layer,
                          neuron,learnrate,batch,'****************')
# Set up the model:
                    model=Sequential()
                    model.add(Dense(neuron, activation='relu',
                                        input_dim=n_cols))
#                                        input_shape=(n_cols,)))
                    for i in range(layer):
# Add the desired number of layers. Use regularisers to eliminate dead neurons.
# Add drop out layer every third layer.
#                        model.add(Dense(neuron, activation='relu', input_shape=(n_cols,),
#                                kernel_regularizer=regularizers.l1(0.01),
#                                bias_regularizer=regularizers.l1(0.01)))
                        model.add(Dense(neuron, activation='relu'))
                        model.add(Dropout(0.5))
# Finish model, compile and run.
                    model.add(Dense(2,activation='softmax'))
                    sgd=optimizers.SGD( lr=learnrate, decay=0.00001,
                                       momentum=0.9, nesterov=True)
#                    adam=optimizers.Adam( lr=learnrate, decay=0.01)
                    model.compile(optimizer='rmsprop',
                                  loss='categorical_crossentropy',
                                  metrics=['acc'])
# Check time to run model.
                    model_start_time=time.time()
# Fitting the categorical model.
                    bigmodel= model.fit(notcurrXtr, notcurrYtr,epochs=numepochs,
                                   batch_size=batch)
# Predict the training data set and evaluate stats..
                    trainpred=model.predict(notcurrXtr)
                    trnacc,trnprec,trnrec,trncnfmtrx= \
                            ACCURACY(trainpred,notcurrYtr)
                    print('\nAcc/Prec/Rec train data (Fully Paid & Charged Off):\n'
                          ,'{:.3f}'.format(trnacc),',',
                          '{:.3f}'.format(trnprec),',',
                          '{:.3f}'.format(trnrec))
                    print('Confusion Matrix:\n',trncnfmtrx,'\n')
# Predict the test training data set (20% of Fully Paid & Charged Off) and
# calcualte stats.
                    testprednc=model.predict(notcurrXte)
                    tstacc,tstprec,tstrec,tstcnfmtrx= \
                            ACCURACY(testprednc,notcurrYte)
                    totchrgdoff=len(dftrain[dftrain['loan_status']=='Charged Off'])
                    actlpctchrgdoff=(totchrgdoff/dftrain.shape[0])*100
                    print('Acc/Prec/Rec test data (Fully Paid & Charged Off):\n'
                          ,'{:.3f}'.format(tstacc),',',
                          '{:.3f}'.format(tstprec),',',
                          '{:.3f}'.format(tstrec))
                    print('Confusion Matrix:\n',tstcnfmtrx,'\n')
# Predict the current loans. Calculate % charged off in Fully Paid &
# Charged Off and calculate % predicted to be Charged Off ub Current
# Loans.
                    testpredcurr=model.predict_proba(currX)
                    print(testpredcurr)
                    binarypredcurr=(testpredcurr>0.5).astype(int)
                    testpredcurr=testpredcurr[:,0]
                    predpctchrgdoff=100-(np.sum(binarypredcurr)/len(testpredcurr))*100
                    print('Pct loans actually charged off:',
                          '{:.1f}'.format(actlpctchrgdoff),
                          '\nPredicted charge-offs (Current Loans):',
                            '{:.1f}'.format(predpctchrgdoff))
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
                        bigmodel.history['loss'][numepochs-1],trnacc,
                        trnprec,trnrec,tstacc,tstprec,tstrec,actlpctchrgdoff,
                        predpctchrgdoff,round(modelapsedtime)]],columns=cols)
                    dfout=dfout.append(df2ad)
dfout.to_csv(path_or_buf=path+outfile, index=False)

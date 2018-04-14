# -*- coding: utf-8 -*-
"""
Created on Fri Dec 29 12:23:59 2017

@author: Kim Earl Lowell
"""

#%%
# KL code.This will clean some of the Martin's Point claims data.
################ concatchars #####################
# Function concatchars checks for non-numeric information in cells where it
# appears that textual information contained a comma -- e.g., "Statistical,
# non-specific chest pain." It concatenates the two fields separating them
# by a slash. It checks for strings that contain no digits.
def concatchars(dfout,i,subjcol):
# Change things if the cell is not null and it contains only characters.
    if pd.notnull(dfout.iloc[i,subjcol]) and not any(char.isdigit() 
        for char in str(dfout.iloc[i,subjcol])):
        dfout.iloc[i,subjcol-1]=str(dfout.iloc[i,subjcol-1])+'/'+\
                  str(dfout.iloc[i,subjcol])
        for j in range(subjcol+1,dfout.shape[1]-1):
            dfout.iloc[i,j-1]=dfout.iloc[i,j]
    dfout.iloc[i,dfout.shape[1]-1]=''
    return dfout
################ concatmixed #####################
# Function concatchars checks if a string as any letters at all in cells where
# it appears that textual information contained a comma -- e.g., "Pneumonia, 13
# cc drug A". It concatenates the two fields separating them
# by a slash. It checks for strings that contain no digits.
def concatmixed(dfout,i,subjcol):
# Change things if the cell is not null and it contains only characters.
    if pd.notnull(dfout.iloc[i,subjcol]) and any(char.isalpha() 
        for char in str(dfout.iloc[i,subjcol])):
        dfout.iloc[i,subjcol-1]=str(dfout.iloc[i,subjcol-1])+'/'+\
                  str(dfout.iloc[i,subjcol])
        for j in range(subjcol+1,dfout.shape[1]-1):
            dfout.iloc[i,j-1]=dfout.iloc[i,j]
    dfout.iloc[i,dfout.shape[1]-1]=''
    return dfout
############## addleadzero #####################
# Function addleadzero adds a zero to the front of zip codes that had the
# zero stripped off (probably when the csv file was created).
def addleadzero(dfout,i,subjcol):
    print(i,type(dfout.iloc[i,subjcol]))
    print(len(dfout.iloc[i,subjcol]))
    if pd.notnull(dfout.iloc[i,subjcol]) and len(dfout.iloc[i,subjcol])<5:
        dfout.iloc[i,subjcol]='0'+dfout.iloc[i,subjcol]
#################################################
############### tominutes #######################
# Function tominutes converts time in seconds to minutes and seconds
def tominutes(timeinseconds):
#    minutes, seconds = divmod(timeinseconds, 60)
#    hours, minutes = divmod(minutes, 60)
    hours=int(timeinseconds/3600)
    minutes=int((timeinseconds- hours*3600)/60)
    seconds=int(timeinseconds-hours*3600-minutes*60)
    return hours,minutes,seconds
#################################################
############## MAIN BODY OF PROGRAM #############
import pandas as pd
import time
# Set up input and output files and read input file.
#inpath = "C:/Analytics/DATA911/Martins_Point/MP_Data/MP_Test_Kim/"
#infile='Claims_201401_201412_Kim_1053.csv'
inpath = "C:/Analytics/DATA911/Martins_Point/MP_Data/MP_Raw/"
infile='Claims_201401_201412.csv'
#infile='Claims_201501_201512.csv'
#infile='Claims_201501_201512.csv'
#infile='Claims_201701_201712.csv'
outfile = "C:/Analytics/DATA911/Martins_Point/MP_Data/MP_Clean/CleanClaims_201401_201412.csv"
#outfile = "C:/Analytics/DATA911/Martins_Point/MP_Data/MP_Clean/CleanClaims_201401_201412.csv"
#outfile = "C:/Analytics/DATA911/Martins_Point/MP_Data/MP_Clean/CleanClaims_201501_201512.csv"
#outfile = "C:/Analytics/DATA911/Martins_Point/MP_Data/MP_Clean/CleanClaims_201501_201512.csv"
#outfile = "C:/Analytics/DATA911/Martins_Point/MP_Data/MP_Clean/CleanClaims_201701_201712.csv"
# Set up counters, timers, output dataframe, etc.
start_time=time.time()
chunksize=10000
chunknumb=0
#colnames=['MembID','Insurance','YesNo','MembState','Age','Gender','MDState',
#          'Diag1','Diag2','Diag3','Diag4','Cost1','Cost2','Cost3']
#cols=[0,2,6,7,11,12,21,39,41,43,45,51,52,53]
dfnewout=pd.DataFrame()
# Ignore initial space in a field rather than stripping it later. And for some
# reason, using nrows=x causes changes in the type of variable created. The
# dtype option changes that. names=range(57) forces the reading of 57 columns
# even though Col 57 is sparsely populated. Read in chunks.
for dfout in pd.read_csv(inpath+infile, chunksize=chunksize, header=None,
                skipinitialspace=True,index_col=False,
                dtype={19:object, 22:object, 27:object,
                28:object, 47:object, 53:object, 55:object, 56:object,
                57:object,58:object,59:object}, names=range(59)):
    chunknumb=chunknumb+1
    startrow=(chunknumb-1)*chunksize+1
    print('\nProcess chunk',chunknumb,'   Starting row:',startrow)
    currenttime=time.time()
    elapsedtime=currenttime-start_time
    hours,mins,seconds=tominutes(elapsedtime)
    millionrowtime=elapsedtime/startrow*1000000
    mhours,mmins,mseconds=tominutes(millionrowtime)
    print('   Elapsed time(h.m.s):',int(hours),':',
          int(mins),':',int(seconds),'\n   Million row time:',int(mhours),
          ':',int(mmins),':',int(mseconds))
#dfin = pd.read_csv(inpath+infile,header=None,skipinitialspace=True,nrows=1000,
#                  dtype={19:object,22:object,27:object,28:object,47:object,
#                          53:object,55:object,56:object,57:object},
#                         names=range(57))
# Loop through dataframe fixing anomalies as we go.
    droplist=[]
    for i in range(dfout.shape[0]):
# Because I drop some rows (based on missing values mjessing up the data),
# I get errors. Test for this error and break out of loop if it does not work.
        try:
            dummyvar=pd.notnull(dfout.iloc[i,25])
        except:
            break
# If Col 26 (25 in Python) contains a first name instead of a blank, an extra
# column is present in the data base. Overwrite Col 29 (28 in Python) which
# seems to be the added column. PATCH after AND: It was also discovered that
# if Col 30 (usually a zip code) is empty, then things have not been shifted.
        if pd.notnull(dfout.iloc[i,25]) and pd.notnull(dfout.iloc[i,30]):
# Col 27 is empty. Overwrite. Note that there is now a superfluous column that
# will have to be deleted.
            for j in range(28,dfout.shape[1]):
                dfout.iloc[i,j-1]=dfout.iloc[i,j]
# If column 29 is numbers rather than a state abbreviation, there is an error.
# Move from Col Q (16) to the end of all variables right one space. Start
# with rightmost variables
        if pd.notnull(dfout.iloc[i,29]) and str(dfout.iloc[i,29]).isdigit():
            for j in range(dfout.shape[1]-1,16,-1):
                dfout.iloc[i,j]=dfout.iloc[i,j-1]
# PATCH: Unfixable problems associated with claims for which Servicing_prov_zip
# is blank.  ***** Add row to drop list for dropping later. 
# ********Ignore the row/lose the claim and get next claim.
# Shift rows 17 to 26 right one column. Reset index so rows are not skipped.
#        if i>510 and i < 540:
#            print(i,len(str(dfout.iloc[i,30])),dfout.iloc[i,29:33])
        if pd.isnull(dfout.iloc[i,30]) or len(str(dfout.iloc[i,30])) < 3:
            droplist.insert(0,i)
#            dfout=dfout.drop(dfout.index[i])
#            dfout=dfout.reset_index(drop=True)
#            continue
# If column 22 is letters (a state abbreviation), there is an error.  Move 
# from Col Q (16) to Col 24 right one columns
        if pd.notnull(dfout.iloc[i,22]) and not str(dfout.iloc[i,22]).isdigit():
            for j in range(17,26):
                dfout.iloc[i,j-1]=dfout.iloc[i,j]
            dfout.iloc[i,25]=''
# If a number of columns contains text ONLY, the text must be appended to the field
# to the left, and all columns to the right shifted one cell to the left.
# This is prevalent enough to write a function concatcols.
# Column 38 (Excel col AM) is part of a diagnosis.
        subjcol=38
        dfout=concatchars(dfout,i,subjcol)
# Columns 41, 43, 45, and 47 are also part of a diagnosis.
        subjcol=41
        dfout=concatchars(dfout,i,subjcol)
        subjcol=43
        dfout=concatchars(dfout,i,subjcol)
        subjcol=45
        dfout=concatchars(dfout,i,subjcol)
        subjcol=47
        dfout=concatchars(dfout,i,subjcol)
# For Col 51, there may be 3 columns that are part of a procedure description.
# The part to concatenate may contain letters and numbers, so a different
# function is required.
        subjcol=51
        for k in range(3):
            dfout=concatmixed(dfout,i,subjcol)
# Some cases could not be fixed, this is indicated by column 54 being empty.
# If this occurs, add the row to the drop list.
        if pd.isnull(dfout.iloc[i,54]):
            droplist.insert(0,i)
# Delete right-most columns that have become superfluous and add the new
# chunk to the dataframe.
    dfout=dfout.drop(dfout.columns[55:59],axis=1)
# Drop rows for which there were problems.
    for row in droplist:
        dfout=dfout.drop(dfout.index[[row]])
# Column 21 is blank. If needed, it should be labelled Servicing_prov_address2
# and be placed after Col 20 Servicing_prov_address1
#    dfout=dfout.drop(dfout.columns[21],axis=1)
    dfnewout=pd.concat([dfnewout,dfout],axis=0)
####################################
#    if chunknumb >= 5:
#        break
####################################
# Write the cleaned and subsetted dataframe to a csv file.
colnames=['Member_no_NPHI','Full_name_NPHI','LOB','plan_code','current_plan_desc',\
          'enroll_status','Overlap_flag','phys_state','zip','DOB_NPHI','DOB_Year',\
          'New_age','gender','Death_Year','PCP_id',\
          'PCP_prov_TYPE','PCP_prov_SPECIALTY',\
          'PCP_contract_affiliation','PCP_address1','PCP_address2','PCP_city',\
          'PCP_state','PCP_zip','Health_System_2',\
          'Servicing_prov_LASTNAME','Servicing_prov_FIRSTNAME',\
          'Servicing_prov_degree','Servicing_prov_address1',\
          'Servicing_prov_city','Servicing_prov_state','Servicing_prov_zip',\
          'de_id_claim_number','Service_date_full_date','paid_denied_flag',\
          'status_level_1','status_level_2','status_level_3','Diag1_AHRQ_long',\
          'Diag1_AHRQ_short','Diag1','Diag1_desc','Diag2','Diag2_desc',\
          'Diag3','Diag3_desc','Diag4','Diag4_desc','DRG_code','DRG_desc',\
          'Procedure_code','Procedure_desc',\
          'Net_amt','Billed_amt','Allowed_amt','Service_Yearmo']
dfnewout.columns=colnames
dfnewout.to_csv(path_or_buf=outfile, index=False)

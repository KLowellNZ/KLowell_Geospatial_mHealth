# -*- coding: utf-8 -*-
"""
Created on Tue Feb 13 13:19:35 2018

@author: Kim Earl Lowell
"""

#%%
# Set up input of dictionary file.  Dictionary will contain all ACCT-codes
# used in the KPIs as keys and the FS files in which they will be found as
# the look-up value.

inpath='C:/Analytics/DATA911/Arkatechture/NCUA_Data/NCUA_Data_Final/PYE_Test/'
# Set up the dictionary to know from which files to grab ACCTs.  Infile 1 is
# the file that says which ACCTs are used to calculate which KPIs and
# also tells in which file an ACCT is located.
infile1='TargetKPI_TargetAccts.csv'
dfdict=pd.read_csv(inpath+ACprefix+infile1, usecols=['Account','AcctName','TableName'],
                   skipinitialspace=True)
# Eliminate duplicate lines. Because some ACCTs are sought in the previous year,
# we have to eliminate duplicates.
dfdict=dfdict.drop_duplicates()
# For ease of searching, make all accounts lowercase.
dfdict['Account']=dfdict['Account'].str.lower()
# Make first two characters of file lowercase.
dfdict['TableName']=dfdict['TableName'].str.replace('FS','fs')
# Create empty dictionary for ACCT/file information.

########################################################
# Text Mining Assignment
# DATA 902
# STUDENT: Kim Lowell
# NARRATIVE: I pulled postings from a UFO blog site. Because 
# blogs are considerably longer than tweets (that are limited
# to 280(?) characters), I pulled about 700 blog postings.
####################################################
# Install libraries
library(qdap)
library(tm)
library(readtext)
library(wordcloud)
library(RWeka)
library(tidytext)
library(dplyr)
library(radarchart)
library(tibble)
library(ggplot2)
library(lubridate)
library(lexicon)
library(lubridate)
library(stringr)


# Import data
setwd('C:/Analytics/DATA902/DATA902_TextMining_Phani/TextMine_Assignments/')
ufotext <- read.csv("ufo_blogs.csv")

###############################################################
# Get rid of emojis and then punctuation.
ufotext$text <- iconv(ufotext$text, from = "UTF-8", to = "ASCII", sub = "")
ufotext$text <- removePunctuation(ufotext$text)

#making a corpus of a vector source 
ufo_corpus <- VCorpus(VectorSource(ufotext$text))
#Cleaning corpus - pre_processing
clean_corpus <- function(cleaned_corpus){
    removeURL <- content_transformer(function(x) gsub("(f|ht)tp(s?)://\\S+", "", x, perl=T))
    cleaned_corpus <- tm_map(cleaned_corpus, removeURL)
    cleaned_corpus <- tm_map(cleaned_corpus, content_transformer(replace_abbreviation))
    cleaned_corpus <- tm_map(cleaned_corpus, content_transformer(tolower))
    cleaned_corpus <- tm_map(cleaned_corpus, removePunctuation)
    cleaned_corpus <- tm_map(cleaned_corpus, removeNumbers)
    cleaned_corpus <- tm_map(cleaned_corpus, removeWords, stopwords("english"))
# Establish custom stopwords to improve analysis.
    custom_stop_words <- c("ufo","ufos","like","see","went","around",
                           "just","saw","get")
    cleaned_corpus <- tm_map(cleaned_corpus, removeWords, custom_stop_words)
# Do not stem corpus as this appears unnecessary
# cleaned_corpus <- tm_map(cleaned_corpus, stemDocument,language = "english")
    cleaned_corpus <- tm_map(cleaned_corpus, stripWhitespace)
    return(cleaned_corpus)
}

cleaned_ufo_corpus <- clean_corpus(ufo_corpus)
# Spotcheck cleaned corpus if desired.
#print(cleaned_ufo_corpus[[8]][1])

########### TDM/DTM########
TDM_ufos <- TermDocumentMatrix(cleaned_ufo_corpus)
TDM_ufos_m <- as.matrix(TDM_ufos)
# If desired, examine the TDM -- i.e., frequency of words
# (rows) in each sentence (columns).
# TDM_ufos_m[1:8,1:3]

# Look at a bar chart form the Term_Frequnecy_Matrix to determine if more
# custom-stop words need to be added.
term_frequency <- rowSums(TDM_ufos_m)
# Sort term_frequency in descending order
term_frequency <- sort(term_frequency,dec=TRUE)
# View the top 20 most common words
top20 <- term_frequency[1:25]
# Plot a barchart of the 20 most common words
barplot(top20,col="darkorange",las=2)

############ UNI-GRAM (SINGLE-WORD) WORD CLOUD  ##############
# Create word_freqs from term_frequencies from TDM matrix.
word_freqs <- data.frame(term = names(term_frequency), num = term_frequency)
# Create a wordcloud for the values in word_freqs
tempwcld<-wordcloud(word_freqs$term, word_freqs$num,min.freq=50,
                    max.words=150,colors=brewer.pal(8, "Set1"))

########################## Colors
# After looking at word cloud, change colours if
# necessary. View the available options.
display.brewer.all()

##############  NOW DO NGRAMS -- SPECIFICALLY 2 AND 3 #############
############## FIRST DO BI-GRAMS ##################################
tokenizer <- function(x)
  NGramTokenizer(x,Weka_control(min=2,max=2))
# Bi-gram tokenise the cleaned corpus. Then convert to matrix.
bigram_tdm <- TermDocumentMatrix(cleaned_ufo_corpus,control =
                                   list(tokenize=tokenizer))
bigram_tdm_m <- as.matrix(bigram_tdm)
# If necessary, check that we have bigrams if necessary. Then produce word cloud.
# bigram_tdm_m[1:5,1:3]
term_frequency <- rowSums(bigram_tdm_m)
term_frequency <- sort(term_frequency,dec=TRUE)
# Create word_freqs
word_freqs <- data.frame(term = names(term_frequency), num = term_frequency)
# Create a wordcloud for the bi-grams in word_freqs
wordcloud(word_freqs$term, word_freqs$num,min.freq=15,max.words=30,
          colors=brewer.pal(8, "Paired"))

###################### NOW DO TRI-GRAMS #########################
########### NOTE: ONLY 2 OR 3 TRI-GRAMS FIT ON PAGE #############
tokenizer <- function(x)
  NGramTokenizer(x,Weka_control(min=3,max=3))
# Bi-gram tokenise the cleaned corpus. Then convert to matrix.
bigram_tdm <- TermDocumentMatrix(cleaned_ufo_corpus,control =
                                   list(tokenize=tokenizer))
bigram_tdm_m <- as.matrix(bigram_tdm)
# Check that we have bigrams if necessary. Then produce word cloud.
bigram_tdm_m[1:5,1:3]
term_frequency <- rowSums(bigram_tdm_m)
term_frequency <- sort(term_frequency,dec=TRUE)
# Create word_freqs
word_freqs <- data.frame(term = names(term_frequency), num = term_frequency)
# Create a wordcloud for the bi-grams in word_freqs
wordcloud(word_freqs$term, word_freqs$num,min.freq=7,max.words=25,
          colors=brewer.pal(8, "Set1"))

########## WORD CLOUD BASED ON TF-IDF WEIGHTING #########
# Start with the cleaned corpus, weight it, convert to
# a matrix, get (unigram) word frequency, sort it and 
# produce the Word cloud.
tfidf_tdm <- TermDocumentMatrix(cleaned_ufo_corpus,
              control=list(weighting=weightTfIdf))
tfidf_tdm_m <- as.matrix(tfidf_tdm)
term_frequency <- rowSums(tfidf_tdm_m)
term_frequency <- sort(term_frequency,dec=TRUE)
# Create word_freqs
word_freqs <- data.frame(term = names(term_frequency),
                         num = term_frequency)
wordcloud(word_freqs$term, word_freqs$num,min.freq=50,
          max.words=150,colors=brewer.pal(8, "Paired"))

#####################  NOW DO SENTIMENT ANALYSIS ###################
### HOW MANY POSITIVE AND HOW MANY NEGATIVE BLOG POSTINGS ARE THERE?
# Get polarity score for each posting and create an extra column 
# with the score. Use the uncleaned text.
(revpolarity<- polarity(ufotext$text))
ufotext$sentiment<- revpolarity$all$polarity
# View(ufotext)

ufoposblogs =length(which(ufotext$sentiment > 0))
ufonegblogs =length(which(ufotext$sentiment <= 0))

ufoposblogs
ufonegblogs
############## GRAPHING SENTIMENT ANALYSIS ############################
# Use bing lexicon
bing_lex <- get_sentiments("bing")
ufo_tidy <- tidy(TDM_ufos)
# Join the bing lexicon
ufo_bing_lex <- inner_join(ufo_tidy, bing_lex, by = c("term" = "word"))
table(ufo_bing_lex$sentiment)
# Track sentiment over blogs
ufo_bing_lex$sentiment_n <- ifelse(ufo_bing_lex$sentiment=="negative", -1, 1)
ufo_bing_lex$sentiment_value <- ufo_bing_lex$sentiment_n * ufo_bing_lex$count
# Do necessary aggregations
ufoaggdata <- aggregate(ufo_bing_lex$sentiment_value, list(index = ufo_bing_lex$document), sum)
sapply(ufoaggdata,typeof)
ufoaggdata$index <- as.numeric(ufoaggdata$index)
# Now plot the results various ways.
# Line chart with "confidence"
ggplot(ufoaggdata, aes(index, x)) + geom_smooth() + theme_bw()+
  geom_hline(yintercept = 0, color = "red")+xlab("Blog")+
  ylab("Positive/Negative Sentiment")+ggtitle("UFO Blog Sentiment")
# Consecutive points.
ggplot(ufoaggdata, aes(index, x)) + geom_point() +xlab("Blog")+
  ylab("Positive/Negative Sentiment")+ggtitle("UFO Blog Sentiment")
# Progressive line.
ggplot(ufoaggdata, aes(index, x)) + geom_line(position="jitter")+xlab("Blog")+
  ylab("Positive/Negative Sentiment")+ggtitle("UFO Blog Sentiment")

######################## COMMONALITY CLOUD ############################
# Now split the dataframe (not the corpus) in two based on positive
# or negative. Column three has the sentiment score.
dfpos <- ufotext[ufotext[ , 3] > 0.0, ]
dfneg <- ufotext[ufotext[ , 3] <= 0.0, ]
# Now put them in a side-by-side data frame. then make a corpus
# and clean it with the function defined earlier.
postext<- paste(unlist(dfpos$text), collapse =" ")
negtext<- paste(unlist(dfneg$text), collapse =" ")
posnegtext <- c(postext,negtext)
posneg_corpus <- VCorpus(VectorSource(posnegtext))
cleaned_posneg_corpus <- clean_corpus(posneg_corpus)
################## TDM/DTM AND ADDITIONAL PRE-PROCESSING ########
TDM_posneg <- TermDocumentMatrix(cleaned_posneg_corpus)
TDM_posneg_m <- as.matrix(TDM_posneg)
term_frequency <- rowSums(TDM_posneg_m)
# Sort term_frequency in descending order
term_frequency <- sort(term_frequency,dec=TRUE)
word_freqs <- data.frame(term = names(term_frequency), num = term_frequency)
# Create a wordcloud for the values in word_freqs
commonality.cloud(TDM_posneg_m,colors=brewer.pal(8, "Dark2"),max.words = 100)

################# COMPARISON CLOUD #########################################
colnames(TDM_posneg) <- c("Good UFOs","Bad UFOs")
TDM_posneg_m <- as.matrix(TDM_posneg)
comparison.cloud(TDM_posneg_m,colors=brewer.pal(8, "Dark2"),max.words = 150)

##################### EMOTIONAL RADAR CHART ###############################
# Use the previously cleaned (not pos-neg-separated) corpus into required
# form.
# cleaned_mytext_corpus <- clean_corpus(review_corpus)
TDM_mytext <- TermDocumentMatrix(cleaned_ufo_corpus)
ufotext_tidy <- tidy(TDM_mytext)
nrc_lex <- get_sentiments("nrc")
# Now link sentiments to individual words.
ufo_nrc <- inner_join(ufotext_tidy, nrc_lex, by = c("term" = "word"))
ufo_nrc_noposneg <- ufo_nrc[!(ufo_nrc$sentiment %in% c("positive","negative")),]
# Aggregate/count words by sentiment.
ufoaggdata <- aggregate(ufo_nrc_noposneg$count, 
                     list(index = ufo_nrc_noposneg$sentiment), sum)
# Produce radar chart.
chartJSRadar(ufoaggdata)


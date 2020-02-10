# load packages
library(tidyverse)
library(haven)

# load Pollbase monthly averages
df.pollbase <- read_csv("Monthly average-Table 1.csv")

# fill in missing dates
df.pollbase <- df.pollbase %>% fill(X1)
df.pollbase$X1[1] <- 1983

# split dataset into (i) polls and (ii) actual GE results
df.polls <- df.pollbase %>% filter(df.pollbase$X2!="GE")
df.ge <- df.pollbase %>% filter(df.pollbase$X2=="GE")

# change to correct date format
table(df.polls$X2)
df.polls$date <- paste0("01-", df.polls$X2)
table(df.polls$date)
df.polls$date <- as.Date(df.polls$date, "%d-%b-%y")
table(df.polls$date)
df.polls$year <- df.polls$X1
table(df.polls$year)

df.ge
# oops, this doesn't contain the actual GE dates...
# ok let's grab them from wikipedia
library(httr)
library(XML)
url <- "https://en.wikipedia.org/wiki/List_of_United_Kingdom_general_elections#List_of_elections"
r <- GET(url)
doc <- readHTMLTable(
  doc=content(r, "text"))
list <- as.data.frame(doc[1])
# we want all GE dates from 1983
ge.dates <- as.character(na.omit(list[88:101,2])) 
ge.dates <- as.Date(ge.dates, "%d %B %Y")
# fill in the dataset
df.ge$date <- ge.dates
df.ge$date.quarter <- floor_date(df.ge$date, unit = c("quarter"))
table(df.ge$date.quarter)
df.ge$date.quarter.lag <- as.yearmon(df.ge$date.quarter) - .25
table(df.ge$date.quarter.lag)

# load GDP data
gdp <- read_csv("series-220120.csv")
head(gdp)
gdp <- gdp[-(2:8),]
gdp$quarter <- substr(gdp$Title, nchar(gdp$Title)-1, nchar(gdp$Title))
table(gdp$quarter)
tail(gdp)
gdp.q1 <- gdp %>% filter(quarter=="Q1")
gdp.q1$year <- substr(gdp.q1$Title, 1,4)
gdp.q1$gdp <- gdp.q1$`Gross Domestic Product: Quarter on Quarter growth: CVM SA %`
gdp.ge <- gdp.q1 %>% select(year, gdp)

names(df.ge)
df.ge$year <- df.ge$X1
df.ge <- df.ge %>% select(year, Conservative, Labour)

df.ge <- merge(df.ge, gdp.ge, by="year")
df.ge$year <- as.numeric(df.ge$year)
df.ge$gdp <- as.numeric(df.ge$gdp)

inc.list <- c("CON", "CON", "CON", "CON", "LAB", "LAB", "LAB", "CON", "CON","CON" )
length(inc.list)
dim(df.ge)
df.ge$incumbent <- inc.list
df.ge$inc.vote.share <- ifelse(df.ge$incumbent=="CON", df.ge$Conservative, df.ge$Labour)
inc.terms <- c(1, 2, 3, 4, 1, 2, 3, 1, 2, 3)
df.ge$inc.terms <- inc.terms

summary(lm(inc.vote.share ~ gdp + year + inc.terms, data=df.ge))



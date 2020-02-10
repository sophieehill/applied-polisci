# required packages
library(tidyverse) # for data wrangling
library(ggplot2) # for plotting
library(dygraphs) # for interactive graph
library(xts)  # for interactive graph


# First, download the latest dataset from Pollbase:
# https://www.markpack.org.uk/opinion-polls/

# Then, save the "monthly average" tab as a .csv file

# Adjust file name below to match where you saved this file

# load data
pb <- read_csv("/Users/sophiehill/Google Drive/applied-polisci/R code/PollBase-Q4-2019/Monthly average-Table 1.csv")

# have a look
head(pb)

# create indicator for GE
pb$GE.ind <- ifelse(pb$X2=="GE", 1, 0)

library(lubridate)
# convert date format
pb$month <- ifelse(pb$X2=="GE", NA, pb$X2)
pb$date <- ifelse(is.na(pb$month), NA, paste("01-", pb$month,sep=""))
pb$date <- as.Date(pb$date, format="%d-%b-%y") # %b means the month is writing in characters not numbers (e.g. "Dec" instead of "12")
pb$date

# let's fill in the GE dates manually
# this gives us the row numbers of the blank GE dates
which(pb$GE.ind==1)
# corresponding to 1983 to 2019
pb$date[1] <- as.Date("1983-06-09")
pb$date[51] <- as.Date("1987-06-11")
pb$date[111] <- as.Date("1992-04-09")
pb$date[173] <- as.Date("1997-05-01")
pb$date[224] <- as.Date("2001-06-07")
pb$date[272] <- as.Date("2005-05-05")
pb$date[334] <- as.Date("2010-05-06")
pb$date[396] <- as.Date("2015-05-07")
pb$date[423] <- as.Date("2017-06-08")
pb$date[455] <- as.Date("2019-12-12")

# select the columns we need
pbx <- pb %>% select(date, Conservative, Labour, LD, UKIP, BXP)
head(pbx)
pbx.wide <- pbx # save wide format to use again later

# change data from wide to long format
# (always use LONG format data with ggplot!)
pbx <- pbx %>% gather("Conservative":"BXP", key=party, value=share)

# take a look
head(pbx)

# set up colors for each party
party.cols <- c("BXP" = "cadetblue1", "Conservative" = "blue", "Labour" = "red", "LD" = "gold1", "UKIP" = "purple")

# save list of GE dates to mark on chart
GE.dates <- pb$date[pb$GE.ind==1]
# save list of GE "names" to annotate on chart
GE.names <- paste0("GE ", substr(GE.dates, 1, 4))


# plot results
pbx %>% 
  ggplot(aes(x=date, y=share, group=party, color=party)) + # set up the axes
  geom_line() + # plot lines
  theme_minimal() + # minimal theme
  xlab("") + ylab("") + # remove axis labels
  theme(legend.title=element_blank(), legend.position="bottom") + # remove legend label and move to bottom of chart
  scale_color_manual(values=party.cols) + # adjust colors 
  geom_vline(xintercept=GE.dates, lty="dashed", color="grey")

# now just plot CON lead over LAB
pbx.wide %>% 
  mutate(con.lead = Conservative - Labour) %>%
  ggplot(aes(x=date, y=con.lead)) + # set up the axes
  geom_line() + 
  theme_minimal() + # minimal theme
  xlab("") + ylab("CON - LAB") + # axis labels
  geom_vline(xintercept=GE.dates, lty="dashed", color="grey")
  

# interactive graphs
pbx.wide$con.lead <- pbx.wide$Conservative - pbx.wide$Labour
pbx.df <- as.data.frame(pbx.wide)

# CON data
pbx.con <- pbx.df[, c("date", "Conservative")]
CON <- xts(pbx.con[,-1], order.by=pbx.con[,1])

# LAB data
pbx.lab <- pbx.df[, c("date", "Labour")]
LAB <- xts(pbx.lab[,-1], order.by=pbx.lab[,1])

# LD data
pbx.ld <- pbx.df[, c("date", "LD")]
LD <- xts(pbx.ld[,-1], order.by=pbx.ld[,1])

# CON LEAD data
pbx.con.lead <- pbx.df[, c("date", "con.lead")]
CON.LEAD <- xts(pbx.con.lead[,-1], order.by=pbx.con.lead[,1])

pbx.all <- cbind(CON, LAB, LD)
dygraph(pbx.all, main = "Monthly poll averages, 1983-2019") %>%
  dyOptions(colors = c("blue", "red", "gold")) %>% 
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.5,
              hideOnMouseOut = FALSE) %>%
  dyRangeSelector() %>%
  dyEvent(GE.dates, GE.names, labelLoc="bottom")

CON.LEAD <- cbind(CON.LEAD)
dygraph(CON.LEAD, main = "Monthly poll averages, 1983-2019") %>%
  dySeries("V1", label = "CON-LAB %") %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.5,
              hideOnMouseOut = FALSE) %>%
  dyRangeSelector() %>%
  dyEvent(GE.dates, GE.names, labelLoc="bottom")


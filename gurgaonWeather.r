## load libraries
  library(dplyr)
  library(lubridate)
  ## ggplot is from gitub branch b181e9a, since the version on CRAN as of May 2016 did not support subtitle on the charts
  ## to install use the following 
      ## devtools::install_github("hadley/ggplot2")
  library(ggplot2)
  
## fetch data from wunderground
  # sample url to fetch data https://www.wunderground.com/history/airport/VIDP/2016/5/19/MonthlyHistory.html?req_city=Gurgaon&req_statename=India&reqdb.zip=00000&reqdb.magic=1&reqdb.wmo=42178&format=1
  # you can adapt it your use case by modifying the parameters like location and dates
  basePath <- c("https://www.wunderground.com/history/airport/VIDP/","/","/","/MonthlyHistory.html?req_city=Gurgaon&req_statename=India&reqdb.zip=00000&reqdb.magic=1&reqdb.wmo=42178&format=1")  
  
  ## set month and date
    ## change the mdate to change the month for which it fetches data
    ## don't change ddate, dont think date parameter has any affect on the data returned
  mDate <- "05"
  dDate <- "01"
  
  ## select range of year for which to fetch data
  ## you have to be careful about the starting year, different weather stations have different operationalisation dates
  yearRange <- c(2006,2016)
  
  ## make a loop and fetch data for the year range mentioned for the entire month
  for (i in yearRange[1]:yearRange[2]) {
    filePath <- paste0(basePath[1],as.character(i),basePath[2],mDate,basePath[3],dDate,basePath[4])
    print(filePath)
    tmp <- read.csv(filePath)
    if(i == yearRange[1]){
      df1 <- tmp
    }else{
      df1 <- rbind(df1,tmp)
    }
  }
  
  ## format the data add in more identifier columns
  df1$Year <- as.factor(year(df1$IST))
  df1$IST <- as.Date(df1$IST,"%Y-%m-%d")
  df1$Date <- as.numeric(format(df1$IST,"%d"))
  df2 <- df1 %>% filter(Date < 21)
  
  ## make plot
  
  ## do the box plot
  q <- ggplot(df2,aes(Year,Max.TemperatureC))
  q  <- q + geom_boxplot() + geom_jitter(colour="grey70")
    ## calculate the median  
    df3 <- df2 %>% select(Year,Max.TemperatureC) %>% group_by(Year) %>% summarise(medTemp = median(Max.TemperatureC))
    ## add in median to the box plot q
    q <- q + geom_text(data = df3, aes(y = medTemp, label = paste0(round(medTemp,0),"C")),size = 3, vjust = -0.5)
    q <- q + ggtitle("Gurgaon Max Temperature for first 20 days of May",subtitle="Line and Text represents median of observed temperatures, grey dots represent individual observations")
    q + theme(plot.title = element_text(hjust=0, size=16)) 
  

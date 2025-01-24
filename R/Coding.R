library(fBasics)
library(stringr)
library(zoo)
library(lubridate)
library(fBasics)
library(tidyverse)
library(vcd)
library(skimr)
library(readxl)
library(ggplot2)
library(tibbletime)
library(fBasics)
library(purrr)
library(openxlsx)
library(patchwork)
library(xts)
library(showtext)
library(forecast)
showtext_auto(enable = TRUE)
font_add("kaishu","simkai.ttf")

csv_list=dir("../",pattern =".csv")
da<-read_csv("../summerOly_athletes.csv")

da|>
  mutate(Golden_Medal = as.numeric(Medal=="Gold"),
         Silver_Medal = as.numeric(Medal=="Silver"),
         Bronze_Medal = as.numeric(Medal=="Bronze"))->da_1

aggregate(x=da_1$Golden_Medal,by=list(da_1$Sport,da_1$Event,da_1$Year,da_1$NOC),sum)|>
  rename(Golden_Medal='x')|>
  inner_join(aggregate(x=da_1$Silver_Medal,by=list(da_1$Sport,da_1$Event,da_1$Year,da_1$NOC),sum))|>
  rename(Silver_Medal='x')|>
  inner_join(aggregate(x=da_1$Bronze_Medal,by=list(da_1$Sport,da_1$Event,da_1$Year,da_1$NOC),sum))|>
  rename(Sport="Group.1",
         Event="Group.2",
         Year="Group.3",
         NOC="Group.4",
         Bronze_Medal='x')|>
  mutate(Total_Medal=Golden_Medal+Silver_Medal+Bronze_Medal)->Medal_data




write.csv("Medal_data.csv")










aggregate(x=da_1$Medal_number,by=list(da_1$Sport,da_1$Event,da_1$Year,da_1$NOC),sum)|>
rename(Sport="Group.1",
       Event="Group.2",
       Year="Group.3",
       NOC="Group.4",
       Total_Medals=x)|>
  inner_join(Golden_data)|>
  mutate(Event.code=as.numeric(factor(Event)))->da_2
aggregate(x=da_1$Medal_number,by=list(da_1$Sport,da_1$Year,da_1$NOC),sum)|>
  rename(Sport="Group.1",
         Year="Group.2",
         NOC="Group.3")->da_3

write.csv()


da_3|>
  filter(Sport=="Football")->da_4

aov(xda_3)

ggplot(da_4,mapping = aes(group = Team,x=Year,y=x))+geom_line()+geom_point()



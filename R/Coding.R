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
library(countrycode)
library(do)

showtext_auto(enable = TRUE)
font_add("kaishu","simkai.ttf")

csv_list=dir("./data",pattern =".csv")
da<-read_xlsx("./data/summerOly_athletes.xlsx")
host_data<-read_csv("./data/summerOly_hosts.csv")


# Event 级别

da|>
  mutate(Golden_Medal = as.numeric(Medal=="Gold"),
         Silver_Medal = as.numeric(Medal=="Silver"),
         Bronze_Medal = as.numeric(Medal=="Bronze"))->da_1
# athlete
aggregate(x=da_1$Golden_Medal,by=list(da_1$Sport,da_1$Event,da_1$Year,da_1$NOC),length)|>
  rename(Athlete_number="x")->Athlete
# event participants
aggregate(x=da_1$Golden_Medal,by=list(da_1$Sport,da_1$Event,da_1$Year),length)|>
  rename(Event_Participants="x")->Event_Participants
# Event Medal
aggregate(x=da_1$Golden_Medal,by=list(da_1$Sport,da_1$Event,da_1$Year),sum)|>
  rename(Event_Golden_Medal='x')|>
  inner_join(aggregate(x=da_1$Silver_Medal,by=list(da_1$Sport,da_1$Event,da_1$Year),sum))|>
  rename(Event_Silver_Medal='x')|>
  inner_join(aggregate(x=da_1$Bronze_Medal,by=list(da_1$Sport,da_1$Event,da_1$Year),sum))|>
  rename(Event_Bronze_Medal='x')->Event_Medal
# Medal
aggregate(x=da_1$Golden_Medal,by=list(da_1$Sport,da_1$Event,da_1$Year,da_1$NOC),sum)|>
  rename(Golden_Medal='x')|>
  inner_join(aggregate(x=da_1$Silver_Medal,by=list(da_1$Sport,da_1$Event,da_1$Year,da_1$NOC),sum))|>
  rename(Silver_Medal='x')|>
  inner_join(Athlete)|>
  inner_join(Event_Medal)|>
  inner_join(Event_Participants)|>
  inner_join(aggregate(x=da_1$Bronze_Medal,by=list(da_1$Sport,da_1$Event,da_1$Year,da_1$NOC),sum))|>
  rename(Sport="Group.1",
         Event="Group.2",
         Year="Group.3",
         NOC="Group.4",
         Bronze_Medal='x')|>
  mutate(Total_Medal=Golden_Medal+Silver_Medal+Bronze_Medal)->Medal_data


# Host
da|>
  distinct(Team,NOC)->Country_NOC
host_data|>
  mutate(Host=str_trim(str_replace_all(str_extract(Host,',.+'),',','')))->xs
NOC_find<-function(country){
  Country_NOC|>
    filter(Team==country)->x
  if(nrow(x)==0){
    return(country)
  }else{
    return(x[["NOC"]])
  }
}
s=list()
for (k in xs$Host){
  s[length(s)+1]=NOC_find(k)
  if(grepl("Jap",s[length(s)])){
    s[length(s)]="JPN"
  }
  if(grepl("United K",s[length(s)])){
    s[length(s)]="GBR"
  }
}
s->host_data$Host

aggregate(x=da_1$Golden_Medal,by=list(da_1$Sport,da_1$Event,da_1$Year),length)

Medal_data|>
  inner_join(host_data)|>
  mutate(Host=as.numeric(Host==NOC),
         Medal_rate=Total_Medal/(Athlete_number+0.00000001),
         Participation_rate=Athlete_number/Event_Participants,
         Golden_rate=Golden_Medal/(Event_Golden_Medal+0.0000000001),
         Silver_rate=Silver_Medal/(Event_Silver_Medal+0.0000000001),
         Bronze_rate=Bronze_Medal/(Event_Bronze_Medal+0.0000000001))|>
  filter(Event_Participants>1,
         Participation_rate<0.999)|>
  mutate(NOC = str_trim(str_replace_all(NOC,"\'",'')))->Medal_data_with_host
write.csv(Medal_data_with_host,file.path("Event_data.csv"))
da|>
  filter(Event=="Art Competitions Mixed Sculpturing, Reliefs")->test

# Country 级别

# Population
Pop<-read_csv("./Data/Population_1.csv")
Pop|>
  pivot_longer(where(is.numeric),
               names_to = "Year",
               values_to = "Population")|>
  drop_na()|>rename(NOC="Country Code",
                    Country="Country Name")|>
  mutate(Year=as.numeric(Year),
         NOC=countrycode(NOC,origin='wb',destination='ioc' ))|>
  select(NOC,Year,Population)->Pop_data

Medal_data_with_host|>
  filter(Year>=1960,NOC!='COK',
         NOC!='CRT',NOC!='EOR',NOC!='NFL')|>
  Replace(c('AIN'),c('RUS'))|>Replace('IOA',"TLS")|>Replace('YAR',"YEM")|>
  Replace('YMD',"YEM")|>mutate(Year=as.numeric(Year))|>
  inner_join(Pop_data)->data_With_year

write.csv(data_With_year,file.path("Data_with_year.csv"))


# test
Pop_data|>
  rename(code="NOC")|>
  distinct(code)->NOC_2
test_2|>
  distinct(NOC)|>
  mutate(Fit=NOC%in%unlist(NOC_2))|>
  filter(Fit==FALSE)->NOC_1
# 



# 3 AIN 俄罗斯与白俄罗斯 
# 2 AHO 荷属安的列斯 解体
# 9 ANZ 澳大拉西亚 澳大利亚与新西兰联队 1908-1912 
# 28 BOH 捷克一部分
# EUN 独联体
# FRG 西德 GDR 东德 IOA改为东帝汶TLS LIB改为LBN MAL改为MAS
# MON改为MGl NBO改为MAS 











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
library(tseries)

showtext_auto(enable = TRUE)
font_add("kaishu","simkai.ttf")

csv_list=dir("./data",pattern =".csv")
da<-read_xlsx("./data/summerOly_athletes.xlsx")
host_data<-read_csv("./data/summerOly_hosts.csv")


# Event 级别

da|>
  mutate(Golden_Medal = as.numeric(Medal=="Gold'"),
         Silver_Medal = as.numeric(Medal=="Silver'"),
         Bronze_Medal = as.numeric(Medal=="Bronze'"))-> da_1
# athlete
aggregate(x= da_1$Golden_Medal,by=list( da_1$Sport, da_1$Event, da_1$Year, da_1$NOC),length)|>
  rename(Athlete_number="x")->Athlete
# event participants
aggregate(x= da_1$Golden_Medal,by=list( da_1$Sport, da_1$Event,da_1$Year),length)|>
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
  mutate(Total_Medal=Golden_Medal+Silver_Medal+Bronze_Medal)|>
  mutate(NOC = str_trim(str_replace_all(NOC,"\'",'')))->Medal_data


# Host
da|>
  distinct(Team,NOC)|>
  mutate(Team = str_trim(str_replace_all(Team,"\'",'')),
         NOC = str_trim(str_replace_all(NOC,"\'",'')))->Country_NOC
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
  if(grepl("Soviet",s[length(s)])){
    s[length(s)]="RUS"
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
         Participation_rate<0.999)->Medal_data_with_host
write.csv(Medal_data_with_host,file.path("Event_data.csv"))
da|>
  filter(Event=="Art Competitions Mixed Sculpturing, Reliefs")->test


# ------------------------------
# Country 级别
da|>
  mutate(Golden_Medal = as.numeric(Medal=="Gold'"),
         Silver_Medal = as.numeric(Medal=="Silver'"),
         Bronze_Medal = as.numeric(Medal=="Bronze'"))->da_c
# athlete
aggregate(x=da_c$Golden_Medal,by=list(da_c$Year,da_c$NOC),length)|>
  rename(Athlete_number="x")->Athlete_c
# event participants
aggregate(x=da_c$Golden_Medal,by=list(da_c$Year),length)|>
  rename(Participants="x")->Participants_c
# Event Medal
aggregate(x=da_c$Golden_Medal,by=list(da_c$Year),sum)|>
  rename(Total_Golden_Medal='x')|>
  inner_join(aggregate(x=da_c$Silver_Medal,by=list( da_c$Year),sum))|>
  rename(Total_Silver_Medal='x')|>
  inner_join(aggregate(x=da_c$Bronze_Medal,by=list( da_c$Year),sum))|>
  rename(Total_Bronze_Medal='x')->Medal_c
# Medal
aggregate(x=da_c$Golden_Medal,by=list( da_c$Year,da_c$NOC),sum)|>
  rename(Golden_Medal='x')|>
  inner_join(aggregate(x=da_c$Silver_Medal,by=list( da_c$Year,da_c$NOC),sum))|>
  rename(Silver_Medal='x')|>
  inner_join(Athlete_c)|>
  inner_join(Medal_c)|>
  inner_join(Participants_c)|>
  inner_join(aggregate(x=da_c$Bronze_Medal,by=list( da_c$Year,da_c$NOC),sum))|>
  rename(
         Year="Group.1",
         NOC="Group.2",
         Bronze_Medal='x')|>
  mutate(Country_Medal=Golden_Medal+Silver_Medal+Bronze_Medal,
         Total_Medal=Total_Golden_Medal+Total_Silver_Medal+Total_Bronze_Medal)|>
  mutate(NOC = str_trim(str_replace_all(NOC,"\'",'')))->Medal_data_c

Medal_data_c|>
  inner_join(host_data)|>
  mutate(Host=as.numeric(Host==NOC),
         Medal_rate=Country_Medal/Total_Medal,
         Participation_rate=Athlete_number/Participants,
         Golden_rate=Golden_Medal/(Total_Golden_Medal),
         Silver_rate=Silver_Medal/(Total_Silver_Medal),
         Bronze_rate=Bronze_Medal/(Total_Bronze_Medal))|>
  filter(Participants>1,
         Participation_rate<0.999)->Medal_data_with_host_c






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
# Country



# 3 AIN 俄罗斯与白俄罗斯 
# 2 AHO 荷属安的列斯 解体
# 9 ANZ 澳大拉西亚 澳大利亚与新西兰联队 1908-1912 
# 28 BOH 捷克一部分
# EUN 独联体
# FRG 西德 GDR 东德 IOA改为东帝汶TLS LIB改为LBN MAL改为MAS
# MON改为MGl NBO改为MAS 
library(forecast)
# ARIMA
# cause test
cause_f<-function(c_code,k_1=1,k_2=3){
  Medal_data_with_host_c|>
    filter(NOC%in%c_code,Year>1940)->ts_dat
  if(nrow(ts_dat)<3){
    return(0)
  }
  ts_data<-ts(ts_dat$Country_Medal)
  ts_data_1<-ts(ts_dat$Participation_rate)
  ord=auto.arima(ts_data,ic="aic")
  ord_1=auto.arima(ts_data_1,ic="aic")
  ccfv<-ccf(ord_1$residuals, ord$residuals, plot=FALSE)
  stat <- ccfv$n.used * sum((ccfv$acf[
    ccfv$lag >= k_1 - 1E-8 & ccfv$lag <= k_2 + 1E-8])^2)
  pvalue <- 1 - pchisq(stat, df=5)
  c(stat=stat,pvalue=pvalue,NOC=c_code)
}


Medal_data_with_host_c|>
  distinct(NOC)->NOC_s
answer<-t(map_dfc(unlist(NOC_s),cause_f))
answer<-data.frame(answer)
answer|>mutate(X2=as.numeric(X2))|>
  filter(X3!='0')|>drop_na()|>mutate(p_value=factor(as.integer(X2*10)/10))->answer_1

ggplot(answer_1,aes(x=p_value,fill=p_value))+
  geom_bar()+scale_fill_brewer(palette = "RdBu")+labs(
    title = "P-Value of Granger Causality Test",
    subtitle = '1940-2024,'
  )+theme(plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5))













Medal_data_with_host_c|>
  filter(NOC=='USA',Year>1940)->ts_dat
ts_data<-ts(ts_dat$Country_Medal)
#paint
plot(ts_data)
adf.test(ts_data)
tsdata.diff11<-diff(ts_data,lag=1,differences=1)
acf(tsdata.diff11)
plot(tsdata.diff11)
# 
ord=auto.arima(ts_data,ic="aic")
resid=ord$residuals 
tsdiag(ord)
#
arima.pred<-forecast(ord,h=5)
plot(arima.pred)
####
ts_data_1<-ts(ts_dat$Participation_rate)
#paint
plot(ts_data_1)
adf.test(ts_data_1)
# 
ord_1=auto.arima(ts_data_1)
resid_1=ord_1$residuals 
tsdiag(ord_1)
#
arima.pred<-forecast(ord_1,h=5)
plot(arima.pred)

ccfv<-ccf(ord_1$residuals, ord$residuals, plot=FALSE)
ccfv
stat <- ccfv$n.used * sum((ccfv$acf[
  ccfv$lag >= -4 - 1E-8 & ccfv$lag <= 4 + 1E-8])^2)
pvalue <- 1 - pchisq(stat, df=9)
c(stat=stat, pvalue=pvalue)
Medal_data_with_host_c|>
  inner_join(coun_e)|>
  filter(Participation_rate<0.3)->test_dat
## 特征工程
#参与者、主办方和总奖牌数
cor.test(test_dat$Medal_rate,
  test_dat$Participation_rate)
plot(test_dat$Medal_rate,
      test_dat$Participation_rate)
lm1<- lm(Country_Medal~Participation_rate+Total_Medal+Host,data =test_dat)
summary(lm1)
# gender

da_1|>filter(Sex=='M\'')->da_M
da_1|>filter(Sex=='F\'')->da_F
nrm=nrow(da_M)
nrf=nrow(da_F)
prop.test(c(sum(da_M$Golden_Medal),sum(da_F$Golden_Medal)),
          c(nrm,nrf))
prop.test(c(sum(da_M$Silver_Medal),sum(da_F$Silver_Medal)),
          c(nrm,nrf))
prop.test(c(sum(da_M$Bronze_Medal),sum(da_F$Bronze_Medal)),
          c(nrm,nrf))
tot_M=sum(da_M$Golden_Medal)+sum(da_M$Silver_Medal)+sum(da_M$Bronze_Medal)
tot_F=sum(da_F$Golden_Medal)+sum(da_F$Silver_Medal)+sum(da_F$Bronze_Medal)
prop.v<-prop.test(c(tot_M,tot_F),
          c(nrm,nrf))
prop.v$p.value

#experience
da|>
  distinct(Year,Name,NOC,Sport)|>
  arrange(Name,Year)->expe_raw
s='0'
Sport_now='0'
NOC_now='0'
expe=list(0)
for(k in 2:nrow(expe_raw)){
  if(s==expe_raw$Name[k]&&Sport_now==expe_raw$Sport[k]&&
     NOC_now==expe_raw$NOC[k]){
    expe[k]=expe[[k-1]]+1
  }
  else{
    expe[k]=0
  }
  s=expe_raw$Name[[k]]
  Sport_now=expe_raw$Sport[k]
  NOC_now=expe_raw$NOC[k]
}
experience<-cbind(expe_raw,unlist(expe))|>
  rename(experience='unlist(expe)')
aggregate(x=experience$experience,by=list(experience$Year,experience$NOC),sum)|>
  rename(experience="x")|>
  inner_join(aggregate(x=experience$experience,
                      by=list(experience$Year,experience$NOC),length))|>
  rename(Year='Group.1',NOC='Group.2',Number='x')|>
  mutate(average_exp=experience/Number)->coun_e




da_1|>
  mutate(experience=expe_cal(Name,Year))->expe_data
answer<-map2_dfc(unlist(da_1$Name),unlist(da_1$Year),expe_cal)



answer<-data.frame(answer)
k<-aov(Medal_rate~Participation_rate,test_dat)
summary(k)

##2 定阶
##查看自相关函数图以及偏自相关函数图，对平稳的序列模型进行识别
##绘制自相关函数图
acf(tsdata.diff11)
tsdata.diff11<-diff(ts_data,lag=1,differences=1)
plot(tsdata.diff11)
adf.test(tsdata.diff11)
# 1阶
##从图可以得知，自相关函数是3阶拖尾
##绘制偏自相关函数图
pacf(tsdata.diff11)
# 1阶
##从图可以得知，偏自相关函数是1阶截尾,可以判断应使用ARIMA(1,1,0)模型
ord=auto.arima(ts_data,ic="aic")
resid=arima.mod$residuals 
##3 构建ARIMA模型：ARIMA(1,1,0)，并检验模型的残差
library(forecast)

arima.mod=auto.arima(ts_France, ic= "aic")
##4 提取模型的残差向量，检验是否还有相关信息可以提取
resid=arima.mod$residuals 
##对残差进行白噪声检验
Box.test(resid) 
##检验的p-value远大于0.01，说明残差为白噪声序列
##再次查看自相关函数图和偏自相关函数图，近似没有信息再提取
acf(resid)
pacf(resid)
##从QQ图上看，中间部分还是近接近正态分布的
qqnorm(resid)
qqline(resid)
##5 进行预测
library(forecast)
arima.pred<-forecast(arima.mod,h=5)
plot(arima.pred)





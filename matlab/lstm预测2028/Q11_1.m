clc
clear
close all
load("athletes.mat")
Ano = xlsread("运动员姓名匹配表.xlsx");
%% 加上每个人的参赛次数
uniqueNames = unique(athletes.Name);
Cdata = [Ano double(athletes.Year)]; %创建比较表

for i=1:size(Cdata,1)
    temp_data = Cdata(Cdata(:,1)==Cdata(i,1),:);
    Cdata(i,3) = sum(Cdata(i,2)>temp_data(:,2))+1; %第几年参赛
end
save("athletes_times.mat","athletes")


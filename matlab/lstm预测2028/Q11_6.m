clc
clear
close all
load("athletes_times.mat")
load("medal.mat")
pre = readtable("95个城市预测结果.xlsx");
country = pre.NOC; %获取城市列表
hData = {}; %储存各城市的历史序列
for i=1:size(country,1)
    temp = medal(strcmp(medal.NOC, country{i}),:) ;
    hData{i,1} = double(temp{:, {'Year','Gold', 'Silver', 'Bronze','Total'}});
end
for i=1:size(pre,1)
    data = [hData{i,1}(:,2:end);double(pre{i,2:end})];
    if data(end,1)<data(end-1,1)
        country{i,2} = -1;
    elseif data(end,1)==data(end-1,1)
        country{i,2} = 0;
    else
        country{i,2} = 1;
    end
end
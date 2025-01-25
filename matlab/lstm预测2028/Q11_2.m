clc
clear
close all
load("athletes_times.mat")
load("medal.mat")
%% 数据说明
%输入：上一期各奖牌数量、这次的参赛人数、本次参赛人员的总参赛年数、本次参赛人员的平均年数
%输出：金、银、铜数量
%% 获取所有国家NOC
uniqueNOCs = unique(medal.NOC);
%% 创建数据
minyear = min(medal.Year);
maxyear = max(medal.Year);
DATA = {};
for c=1:size(uniqueNOCs,1) %遍历每一个国家
    nowNOC = uniqueNOCs{c}; %当前目标国家
    temp = []; %当前要考虑的国家的表
    num = 1;
    % 找到当前 NOC 的所有行
    NOC_medal = medal(strcmp(medal.NOC, nowNOC),:);
    for year = minyear+4:4:maxyear
        %% 存上一期奖牌数量
        L_index = ismember(NOC_medal.Year, year-4); %上一年的索引
        index = find(L_index==1);
        if any(L_index) %如果有上一年
            temp(num,1:3) = double(NOC_medal{index(1), {'Gold', 'Silver', 'Bronze'}}); %更新上一年的奖牌数量
        else %如果没有上一年
            temp(num,1:3) = [0 0 0];
        end
        %% 存这次的参赛人数
        C_p = athletes((strcmp(athletes.NOC, nowNOC) & athletes.Year == year),:); %当前期的参赛表
        if isempty(C_p) %如果今年未参赛
            temp(num,:) = []; %不计入数据集
            continue %就直接找下一年
        else %今年参赛
            temp(num,4) = size(C_p,1); %参赛人数
            temp(num,5) = sum(C_p.times); %总参赛年数
            temp(num,6) = sum(C_p.times)/size(C_p,1); %本次参赛人员的平均年数
        end
        %% 存因变量
        C_index = ismember(NOC_medal.Year, year); %当前年索引
        index = find(C_index==1);
        if any(C_index)
            temp(num,7:9) = double(NOC_medal{index(1), {'Gold', 'Silver', 'Bronze'}}); %更新上一年的奖牌数量
        else 
            temp(num,7:9) = [0 0 0];
        end
        num = num +1;
    end
    DATA{1,c} = temp;
end
%% 删除空表
LSTM_data = DATA;
for j=size(LSTM_data,2):-1:1
    if isempty(LSTM_data{1,j})
        uniqueNOCs(j,:) = [];
        LSTM_data(:,j) = [];
    end
end
LSTM_data = [uniqueNOCs LSTM_data'];
save("LSTM_data.mat","LSTM_data")

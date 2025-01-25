clc
clear
close all
load("athletes_times.mat")
load("medal.mat")
%% 数据说明
%输入：t-1奖牌数量、近3届的参赛人数、本次参赛人员的总参赛年限、本次参赛人员的平均年限
%输出：奖牌数量
%% 先获取所有国家的唯一值
uniqueNOCs = unique(medal.NOC);
%% 创建数据
minyear = min(medal.Year);
maxyear = max(medal.Year);
DATA = {};
for c=1:size(uniqueNOCs,1) %遍历每一个国家
    nowNOC = uniqueNOCs{c}; %当前要查找的国家
    temp = []; %当前要考虑的国家的表
    num = 1; %记录存到第几行了
    % 找到当前 NOC 的所有行
    NOC_medal = medal(strcmp(medal.NOC, nowNOC),:);
    for year = minyear+8:4:maxyear
        %% 存t-1奖牌数量
        L_index = ismember(NOC_medal.Year, year-4); %上一年的索引
        index = find(L_index==1);
        if any(L_index) %如果有t-1
            temp(num,1) = double(NOC_medal{index(1), {'Total'}}); %更新上一年的奖牌数量
        else %如果没有上一年
            temp(num,1) = 0;
        end
        %% 存t-2的参赛人数
        C_p = athletes((strcmp(athletes.NOC, nowNOC) & athletes.Year == year-8),:); %当前期的参赛表
        if isempty(C_p) %如果没有参赛
            temp(num,2) = 0;
        else %如果参赛了
            temp(num,2) = size(C_p,1); %参赛人数
        end
        %% 存t-2的参赛人数
        C_p = athletes((strcmp(athletes.NOC, nowNOC) & athletes.Year == year-4),:); %当前期的参赛表
        if isempty(C_p) %如果没有参赛
            temp(num,3) = 0;
        else %如果参赛了
            temp(num,3) = size(C_p,1); %参赛人数
        end
        %% 存这次的参赛人数
        C_p = athletes((strcmp(athletes.NOC, nowNOC) & athletes.Year == year),:); %当前期的参赛表
        if isempty(C_p) %如果今年没有参赛
            temp(num,:) = []; %不计入数据集
            continue %就直接找下一年
        else %如果今年参赛了
            temp(num,4) = size(C_p,1); %参赛人数
            temp(num,5) = sum(C_p.times); %总参赛年限
            temp(num,6) = sum(C_p.times)/size(C_p,1); %本次参赛人员的平均年限
        end
        %% 存因变量
        C_index = ismember(NOC_medal.Year, year); %当前年的索引
        index = find(C_index==1);
        if any(C_index) %如果有当前年
            temp(num,7) = 1; %更新标签
        else %如果没有当前年
            temp(num,7) = 0;
        end
        num = num +1;
    end
    DATA{1,c} = temp;
end
%% 删除空表
BP_data = DATA;
for j=size(BP_data,2):-1:1
    if isempty(BP_data{1,j})
        uniqueNOCs(j,:) = [];
        BP_data(:,j) = [];
    end
end
BP_data = [uniqueNOCs BP_data'];
save("BP_data.mat","BP_data")
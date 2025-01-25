clc
clear
close all
load("athletes_times.mat")
load("BP_data.mat")
load("medal.mat")
%% 数据说明
%输入：上一期各奖牌数量、这次的参赛人数、本次参赛人员的总参赛年限、本次参赛人员的平均年限
%% 先获取所有国家num
uniqueNOCs = unique(BP_data(:,1));
%% 创建数据
input28 = []; %当前目标国家
for c=1:size(uniqueNOCs,1) %遍历每一个国家
    nowNOC = uniqueNOCs{c};
    % 当前 NOC 的所有行
    NOC_medal = medal(strcmp(medal.NOC, nowNOC),:);
    year = 2028;
    %% 存上一期奖牌数量
    L_index = ismember(NOC_medal.Year, year-4); %上一年的索引
    index = find(L_index==1);
    if any(L_index) %如果有上一年
        input28(c,1:3) = double(NOC_medal{index(1), {'Gold', 'Silver', 'Bronze'}});
    else %如果没有上一年
        input28(c,1:3) = [0 0 0];
    end
    %% 存这次的参赛人数
    C_p = athletes((strcmp(athletes.NOC, nowNOC) & athletes.Year == year-4),:); %当前期的参赛表
    if isempty(C_p) %如果今年没有参赛
        input28(c,:) = []; %不计入
        continue %就直接找下一年
    else %如果今年参赛了
        input28(c,4) = size(C_p,1); %参赛人数
        input28(c,5) = sum(C_p.times); %总参赛年数
        input28(c,6) = sum(C_p.times)/size(C_p,1); %本次参赛人员的平均年数
    end
end
save("input28.mat","input28")
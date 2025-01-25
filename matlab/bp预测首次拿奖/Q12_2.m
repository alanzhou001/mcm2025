clc
clear
close all
load("athletes_times.mat")
load("BP_data.mat")
load("medal.mat")
uAthletesNOCs = unique(athletes.NOC);
uBPNOCs = unique(medal.NOC);
complement = setdiff(uAthletesNOCs,uBPNOCs); %需要进行判别的国家
%% 数据说明
%输入：t-1奖牌数量、近3届的参赛人数、本次参赛人员的总参赛年限、本次参赛人员的平均年限
%% 创建数据
input28 = []; %当前要考虑的国家的表
for c=1:size(complement,1) %遍历每一个国家
    nowNOC = complement{c}; %当前要查找的国家
    % 找到当前 NOC 的所有行
    NOC_medal = medal(strcmp(medal.NOC, nowNOC),:);
    year = 2028;
    %% 存t-1奖牌数量
    L_index = ismember(NOC_medal.Year, year-4); %上一年的索引
    index = find(L_index==1);
    if any(L_index) %如果有t-1
        input28(c,1) = double(NOC_medal{index(1), {'Total'}}); %更新上一年的奖牌数量
    else %如果没有上一年
        input28(c,1) = 0;
    end
    %% 存t-2的参赛人数
    C_p = athletes((strcmp(athletes.NOC, nowNOC) & athletes.Year == year-8),:); %当前期的参赛表
    if isempty(C_p) %如果没有参赛
        input28(c,2) = 0;
    else %如果参赛了
        input28(c,2) = size(C_p,1); %参赛人数
    end
    %% 存t-2的参赛人数
    C_p = athletes((strcmp(athletes.NOC, nowNOC) & athletes.Year == year-4),:); %当前期的参赛表
    if isempty(C_p) %如果没有参赛
        input28(c,3) = 0;
    else %如果参赛了
        input28(c,3) = size(C_p,1); %参赛人数
    end
    %% 存这次的参赛人数
    C_p = athletes((strcmp(athletes.NOC, nowNOC) & athletes.Year == year-4),:); %当前期的参赛表
    if isempty(C_p) %如果今年没有参赛
        input28(c,:) = []; %不计入数据集
        continue %就直接找下一年
    else %如果今年参赛了
        input28(c,4) = size(C_p,1); %参赛人数
        input28(c,5) = sum(C_p.times); %总参赛年限
        input28(c,6) = sum(C_p.times)/size(C_p,1); %本次参赛人员的平均年限
    end
end
save("input28.mat","input28")
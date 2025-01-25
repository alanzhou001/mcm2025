clc
clear
data = readtable('medal_counts.xlsx');
%% 删除不再分析的数据
% 定义要删除的值列表
valuesToDelete = {'AHO', 'BLR', 'BOH', 'CRT', 'EUN', 'LIB', 'MAL', 'NBO', 'NFL', 'RHO', 'ROC', 'RUS', 'SCG', 'TCH', 'UAR', 'UNK', 'URS', 'VNM', 'WIF', 'YUG'};

% 使用 ismember 函数创建一个逻辑数组，标识 NOC 列中是否包含要删除的值
rowsToDelete = ismember(data.NOC, valuesToDelete);

% 使用逻辑索引删除这些行
data = data(~rowsToDelete, :);
%% ANZ：随机分至澳大利亚和新西兰
for i=1:size(data,1)
    if strcmp(data.NOC{i}, 'ANZ')
        if rand<0.5
            data.NOC(i) = {'AUS'};
        else
            data.NOC(i) = {'NZL'};
        end
    end
end
%% ANZ：FRG、GDR：1990年前的数据合并至德国GER
%% SAA：纳入YEM
%% VNM:并入VIE
for i=1:size(data,1)
    if strcmp(data.NOC{i}, 'FRG') || strcmp(data.NOC{i}, 'GDR')
        if data.Year(i)<=1990
            data.NOC(i) = {'GER'};
        end
    end
    if strcmp(data.NOC{i}, 'SAA')
        data.NOC(i) = {'YEM'};
    end
    if strcmp(data.NOC{i}, 'VNM')
        data.NOC(i) = {'VIE'};
    end
end
medal = data;
save("medal.mat","medal")
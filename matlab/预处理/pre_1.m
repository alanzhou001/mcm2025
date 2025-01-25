clc
clear
data = readtable('summerOly_athletes.xlsx');

% 找出 NOC 列中的所有唯一值
uniqueNOCs = unique(data.NOC);
 
% 初始化一个 cell 数组来存储结果
maxYears = cell(length(uniqueNOCs), 1);
 
% 遍历每个唯一值，并找到对应的 Year 列中的最大值
for i = 1:length(uniqueNOCs)
    % 找到当前 NOC 的所有行
    rows = strcmp(data.NOC, uniqueNOCs{i});
    % 找到这些行中 Year 列的最小值
    minYears{i} = min(data.Year(rows));
    % 找到这些行中 Year 列的最大值
    maxYears{i} = max(data.Year(rows));
end
resultsTable = table(uniqueNOCs, minYears', maxYears, 'VariableNames', {'NOC', 'MinYear', 'MaxYear'});
 
% 显示结果
disp(resultsTable);

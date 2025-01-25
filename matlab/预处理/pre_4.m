clc
clear
load("athletes.mat")
% 使用 groupsummary 函数按 "NOC" 和 "Year" 分组，并计算每个组的行数
summarizedData = groupsummary(athletes, {'NOC', 'Year'}, @(x) length(x));
 
% 重命名输出表的统计列
summarizedData.NumAthletes = summarizedData.GroupCount;
summarizedData.GroupCount = []; % 删除原始的 GroupCount 列
newTable = summarizedData(:, 1:3);

% 获取唯一的 NOC 值
uniqueNOCs = unique(newTable.NOC);
selectedNOCs = uniqueNOCs(randperm(numel(uniqueNOCs), 20));
 
% 预设图形窗口和子图布局（例如，3x3 布局）
figure;
tiledlayout(5, 4);
 
% 遍历选中的 NOC，为每个 NOC 绘制子图
for i = 1:numel(selectedNOCs)
    % 筛选出当前 NOC 的数据
    nocData = newTable(strcmp(newTable.NOC, selectedNOCs{i}), :);
    
    % 获取当前 NOC 的名称（用于子图标题）
    nocName = selectedNOCs{i};
    
    % 确定当前子图的位置
    ax = nexttile;
    
    % 绘制散点图或线图（根据数据特性选择）
    scatter(nocData.Year, nocData.fun1_Name, 'filled'); % 示例使用散点图
    % 线图
    % plot(nocData.Year, nocData.fun1_Name, '-o');
    
    % 设置子图标题
    title(ax, ['NOC: ', nocName]);
    
    xlabel(ax, 'Year');
    ylabel(ax, 'Number of participants');
    grid on;
end
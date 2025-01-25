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
for i=size(hData,1):-1:1
    if size(hData{i,1},1)<=2
        hData(i,:) = [];
        pre(i,:) = [];
        country(i,:) = [];
    end
end


Rindex = randperm(size(country,1));
Rindex = Rindex(1:28); %随机选28个

hData = hData(Rindex,1);
pre = pre(Rindex,:);

figure
for i=1:size(pre,1)
    subplot(7,4,i)
    data = [hData{i,1}(:,2:end);double(pre{i,2:end})];
    % 获取矩阵的大小
    [numRows, numCols] = size(data);

    hold on; % 保持当前图形，以便在同一幅图中绘制多条线

    % 获取 MATLAB 内置的 lines 颜色顺序
    colors = lines(numCols);  % 循环遍历每一列
    for col = 1:numCols
        % 提取观测值（除去最后一行）
        observations = data(1:end-1, col);
        % 提取预测值（最后一行）
        predictions = data(end, col);
        % 计算偏差量
        deviation = mean(abs(observations-mean(observations)));

        % 为了在图中区分观测值和预测值，我们可以稍微调整预测值的 x 位置
        % 这样可以避免观测值和预测值的标记重叠
        x_observations = 1:length(observations);
        x_predictions = x_observations(end)+1;

        % 绘制观测值的折线图
        plot(x_observations, observations, '-o', 'Color', colors(col, :));
        % 绘制预测值的点（或你可以使用其他标记或线型）
        errorbar(x_predictions, predictions, predictions-deviation, predictions+deviation, '*', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor',colors(col, :),'Color',colors(col, :));
    end

    % 设置图形的标题和轴标签
    title(string(pre{i,1}));

    xlabel('Time');
    ylabel('Quantity');
    xlim([1 x_predictions])
    % 显示网格（可选）
    grid on;
    hold on;
end

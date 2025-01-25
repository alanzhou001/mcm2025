clc
clear
load("R.mat")
load("medal.mat")
Country = unique(medal.NOC); %所有国家
record = [];
for i=1:size(R,1)
    temp = R{i,1};
    record(i,1) = sum(sum(abs(temp)));
end

new_set(:,1) = Country;
for i=1:size(record,1)
    new_set{i,2} = record(i);
end

% 提取第二列数据（转换为数值型，因为 cell 数组可能包含不同类型的数据）
secondColumnData = cell2mat(new_set(:, 2));
 
% 对第二列数据进行降序排序，并获取排序索引
[~, sortIndices] = sort(secondColumnData, 'descend');
 
% 根据排序索引重新排列整个 cell 数组
sorted_new_set = new_set(sortIndices, :);

%% 下面进行可视化
r1 = R{sortIndices(1),1};
r2 = R{sortIndices(2),1};
r3 = R{sortIndices(2),1};
s_r = [];
s_r(:,1) = sum(abs(r1'));
s_r(:,2) = sum(abs(r2'));
s_r(:,3) = sum(abs(r3'));
%% 下面是热力图
% 奖项标签
awardLabels = {'Gold', 'Silver', 'Bronze'};

% 项目/地区标签
regionLabels = {'SWA', 'DIV', 'OWS', 'SWM', 'WPO', 'ARC', 'ATH', 'BDM', 'BSB', 'SBL', 'BK3', ...
    'BKB', 'PEL', 'BOX', 'BKG', 'CSP', 'CSL', 'CKT', 'CQT', 'BMF', 'BMX', 'MTB', 'CRD', ...
    'CTR', 'EDR', 'EVE', 'EJP', 'EVL', 'EDV', 'FEN', 'HOC', 'AFB', 'FBL', 'GLF', 'GAR', ...
    'GRY', 'GTR', 'HBL', 'HBL', 'Jeu de Paume', 'JUD', 'KTE', 'LAX', 'LAX', 'MPN', 'POL', ...
    'RQT', 'Roque', 'ROC', 'ROW', 'RU7', 'RUG', 'SAL', 'SHO', 'SKB', 'CLB', 'SQU', 'SRF', ...
    'TTE', 'TKW', 'TEN', 'TRI', 'TOW', 'VBV', 'VVO', 'PBT', 'WLF', 'WRF', 'WRG', 'FSK', ...
    'IHO'};

% 绘制第一幅热力图 (r1)
figure;

subplot(3, 1, 1);
imagesc(r1);  % 使用 imagesc 绘制热力图
colormap('parula');  % 使用合适的配色方案
colorbar;  % 添加颜色条
set(gca, 'YTick', 1:3, 'YTickLabel', awardLabels);  % 设置 Y 轴标签
set(gca, 'XTick', 1:71, 'XTickLabel', regionLabels);  % 设置 X 轴标签
xtickangle(90);  % X 轴标签旋转90度，避免重叠
title('CHN');  % 设置标题

% 绘制第二幅热力图 (r2)
subplot(3, 1, 2);
imagesc(r2);  % 使用 imagesc 绘制热力图
colormap('parula');  % 使用合适的配色方案
colorbar;  % 添加颜色条
set(gca, 'YTick', 1:3, 'YTickLabel', awardLabels);  % 设置 Y 轴标签
set(gca, 'XTick', 1:71, 'XTickLabel', regionLabels);  % 设置 X 轴标签
xtickangle(90);  % X 轴标签旋转90度，避免重叠
title('ESP');  % 设置标题

% 绘制第三幅热力图 (r3)
subplot(3, 1, 3);
imagesc(r3);  % 使用 imagesc 绘制热力图
colormap('parula');  % 使用合适的配色方案
colorbar;  % 添加颜色条
set(gca, 'YTick', 1:3, 'YTickLabel', awardLabels);  % 设置 Y 轴标签
set(gca, 'XTick', 1:71, 'XTickLabel', regionLabels);  % 设置 X 轴标签
xtickangle(90);  % X 轴标签旋转90度，避免重叠
title('KOR');  % 设置标题

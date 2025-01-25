clc
clear
data = readtable('summerOly_athletes.xlsx');
%% 删除不再分析的数据
% 定义要删除的值列表
valuesToDelete = {'AHO', 'BLR', 'BOH', 'CRT', 'EUN', 'LIB', 'MAL', 'NBO', 'NFL', 'RHO', 'ROC', 'RUS', 'SCG', 'TCH', 'UAR', 'UNK', 'URS', 'VNM', 'WIF', 'YUG'};

% 使用 ismember 函数创建一个逻辑数组，标识 NOC 列中是否包含要删除的值
rowsToDelete = ismember(data.NOC, valuesToDelete);

% 使用逻辑索引删除这些行
data = data(~rowsToDelete, :);

%% ANZ：均分至澳大利亚和新西兰
% 找到 NOC 列中为 'ANZ' 的行
anzRows = strcmp(data.NOC, 'ANZ');

% 获取这些行的索引
anzIndices = find(anzRows);

% 确定要分成两部分的数量
numAnzRows = sum(anzRows);
halfNumAnzRows1 = ceil(numAnzRows / 2);
halfNumAnzRows2 = numAnzRows - halfNumAnzRows1;

% 随机打乱索引
randPermIndices = randperm(numAnzRows);

% 设置随机数种子
% rng('default'); % 使用默认随机数生成器状态
% rng(1); % 使用固定的种子值

% 将 'AUS' 和 'NZL' 转换为 cell 数组
ausCell = {'AUS'};
nzlCell = {'NZL'};

% 分配新的 NOC 值
data.NOC(anzIndices(randPermIndices(1:halfNumAnzRows1))) = {'AUS'};
data.NOC(anzIndices(randPermIndices(halfNumAnzRows1+1:end))) = {'NZL'};

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
athletes = data;
save("athletes.mat","athletes")
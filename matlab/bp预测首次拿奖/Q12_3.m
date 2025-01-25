clc;
clear;
close all;

% 加载数据
load('BP_data.mat');
load('input28.mat');

% 数据处理
data = [];
for i = 1:size(BP_data, 1)
    data = [data; BP_data{i, 2}];
end
R = randperm(size(data, 1));
data = data(R, :);

% 划分训练集和测试集
train_ratio = 0.90; % 训练集比例
train1 = data(1:(floor(train_ratio * size(data, 1))), :); % 前90%用于训练
x_train = train1(:, 1:end-1);
y_train = train1(:, end);
test1 = data(((floor(train_ratio * size(data, 1))) + 1):size(data, 1), :); % 后10%用于测试
x_test = test1(:, 1:end-1);
y_test = test1(:, end);

% 数据标准化
[x_train_normalized, mu, sigma] = zscore(x_train);
x_test_normalized = (x_test - mu) ./ sigma;

% 建立网络
net = feedforwardnet([30]); % 隐含层节点数为30
net.divideParam.trainRatio = 80/100; % 训练集比例
net.divideParam.valRatio = 20/100; % 验证集比例
net.divideParam.testRatio = 0/100; % 不使用测试集
net.trainParam.epochs = 5000; % 最大迭代次数
net.trainParam.goal = 0; % 目标精度

% 训练网络
[net, trainInfo] = train(net, x_train_normalized', y_train'); % 训练网络

% 测试效果
test_out = sim(net, x_test_normalized'); % 测试
test_out = test_out';
test_out = round(test_out);
test_out(test_out < 0) = 0;
test_out(test_out > 1) = 1;

% 评价指标
y_true = y_test;
y_pred = test_out;
TP = sum((y_true == 1) & (y_pred == 1));  
TN = sum((y_true == 0) & (y_pred == 0));  
FP = sum((y_true == 0) & (y_pred == 1));  
FN = sum((y_true == 1) & (y_pred == 0));  
accuracy = (TP + TN) / (TP + TN + FP + FN);  
precision = TP / (TP + FP);  
recall = TP / (TP + FN);  
F1 = 2 * (precision * recall) / (precision + recall);  

% 显示评价结果
fprintf('Accuracy: %f\n', accuracy);  
fprintf('Precision: %f\n', precision);  
fprintf('Recall: %f\n', recall);  
fprintf('F1 Score: %f\n', F1);  

% 预测每个国家的数据
predict_set = [];
for c = 1:size(input28, 1) % 遍历每个国家
    Pdata = input28(c, :); % 要预测的数据
    Pdata_normalized = (Pdata - mu) ./ sigma; % 标准化
    y_predict = sim(net, Pdata_normalized'); % 预测
    y_predict = y_predict';
    y_predict(y_predict < 0) = 0;
    y_predict(y_predict > 1) = 1;
    predict_set = [predict_set; y_predict'];
end

% ---- 可视化 ----

% 训练误差曲线
figure;
plot(trainInfo.epoch, trainInfo.perf, 'LineWidth', 1.5);
title('Training Loss Curve');
xlabel('Epochs');
ylabel('Loss');
grid on;

% 测试集预测结果 vs 实际值
figure;
plot(1:length(y_test), y_test, 'bo-', 'LineWidth', 1.5, 'DisplayName', 'True Values'); % 真实值
hold on;
plot(1:length(y_test), test_out, 'rx--', 'LineWidth', 1.5, 'DisplayName', 'Predicted Values'); % 预测值
title('Test Set: True vs Predicted');
xlabel('Sample Index');
ylabel('Value');
legend;
grid on;

% 各国家预测值可视化
figure;
for c = 1:size(input28, 1)
    subplot(ceil(sqrt(size(input28, 1))), ceil(sqrt(size(input28, 1))), c);
    Pdata = input28(c, :); % 当前国家数据
    Pdata_normalized = (Pdata - mu) ./ sigma; % 标准化
    y_predict = sim(net, Pdata_normalized'); % 预测
    y_predict(y_predict < 0) = 0;
    y_predict(y_predict > 1) = 1;

    % 绘制预测值
    bar(y_predict, 'FaceColor', 'blue');
    title(['Country ', num2str(c)]);
    xlabel('Features');
    ylabel('Prediction');
    grid on;
end

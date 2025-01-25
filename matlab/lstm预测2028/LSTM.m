function [T_sim3]=LSTM(data,Pdata,ref)

data1=data;

%% 3.数据处理
nn=size(data,1);%训练数据集大小
numTimeStepsTrain = floor(nn);%nn数据训练 ，N-nn个用来验证
[XTrain,YTrain,XTest,YTest] = shujuchuli(data,numTimeStepsTrain,ref,1);
dataPredict = Pdata;
XTrain=XTrain';
YTrain=YTrain';
dataPredict = dataPredict';

%% 4.定义LSTM结构参数
numFeatures= 6;%输入节点
numResponses = 3;%输出节点
numHiddenUnits = 2000;%隐含层神经元节点数 
 
%构建 LSTM网络 
layers = [sequenceInputLayer(numFeatures) 
 lstmLayer(numHiddenUnits) %lstm函数 
dropoutLayer(0.2)%丢弃层概率 
 reluLayer('name','relu')% 激励函数 RELU 
fullyConnectedLayer(numResponses)
regressionLayer];
 
%% 5.定义LSTM函数参数 
def_options();
%% 6.训练LSTM网络 
options = trainingOptions('adam', 'Plots', 'none'); % 设置不显示训练窗口，如果要训练窗口的话就注释掉这行 
[net,info] = trainNetwork(XTrain,YTrain,layers,options);
% 提取并保存训练损失  
trainingLoss = info.TrainingLoss;
%% 7.建立训练模型 
net = predictAndUpdateState(net,XTrain);
 
%% 8.仿真预测(训练集) 
M = size(XTrain,2);
for i = 1:M
    [net,YPred_1(:,i)] = predictAndUpdateState(net,XTrain(:,i),'ExecutionEnvironment','cpu');%
end
T_sim1 = round(YPred_1);
%% 9.预测(预测集) 
N = size(XTest,2);
[net,YPred_3] = predictAndUpdateState(net,dataPredict,'ExecutionEnvironment','cpu');%
T_sim3 = round(YPred_3); 
T_sim3(T_sim3<0) = 0;
end
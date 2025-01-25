function [XTrain,YTrain,XTest,YTest] = shujuchuli(data,numTimeStepsTrain,ref,step)
sequenceLengthX = ref; % XTrain 参考的序列长度  
sequenceLengthY = step; % YTrain 的序列长度  
dataTrain = data(1:numTimeStepsTrain,:);% 训练样本
dataTest = data(numTimeStepsTrain+1:end,:); %验证样本 

XTrain = dataTrain(:,1:end-3);  
YTrain = dataTrain(:,end-2:end); 
XTest = dataTest(:,1:end-3);  
YTest = dataTest(:,end-2:end); 
end
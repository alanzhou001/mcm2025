clc
clear
close all
load('LSTM_data.mat')
load('input28.mat')
ref = 1;
predict_set = [];
for c = 1:size(LSTM_data,1) %遍历每个国家
    Hdata = LSTM_data{c,2}; %历史的训练数据
    Pdata = input28(c,:); %要预测的数据
    [y_predict]=LSTM(Hdata,Pdata,ref);
    predict_set = [predict_set;y_predict']; 
end

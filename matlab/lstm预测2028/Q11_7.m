clc
clear
close all
pre = readtable("95个城市预测结果.xlsx");
for i = size(pre,1):-1:1
    if pre.Total(i)==0
        pre(i,:) = [];
    end
end
pre_sorted = sortrows(pre, 'Gold', 'descend');
clc
clear
close all
programs = xlsread("programs.xlsx");
load("medal.mat")
load("athletes_times.mat")

Country = unique(medal.NOC); %所有国家

X = programs(:,2:end);

YSET = {}; %储存用的表
for c=1:size(Country,1) %遍历每一个国家
    nowNOC = Country{c}; %当前要查找的国家
    for i=1:size(programs,1) % 去找每个年份的获奖情况
        year = programs(i,1);
        NOC_medal = medal(strcmp(medal.NOC, nowNOC) & medal.Year == year,{'Gold','Silver','Bronze'}); % 提取奖牌信息
        if ~isempty(NOC_medal)
            YSET{c,1}(i,:) =  table2array(NOC_medal(1,:));
        else
            YSET{c,1}(i,:) = [0 0 0];
        end
    end
end

R = {}; %储存相关性结果用的表
for c=1:size(Country,1) %遍历每一个国家
    for e = 1:size(X,2) %遍历每个项目
        for p =1:size(YSET{c,1},2) %遍历每个奖项
            x = X(:,e);
            y = YSET{c,1}(:,p);
            % 下面删掉没有参赛的年份
            %             no_record = [];
            %             for i=1:size(programs,1)
            %                 year = programs(i,1);
            %                 C_p = athletes((strcmp(athletes.NOC, Country{c}) & athletes.Year == year),:); %当前期的参赛表
            %                 if isempty(C_p) %如果没有参赛
            %                     no_record = [no_record i];
            %                 end
            %             end
            %             x(no_record,:) = [];
            %             y(no_record,:) = [];
%             for i=size(x,1):-1:1
%                 if x(i,1)==0 && y(i,1)==0
%                     x(i,:) = [];
%                     y(i,:) = [];
%                 end
%             end
            if isempty(x)||isempty(y)
                rho =  0;
            else
                rho = corr(x, y, 'Type', 'Spearman');
                if isnan(rho)
                    rho =  0;
                end
            end
            R{c,1}(p,e) = rho;
        end
    end
end

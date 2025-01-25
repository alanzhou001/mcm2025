% Data
data = [
   37.0015 36.7514 36.5636;
   32.9158 34.4654 36.6576;
   32.9158 34.4654 36.6576
];

figure
h = bar3(data, 0.5); % 0.5 controls bar width

% Custom pastel colors
colors = [
   246,189,196; % Pastel pink
   194,232,206; % Pastel green  
   198,219,239  % Pastel blue
]/255;

% Apply colors to bars
for i = 1:length(h)
   set(h(i), 'FaceColor', colors(i,:))
end

xlabel('Medal Type')
ylabel('Country')
zlabel('Count')
xticklabels({'Gold', 'Silver', 'Bronze'})
yticklabels({'CHN', 'ESP', 'KOR'})
title('Olympic Medal Predictions')
grid on

view(45, 30)
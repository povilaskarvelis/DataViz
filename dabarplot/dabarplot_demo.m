% dabarplot_demo a few examples of dabarplot functionality 
%
% Povilas Karvelis 
% 13/06/2020
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
rng('default')

% data in a numreic array (+ grouping indices)
data1 = [3,4,5,6] + [randn([30,4]); randn([30,4]);...
                     randn([30,4]);randn([30,4])];
group_inx = [ones(1,30), 2.*ones(1,30), 3.*ones(1,30), 4.*ones(1,30)];

% full data in a cell array 
data2{1} = [1,2,3,4] + randn([30,4]); % Humans
data2{2} = [1,2,3,4] + randn([30,4]); % Dogs
data2{3} = [1,2,3,4] + randn([30,4]); % God
data2{4} = [1,2,3,4] + randn([30,4]); % Potato

% data in a cell array with one datapoint per group per condition
data3(1,:) = mean(data2{1});
data3(2,:) = mean(data2{2});
data3(3,:) = mean(data2{3});
data3(4,:) = mean(data2{4}); 

% convert means to percentages (averaged across groups)
datap = 100*data3./sum(data3);

group_names = {'Humans', 'Dogs' , 'God', 'Potato'};
condition_names = {'Water', 'Land', 'Moon', 'Hyperspace'};

% an alternative color scheme for some plots
c =  [0.45, 0.80, 0.69;...
      0.98, 0.40, 0.35;...
      0.55, 0.60, 0.79;...
      0.90, 0.70, 0.30];  
   
figure('Name', 'dabarplot_demo','WindowStyle','docked');

% default bar plots for one group and three conditions 
subplot(2,3,1)
h = dabarplot(data1,'groups',group_inx(1:30));

% non-filled grouped bar plots for two groups
subplot(2,3,2)
h = dabarplot(data1(1:60,:),'groups',group_inx(1:60),'errorbars','WSE',...
    'xtlabels', condition_names,'fill',0,'legend',group_names(1:2));
ylabel('Performance');
xl = xlim; xlim([xl(1), xl(2)+1]);  % make more space for the legend
set(gca,'FontSize',11);

% filled bar plots, different color scheme, standard deviation error bars
subplot(2,3,3)
h = dabarplot(data1(:,1:3),'groups',group_inx(1:90),'errorbars','SD',...
    'xtlabels', condition_names,'legend',group_names(1:3),'color',c,...
    'errorhats',0);
ylabel('Performance');
xl = xlim; xlim([xl(1), xl(2)+1]);  % make more space for the legend
set(gca,'FontSize',11);

% bar plots with a data scatter on top, rotated horizontally
subplot(2,3,4)
h = dabarplot(data1,'groups',group_inx,...
    'xtlabels', condition_names,'errorbars',0,...
    'scatter',1,'scattersize',15,'scatteralpha',0.5,...
    'barspacing',0.8,'legend',group_names); 
ylabel('Performance');
yl = ylim; ylim([yl(1), yl(2)+2]);  % make more space for the legend
set(gca,'FontSize',11);
camroll(-90)

% stacked bar plots and added numbers to emphasize condition differences
subplot(2,3,5)
h = dabarplot(data3,'group',[1,2,3,4],'xtlabels', condition_names,...
    'colors',c,'bartype','stacked','numbers',1,'round',1); 
ylabel('Performance');
legend([h.br(1,:)],group_names);    % add the legend manually
xl = xlim; xlim([xl(1), xl(2)+1]);  % make more space for the legend
ylim([0 18]); set(gca,'FontSize',11);

% stacked plot and added numbers to emphasize group differences
subplot(2,3,6)
h = dabarplot(datap,'group',[1,2,3,4],'xtlabels', condition_names,...
    'colors',c,'scattersize',16,'bartype','stacked','numbers',2, ...
    'round',0); 
ylabel('Contribution (%)');
legend([h.br(1,:)],group_names);    % add the legend manually
xl = xlim; xlim([xl(1), xl(2)+1]);  % make more space for the legend
ylim([0 100]); set(gca,'FontSize',11);







% daviolinplot_demo a few examples of daviolinplot functionality 
%
% Povilas Karvelis
% 05/05/2020
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
rng('default')

% data in a cell array 
data1{1} = randn([30,1]);   % Humans
data1{2} = randn([40,1]);   % Dogs
data1{3} = randn([50,1]);   % God

% data in a matrix (+ grouping indices)
data2 = [randn([30,4]); randn([30,4]);...
         randn([30,4]); randn([30,4])];
group_inx = [ones(1,30), 2.*ones(1,30) 3.*ones(1,30) 4.*ones(1,30)];

% new data in a cell array with group differences 
data3{1} = randn([20,3]) + (0:0.5:1);    % Humans
data3{2} = randn([20,3]) - (2:2:6);      % Dogs

group_names = {'Humans', 'Dogs' , 'God', 'Potato'};
condition_names = {'Water', 'Land', 'Moon', 'Hyperspace'};

% an alternative color scheme for some plots
c =  [0.45, 0.80, 0.69;...
      0.98, 0.40, 0.35;...
      0.55, 0.60, 0.79;...
      0.90, 0.70, 0.30]; 
  
figure('Name', 'daviolinplot_demo','WindowStyle','docked');

% default half-violin + boxplots for three groups and one condition 
subplot(3,3,1)
h = daviolinplot(data2(:,1),'groups',group_inx(1:90));

% adding jittered scattered data same color boxplots for 2x2 data
subplot(3,3,2)
h = daviolinplot(data2(:,1:2),'groups',group_inx(1:60),'outsymbol','k+',...
    'boxcolors','same','scatter',1,'jitter',1,'xtlabels', condition_names,...
    'legend',group_names(1:2));
ylabel('Performance');
xl = xlim; xlim([xl(1)-0.1, xl(2)+0.2]); % make more space for the legend
set(gca,'FontSize',10);

% full violin plots with white embedded boxplots for 3x2 data
subplot(3,3,3)
h = daviolinplot(data2(:,1:2),'groups',group_inx(1:90),...
    'xtlabels', condition_names,'violin','full',...
    'boxcolors','w'); 
ylabel('Performance');
xl = xlim; xlim([xl(1), xl(2)+0.25]);    % make space for the legend
legend([h.ds(1,:)],group_names(1:3));    % add the legend manually
set(gca,'FontSize',10);

% different color scheme, different position of boxplots and scatter
subplot(3,2,3)
h = daviolinplot(data2(:,1:2),'groups',group_inx(1:90),'outsymbol','k+',...
    'xtlabels', condition_names,'color',c,'scatter',2,'jitter',1,...
    'box',1,'boxcolors','same','scattercolors','same',...
    'boxspacing',1.1,'legend',group_names(1:3));
ylabel('Performance');
xl = xlim; xlim([xl(1)-0.1, xl(2)+0.2]); % make more space for the legend
set(gca,'FontSize',10);

% half-violin plots combined with dotplots keeping the colors the same
subplot(3,2,4)
h = daviolinplot(data2(:,1:2),'groups',group_inx(1:90),...
    'xtlabels', condition_names,'box',0,'boxcolors','k',...
    'boxspacing',1.2,'scatter',2,'jitter',2,'scattercolors','same',...
    'scattersize',14,'bins',12,'legend',group_names(1:3)); 
ylabel('Performance');
xl = xlim; xlim([xl(1)-0.1, xl(2)+0.2]); % make more space for the legend
set(gca,'FontSize',10);

% half-violin plots with black boxplots and dotplots
subplot(3,2,5)
h = daviolinplot(data1,'colors',c,'boxcolors','k','outliers',0,...
    'box',3,'boxwidth',0.8,'scatter',2,'scattersize',35,'jitter',2,...
    'xtlabels', group_names(1:3)); 
ylabel('Performance');
xl = xlim; xlim([xl(1)-0.2, xl(2)+0.2]); % make more space for the legend
set(gca,'FontSize',10);

% half-violin plots with white boxplots, jittered scatter and linkline 
subplot(3,2,6)
h = daviolinplot(data3,'groups',group_inx(1:90),'colors',c,'box',3,...
    'boxcolor','w','scatter',2,'jitter',1,'scattercolor','same',...
    'scattersize',10,'scatteralpha',0.7,'linkline',1,...
    'xtlabels', condition_names,...
    'legend',group_names(1:2)); 
ylabel('Performance');
xl = xlim; xlim([xl(1)-0.1, xl(2)+0.3]); % make more space for the legend
set(h.sc,'MarkerEdgeColor','none');      % remove marker edge color
set(gca,'FontSize',10);


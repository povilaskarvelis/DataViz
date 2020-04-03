%DABOXPLOT_DEMO a few examples of DABOXPLOT functionality 
%
% Povilas Karvelis <karvelis.povilas@gmail.com>
% 15/04/2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rng('default')

% data in a cell array 
data1{1} = randn([60,4]); % Humans
data1{2} = randn([60,4]); % Dogs
data1{3} = randn([60,4]); % God
data1{4} = randn([60,4]); % Potato

% data in a matrix (+ grouping indices)
data2 = [randn([20,4]); randn([20,4]);...
         randn([20,4]); randn([20,4])];
group_inx = [ones(1,20), 2.*ones(1,20) 3.*ones(1,20) 4.*ones(1,20)];

group_names = {'Humans', 'Dogs' , 'God', 'Potato'};
condition_names = {'Water', 'Land', 'Moon', 'Hyperspace'};

% an alternative color scheme for some plots
c =  [0.45, 0.80, 0.69;...
      0.98, 0.40, 0.35;...
      0.55, 0.60, 0.79;...
      0.90, 0.70, 0.30];
  
figure('Name', 'daboxplot_demo','WindowStyle','docked');
pause(0.5); % prevents a glitch in xlim; don't ask me why

% the default style
subplot(3,2,1)
handles = daboxplot(data1);
xticklabels(condition_names);
ylabel('Performance');
xl = xlim; xlim([xl(1), xl(2)+1]); % make space for the legend
legend([handles.bx(1,:)],group_names)
set(gca,'box','off'); ylim([-4 4])

% non-filled boxplots
subplot(3,2,2)
handles = daboxplot(data2,'groups',group_inx,...
    'conditions', condition_names,'fill',0);
ylabel('Performance');
xl = xlim; xlim([xl(1), xl(2)+1]); % make space for the legend
legend([handles.bx(1,:)],group_names)
set(handles.wh,'Color',[0.2 0.6 0.2],'LineWidth',1.5); % customize whiskers

% transparent boxplots with no whiskers and jittered datapoints underneath
subplot(3,2,3)
handles = daboxplot(data1,'scatter',2,'whiskers',0,...
    'jitter',1,'boxalpha',0.7,'conditions', condition_names); 
ylabel('Performance');
xl = xlim; xlim([xl(1), xl(2)+1]); % make space for the legend
legend([handles.bx(1,:)],group_names)

% different color scheme, shorter whiskers and outliers only
subplot(3,2,4)
handles = daboxplot(data2,'groups',group_inx,...
    'conditions', condition_names,'colors',c,'fill',0,'whiskers',2,...
    'jitter',1,'outliers',1,'scattersize',30); 
ylabel('Performance');
xl = xlim; xlim([xl(1), xl(2)+1]); % make space for the legend
legend([handles.bx(1,:)],group_names)
set(handles.m,'Color','k','LineWidth',1.5); % customize median lines


% different color scheme, no whiskers, no jitter, data scattered underneath
subplot(3,2,5)
handles = daboxplot(data2,'colors',c,'groups',group_inx,...
    'scatter',2,'whiskers',0,'conditions', condition_names); 
ylabel('Performance');
xl = xlim; xlim([xl(1), xl(2)+1]); % make space for the legend
legend([handles.bx(1,:)],group_names)

% different color scheme, data scattered underneath as small dots
subplot(3,2,6)
handles = daboxplot(data1,'conditions', condition_names,'colors',c,...
    'whiskers',1,'fill',1,'scatter',2,'jitter',1,'scattersize',15,...
    'outliers',1,'boxalpha',0.7); 
ylabel('Performance');
xl = xlim; xlim([xl(1), xl(2)+1]); % make space for the legend
legend([handles.bx(1,:)],group_names)
set(handles.wh,'Color','none'); % customize whiskers


% TIP: to make the plots vertical use camroll(-90)







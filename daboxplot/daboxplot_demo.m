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
data2 = [randn([30,4]); randn([30,4]);...
         randn([30,4]); randn([30,4])];
group_inx = [ones(1,30), 2.*ones(1,30) 3.*ones(1,30) 4.*ones(1,30)];

group_names = {'Humans', 'Dogs' , 'God', 'Potato'};
condition_names = {'Water', 'Land', 'Moon', 'Hyperspace'};

% an alternative color scheme for some plots
c =  [0.45, 0.80, 0.69;...
      0.98, 0.40, 0.35;...
      0.55, 0.60, 0.79;...
      0.90, 0.70, 0.30];  
  
figure('Name', 'daboxplot_demo','WindowStyle','docked');
pause(0.5); % prevents a glitch in xlim; don't ask me why


% filled boxplots with no outliers
subplot(3,2,1)
h = daboxplot(data1,'outliers',0,'legend',group_names);
xticklabels(condition_names);
ylabel('Performance');
xl = xlim; xlim([xl(1), xl(2)+1]);    % make more space for the legend
set(h.lg,'FontSize',9);               % make the legend bigger
ylim([-4 4])


% non-filled boxplots, different color scheme and cutomized medians
subplot(3,2,2)
h = daboxplot(data2,'groups',group_inx,'colors',c,...
    'conditions', condition_names,'fill',0,'legend',group_names);
ylabel('Performance');
xl = xlim; xlim([xl(1), xl(2)+1]);    % make more space for the legend
set(h.m,'Color','k','LineWidth',1.5); % customize median lines
set(h.lg,'FontSize',9);               % make the legend bigger


% transparent boxplots with no whiskers and jittered datapoints underneath
subplot(3,2,3)
h = daboxplot(data1,'scatter',2,'whiskers',0,'boxalpha',0.7,...
    'conditions', condition_names); 
ylabel('Performance');
xl = xlim; xlim([xl(1), xl(2)+1]);            % make space for the legend
legend([h.bx(1,:)],group_names,'FontSize',9); % add the legend manually

% different color scheme, a color flip, different outlier symbol
subplot(3,2,4)
h = daboxplot(data2,'groups',group_inx,'conditions', condition_names,...
    'colors',c,'fill',0,'whiskers',0,'scatter',2,'symbol','k*',...
    'outliers',1,'scattersize',16,'flipcolors',1,'boxspacing',1.2,...
    'legend',group_names); 
ylabel('Performance');
xl = xlim; xlim([xl(1), xl(2)+1]); % make more space for the legend
set(h.lg,'FontSize',9);            % make the legend bigger


% different color scheme, data scattered on top
subplot(3,2,5:6)
h = daboxplot(data2,'groups',group_inx,...
    'conditions', condition_names,'colors',c,'whiskers',0,'fill',1,...
    'scatter',1,'scattersize',15,'outliers',1,'scatteralpha',0.5,...
    'boxspacing',0.8,'legend',group_names); 
ylabel('Performance');
xl = xlim; xlim([xl(1), xl(2)+0.5]); % make space for the legend
set(h.lg,'FontSize',9);              % make the legend bigger


% TIP: to make the plots vertical use camroll(-90)







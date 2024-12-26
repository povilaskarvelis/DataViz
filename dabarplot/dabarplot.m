function h = dabarplot(Y,varargin)
% dabarplot draws neat bars for multiple groups and multiple conditions 
%
% Description:
%
%   Creates bars organized by condition and colored by group. Does not
%   require the groups to be of the same size. Has some essential options
%   (see below) and exports the main handles for further customization. 
%
% Syntax:
%
%   dabarplot(Y)
%   dabarplot(Y,param,val,...)
%   h = dabarplot(Y)
%   h = dabarplot(Y,param,val,...)
%
% Input Arguments:
%
%   Y - data input (matrix or cell array) containing all conditions and all
%   groups. If Y is a matrix, each column has to correspond to different
%   condition, while the groups need to be specified in 'groups' vector.
%   If Y is a cell array, each cell has to contain data matrices for each 
%   group (columns being different conditions). In such case, the grouping 
%   is done automatically based on the cell structure.   
%
% Optional Input Parameter Name/Value Pairs:
%
%   NAME              VALUE
%
%   'groups'          A vector containing grouping variables. By default
%                     assumes a single group for a matrix data input. 
%
%   'fill'            0 - non-filled bars (contrours only)
%                     1 - bars filled with color (default)
%
%   'colors'          The RGB matrix for bar colors of different groups
%                     (each row corresponding to a different group). If
%                     bar plots are filled, these are the fill colors with 
%                     the edges being black. If bar plots are not filled,
%                     these colors are used for edges. 
%                     Default colors: default matlab colors. 
%   
%   'errorbars'       Draws errorbars on each of the bars
%                     'SE'  - standard error of the mean (default)
%                     'WSE' - within-subject error bars  
%                     'SD'  - standard deviation 
%                     'CI'  - 95% confidence interval
%                      0    - no errorbars
%
%   'errorhats'       Modifies the visual appearance of the errorbars
%                     0 - no hats on error bars
%                     1 - add hats to error bars (default)
%                       
%   'scatter'         0 - no datta scatter (deffault)
%                     1 - on top of the bar plot 
%                     2 - underneath the bar plot 
%
%   'scattersize'     Size of the scatter markers. Default: 15
%
%   'scattercolors'   Colors for the scattered data: {face, edge}
%                     Default: {'k','w'}
%
%   'scatteralpha'    Transparency of scattered data (between 0 and 1)
%                     Default: 1 (completely non-transparent)
%
%   'jitter'          0 - do not jitter scattered data 
%                     1 - jitter scattered data (default)
% 
%   'outliers'        Highlights the outliers in the plot. The outliers 
%                     are values below Q1-1.5*IQR and above Q3+1.5*IQR.
%                     0 - do not highlight outliers  
%                     1 - highlight outliers (default)
%
%   'symbol'          Symbol and color for highlighting outliers.
%                     Default: 'rx' (red crosses).
%
%   'baralpha'        Bar transparency (between 0 and 1)
%                     Default: 1 (completely non-transparent)
%
%   'barspacing'      Scales spacing between bars in the same condition. 
%                     Note that spacing is also dependent on bar width
%                     Default: 1
%
%   'barwidth'        Scales the width of all bars
%                     Default: 1 
%
%   'bartype'         How bars in each condition should be arranged
%                     'grouped'  - side by side (default)
%                     'stacked'  - stacked on top of each other
%
%   'numbers'         Display the values of each bar in numeric form
%                     0 - no numbers (default)
%                     1 - add total numbers for each condition
%                     2 - add numbers for each group when bars are stacked
%
%   'round'           Specifies the rounding if numbers are added. Rounds 
%                     to the number of specified digits to the right of the 
%                     decimal point
%                     Default: 0 
%
%   'xtlabels'        Xtick labels (a cell of chars) for conditions. If
%                     there is only 1 condition and multiple groups, then 
%                     xticks and xtlabels will automatically mark different
%                     groups.
%                     Default: conditions/groups are numbered in the input 
%                     order
%
%   'legend'          Names of groups (a cell) for creating a legend
%                     Default: no legend
%
%
% Output Arguments:
%
%   h - a structure containing handles for further customization of the 
%   produced plot:
%       cpos - condition positions
%       gpos - group positions
%       
%       graphics objects:
%       br - bars
%       sc - scattered data markers
%       ot - outlier markers
%       er - error bars
%       nm - the numbers added to stacked bars
%       lg - legend
%
%
% For examples have a look at dabarplot_demo.m
% Also see: daviolinplot.m and daboxplot.m
%
% Povilas Karvelis
% 13/06/2020
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


h = struct;
p = inputParser;

% specify default options
addParameter(p, 'groups', []);
addParameter(p, 'fill', 1); 
addParameter(p, 'colors', get(gca,'colororder'));
addParameter(p, 'errorbars', 'SE');
addParameter(p, 'errorhats', 1);
addParameter(p, 'scatter', 0); 
addParameter(p, 'scattersize', 15)
addParameter(p, 'scattercolors', {'k','w'}); 
addParameter(p, 'condcolors', 0);
addParameter(p, 'scatteralpha', 1); 
addParameter(p, 'jitter', 1);
addParameter(p, 'mean', 1);
addParameter(p, 'outliers', 0); 
addParameter(p, 'symbol', 'rx'); 
addParameter(p, 'baralpha', 1);
addParameter(p, 'barspacing', 1);
addParameter(p, 'barwidth', 1);
addParameter(p, 'bartype', 'grouped');
addParameter(p, 'numbers', 0);
addParameter(p, 'round', 0);
addParameter(p, 'xtlabels', []);
addParameter(p, 'legend', []);

% parse the input options
parse(p, varargin{:});
confs = p.Results;    

% get group indices and labels
if ~isempty(confs.groups)
    [Gi,Gn] = findgroups(confs.groups);
    num_groups = numel(Gn);
end

% find the number of groups
if iscell(Y)    
    num_groups = numel(Y);
    
    y = []; Gi = [];    
    for g = 1:num_groups
        y = [y; Y{g}];
        Gi = [Gi; g*ones(size(Y{g},1),1)];
    end   
       
    Y = y; % replace the cell with a data array
    
elseif ismatrix(Y)     
    % assume 1 group if none are specified
    if isempty(confs.groups)
       Gi = ones(size(Y,1),1);
       num_groups = 1;
    end
end

% find condition positions
if any(size(Y)==1)
    Y = Y(:);
    cpos = 1;
else
    cpos = 1:size(Y,2);
end
num_locs = numel(cpos);

% use condition positions to scale spacings
gpos = [];
if num_locs==1
    if strcmp(confs.bartype,'grouped')
        gpos      = (1:num_groups)';
        cpos      = gpos;
    elseif strcmp(confs.bartype,'stacked')
        for g = 1:num_groups
            gpos = [gpos;cpos];
        end
    end    
    bar_width = 4/5*confs.barwidth;
else    
    if num_groups==1
        gpos      = cpos;
        bar_width = 4/5*confs.barwidth;
    else
        % set group positions for each group
        if strcmp(confs.bartype,'grouped')
            bar_width = (2/3)/(num_groups+1)*confs.barwidth;  % bar width 
            loc_sp    = (bar_width/3)*confs.barspacing; % local spacing of bars
            for g = 1:num_groups
                gpos = [gpos; cpos + (g-(num_groups+1)/2)*(bar_width + loc_sp)];
            end
        elseif strcmp(confs.bartype,'stacked')
            for g = 1:num_groups
                gpos = [gpos;cpos];
            end
            bar_width = 4/5*confs.barwidth;
        end

    end
end

h.gpos = gpos;
h.cpos = cpos; 

% if the bars are stacked disable data scatter
if ~strcmp(confs.bartype,'grouped')
    confs.scatter   = 0;
    confs.jitter    = 0;
    confs.outiers   = 0;
end

% loop over groups
for g = 1:num_groups 
    
    % get means of each condition
    means   = nanmean(Y(Gi==g,:),1);   
    
    if ischar(confs.errorbars) && strcmp(confs.bartype,'grouped')
        if confs.errorbars == "WSE"
            Yad = Y(Gi==g,:) - repmat(nanmean(Y(Gi==g,:), 2), [1, size(Y(Gi==g,:),2)]);
            er  = nanstd(Yad)/sqrt(size(Y(Gi==g,:),1));
        elseif confs.errorbars == "SE"
            er = nanstd(Y(Gi==g,:),[],1)/sqrt(size(Y(Gi==g,:),1));
        elseif confs.errorbars == "SD"
            er = nanstd(Y(Gi==g,:),[],1);
        end    
    end
            
    % create coordinates for drawing bars
    if strcmp(confs.bartype,'grouped')

        yb = reshape([zeros(1,length(means)); zeros(1,length(means))], 1, []);
        yt = reshape([means; means], 1, []);
    
        x1 = [gpos(g,:) - bar_width/2; gpos(g,:) - bar_width/2];
        x2 = [gpos(g,:) + bar_width/2; gpos(g,:) + bar_width/2];
    
        bar_ycor  = [yt; yb];        
        bar_xcor  = reshape([x1; x2],2,[]);  

    elseif strcmp(confs.bartype,'stacked')
    
        % use 0s as the bottom for the first group
        if g == 1
            yt(g,:) = reshape([means; means], 1, []);
            yb(g,:) = reshape([zeros(1,length(means)); zeros(1,length(means))], 1, []);
        else 
            % make the stacking work in case there are negative values
            ni = find(means<0);

            ytn = max([yt; yb]); 
            ybn = min([yt; yb]);
            
            % redefine where the 'top' is for negative values
            if ni>0
                ytn([ni, ni+1]) = ybn([ni, ni+1]);
            end            

            yt(g,:) = ytn  + reshape([means; means], 1, []);
            yb(g,:) = ytn;
        end
    
        x1 = [gpos(g,:) - bar_width/2; gpos(g,:) - bar_width/2];
        x2 = [gpos(g,:) + bar_width/2; gpos(g,:) + bar_width/2];
    
        bar_ycor  = [yt(g,:); yb(g,:)];        
        bar_xcor  = reshape([x1; x2],2,[]); 
    end

    % spefify coordinates for drawing error bars    
    hat_xcor = [gpos(g,:) - bar_width/4; gpos(g,:) + bar_width/4];    
    whi_xcor = [gpos(g,:); gpos(g,:)];   
    
    % draw one bar at a time
    for k = 1:num_locs
        
        data_vals = Y(Gi==g,k); % data for a single bar
        
        if ischar(confs.errorbars) && strcmp(confs.bartype,'grouped')
            whi_ycor(:,1,k) = [means(k)-er(k), means(k)]; % lower whisker        
            whi_ycor(:,2,k) = [means(k)+er(k), means(k)]; % upper whisker
        end
        
        % jitter or not
        if confs.jitter==1
            xdata =  gpos(g,k).*ones(numel(Y(Gi==g,k)),1) + ...
                (bar_width/3).*(0.5 - rand(numel(Y(Gi==g,k)),1));
        elseif confs.jitter==0
            xdata = gpos(g,k).*ones(numel(Y(Gi==g,k)),1);
        end        
                
        % index values for each bar
        wk = (1:2)+2*(k-1);
        Xx = bar_xcor(1:2,wk); 
        Yy = bar_ycor(1:2,wk); 
        
        % color conditions instead of groups
        if confs.condcolors==1
            gk = k;
        else
            gk = g;
        end

        % filled or not filled bars
        if confs.fill==0 
                        
            % no fill bar
            h.br(k,g) = line([Xx(:,1)' Xx(1,:) Xx(:,2)' Xx(2,:)],...
                [Yy(:,1)' Yy(1,:) Yy(:,2)' Yy(2,:)],...
                'color',confs.colors(gk,:),'LineWidth',1.5); 
            hold on;            
            
        elseif confs.fill==1
            % bar filled with color 
            h.br(k,g) = fill([Xx(:,1)' Xx(1,:) Xx(:,2)' Xx(2,[2,1])],...
                 [Yy(:,1)' Yy(1,:) Yy(:,2)' Yy(2,:)],confs.colors(gk,:));            
            set(h.br(k,g),'FaceAlpha',confs.baralpha); 
            hold on;
        end  
       
        ox = data_vals>max(data_vals); % default - no outliers
        
        % draw outliers
        if confs.outliers==1          
            ox = data_vals<whi_ycor(1,1,k) | data_vals>whi_ycor(1,2,k);
            h.ot(k,g) = scatter(xdata(ox),data_vals(ox),confs.scattersize,...
                confs.symbol);            
        end        
        
        % draw error bars
        if ischar(confs.errorbars) && strcmp(confs.bartype,'grouped')
            if confs.errorhats==1
                h.wh(k,g,:) = plot(whi_xcor(:,k),whi_ycor(:,1,k),'k-',... 
                    hat_xcor(:,k),[whi_ycor(1,1,k) whi_ycor(1,1,k)],'k-',... 
                    whi_xcor(:,k),whi_ycor(:,2,k),'k-',... 
                    hat_xcor(:,k),[whi_ycor(1,2,k) whi_ycor(1,2,k)],'k-',... 
                    'LineWidth',1);   
            elseif confs.errorhats==0
                h.wh(k,g,:) = plot(whi_xcor(:,k),whi_ycor(:,1,k),'k-',...
                    whi_xcor(:,k),whi_ycor(:,2,k),'k-',...
                    'LineWidth',1); 
            end
        end 

        % scatter on top of the bar plots
        if confs.scatter==1 || confs.scatter==2           
            h.sc(k,g) = scatter(xdata(~ox),data_vals(~ox),...
                confs.scattersize,...
                'MarkerFaceColor', confs.scattercolors{1},...
                'MarkerEdgeColor', confs.scattercolors{2},...
                'MarkerFaceAlpha', confs.scatteralpha); 
            hold on;    
        end        
        
    end  

    % add number values on top of the stacked bars
    if confs.numbers == 2 && strcmp(confs.bartype,'stacked')
       h.nm{g} = text(cpos,...
           mean(bar_ycor(:,1:2:end)),string(round(means,confs.round)),...
           'HorizontalAlignment', 'center',"FontSize",11);
    end
        
    % put scattered data underneath bar plots
    if confs.scatter==2
        uistack(h.sc(:,g),'bottom')
    end   
    
end

% add numbers of total values for each condition 
if confs.numbers == 1
    vv = max([yt(end,1:2:end); yb(end,1:2:end)]); % value vector
    lv = 0.05*max(vv) + vv;                       % value location
    h.nm = text(cpos,...
       lv,string(round(vv,confs.round)),...
       'HorizontalAlignment', 'center',"FontSize",11);
end

% add a legend based on box colors
if ~isempty(confs.legend)
    h.lg = legend(h.br(1,:),confs.legend);
end

% set ticks and labels
set(gca,'XTick',cpos,'XTickLabels',cpos,'box','off');
if ~isempty(confs.xtlabels)
    set(gca,'XTickLabels',confs.xtlabels,'XTick',cpos);
end  

xlim([gpos(1)-bar_width, gpos(end)+bar_width]); % adjust x-axis margins

end
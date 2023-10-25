function h = daboxplot(Y,varargin)
% daboxplot draws neat boxplots for multiple groups and multiple conditions 
%
% Description:
%
%   Creates boxplots organized by condition and colored by group. Supports 
%   various options such as scatter, transparency, outliers, mean and 
%   group linking lines, scaling, etc, to maximize data readability. See 
%   daboxplot_demo. for examples of the use and functionality.  
%
% Syntax:
%
%   daboxplot(Y)
%   daboxplot(Y,param,val,...)
%   h = daboxplot(Y)
%   h = daboxplot(Y,param,val,...)
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
%   'fill'            0 - non-filled boxplots (contrours only)
%                     1 - boxplots filled with color (default)
%
%   'colors'          The RGB matrix for box colors of different groups
%                     (each row corresponding to a different group). If
%                     boxplots are filled, these are the fill colors with 
%                     the edges being black. If boxplots are not filled,
%                     these colors are used for edges. These colors can be 
%                     also used for scatter data instead (see 'flipcolors')
%                     Default colors: default matlab colors
%   
%   'whiskers'        Draws whiskers to show min and max data values after 
%                     disregarding the outliers (see outlier description)
%                     0 - no whiskers
%                     1 - draw whiskers (default)                     
%
%   'scatter'         0 - no datta scatter (deffault)
%                     1 - on top of the boxplot 
%                     2 - underneath the boxplot
%
%   'scattersize'     Size of the scatter markers. Default: 15
%
%   'scattercolors'   Colors for the scattered data: {face, edge}
%                     Default: {'k','w'}
%
%   'flipcolors'      Will flip the colors of scatter points and boxplots
%                     0 - boxplots colored by group (default)
%                     1 - scatter is colored by group
%
%   'scatteralpha'    Transparency of scattered data (between 0 and 1)
%                     Default: 1 (completely non-transparent)
%
%   'jitter'          0 - do not jitter scattered data 
%                     1 - jitter scattered data (default)
%
%   'mean'            0 - do not mark the mean (default)
%                     1 - mark the mean with a dotted line
% 
%   'outliers'        Highlights the outliers in the plot. The outliers 
%                     are values below Q1-1.5*IQR and above Q3+1.5*IQR.
%                     0 - do not highlight outliers  
%                     1 - highlight outliers (default)
%
%   'outfactor'       Multiple of the interquartile range used to find
%                     outliers: below Q1-outfactor*IQR and above 
%                     Q3+outfactor*IQR
%                     Default: 1.5
%
%   'outsymbol'       Symbol and color for highlighting outliers.
%                     Default: 'rx' (red crosses).
%
%   'boxalpha'        Boxplot transparency (between 0 and 1)
%                     Default: 1 (completely non-transparent)
%
%   'boxspacing'      A real number to scale spacing between boxes in the 
%                     same condition. Note that negative values result in 
%                     partially overlapping boxes within the same condition
%                     Default: 1
%
%   'boxwidth'        A real number to scale the width of all boxes. Note 
%                     that this also controls the spacing between different 
%                     conditions (while spacings in the same condition are 
%                     controlled by 'boxspacing')                      
%                     Default: 1
%
%   'linkline'        Superimposes lines linking boxplots across conditions
%                     for each group. Helps to see more clearly possible 
%                     interaction effects between conditions and groups.
%                     0 - no dash lines (default)
%                     1 - dash lines
%
%   'withinlines'     Draws a line between each pair of data points in 
%                     paired datasets. Meant to be used only when plotting
%                     one group.
%                     0 - no lines (default)
%                     1 - lines
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
%   h - a structure containing handles for further customization of
%   the produced plot:
%       cpos - condition positions
%       gpos - group positions
%       
%       graphics objects:
%       bx - boxplot box 
%       md - median line
%       mn - mean line
%       sc - scattered data markers
%       ot - outlier markers
%       wh - whiskers 
%       ln - line linking boxplots 
%       lg - legend
%
%
% For examples have a look at daboxplot_demo.m
% Also see: daviolinplot.m and dabarplot.m
%
%
% Povilas Karvelis
% 15/04/2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = struct;
p = inputParser;

% specify default options
addOptional(p, 'groups', []);
addOptional(p, 'fill', 1); 
addOptional(p, 'colors', get(gca,'colororder'));
addOptional(p, 'whiskers', 1);
addOptional(p, 'scatter', 0); 
addOptional(p, 'scattersize', 15)
addOptional(p, 'scattercolors', {'k','w'}); 
addOptional(p, 'flipcolors', 0);
addOptional(p, 'scatteralpha', 1); 
addOptional(p, 'jitter', 1);
addOptional(p, 'mean', 0);
addOptional(p, 'outliers', 1); 
addOptional(p, 'outfactor', 1.5);
addOptional(p, 'outsymbol', 'rx'); 
addOptional(p, 'boxalpha', 1);
addOptional(p, 'boxspacing', 1);
addOptional(p, 'boxwidth', 1);
addOptional(p, 'linkline',0);
addOptional(p, 'withinlines',0);
addOptional(p, 'xtlabels', []);
addOptional(p, 'legend', []);

% parse the input options
parse(p, varargin{:});
confs = p.Results;    

% get group indices and labels
if ~isempty(confs.groups)
    [Gi,Gn,Gv] = grp2idx(confs.groups);
    num_groups = numel(Gv);
end

% find the number of groups
if iscell(Y)    
    num_groups = numel(Y);
    
    y = []; Gi = [];    
    for g = 1:num_groups
        y = [y; Y{g}];
        Gi = [Gi; g*ones(size(Y{g},1),1)];
    end   
       
    % default numbered group labels
    if ~exist('Gn','var')
        for g = 1:num_groups
            Gn{g} = num2str(g);
        end
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
gpos=[];
if num_locs==1
    gpos = (1:num_groups)';
    box_width = 1/3*confs.boxwidth;
    cpos=gpos;
else    
    if num_groups==1
        gpos = cpos;
        box_width = 1/3*confs.boxwidth;
    else
        box_width = (2/3)/(num_groups+1)*confs.boxwidth;  % calculate box width 
        loc_sp = (box_width/3)*confs.boxspacing; % local spacing between boxplots

        % set group positions for each group
        for g = 1:num_groups
            gpos = [gpos; cpos + (g-(num_groups+1)/2)*(box_width + loc_sp)];
        end
    end
end

h.gpos = gpos;
h.cpos = cpos; 

% loop over groups
for g = 1:num_groups 
    
    % get percentiles
    pt = prctile(Y(Gi==g,:),[2 9 25 50 75 91 98]); 
    means = mean(Y(Gi==g,:));
    
    if size(pt,1)==1 pt=pt'; end % for plotting one condition
    
    IQR = (pt(5,:)-pt(3,:));
        
    % create coordinates for drawing boxes
    y25 = reshape([pt(3,:); pt(3,:)], 1, []);
    y75 = reshape([pt(5,:); pt(5,:)], 1, []);

    x1 = [gpos(g,:) - box_width/2; gpos(g,:) - box_width/2];
    x2 = [gpos(g,:) + box_width/2; gpos(g,:) + box_width/2];

    box_ycor = [y75; y25];        
    box_xcor = reshape([x1; x2],2,[]); 
    box_mdcor = reshape([pt(4,:); pt(4,:)], 1, []);
    box_mncor = reshape([means; means], 1, []);
    
    % create coordinates for drawing whiskers with cross-hatches and ends    
    hat_xcor = [gpos(g,:) - box_width/4; gpos(g,:) + box_width/4];    
    whi_xcor = [gpos(g,:); gpos(g,:)];        
    
    % draw one box at a time
    for k = 1:num_locs
        
        data_vals = Y(Gi==g,k); % data for a single box
        
        % determine outliers and whisker length 
        ol = data_vals<(pt(3,k)-confs.outfactor*IQR(k)); % indices of lower outliers
        ou = data_vals>(pt(5,k)+confs.outfactor*IQR(k)); % indices of upper outliers    

        whi_ycor(:,1,k) = [min(data_vals(~ol)), pt(3,k)]; % lower whisker        
        whi_ycor(:,2,k) = [max(data_vals(~ou)), pt(5,k)]; % upper whisker        
        
        % jitter or not
        if confs.jitter==1
            xdata =  gpos(g,k).*ones(numel(Y(Gi==g,k)),1) + ...
                (box_width/3).*(0.5 - rand(numel(Y(Gi==g,k)),1));
        elseif confs.jitter==0
            xdata = gpos(g,k).*ones(numel(Y(Gi==g,k)),1);
        end        

        % store data in case it's needed for withinlines
        scdata{g}(:,:,k) = [xdata, data_vals];

        % index values for each box
        wk = (1:2)+2*(k-1);
        Xx = box_xcor(1:2,wk); 
        Yy = box_ycor(1:2,wk); 

        % filled or not filled boxes
        if confs.fill==0            
            % no fill box
            h.bx(k,g) = line([Xx(:,1)' Xx(1,:) Xx(:,2)' Xx(2,:)],...
                [Yy(:,1)' Yy(1,:) Yy(:,2)' Yy(2,:)],...
                'color',confs.colors(g,:),'LineWidth',1.5); 
            hold on;        
            
            % draw the median
            h.md(k,g) = line(Xx(1,:), box_mdcor(wk),...
                'color',confs.colors(g,:), 'LineWidth', 2);            
            
            % draw the mean
            if confs.mean==1
                h.mn(k,g) = line(Xx(1,:),box_mncor(wk),'LineStyle',':',...
                    'color',confs.colors(g,:),'LineWidth', 1.5);
            end           
            
        elseif confs.fill==1
            % box filled with color 
            h.bx(k,g) = fill([Xx(:,1)' Xx(1,:) Xx(:,2)' Xx(2,[2,1])],...
                 [Yy(:,1)' Yy(1,:) Yy(:,2)' Yy(2,:)],confs.colors(g,:));            
            set(h.bx(k,g),'FaceAlpha',confs.boxalpha); 
            hold on;

            % draw the median
            h.md(k,g) = line(Xx(1,:), box_mdcor(wk),...
                'color','k', 'LineWidth', 2);
            
            % draw the mean
            if confs.mean==1
                h.mn(k,g) = line(Xx(1,:),box_mncor(wk),'LineStyle',':',...
                    'color','k','LineWidth', 1.5);
            end
        end        
        
        ox = data_vals>max(data_vals); % default - no outliers
        
        % draw outliers
        if confs.outliers==1            
            ox = data_vals<whi_ycor(1,1,k) | data_vals>whi_ycor(1,2,k);
            h.ot(k,g) = scatter(xdata(ox),data_vals(ox),confs.scattersize,...
                confs.outsymbol);            
        end

        % draw whiskers
        if confs.whiskers==1            
            h.wh(k,g,:) = plot(whi_xcor(:,k),whi_ycor(:,1,k),'k-',... 
                hat_xcor(:,k),[whi_ycor(1,1,k) whi_ycor(1,1,k)],'k-',... 
                whi_xcor(:,k),whi_ycor(:,2,k),'k-',... 
                hat_xcor(:,k),[whi_ycor(1,2,k) whi_ycor(1,2,k)],'k-',... 
                'LineWidth',1);                              
        end 

        % scatter on top of the boxplots
        if confs.scatter==1 || confs.scatter==2            
            h.sc(k,g) = scatter(xdata(~ox),data_vals(~ox),...
                confs.scattersize,...
                'MarkerFaceColor', confs.scattercolors{1},...
                'MarkerEdgeColor', confs.scattercolors{2},...
                'MarkerFaceAlpha', confs.scatteralpha); 
            hold on; 
            
        end        
        
    end        
 
    % link the medians of the boxplots with a line
    if confs.linkline==1
       h.ln(g) = line(gpos(g,:),pt(4,:),'color',confs.colors(g,:),...
           'LineStyle','-.','LineWidth',1.5); 
    end
    
    % link individual within group data points
    if confs.withinlines==1
        for s = 1:size(scdata{g},1)                
            h.wl(g) = plot(squeeze(scdata{g}(s,1,:)),...
                squeeze(scdata{g}(s,2,:)),'color', [0.8 0.8 0.8]);
            uistack(h.wl(g),'bottom')
        end
    end

    % put scattered data underneath boxplots
    if confs.scatter==1        
        if confs.mean==1
            uistack(h.mn(:,g),'bottom')
        end

        uistack(h.md(:,g),'bottom')
        uistack(h.bx(:,g),'bottom')
        
        if confs.whiskers==1
            uistack(h.wh(:,g,:),'bottom')        
        end       

    elseif confs.scatter==2
        uistack(h.sc(:,g),'bottom')
    end 
    
end

% move lines to the background
if confs.linkline==1
    uistack(h.ln,'bottom')
end

% flip scatter and box colors and make a legend
if confs.flipcolors==1    
    
    box_class = class(h.bx); % box filled or no
    
    if strcmp(box_class,'matlab.graphics.primitive.Patch')
        set(h.bx,'FaceColor',confs.scattercolors{1});
        set(h.md,'Color',confs.scattercolors{2});
        
        if confs.mean==1
            set(h.mn,'Color',confs.scattercolors{2});
        end
    else
        set(h.bx,'Color',confs.scattercolors{1});
        set(h.md,'Color',confs.scattercolors{1});
        
        if confs.mean==1
            set(h.mn,'Color',confs.scattercolors{1});
        end
    end

    for g = 1:num_groups
       set(h.sc(:,g),'MarkerFaceColor',confs.colors(g,:))
    end
    
    % add a legend based on scatter colors
    if ~isempty(confs.legend)
        h.lg = legend(h.sc(1,:),confs.legend);
    end
else
    
    % add a legend based on box colors
    if ~isempty(confs.legend)
        h.lg = legend(h.bx(1,:),confs.legend);
    end
end

% set ticks and labels
set(gca,'XTick',cpos,'XTickLabels',cpos,'box','off');
if ~isempty(confs.xtlabels)
    set(gca,'XTickLabels',confs.xtlabels,'XTick',cpos);
end  

xlim([gpos(1)-3*box_width, gpos(end)+3*box_width]); % adjust x-axis margins

end
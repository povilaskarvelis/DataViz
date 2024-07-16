function h = daviolinplot(Y,varargin)
% daviolinplot combines density and box plots for 2-level factorial data 
%
% Description:
%
%   Plots violins/density/historgrams/boxplots organized by condition and 
%   colored by group. This is much more informative and transparent than 
%   plotting boxplots alone. 
%
% Syntax:
%
%   daviolinplot(Y)
%   daviolinplot(Y,param,val,...)
%   h = daviolinplot(Y)
%   h = daviolinplot(Y,param,val,...)
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
%   'violin'          'half'  - half-violins, right side (default) 
%                     'half2' - half-violins, left side 
%                     'full'  - full violins
%
%   'colors'          The RGB matrix for violin colors of different groups
%                     (each row corresponding to a different group). If not
%                     provided, the default colors are used.
%
%   'violinalpha'     Violin transparency (between 0 and 1)
%                     Default: 1 (completely non-transparent)
%
%   'violinwidth'     Scalar value for scaling the width of violins
%                     Default: 1
%
%
%   'smoothing'       A scalar value for bandwith of the smoothing kernel. 
%                     The default is optimal for estimating normal 
%                     densities, but you may want to choose a smaller value
%                     to reveal features such as multiple modes.
%
%
%   'box'             Whether to include and where to include the boxplots.
%                     Note that location options only work for half violins
%                     while for full violins the boxplots will be centered
%                     by default.
%                     0 - do not include boxplots
%                     1 - display boxplots; shifted to the left
%                     2 - display boxplots; centered (default)
%                     3 - display boxplots; shifted to the right                    
%
%   'boxcolors'       Color options for boxplots
%                     'k' - all black (default)
%                     'w' - all white
%                     'same' - same as violin/group colors
%   
%   'whiskers'        Draws whiskers to show min and max data values after 
%                     disregarding the outliers (see outlier description)
%                     0 - no whiskers
%                     1 - draw whiskers (default)                     
%
%   'scatter'         0 - no datta scatter (deffault)
%                     1 - scatter shifted to the left
%                     2 - scatter in the center
%                     3 - scatter shifted to the right
%
%   'scattersize'     Size of the scatter markers. Default: 15
%
%   'scattercolors'   Colors for the scattered data. 
%                     Default: same colors as for the violins/groups
%
%   'scatteralpha'    Transparency of scattered data (between 0 and 1)
%                     Default: 1 (completely non-transparent)
%
%   'jitter'          0 - do not jitter scattered data 
%                     1 - jitter scattered data (default)
%                     2 - build a histogram using the scatter markers
%
%   'jitterspacing'   Horizontal spacing between datapoints for jitter 2 
%                     Default: 1
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
%                     Default: 'k*' (black asterisk).
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
%       sc - scattered data markers
%       ot - outlier markers
%       wh - whiskers 
%       ln - line linking boxplots 
%       lg - legend
%
%
% For examples have a look at daviolinplot_demo.m
% Also see: daboxplot.m and dabarplot.m
%
%
% Povilas Karvelis
% 05/05/2020
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = struct;
p = inputParser;

% specify default options
addOptional(p, 'groups', []);
addOptional(p, 'violin', 'half'); 
addOptional(p, 'bins', 10);
addOptional(p, 'colors', get(gca,'colororder'));
addOptional(p, 'violinalpha', 1);
addOptional(p, 'violinwidth', 1);
addOptional(p, 'smoothing','default');
addOptional(p, 'box', 2);
addOptional(p, 'boxcolors', 'k'); 
addOptional(p, 'whiskers', 1);
addOptional(p, 'scatter', 0); 
addOptional(p, 'scattersize', 20)
addOptional(p, 'scattercolors', 'k'); 
addOptional(p, 'flipcolors', 0);
addOptional(p, 'scatteralpha', 1); 
addOptional(p, 'jitter', 0);
addOptional(p, 'jitterspacing', 1);
addOptional(p, 'outliers', 1); 
addOptional(p, 'outfactor', 1.5);
addOptional(p, 'outsymbol', 'k*'); 
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

% get group indices 
if ~isempty(confs.groups)
    [Gi, Gn] = findgroups(confs.groups);
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
gpos=[];
if num_locs==1
    gpos = (1:num_groups)';
    box_width = 0.1*confs.boxwidth;
    cpos=gpos;
else    
    if num_groups==1
        gpos = cpos;
        box_width = 0.1*confs.boxwidth;
    else
        box_width = 0.2/(num_groups+1)*confs.boxwidth;  % calculate box width 
        loc_sp = 4*box_width*confs.boxspacing; % local spacing between boxplots

        % set group positions for each group
        for g = 1:num_groups
            gpos = [gpos; cpos + (g-(num_groups+1)/2)*(box_width + loc_sp)];
        end
    end
end

h.gpos = gpos;
h.cpos = cpos; 

% set boxplot colors
if ~strcmp(confs.boxcolors,'same')
    bcol = confs.boxcolors;
end

% set scatter colors
if ~strcmp(confs.scattercolors,'same')
    scol = confs.scattercolors;
end

% change edge color to white if face color is black; otherwise black
if exist('scol') && strcmp(scol,'k')
    ecol = 'w';
else
    ecol = 'k';
end

% change median line to white if boxplot is black; otherwise black
if exist('bcol') && strcmp(bcol,'k')
    mcol = 'w';
else
    mcol = 'k';
end

% loop over groups
for g = 1:num_groups 
    
    % get percentiles
    pt = prctile(Y(Gi==g,:),[2 9 25 50 75 91 98]); 
    
    if size(pt,1)==1 pt=pt'; end % for plotting one condition
    
    IQR = (pt(5,:)-pt(3,:));
        
    % create coordinates for drawing boxes
    y25 = reshape([pt(3,:); pt(3,:)], 1, []);
    y75 = reshape([pt(5,:); pt(5,:)], 1, []);

    x1 = [gpos(g,:) - box_width/2; gpos(g,:) - box_width/2];
    x2 = [gpos(g,:) + box_width/2; gpos(g,:) + box_width/2];

    box_ycor = [y75; y25];        
    box_medcor = reshape([pt(4,:); pt(4,:)], 1, []);
    
    % x coordinates for boxes
    if strcmp(confs.violin,'full')        
        box_xcor = reshape([x1; x2],2,[]);    
        whi_xcor = [gpos(g,:); gpos(g,:)];  

    elseif strcmp(confs.violin,'half')
        if confs.box==3
            bpos = -15;
        elseif confs.box==2  
            bpos = 2;
        else
            bpos = 0.5;            
        end
        box_xcor = reshape([x1; x2],2,[])-box_width/bpos;    
        whi_xcor = [gpos(g,:); gpos(g,:)]-box_width/bpos;

    elseif strcmp(confs.violin,'half2')
        if confs.box==3
            bpos = 15;
        elseif confs.box==2  
            bpos = 2;
        else
            bpos = 0.5;            
        end
        box_xcor = reshape([x1; x2],2,[])+box_width/bpos;    
        whi_xcor = [gpos(g,:); gpos(g,:)]+box_width/bpos;
    end
    
    % draw one box at a time
    for k = 1:num_locs
        
        data_vals = Y(Gi==g,k); % data for a single box        
        
        % estimate probability density of the data
        if strcmp(confs.smoothing,'default')
            [f,xi] = ksdensity(data_vals);
        else
            [f,xi] = ksdensity(data_vals,'Bandwidth',confs.smoothing);
        end
        
        % normalize/scale density
        f = confs.violinwidth.*(f/max(f))*(21*box_width/(num_groups+7));

        % plot the violin
        if strcmp(confs.violin,'full')            
            h.ds(k,g) = fill([f,-fliplr(f)]+gpos(g,k),...
                [xi,fliplr(xi)],confs.colors(g,:));            
        elseif strcmp(confs.violin,'half')   
            if confs.box==3
                h.ds(k,g) = fill(1.3.*f+gpos(g,k),xi,confs.colors(g,:));
            else
                h.ds(k,g) = fill(f+gpos(g,k),xi,confs.colors(g,:));
            end 
        elseif strcmp(confs.violin,'half2')   
            if confs.box==3
                h.ds(k,g) = fill(1.3.*-fliplr(f)+gpos(g,k),xi,confs.colors(g,:));
            else
                h.ds(k,g) = fill(-fliplr(f)+gpos(g,k),xi,confs.colors(g,:));
            end 
        end      
        
        set(h.ds(k,g),'FaceAlpha',confs.violinalpha); hold on
             
        % plot boxplots
        if confs.box~=0
            
            % index values for each box
            win_k = (1:2)+2*(k-1); 
            Yy = box_ycor(1:2,win_k);
            Xx = box_xcor(1:2,win_k);            
            
            % draw boxes
            if strcmp(confs.boxcolors,'same')
                h.bx(k,g) = fill([Xx(:,1)' Xx(1,:) Xx(:,2)' Xx(2,[2,1])],...
                     [Yy(:,1)' Yy(1,:) Yy(:,2)' Yy(2,:)],confs.colors(g,:)); 
            else
                h.bx(k,g) = fill([Xx(:,1)' Xx(1,:) Xx(:,2)' Xx(2,[2,1])],...
                     [Yy(:,1)' Yy(1,:) Yy(:,2)' Yy(2,:)],bcol);
            end
            set(h.bx(k,g),'FaceAlpha',confs.boxalpha); 
            
            % draw the median
            h.md(k,g) = line(Xx(1,:), box_medcor(win_k),...
                'color',mcol,'LineWidth', 2);
            
            % draw whiskers
            if confs.whiskers==1
                
                % determine outliers and whisker length 
                ol = data_vals<(pt(3,k)-confs.outfactor*IQR(k)); % indices of lower outliers
                ou = data_vals>(pt(5,k)+confs.outfactor*IQR(k)); % indices of upper outliers  

                whi_ycor(:,1,k) = [min(data_vals(~ol)), pt(3,k)]; % lowhisk        
                whi_ycor(:,2,k) = [max(data_vals(~ou)), pt(5,k)]; % upwhisk
                
                % plot whiskers
                h.wh(k,g,:) = plot(whi_xcor(:,k),whi_ycor(:,1,k),'k-',... 
                    whi_xcor(:,k),whi_ycor(:,2,k),'k-',... 
                    'LineWidth',1.5);                              
            end             
        end
        
        ox = data_vals>max(data_vals); % default - no outliers        
        
        % jitter or not
        if confs.jitter==0
            xdata = gpos(g,k).*ones(numel(Y(Gi==g,k)),1);
        
        % a simple jitter    
        elseif confs.jitter==1
            xdata =  gpos(g,k).*ones(numel(Y(Gi==g,k)),1) + ...
                (box_width/1.5).*(0.5 - rand(numel(Y(Gi==g,k)),1));
        
        % build a histogram from discrete data points    
        elseif confs.jitter==2
            [N,E] = histcounts(data_vals,confs.bins);
            bin_w = E(2)-E(1); bm = E + (bin_w)/2; bm(end)=[];
            hx=[]; hy=[];
            for i = 1:numel(N)
                for j = 1:N(i)
                    hy = [hy, bm(i)];
                    hx = [hx, (-j+0.8)*confs.jitterspacing/(8*numel(gpos))...
                         + gpos(g,k)];                                           
                end
            end 
            xdata = hx; data_vals = hy;            
        end  
        
        % default: scatter on boxplot if half violin is used
        if confs.jitter~=2
            if strcmp(confs.violin,'half')
                xdata = xdata - box_width/2;
            elseif strcmp(confs.violin,'half2')
                xdata = xdata + 2*box_width;
            end
        end
        
        % specify the x position of the data scatter
        if confs.scatter==1 
            xdata = xdata - 1.3*box_width;
        elseif confs.scatter==2 
            if confs.box==3
                xdata = xdata - box_width*(8/10);
            else
                xdata = xdata - box_width/4;
            end
        elseif confs.scatter==3
                xdata = xdata + box_width;            
        end

        % store data in case it's needed for withinlines
        scdata{g}(:,:,k) = [xdata, data_vals];
        
        % draw outliers
        if confs.outliers==1    
            ox = data_vals<(pt(3,k)-confs.outfactor*IQR(k)) | ...
                 data_vals>(pt(5,k)+confs.outfactor*IQR(k));
            h.ot(k,g) = scatter(xdata(ox),data_vals(ox),confs.scattersize,...
                confs.outsymbol);    
        end            

        % scatter the data
        if confs.scatter~=0 
            if strcmp(confs.scattercolors,'same')
                h.sc(k,g) = scatter(xdata(~ox),data_vals(~ox),...
                    confs.scattersize,...
                    'MarkerFaceColor', confs.colors(g,:),...
                    'MarkerEdgeColor', 'k',...
                    'MarkerFaceAlpha', confs.scatteralpha);  
            else
                h.sc(k,g) = scatter(xdata(~ox),data_vals(~ox),...
                    confs.scattersize,...
                    'MarkerFaceColor', scol,...
                    'MarkerEdgeColor', ecol,...
                    'MarkerFaceAlpha', confs.scatteralpha);  
            end
        end        
    end        
    
    % draw a line that links each group across conditions
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
end

% move lines to the background
if confs.linkline==1
    uistack(h.ln,'bottom')
end

% build a legend
if ~isempty(confs.legend)
    h.lg = legend(h.ds(1,:),confs.legend);
end

% set ticks and labels
set(gca,'XTick',cpos,'XTickLabels',cpos,'box','off');
if ~isempty(confs.xtlabels)
    set(gca,'XTickLabels',confs.xtlabels,'XTick',cpos);
end  

xlim([gpos(1)-3*box_width, gpos(end)+3*box_width]); % adjust x-axis margins


end
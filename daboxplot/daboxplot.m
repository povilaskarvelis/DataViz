function handles = daboxplot(Y,varargin)
%DABOXPLOT draws neat boxplots for multiple groups and multiple conditions 
%
% Description:
%
%   Creates boxplots organized by condition and colored by group. Does not
%   require the groups to be of the same size. Has some essential options
%   (see below) and exports the main handles for further customization. 
%
% Syntax:
%
%   daboxplot(Y)
%   daboxplot(Y,param,val,...)
%   handles = daboxplot(Y)
%   handles = daboxplot(Y,param,val,...)
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
%   'fill'            0 - non-colored boxplots (contrours only)
%                     1 - boxplots filled with color
%
%   'colors'          The RGB matrix for box colors of different groups
%                     (each row corresponding to a different group). If
%                     boxplots are filled, these are the fill colors with 
%                     the edges being black. If boxplots are not filled,
%                     these colors are used for edges. 
%                     Default: default matlab colors. 
%   
%   'whiskers'        0 - no whiskers
%                     1 - 2nd & 98th percentile (default)
%                     2 - 9th & 91th percentile
%
%   'scatter'         0 - no datta scatter (deffault)
%                     1 - on top of the boxplot 
%                     2 - underneath the boxplot
%
%   'scattercolors'   Colors for the scattered data: {face, edge}
%                     Default: {'k','w'}
%
%   'scatteralpha'    Transparency of scattered data (between 0 and 1)
%                     Default: 1 (completely non-transparent)
%
%   'jitter'          0 - do not jitter scattered data (default)
%                     1 - jitter scattered data
% 
%   'outliers'        Highlights the outliers in the plot. The outliers 
%                     are determined based on the choice of whiskers.
%                     0 - do not highlight outliers (default) 
%                     1 - highlight outliers
%
%   'symbol'          Symbol and color for highlighting outliers.
%                     Default: 'rx' (red crosses).
%
%   'boxalpha'        Boxplot transparency (between 0 and 1)
%                     Default: 1 (completely non-transparent)
%
%   'conditions'      Xtick labels for conditions (a cell of chars)
%                     Default: conditions are numbered in the input order.
%
% Output Arguments:
%
%   handles - a structure containing handles for further customization of
%   the produced plot:
%       cpos - condition positions
%       gpos - group positions
%       bx - boxplot box (graphics object)
%       m  - median line (graphics object)
%       sc - scattered data markers (graphics object)
%       ot - outlier markers (graphics object)
%       wh - whiskers (graphics object)
%
%
% For examples have a look at daboxplot_demo.m
%
%
% Povilas Karvelis <karvelis.povilas@gmail.com>
% 15/04/2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

handles = struct;
p = inputParser;

% specify default options
addOptional(p, 'groups', []);
addOptional(p, 'fill', 1); 
addOptional(p, 'colors', get(gca,'colororder'));
addOptional(p, 'whiskers', 1);
addOptional(p, 'scatter', 0); 
addOptional(p, 'scattersize', 20)
addOptional(p, 'scattercolors', {'k','w'}); 
addOptional(p, 'scatteralpha', 1); 
addOptional(p, 'jitter', 0);
addOptional(p, 'outliers', 0); 
addOptional(p, 'symbol', 'rx'); 
addOptional(p, 'boxalpha', 1);
addOptional(p, 'conditions', []); 

% parse the input options
parse(p, varargin{:});
confs = p.Results;

% get group indices and labels if 
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
if num_groups==1
    gpos = cpos;
    box_width = 1/3;
else
    box_width = (2/3)/(num_groups+1);   % calculate box width 
    loc_sp = box_width/4;   % gap of 1/4 box width between boxplots
    
    % set group positions for each group
    for g = 1:num_groups
        gpos = [gpos; cpos + (g-(num_groups+1)/2)*(box_width + loc_sp)];
    end
end

handles.gpos = gpos;
handles.cpos = cpos; 


% loop over groups
for g = 1:num_groups 
    
    % get percentiles
    pt = prctile(Y(Gi==g,:),[2 9 25 50 75 91 98]);   
    
    % create coordinates for drawing boxes
    y25 = reshape([pt(3,:); pt(3,:)], 1, []);
    y75 = reshape([pt(5,:); pt(5,:)], 1, []);

    x1 = [gpos(g,:) - box_width/2; gpos(g,:) - box_width/2];
    x2 = [gpos(g,:) + box_width/2; gpos(g,:) + box_width/2];

    box_ycords = [y75; y25];        
    box_xcords = reshape([x1; x2],2,[]); 
    box_medcords = reshape([pt(4,:); pt(4,:)], 1, []);
    
    % create coordinates for drawing whiskers with cross-hatches and ends    
    hat_xcords = [gpos(g,:) - box_width/4; gpos(g,:) + box_width/4];    
    whi_xcords = [gpos(g,:); gpos(g,:)];
    
    % draw one box at a time
    for k = 1:num_locs

        % jitter or not
        if confs.jitter==1
            xdata =  gpos(g,k).*ones(numel(Y(Gi==g,k)),1) + ...
                (box_width/2).*(0.5 - rand(numel(Y(Gi==g,k)),1));
        elseif confs.jitter==0
            xdata = gpos(g,k).*ones(numel(Y(Gi==g,k)),1);
        end
        data_vals = Y(Gi==g,k);

        % index values for each box
        win_k = (1:2)+2*(k-1);
        Xx = box_xcords(1:2,win_k); 
        Yy = box_ycords(1:2,win_k); 

        % filled or not filled boxes
        if confs.fill==0            
            % no fill box
            bx(k,g) = line([Xx(:,1)' Xx(1,:) Xx(:,2)' Xx(2,:)],...
                [Yy(:,1)' Yy(1,:) Yy(:,2)' Yy(2,:)],...
                'color',confs.colors(g,:),'LineWidth',1.5); 
            hold on;        
            
            % median
            m(k,g) = line(Xx(1,:), box_medcords(win_k),...
                'color',confs.colors(g,:), 'LineWidth', 2);
            
        elseif confs.fill==1
            % box filled with color 
            bx(k,g) = fill([Xx(:,1)' Xx(1,:) Xx(:,2)' Xx(2,[2,1])],...
                 [Yy(:,1)' Yy(1,:) Yy(:,2)' Yy(2,:)],confs.colors(g,:));            
            alpha(confs.boxalpha); 
            hold on;

            % draw the median
            m(k,g) = line(Xx(1,:), box_medcords(win_k),...
                'color','k', 'LineWidth', 2);
        end
        
        % if no whiskers, use boxplot edges to determine outliers
        whi_ends = pt([3,5],k); 
        
        if confs.whiskers==1

            wh(k,g,:) = plot(whi_xcords(:,k),pt([1,3],k),'k-',... % lower whisker  
                hat_xcords(:,k),[pt(1,k) pt(1,k)],'k-',... % lower end (2%)
                whi_xcords(:,k),pt([5,7],k),'k-',... % upper whisker
                hat_xcords(:,k),[pt(7,k) pt(7,k)],'k-',... % upper end (98%)
                'LineWidth',1); 
            
            whi_ends = pt([1,7],k);
            
        elseif confs.whiskers==2
            
            wh(k,g,:) = plot(whi_xcords(:,k),pt([2,3],k),'k-',... % lower whisker
                hat_xcords(:,k),[pt(2,k) pt(2,k)],'k-',... % lower end (9%)
                whi_xcords(:,k),pt([5,6],k),'k-',... % upper whisker
                hat_xcords(:,k),[pt(6,k) pt(6,k)],'k-',... % upper end (91%)
                'LineWidth',1);  
            
            whi_ends = pt([2,6],k);           
        end
        
        ox = data_vals>max(data_vals); % default - no outliers
        
        % draw outliers
        if confs.outliers==1            
            ox = data_vals<whi_ends(1) |  data_vals>whi_ends(2);
            ot(k,g) = scatter(xdata(ox),data_vals(ox),confs.scattersize,...
                confs.symbol);            
        end       

        % scatter on top of the boxplots
        if confs.scatter==1 || confs.scatter==2            
            sc(k,g) = scatter(xdata(~ox),data_vals(~ox),confs.scattersize,...
                'MarkerFaceColor', confs.scattercolors{1},...
                'MarkerEdgeColor', confs.scattercolors{2},...
                'MarkerFaceAlpha', confs.scatteralpha); 
            hold on;    
        end        
        
    end        
        
    % put scattered data underneath boxplots
    if confs.scatter==2
        uistack(sc(:,g),'bottom')
    end
    
end

handles.bx = bx; 
handles.m  =  m;

if exist('sc')
    handles.sc = sc;
end

if exist('ot')
    handles.ot = ot;
end

if exist('wh')
    handles.wh =  wh;
end

set(gca,'XTick',cpos,'box','off');

if ~isempty(confs.conditions)
    set(gca,'XTickLabels',confs.conditions,'XTick',cpos);
end    

end
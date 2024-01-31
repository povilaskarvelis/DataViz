function ca = fromtable2cell(tvalues, tconditions, tgroups)
%fromtable2cell
%
% Description: This function rearranges data from a table into a cell array
% compatible with the daboxplot function. It handles categorical or char
% types for conditions and groups by converting them to numerical indices.
%
% Syntax:
% ca = fromtable2cell(tvalues, tconditions, tgroups)
%
% Input Arguments:
% tvalues - Array with the table column that contains the data to be plotted.
% tconditions - Array with the table column that corresponds to "conditions".
% tgroups - Array with the table column that corresponds to "groups".

% Convert categorical/char tconditions and tgroups to numerical indices
tconditions = convertCategorical(tconditions, 'conditions');
tgroups = convertCategorical(tgroups, 'groups');

% Unique conditions and groups
conds = unique(tconditions);
groups = unique(tgroups);

% Preallocate cell array
ca = cell(1, length(groups));

% Populate cell array
for gi = 1:length(groups)
    for ci = 1:length(conds)
        % Filter values by condition and group
        ci_val = tvalues(tconditions == conds(ci) & tgroups == groups(gi));
        
        if ci == 1
            % Preallocate NaN array for the group
            ca{gi} = nan(max(arrayfun(@(x) sum(tconditions == x & tgroups == groups(gi)), conds)), length(conds));
        end
        
        % Assign values to cell array
        ca{gi}(1:length(ci_val), ci) = ci_val;
    end    
end
end

function [catArray, isCat] = convertCategorical(catArray, varName)
% Convert categorical or character array to numerical indices
isCat = iscategorical(catArray) || ischar(catArray);
if isCat
    [~, ~, catArray] = unique(catArray);
    fprintf('WARNING: Categorical/char values of %s are transformed to numerical indices.\n', varName);
end
end
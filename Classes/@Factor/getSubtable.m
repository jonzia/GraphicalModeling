function rows = getSubtable(obj, conditions)

% -------------------------------------------------------------------------
% SUMMARY
% Get a subtable from a factor table given a table of conditions. The
% conditions table must be a single row representing a subset of the factor
% table of the Factor object.

% ARGUMENTS
% - conditions  Table   Row table of conditions, with row headings
%                       representing variable names and the values
%                       representing conditions

% EXAMPLE
% >> conditions = table(condition1, condition2);
% >> conditions.Properties.VariableNames = {'var1', 'var2'};
% >> rows = factor.getSubtable(conditions);
% -------------------------------------------------------------------------

% Remove extraneous columns from conditions
removeIdx = [];     % Set placeholder for removal columns
for i = 1:size(conditions, 2)   % For each variable...
    if isempty(find(strcmp(obj.table.Properties.VariableNames, conditions.Properties.VariableNames{i}), 1))
        % Add the index if it is not found in the factor table
        removeIdx = [removeIdx i];
    end
end; conditions(:, removeIdx) = [];

% Set placeholder for matching elements
match = zeros(size(obj.table, 1), size(conditions, 2));

% Whittle the table based on each condition
for i = 1:length(conditions.Properties.VariableNames)
    match(:, i) = obj.table.(conditions.Properties.VariableNames{i}) == ...
        conditions.(conditions.Properties.VariableNames{i});
end

% Get the rows that have all matches
matched = prod(match, 2); rows = find(matched == 1);

end
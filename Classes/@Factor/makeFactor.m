function obj = makeFactor(obj, names, values, varargin)

% -------------------------------------------------------------------------
% SUMMARY
% Create a factor table for a variable node. The factor has one column for
% each variable, each row corresponding to one permutation of the
% variables. Optional additional columns may be added, such as for factor
% values (e.g. assignment probabilities). Additional columns are set to
% random values normalized to 1 over all rows.

% ARGUMENTS (REQ'D)
% - names   {String}    Column names for factor table
% - values  {{Any}}     Cell vector of value vectors for each variable

% ARGUMENTS (OPT'L)
% {String}              Cell vector of names for extra columns
% -------------------------------------------------------------------------

% Parse input arguments
if ~isempty(varargin); extraCols = varargin{1}; else; extraCols = {}; end

% Set the names and values to default if blank
if isempty(names) || isempty(values)
    names = {obj.name}; values = {{Class.true, Class.false}};
end

% Get the total number of factor combinations
totalCombinations = 1;
for i = 1:length(values)
    totalCombinations = totalCombinations*length(values{i});
end

% Initialize a cell array for holding table values
tabVal = cell(totalCombinations, length(names));

% Populate array of table values
temp = totalCombinations;   % Copy the total number of combinations
for i = 1:length(names)
    % Determine how many times to repeat each value for the column
    temp = temp/length(values{i}); idx = 0;
    for j = 1:totalCombinations
        tabVal{j,i} = values{i}{mod(idx, length(values{i})) + 1};
        if mod(j, temp) == 0; idx = idx + 1; end
    end
end

% Create table from array
tab = cell2table(tabVal);

% Add column names
tab.Properties.VariableNames = names;

% Add extra columns (if necessary)
if ~isempty(extraCols)
    % Add columns
    for i = 1:length(extraCols)
        randVec = rand(size(tab, 1), 1);
        newTab = table(randVec./sum(randVec));
        newTab.Properties.VariableNames = extraCols(i);
        tab = [tab newTab];
    end
end

% Set return value
obj.table = tab;

end
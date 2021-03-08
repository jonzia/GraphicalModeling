function result = query(obj, varargin)

% -------------------------------------------------------------------------
% SUMMARY
% Query a Node object. Result is in the form of a probability table unless
% a value is specified, which results in returning the value of the factor.

% ARGUMENTS:
% - 'value'                         Value of the node
% - 'given'     {String}, {Any}     Cell vectors of parent names + values
% - 'query'     Table               Table with which to make query

% USAGE:
% Consider the graphical model with binary parent nodes A and B and binary
% child node C. C may be evaluated given A and B in two ways, the first
% being a list of query nodes and values:
% >> result = node.query('value', false, 'given', {'A', 'B'}, {true, false});
% The second method performs the same query with a table:
% >> tab = table(true, false, false); tab.Properties.VariableNames = {'A', 'B', 'C'};
% >> result = node.query(tab);
% -------------------------------------------------------------------------

% Placeholder for name-value pairs
names = {}; conditions = {}; value = {};

% Parse input arguments
if ~isempty(varargin)
    for arg = 1:length(varargin)
        if strcmp(varargin{arg}, 'given'); names = varargin{arg + 1}; conditions = varargin{arg + 2};
        elseif strcmp(varargin{arg}, 'value'); value = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'table'); queryTable = varargin{arg + 1};
        end
    end
end

% If there is a query table given, narrow the factor table by the query
if exist('queryTable', 'var')
    rows = obj.factor.getSubtable(queryTable);
    result = obj.factor.table(rows, :);
elseif exist('names', 'var') && exist('conditions', 'var')
    % If there is no query table, make a query table and narrow the factor
    queryTable = cell2table(conditions); queryTable.Properties.VariableNames = names;
    % Query the factor
    rows = obj.factor.getSubtable(queryTable);
    result = obj.factor.table(rows, :);
end

% If a value is specified, return only the decimal number
if ~isempty(value); result = result.probability(result.(obj.name) == value); end

end
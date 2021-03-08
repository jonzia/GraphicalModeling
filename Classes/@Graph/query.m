function queryTable = query(obj, varargin)

% -------------------------------------------------------------------------
% SUMMARY
% Return a probability distribution table based on query conditions given
% as either a table or list of query nodes, evidence nodes, and conditions.

% ARGUMENTS (OPT'L)
% - 'query'         {Node}  Cell vector of Node(s) to query
% - 'evidence'      {Node}  Cell vector of evidence nodes
% - 'conditions'    {Any}   Cell vector of evidence node values
% - 'table'         Table   Table for probability of assignment

% USAGE
% Two example usages are shown for an example graph with binary parents A
% and B and binary child C. The first is a list of conditions:
% >> queryTable = graph.query('query', {A}, 'evidence', {B, C}, {true, false});
% The second is the same query using a table
% >> tab = table(true, false); tab.Properties.VariableNames = {'A', 'B'};
% >> queryTable = graph.query(tab);
% -------------------------------------------------------------------------

% Parse input arguments
if ~isempty(varargin)
    for arg = 1:length(varargin)
        if strcmp(varargin{arg}, 'query'); queryNodes = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'evidence'); evidenceNodes = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'conditions'); conditions = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'table'); evidenceTable = varargin{arg + 1};
        end
    end
end

% If no evidence table is provided, make an evidence table
if ~exist('evidenceTable', 'var') && ~isempty(evidenceNodes)
    evidenceNames = cell(length(evidenceNodes), 1);
    evidenceValues = cell(length(evidenceNodes), 1);
    for i = 1:length(evidenceNodes)
        evidenceNames{i} = evidenceNodes{i}.name;
        evidenceValues{i} = {conditions{i}};
    end
    evidenceTable = Factor('evidence');
    evidenceTable = evidenceTable.makeFactor(evidenceNames, evidenceValues, {'value'});
    evidenceTable = evidenceTable.table;
end

% If the assignment table has already been calculated, use that for
% inference. Else, compute the assignment table

if isempty(obj.assignments); obj = obj.setAssignments(); end

% Get the total probability of assignment
if exist('evidenceTable', 'var')
    rows = obj.assignments.getSubtable(evidenceTable(1, :));
    totalProbability = sum(obj.assignments.table.probability(rows));
    obj.assignments.table = obj.assignments.table(rows, :);
else
    totalProbability = 1;
end

% Create a new table with only query nodes
queryNames = cell(length(queryNodes), 1);
queryValues = cell(length(queryNodes), 1);
for i = 1:length(queryNodes)
    queryNames{i} = queryNodes{i}.name;
    queryValues{i} = queryNodes{i}.values;
end
queryTable = Factor('evidence');
queryTable = queryTable.makeFactor(queryNames, queryValues, {'value'});
queryTable = queryTable.table;

% Populate the query table
for row = 1:size(queryTable, 1)
    rows = obj.assignments.getSubtable(queryTable(row, :));
    queryTable.value(row) = sum(obj.assignments.table.probability(rows, :))/totalProbability;
end

end
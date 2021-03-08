function obj = createMessage(obj, parents, eval, over)

% -------------------------------------------------------------------------
% SUMMARY
% Compute the message lookup table using factor multiplication and either
% sum-product or max-product. The parents are Factor objects and the type
% is a MessageEval enumeration. Specify the variable name(s) over which to
% perform sum-product or max-product.

% ARGUMENTS (REQ'D)
% - parents     {cell}          Cell vector of parent nodes
% - eval        MessageEval     Type of evaluation to perform
% - over        {String}        Variable(s) to sum out from table
% -------------------------------------------------------------------------

% Perform factor multiplication of each factor, in sequence
newFactor = parents{1}.factor;
for i = 2:length(parents)
    if isa(parents{i}, 'Node')
        multiplicand = parents{i}.factor;
    else
        multiplicand = parents{i};
    end
    newFactor = newFactor.multiply(multiplicand);
end

% Create a factor that doesn't include the variable(s) over which
% summation/maximization will occur
newParents = newFactor.tableNames; newValues = newFactor.tableValues;
for i = 1:length(over)
    idx = strcmp(newFactor.tableNames, over{i});
    newParents(idx) = []; newValues(idx) = [];
end
factor = Factor('result'); factor = factor.makeFactor(newParents, newValues, {'value'});

% Perform either sum-product or max-product operation
% -------------------------------------------------------------------------
% Sum-Product
% -------------------------------------------------------------------------

if eval == MessageEval.sumProduct
    
    % For each row in the new factor table, add up the corresponding
    % entries from the original table and write to the new table
    for row = 1:size(factor.table, 1)
        rows = newFactor.getSubtable(factor.table(row, :));
        factor.table.value(row) = sum(newFactor.table.probability(rows));
    end
    
end

% -------------------------------------------------------------------------
% Max-Product
% -------------------------------------------------------------------------

if eval == MessageEval.maxProduct
    
    % For each row in the new factor table, return the maximum values from
    % the corresponding entries in the original table
    for row = 1:size(factor.table, 1)
        rows = newFactor.getSubtable(factor.table(row, :));
        factor.table.value(row) = max(newFactor.table.probability(rows));
    end
    
end

% Assign table to object
% Remove names in "over" from new table
factor.table.Properties.VariableNames{end} = 'probability';
obj.table = factor.table; obj.tableNames = newParents; obj.tableValues = newValues;

end
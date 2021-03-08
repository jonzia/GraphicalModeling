function newFactor = multiply(obj, multiplicand)

% -------------------------------------------------------------------------
% SUMMARY
% Perform factor multiplication for two factors or messages. Factors are
% multiplied by creating a new table with all variable combinations from
% the parent factors. Entries in the parent tables corresponding to rows of
% the child table are multiplied together to populate the new table.

% ARGUMENTS
% - multiplicand    Factor/Message  Factor with which to multiply
% -------------------------------------------------------------------------

% Initialize a factor that has all the variable fields of the two factors
newFactor = Factor('result');   % Initialize factor

% Get the parent names and values from both factors
parentNames = {obj.tableNames{1}}; parentValues = {obj.tableValues{1}};
if length(obj.tableNames) > 1
    for i = 2:length(obj.tableNames)
        if isempty(find(strcmp(parentNames, obj.tableNames{i}), 1))
            parentNames{end + 1} = obj.tableNames{i};
            parentValues{end + 1} = obj.tableValues{i};
        end
    end
end
for i = 1:length(multiplicand.tableNames)
    if isempty(find(strcmp(parentNames, multiplicand.tableNames{i}), 1))
        parentNames{end + 1} = multiplicand.tableNames{i};
        parentValues{end + 1} = multiplicand.tableValues{i};
    end
end

% Populate the new factor with parent permutations
newFactor = newFactor.makeFactor(parentNames, parentValues, {'value'});

% For each row in the new factor, narrow the operands and multiply the result
for row = 1:size(newFactor.table, 1)
    
    row1 = obj.getSubtable(newFactor.table(row, :));
    row2 = multiplicand.getSubtable(newFactor.table(row, :));
    newFactor.table.value(row) = obj.table.probability(row1)*multiplicand.table.probability(row2);
    
end

% Rename the probability column of the new factor and return
newFactor.table.Properties.VariableNames{end} = 'probability';

% Set the remaining factor properties
newFactor.tableNames = parentNames; newFactor.tableValues = parentValues;
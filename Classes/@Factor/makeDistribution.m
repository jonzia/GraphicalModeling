function obj = makeDistribution(obj, varnode)

% -------------------------------------------------------------------------
% SUMMARY
% Make a factor into a valid probability distribution over one or more
% variables listed in a cell array (Varnode objects). For each permutation
% of parent variables, normalize the child values over the permutation. For
% example, for binary node C with binary parents A and B, the sum of all
% factor values where A = false and B = false is 1.

% ARGUMENTS
% - varnode     Node    Variable node to which factor belongs
% -------------------------------------------------------------------------

% Extract parents
parents = varnode.parents;

% If there are no parents, normalize the entire row and return
if isempty(parents); obj.table.probability = obj.table.probability./sum(obj.table.probability); return; end

% Make a table of all parent permutations
parentNames = cell(length(parents), 1); parentValues = cell(length(parents), 1);
for i = 1:length(parents); parentNames{i} = parents{i}.name; parentValues{i} = parents{i}.values; end
parentFactor = Factor('parents'); parentFactor = parentFactor.makeFactor(parentNames, parentValues);

% For each row in the child factor table, get the corresponding rows in
% the original factor and sum the final column
for row = 1:size(parentFactor.table, 1)
    
    % Whittle the table by the child factors
    rows = obj.getSubtable(parentFactor.table(row, :));
    
    % Normalize the final column
    obj.table.probability(rows) = obj.table.probability(rows)./sum(obj.table.probability(rows));
    
end

end
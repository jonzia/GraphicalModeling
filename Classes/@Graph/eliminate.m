function probTable = eliminate(obj, evaluate, givenNodes, givenVals, order)

% -------------------------------------------------------------------------
% SUMMARY
% Perform variable elimination on the graph to evaluate a node or set of
% nodes and eliminate them with a specified or random order. This is
% performed by generating messages from groups of factors which share the
% variable to be eliminated. Resultant messages are not dependent upon the
% eliminated variable, and the variable is thus eliminated from the graph.
% The process is continued until the evaluation nodes remain. At this
% point, the nodes are combined into a single message.

% ARGUMENTS
% - evaluate    {Node}      List of nodes to evaluate
% - givenNodes  {Node}      List of nodes that are given
% - givenVals   {Any}       Values of given nodes
% - order
%   - {Node}                List of nodes to eliminate, in order
%   - 'rand'                Random ordering of nodes to eliminate

% EXAMPLE
% Consider the graph with binary parent nodes A and B with binary child
% node C, the following command evaluates C with respect to A and B.
% >> probTable = graph.evaluate({C}, {A, B}, {true, false}, 'rand');
% -------------------------------------------------------------------------

% Get the graph nodes
allNodes = obj.nodes;

% For each given node, set the factor to the given value
for i = 1:length(givenNodes)
    % For the node in allNodes...
    for j = 1:length(allNodes)
        if strcmp(allNodes{j}.name, givenNodes{i}.name)
            % Update the factor as indicated
            allNodes{j}.factor.table.probability(allNodes{j}.factor.table.(allNodes{j}.name) ~= givenVals{i}) = 0; 
        end
    end
end

% Get the names of all nodes in the graph
names = cell(length(allNodes), 1);
for i = 1:length(allNodes)
    names{i} = allNodes{i}.name;
end

% Get the names of nodes to be evaluated
eval = cell(length(evaluate), 1);
for i = 1:length(evaluate)
    eval{i} = evaluate{i}.name;
end

% Get the names of nodes to be eliminated
elim = cell(length(allNodes) - length(eval), 1); c = 1;
for i = 1:length(names)
    if isempty(find(strcmp(eval, names{i}), 1))
        elim{c} = names{i}; c = c + 1;
    end
end

% If the order is 'rand', generate a random order on the nodes
% Else, get the names in order

if ischar(order) && strcmp(order, 'rand')
    elim = elim(randperm(numel(elim)));
else
    elim = cell(length(order), 1);
    for i = 1:length(order)
        elim{i} = order{i}.name;
    end
end

% -------------------------------------------------------------------------
% Variable Elimination
% -------------------------------------------------------------------------

% Eliminate the indicated nodes, in order
for i = 1:length(elim)
    
    % Indicate node for elimination
    elimNode = elim{i};
    
    % Find all nodes in the graph with a factor containing elimNode
    containElim = {};
    for j = 1:length(allNodes)
        % Get the parents of the factor
        if isa(allNodes{j}, 'Node')
            parents = allNodes{j}.factor.tableNames;
        else
            parents = allNodes{j}.tableNames;
        end
        % For each parent...
        for p = 1:length(parents)
            % If the parent contains the node to be eliminated, add the node
            if ~isempty(find(strcmp(parents, elimNode), 1))
                containElim{end+1} = allNodes{j}; break
            end
        end
    end
    
    % Construct a message from the nodes
    message = Message(char('Message' + string(i)), MessageType.varToVar);
    message = message.createMessage(containElim, MessageEval.sumProduct, {elimNode});
    
    % Remove all eliminated nodes from the graph
    removeIdx = [];
    for j = 1:length(allNodes)
        for k = 1:length(containElim)
            if strcmp(allNodes{j}.name, containElim{k}.name)
                removeIdx = [removeIdx j];
            end
        end
    end; removeIdx = unique(removeIdx);
    allNodes(removeIdx) = [];
    
    % Add the message to the graph
    allNodes{end+1} = message;
    
end

% Return final message, normalized to account for observations
probTable = allNodes{1};
if length(allNodes) > 1
    for i = 2:length(allNodes)
        probTable = probTable.multiply(allNodes{i});
    end
end
probTable = probTable.table;
probTable.probability = probTable.probability./sum(probTable.probability);

end
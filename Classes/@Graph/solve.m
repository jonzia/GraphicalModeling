function obj = solve(obj)

% -------------------------------------------------------------------------
% SUMMARY
% Evaluate all possible nodes in a factor graph recursively. A node in the
% graph is evaluated if its parents are evaluated in each iteration. The
% process is continued until all variable nodes are evaluated.
% -------------------------------------------------------------------------

% Determine the number of nodes evaluated
numEvaluated = 0; for i = 1:length(obj.nodes); if obj.nodes{i}.evaluated == true; ...
            numEvaluated = numEvaluated + 1; end; end

% Set the loop flag
if numEvaluated < length(obj.nodes); FLAG = true; else; FLAG = false; end

% Perform the process while there are unevaluated nodes and progress is
% being made
while FLAG
    
    % Find all non-evaluated nodes whose parents are evaluated
    nextNodes = [];
    for i = 1:length(obj.nodes)
        flag = true;    % Set placeholder
        % If the node is non-evaluated
        if ~obj.nodes{i}.evaluated
            % If the node's parents are evaluated
            for j = 1:length(obj.nodes{i}.parents)
                if ~obj.nodes{i}.parents{j}.evaluated
                    flag = false;
                end
            end
        else
            flag = false;
        end
        % Add the node if it is eligible for evaluation
        if flag; nextNodes = [nextNodes i]; end
    end
    
    % Evaluate all nodes in the list
    if ~isempty(nextNodes)
        
        for i = 1:length(nextNodes)

            % Evaluate the node
            obj.nodes{nextNodes(i)} = obj.nodes{nextNodes(i)}.evaluate();
            
            % Update nodes that have this node as its parent
            for j = 1:length(obj.nodes)
                for k = 1:length(obj.nodes{j}.parents)
                    if strcmp(obj.nodes{j}.parents{k}.name, obj.nodes{nextNodes(i)}.name)
                        obj.nodes{j}.parents{k} = obj.nodes{nextNodes(i)};
                    end
                end
            end

        end
    
    else
        
        % If there are no nodes to be evaluated, set the flag to false
        FLAG = false;
        
    end
    
    % If there are no nodes left to be evaluated, set flag to false
    numEvaluated = 0; for i = 1:length(obj.nodes); if obj.nodes{i}.evaluated == true; ...
            numEvaluated = numEvaluated + 1; end; end
    if numEvaluated == length(obj.nodes); FLAG = false; end
    
end

end
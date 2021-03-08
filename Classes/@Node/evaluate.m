function obj = evaluate(obj)

% -------------------------------------------------------------------------
% SUMMARY
% Evaluate a factor or variable node given a cell array of messages.
% Variable nodes are evaluated using a max-product algorithm over the
% incoming messages, while factor nodes are evaluated by narrowing its
% factor table based on its incoming messages.
% -------------------------------------------------------------------------

% Extract messages from parents
messages = cell(length(obj.parents), 1);
for i = 1:length(messages)
    messages{i} = obj.parents{i}.value;
end

% -------------------------------------------------------------------------
% Variable Node
% -------------------------------------------------------------------------

% For variable nodes, perform factor multiplication and take the argmax
if obj.type == NodeType.variable
    
    % Change the parent's name in the table to the child's name
    for i = 1:length(messages)
        messages{i}.table.Properties.VariableNames{1} = obj.name;
        messages{i}.tableNames{1} = obj.name;
    end
    
    % Set placeholder
    message = messages{1};
    
    % Perform message multiplication
    if length(messages) > 1
        for i = 2:length(messages)
            message = message.multiply(messages{i});
        end
    end
    
    % Write the value
    [~, idx] = max(message.table.probability); obj = obj.write(obj.values{idx});
    
end

% -------------------------------------------------------------------------
% Factor Node
% -------------------------------------------------------------------------

% For factor nodes, whittle the table with each incoming message
if obj.type == NodeType.factor
    
    % Set placeholder
    temp = obj.factor;
    
    % Whittle the probability tables
    for i = 1:length(messages)
        rows = temp.getSubtable(messages{i});
        temp.table = temp.table(rows, :);
        % Remove the corresponding column from the table
        temp.table.(obj.parents{i}.name) = [];
        % Get the index of the parent
        for idx = 1:length(temp.tableNames)
            if strcmp(temp.tableNames{idx}, obj.parents{i}.name)
                temp.tableNames(idx) = []; temp.tableValues(idx) = []; break;
            end
        end
    end
    
    % Write the value
    obj.value = temp; obj.evaluated = true;
    
end

end
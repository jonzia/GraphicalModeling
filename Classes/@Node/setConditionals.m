function obj = setConditionals(obj, observations)

% -------------------------------------------------------------------------
% SUMMARY
% Set the conditional probabilities of an object given a data table. The
% rows of the table represents individual observations and the columns
% represent the variables of the graphical model.

% ARGUMENTS (REQ'D)
% - observations    Table   Table of observations
% -------------------------------------------------------------------------

% Quantize the values in the table, if necessary
% For each variable in the table
for i = 1:size(observations, 2)
    % If the variable is a parent...
    if ~isempty(obj.parents)
        % If the parent corresponding to the variable is numerical...
        for j = 1:length(obj.parents)
            if strcmp(obj.parents{j}.name, observations.Properties.VariableNames{i})
                if obj.parents{j}.numerical
                    % Quantize the table entries
                    for k = 1:size(observations, 1)
                        observations.(obj.parents{j}.name)(k) = ...
                            obj.parents{j}.quantize(observations.(obj.parents{j}.name)(k));
                    end
                end
            end
        end
    end
    % For the object itself...
    if strcmp(obj.name, observations.Properties.VariableNames{i})
        % If it is numerical...
        if obj.numerical
            % Quantize the table entries
            for k = 1:size(observations, 1)
                observations.(obj.name)(k) = obj.quantize(observations.(obj.name)(k));
            end
        end
    end
end

% Set the factors to 0 (counters)
obj.factor.table.probability = zeros(size(obj.factor.table, 1), 1);

% For each row in the observation table
for row = 1:size(observations, 1)
    
    % Get the row(s) corresponding to each observation
    rows = obj.factor.getSubtable(observations(row, :));
    
    % Increment the counter in the specified rows
    obj.factor.table.probability(rows) = obj.factor.table.probability(rows) + 1;
end

% Normalize the table to obtain a valid distribution
obj.factor = obj.factor.makeDistribution(obj);

end
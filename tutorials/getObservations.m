function tab = getObservations(dataset, varnames)

% Build a data table from a datset file. Input arguments include:
% (1) dataset: Integer vector of observations
% (2) varnames: Variable name for each element

% Convert integer observations to binary vectors
binary = dec2bin(dataset); temp = zeros(size(binary));
for i = 1:size(binary, 1)
    for j = 1:size(binary, 2)
        if binary(i,j) == '1'; temp(i,j) = 1; end
    end
end; binary = temp;

% Convert binary vectors to class
class = cell(size(binary));
for i = 1:size(binary, 1)
    for j = 1:size(binary, 2)
        if binary(i,j) == 0; class{i,j} = Class.false; ...
        else; class{i,j} = Class.true; end
    end
end

% Initialize table
tab = table();

% Build table
for i = 0:length(varnames)-1
    tab = [tab table([class{:,end-i}]')]; names = varnames(1:i+1);
    tab.Properties.VariableNames = names;
end

end
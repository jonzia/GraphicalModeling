function obj = define(obj, varargin)

% -------------------------------------------------------------------------
% SUMMARY
% Define a Node object, including initializing a factor table, specifying
% parents, and/or specifying its possible values. Additionally, nodes may
% be specified as continuous or discrete variables.

% ARGUMENTS (OPT'L)
% - 'parents'       {Node}  Cell vector node Node parents
% - 'factor'        Factor  Factor object for Node
% - 'values'        {Any}   Cell vector of values the node can take
%   - 'Gaussian'    FLAG    If provided, the variable is Gaussian;
%                           'values' is interpreted as [mean, std];
%                           Default is multinomial distribution
%   - 'tol'                 If 'Gaussian', std range outside which
%                           probability is quantized to zero
%   - 'numPoints'           Number of points for Gaussian evaluation
% -------------------------------------------------------------------------

% Set flags
cp = false; val = false; gaussian = false;

% Parse optional inputs
if ~isempty(varargin)
    for arg = 1:length(varargin)
        if strcmp(varargin{arg}, 'parents'); obj.parents = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'factor'); obj.factor = varargin{arg + 1}; cp = true;
        elseif strcmp(varargin{arg}, 'values'); obj.values = varargin{arg + 1}; val = true;
        elseif strcmp(varargin{arg}, 'gaussian'); gaussian = true;
        elseif strcmp(varargin{arg}, 'tol'); tol = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'numPoints'); numPoints = varargin{arg + 1};
        end
    end
end

% Set default values, including for Gaussian distribution
if ~val && ~gaussian
    obj.values = {Class.true, Class.false};     % Default categorical data
elseif ~val
    obj.values = [0, 1];                        % Default Gaussian parameters (mu = 0, sigma = 1)
end

% Determine whether node is numerical or categorical
obj.numerical = true;
for i = 1:length(obj.values)
    if ~isa(obj.values{i}, 'double'); obj.numerical = false; break; end
end

% Return an error if the values are not doubles but 'gaussian' is indicated
if gaussian && ~obj.numerical
    disp("-> Error in define.m: Gaussian distribution cannot be applied to categorical data")
end

% Set default values if none provided
if gaussian && ~exist('numPoints', 'var'); numPoints = 100; end
if gaussian && ~exist('tol', 'var'); tol = 2; end

% Set the Gaussian distribution values if indicated
if gaussian
    mu = obj.values(1); sigma = obj.values(2);
    obj.values = num2cell(linspace(mu - tol*sigma, mu + tol*sigma, numPoints));
end

% Reset the factor table when defining the node
if ~cp
    
    % Get parent names and values
    parentNames = cell(length(obj.parents), 1);
    parentVals = cell(length(obj.parents), 1);
    for i = 1:length(parentNames)
        parentNames{i} = obj.parents{i}.name;
        parentVals{i} = obj.parents{i}.values;
    end
    
    % Add the object's own name and values to the table
    tempNames = parentNames; tempNames{end + 1} = obj.name;
    tempValues = parentVals; tempValues{end + 1} = obj.values;
    
    % Update the factors parent name and value fields
    obj.factor.tableNames = tempNames;
    obj.factor.tableValues = tempValues;
    
    % Create an empty factor table (randomized)
    obj.factor = obj.factor.makeFactor(tempNames, tempValues, {'probability'});
    
    % Make the factor into a valid conditional probability distribution
    obj.factor = obj.factor.makeDistribution(obj);
    
end

end
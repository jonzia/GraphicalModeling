function obj = trainObserved(obj, data, labels, varargin)

% -------------------------------------------------------------------------
% This function trains a HMM where hidden states are observed during
% training. Model parameters may be overridden with varargin.
%
% Arguments (required)
% - data        [NxF]   N observations of F features
% - labels      [Nx1]   Label for each of N observations
%                       (NOTE: labels must be non-zero integers)
%
% Arguments (optional)
% - tranProb    [SxS]   Transition probability matrix
%                       (S states, row = to, col = from)
% - Mu          [FxS]   Feature means given classes
% - Cov         [FxFxS] Feature covariance matrix given classes
% - P_init      [Sx1]   Initial probability (default [1, 0, 0, ... 0])
% - states      {Sx1}   Cell array of state name strings
% - variables   {Fx1}   Cell array of variable name strings
% -------------------------------------------------------------------------

% Parse optional input arguments
if ~isempty(varargin)
    for arg = 1:length(varargin)
        if strcmp(varargin{arg}, 'tranProb'); P = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'Mu'); Mu = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'Cov'); Cov = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'P_init'); P_init = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'states'); states = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'variables'); variables = varargin{arg + 1};
        end
    end
end

% Return the number of features and classes
numFeatures = size(data, 2); numClasses = length(unique(labels));

% Set the initial probability if necessary
if ~exist('P_init', 'var'); P_init = zeros(numClasses, 1); P_init(1) = 1; end

% Compute transition probabilities if necessary
if ~exist('P', 'var')
    
    % Set placeholder for transition probabilities
    P = zeros(numClasses);
    
    % Compute transition probabilities
    % For each class combination
    for i = 1:numClasses
        for j = 1:numClasses
            % Compute P(S_k = i | S_(k-1) = j)
            for k = 2:length(labels)
                if labels(k) == i && labels(k-1) == j
                    P(i, j) = P(i, j) + 1;
                end
            end
        end
    end
    
    % Normalize P by columns (class)
    for j = 1:size(P, 2); P(:, j) = P(:, j)./sum(P(:, j)); end
    
end

% Compute the mean for each feature for each class, if necessary
if ~exist('Mu', 'var')
    
    % Set placeholder for mean feature value
    Mu = zeros(numFeatures, numClasses);
    
    % Compute mean for each feature for each class
    for class = 1:numClasses
        % Extract the data for the current class
        X = data(labels == class, :);
        for feature = 1:numFeatures
            % Compute the mean for the feature
            Mu(feature, class) = mean(X(:, feature));
        end
    end
    
end

% Compute covariance for each feature pair for each class, if necessary
if ~exist('Cov', 'var')
    
    % Set placeholder for feature covariance
    Cov = zeros(numFeatures, numFeatures, numClasses);
    
    % Compute covariance for each feature pair for each class
    for class = 1:numClasses
        % Extract the data for the current class
        X = data(labels == class, :);
        % Compute the covariance for the features
        Cov(:, :, class) = cov(X);
    end
    
end

% Set the number of states and observations
obj = obj.set('numStates', numClasses, 'numObserved', numFeatures);

% Define the state names if necessary
if ~exist('states', 'var')
    states = cell(numClasses, 1);
    for i = 1:numClasses
        states{i} = "S" + string(i);
    end
end

if ~exist('variables', 'var')
    variables = cell(numFeatures, 1);
    for i = 1:numFeatures
        variables{i} = "F" + string(i);
    end
end

% Set the names of the hidden states and observations
obj = obj.set('stateNames', states, 'observedNames', variables);

% Set the probability tables
obj = obj.set('initProb', P_init, 'tranProb', P, 'mu', Mu, 'sigma', Cov);

end


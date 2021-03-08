function path = viterbi(obj, observations, varargin)

% -------------------------------------------------------------------------
% This function computes the Viterbi hidden state path that best explains
% the observed data in the hidden Markov model given the parameters.

% See: https://web.stanford.edu/class/cs224s/lectures/224s.17.lec3.pdf

% Arguments (required)
% - observations    [TxM]   Row-wise matrix of observations

% Arguments (optional)
% - 'plot'          FLAG    Plot results?
% - 'knownStates'   [Mx1]   Vector of state indices, if known
% -------------------------------------------------------------------------

% Parse optional input arguments
if ~isempty(varargin)
    for arg = 1:length(varargin)
        if strcmp(varargin{arg}, 'plot'); Plot = true;
        elseif strcmp(varargin{arg}, 'knownStates'); knownStates = varargin{arg + 1};
        end
    end
end

% Set defaults for optional inputs
if ~exist('Plot', 'var'); Plot = false; end

% Set placeholders
numSteps = size(observations, 1);               % Number of time-steps
viterbi = zeros(obj.numStates, numSteps);       % Probabilities
backpointer = zeros(obj.numStates, numSteps);   % States

% -------------------------------------------------------------------------
% Initialization Step
% -------------------------------------------------------------------------

% For each state...
for s = 1:obj.numStates
    
    % Compute the probability of the observation given state "s"
    b = mvnpdf(observations(1, :), obj.mu(:, s)', obj.sigma(:, :, s));
    
    % Obtain the probability of assignment to state "s"
    viterbi(s, 1) = b*obj.initProb(s);
    
    % Set the backpointer
    [~, backpointer(s, 1)] = max(viterbi(:, 1));
    
end

% -------------------------------------------------------------------------
% Recursion Step
% -------------------------------------------------------------------------

% For each subsequent time-step...
for t = 2:numSteps
    
    % For each state...
    for s = 1:obj.numStates
        
        % Compute the probability of the observation given state "s"
        b = mvnpdf(observations(t, :), obj.mu(:, s)', obj.sigma(:, :, s));
        
        % Obtain the probability of assignment to state "s"
        viterbi(s, t) = max(viterbi(:, t-1).*obj.tranProb(:, s)*b);

        % Set the backpointer
        [~, backpointer(s, t)] = max(viterbi(:, t-1).*obj.tranProb(:, s));
        
    end
    
    % Normalize the viterbi column
    viterbi(:, t) = viterbi(:, t)./sum(viterbi(:, t));
    
end

% -------------------------------------------------------------------------
% Return the backtrace path
% -------------------------------------------------------------------------

% Initialize the path
path = zeros(numSteps, 1);

% Determine final state
[~, path(end)] = max(viterbi(:, end));

% Return the backtrace path
for t = numSteps-1:-1:1; path(t) = backpointer(path(t+1), t+1); end

% -------------------------------------------------------------------------
% Visualize Results
% -------------------------------------------------------------------------

% Visualize results, if necessary
if Plot
    figure; subplot(2, 1, 1); hold on; grid on;
    title("Hidden State"); plot(path)
    % Plot the known states, if they exist
    if exist('knownStates', 'var'); plot(knownStates); legend('Viterbi', 'Actual'); end
    % Plot the observations
    subplot(2, 1, 2); hold on; grid on;
    title("Observations"); plot(observations)
    if ~isempty(obj.observedNames); legend(obj.observedNames); end
end

end


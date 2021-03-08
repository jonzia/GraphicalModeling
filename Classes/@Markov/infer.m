function [states, confidence] = infer(obj, observations, varargin)

% -------------------------------------------------------------------------
% This function infers hidden states from observations given the current
% probability matrices.

% Arguments (required)
% - observations	[MxN]	Array of observations 
%                           (M = #samples, N = #variables)

% Arguments (optional)
% - 'plot'          FLAG	Plot results?
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

% Set defaults for optional arguments
if ~exist('Plot', 'var'); Plot = false; end

% Get the number of observations
numObservations = size(observations, 1);

% Set placeholders for return values
states = zeros(numObservations, 1); confidence = zeros(numObservations, 1);

% -------------------------------------------------------------------------
% Determine Initial State
% -------------------------------------------------------------------------

% argmax_j P(observations | mu_j, sigma_j)P(state_j)
P = zeros(obj.numStates, 1);    % Placeholder for probability of each state
for state = 1:obj.numStates
    % Return probability for argument
    P(state) = mvnpdf(observations(1, :), ...
        obj.mu(:, state)', obj.sigma(:, :, state))*obj.initProb(state);
end

% Record the initial state and confidence of decision
[~, states(1)] = max(P); confidence(1) = getConfidence(P);

% -------------------------------------------------------------------------
% Determine Subsequent States
% -------------------------------------------------------------------------

% For each observation...
for sample = 2:numObservations
    
    % For each state...
    for state = 1:obj.numStates
        % argmax_j P(observations | mu_j, sigma_j)P(state_j | state_i)
        P(state) = mvnpdf(observations(sample, :), ...
            obj.mu(:, state)', obj.sigma(:, :, state))*obj.tranProb(states(sample - 1), state);
    end
    
    % Record the state and confidence of decision
    [~, states(sample)] = max(P); confidence(sample) = getConfidence(P);
    
end

% Normalize the confidence before proceeding
confidence = confidence./max(confidence);

% -------------------------------------------------------------------------
% Visualize Results
% -------------------------------------------------------------------------

% Plot the results, if necessary
if Plot
    figure; subplot(3, 1, 1); hold on; grid on;
    title("Hidden State"); plot(states)
    % Plot the known states, if they exist
    if exist('knownStates', 'var'); plot(knownStates); legend('Inferred', 'Actual'); end
    % Plot the observations
    subplot(3, 1, 2); hold on; grid on;
    title("Observations"); plot(observations)
    if ~isempty(obj.observedNames); legend(obj.observedNames); end
    % Plot the confidence
    subplot(3, 1, 3); hold on; grid on;
    title("Confidence"); plot(confidence); ylim([0, 1])
end

% -------------------------------------------------------------------------
% Sub-Functions
% -------------------------------------------------------------------------
    % Return the confidence given a probability vector
    function confidence = getConfidence(probabilities)
        
        % Confidence is defined as the ratio between the maximum
        % probability and the mean of the vector
        confidence = max(probabilities)/mean(probabilities);
        
    end

end
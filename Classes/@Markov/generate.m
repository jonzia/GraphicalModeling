function [states, observations] = generate(obj, varargin)

% -------------------------------------------------------------------------
% This function generates synthetic data given the transition, emission,
% and initial state probabilities of the Markov model.

% Arguments (optional)
% - 'numSamples'        Number of samples to generate
% - 'plot'      FLAG    Plot results?
% -------------------------------------------------------------------------

% Parse optional input arguments
if ~isempty(varargin)
    for arg = 1:length(varargin)
        if strcmp(varargin{arg}, 'numSamples'); numSamples = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'plot'); Plot = true;
        end
    end
end

% Set defaults
if ~exist('numSamples', 'var'); numSamples = 100; end
if ~exist('Plot', 'var'); Plot = false; end

% Set placeholders for return values
states = zeros(numSamples, 1); observations = zeros(numSamples, obj.numObserved);

% Compute initial state
states(1) = find(mnrnd(1, obj.initProb) == 1);

% Get the mean and covariance matrices for the initial state
mu = obj.mu(:, states(1)); sigma = obj.sigma(:, :, states(1));

% Return a vector of observations for the sample
observations(1, :) = mvnrnd(mu, sigma);

% For each subsequent sample...
for sample = 2:numSamples
    
    % Return the probability transition vector for the current state
    p = obj.tranProb(states(sample - 1), :);
    
    % Determine the next state
    states(sample) = find(mnrnd(1, p) == 1);
    
    % Get the mean and covariance matrices for the sample
    mu = obj.mu(:, states(sample)); sigma = obj.sigma(:, :, states(sample));
    
    % Return a vector of observations for the sample
    observations(sample, :) = mvnrnd(mu, sigma);
    
end

% Plot the results, if indicated
if Plot
    figure; subplot(2, 1, 1); hold on; grid on;
    title("Hidden State"); plot(states)
    subplot(2, 1, 2); hold on; grid on;
    title("Observations"); plot(observations)
    if ~isempty(obj.observedNames); legend(obj.observedNames); end
end

end


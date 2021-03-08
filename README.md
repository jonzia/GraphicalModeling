# Probabilistic Graphical Modeling

## Summary

This collection of MATLAB classes provides an extensible framework for building probabilistic graphical models. Users can define directional or factor graphs, learn or pre-define conditional probability tables, query nodes of the graph, perform variable elimination, and more. The graphs contain the necessary functionality to handle continuous or discrete values, perform message passing, and recursively solve factor graphs. A tutorial of the full functionality of this framework is under development.

This framework contains a separate class which builds on the aforementioned functionality to implement hidden Markov modeling (HMM) with hidden state inference using the Viterbi algorithm. A tutorial for implementing HMMs with this framework is provided below.

## How to Use

### Tutorial 1: Directional Graphs
*Under Development*

### Tutorial 2: Factor Graphs
*Under Development*

### Tutorial 2: Hidden Markov Models (HMM)
In this tutorial, we use a HMM to determine whether each datapoint in a two-dimensional data stream was generated from one of two different Gaussian distributions. In this example, we will define a HMM to generate the data, and run the same model back over the generated data to re-infer the hidden states. To begin, we initialize a blank HMM and set the number of states and observed output variables.
```matlab
% Set the number of states and observations
markov = markov.set('numStates', 2, 'numObserved', 2);
% Set the names of the hidden states and observations
markov = markov.set('stateNames', {'State1', 'State2'}, 'observedNames', {'Output1', 'Output2'});
```
Next, we initialized the probability tables. In this case, we start with State 1; we have a 90% chance of remaining in the current state or switching states; and the observations have state-dependent Gaussian distributions: in State 1, Output 1 has mean 1 and Output 2 has mean 2, and vice-versa in State 2.
```matlab
% Initialize the probability tables
initProb = [1, 0];              % Starting with State 1  
tranProb = [0.9 0.1; 0.1 0.9];  % Propensity to remain in the current state
mu = [1 -1; -1 1];              % The observations have state-dependent Gaussian distributions (mu, sigma)
sigma = zeros(2, 2, 2); sigma(:, :, 1) = 1.0*eye(2); sigma(:, :, 2) = sigma(:, :, 1);
% Set the probability tables in the Markov object
markov = markov.set('initProb', initProb, 'tranProb', tranProb, 'mu', mu, 'sigma', sigma);
```
We then generate a test sequence of 100 samples and plot the results.
```matlab
[states, observations] = markov.generate('numSamples', 100, 'plot');
```
The true hidden states used to generate the data points are captured above. Finally, we use the Viterbi algorithm with the model defined above to re-infer the hidden states from the observations.
```matlab
viterbi_states = markov.viterbi(observations, 'plot', 'knownStates', states);
```
In reality of course, the parameters of the HMM must be learned from the data and will not be available a priori. As this model was developed as an extensible framework, such functionality may be added in the future with methods such as the Baum-Welch algorithm. In the meantime, this tutorial serves as an example of the utility of this framework for performing a variety of higher-level tasks with probabilistic graphical models.

### Additional Help
Additional help is available for each function in the framework by typing `help <Class>.<function> in the command line.

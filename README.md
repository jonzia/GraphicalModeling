# Probabilistic Graphical Modeling

## Summary

This collection of MATLAB classes provides an extensible framework for building probabilistic graphical models. Users can define directional or factor graphs, learn or pre-define conditional probability tables, query nodes of the graph, perform variable elimination, and more. The graphs contain the necessary functionality to handle continuous or discrete values, perform message passing, and recursively solve factor graphs. A tutorial of the full functionality of this framework is under development.

This framework contains a separate class which builds on the aforementioned functionality to implement hidden Markov modeling (HMM) with hidden state inference using the Viterbi algorithm. A tutorial for implementing HMMs with this framework is provided below.

## How to Use

### Tutorial 1: Directional Graphs
For this example, we seek to create a hypothetical diagnostic algorithm relating symptoms to an underlying pathology. The possible symptoms are respiratory problems, gastric problems, rash, cough, fatigue, vomiting, and fever; the season (summer or not summer) is included to adjust for seasonality; and the pathologies are flu, food poisoning, hay fever, and pneumonia. We are provided with a data file (`joint.dat`) which provides the true joint probability distributions over these 12 binary variables, and `dataset.dat`, which contains samples from the probability distributions in `joint.dat`.

#### Graph Creation
We begin by defining a directional graph of the above variables based on our intuition and domain knowledge. We initialize the nodes of the graph as variable nodes and set dependencies once nodes are all initialized. The nodes and dependencies are then wrapped in a `Graph` object.
```matlab
% Initialize graph nodes
summer = Node('isSummer'); hayFever = Node('hasHayFever');
pneumonia = Node('hasPneumonia'); flu = Node('hasFlu');
foodPoisoning = Node('hasFoodPoisoning'); rash = Node('hasRash');
respiratory = Node('hasRespiratoryProblems'); cough = Node('coughs');
gastric = Node('hasGastricProblems'); vomit = Node('vomits');
fatigue = Node('isFatigued'); fever = Node('hasFever');

% Set dependencies
hayFever = hayFever.define('parents', {summer});
pneumonia = pneumonia.define('parents', {summer});
flu = flu.define('parents', {summer});
rash = rash.define('parents', {hayFever});
respiratory = respiratory.define('parents', {hayFever, pneumonia, flu});
cough = cough.define('parents', {hayFever, pneumonia, flu});
gastric = gastric.define('parents', {flu, foodPoisoning});
vomit = vomit.define('parents', {pneumonia, flu, foodPoisoning, gastric});
fatigue = fatigue.define('parents', {hayFever, pneumonia, flu});
fever = fever.define('parents', {pneumonia, flu, foodPoisoning});

% Add nodes to graph
graph = Graph(summer, hayFever, pneumonia, flu, foodPoisoning, rash, respiratory, ...
  cough, gastric, vomit, fatigue, fever);
```
We then build a table from the observations in `dataset.dat`. The function `getObservations()` is provided in the `tutorials` folder.
```matlab
% Load the dataset
dataset = load('dataset.dat');

% Set variable names to import data table
varnames = {summer.name, flu.name, foodPoisoning.name, hayFever.name, pneumonia.name...
  respiratory.name, gastric.name, rash.name, cough.name, fatigue.name, vomit.name, fever.name};

% Import data table
tab = getObservations(dataset, varnames);
```
Once the data table is loaded, we use the table to set the conditional probabilities in the graph and return a table of the estimated joint probabilities when we're done.
```matlab
% Set conditional probabilities
graph = graph.setConditionals(tab);
% Set assignments
graph = graph.setAssignments();
```
To compare our results with the ground-truth, we load the data in `joint.dat` and compute the L1 distance between our estimated joint probability distribution and the ground truth.
```matlab
% Load the joint dataset
joint = load('joint.dat');

% Construct a table from the data
% Get variable combinations
jointTab = getObservations(joint(:,1), varnames);
% Add probabilities to table
jointVarnames = varnames; jointVarnames{13} = 'probability';
jointTab = [jointTab table(joint(:, 2))]; jointTab.Properties.VariableNames = jointVarnames;

% For each row in the table, get the probability of assignment
graph = graph.prob(jointTab);

% Get L1 distance
dist = norm(graph.probabilities.probability - joint(:, 2), 1); disp(dist)
```

#### Querying the Model
By querying our trained model, we can determine the probability that a node will take a value based on certain priors. For instance, we can determine the probability that our patient has the flu given that they have a cough and fever.
```matlab
query1 = graph.query({flu}, {cough, fever}, {Class.true, Class.true}); disp(query1)
```
We can also query the value of more than one variable given one or more conditions.
```matlab
query2 = graph.query({rash, cough, fatigue, vomit, fever}, {pneumonia}, {Class.true}); disp(query2)
```

#### Variable Elimination
We may eliminate variables from the graph by providing the node(s) to evaluate, followed by our conditionals, followed by the order in which to perform elimination.
```matlab
query3 = graph.eliminate({flu}, {cough, fever}, {Class.true, Class.true}, ...
  {cough, fever, respiratory, gastric, rash, fatigue, vomit, foodPoisoning, hayFever, ...
  pneumonia, summer});
```
Alternatively, we may evaluate more than one node and eliminate the rest.
```matlab
query4 = graph.eliminate({rash, cough, fatigue, vomit, fever}, {pneumonia}, {Class.true}, ...
  {gastric, respiratory, flu, foodPoisoning, hayFever, pneumonia, summer});
```

### Tutorial 2: Factor Graphs
*Under Development*

### Tutorial 3: Hidden Markov Models (HMM)
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
Additional help is available for each function in the framework by typing `help <Class>.<function>` in the command line.

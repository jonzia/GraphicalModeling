classdef Markov
    
    % Class for defining, training, and testing hidden markov models (HMMs)
    
    properties (GetAccess = public, SetAccess = private)
        name            % Model description
        numStates       % Number of hidden states
        numObserved     % Number of observed variables
        stateNames      % Cell vector of hidden state names
        observedNames   % Cell vector of observed variable names
        tranProb        % Array of state transition probabilities
                        % (dim1 = source; dim2 = destination)
        mu              % Array of mean values for emission probabilities
                        % (dim1 = variable; dim2 = hidden state)
        sigma           % Covariance matrix for emission probabilities
                        % (dim1/2 = variable; dim3 = hidden state)
        initProb        % Vector of initial state probabilities
    end
    
    methods
        
        % Object constructor
        function obj = Markov(name, varargin)
            
            % Parse optional input arguments
            if ~isempty(varargin)
                for arg = 1:length(varargin)
                    if strcmp(varargin{arg}, 'numStates'); obj.numStates = varargin{arg + 1};
                    elseif strcmp(varargin{arg}, 'numObserved'); obj.numObserved = varargin{arg + 1};
                    elseif strcmp(varargin{arg}, 'tranProb'); obj.tranProb = varargin{arg + 1};
                    elseif strcmp(varargin{arg}, 'mu'); obj.mu = varargin{arg + 1};
                    elseif strcmp(varargin{arg}, 'sigma'); obj.sigma = varargin{arg + 1};
                    elseif strcmp(varargin{arg}, 'initProb'); obj.initProb = varargin{arg + 1};
                    elseif strcmp(varargin{arg}, 'stateNames'); obj.stateNames = varargin{arg + 1};
                    elseif strcmp(varargin{arg}, 'observedNames'); obj.observedNames = varargin{arg + 1};
                    end
                end
            end
            
            % Set given parameters
            obj.name = name;
            
        end
        
        % Set class properties
        function obj = set(obj, varargin)
            
            % Parse optional input arguments
            if ~isempty(varargin)
                for arg = 1:length(varargin)
                    if strcmp(varargin{arg}, 'numStates'); obj.numStates = varargin{arg + 1};
                    elseif strcmp(varargin{arg}, 'numObserved'); obj.numObserved = varargin{arg + 1};
                    elseif strcmp(varargin{arg}, 'tranProb'); obj.tranProb = varargin{arg + 1};
                    elseif strcmp(varargin{arg}, 'mu'); obj.mu = varargin{arg + 1};
                    elseif strcmp(varargin{arg}, 'sigma'); obj.sigma = varargin{arg + 1};
                    elseif strcmp(varargin{arg}, 'initProb'); obj.initProb = varargin{arg + 1};
                    elseif strcmp(varargin{arg}, 'stateNames'); obj.stateNames = varargin{arg + 1};
                    elseif strcmp(varargin{arg}, 'observedNames'); obj.observedNames = varargin{arg + 1};
                    end
                end
            end
            
        end
        
        % Randomly initialize probability tables
        function obj = randInit(obj)
            
            % Check to see whether necessary arguments are provided
            if isempty(obj.numStates) || isempty(obj.numObserved)
                disp("-> Error in randInit(): Must define number of hidden states and observed variables")
            end
            
            % Create transition probability array
            obj.tranProb = rand(obj.numStates, obj.numStates);
            obj.tranProb = obj.tranProb./sum(obj.tranProb, 2);
            
            % Create initial state probability array
            obj.initProb = rand(obj.numStates, 1);
            obj.initProb = obj.initProb./sum(obj.initProb);
            
            % Create emission probability array
            obj.mu = rand(obj.numObserved, obj.numStates);
            obj.sigma = rand(obj.numObserved, obj.numObserved, obj.numStates);
            
        end
        
        % Generate synthetic data given probability tables
        [states, observations] = generate(obj, varargin)
        
        % Infer hidden states from observations (average state path)
        [states, confidence] = infer(obj, observations, varargin)
        
        % Todo: Train model to learn probability matrices (QDA)
        obj = train(obj, observations, states, varargin)
        
        % Viterbi Decoding
        states = viterbi(obj, observations, varargin)
        
    end
    
end


classdef Graph
    
    % Graphical model object
    
    properties (GetAccess = public, SetAccess = public)
        nodes               % Cell vector of Node objects
        assignments Factor  % Table of possible variable assignments
    end
    
    methods
        
        function obj = Graph(varargin)
            %Construct an instance of this class
            % A list of variable nodes is accepted
            
            % Set placeholder for variable nodes
            varnodes = cell(length(varargin), 1);
            
            % Parse the list of variable nodes and return the output
            for i = 1:length(varargin); varnodes{i} = varargin{i}; end
            obj.nodes = varnodes;
        end
        
        function obj = addNodes(obj, varargin)
            % Add nodes to the object
            % Parse the list of variable nodes and add to graph property
            for i = 1:length(varargin); obj.nodes{end+1} = varargin{i}; end
        end
        
        function obj = setConditionals(obj, tab)
            % Set conditionals for all nodes in graph with data table
            for i = 1:length(obj.nodes); obj.nodes{i} = obj.nodes{i}.setConditionals(tab); end
        end
        
        % Get probability distribution table based on query conditions
        queryTable = query(obj, varargin)
        
        % Perform variable elimination to get distribution
        probTable = eliminate(obj, evaluate, givenNodes, givenVals, order)
        
        % Evaluate all nodes in graph (factor graphs only)
        obj = solve(obj)
        
        function obj = setAssignments(obj)
            % Construct table of variable assignments
            % Perform factor multiplication of all graph factors
            temp = obj.nodes{1}.factor;
            for i = 2:length(obj.nodes)
                temp = temp.multiply(obj.nodes{i}.factor);
            end
            % Return assignment table (with joint probabilities)
            obj.assignments = temp;
        end
        
    end
end


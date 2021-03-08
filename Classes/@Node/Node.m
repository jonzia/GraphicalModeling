classdef Node
    
    % Class for variable and factor nodes in graphical model
    
    properties (GetAccess = public, SetAccess = public)
        name                % Node name
        values              % List of values for variable node
        parents             % Cell array of Varnode objects
        factor Factor       % Conditional probability table
        type NodeType       % Type of node (variable or factor)
        evaluated logical   % Has the node been evaluated?
        numerical logical   % Are the node values numerical?
        value               % Value for evaluation
    end
    
    methods
        
        % Class constructor
        function obj = Node(name, varargin)
            
            % The constructor creates a node, optionally defining the node
            % if additional information is provided. The following may be
            % provided for node definition:
            % - 'parents'   {Node}  Cell vector node Node parents
            % - 'factor'    Table   Factor table for Node
            % - 'values'	{Any}   Cell vector of values the node can take
            %   - 'Gaussian', 'tol', 'numPoints'    (see define.m)
            % The following may be provided for the constructor:
            % - 'type'      NodeType
            
            % Set the node type
            obj.type = NodeType.variable;
            if ~isempty(varargin)
                for arg = 1:length(varargin)
                    if isa(varargin{arg}, 'NodeType'); ...
                            obj.type = varargin{arg}; break; end
                end
            end
            
            % Set object values
            obj.name = name; obj.factor = Factor(obj.name); obj.evaluated = false;
            
            % Define the object
            obj = obj.define(varargin{:});
            
        end
        
        % Set node properties
        obj = define(obj, varargin)
        
        % Query node
        result = query(obj, varargin)
        
        % Set conditionals based on observations
        obj = setConditionals(obj, table);
        
        % Evaluate node given parent messages
        obj = evaluate(obj)
        
        % Write a value to the node (variable only)
        function obj = write(obj, value)
            if obj.type == NodeType.variable
                tab = table(value); tab.Properties.VariableNames = {obj.name};
                obj.value = tab; obj.evaluated = true;
            end
        end
        
        % Return a quantized value based on the node's possible values
        val = quantize(obj, value)
        
    end
    
end
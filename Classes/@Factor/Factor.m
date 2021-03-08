classdef Factor
    
    % Class for factor objects for graphical models
    
    properties
        name            % Factor name
        table           % Factor table
        tableNames      % Names of factor table fields
        tableValues     % Values of each factor table field
    end
    
    methods
        
        % Constructor
        function obj = Factor(name)
            obj.name = name;
        end
        
        % Initialize random factor table
        obj = makeFactor(obj, names, values, varargin)
        
        % Make factor table into a valid distribution
        obj = makeDistribution(obj, parents)
        
        % Factor multiplication
        factor = multiply(obj, multiplicand)
        
    end
end


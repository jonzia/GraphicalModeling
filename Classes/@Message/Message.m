classdef Message < Factor
    
    % Class for message objects
    
    properties (SetAccess = private, GetAccess = public)
        type MessageType	% Type of message
    end
    
    methods
        
        % Constructor
        function obj = Message(name, type)
            obj@Factor(name); obj.type = type;
        end
        
        % Compute lookup table with factor multiplication
        obj = createMessage(obj, parents, eval, over)
        
    end
end


function val = quantize(obj, value)

% -------------------------------------------------------------------------
% SUMMARY
% Set the node's value to a quantized version of an input value. The input
% value is quantized based on the node's possible values. For categorical
% nodes, verify whether the input value is valid.

% ARGUMENTS (REQ'D)
% - value   Value which to quantize
% -------------------------------------------------------------------------

% If the node is not numerical, verify that the category is present
if ~obj.numerical
    
    valid = false;  % Set default
    % Determine whether category is present
    for i = 1:length(obj.values); if value == obj.values{i}; valid = true; end; end
    
    % If the category was not present, return an error
    if ~valid; disp("-> Error in quantize.m: Input value is invalid"); val = nan;
    else; val = value;
    end
    
end

if obj.numerical
    
    % Get the distance between each possible value and provided value
    vals = cell2mat(obj.values); distance = abs(vals - value);

    % Find the index that minimizes the distance
    [~, idx] = min(distance);

    % Return the quantized value
    val = vals(idx);
    
end

end
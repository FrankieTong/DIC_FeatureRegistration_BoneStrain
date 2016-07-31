function [r_squared, offset, slope] = Skeletonization_Linear_Model(ideal_values, actual_values)

%Calculate line of best fit and identify offset and slope
%Calculate R^2 with Strain Calculated vs Strain Ideal

if isrow(ideal_values)
    ideal_values = ideal_values';
end

if isrow(actual_values)
    actual_values = actual_values';
end

F = [ideal_values.^0 ideal_values];           % make design matrix [1,x]  //ideal

c = F\actual_values;                  % get least-squares fit
res = actual_values - F*c;           % calculate residuals
r_squared = 1 - nanvar(res)/nanvar(actual_values);  % calculate R^2
offset = c(1);
slope = c(2);

% 
% disp('Strain Percentage Calculated vs. Strain Percentage Ideal');

% string = sprintf('R^2: %f',r_squared);
% disp(string);
% string = sprintf('Offset: %f',c(1));
% disp(string);
% string = sprintf('Slope: %f',c(2));
% disp(string);

end


function [mean_error, std_deviation, ten_percentile, ninety_percentile, directional_similarity, difference_of_magnitude, magnitude_of_difference] = Skeletonization_Error(ideal_values, actual_values)

%Calculate directional simularity, difference of magnitude and magnitude of
%difference
if isrow(ideal_values)
    ideal_values = ideal_values';
end

if isrow(actual_values)
    actual_values = actual_values';
end

error = actual_values - ideal_values;
mean_error = nanmean(error);
std_deviation = nanstd(error);
ten_percentile = prctile(error,10);
ninety_percentile = prctile(error,90);

directional_similarity = nanmean(actual_values.*ideal_values./abs(actual_values.*ideal_values));
difference_of_magnitude = nanmean(abs(actual_values) - abs(ideal_values));
magnitude_of_difference = nanmean(abs(actual_values - ideal_values));

% 
% disp('Strain Percentage Calculated vs. Strain Percentage Ideal');

% string = sprintf('R^2: %f',r_squared);
% disp(string);
% string = sprintf('Offset: %f',c(1));
% disp(string);
% string = sprintf('Slope: %f',c(2));
% disp(string);

end


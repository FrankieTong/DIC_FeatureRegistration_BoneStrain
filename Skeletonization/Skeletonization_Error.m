function [mean_error, absolute_mean_error, std_deviation, ten_percentile, ninety_percentile, directional_similarity, difference_of_magnitude, magnitude_of_difference] = Skeletonization_Error(ideal_values, actual_values)

    %Calculate directional simularity, difference of magnitude and magnitude of
    %difference
    
    % Assuming the input is 2 column vectors of values with size = [n by dim]

    error = actual_values - ideal_values;
    
    if size(error,2) == 1
        mean_error = nanmean(error);
        absolute_mean_error = nanmean(abs(error));
        std_deviation = nanstd(error);
        ten_percentile = prctile(error,10);
        ninety_percentile = prctile(error,90);
    else
        mean_error = NaN;
        absolute_mean_error = NaN;
        std_deviation = NaN;
        ten_percentile = NaN;
        ninety_percentile = NaN;
    end

    magnitude_actual_values = sqrt(diag(actual_values*actual_values'));
    magnitude_ideal_values = sqrt(diag(ideal_values*ideal_values'));
    
    directional_similarity = nanmean(diag(actual_values*ideal_values')./(magnitude_actual_values.*magnitude_ideal_values));
    difference_of_magnitude = nanmean(abs(magnitude_actual_values) - abs(magnitude_ideal_values));
    magnitude_of_difference = nanmean(sqrt(diag(error*error')));

    % 
    % disp('Strain Percentage Calculated vs. Strain Percentage Ideal');

    % string = sprintf('R^2: %f',r_squared);
    % disp(string);
    % string = sprintf('Offset: %f',c(1));
    % disp(string);
    % string = sprintf('Slope: %f',c(2));
    % disp(string);

end


global t EPSyyRW

X = EPSyyRW{t}(:,1);
Y = EPSyyRW{t}(:,2);

% Cook's Distance for a given data point measures the extent to 
% which a regression model would change if this data point 
% were excluded from the regression. Cook's Distance is 
% sometimes used to suggest whether a given data point might be an outlier.

% Use regstats to calculate Cook's Distance
stats = regstats(Y,X,'linear');

% if Cook's Distance > n/4 is a typical treshold that is used to suggest
% the presence of an outlier
potential_outlier = stats.cookd > 4/length(X);

% Display the index of potential outliers and graph the results
X(potential_outlier)
scatter(X,Y, 'b.')
hold on
scatter(X(potential_outlier),Y(potential_outlier), 'r.')

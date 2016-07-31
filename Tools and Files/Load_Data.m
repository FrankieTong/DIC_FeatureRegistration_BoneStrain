function RD = Load_Data(file_name)

% Open the raw data file
file_id = fopen(file_name, 'rt');

% The first lines of the raw data file should be dates with the following formats
% "July 20, 2007 - 18:24:55"   and  " 2007-07-20, 18'24'55
reader = textscan(file_id, '%s%s%s%s', 1, 'delimiter', '"');
RD.date_time_long = cell2mat(reader{2});
RD.date_time_short = cell2mat(reader{4});
clear reader

% The next raw file line says how the images were compared (Regular DIC, or Incremental DIC)
reader = textscan(file_id, '%s', 1);
if isequal(cell2mat(reader{1}), 'Regular')
    RD.do_incremental = 0;
elseif isequal(cell2mat(reader{1}), 'Incremental')
    RD.do_incremental = 1;
end
clear reader

% The raw file then writes a row with all the names of the variables.
reader = textscan(file_id, '%s', 3, 'delimiter', '\n');
var_names = textscan(reader{1,1}{3,1}, '%s', 'delimiter', ',');
clear reader

% Now the values for all these are stored in the rest of the file create a
% format based on how many variables were saved
var_format = '';
for i = 1:numel(var_names{1})
    var_format = strcat(var_format, '%n');
end
reader = textscan(file_id, var_format, 'delimiter', ',');

% Since the first column can be shorter than later ones, define when the NaNs start appearing
orig_end = numel( find(isfinite( reader{1,1} )));


% Now we can redefine values we had before
xp_first = reader{1,1}(1,1); 
xp_last = reader{1,1}(orig_end,1);
yp_first = reader{1,2}(1,1);
yp_last = reader{1,2}(orig_end, 1);

subset_space = reader{1,1}(2) - reader{1,1}(1);
if subset_space < 1
    subset_space = reader{1,2}(2) - reader{1,2}(1);
end

% Compute useful values
num_subsets_X = floor( (xp_last-xp_first)/subset_space ) + 1;
num_subsets_Y = floor( (yp_last-yp_first)/subset_space ) + 1;

if numel(var_names{1}) < 20 % 0th order raw data file
    % Retrieve the results for the original grid and make them into matrices (not vectors)
    RD.orig_gridX = reshape( reader{1,1}(1:orig_end), num_subsets_Y, num_subsets_X);
    RD.orig_gridY = reshape( reader{1,2}(1:orig_end), num_subsets_Y, num_subsets_X);
    TOTAL_DEFORMATIONS(:,:,1) = reshape( reader{1,3}(1:orig_end), num_subsets_Y, num_subsets_X );
    TOTAL_DEFORMATIONS(:,:,2) = reshape( reader{1,4}(1:orig_end), num_subsets_Y, num_subsets_X );
    TOTAL_DEFORMATIONS(:,:,3) = reshape( reader{1,5}(1:orig_end), num_subsets_Y, num_subsets_X );
    RD.TOTAL_DEFORMATIONS = TOTAL_DEFORMATIONS;
    INCREM_DEFORMATIONS(:,:,1) = reshape( reader{1,6}(1:orig_end), num_subsets_Y, num_subsets_X );
    INCREM_DEFORMATIONS(:,:,2) = reshape( reader{1,7}(1:orig_end), num_subsets_Y, num_subsets_X );
    INCREM_DEFORMATIONS(:,:,3) = reshape( reader{1,5}(1:orig_end), num_subsets_Y, num_subsets_X );
    RD.INCREM_DEFORMATIONS = INCREM_DEFORMATIONS;

    % Do the current values - NOTE, the following are not always the same as above
    Xp_first = reader{1,9}(1,1); 
    Xp_last = reader{1,9}(end,end);
    Yp_first = reader{1,10}(1,1);
    Yp_last = reader{1,10}(end, end);

    % Compute useful values
    num_subsets_X = floor( (Xp_last-Xp_first)/subset_space ) + 1;
    num_subsets_Y = floor( (Yp_last-Yp_first)/subset_space ) + 1;

    % Retrieve the results for the latest grid and make them into matrices (not vectors)
    RD.X_def_grid = reshape( reader{1,9}, num_subsets_Y, num_subsets_X );
    RD.Y_def_grid = reshape( reader{1,10}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,1) = reshape( reader{1,11}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,2) = reshape( reader{1,12}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,3) = reshape( reader{1,13}, num_subsets_Y, num_subsets_X );
    RD.DEFORMATION_PARAMETERS = DEFORMATION_PARAMETERS;
    
    % Store that this is a zeroth order DIC
    RD.Subset_Deform_Order = 0;
    
else % 1st order raw data file
    % Retrieve the results for the original grid and make them into matrices (not vectors)
    RD.orig_gridX = reshape( reader{1,1}(1:orig_end), num_subsets_Y, num_subsets_X);
    RD.orig_gridY = reshape( reader{1,2}(1:orig_end), num_subsets_Y, num_subsets_X);
    TOTAL_DEFORMATIONS(:,:,1) = reshape( reader{1,3}(1:orig_end), num_subsets_Y, num_subsets_X );
    TOTAL_DEFORMATIONS(:,:,2) = reshape( reader{1,4}(1:orig_end), num_subsets_Y, num_subsets_X );  
    TOTAL_DEFORMATIONS(:,:,3) = reshape( reader{1,6}(1:orig_end), num_subsets_Y, num_subsets_X );
    TOTAL_DEFORMATIONS(:,:,4) = reshape( reader{1,7}(1:orig_end), num_subsets_Y, num_subsets_X );
    TOTAL_DEFORMATIONS(:,:,5) = reshape( reader{1,8}(1:orig_end), num_subsets_Y, num_subsets_X );
    TOTAL_DEFORMATIONS(:,:,6) = reshape( reader{1,9}(1:orig_end), num_subsets_Y, num_subsets_X );
    TOTAL_DEFORMATIONS(:,:,7) = reshape( reader{1,5}(1:orig_end), num_subsets_Y, num_subsets_X );
    RD.TOTAL_DEFORMATIONS = TOTAL_DEFORMATIONS;
    INCREM_DEFORMATIONS(:,:,1) = reshape( reader{1,10}(1:orig_end), num_subsets_Y, num_subsets_X );
    INCREM_DEFORMATIONS(:,:,2) = reshape( reader{1,11}(1:orig_end), num_subsets_Y, num_subsets_X );
    INCREM_DEFORMATIONS(:,:,3) = reshape( reader{1,12}(1:orig_end), num_subsets_Y, num_subsets_X );
    INCREM_DEFORMATIONS(:,:,4) = reshape( reader{1,13}(1:orig_end), num_subsets_Y, num_subsets_X );
    INCREM_DEFORMATIONS(:,:,5) = reshape( reader{1,14}(1:orig_end), num_subsets_Y, num_subsets_X );
    INCREM_DEFORMATIONS(:,:,6) = reshape( reader{1,15}(1:orig_end), num_subsets_Y, num_subsets_X );
    INCREM_DEFORMATIONS(:,:,7) = reshape( reader{1,5}(1:orig_end), num_subsets_Y, num_subsets_X );
    RD.INCREM_DEFORMATIONS = INCREM_DEFORMATIONS;

    % Do the current values - NOTE, the following are not always the same as above
    Xp_first = reader{1,17}(1,1); 
    Xp_last = reader{1,17}(end,end);
    Yp_first = reader{1,18}(1,1);
    Yp_last = reader{1,18}(end, end);

    % Compute useful values
    num_subsets_X = floor( (Xp_last-Xp_first)/subset_space ) + 1;
    num_subsets_Y = floor( (Yp_last-Yp_first)/subset_space ) + 1;

    % Retrieve the results for the latest grid and make them into matrices (not vectors)
    RD.X_def_grid = reshape( reader{1,17}, num_subsets_Y, num_subsets_X );
    RD.Y_def_grid = reshape( reader{1,18}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,1) = reshape( reader{1,19}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,2) = reshape( reader{1,20}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,3) = reshape( reader{1,22}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,4) = reshape( reader{1,23}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,5) = reshape( reader{1,24}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,6) = reshape( reader{1,25}, num_subsets_Y, num_subsets_X );
    DEFORMATION_PARAMETERS(:,:,7) = reshape( reader{1,21}, num_subsets_Y, num_subsets_X );
    RD.DEFORMATION_PARAMETERS = DEFORMATION_PARAMETERS;
    
    % Store that this is a 1st order DIC
    RD.Subset_Deform_Order = 1;
end

% Compute the subset spacing using two points
RD.subset_space = subset_space;

fclose(file_id);

end % function

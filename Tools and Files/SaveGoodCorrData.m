%{
This file is part of the McGill Digital Image Correlation Research Tool (MDICRT).
Copyright © 2010, Jeffrey Poissant, Francois Barthelat

MDICRT is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

MDICRT is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with MDICRT.  If not, see <http://www.gnu.org/licenses/>.


% Digital Image Correlation: Save Good Correlation Data
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  June 27, 2010
% Modified on: 


---------------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: SAVE GOOD CORRELATION DATA     |
---------------------------------------------------------------

This M-File will store some key parameters used in the subset splitting
method for review later on.

%}

function SaveGoodCorrData(goodCorr, split_tol, f_g_tol, beforeSS)

% Load in some global variables
global Xp_first;
global Yp_first;
global Xp_last;
global Yp_last;
global subset_space;
global date_time_run;
global do_incremental;

% Save the current directory
tmp_directory = pwd;

% Return to the root DIC directory
cd('..');

% The output folder contains the start date_time when the "RUN" button was pressed
date_time_folder = datestr(date_time_run, ' yyyy-mm-dd, HH''MM''SS');

% Define the path where new outputs will be saved
output_folder_path = sprintf('%s\\DIC Outputs for %s', cd, date_time_folder);

% Record the date and time now for the subset splitting files
date_time = now;
date_time_long = datestr(date_time, 'mmmm dd, yyyy - HH:MM:SS');
date_time_short = datestr(date_time, ' yyyy-mm-dd, HH''MM''SS');

% Make the directory (in case it hasn't been created yet)
[tmp1, tmp2, tmp3] = mkdir(output_folder_path, 'PreSplit Info');
clear tmp1 tmp2 tmp3;

% Are we recording data before subset splitting?
if beforeSS == true
    % Define the filenames and open the first file
    presplit_name = strcat(output_folder_path, '\PreSplit Info\PreSplit Info', date_time_short, '.txt');
    goodcorr_name = strcat(output_folder_path, '\PreSplit Info\GoodCorrBeforeSS', date_time_short, '.txt');
    
    file_ID1 = fopen(presplit_name, 'w');
    
    % The first line contains date information
    fprintf(file_ID1, '"%s", "%s"', date_time_long, date_time_short);
    
    % The second line mentions which method was used to compare images
    if do_incremental == true
        fprintf(file_ID1, '\nIncremental');
    else
        fprintf(file_ID1, '\nRegular');
    end

    % The next line will print some useful information
    fprintf(file_ID1, '\nSplitting Tolerance C_st =, %s', split_tol);
    fprintf(file_ID1, '\nf_g_tol = , %s', f_g_tol);

    fclose(file_ID1);   
else
    % Define the original filename and open this file
    goodcorr_name = strcat(output_folder_path, '\PreSplit Info\GoodCorrAfterSS', date_time_short, '.txt');
end
    
% Open the good corr file
file_ID2 = fopen(goodcorr_name, 'w');

% The following lines contain the names of all the variables and their respective values
fprintf(file_ID2, strcat('X, Y, GoodCorr') );

% Compute how many subsets are in each direction
num_subsets_X = floor( (Xp_last-Xp_first)/subset_space ) + 1;
num_subsets_Y = floor( (Yp_last-Yp_first)/subset_space ) + 1;

% Define the X and Y coordinates of each subset center
mesh_col = Xp_first:subset_space:(num_subsets_X-1)*subset_space+Xp_first;
mesh_row = Yp_first:subset_space:(num_subsets_Y-1)*subset_space+Yp_first;
    
% Create a grid to represent the subset centers of the current correlation
[X_def_grid, Y_def_grid] = meshgrid( mesh_col, mesh_row );

myH = figure('Units', 'normalized');
set(gcf, 'Position', [0.025;0.05;0.95;0.85]);
surf(X_def_grid, Y_def_grid, goodCorr, 'LineStyle', 'none'); view(0,90);
title('Good Corr', 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        
colorbar;
xlim([X_def_grid(1,1), X_def_grid(end,end)]);    
ylim([Y_def_grid(1,1), Y_def_grid(end,end)]);
xlabel('x (pixels)', 'FontName', 'Arial', 'FontSize', 14); 
ylabel('y (pixels)', 'FontName', 'Arial', 'FontSize', 14);
set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);
if beforeSS == true
    saveas(myH, strcat(output_folder_path, '\PreSplit Info\goodCorrBeforeSS', date_time_short, '.tif') );
else
    saveas(myH, strcat(output_folder_path, '\PreSplit Info\goodCorrAfterSS', date_time_short, '.tif') );
end
close(myH);

% Reshape all the required vectors to print out the data
X_current_grid          = reshape(X_def_grid, numel(X_def_grid), 1);
Y_current_grid          = reshape(Y_def_grid, numel(Y_def_grid), 1);
good_corr_current_grid  = reshape(goodCorr, numel(goodCorr), 1);

for ii = 1:numel(X_def_grid)
        fprintf(file_ID2, '\n%g, %g, %g', X_current_grid(ii), Y_current_grid(ii), good_corr_current_grid(ii) );
end


fclose(file_ID2);

% Return to the original directory
cd(tmp_directory);

end % function
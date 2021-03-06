%{
This file is part of the McGill Digital Image Correlation Research Tool (MDICRT).
Copyright � 2008, Jeffrey Poissant, Francois Barthelat

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


% Digital Image Correlation: End Correlation Processing
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  July 18, 2007
% Modified on: July 30, 2007


---------------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: END CORRELATION PROCESSING     |
---------------------------------------------------------------

This M-File represents the processing that occurs after performing
Digital Image Correlation on a reference and deformed image.

In order to minimize the number of files that need to be edited, this 
M-file will be made as general as needed to ensure that any correlation 
method can call this one main function to process/save their results.

%}


function output_folder_path = End_NoSplit_Correlation(DEFORMATION_PARAMETERS, good_corr, mean_C, f_g_tol)

%_______END-CORRELATION-PROCESSING___________________________________________

% Recall several varibles to be saved
global Xp_first;
global Yp_first;
global Xp_last;
global Yp_last;
global subset_space;
global qo;
global do_incremental;
global last_WS;
global Input_info;
global date_time_run;

% Compute useful values
num_subsets_X = floor( (Xp_last-Xp_first)/subset_space ) + 1;
num_subsets_Y = floor( (Yp_last-Yp_first)/subset_space ) + 1;
total_num_subsets = num_subsets_X*num_subsets_Y;


%------------------------FINDING TOTAL/INCREM DEFORMATIONS-------------------------------

% The main results of correlation are stored in an M-by-N-by-k matrix named DEFORMATION_PARAMETERS
% k changes depending on the Subset Deformations chosen.
k = size(DEFORMATION_PARAMETERS, 3);

% Define the X and Y coordinates of each subset center
mesh_col = Xp_first:subset_space:(num_subsets_X-1)*subset_space+Xp_first;
mesh_row = Yp_first:subset_space:(num_subsets_Y-1)*subset_space+Yp_first;
    
% Create a grid to represent the subset centers of the current correlation
[X_def_grid, Y_def_grid] = meshgrid( mesh_col, mesh_row );

% Recall the original grid used on the first reference image of this run
orig_gridX = last_WS.orig_gridX;
orig_gridY = last_WS.orig_gridY;
    
if do_incremental == true
    
    % Recall the previous total u and v displacements to define the original
    % grid's current deformed positions (x*, y*)
    x_star = orig_gridX + last_WS.TOTAL_DEFORMATIONS(:,:,1);
    y_star = orig_gridY + last_WS.TOTAL_DEFORMATIONS(:,:,2);
    
    % The original grid was made of m-by-n points
    [m,n] = size(orig_gridX);
    
    % Computing the TOTAL_DEFORMATIONS and INCREM_DEFORMATIONS differs for split/not-split subsets
    if isequal(Input_info{3}, 'Zeroth Order with Subset Slicing') == true || isequal(Input_info{3}, 'First Order with Subset Slicing')
        % Preallocate the TOTAL_DEFORMATION and INCREM_DEFORMATIONS matrices
        TOTAL_DEFORMATIONS = zeros(m, n, k);
        INCREM_DEFORMATIONS = zeros(m, n, k);
        
        % Since the incremental method compares, def_i and def_i+1, the interpolated values 
        % at x*, y* represent the incremental deformations.
        % To obtain the total deformations, the incremental deformations are added to the previous total deformations
        for itr = 1:k-3
            INCREM_DEFORMATIONS(:,:,itr) = interp2(X_def_grid, Y_def_grid, DEFORMATION_PARAMETERS(:,:,itr), x_star, y_star, 'cubic' );
            TOTAL_DEFORMATIONS(:,:,itr) = last_WS.TOTAL_DEFORMATIONS(:,:,itr) + INCREM_DEFORMATIONS(:,:,itr);
        end
        % Not all terms are growing: for example, the correlation quality "C" does not have a total amount, 
        % however I save it within TOTAL_DEFORMATIONS to make both INCREM_ and TOTAL_ the same size
        for itr = k-2:k
            INCREM_DEFORMATIONS(:,:,itr) = interp2(X_def_grid, Y_def_grid, DEFORMATION_PARAMETERS(:,:,itr), x_star, y_star, 'cubic' );
            TOTAL_DEFORMATIONS(:,:,itr) = INCREM_DEFORMATIONS(:,:,itr);
        end
                                            
    else            % if 'First Order of Zeroth Order DIC'
        % Preallocate the TOTAL_DEFORMATION and INCREM_DEFORMATIONS matrices
        TOTAL_DEFORMATIONS = zeros(m, n, k);
        INCREM_DEFORMATIONS = zeros(m, n, k);
        
        % Since the incremental method compares, def_i and def_i+1, the interpolated values
        % at x*, y* represent the incremental deformations.
        % To obtain the total deformations, the incremental deformations are added to the previous total deformations
        for itr = 1:k-1
            INCREM_DEFORMATIONS(:,:,itr) = interp2(X_def_grid, Y_def_grid, DEFORMATION_PARAMETERS(:,:,itr), x_star, y_star, 'cubic' );
            TOTAL_DEFORMATIONS(:,:,itr) = last_WS.TOTAL_DEFORMATIONS(:,:,itr) + INCREM_DEFORMATIONS(:,:,itr);
        end
        INCREM_DEFORMATIONS(:,:,k) = interp2(X_def_grid, Y_def_grid, DEFORMATION_PARAMETERS(:,:,k), x_star, y_star, 'cubic' );
        TOTAL_DEFORMATIONS(:,:,k) = INCREM_DEFORMATIONS(:,:,k);
    end
 
                                        
    % Store the first result as the initial guess for any subsequent correlations
    % Notice that in this case, the deformation is between def_i and def_i+1, not ref (def_0) and def_i+1
    qo(1:2) = round(DEFORMATION_PARAMETERS(1,1,1:2));
    if k-1 >= 3
        qo(3:k-1) = DEFORMATION_PARAMETERS(1,1,3:k-1);
    end
    
    
else % do_incremental == false
    
    % Save the current results as the total deformations (from ref to def_i+1)
    TOTAL_DEFORMATIONS = DEFORMATION_PARAMETERS;
    
    % Each deformation parameter is a grid of m-by-n points
    [m,n] = size(TOTAL_DEFORMATIONS(:,:,1));
    
    % Computing the INCREM_DEFORMATIONS differs for split/not-split subsets
    if isequal(Input_info{3}, 'Zeroth Order with Subset Slicing') == true || isequal(Input_info{3}, 'First Order with Subset Slicing')
        % Preallocate the INCREM_DEFORMATION matrix
        INCREM_DEFORMATIONS = zeros(m, n, k);
        
        % Recall the previous total deformations and subtract from the current total
        for itr = 1:k-3
            INCREM_DEFORMATIONS(:,:,itr) = TOTAL_DEFORMATIONS(:,:,itr) - last_WS.TOTAL_DEFORMATIONS(:,:,itr);
        end
        for itr = k-2:k
            INCREM_DEFORMATIONS(:,:,itr) = TOTAL_DEFORMATIONS(:,:,itr);
        end
                                            
    else
        % Preallocate the INCREM_DEFORMATION matrix
        INCREM_DEFORMATIONS = zeros(m, n, k);
        
        % Recall the previous total deformations and subtract from the current total
        for itr = 1:k-1
            INCREM_DEFORMATIONS(:,:,itr) = TOTAL_DEFORMATIONS(:,:,itr) - last_WS.TOTAL_DEFORMATIONS(:,:,itr);
        end
        INCREM_DEFORMATIONS(:,:,k) = TOTAL_DEFORMATIONS(:,:,itr);
    end
    
    % Store the first result as the initial guess for any subsequent correlations
    qo(1:2) = round(TOTAL_DEFORMATIONS(1,1,1:2));
    if k-1 >= 3
        qo(3:k-1) = TOTAL_DEFORMATIONS(1,1,3:k-1);
    end
    
end



%------------------------END OF TOTAL/INCREM DEFORMATIONS-------------------------------


% Return to the root DIC directory
cd('..');

% The output folder contains the start date_time when the "RUN" button was pressed
date_time_folder = datestr(date_time_run, ' yyyy-mm-dd, HH''MM''SS');

% Define the path where new outputs will be saved
output_folder_path = sprintf('%s\\DIC Outputs for %s', cd, date_time_folder);

% Record the date and time now for the input and workspace files
date_time = now;
date_time_long = datestr(date_time, 'mmmm dd, yyyy - HH:MM:SS');
date_time_short = datestr(date_time, ' yyyy-mm-dd, HH''MM''SS');


%------------------------SAVE THE RAW DATA-------------------------------
[tmp1, tmp2, tmp3] = mkdir(output_folder_path, 'Raw Data');
clear tmp1 tmp2 tmp3;

% Define the original filename open this file
rawdata_name = strcat(output_folder_path, '\Raw Data\Raw PreSplit Data', date_time_short, '.txt');
file_ID = fopen(rawdata_name, 'at');

% The first line contains date information
fprintf(file_ID, '"%s", "%s"', date_time_long, date_time_short);

% The second line mentions which method was used to compare images
if do_incremental == true
    fprintf(file_ID, '\nIncremental');
else
    fprintf(file_ID, '\nRegular');
end

% Save the data differently for first order techniques
if isequal(Input_info{3}, 'First Order with Subset Slicing') || isequal(Input_info{3}, 'First Order with Subset Slicing')
    
    
    % The following lines contain the names of all the variables and their respective values
    fprintf(file_ID, strcat('\n\nx_orig_grid, y_orig_grid, u_total, v_total, C, du/dx_total, dv/dy_total, du/dy_total, dv/dx_total,', ...
                                'delta_u, delta_v, delta_du/dx, delta_dv/dy, delta_du/dy, delta_dv/dx, ,', ...
                                'X_current_grid, Y_current_grid, U_current_grid, V_current_grid, C_current_grid,', ...
                                'du/dx_current_grid, dv/dy_current_grid, du/dy_current_grid, dv/dx_current_grid') );

    % Reshape all the required vectors to print out the data                    
    x_orig_grid     = reshape(orig_gridX, numel(orig_gridX), 1);
    y_orig_grid     = reshape(orig_gridY, numel(orig_gridY), 1);
    u_total         = reshape(TOTAL_DEFORMATIONS(:,:,1), numel(orig_gridX), 1);
    v_total         = reshape(TOTAL_DEFORMATIONS(:,:,2), numel(orig_gridX), 1);
    C               = reshape(TOTAL_DEFORMATIONS(:,:,end), numel(orig_gridX), 1);
    du_dx_total     = reshape(TOTAL_DEFORMATIONS(:,:,3), numel(orig_gridX), 1);
    dv_dy_total     = reshape(TOTAL_DEFORMATIONS(:,:,4), numel(orig_gridX), 1);
    du_dy_total     = reshape(TOTAL_DEFORMATIONS(:,:,5), numel(orig_gridX), 1);
    dv_dx_total     = reshape(TOTAL_DEFORMATIONS(:,:,6), numel(orig_gridX), 1);
    delta_u         = reshape(INCREM_DEFORMATIONS(:,:,1), numel(orig_gridX), 1);
    delta_v         = reshape(INCREM_DEFORMATIONS(:,:,2), numel(orig_gridX), 1);
    delta_du_dx     = reshape(INCREM_DEFORMATIONS(:,:,3), numel(orig_gridX), 1);
    delta_dv_dy     = reshape(INCREM_DEFORMATIONS(:,:,4), numel(orig_gridX), 1);
    delta_du_dy     = reshape(INCREM_DEFORMATIONS(:,:,5), numel(orig_gridX), 1);
    delta_dv_dx     = reshape(INCREM_DEFORMATIONS(:,:,6), numel(orig_gridX), 1);
    X_current_grid     = reshape(X_def_grid, numel(X_def_grid), 1);
    Y_current_grid     = reshape(Y_def_grid, numel(Y_def_grid), 1);
    U_current_grid     = reshape(DEFORMATION_PARAMETERS(:,:,1), numel(DEFORMATION_PARAMETERS(:,:,1)), 1);
    V_current_grid     = reshape(DEFORMATION_PARAMETERS(:,:,2), numel(DEFORMATION_PARAMETERS(:,:,2)), 1);
    C_current_grid     = reshape(DEFORMATION_PARAMETERS(:,:,end), numel(DEFORMATION_PARAMETERS(:,:,end)), 1);
    du_dx_current_grid = reshape(DEFORMATION_PARAMETERS(:,:,3), numel(DEFORMATION_PARAMETERS(:,:,3)), 1);
    dv_dy_current_grid = reshape(DEFORMATION_PARAMETERS(:,:,4), numel(DEFORMATION_PARAMETERS(:,:,4)), 1);
    du_dy_current_grid = reshape(DEFORMATION_PARAMETERS(:,:,5), numel(DEFORMATION_PARAMETERS(:,:,5)), 1);
    dv_dx_current_grid = reshape(DEFORMATION_PARAMETERS(:,:,6), numel(DEFORMATION_PARAMETERS(:,:,6)), 1);

    for ii = 1:numel(X_def_grid)
        if ii <= numel(orig_gridX)
            fprintf(file_ID,    '\n%g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, ,%g, %g, %g, %g, %g, %g, %g, %g, %g', ...
                                x_orig_grid(ii), y_orig_grid(ii), u_total(ii), v_total(ii), C(ii), ...
                                du_dx_total(ii), dv_dy_total(ii), du_dy_total(ii), dv_dx_total(ii), delta_u(ii), delta_v(ii), ...
                                delta_du_dx(ii), delta_dv_dy(ii), delta_du_dy(ii), delta_dv_dx(ii), ...
                                X_current_grid(ii), Y_current_grid(ii), U_current_grid(ii), V_current_grid(ii), C_current_grid(ii), ...
                                du_dx_current_grid(ii), dv_dy_current_grid(ii), du_dy_current_grid(ii), dv_dx_current_grid(ii) );
        else
            fprintf(file_ID,    '\n , , , , , , , , , , , , , , , ,%g, %g, %g, %g, %g, %g, %g, %g, %g', ...
                                X_current_grid(ii), Y_current_grid(ii), U_current_grid(ii), V_current_grid(ii), C_current_grid(ii), ...
                                du_dx_current_grid(ii), dv_dy_current_grid(ii), du_dy_current_grid(ii), dv_dx_current_grid(ii) );
        end
    end
else
    % The following lines contain the names of all the variables and their respective values
    fprintf(file_ID, strcat('\n\nx_orig_grid, y_orig_grid, u_total, v_total, C, delta_u, delta_v, ,', ...
                            'X_current_grid, Y_current_grid, U_current_grid, V_current_grid, C_current_grid') );

    % Reshape all the required vectors to print out the data                    
    x_orig_grid = reshape(orig_gridX, numel(orig_gridX), 1);
    y_orig_grid = reshape(orig_gridY, numel(orig_gridY), 1);
    u_total     = reshape(TOTAL_DEFORMATIONS(:,:,1), numel(orig_gridX), 1);
    v_total     = reshape(TOTAL_DEFORMATIONS(:,:,2), numel(orig_gridX), 1);
    C           = reshape(TOTAL_DEFORMATIONS(:,:,end), numel(orig_gridX), 1);
    delta_u     = reshape(INCREM_DEFORMATIONS(:,:,1), numel(orig_gridX), 1);
    delta_v     = reshape(INCREM_DEFORMATIONS(:,:,2), numel(orig_gridX), 1);
    X_current_grid     = reshape(X_def_grid, numel(X_def_grid), 1);
    Y_current_grid     = reshape(Y_def_grid, numel(Y_def_grid), 1);
    U_current_grid     = reshape(DEFORMATION_PARAMETERS(:,:,1), numel(DEFORMATION_PARAMETERS(:,:,1)), 1);
    V_current_grid     = reshape(DEFORMATION_PARAMETERS(:,:,2), numel(DEFORMATION_PARAMETERS(:,:,2)), 1);
    C_current_grid     = reshape(DEFORMATION_PARAMETERS(:,:,end), numel(DEFORMATION_PARAMETERS(:,:,end)), 1);

    for ii = 1:numel(X_def_grid)
        if ii <= numel(orig_gridX)
            fprintf(file_ID, '\n%g, %g, %g, %g, %g, %g, %g, ,%g, %g, %g, %g, %g', x_orig_grid(ii), y_orig_grid(ii), ...
                                                                                 u_total(ii), v_total(ii), C(ii), ...
                                                                                 delta_u(ii), delta_v(ii), ...
                                                                                 X_current_grid(ii), Y_current_grid(ii), ...
                                                                                 U_current_grid(ii), V_current_grid(ii), C_current_grid(ii)  );
        else
            fprintf(file_ID, '\n ,  ,  ,  , , , , ,%g, %g, %g, %g, %g', X_current_grid(ii), Y_current_grid(ii), ...
                                                                       U_current_grid(ii), V_current_grid(ii), C_current_grid(ii)  );
        end
    end
    
end % if 1st order

fclose(file_ID);   

%------------------------END SAVE THE RAW DATA-------------------------------


%------------------------SAVE THE PRESPLIT INFO-------------------------------
[tmp1, tmp2, tmp3] = mkdir(output_folder_path, 'PreSplit Info');
clear tmp1 tmp2 tmp3;

% Define the original filename open this file
presplit_name = strcat(output_folder_path, '\PreSplit Info\PreSplit Info', date_time_short, '.txt');
goodcorr_name = strcat(output_folder_path, '\PreSplit Info\GoodCorr', date_time_short, '.txt');
file_ID1 = fopen(presplit_name, 'at');
file_ID2 = fopen(goodcorr_name, 'at');

% The first line contains date information
fprintf(file_ID1, '"%s", "%s"', date_time_long, date_time_short);

% The second line mentions which method was used to compare images
if do_incremental == true
    fprintf(file_ID1, '\nIncremental');
else
    fprintf(file_ID1, '\nRegular');
end

% The next line will print some useful information
fprintf(file_ID1, '\nMean_C =, %s', mean_C);
fprintf(file_ID1, '\nf_g_tol = , %s', f_g_tol);

% The following lines contain the names of all the variables and their respective values
fprintf(file_ID2, strcat('X, Y, GoodCorr') );

% Reshape all the required vectors to print out the data
X_current_grid          = reshape(X_def_grid, numel(X_def_grid), 1);
Y_current_grid          = reshape(Y_def_grid, numel(Y_def_grid), 1);
good_corr_current_grid  = reshape(good_corr, numel(good_corr), 1);

for ii = 1:numel(X_def_grid)
        fprintf(file_ID2, '\n%g, %g, %g', X_current_grid(ii), Y_current_grid(ii), good_corr_current_grid(ii) );
end

fclose(file_ID1);   
fclose(file_ID2);  
%------------------------END SAVE THE PRESPLIT INFO-------------------------------

return;
end % function
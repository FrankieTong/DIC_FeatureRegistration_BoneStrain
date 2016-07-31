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



% Digital Image Correlation: Just Subset Splitting
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  November 10, 2007
% Modified on: June 26, 2010


---------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: JUST SUBSET SPLITTING    |
---------------------------------------------------------

The following function is a script which will perform subset splitting. It
was taken directly from the main code itself, but allows for users to change
their inputs immediately at the beginning of this file.

To use this script:
1. Enter your desired values in the first section of this file identified 
   as "Inputs".
2. Save your changes.
3. Load the "Presplit Workspace" into your Matlab workspace
   Note - when you run a DIC analysis using "First Order with Subset Splitting", 
          once regular DIC is complete, before starting subset splitting, 
          the "Presplit Workspace" will be saved along with other DIC outputs.
4. Run this script (either by pressing F5, or typing the file's name at the Matlab command window)
%}

% Define the X and Y coordinates of each subset center
mesh_col = Xp_first:subset_space:(num_subsets_X-1)*subset_space+Xp_first;
mesh_row = Yp_first:subset_space:(num_subsets_Y-1)*subset_space+Yp_first;
    

% **************************************
% * - - - - - - INPUTS - - - - - - - - *
% **************************************

% Enter the splitting tolerance here (C_st).
% If you leave split_tol as 0, the program will ask you for the splitting tolerance
split_tol = 0;

% Enter the f_g_tol parameter which determine how to create the splitting
% line. I strongly recommend making this parameter larger than the default
% value computed by the regular DIC algorithm.
% Note that too large a value of f_g_tol will neglect subsets from being
% processed by subset splitting, too small a value could cause crashes
% (Bad_Values matrix filled with ones).
f_g_tol = f_g_tol*1.25;

% Enter a rectangular region where you want subset splitting performed
% In other words, values outside this region will not be processed by
% subset splitting. Leaving this empty will ignore this operation
% Note that the coordinates are relative to your area of interest, so that
% (i,j) = (1,1) represents the top-left corner of your area of interest and
% (i,j) = (num_subsets_X, num_subsets_Y) is the bottom-right
i_min = 1;
j_min = 1;

[m,n] = size(DEFORMATION_PARAMETERS(:,:,end));
i_max = n;
j_max = m;

% Do you want to overwrite the regular DIC results with newer subset splitting results?
% This option is typically used so that the newer subset splitting run can be
% re-processed by subset splitting to try and further improve results (recall that
% subset splitting only keeps the best results).
% To use, uncomment the following 3 lines, and enter the full path name of
% your the workspace containing your newer results
%WS = load('..\DIC Outputs for  2010-06-26, 16''49''00\Workspace\Workspace 2010-06-26, 14''03''37.mat');
%DEFORMATION_PARAMETERS = WS.DEFORMATION_PARAMETERS;
%clear WS;

% **************************************
% * - - - - - - END INPUTS - - - - - - *
% **************************************

% Splitting region
i_j_region = [i_min, j_min; i_max, j_max];

% Define your subsets to split
Selected_Subsets = Splitting_Tol_Select(mesh_col, mesh_row, DEFORMATION_PARAMETERS, split_tol, i_j_region);

% Redefine the subset splitting data if the user input a valid value
try
if isempty(Selected_Subsets) == false
    good_corr           = Selected_Subsets.good_corr;
    IIsplit             = Selected_Subsets.IIsplit;
    JJsplit             = Selected_Subsets.JJsplit;
    Xsplit              = Selected_Subsets.Xsplit;
    Ysplit              = Selected_Subsets.Ysplit;
    cnt_split           = Selected_Subsets.cnt_split;
    num_subsets_split   = Selected_Subsets.num_subsets_split;
    num_good_corr       = total_num_subsets - num_subsets_split;
    split_tol           = Selected_Subsets.split_tol;
else
    good_corr           = ones(numel(mesh_row), numel(mesh_col));
    num_subsets_split   = 0;
    split_tol = 0;
end
catch
    num_subsets_split   = 0;
    good_corr = ones(numel(mesh_row), numel(mesh_col));
    split_tol = 0;
end



% Store the good_corr matrix which indicates which subsets will be split
SaveGoodCorrData(good_corr, split_tol, f_g_tol, true);





%---------------------PREPARE FOR SUBSET SPLITTING--------------------------------
% Declare a few gobal variables that we will need to use later on
% ( G = Good, B = Bad )
global def_interp_G;
global def_interp_B;
global def_interp_x_G;
global def_interp_y_G;
global def_interp_x_B;
global def_interp_y_B;

% If all points were well correlated, there's no point in doing subset splitting
if num_subsets_split > 0
    
% Reinitialize the Progress Bar
if ishandle(h_wait) ~= false
    close(h_wait);
end
BarText = sprintf('Performing subset splitting:  %s out of %s,          Estimated Time: %s min, %s sec\n%4.1f%% Complete', ...
                num2str(0), num2str(num_subsets_split), '--', '--', 0);
h_wait = waitbar(0, BarText, 'Name', 'Progress Bar: Performing Subset Splitting', 'Units', 'normalized');
set(h_wait, 'Position', [0.3 0.5 0.45 0.11] );
h_child = get(h_wait, 'Children');
h_child_title = get(h_child, 'Title');
set(h_child, 'Units', 'normalized', 'Position', [0.1, 0.25, 0.8, 0.15]);
set(h_child_title, 'FontName', 'Arial', 'FontWeight', 'Bold');


% The second initial guess for subset splitting is found using a coarse
% search. Define a position to start the coarse search on the first
% splitting here:
q_0_B(1:6,1) = 0;




% Restart the timer
tic
%---------------------SUBSET SPLITTING--------------------------------

% [TO BE UPDATED] Define the interpolated deformed image
def_interp_G = def_interp;
def_interp_B = def_interp;
def_interp_x_G = def_interp_x;
def_interp_y_G = def_interp_y;
def_interp_x_B = def_interp_x;
def_interp_y_B = def_interp_y;

% MAIN SUBSET SPLITTING LOOP -- CORRELATE THE POINTS THAT NEED SUBSET SPLITTING
for counter = 1:num_subsets_split
    
    % Initialize some useful values from the information saved during regular correlation
    Xp = Xsplit(counter);
    Yp = Ysplit(counter);
    ii = IIsplit(counter);
    jj = JJsplit(counter);
    cnt = cnt_split(counter);
    
    t_tmp = toc;
    %__________UPDATE THE PROGRESS BAR_________________________________
    % Display correlation's progress in the progress bar
    progbar = roundn((counter/num_subsets_split).*100,-2);
    % Compute an estimate to see how much time remains
    t_now = toc;
    t_left = ((100/progbar - 1)*t_now);
    t_left_min = floor(t_left/60);
    t_left_sec = roundn(mod(t_left,60),-2);
    BarText = sprintf('Performing subset splitting:  %s out of %s,          Estimated Time: %s min, %s sec\n%4.1f%% Complete', ...
            num2str(counter), num2str(num_subsets_split), num2str(t_left_min), num2str(t_left_sec), progbar);
    %ProgressBar;
    waitbar(progbar/100, h_wait, BarText);
    %_________________________________________________________________________ 
    t_prog(cnt) = toc - t_tmp;      % Save the amount of time it took to update the progress bar
    
    
    
    
    
    %__________SAVE THE BEST RESULTS________________________    
    % Before we begin subset splitting, let's save the current DIC results. This section always takes
    % the best results as being correct. If subset splitting makes the results worse, we'll want to output
    % the results we have now:
    best_result(1:6, 1)  = DEFORMATION_PARAMETERS(jj,ii,1:6);       % Deformation u, v, du/dx, dv/dy, du/dy, dv/dx
    best_result(7:12, 1) = 0;                                       % Deformation uJ, vJ, du/dxJ, dv/dyJ, du/dyJ, dv/dxJ
    best_result(13:14, 1)= NaN;                                     % Line parameters a, b
    best_result(15,1)    = 1-DEFORMATION_PARAMETERS(jj,ii,end);     % Correlation Coefficient C (best possible value = 0)
    best_result_disp     = 1;                                       % "disps" (position of master subset)
    best_result_method   = 'No subset splitting';                   % Best method
    %______________________________________________________________________
    
    
    
    
    % Now to start subset splitting, we need to obtain initial guesses for the displacements of the subset. 
    % Since subset splitting involves deforming two parts of the subset differently, we need to have two
    % sets of deformation parameters:
    
    %__________FIND FIRST INITIAL GUESS FOR THE GOOD SECTOR AND FIT SPLINE ________________________
    % The first initial guess to compute is for the well-correlated section of the subset.
    % Fortunately, we have all the properly correlated results near the current point of interest. 
    % By choosing the best one, we'll get a good estimate for one set of deformation paramters.
    
    % The function Inital_Guess_Good, will look at the correlation quality of other points 
    % near the current point of interest and choose the results from the best correlated point 
    % as the first initial guess for subset splitting
    q_0_G = Initial_Guess_Good(good_corr, ii, jj, DEFORMATION_PARAMETERS);
    
    
    %t_tmp = toc;
    % Now that we have an idea where one part of the correlation takes place, define the first deformed image sector.
    %X_defcoord_G       = -floor(subset_size/2)+Xp+floor(q_0_G(1))-interp_buffer:floor(subset_size/2)+Xp+floor(q_0_G(1))+interp_buffer;
    %Y_defcoord_G       = -floor(subset_size/2)+Yp+floor(q_0_G(2))-interp_buffer:floor(subset_size/2)+Yp+floor(q_0_G(2))+interp_buffer;

    % Fit the interpolating spline: g(x,y) around the first sector of interest
    %def_interp_G   = spapi( {spline_order,spline_order}, {Y_defcoord_G, X_defcoord_G}, def_image(Y_defcoord_G, X_defcoord_G) );

    % Find the partial derivitives of the spline: dg/dx and dg/dy
    %def_interp_x_G = fnder(def_interp_G, [0,1]);
    %def_interp_y_G = fnder(def_interp_G, [1,0]);
    t_good_interp = 0;%toc - t_tmp;    % Save the amount of time it took to interpolate
    %___________________________________________________________________________________________________________
    
    
    
    
    %__________DEFINE THE BAD_VALUES MATRIX________________________  
    % The "Bad_Values" matrix is obtained by finding which of the points within the subset 
    % are poorly correlated when deformimg the subset using only q_0_G.
    
    % Get the intensities of the reference and deformed images
    f_0 = ref_image(Yp+j, Xp+i);
    
    X = Xp + q_0_G(1) + I + I.*q_0_G(3) + J.*q_0_G(5);
    Y = Yp + q_0_G(2) + J + J.*q_0_G(4) + I.*q_0_G(6);
    g_0 = reshape( fnval(def_interp_G, [Y;X]), subset_size, subset_size);
    
    % The difference between the reference and deformed intensities squared, 
    % is a meausure of the error. The points that are over some tolerance,
    % have large error and are thus called "Bad_Values".
    Bad_Values = (f_0-g_0).^2 > f_g_tol;
    
    % Sometimes, the Bad_Values matrix might contain only 1 non-zero value.
    % Othertimes, it might have a few of non-zeros that are quite far from each other.
    % Also, the opposite can happen as well where sparse zeros appear in a region dominated by non-zeros
    % In such a case, the matrix must be filtered to remove these erroneous points.
    
    % Initialize the variable that determines when the filtering is completed
    filtering_complete = false;
    
    % Perform some filtering on the Bad_Values matrix to fill any "holes"
    while filtering_complete == false
        % Pass Bad_Values through the Max_Min_filter function twice
        Bad_Values_filt = Max_Min_filter( Max_Min_filter(Bad_Values, subset_size, 'max'), subset_size, 'min');
        % If there was no change to the Bad_Values matrix, filtering is complete
        filtering_complete = all(all(Bad_Values_filt == Bad_Values));
        % Update the old matrix
        Bad_Values = Bad_Values_filt;
    end
    %______________________________________________________________________
    
    
    %__________CHECK IF BAD_VALUES IS ALMOST EMPTY________________________
    % If there are practically no bad points, then there is no real reason 
    % to subset split this matrix. Instead, just try correlating without the bad points 
    % to see if things improve, and set the Bad_Values matrix to be full of zeros
    if numel(find(Bad_Values)) < 0.25*subset_size 

        % The function Few_Bad_Values_Subset_Splitting will perform a special DIC
        % where the "Bad_Values" are removed from the correlation
        
        % Define the initial guess for the point removal
        q_00 = q_0_G;

        % Supply the initial guess and the Bad_Values matrix
        results = Few_Bad_Values_Subset_Splitting( q_00, Bad_Values );
        
        % If this answer is better than basic DIC, save it as the best.
        if results(end) < best_result(end)
            best_result(1:6, 1)  = results(1:6);                            % Deformation uG, vG, du/dxG, dv/dyG, du/dyG, dv/dxG
            best_result(7:12, 1) = 0;                                       % Deformation uB, vB, du/dxB, dv/dyB, du/dyB, dv/dxB
            best_result(13:14, 1)= [NaN, NaN];                              % Line parameters a, b
            best_result(15,1)    = results(end);                            % Correlation Coefficient C (best possible value = 0)
            best_result_disp     = 1;                                       % "disps" (position of master subset)
            best_result_method   = 'Bad_Values was mostly empty';           % Best method
        end
        
        % Empty out the Bad_Values matrix, this is as far as it goes
        Bad_Values = zeros(subset_size, subset_size);
    end
    %______________________________________________________________________

    
    %__________WITH BAD_VALUES, DEFINE SPLITTING LINE________________________
    % The Bad_values matrix should generally contain one section full of zeros
    % and another section full of ones. These two sections must be seperated by a line
    % The line is defined by two parameters: its slope "a", and y-intercept "b"
   
    % Start by assuming that the a and b are not optimized
    a_b_optim_completed = false;
    
    % Check the Bad_Values matrix. If it's all zeros, ignore subset splitting (there's nothing we can do)
    if all(reshape(Bad_Values, 1, N) == 0) 

        % Set good_corr to be 0.9 since the Bad_Values matrix was full of zeros
        good_corr(jj,ii) = 0.9;
        a_b_optim_completed = true;

    % If Bad_Values is all ones, or anything else, there's a problem. In such acase, crash and give detailed info.
    elseif all(reshape(Bad_Values, 1, N) == 1) || any(isnan(reshape(Bad_Values, 1, N)))

        fprintf(1, '\n\nThe Bad_Values matrix was full of %g\n\n\n', Bad_Values(1,1));
        fprintf(1, 'Here is the info on the crash\n\n');
        fprintf(1, '(Xp, Yp) = (%g, %g)\n(ii, jj) = (%g, %g)\n', Xp, Yp, ii, jj );
        fprintf(1, 'n = %g\ntries = %g\n', n, tries);
        fprintf(1, 'a = %g\nb = %g\n', a, b);
        errordlg('Bad_Values = 1 or NaN. Read the command window','Error during Subset Splitting','modal');
        return;

    else
    % Otherwise, the Bad_Values matrix is okay. Obtain a best fit line through the matrix
    
    % The Optimize_a_b function will produce the line parameters "a" and
    % "b", it will define the well-correlated section of the subset, and the
    % poorly correlated section of the subset, and it will state on which side of
    % the splitting line these sections lie
    [a, b, good_section, bad_section, bad_up_or_down, disps] = Optimize_a_b_J1([q_0_G;q_0_B], Bad_Values );
    
    %______________________________________________________________________
    
    
    %__________VERIFY IF SUBSET IS MOSTLY WELL CORRELATED________________
    % If the poorly correlated section of the subset is very small (i.e. if the bad_section matrix 
    % has almost no "ones"), then subset splitting might not work well. 
    % Therefore, try using subset cropping. 
    % NOTE: Unlike the previous section, where a check was made for an almost empty Bad_Values matrix,
    %       entering this condition does not necessarily prevent subset splitting
    
    % Define a tolerance for how many values there should be in the bad_section of the subset
    crop_tol = 2.5*subset_size;
    if (numel(find(bad_section)) < crop_tol || numel(find(Bad_Values)) < subset_size) && disps == 1        

        % Define the initial guess for the subset cropping method
        q_1 = q_0_G;
        
        % Supply the function with an initial guess, and a matrix that says what to 
        % points to remove from the correlation (subset cropping).
        % the cropped points will be the bad_section, plus the pixels crossed by the line 
        % (i.e. 1-good_section)
        results = Few_Bad_Values_Subset_Splitting( q_1, 1-good_section );
        
        % If the current result is better than the last result save it as the best answer (so far)
        if results(end) < best_result(end)
            best_result(1:6, 1)  = results(1:6);                            % Deformation uG, vG, du/dxG, dv/dyG, du/dyG, dv/dxG
            best_result(7:12, 1) = 0;                                       % Deformation uB, vB, du/dxB, dv/dyB, du/dyB, dv/dxB
            best_result(13:14, 1)= [a, b];                                  % Line parameters a, b
            best_result(15,1)    = results(end);                            % Correlation Coefficient C (best possible value = 0)
            best_result_disp     = 1;                                       % "disps" (position of master subset)
            best_result_method   = 'Subset Cropping (good section)';        % Best method
        end
        
        % If your answer is within tolerance, you don't need to try subset splitting
        if 1-results(end) > split_tol || numel(find(bad_section)) < subset_size
            a_b_optim_completed = true;
            good_corr(jj,ii) = 0.8; % Subset cropping was used on a mostly well correlated subset
        end
    end
    %______________________________________________________________________
    
    
    
    %______FIND AN INITIAL GUESS FOR THE BAD SECTION AND INTERPOLATE_______
    % Previously, we found an initial guess for the well-correlated section
    % of the subset. Now, another intial guess must be obtained for the poorly correlated
    % section of the subset. This task is done by searching, in a direction
    % normal to the splitting line, for a DIC point which does not require subset splitting.
    q_0_B = Initial_Guess_Bad(good_corr, ii, jj, DEFORMATION_PARAMETERS, bad_up_or_down, a);
    
    %t_tmp = toc;
    %-------FIT SPLINE ONTO BAD DEFORMED SECTOR------
    % Now that we have an idea where the second part of the correlation takes place, define the second deformed image sector.
    %X_defcoord_B       = -floor(subset_size/2)+Xp+floor(q_0_B(1))-interp_buffer:floor(subset_size/2)+Xp+floor(q_0_B(1))+interp_buffer;
    %Y_defcoord_B       = -floor(subset_size/2)+Yp+floor(q_0_B(2))-interp_buffer:floor(subset_size/2)+Yp+floor(q_0_B(2))+interp_buffer;

    % Fit the interpolating spline: g(x,y) around the second sector of interest
    %def_interp_B   = spapi( {spline_order,spline_order}, {Y_defcoord_B, X_defcoord_B}, def_image(Y_defcoord_B, X_defcoord_B) );

    % Find the partial derivitives of the spline: dg/dx and dg/dy
    %def_interp_x_B = fnder(def_interp_B, [0,1]);
    %def_interp_y_B = fnder(def_interp_B, [1,0]);
    %-------------------------------------------------- 
    t_interp(cnt) = 0;%(toc - t_tmp) + t_good_interp;    % Save the amount of time it took to interpolate

    %______________________________________________________________________

            
    
    %__________VERIFY IF SUBSET IS MOSTLY BADLY CORRELATED________________
    % If the well-correlated section of the subset is very small (i.e. if the good_section matrix 
    % has almost no "ones"), then subset splitting might not work well.
    % Also, if the Bad_Values matrix is almost filled with "ones", this might cause problems as well.
    % Therefore, try using subset cropping. 
    if (numel(find(good_section)) < crop_tol || numel(find(1-Bad_Values)) < subset_size) && disps == 2
        
        % Define the initial guess for the cropping method
        % In this case, rather than using the initial guess for the well-correlated section 
        % of the subset, we use the initial guess for the poorly correlated section 
        q_2 = q_0_B;
        
        % Supply the initial guess, and define the points to crop out as
        % being the well-correlated section of the subset, plus the pixels
        % that were crossed by the splitting line (i.e. 1-bad_section)
        results = Few_Bad_Values_Subset_Splitting( q_2, 1-bad_section );
        
        % If the current result is better than the last result save it as the best answer (so far)
        if results(end) < best_result(end)
            best_result(1:6, 1)  = 0;                                       % Deformation uG, vG, du/dxG, dv/dyG, du/dyG, dv/dxG
            best_result(7:12, 1) = results(1:6);                            % Deformation uB, vB, du/dxB, dv/dyB, du/dyB, dv/dxB
            best_result(13:14, 1)= [a, b];                                  % Line parameters a, b
            best_result(15,1)    = results(end);                            % Correlation Coefficient C (best possible value = 0)
            best_result_disp     = 2;                                       % "disps" (position of master subset)
            best_result_method   = 'Subset Cropping (bad section)';         % Best method
        end
        
        % If your answer is within tolerance, you don't need to try subset splitting
        if 1-results(end) > split_tol || numel(find(good_section)) < subset_size
            a_b_optim_completed = true;
            good_corr(jj,ii) = 0.7; % Subset cropping was used on a mostly badly correlated subset
        end
    end
    %______________________________________________________________________
    
    end % if Bad_Values is all zeroes, or ones, or something in between
    
    
    t_tmp = toc;
    %_____________________OPTIMIZATION ROUTINE: SUBSET SPLITTING___________________
    % Initialize the vector of deformation parameters q_k = [uG; vG; du/dxG; ... uB; vB; du/dxB; ...]
    q_k = [q_0_G ; q_0_B ];
    
    % Initialize some values
    tries = 0;
    
    while a_b_optim_completed == false
        
        % Initialize the number of iterations.
        n = 0;
        
        % Find the starting optimization values using the q_k and sections defined above
        [C_last_G, GRAD_last_G, HESS_G] = C_First_Split_GB(q_k(1:6), good_section, 'good' );
        [C_last_B, GRAD_last_B, HESS_B] = C_First_Split_GB(q_k(7:12), bad_section, 'bad' );
        C_last = C_First_Split_GB_Total( q_k, good_section, bad_section );
        
        optim_completed = false;
        
        % If the current result from subset splitting is better than the last result
        % of DIC, save it as the best answer (so far)
        if C_last < best_result(end)
            best_result(1:6, 1)  = q_k(1:6);                                % Deformation uG, vG, du/dxG, dv/dyG, du/dyG, dv/dxG
            best_result(7:12, 1) = q_k(7:12);                               % Deformation uB, vB, du/dxB, dv/dyB, du/dyB, dv/dxB
            best_result(13:14, 1)= [a, b];                                  % Line parameters a, b
            best_result(15,1)    = C_last;                                  % Correlation Coefficient C (best possible value = 0)
            best_result_disp     = disps;                                   % "disps" (position of master subset)
            best_result_method   = sprintf('Subset Splitting, n=%g, tries=%g', n, tries); % Best method
        end
        
        % This "try" command has been put in place in case the optimization
        % diverges. This will ensure that the algorithm does not crash.
        try

            % Optimize the two sections seperatly and combine their results
            while optim_completed == false

                % Compute the next guess and update the values for the good section
                delta_q_G = HESS_G\(-GRAD_last_G);                         % Find the difference between q_k+1 and q_k
                q_k(1:6) = q_k(1:6) + delta_q_G;                           % q_k+1 = q_k + delta_q

                % Compute the next guess and update the values for the bad section
                delta_q_B = HESS_B\(-GRAD_last_B);                         % Find the difference between q_k+1 and q_k
                q_k(7:12) = q_k(7:12) + delta_q_B;                         % q_k+1 = q_k + delta_q

                % Compute new values of C, GRAD, and HESS
                [C_G, GRAD_G, HESS_G] = C_First_Split_GB(q_k(1:6), good_section, 'good' );
                [C_B, GRAD_B, HESS_B] = C_First_Split_GB(q_k(7:12), bad_section, 'bad' );
                C = C_First_Split_GB_Total( q_k, good_section, bad_section );      

                % Add one to the iteration counter
                n = n + 1;                                       % Keep track of the number of iterations

                % Check to see if the values have converged according to the stopping criteria
                if n > Max_num_iter+15 || ( abs(C-C_last) < TOL(1) && all(abs(delta_q) < TOL(2)) )
                    optim_completed = true;
                end

                C_last = C;                                      % Save the C value for comparison in the next iteration
                GRAD_last_G = GRAD_G;                            % Save the GRAD value for comparison in the next iteration
                GRAD_last_B = GRAD_B;                            % Save the GRAD value for comparison in the next iteration
            end

            % If the current result from subset splitting is better than last result
            % of DIC, save it as the best answer (so far)
            if C_last < best_result(end)
                best_result(1:6, 1)  = q_k(1:6);                                % Deformation uG, vG, du/dxG, dv/dyG, du/dyG, dv/dxG
                best_result(7:12, 1) = q_k(7:12);                               % Deformation uB, vB, du/dxB, dv/dyB, du/dyB, dv/dxB
                best_result(13:14, 1)= [a, b];                                  % Line parameters a, b
                best_result(15,1)    = C_last;                                  % Correlation Coefficient C (best possible value = 0)
                best_result_disp     = disps;                                   % "disps" (position of master subset)
                best_result_method   = sprintf('Subset Splitting, n=%g, tries=%g', n, tries); % Best method
            end
        
        catch
            tries = 6;
            C_last = best_result(end);
        end
        
        % If the value of C is now good...
        if ( 1-C_last > split_tol )
            % Optimization of a and b is complete
            a_b_optim_completed = true;
            % The correlation here is now good
            % Set the value to 0.5 to show that value is good, but subset
            % splitting was used
            good_corr(jj,ii) = 0.5; % Subset Splitting Algorithm success
            
        % If the value of C is still not good, try updating the Bad_Values matrix
        elseif tries < 5
            
            % This "try" command has been put in place in case the next
            % iteration of Bad_Values diverges. This will ensure that the algorithm does not crash.
            try
                % Update the Bad_Values matrix
                % Get the intensities using the best initial guess
                X = Xp + q_k(1) + I + I.*q_k(3) + J.*q_k(5);
                Y = Yp + q_k(2) + J + J.*q_k(4) + I.*q_k(6);

                g_0 = reshape( fnval(def_interp_G, [Y;X]), subset_size, subset_size);

                Bad_Values = (f_0-g_0).^2 > f_g_tol;
                
                % Perform some filtering on the Bad_Values matrix
                filtering_complete = false;
                while filtering_complete == false
                    % Pass Bad_Values through the Max_Min_filter function twice
                    Bad_Values_filt = Max_Min_filter( Max_Min_filter(Bad_Values, subset_size, 'max'), subset_size, 'min');
                    % If there was no change to the Bad_Values matrix, filtering is complete
                    filtering_complete = all(all(Bad_Values_filt == Bad_Values));
                    % Update the old matrix
                    Bad_Values = Bad_Values_filt;
                end

                tries = tries + 1;
                
                % Check the Bad_Values matrix. If it's all zeros, ones, or anything else, this method won't get any better
                if all(reshape(Bad_Values, 1, N) == 0) || all(reshape(Bad_Values, 1, N) == 1) || any(isnan(reshape(Bad_Values, 1, N)))

                    % Reset the Bad_Values matrix
                    f_0 = ref_image(Yp+j, Xp+i);

                    X = Xp + q_0_G(1) + I + I.*q_0_G(3) + J.*q_0_G(5);
                    Y = Yp + q_0_G(2) + J + J.*q_0_G(4) + I.*q_0_G(6);
                    g_0 = reshape( fnval(def_interp_G, [Y;X]), subset_size, subset_size);

                    Bad_Values = (f_0-g_0).^2 > f_g_tol;
                    
                    % Reinitialize the initial guess
                    q_k = [q_0_G ; q_0_B];
                    
                    % Get out of this section of the optimization
                    tries = 6;                
                end
                
                % The Bad_Values matrix was updated. Obtain a best fit line through the matrix
                [a, b, good_section, bad_section, bad_up_or_down, disps] = Optimize_a_b_J1(q_k, Bad_Values );
            catch
                tries = 6;
            end       
            %______________________________________________________________________
    
    
            %_____OPTIMIZATION ROUTINE: LINEAR SEARCH, LAST ATTEMPT________
        else % tries >= 5
            % If you reach this point, there were problems trying to get a good solution. 
            % So we need to resort to a linear search, which is a longer method.
                                    
            % Reinitialize the vector of deformation parameters using the best answer (so far)
            q_k = best_result(1:12);
            
            % Reinitialize the line parameters "a" and "b" using the best
            % results (as long as the best results aren't NaN)
            if all( isfinite(best_result(13:14)) ) == true
                a = best_result(13);
                b = best_result(14);
            end
            
            % Reinitialize the "Bad_Values" matrix
            X = Xp + q_k(1) + I + I.*q_k(3) + J.*q_k(5);
            Y = Yp + q_k(2) + J + J.*q_k(4) + I.*q_k(6);
            g_0 = reshape( fnval(def_interp_G, [Y;X]), subset_size, subset_size);
    
            Bad_Values = (f_0-g_0).^2 > f_g_tol;
            
            % Perform some filtering on the Bad_Values matrix to fill any holes
            filtering_complete = false;
            while filtering_complete == false
                % Pass Bad_Values through the Max_Min_filter function twice
                Bad_Values_filt = Max_Min_filter( Max_Min_filter(Bad_Values, subset_size, 'max'), subset_size, 'min');
                % If there was no change to the Bad_Values matrix, filtering is complete
                filtering_complete = all(all(Bad_Values_filt == Bad_Values));
                % Update the old matrix
                Bad_Values = Bad_Values_filt;
            end
            
            % Initialize the number of iterations.
            n = 0;

            % Find the best "a" and "b" using a linear loop search with the previous best_result's "a" and "b" as initial guess
            [a_new, b_new, good_section, bad_section, bad_up_or_down, disps] = Optimize_a_b_J1(q_k, Bad_Values, [a;b] );
            
            % Find the starting optimization values using the q_k and sections defined above
            [C_last_G, GRAD_last_G, HESS_G] = C_First_Split_GB(q_k(1:6), good_section, 'good' );
            [C_last_B, GRAD_last_B, HESS_B] = C_First_Split_GB(q_k(7:12), bad_section, 'bad' );
            C_last = C_First_Split_GB_Total( q_k, good_section, bad_section );
            
            optim_completed = false;
            
            % If the current result for subset splitting is better than the last result save it as the best answer (so far)
            if C_last < best_result(end)
                best_result(1:6, 1)  = q_k(1:6);                                % Deformation uG, vG, du/dxG, dv/dyG, du/dyG, dv/dxG
                best_result(7:12, 1) = q_k(7:12);                               % Deformation uB, vB, du/dxB, dv/dyB, du/dyB, dv/dxB
                best_result(13:14, 1)= [a_new, b_new];                          % Line parameters a, b
                best_result(15,1)    = C_last;                                  % Correlation Coefficient C (best possible value = 0)
                best_result_disp     = disps;                                   % "disps" (position of master subset)
                best_result_method   = sprintf('Linear Search, n=%g', n);       % Best method
            end
            
            % This "try" command has been put in place in case the optimization
            % diverges. This will ensure that the algorithm does not crash.
            try
            
                while optim_completed == false

                    % Compute the next guess and update the values for the good values
                    delta_q_G = HESS_G\(-GRAD_last_G);                         % Find the difference between q_k+1 and q_k
                    q_k(1:6) = q_k(1:6) + delta_q_G;                           % q_k+1 = q_k + delta_q

                    % Compute the next guess and update the values for the bad values
                    delta_q_B = HESS_B\(-GRAD_last_B);                         % Find the difference between q_k+1 and q_k
                    q_k(7:12) = q_k(7:12) + delta_q_B;                         % q_k+1 = q_k + delta_q

                    % Compute new values of C, GRAD, and HESS
                    [C_G, GRAD_G, HESS_G] = C_First_Split_GB(q_k(1:6), good_section, 'good' );
                    [C_B, GRAD_B, HESS_B] = C_First_Split_GB(q_k(7:12), bad_section, 'bad' );
                    C = C_First_Split_GB_Total( q_k, good_section, bad_section );      

                    % Add one to the iteration counter
                    n = n + 1;                                       % Keep track of the number of iterations

                    % Check to see if the values have converged according to the stopping criteria
                    if n > Max_num_iter+15 || ( abs(C-C_last) < TOL(1) && all(abs(delta_q) < TOL(2)) )
                        optim_completed = true;
                    end

                    C_last = C;                                      % Save the C value for comparison in the next iteration
                    GRAD_last_G = GRAD_G;                            % Save the GRAD value for comparison in the next iteration
                    GRAD_last_B = GRAD_B;                            % Save the GRAD value for comparison in the next iteration
                end

                % If the current result for subset splitting is better than
                % the last result save it as the best answer (so far)
                if C_last < best_result(end)
                    best_result(1:6, 1)  = q_k(1:6);                                % Deformation uG, vG, du/dxG, dv/dyG, du/dyG, dv/dxG
                    best_result(7:12, 1) = q_k(7:12);                               % Deformation uB, vB, du/dxB, dv/dyB, du/dyB, dv/dxB
                    best_result(13:14, 1)= [a_new, b_new];                          % Line parameters a, b
                    best_result(15,1)    = C_last;                                  % Correlation Coefficient C (best possible value = 0)
                    best_result_disp     = disps;                                   % "disps" (position of master subset)
                    best_result_method   = sprintf('Linear Search, n=%g', n);       % Best method
                end
                
            catch
                C_last = best_result(end);
            end
                

            % If C is now good, you're done
            if 1-C_last > split_tol
                % Optimization of a and b is complete
                a_b_optim_completed = true;
                % The correlation here is now good
                good_corr(jj,ii) = 0.35; % Linear search subset splitting success

            else

                fprintf(1,'\nThe subset splitting can''t find a good answer. The best answer was used\n');
                fprintf(1,'uG \t= %g, \t\t\t\t vG \t= %g\n', best_result(1), best_result(2));
                fprintf(1,'duG/dx = %g, \t\t dvG/dy = %g\n', best_result(3), best_result(4));
                fprintf(1,'duG/dy = %g, \t\t dvG/dx = %g\n', best_result(5), best_result(6));
                fprintf(1,'uB \t= %g, \t\t\t\t vB \t= %g\n', best_result(7), best_result(8));
                fprintf(1,'duB/dx = %g, \t\t dvB/dy = %g\n', best_result(9), best_result(10));
                fprintf(1,'duB/dy = %g, \t\t dvB/dx = %g\n', best_result(11), best_result(12));
                fprintf(1,'a_best = %g\n', best_result(13));
                fprintf(1,'b_best = %g\n', best_result(14));
                fprintf(1,'C_best = %g\n', best_result(15));
                fprintf(1,'disps = %g\n', best_result_disp);
                fprintf(1,'Method = %s\n', best_result_method);
                
                fprintf(1,'The problem occurred at (X,Y) = (%g,%g)\n',Xp,Yp);
                fprintf(1,'Or at matrix positions (ii,jj) = (%g,%g)\n\n', ii,jj);
                
             
                % Optimization of a and b is complete
                a_b_optim_completed = true;
                % The correlation here is now good
                good_corr(jj,ii) = 0.2; % Subset splitting could not surpass the splitting tolerance, the best answer was used

            end % if C < 1-split_tol (linear search)
            
        end % if C < 1-split_tol (Newton-Raphson)
            
    end % while a_b_optim...
    %_________________________________________________________________________
    t_optim(cnt) = toc - t_tmp;
    iters(cnt) = n;

  
    %_______STORE RESULTS_______________________________________________
    switch best_result_disp
        case 1
            % Store the current displacements (the main displacements are u1, v1)
            DEFORMATION_PARAMETERS(jj,ii,1) = best_result(1);       % main displacement u
            DEFORMATION_PARAMETERS(jj,ii,2) = best_result(2);       % main displacement v
            DEFORMATION_PARAMETERS(jj,ii,3) = best_result(3);       % main 1st order def. du/dx      
            DEFORMATION_PARAMETERS(jj,ii,4) = best_result(4);       % main 1st order def. dv/dy 
            DEFORMATION_PARAMETERS(jj,ii,5) = best_result(5);       % main 1st order def. du/dy 
            DEFORMATION_PARAMETERS(jj,ii,6) = best_result(6);       % main 1st order def. dv/dx 
            DEFORMATION_PARAMETERS(jj,ii,7) = best_result(7);       % secondary displacement u
            DEFORMATION_PARAMETERS(jj,ii,8) = best_result(8);       % secondary displacement v
            DEFORMATION_PARAMETERS(jj,ii,9) = best_result(9);       % secondary 1st order def. du/dx
            DEFORMATION_PARAMETERS(jj,ii,10) = best_result(10);     % secondary 1st order def. dv/dy 
            DEFORMATION_PARAMETERS(jj,ii,11) = best_result(11);     % secondary 1st order def. du/dy 
            DEFORMATION_PARAMETERS(jj,ii,12) = best_result(12);     % secondary 1st order def. dv/dx
            DEFORMATION_PARAMETERS(jj,ii,13) = best_result(13);     % line parameter: slope a
            DEFORMATION_PARAMETERS(jj,ii,14) = best_result(14);     % line parameter: y-intercept b
            DEFORMATION_PARAMETERS(jj,ii,15) = 1-best_result(15);   % correlation quality
        case 2
            % Store the current displacements (the main displacements are u2, v2)
            DEFORMATION_PARAMETERS(jj,ii,1) = best_result(7);       % main displacement u
            DEFORMATION_PARAMETERS(jj,ii,2) = best_result(8);       % main displacement v
            DEFORMATION_PARAMETERS(jj,ii,3) = best_result(9);       % main 1st order def. du/dx      
            DEFORMATION_PARAMETERS(jj,ii,4) = best_result(10);      % main 1st order def. dv/dy 
            DEFORMATION_PARAMETERS(jj,ii,5) = best_result(11);      % main 1st order def. du/dy 
            DEFORMATION_PARAMETERS(jj,ii,6) = best_result(12);      % main 1st order def. dv/dx 
            DEFORMATION_PARAMETERS(jj,ii,7) = best_result(1);       % secondary displacement u
            DEFORMATION_PARAMETERS(jj,ii,8) = best_result(2);       % secondary displacement v
            DEFORMATION_PARAMETERS(jj,ii,9) = best_result(3);       % secondary 1st order def. du/dx
            DEFORMATION_PARAMETERS(jj,ii,10) = best_result(4);      % secondary 1st order def. dv/dy 
            DEFORMATION_PARAMETERS(jj,ii,11) = best_result(5);      % secondary 1st order def. du/dy 
            DEFORMATION_PARAMETERS(jj,ii,12) = best_result(6);      % secondary 1st order def. dv/dx
            DEFORMATION_PARAMETERS(jj,ii,13) = best_result(13);     % line parameter: slope a
            DEFORMATION_PARAMETERS(jj,ii,14) = best_result(14);     % line parameter: y-intercept b
            DEFORMATION_PARAMETERS(jj,ii,15) = 1-best_result(15);   % correlation quality
        otherwise % disps == NaN
            % Store the current displacements (the main displacements are u2, v2)
            DEFORMATION_PARAMETERS(jj,ii,1) = (best_result(1)+best_result(7))/2;       % main displacement u
            DEFORMATION_PARAMETERS(jj,ii,2) = (best_result(2)+best_result(8))/2;       % main displacement v
            DEFORMATION_PARAMETERS(jj,ii,3) = (best_result(3)+best_result(9))/2;       % main 1st order def. du/dx      
            DEFORMATION_PARAMETERS(jj,ii,4) = (best_result(4)+best_result(10))/2;      % main 1st order def. dv/dy 
            DEFORMATION_PARAMETERS(jj,ii,5) = (best_result(5)+best_result(11))/2;      % main 1st order def. du/dy 
            DEFORMATION_PARAMETERS(jj,ii,6) = (best_result(6)+best_result(12))/2;      % main 1st order def. dv/dx 
            DEFORMATION_PARAMETERS(jj,ii,7) = (best_result(7)+best_result(1))/2;       % secondary displacement u
            DEFORMATION_PARAMETERS(jj,ii,8) = (best_result(8)+best_result(2))/2;       % secondary displacement v
            DEFORMATION_PARAMETERS(jj,ii,9) = (best_result(9)+best_result(3))/2;       % secondary 1st order def. du/dx
            DEFORMATION_PARAMETERS(jj,ii,10) = (best_result(10)+best_result(4))/2;     % secondary 1st order def. dv/dy 
            DEFORMATION_PARAMETERS(jj,ii,11) = (best_result(11)+best_result(5))/2;     % secondary 1st order def. du/dy 
            DEFORMATION_PARAMETERS(jj,ii,12) = (best_result(12)+best_result(6))/2;     % secondary 1st order def. dv/dx
            DEFORMATION_PARAMETERS(jj,ii,13) = best_result(13);                        % line parameter: slope a
            DEFORMATION_PARAMETERS(jj,ii,14) = best_result(14);                        % line parameter: y-intercept b
            DEFORMATION_PARAMETERS(jj,ii,15) = 1-best_result(15);                      % correlation quality
            
            % The correlation here is not possible
            good_corr(jj,ii) = 0; % Could not correlate this point (subset set center was split by line fit)
    end
end % End the looping once all subsets have successfully been split
        
% Fix the "NaN" displacements by averaging with valid, nearby displacements
[DEFORMATION_PARAMETERS, good_corr_out] = NaN_Value_Averaging(good_corr, DEFORMATION_PARAMETERS);

end % if num_subset_split > 0

% Record total run-time
run_time = toc;
% Compute average progressbar time
t_total_bar = mean(t_prog)*total_num_subsets;
% Compute average optimization time
t_total_optim = mean(t_optim)*total_num_subsets;
% Compute average interpolation time
t_total_interp = mean(t_interp)*total_num_subsets;

% Average number of iterations
Ave_iter = mean(iters);

% Close the progressbar window
%close(findobj('Name','ProgressBar'));
close(h_wait);

%_______________END COMPUTATIONS________________

% Store the good_corr matrix to show how subset splitting performed
SaveGoodCorrData(good_corr, split_tol, f_g_tol, false);

End_Correlation_Processing(DEFORMATION_PARAMETERS, run_time, t_total_bar, t_total_optim, t_total_interp, Ave_iter, q_0  );


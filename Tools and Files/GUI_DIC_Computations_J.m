%{
This file is part of the McGill Digital Image Correlation Research Tool (MDICRT).
Copyright © 2008, Jeffrey Poissant, Francois Barthelat

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


% Digital Image Correlation: First Order
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  June 23, 2007
% Modified on: August 27, 2007


-----------------------------------------------------------
|       DIGITAL IMAGE CORRELATION: FIRST ORDER            |
-----------------------------------------------------------

The goal of this program is to perform digital image correlation such that
the Rigid Translations can be determined between a reference and a 
deformed image.
%}

%*********************************************************
%*                   MAIN FUNCTION                       *
%*********************************************************
function GUI_DIC_Computations_J( method )

switch method
    case 'Zeroth'
        Zeroth_Order_GUI_DIC
    case 'First'
        First_Order_GUI_DIC
    case 'Zeroth Split'
        fprint(1, '\nThe function Zeroth Order Subset Splitting is unavailble\n\n');
        %Zeroth_Split_GUI_DIC
    case 'First Split'
        First_Split_GUI_DIC
    otherwise
        First_Order_GUI_DIC
end % switch
end % function







%*********************************************************
%*                   ZEROTH ORDER                        *
%*********************************************************

function Zeroth_Order_GUI_DIC
   
% Call the script command "Initialize_Variables" to set every variable we will need
Initialize_Variables   

% Preallocate the matrix that holds the deformation parameter results
DEFORMATION_PARAMETERS = zeros(num_subsets_Y, num_subsets_X, 3);

% Set the initial guess to be the "last iteration's" solution.
q_k(1:2,1) = q_0(1:2,1);


%_______________COMPUTATIONS________________

% Start the timer: Track the time it takes to perform the heaviest computations
tic


%__________FIT SPLINE ONTO DEFORMED SUBSET________________________
% Obtain the size of the reference image
[Y_size, X_size] = size(ref_image);

% Define the deformed image's coordinates
X_defcoord = 1:X_size;
Y_defcoord = 1:Y_size;

% Fit the interpolating spline: g(x,y)
def_interp = spapi( {spline_order,spline_order}, {Y_defcoord, X_defcoord}, def_image(Y_defcoord,X_defcoord) );

% Find the partial derivitives of the spline: dg/dx and dg/dy
%def_interp_x = fnder(def_interp, [0,1]);
%def_interp_y = fnder(def_interp, [1,0]);

% Convert all the splines from B-form into ppform to make it computationally cheaper to evaluate
def_interp = fn2fm(def_interp, 'pp');
def_interp_x = fnder(def_interp, [0,1]);
def_interp_y = fnder(def_interp, [1,0]);
%_________________________________________________________________________ 
t_interp = toc;    % Save the amount of time it took to interpolate




% MAIN CORRELATION LOOP -- CORRELATE THE POINT REQUESTED
for counter = 1:total_num_subsets

    t_tmp = toc;
    %__________UPDATE THE PROGRESS BAR_________________________________
    % Display correlation's progress in the progress bar
    if mod(counter,floor(total_num_subsets*update_every)) == 0;
        progbar = roundn((counter/total_num_subsets).*100,-2);
        % Compute an estimate to see how much time remains
        t_now = toc;
        t_left = ((100/progbar - 1)*t_now);
        t_left_min = floor(t_left/60);
        t_left_sec = roundn(mod(t_left,60),-2);
        BarText = sprintf('Correlating subsets:  %s out of %s,          Estimated Time: %s min, %s sec\n%4.1f%% Complete', ...
                num2str(counter), num2str(total_num_subsets), num2str(t_left_min), num2str(t_left_sec), progbar);
        %ProgressBar;
        waitbar(progbar/100, h_wait, BarText);
    end
    %_________________________________________________________________________ 
    t_prog(counter) = toc - t_tmp;      % Save the amount of time it took to update the progress bar


    %t_tmp = toc;
    %__________FIT SPLINE ONTO DEFORMED SUBSET________________________
    % Define the center coordinates of the new subset
    Xp = Xp_first + subset_space*(ii-1);
    Yp = Yp_first + subset_space*(jj-1);

    % The interpolation buffer is by how many more pixels, on each side, is the sector larger than the subset
    % Define the sector's coordinates
    %X_defcoord = -floor(subset_size/2)+Xp+floor(q_k(1))-interp_buffer:floor(subset_size/2)+Xp+floor(q_k(1))+interp_buffer;
    %Y_defcoord = -floor(subset_size/2)+Yp+floor(q_k(2))-interp_buffer:floor(subset_size/2)+Yp+floor(q_k(2))+interp_buffer;

    % Fit the interpolating spline: g(x,y)
    %def_interp = spapi( {spline_order,spline_order}, {Y_defcoord, X_defcoord}, def_image(Y_defcoord,X_defcoord) );

    % Find the partial derivitives of the spline: dg/dx and dg/dy
    %def_interp_x = fnder(def_interp, [0,1]);
    %def_interp_y = fnder(def_interp, [1,0]);
    %_________________________________________________________________________ 
    %t_interp(counter) = toc - t_tmp;    % Save the amount of time it took to interpolate


    t_tmp = toc;
    %__________OPTIMIZATION ROUTINE: FIND BEST FIT____________________________
    switch optim_method 
        case 'Newton Raphson'

        % Initialize some values
        n = 0;
        [C_last, GRAD_last, HESS ] = C_Zeroth_Order(q_k);   % q_k was the result from last point or the user's guess
        optim_completed = false;

        while optim_completed == false

            % Compute the next guess and update the values
            delta_q = HESS\(-GRAD_last);                     % Find the difference between q_k+1 and q_k
            q_k = q_k + delta_q;                             % q_k+1 = q_k + delta_q
            [C, GRAD, HESS] = C_Zeroth_Order(q_k);           % Compute new values

            % Add one to the iteration counter
            n = n + 1;                                       % Keep track of the number of iterations          

            % Check to see if the values have converged according to the stopping criteria
            if n > Max_num_iter || ( abs(C-C_last) < TOL(1) && all(abs(delta_q) < TOL(2)) )
                optim_completed = true;
            end

            C_last = C;                                      % Save the C value for comparison in the next iteration
            GRAD_last = GRAD;                                % Save the GRAD value for comparison in the next iteration
        end
        case 'fmincon'
            q_o = q_k(1:2);                                 % Initial Guess equals the last iteration's result
            q_lb = q_o-1;                                   % Lower bound is 1 pixel less than initial guess
            q_ub = q_o+1;                                   % Upper bound is 1 pixel more than initial guess
            [q_k(1:2), C] = fmincon( @C_Zeroth_Order, ...   % Optimize
                                     q_o,             ...
                                     [], [], [], [],  ...
                                     q_lb,            ...
                                     q_ub, [],        ...
                                     options);
    end
    %_________________________________________________________________________
    t_optim(counter) = toc - t_tmp;
    iters(counter) = n;


    %_______STORE RESULTS AND PREPARE INDICES OF NEXT SUBSET__________________
    % Store the current displacements
    DEFORMATION_PARAMETERS(jj,ii,1) = q_k(1);
    DEFORMATION_PARAMETERS(jj,ii,2) = q_k(2);
    DEFORMATION_PARAMETERS(jj,ii,3) = 1-C;

    % Prepare/Track the movement of the subset center
    ii = ii + (-1).^(mod(jj,2)+1);
    if ( mod(counter,num_subsets_X) == 0 )
        ii = ii - (-1).^(mod(jj,2)+1);
        jj = jj + 1;
    end
    %_________________________________________________________________________

end % End the looping once all subsets are evaluated    


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


%_______POST-PROCESSING__________________________________________

End_Correlation_Processing(DEFORMATION_PARAMETERS, run_time, t_total_bar, t_total_optim, t_total_interp, Ave_iter, q_0  );


return;
end % function







%*********************************************************
%*                   FIRST ORDER                         *
%*********************************************************

function First_Order_GUI_DIC                          

% Call the script command "Initialize_Variables" to set every variable we will need
Initialize_Variables

% Preallocate the matrix that holds the deformation parameter results
DEFORMATION_PARAMETERS = zeros(num_subsets_Y, num_subsets_X, 3);

% Set the initial guess to be the "last iteration's" solution.
q_k(1:6,1) = q_0(1:6,1);


%_______________COMPUTATIONS________________

% Start the timer: Track the time it takes to perform the heaviest computations
tic

%__________FIT SPLINE ONTO DEFORMED SUBSET________________________
% Obtain the size of the reference image
[Y_size, X_size] = size(ref_image);

% Define the deformed image's coordinates
X_defcoord = 1:X_size;
Y_defcoord = 1:Y_size;

% Fit the interpolating spline: g(x,y)
def_interp = spapi( {spline_order,spline_order}, {Y_defcoord, X_defcoord}, def_image(Y_defcoord,X_defcoord) );

% Find the partial derivitives of the spline: dg/dx and dg/dy
%def_interp_x = fnder(def_interp, [0,1]);
%def_interp_y = fnder(def_interp, [1,0]);

% Convert all the splines from B-form into ppform to make it computationally cheaper to evaluate
def_interp = fn2fm(def_interp, 'pp');
def_interp_x = fnder(def_interp, [0,1]);
def_interp_y = fnder(def_interp, [1,0]);
%_________________________________________________________________________ 
t_interp = toc;    % Save the amount of time it took to interpolate


% MAIN CORRELATION LOOP -- CORRELATE THE POINTS REQUESTED
for counter = 1:total_num_subsets

    t_tmp = toc;
    %__________UPDATE THE PROGRESS BAR_________________________________
    % Display correlation's progress in the progress bar
    if mod(counter,floor(total_num_subsets*update_every)) == 0;
        progbar = roundn((counter/total_num_subsets).*100,-2);
        % Compute an estimate to see how much time remains
        t_now = toc;
        t_left = ((100/progbar - 1)*t_now);
        t_left_min = floor(t_left/60);
        t_left_sec = roundn(mod(t_left,60),-2);
        BarText = sprintf('Correlating subsets:  %s out of %s,          Estimated Time: %s min, %s sec\n%4.1f%% Complete', ...
                num2str(counter), num2str(total_num_subsets), num2str(t_left_min), num2str(t_left_sec), progbar);
        %ProgressBar;
        waitbar(progbar/100, h_wait, BarText);
        
    end
    %_________________________________________________________________________ 
    t_prog(counter) = toc - t_tmp;      % Save the amount of time it took to update the progress bar


    %t_tmp = toc;
    %__________FIT SPLINE ONTO DEFORMED SUBSET________________________
    % Define the center coordinates of the new subset
    Xp = Xp_first + subset_space*(ii-1);
    Yp = Yp_first + subset_space*(jj-1);

    % The interpolation buffer is by how many more pixels, on each side, is the sector larger than the subset
    % Define the sector's coordinates
    %X_defcoord = -floor(subset_size/2)+Xp+floor(q_k(1))-interp_buffer:floor(subset_size/2)+Xp+floor(q_k(1))+interp_buffer;
    %Y_defcoord = -floor(subset_size/2)+Yp+floor(q_k(2))-interp_buffer:floor(subset_size/2)+Yp+floor(q_k(2))+interp_buffer;

    % Fit the interpolating spline: g(x,y)
    %def_interp = spapi( {spline_order,spline_order}, {Y_defcoord, X_defcoord}, def_image(Y_defcoord,X_defcoord) );

    % Find the partial derivitives of the spline: dg/dx and dg/dy
    %def_interp_x = fnder(def_interp, [0,1]);
    %def_interp_y = fnder(def_interp, [1,0]);
    %_________________________________________________________________________ 
    %t_interp(counter) = toc - t_tmp;    % Save the amount of time it took to interpolate


    t_tmp = toc;
    %__________OPTIMIZATION ROUTINE: FIND BEST FIT____________________________
    switch optim_method 
        case 'Newton Raphson'

        % Initialize some values
        n = 0;
        [C_last, GRAD_last, HESS ] = C_First_Order(q_k);   % q_k was the result from last point or the user's guess
        optim_completed = false;

        while optim_completed == false

            % Compute the next guess and update the values
            delta_q = HESS\(-GRAD_last);                     % Find the difference between q_k+1 and q_k
            q_k = q_k + delta_q;                             % q_k+1 = q_k + delta_q
            [C, GRAD, HESS] = C_First_Order(q_k);            % Compute new values

            % Add one to the iteration counter
            n = n + 1;                                       % Keep track of the number of iterations

            % Check to see if the values have converged according to the stopping criteria
            if n > Max_num_iter || ( abs(C-C_last) < TOL(1) && all(abs(delta_q) < TOL(2)) )
                optim_completed = true;
            end

            C_last = C;                                      % Save the C value for comparison in the next iteration
            GRAD_last = GRAD;                                % Save the GRAD value for comparison in the next iteration
        end
        case 'fmincon'
            q_o = q_k(1:6);                                 % Initial Guess equals the last iteration's result
            q_lb = q_o-1;                                   % Lower bound is 1 pixel less than initial guess
            q_ub = q_o+1;                                   % Upper bound is 1 pixel more than initial guess
            [q_k(1:6), C] = fmincon( @C_First_Order, ...    % Optimize
                                     q_o,             ...
                                     [], [], [], [],  ...
                                     q_lb,            ...
                                     q_ub, [],        ...
                                     options);
    end
    %_________________________________________________________________________
    t_optim(counter) = toc - t_tmp;
    iters(counter) = n;


    %_______STORE RESULTS AND PREPARE INDICES OF NEXT SUBSET__________________
    % Store the current displacements
    DEFORMATION_PARAMETERS(jj,ii,1) = q_k(1);
    DEFORMATION_PARAMETERS(jj,ii,2) = q_k(2);
    DEFORMATION_PARAMETERS(jj,ii,3) = q_k(3);
    DEFORMATION_PARAMETERS(jj,ii,4) = q_k(4);
    DEFORMATION_PARAMETERS(jj,ii,5) = q_k(5);
    DEFORMATION_PARAMETERS(jj,ii,6) = q_k(6);
    DEFORMATION_PARAMETERS(jj,ii,7) = 1-C;

    % Prepare/Track the movement of the subset center
    ii = ii + (-1).^(mod(jj,2)+1);
    if ( mod(counter,num_subsets_X) == 0 )
        ii = ii - (-1).^(mod(jj,2)+1);
        jj = jj + 1;
    end
    %_________________________________________________________________________

end % End the looping once all subsets are evaluated


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




%_______POST-PROCESSING__________________________________________

End_Correlation_Processing(DEFORMATION_PARAMETERS, run_time, t_total_bar, t_total_optim, t_total_interp, Ave_iter, q_0  );

return;
end % function






%*********************************************************
%*                   ZEROTH SPLIT                        *
%*********************************************************

function Zeroth_Split_GUI_DIC                          

% Call the script command "Initialize_Variables" to set variables we will need
Initialize_Variables;

global last_WS;
global Input_info;
global do_incremental;
global date_time_run;

global def_interp_up;
global def_interp_down;
global def_interp_x_up;
global def_interp_x_down;
global def_interp_y_up;
global def_interp_y_down;

% Preallocate the matrix that holds the deformation parameter results
DEFORMATION_PARAMETERS = zeros(num_subsets_Y, num_subsets_X, 11);

% Set the initial guess for standard DIC to be the results of initialization
q_k(1:6,1) = q_0(1:6,1);

% Define q_good, a variable that remembers the last well correlated solution.
q_good = q_k;

% i and j will define the subset points to be compared.
i = -floor(subset_size/2) : 1 : floor(subset_size/2);
j = -floor(subset_size/2) : 1 : floor(subset_size/2);

% I_matrix and J_matrix are the grid of data points formed by vectors i and j
[I_matrix,J_matrix] = meshgrid(i,j);

% Store the number of points in the subset
N = subset_size.*subset_size;

% Reshape the I and J from grid matrices into vectors containing the (x,y) coordinates of each point
% This is needed to evaluate the deformed positions (which are no longer forming a grid)
I = reshape(I_matrix, 1,N);
J = reshape(J_matrix, 1,N);

% These values will determine when subset splitting is required. Make them too big for now
mean_C = 1;

% This tolerance value will define what a "bad" value is when subset splitting is applied.
global f_g_tol;
f_g_tol = 0;

% This variable will store a good initial guess for subset splitting
first_split = true;

% This counter will track how many subsets (points) were well correlated
num_good_corr = 0;

% This counter will track how many subsets (points) need subset splitting
num_subsets_split = 0;

% Track which points are good correlations, which are bad
good_corr = ones(num_subsets_Y, num_subsets_X);

% Define the mulitplier of mean_C to determine when subset splitting is needed
tol_multi = 1.5;


%_______________COMPUTATIONS________________

% Start the timer: Track the time it takes to perform the heaviest computations
tic

%__________FIT SPLINE ONTO DEFORMED SUBSET________________________
% Obtain the size of the reference image
[Y_size, X_size] = size(ref_image);

% Define the deformed image's coordinates
X_defcoord = 1:X_size;
Y_defcoord = 1:Y_size;

% Fit the interpolating spline: g(x,y)
def_interp = spapi( {spline_order,spline_order}, {Y_defcoord, X_defcoord}, def_image(Y_defcoord,X_defcoord) );

% Find the partial derivitives of the spline: dg/dx and dg/dy
%def_interp_x = fnder(def_interp, [0,1]);
%def_interp_y = fnder(def_interp, [1,0]);

% Convert all the splines from B-form into ppform to make it computationally cheaper to evaluate
def_interp = fn2fm(def_interp, 'pp');
def_interp_x = fnder(def_interp, [0,1]);
def_interp_y = fnder(def_interp, [1,0]);
%_________________________________________________________________________ 
t_interp = toc;    % Save the amount of time it took to interpolate

% MAIN CORRELATION LOOP -- CORRELATE THE POINTS REQUESTED
for counter = 1:total_num_subsets

    t_tmp = toc;
    %__________UPDATE THE PROGRESS BAR_________________________________
    % Display correlation's progress in the progress bar
    if mod(counter,floor(total_num_subsets*update_every)) == 0;
        progbar = roundn((counter/total_num_subsets).*100,-2);
        % Compute an estimate to see how much time remains
        t_now = toc;
        t_left = ((100/progbar - 1)*t_now);
        t_left_min = floor(t_left/60);
        t_left_sec = roundn(mod(t_left,60),-2);
        BarText = sprintf('Correlating subsets:  %s out of %s,          Estimated Time: %s min, %s sec\n%4.1f%% Complete', ...
                num2str(counter), num2str(total_num_subsets), num2str(t_left_min), num2str(t_left_sec), progbar);
        %ProgressBar;
        waitbar(progbar/100, h_wait, BarText);
    end
    %_________________________________________________________________________ 
    t_prog(counter) = toc - t_tmp;      % Save the amount of time it took to update the progress bar


    t_tmp = toc;
    %__________FIT SPLINE ONTO DEFORMED SUBSET________________________
    % Define the center coordinates of the new subset
    Xp = Xp_first + subset_space*(ii-1);
    Yp = Yp_first + subset_space*(jj-1);

    % The interpolation buffer is by how many more pixels, on each side, is the sector larger than the subset
    % Define the sector's coordinates
    X_defcoord = -floor(subset_size/2)+Xp+floor(q_k(1))-interp_buffer:floor(subset_size/2)+Xp+floor(q_k(1))+interp_buffer;
    Y_defcoord = -floor(subset_size/2)+Yp+floor(q_k(2))-interp_buffer:floor(subset_size/2)+Yp+floor(q_k(2))+interp_buffer;

    % Fit the interpolating spline: g(x,y)
    def_interp = spapi( {spline_order,spline_order}, {Y_defcoord, X_defcoord}, def_image(Y_defcoord,X_defcoord) );

    % Find the partial derivitives of the spline: dg/dx and dg/dy
    def_interp_x = fnder(def_interp, [0,1]);
    def_interp_y = fnder(def_interp, [1,0]);
    %_________________________________________________________________________ 
    t_interp(counter) = toc - t_tmp;    % Save the amount of time it took to interpolate


    t_tmp = toc;
        
    
    %__________OPTIMIZATION ROUTINE: FIND BEST FIT____________________________
    switch optim_method 
        case 'Newton Raphson'
            
            % Always start by assuming no splitting is needed
            split_subset = false;

            % Perform regular 1st order DIC
            % Initialize some values
            n = 0;
            [C_last, GRAD_last, HESS ] = C_First_Order(q_k);   % q_k was the result from last point or the user's guess
            optim_completed = false;

            while optim_completed == false

                % Compute the next guess and update the values
                delta_q = HESS\(-GRAD_last);                     % Find the difference between q_k+1 and q_k
                q_k = q_k + delta_q;                             % q_k+1 = q_k + delta_q
                [C, GRAD, HESS] = C_First_Order(q_k);            % Compute new values

                % Add one to the iteration counter
                n = n + 1;                                       % Keep track of the number of iterations

                % Check to see if the values have converged according to the stopping criteria
                if n > Max_num_iter || ( abs(C-C_last) < TOL(1) && all(abs(delta_q) < TOL(2)) )
                    optim_completed = true;
                end

                C_last = C;                                      % Save the C value for comparison in the next iteration
                GRAD_last = GRAD;                                % Save the GRAD value for comparison in the next iteration
            end
        %_________________________________________________________________________
    end
    t_optim(counter) = toc - t_tmp;
    iters(counter) = n;


    %_______STORE RESULTS AND PREPARE INDICES OF NEXT SUBSET__________________
    % Store the current displacements
    DEFORMATION_PARAMETERS(jj,ii,1) = q_k(1);       % displacement u1
    DEFORMATION_PARAMETERS(jj,ii,2) = q_k(2);       % displacement v1
    DEFORMATION_PARAMETERS(jj,ii,3) = q_k(3);       % 1st order def. du1/dx      
    DEFORMATION_PARAMETERS(jj,ii,4) = q_k(4);       % 1st order def. dv1/dy 
    DEFORMATION_PARAMETERS(jj,ii,5) = q_k(5);       % 1st order def. du1/dy 
    DEFORMATION_PARAMETERS(jj,ii,6) = q_k(6);       % 1st order def. dv1/dx 
    DEFORMATION_PARAMETERS(jj,ii,7) = NaN;          % subset split displacement u2 
    DEFORMATION_PARAMETERS(jj,ii,8) = NaN;          % subset split displacement v2
    DEFORMATION_PARAMETERS(jj,ii,9) = NaN;          % line parameter: slope a
    DEFORMATION_PARAMETERS(jj,ii,10) = NaN;         % line parameter: y-intercept b
    DEFORMATION_PARAMETERS(jj,ii,11) = 1-C;         % correlation quality

    
    % CHECKING IF WE NEED SUBSET SPLITTING
            
    % If the current correlation quality is greater than some tolerance quality, 
    % then the subset should be split since the correlation was bad. 
    if C > tol_multi*mean_C
        split_subset = true;
    end

    if split_subset == false    % If it's a good correlation, update the tolerances
        
        % Get the intensities using the last good answer as initial guess
        f_result = reshape(ref_image(Yp+j, Xp+i), 1,N);
        X = Xp + q_k(1) + I + I.*q_k(3) + J.*q_k(5);
        Y = Yp + q_k(2) + J + J.*q_k(4) + I.*q_k(6);
        g_result = fnval(def_interp, [Y;X]);
        
        % With the two subsets compute (f-g)^2
        f_g_sq_result = (f_result-g_result).^2;
        mean_C    = (mean_C*(num_good_corr) + C)/(num_good_corr+1);                     % Since this is a good correlation, update the average of "C"
        if first_split == true
            f_g_tol   = (f_g_tol*(num_good_corr) + max(f_g_sq_result))/(num_good_corr+1); % Since this is a good correlation, update the tol of (f-g)^2
        end
        
        % Increment the number of good correlations counter
        num_good_corr = num_good_corr + 1;
        
    else            % If it's a bad correlation, record information about the current point in order to perform subset splitting later

        % Increment the number of subsets that need splitting
        num_subsets_split = num_subsets_split + 1;

        % Record the (x,y) positions, as well as the indices (jj,ii), and the counter number
        Xsplit(num_subsets_split,1) = Xp;
        Ysplit(num_subsets_split,1) = Yp;
        JJsplit(num_subsets_split,1) = jj;
        IIsplit(num_subsets_split,1) = ii;
        cnt_split(num_subsets_split,1) = counter;
        
        % This is a bad correlation, take note of it.
        good_corr(jj,ii) = 0;

    end % if split_subset
        

    % Prepare/Track the movement of the subset center
    ii = ii + (-1).^(mod(jj,2)+1);
    if ( mod(counter,num_subsets_X) == 0 )
        ii = ii - (-1).^(mod(jj,2)+1);
        jj = jj + 1;
    end
    %_________________________________________________________________________

end % End the looping once all subsets are evaluated

% Save the current directory
tmp_directory = pwd;
% Save the current results
output_folder_path = End_NoSplit_Correlation(DEFORMATION_PARAMETERS, good_corr, mean_C, f_g_tol);


%------------------------SAVE THE WORKSPACE-------------------------------
[tmp1, tmp2, tmp3] = mkdir(output_folder_path, 'PreSplit_Workspace');
clear tmp1 tmp2 tmp3;

% Record the date and time now for the input and workspace files
date_time = now;
date_time_short = datestr(date_time, ' yyyy-mm-dd, HH''MM''SS');

% Define the original filename and save the workspace to this file
workspace_name = strcat('\PreSplit_Workspace', date_time_short, '.mat');
save(strcat(output_folder_path, '\PreSplit_Workspace', workspace_name));
%------------------------END SAVE THE WORKSPACE-------------------------------

% Return to the original directory
cd(tmp_directory);


% Define the X and Y coordinates of each subset center
mesh_col = Xp_first:subset_space:(num_subsets_X-1)*subset_space+Xp_first;
mesh_row = Yp_first:subset_space:(num_subsets_Y-1)*subset_space+Yp_first;
    
% Call the function that will ask the user for a tolerance
Selected_Subsets = Splitting_Tol_Select(mesh_col, mesh_row, DEFORMATION_PARAMETERS);

% Redefine the subset splitting data if needed
if isempty(Selected_Subsets) == false
    good_corr           = Selected_Subsets.good_corr;
    IIsplit             = Selected_Subsets.IIsplit;
    JJsplit             = Selected_Subsets.JJsplit;
    Xsplit              = Selected_Subsets.Xsplit;
    Ysplit              = Selected_Subsets.Ysplit;
    cnt_split           = Selected_Subsets.cnt_split;
    num_subsets_split   = Selected_Subsets.num_subsets_split;
    num_good_corr       = total_num_subsets - num_subsets_split;
end










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
q_0_B(1:2,1) = 0;




% Restart the timer
tic
%---------------------SUBSET SPLITTING--------------------------------

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
    
    % Before we begin subset splitting, we need to determine a good initial
    % guess for the displacements of the subset. Since subset splitting
    % involves deforming two parts of the subset differently, we need to have two
    % sets of deformation parameters. 
    
    % First, let's save the results of from non-spitting DIC in case subset splitting makes things worse:
    best_result(1:2, 1) = DEFORMATION_PARAMETERS(jj,ii,1:2);        % Deformation u, v
    best_result(3:4, 1) = 0;                                        % Deformation uJ, vJ
    best_result(5:6, 1) = NaN;                                      % Line parameters a, b
    best_result(7,1)    = 1-DEFORMATION_PARAMETERS(jj,ii,end);      % Correlation Quality C
    best_result(8,1)    = 1;                                        % "disps" (position of master subset)
    
    % At this point, we have all the well correlated solutions near the current point of interest. 
    % By finding the best one, we'll get a good estimate for one set of deformation paramters.
    q_0_G = Initial_Guess_Good(good_corr, ii, jj, DEFORMATION_PARAMETERS);
    
    
    t_tmp = toc;
    %__________FIT SPLINE ONTO GOOD DEFORMED SECTOR________________________
    % Now that we have an idea where one part of the correlation takes place, define the first deformed image sector.
    X_defcoord_G       = -floor(subset_size/2)+Xp+floor(q_0_G(1))-interp_buffer:floor(subset_size/2)+Xp+floor(q_0_G(1))+interp_buffer;
    Y_defcoord_G       = -floor(subset_size/2)+Yp+floor(q_0_G(2))-interp_buffer:floor(subset_size/2)+Yp+floor(q_0_G(2))+interp_buffer;

    % Fit the interpolating spline: g(x,y) around the first sector of interest
    def_interp_G   = spapi( {spline_order,spline_order}, {Y_defcoord_G, X_defcoord_G}, def_image(Y_defcoord_G, X_defcoord_G) );

    % Find the partial derivitives of the spline: dg/dx and dg/dy
    def_interp_x_G = fnder(def_interp_G, [0,1]);
    def_interp_y_G = fnder(def_interp_G, [1,0]);
    t_good_interp = toc - t_tmp;    % Save the amount of time it took to interpolate

    
    
    % Now, the other part of the initial guess (uJ and vJ) must be obtained by
    % performing a coarse search. However, to avoid any bias from the good
    % points that deform by q_0_G, the subset will be multiplied by the
    % "Bad_Values" matrix to zero out these points.
    
    % The "Bad_Values" matrix is obtained by finding which of the subset points are 
    % poorly correlated when using q_0_G as displacement with no splitting.
    
    % Get the intensities of the reference and deformed images
    f_0 = ref_image(Yp+j, Xp+i);
    if isnan(q_0_G(3:6)) == false
        X = Xp + q_0_G(1) + I + I.*q_0_G(3) + J.*q_0_G(5);
        Y = Yp + q_0_G(2) + J + J.*q_0_G(4) + I.*q_0_G(6);
    else
        X = Xp + q_0_G(1) + I;
        Y = Yp + q_0_G(2) + J;
    end
    g_0 = reshape( fnval(def_interp_G, [Y;X]), subset_size, subset_size);
    
    % The difference between the reference and deformed intensities
    % squared, should have some points which are over some tolerance. These
    % are the "Bad_Values".
    Bad_Values = (f_0-g_0).^2 > f_g_tol;
    
    Bad_Values = Max_Min_filter( Max_Min_filter(Bad_Values, subset_size, 'max'), subset_size, 'min');
    
    
    if numel(find(Bad_Values)) <= 1.5.*subset_size
        
        if any(isnan(q_0_G(3:6))) == true
            q_1(1:2,1) = q_0_G(1:2);
            q_1(3:6,1) = 0;
        else
            q_1 = q_0_G;
        end
        
        results = Few_Bad_Values_Subset_Splitting( q_1, Bad_Values );
        
        % If the current initial guess for subset splitting is better than last result
        % of DIC, save it as the best answer (so far)
        if results(end) < best_result(end-1)
            best_result = [results(1:2); 0; 0; NaN; NaN; results(end); 1];
            checker = best_result;
        end
    end
    

    %_________________COARSE INITIAL GUESS SEARCH____________________________
    % Perform a coarse search for the best "u" and "v" values within a region
    range = 10;   % For now... assume that the correct value is within 10 pixels.
    u_check = (round(q_0_B(1)) - range):(round(q_0_B(1)) + range);
    v_check = (round(q_0_B(2)) - range):(round(q_0_B(2)) + range);

    % Define the intensities of the reference subset
    subref = f_0;

    % Zero out the points which are well correlated
    subref = subref.*Bad_Values;

    % Preallocate some matrix space               
    sum_diff_sq = zeros(numel(u_check), numel(v_check));

    % Check every value of u and v and see where the best match occurs
    for iter1 = 1:numel(u_check);
        for iter2 = 1:numel(v_check);
            % Extract the deformed intensities at integer locations, zero
            % out the good positions and find the sum of the difference
            % squared for the ref and def intensities.
            subdef = def_image( Yp+v_check(iter2)+j, Xp+u_check(iter1)+i );
            subdef = subdef.*Bad_Values;
            sum_diff_sq(iter2,iter1) = sum(sum( (subref - subdef).^2));
        end
    end
    % The best match is at the minimum value of sum_diff_sq
    [TMP1,OFFSET1] = min(min(sum_diff_sq,[],2));
    [TMP2,OFFSET2] = min(min(sum_diff_sq,[],1));
    q_0_B(1) = u_check(OFFSET2);
    q_0_B(2) = v_check(OFFSET1);
    clear u_check v_check iter1 iter2 subref subdef sum_diff_sq TMP1 TMP2 OFFSET1 OFFSET2;

    % Initialize the vector of deformation parameters q_k = [u, v, uJ, vJ]
    q_k = [q_0_G(1); q_0_G(2); q_0_B(1) - q_0_G(1); q_0_B(2) - q_0_G(2)];
    
    
    t_tmp = toc;
    %__________FIT SPLINE ONTO BAD DEFORMED SECTOR________________________
    % Now that we have an idea where the second part of the correlation takes place, define the second deformed image sector.
    X_defcoord_B       = -floor(subset_size/2)+Xp+floor(q_k(1)+q_k(3))-interp_buffer:floor(subset_size/2)+Xp+floor(q_k(1)+q_k(3))+interp_buffer;
    Y_defcoord_B       = -floor(subset_size/2)+Yp+floor(q_k(2)+q_k(4))-interp_buffer:floor(subset_size/2)+Yp+floor(q_k(2)+q_k(4))+interp_buffer;

    % Fit the interpolating spline: g(x,y) around the second sector of interest
    def_interp_B   = spapi( {spline_order,spline_order}, {Y_defcoord_B, X_defcoord_B}, def_image(Y_defcoord_B, X_defcoord_B) );

    % Find the partial derivitives of the spline: dg/dx and dg/dy
    def_interp_x_B = fnder(def_interp_B, [0,1]);
    def_interp_y_B = fnder(def_interp_B, [1,0]);
    %_________________________________________________________________________ 
    t_interp(cnt) = (toc - t_tmp) + t_good_interp;    % Save the amount of time it took to interpolate


    t_tmp = toc;
    %__________OPTIMIZATION ROUTINE: FIND BEST FIT____________________________
    % Initialize some values
    a_b_optim_completed = false;
    tries = 0;
    a = NaN;
    b = NaN;
    
    while a_b_optim_completed == false
    
        % Check the Bad_Values matrix. If it's all zeros, ignore subset splitting (there's nothing we can do)
        % If it's all ones, or anything else, there's a problem. In such a case, crash and give detailed info. 
        if all(reshape(Bad_Values, 1, N) == 0) 
            
            break;
            
        elseif all(reshape(Bad_Values, 1, N) == 1) || all(isnan(reshape(Bad_Values, 1, N)))
            
            fprintf(1, '\n\nThe Bad_Values matrix was full of %g\n\n\n', Bad_Values(1,1));
            fprintf(1, 'Here is the info on the crash\n\n');
            fprintf(1, '(Xp, Yp) = (%g, %g)\n(ii, jj) = (%g, %g)\n', Xp, Yp, ii, jj );
            fprintf(1, 'n = %g\ntries = %g\n', n, tries);
            fprintf(1, 'a = %g\nb = %g\n', a, b);
            errordlg('Bad_Values = 1 or NaN. Read the command window','Error during Subset Splitting','modal');
            return;
            
        end
        
        % Initialize the number of iterations.
        n = 0;
            
        % Refine the a,b guess using a loop that checks nearby values of "a" and "b"
        [a_new, b_new, good_section, bad_section, disps] = Optimize_a_b_J(q_k, Bad_Values );
        [C_last, GRAD_last, HESS] = C_Zeroth_Split_J(q_k, good_section, bad_section);   % q_k was the result from last point or the user's guess
        optim_completed = false;
        
        % If the current initial guess for subset splitting is better than last result
        % of DIC, save it as the best answer (so far)
        if C_last < best_result(end-1)
            best_result = [q_k; a_new; b_new; C_last; disps];
        end

        while optim_completed == false

            % Compute the next guess and update the values
            if isempty(find(good_section,1)) == true
                delta_q = HESS(3:4,3:4)\(-GRAD_last(3:4));                 % Find the difference between q_k+1 and q_k
                q_k(3:4) = q_k(3:4) + delta_q;                             % q_k+1 = q_k + delta_q
            elseif isempty(find(bad_section,1)) == true
                delta_q = HESS(1:2,1:2)\(-GRAD_last(1:2));                 % Find the difference between q_k+1 and q_k
                q_k(1:2) = q_k(1:2) + delta_q;                             % q_k+1 = q_k + delta_q
            else
                delta_q = HESS\(-GRAD_last);                               % Find the difference between q_k+1 and q_k
                q_k = q_k + delta_q;                                       % q_k+1 = q_k + delta_q
            end
            [C, GRAD, HESS] = C_Zeroth_Split_J(q_k, good_section, bad_section);       % Compute new values

            % Add one to the iteration counter
            n = n + 1;                                       % Keep track of the number of iterations

            % Check to see if the values have converged according to the stopping criteria
            if n > Max_num_iter+15 || ( abs(C-C_last) < TOL(1) && all(abs(delta_q) < TOL(2)) )
                optim_completed = true;
            end

            C_last = C;                                      % Save the C value for comparison in the next iteration
            GRAD_last = GRAD;                                % Save the GRAD value for comparison in the next iteration
        end
        
        % If the current result from subset splitting is better than last result
        % of DIC, save it as the best answer (so far)
        if C_last < best_result(end-1)
            best_result = [q_k; a_new; b_new; C_last; disps];
        end
        
        % If the values of a and b barely changed and if C is now good
        if ( all(abs([a_new - a ; b_new - b]) < TOL(1)) && C <= tol_multi*mean_C )
            % Optimization of a and b is complete
            a_b_optim_completed = true;
            % The correlation here is now good
            good_corr(jj,ii) = 1;
            
            best_result = [q_k; a_new; b_new; C; disps];
            
        elseif tries < 5
            
            try
                a = a_new;
                b = b_new;

                % Update the Bad_Values matrix
                % Get the intensities using the best initial guess
                if all( isnan(q_0_G(3:6)) ) == false
                    X = Xp + q_k(1) + I + I.*q_0_G(3) + J.*q_0_G(5);
                    Y = Yp + q_k(2) + J + J.*q_0_G(4) + I.*q_0_G(6);
                else
                    X = Xp + q_k(1) + I;
                    Y = Yp + q_k(2) + J;
                end
                g_0 = reshape( fnval(def_interp_G, [Y;X]), subset_size, subset_size);

                Bad_Values = (f_0-g_0).^2 > f_g_tol;
                
                Bad_Values = Max_Min_filter( Max_Min_filter(Bad_Values, subset_size, 'max'), subset_size, 'min');

                tries = tries + 1;
            catch
                tries = 6;
            end
        
            
        else % tries >= 5
            % If you reach this point, there were problems trying to get a good solution. 
            % So we need to resort to a linear search, which is a longer method.
                                    
            % Reinitialize the vector of deformation parameters q_k = [u, v, uJ, vJ] in case the previous method diverged
            q_k = [q_0_G(1); q_0_G(2); q_0_B(1) - q_0_G(1); q_0_B(2) - q_0_G(2)];
            
            % Reinitialize the "Bad_Values" matrix
            if isnan(q_0_G(3:6)) == false
                X = Xp + q_0_G(1) + I + I.*q_0_G(3) + J.*q_0_G(5);
                Y = Yp + q_0_G(2) + J + J.*q_0_G(4) + I.*q_0_G(6);
            else
                X = Xp + q_0_G(1) + I;
                Y = Yp + q_0_G(2) + J;
            end
            g_0 = reshape( fnval(def_interp_G, [Y;X]), subset_size, subset_size);
    
            Bad_Values = (f_0-g_0).^2 > f_g_tol;
            
            Bad_Values = Max_Min_filter( Max_Min_filter(Bad_Values, subset_size, 'max'), subset_size, 'min');
            
            % Initialize the number of iterations.
            n = 0;

            % Find the best "a" and "b" using a linear loop search.
            [a_new, b_new, good_section, bad_section, disps] = Optimize_a_b_J(q_k, Bad_Values, [a;b] );
            [C_last, GRAD_last, HESS] = C_Zeroth_Split_J(q_k, good_section, bad_section);
            optim_completed = false;
            
            % If the current initial guess for subset splitting is better than the last result
            % of DIC, save it as the best answer (so far)
            if C_last < best_result(end-1)
                best_result = [q_k; a_new; b_new; C_last; disps];
            end
            
            while optim_completed == false

                % Compute the next guess and update the values
                if isempty(find(good_section,1)) == true
                    delta_q = HESS(3:4,3:4)\(-GRAD_last(3:4));                                % Find the difference between q_k+1 and q_k
                    q_k(3:4) = q_k(3:4) + delta_q;                                            % q_k+1 = q_k + delta_q
                elseif isempty(find(bad_section,1)) == true
                    delta_q = HESS(1:2,1:2)\(-GRAD_last(1:2));                                % Find the difference between q_k+1 and q_k
                    q_k(1:2) = q_k(1:2) + delta_q;                                            % q_k+1 = q_k + delta_q
                else
                    delta_q = HESS\(-GRAD_last);                                              % Find the difference between q_k+1 and q_k
                    q_k = q_k + delta_q;                                                      % q_k+1 = q_k + delta_q
                end
                [C, GRAD, HESS] = C_Zeroth_Split_J(q_k, good_section, bad_section);       % Compute new values

                % Add one to the iteration counter
                n = n + 1;                                       % Keep track of the number of iterations

                % Check to see if the values have converged according to the stopping criteria
                if n > Max_num_iter+15 || ( abs(C-C_last) < TOL(1) && all(abs(delta_q) < TOL(2)) )
                    optim_completed = true;
                end

                C_last = C;                                      % Save the C value for comparison in the next iteration
                GRAD_last = GRAD;                                % Save the GRAD value for comparison in the next iteration
            end
            
            % If the current initial guess for subset splitting is better than the last result
            % of DIC, save it as the best answer (so far)
            if C_last < best_result(end-1)
                best_result = [q_k; a_new; b_new; C_last; disps];
            end

            % If C is now good, you're done
            if C <= tol_multi*mean_C
                % Optimization of a and b is complete
                a_b_optim_completed = true;
                % The correlation here is now good
                good_corr(jj,ii) = 1;

                best_result = [q_k; a_new; b_new; C; disps];

            else

                fprintf(1,'\nThe subset splitting can''t find a good answer. The best answer was used\n');
                fprintf(1,'Problem had the following results:\n');
                fprintf(1,'u_best = %g\n', best_result(1));
                fprintf(1,'v_best = %g\n', best_result(2));
                fprintf(1,'u_jump_best = %g\n', best_result(3));
                fprintf(1,'v_jump_best = %g\n', best_result(4));
                fprintf(1,'a_best = %g\n', best_result(5));
                fprintf(1,'b_best = %g\n', best_result(6));
                fprintf(1,'C_best = %g\n', best_result(7));
                fprintf(1,'disps = %g\n\n', best_result(8));
                
                fprintf(1,'The problem occurred at (X,Y) = (%g,%g)\n',Xp,Yp);
                fprintf(1,'Or at matrix positions (ii,jj) = (%g,%g)\n\n', ii,jj);
                
             
                % Optimization of a and b is complete
                a_b_optim_completed = true;
                % The correlation here is now good
                good_corr(jj,ii) = 1;

            end % if C <= tol_multi*mean_C
            
        end % if C <= tol_multi*mean_C && a_new - a ...
            
    end % while a_b_optim...
    %_________________________________________________________________________
    t_optim(cnt) = toc - t_tmp;
    iters(cnt) = n;

    % The best results will be returned
    q_k = best_result(1:4);
    a   = best_result(5);
    b   = best_result(6);
    C   = best_result(7);
    disps = best_result(8);
    
    if all(best_result == checker) == true
        fprintf(1, '\nThe "Few Subset" worked best!!!\n');
    end

    
    %_______STORE RESULTS_______________________________________________
    switch disps
        case 1
            % Store the current displacements (the main displacements are u1, v1)
            DEFORMATION_PARAMETERS(jj,ii,1) = q_k(1);       % main displacement u
            DEFORMATION_PARAMETERS(jj,ii,2) = q_k(2);       % main displacement v
            DEFORMATION_PARAMETERS(jj,ii,3) = NaN;          % 1st order def. du1/dx      
            DEFORMATION_PARAMETERS(jj,ii,4) = NaN;          % 1st order def. dv1/dy 
            DEFORMATION_PARAMETERS(jj,ii,5) = NaN;          % 1st order def. du1/dy 
            DEFORMATION_PARAMETERS(jj,ii,6) = NaN;          % 1st order def. dv1/dx 
            DEFORMATION_PARAMETERS(jj,ii,7) = q_k(3);       % secondary displacement u
            DEFORMATION_PARAMETERS(jj,ii,8) = q_k(4);       % secondary displacement v
            DEFORMATION_PARAMETERS(jj,ii,9) = a;        % line parameter: slope a
            DEFORMATION_PARAMETERS(jj,ii,10) = b;       % line parameter: y-intercept b
            DEFORMATION_PARAMETERS(jj,ii,11) = 1-C;         % correlation quality
        case 2
            % Store the current displacements (the main displacements are u2, v2)
            DEFORMATION_PARAMETERS(jj,ii,1) = q_k(1)+q_k(3);   % main displacement u
            DEFORMATION_PARAMETERS(jj,ii,2) = q_k(2)+q_k(4);   % main displacement v
            DEFORMATION_PARAMETERS(jj,ii,3) = NaN;          % 1st order def. du1/dx      
            DEFORMATION_PARAMETERS(jj,ii,4) = NaN;          % 1st order def. dv1/dy 
            DEFORMATION_PARAMETERS(jj,ii,5) = NaN;          % 1st order def. du1/dy 
            DEFORMATION_PARAMETERS(jj,ii,6) = NaN;          % 1st order def. dv1/dx 
            DEFORMATION_PARAMETERS(jj,ii,7) = -q_k(3);      % secondary displacement u
            DEFORMATION_PARAMETERS(jj,ii,8) = -q_k(4);      % secondary displacement v
            DEFORMATION_PARAMETERS(jj,ii,9) = a;        % line parameter: slope a
            DEFORMATION_PARAMETERS(jj,ii,10) = b;       % line parameter: y-intercept b
            DEFORMATION_PARAMETERS(jj,ii,11) = 1-C;         % correlation quality
        otherwise % disps == NaN
            % Store the current displacements (the main displacements are u2, v2)
            DEFORMATION_PARAMETERS(jj,ii,1) = NaN;       % main displacement u
            DEFORMATION_PARAMETERS(jj,ii,2) = NaN;       % main displacement v
            DEFORMATION_PARAMETERS(jj,ii,3) = NaN;       % 1st order def. du1/dx      
            DEFORMATION_PARAMETERS(jj,ii,4) = NaN;       % 1st order def. dv1/dy 
            DEFORMATION_PARAMETERS(jj,ii,5) = NaN;       % 1st order def. du1/dy 
            DEFORMATION_PARAMETERS(jj,ii,6) = NaN;       % 1st order def. dv1/dx 
            DEFORMATION_PARAMETERS(jj,ii,7) = NaN;       % secondary displacement u
            DEFORMATION_PARAMETERS(jj,ii,8) = NaN;       % secondary displacement v
            DEFORMATION_PARAMETERS(jj,ii,9) = a;     % line parameter: slope a
            DEFORMATION_PARAMETERS(jj,ii,10) = b;    % line parameter: y-intercept b
            DEFORMATION_PARAMETERS(jj,ii,11) = NaN;      % correlation quality
            
            % The correlation here is not possible
            good_corr(jj,ii) = NaN;
    end
end % if num_subset_split > 0
        
end % End the looping once all subsets have successfully been split

% Fix the "NaN" displacements by averaging with valid, nearby displacements
[DEFORMATION_PARAMETERS, good_corr_out] = NaN_Value_Averaging(good_corr, DEFORMATION_PARAMETERS);

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


End_Correlation_Processing(DEFORMATION_PARAMETERS, run_time, t_total_bar, t_total_optim, t_total_interp, Ave_iter, q_0  );


return;
end % function







%*********************************************************
%*                   FIRST SPLIT                         *
%*********************************************************

function First_Split_GUI_DIC 

% Call the script command "Initialize_Variables" to set variables we will need
Initialize_Variables;

global last_WS;
global Input_info;
global do_incremental;
global date_time_run;

global def_interp_up;
global def_interp_down;
global def_interp_x_up;
global def_interp_x_down;
global def_interp_y_up;
global def_interp_y_down;

% Preallocate the matrix that holds the deformation parameter results
DEFORMATION_PARAMETERS = zeros(num_subsets_Y, num_subsets_X, 15);

%cd('..');
%HELPER = load('DIC_2008-11-18, 05''57''38_FilterBy1.mat');
%cd('Tools and Files');
    
% Set the initial guess for standard DIC to be the results of initialization
q_k(1:6,1) = q_0(1:6,1);

% i and j will define the subset points to be compared.
i = -floor(subset_size/2) : 1 : floor(subset_size/2);
j = -floor(subset_size/2) : 1 : floor(subset_size/2);

% I_matrix and J_matrix are the grid of data points formed by vectors i and j
[I_matrix,J_matrix] = meshgrid(i,j);

% Store the number of points in the subset
N = subset_size.*subset_size;

% Reshape the I and J from grid matrices into vectors containing the (x,y) coordinates of each point
% This is needed to evaluate the deformed positions (which are no longer forming a square grid)
I = reshape(I_matrix, 1,N);
J = reshape(J_matrix, 1,N);

% These values will determine when subset splitting is required. Make them too big for now
mean_C = 1;

% This tolerance value will define what a "bad" value is when subset splitting is applied.
global f_g_tol;
f_g_tol = 0;

% This variable will store a good initial guess for subset splitting
first_split = true;

% This counter will track how many subsets (points) were well correlated
num_good_corr = 0;

% This counter will track how many subsets (points) need subset splitting
num_subsets_split = 0;

% Track which points are good correlations, which are bad
good_corr = ones(num_subsets_Y, num_subsets_X);

% Define the mulitplier of mean_C to determine when subset splitting is needed
tol_multi = 1.5;


%_______________COMPUTATIONS________________

% Start the timer: Track the time it takes to perform the heaviest computations
tic


%__________FIT SPLINE ONTO DEFORMED SUBSET________________________
% Obtain the size of the reference image
[Y_size, X_size] = size(ref_image);

% Define the deformed image's coordinates
X_defcoord = 1:X_size;
Y_defcoord = 1:Y_size;

% Fit the interpolating spline: g(x,y)
def_interp = spapi( {spline_order,spline_order}, {Y_defcoord, X_defcoord}, def_image(Y_defcoord,X_defcoord) );

% Find the partial derivitives of the spline: dg/dx and dg/dy
%def_interp_x = fnder(def_interp, [0,1]);
%def_interp_y = fnder(def_interp, [1,0]);

% Convert all the splines from B-form into ppform to make it computationally cheaper to evaluate
def_interp = fn2fm(def_interp, 'pp');
def_interp_x = fnder(def_interp, [0,1]);
def_interp_y = fnder(def_interp, [1,0]);
%_________________________________________________________________________ 
t_interp = toc;    % Save the amount of time it took to interpolate


% MAIN CORRELATION LOOP -- CORRELATE THE POINTS REQUESTED
for counter = 1:total_num_subsets

    t_tmp = toc;
    %__________UPDATE THE PROGRESS BAR_________________________________
    % Display correlation's progress in the progress bar
    if mod(counter,floor(total_num_subsets*update_every)) == 0;
        progbar = roundn((counter/total_num_subsets).*100,-2);
        % Compute an estimate to see how much time remains
        t_now = toc;
        t_left = ((100/progbar - 1)*t_now);
        t_left_min = floor(t_left/60);
        t_left_sec = roundn(mod(t_left,60),-2);
        BarText = sprintf('Correlating subsets:  %s out of %s,          Estimated Time: %s min, %s sec\n%4.1f%% Complete', ...
                num2str(counter), num2str(total_num_subsets), num2str(t_left_min), num2str(t_left_sec), progbar);
        %ProgressBar;
        waitbar(progbar/100, h_wait, BarText);
    end
    %_________________________________________________________________________ 
    t_prog(counter) = toc - t_tmp;      % Save the amount of time it took to update the progress bar

  
    
    %t_tmp = toc;
    %__________FIT SPLINE ONTO DEFORMED SUBSET________________________
    % Define the center coordinates of the new subset
    Xp = Xp_first + subset_space*(ii-1);
    Yp = Yp_first + subset_space*(jj-1);

    
    %[C_last] = C_First_Order(q_k);
    %****************
    %* NEW ADDITION *
    %****************
    
    %if C_last > 0.00025
    %cd('..');
    %WWSS = load('Extra.mat');
    %last_WS.TOTAL_DEFORMATIONS = WWSS.TOTAL_DEFORMATIONS;
    %cd('Tools and Files');
    %if any( last_WS.TOTAL_DEFORMATIONS(jj,ii,:) ~= 0 )
        %for new_add = 1:6
            
            %q_k(new_add,1) = last_WS.TOTAL_DEFORMATIONS(jj,ii,new_add);
            
            %q_k(1,1) = HELPER.DISP_U(jj,ii);
            %q_k(2,1) = HELPER.DISP_V(jj,ii);
            %q_k(3,1) = HELPER.DU_DX_filtered(jj,ii);
            %q_k(4,1) = HELPER.DV_DY_filtered(jj,ii);
            %q_k(5,1) = HELPER.DU_DY_filtered(jj,ii);
            %q_k(6,1) = HELPER.DV_DX_filtered(jj,ii);
            
            %{
            if new_add == 2
                
                %if q_k(new_add,1) > 0
                %    range_low = 1;        range_high = 3;
                %elseif q_k(new_add,1) < 0
                %     range_low = 3;        range_high = 1;
                %else
                %     range_low = 2;        range_high = 2;
                %end
                
                % Automatic Initial Guess
                % The initial guess must lie between -range to range in pixels
                
                %u_check = (round(q_k(1)) - 1):(round(q_k(1)) + 1);
                %v_check = (round(q_k(2)) - range_low):(round(q_k(2)) + range_high);
                u_check = (round(q_k(1)) - 5):(round(q_k(1)) + 5);
                v_check = (round(q_k(2)) - 5):(round(q_k(2)) + 5);

                % Define the intensities of the first reference subset
                subref = ref_image(Yp-floor(subset_size/2):Yp+floor(subset_size/2), ...
                                   Xp-floor(subset_size/2):Xp+floor(subset_size/2));
                % Preallocate some matrix space               
                sum_diff_sq = zeros(numel(v_check), numel(u_check));
                % Check every value of u and v and see where the best match occurs
                for iter1 = 1:numel(u_check)
                    for iter2 = 1:numel(v_check)
                        subdef = def_image( (Yp-floor(subset_size/2)+v_check(iter2)):(Yp+floor(subset_size/2)+v_check(iter2)), ...
                                            (Xp-floor(subset_size/2)+u_check(iter1)):(Xp+floor(subset_size/2)+u_check(iter1)) );
                        sum_diff_sq(iter2,iter1) = sum(sum( (subref - subdef).^2));
                    end
                end
                [TMP1,OFFSET1] = min(min(sum_diff_sq,[],2));
                [TMP2,OFFSET2] = min(min(sum_diff_sq,[],1));
                q_k(1,1) = u_check(OFFSET2);
                q_k(2,1) = v_check(OFFSET1);
                clear u_check v_check iter1 iter2 subref subdef sum_diff_sq TMP1 TMP2 OFFSET1 OFFSET2;
                
            elseif new_add > 2
                
                % Remove old values
                q_k(new_add,1) = 0;
                
            end % if new_add == 2% if new_add == 2
        end % for
    %end % if C_last > 0.0005
    %}
    
    
    % The interpolation buffer is by how many more pixels, on each side, is the sector larger than the subset
    % Define the sector's coordinates
    %X_defcoord = -floor(subset_size/2)+Xp+floor(q_k(1))-interp_buffer:floor(subset_size/2)+Xp+floor(q_k(1))+interp_buffer;
    %Y_defcoord = -floor(subset_size/2)+Yp+floor(q_k(2))-interp_buffer:floor(subset_size/2)+Yp+floor(q_k(2))+interp_buffer;

    % Fit the interpolating spline: g(x,y)
    %def_interp = spapi( {spline_order,spline_order}, {Y_defcoord, X_defcoord}, def_image(Y_defcoord,X_defcoord) );

    % Find the partial derivitives of the spline: dg/dx and dg/dy
    %def_interp_x = fnder(def_interp, [0,1]);
    %def_interp_y = fnder(def_interp, [1,0]);
    %_________________________________________________________________________ 
    %t_interp(counter) = toc - t_tmp;    % Save the amount of time it took to interpolate

    t_tmp = toc;
        
    
    %__________OPTIMIZATION ROUTINE: FIND BEST FIT____________________________
    switch optim_method 
        case 'Newton Raphson'
            
            % Always start by assuming no splitting is needed
            split_subset = false;

            % Perform regular 1st order DIC
            % Initialize some values
            n = 0;
            [C_last, GRAD_last, HESS ] = C_First_Order(q_k);   % q_k was the result from last point or the user's guess
            optim_completed = false;

            while optim_completed == false

                % Compute the next guess and update the values
                delta_q = HESS\(-GRAD_last);                     % Find the difference between q_k+1 and q_k
                q_k = q_k + delta_q;                             % q_k+1 = q_k + delta_q
                [C, GRAD, HESS] = C_First_Order(q_k);            % Compute new values

                % Add one to the iteration counter
                n = n + 1;                                       % Keep track of the number of iterations

                % Check to see if the values have converged according to the stopping criteria
                if n > Max_num_iter || ( abs(C-C_last) < TOL(1) && all(abs(delta_q) < TOL(2)) )
                    optim_completed = true;
                end

                C_last = C;                                      % Save the C value for comparison in the next iteration
                GRAD_last = GRAD;                                % Save the GRAD value for comparison in the next iteration
            end
        %_________________________________________________________________________
    end
    t_optim(counter) = toc - t_tmp;
    iters(counter) = n;


    %_______STORE RESULTS AND PREPARE INDICES OF NEXT SUBSET__________________
    % Store the current displacements
    DEFORMATION_PARAMETERS(jj,ii,1) = q_k(1);       % displacement u1
    DEFORMATION_PARAMETERS(jj,ii,2) = q_k(2);       % displacement v1
    DEFORMATION_PARAMETERS(jj,ii,3) = q_k(3);       % 1st order def. du1/dx      
    DEFORMATION_PARAMETERS(jj,ii,4) = q_k(4);       % 1st order def. dv1/dy 
    DEFORMATION_PARAMETERS(jj,ii,5) = q_k(5);       % 1st order def. du1/dy 
    DEFORMATION_PARAMETERS(jj,ii,6) = q_k(6);       % 1st order def. dv1/dx 
    DEFORMATION_PARAMETERS(jj,ii,7) = NaN;          % subset split displacement u2 
    DEFORMATION_PARAMETERS(jj,ii,8) = NaN;          % subset split displacement v2
    DEFORMATION_PARAMETERS(jj,ii,9) = NaN;          % subset split 1st order def. du1/dx
    DEFORMATION_PARAMETERS(jj,ii,10) = NaN;         % subset split 1st order def. dv1/dy
    DEFORMATION_PARAMETERS(jj,ii,11) = NaN;         % subset split 1st order def. du1/dy 
    DEFORMATION_PARAMETERS(jj,ii,12) = NaN;         % subset split 1st order def. dv1/dx 
    DEFORMATION_PARAMETERS(jj,ii,13) = NaN;         % line parameter: slope a
    DEFORMATION_PARAMETERS(jj,ii,14) = NaN;         % line parameter: y-intercept b
    DEFORMATION_PARAMETERS(jj,ii,15) = 1-C;         % correlation quality

    
    % CHECKING IF WE NEED SUBSET SPLITTING
            
    % If the current correlation quality is greater than some tolerance quality, 
    % then the subset should be split since the correlation was bad. 
    if C > tol_multi*mean_C
        split_subset = true;
    end

    if split_subset == false    % If it's a good correlation, update the tolerances
        
        % Get the intensities using the last good answer as initial guess
        f_result = reshape(ref_image(Yp+j, Xp+i), 1,N);
        X = Xp + q_k(1) + I + I.*q_k(3) + J.*q_k(5);
        Y = Yp + q_k(2) + J + J.*q_k(4) + I.*q_k(6);
        g_result = fnval(def_interp, [Y;X]);
        
        % With the two subsets compute (f-g)^2
        f_g_sq_result = (f_result-g_result).^2;
        mean_C    = (mean_C*(num_good_corr) + C)/(num_good_corr+1);                     % Since this is a good correlation, update the average of "C"
        if first_split == true
            f_g_tol   = (f_g_tol*(num_good_corr) + max(f_g_sq_result))/(num_good_corr+1); % Since this is a good correlation, update the tol of (f-g)^2
        end
        
        % Increment the number of good correlations counter
        num_good_corr = num_good_corr + 1;
        
    else            % If it's a bad correlation, record information about the current point in order to perform subset splitting later

        % Increment the number of subsets that need splitting
        num_subsets_split = num_subsets_split + 1;

        % Record the (x,y) positions, as well as the indices (jj,ii), and the counter number
        Xsplit(num_subsets_split,1) = Xp;
        Ysplit(num_subsets_split,1) = Yp;
        JJsplit(num_subsets_split,1) = jj;
        IIsplit(num_subsets_split,1) = ii;
        cnt_split(num_subsets_split,1) = counter;
        
        % This is a bad correlation, take note of it.
        good_corr(jj,ii) = 0;

    end % if split_subset
        

    % Prepare/Track the movement of the subset center
    ii = ii + (-1).^(mod(jj,2)+1);
    if ( mod(counter,num_subsets_X) == 0 )
        ii = ii - (-1).^(mod(jj,2)+1);
        jj = jj + 1;
    end
    %_________________________________________________________________________

end % End the looping once all subsets are evaluated

% Save the current directory
tmp_directory = pwd;
% Save the current results
output_folder_path = End_NoSplit_Correlation(DEFORMATION_PARAMETERS, good_corr, mean_C, f_g_tol);


%------------------------SAVE THE WORKSPACE-------------------------------
[tmp1, tmp2, tmp3] = mkdir(output_folder_path, 'PreSplit_Workspace');
clear tmp1 tmp2 tmp3;

% Record the date and time now for the input and workspace files
date_time = now;
date_time_short = datestr(date_time, ' yyyy-mm-dd, HH''MM''SS');

% Define the original filename and save the workspace to this file
workspace_name = strcat('\PreSplit_Workspace', date_time_short, '.mat');
save(strcat(output_folder_path, '\PreSplit_Workspace', workspace_name));
%------------------------END SAVE THE WORKSPACE-------------------------------

% Return to the original directory
cd(tmp_directory);


% Define the X and Y coordinates of each subset center
mesh_col = Xp_first:subset_space:(num_subsets_X-1)*subset_space+Xp_first;
mesh_row = Yp_first:subset_space:(num_subsets_Y-1)*subset_space+Yp_first;
    
% Call the function that will ask the user for a tolerance
% Or simply assign a tolerance, and the function will prepare the required variables
split_tol = 0;
i_j_region = [];
%split_tol = 1-0.00001;
%f_g_tol = 0.00005;

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


return;
end % function
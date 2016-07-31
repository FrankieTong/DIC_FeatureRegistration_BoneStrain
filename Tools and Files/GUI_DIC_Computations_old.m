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
% Modified on: August 12, 2007


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
function GUI_DIC_Computations( method )

switch method
    case 'Zeroth'
        Zeroth_Order_GUI_DIC
    case 'First'
        First_Order_GUI_DIC
    case 'Zeroth Split'
        Zeroth_Split_GUI_DIC
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
        BarText = sprintf('Correlating subsets:  %s out of %s,               Estimated Time: %s min, %s sec\n%4.1f%% Complete', ...
                num2str(counter), num2str(total_num_subsets), num2str(t_left_min), num2str(t_left_sec), progbar);
        ProgressBar;
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
close(findobj('Name','ProgressBar'));


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
        BarText = sprintf('Correlating subsets:  %s out of %s,               Estimated Time: %s min, %s sec\n%4.1f%% Complete', ...
                num2str(counter), num2str(total_num_subsets), num2str(t_left_min), num2str(t_left_sec), progbar);
        ProgressBar;
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
close(findobj('Name','ProgressBar'));

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

% Preallocate the matrix that holds the deformation parameter results
DEFORMATION_PARAMETERS = zeros(num_subsets_Y, num_subsets_X, 7);

% Set the initial guess to be the "last iteration's" solution.
q_k(1:4,1) = q_0(1:4,1);
q_k(1) = 0;
q_k(2) = -1;
q_k(3) = 0;
q_k(4) = 2;

%_______________COMPUTATIONS________________

% Start the timer: Track the time it takes to perform the heaviest computations
tic


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
        BarText = sprintf('Correlating subsets:  %s out of %s,               Estimated Time: %s min, %s sec\n%4.1f%% Complete', ...
                num2str(counter), num2str(total_num_subsets), num2str(t_left_min), num2str(t_left_sec), progbar);
        ProgressBar;
    end
    %_________________________________________________________________________ 
    t_prog(counter) = toc - t_tmp;      % Save the amount of time it took to update the progress bar


    t_tmp = toc;
    %__________FIT SPLINE ONTO DEFORMED SUBSET________________________
    % Define the center coordinates of the new subset
    Xp = Xp_first + subset_space*(ii-1);
    Yp = Yp_first + subset_space*(jj-1);

    % The interpolation buffer is by how many more pixels, on each side, is the sector larger than the subset
    % Define the minimum and maximum coordinates based on the two centers (using u, v and u_jump and v_jump)
    X_u_coord       = [-floor(subset_size/2)+Xp+floor(q_k(1))-interp_buffer, floor(subset_size/2)+Xp+floor(q_k(1))+interp_buffer];
    X_u_jump_coord  = [-floor(subset_size/2)+Xp+floor(q_k(1) + q_k(3))-interp_buffer, floor(subset_size/2)+Xp+floor(q_k(1) + q_k(3))+interp_buffer];
    Y_v_coord       = [-floor(subset_size/2)+Yp+floor(q_k(2))-interp_buffer, floor(subset_size/2)+Yp+floor(q_k(2))+interp_buffer];
    Y_v_jump_coord  = [-floor(subset_size/2)+Yp+floor(q_k(2) + q_k(4))-interp_buffer, floor(subset_size/2)+Yp+floor(q_k(2) + q_k(4))+interp_buffer];
    
    X_defcoord = min(X_u_coord(1), X_u_jump_coord(1)):max(X_u_coord(2), X_u_jump_coord(2));
    Y_defcoord = min(Y_v_coord(1), Y_v_jump_coord(1)):max(Y_v_coord(2), Y_v_jump_coord(2));

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

        % Initialize some values
        n = 0;
        [C_last, GRAD_last, HESS] = C_Zeroth_Split_Jeff(q_k);   % q_k was the result from last point or the user's guess
        optim_completed = false;

        while optim_completed == false

            % Compute the next guess and update the values
            delta_q = HESS\(-GRAD_last);                      % Find the difference between q_k+1 and q_k
            q_k = q_k + delta_q;                              % q_k+1 = q_k + delta_q
            [C, GRAD, HESS, a, b, Inverse] = C_Zeroth_Split_Jeff(q_k); % Compute new values
            

            % Add one to the iteration counter
            n = n + 1;                                       % Keep track of the number of iterations

            % Check to see if the values have converged according to the stopping criteria
            if n > Max_num_iter+15 || ( abs(C-C_last) < TOL(1) && all(abs(delta_q) < TOL(2)) )
                optim_completed = true;
            end

            C_last = C;                                      % Save the C value for comparison in the next iteration
            GRAD_last = GRAD;                                % Save the GRAD value for comparison in the next iteration
        end
        case 'fmincon'
            q_o = q_k(1:6);                                 % Initial Guess equals the last iteration's result
            q_lb = q_o-1;                                   % Lower bound is 1 pixel less than initial guess
            q_ub = q_o+1;                                   % Upper bound is 1 pixel more than initial guess
            [q_k(1:6), C] = fmincon( @C_Zeroth_Split_Jeff, ...   % Optimize
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
    if Inverse == false
        DEFORMATION_PARAMETERS(jj,ii,1) = q_k(1);
        DEFORMATION_PARAMETERS(jj,ii,2) = q_k(2);
        DEFORMATION_PARAMETERS(jj,ii,3) = q_k(3);
        DEFORMATION_PARAMETERS(jj,ii,4) = q_k(4);
        DEFORMATION_PARAMETERS(jj,ii,5) = a;
        DEFORMATION_PARAMETERS(jj,ii,6) = b;
        DEFORMATION_PARAMETERS(jj,ii,7) = 1-C;
    else
        DEFORMATION_PARAMETERS(jj,ii,1) = q_k(1)+q_k(3);
        DEFORMATION_PARAMETERS(jj,ii,2) = q_k(2)+q_k(4);
        DEFORMATION_PARAMETERS(jj,ii,3) = -q_k(3);
        DEFORMATION_PARAMETERS(jj,ii,4) = -q_k(4);
        DEFORMATION_PARAMETERS(jj,ii,5) = a;
        DEFORMATION_PARAMETERS(jj,ii,6) = b;
        DEFORMATION_PARAMETERS(jj,ii,7) = 1-C;
    end
        

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
close(findobj('Name','ProgressBar'));

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

% Preallocate the matrix that holds the deformation parameter results
DEFORMATION_PARAMETERS = zeros(num_subsets_Y, num_subsets_X, 9);

% Set the initial guess to be the best guess from initialization
q_k(1:6,1) = q_0(1:6,1);

% Define q_good, to hold the last well correlated solution.
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
stand_dev = 10;
mean_C = 10;

% This tolerance value will define what a "bad" value is when subset splitting is applied.
global f_g_tol;
f_g_tol = 0;

% This variable will store a good initial guess for subset splitting
first_point_1 = true;

% This counter will track how many subsets (points) were well correlated
num_good_corr = 0;

% This counter will track how many subsets (points) need subset splitting
num_subsets_split = 0;


%_______________COMPUTATIONS________________

% Start the timer: Track the time it takes to perform the heaviest computations
tic


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
        BarText = sprintf('Correlating subsets:  %s out of %s,               Estimated Time: %s min, %s sec\n%4.1f%% Complete', ...
                num2str(counter), num2str(total_num_subsets), num2str(t_left_min), num2str(t_left_sec), progbar);
        ProgressBar;
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
            
            % Start by getting the values in the subsets using the last
            % good answer as initial guess
            
            % Extract the two subsets completly and compute (f-g)^2 for later use
            f_test = reshape(ref_image(Yp+j, Xp+i), 1,N);
            X = Xp + q_good(1) + I + I.*q_good(3) + J.*q_good(5);
            Y = Yp + q_good(2) + J + J.*q_good(4) + I.*q_good(6);
            g_test = fnval(def_interp, [Y;X]);
            f_g_sq_test = (f_test-g_test).^2;
            
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

            a = NaN;                                            % Splitting line parameter "a" is not needed
            b = NaN;                                            % Splitting line parameter "b" is not needed
            %_________________________________________________________________________
            t_optim(counter) = toc - t_tmp;
            iters(counter) = n;


            %_______STORE RESULTS_____________________________________________________
            % Store the current displacements
            DEFORMATION_PARAMETERS(jj,ii,1) = q_k(1);
            DEFORMATION_PARAMETERS(jj,ii,2) = q_k(2);
            DEFORMATION_PARAMETERS(jj,ii,3) = q_k(3);
            DEFORMATION_PARAMETERS(jj,ii,4) = q_k(4);
            DEFORMATION_PARAMETERS(jj,ii,5) = q_k(5);
            DEFORMATION_PARAMETERS(jj,ii,6) = q_k(6);
            DEFORMATION_PARAMETERS(jj,ii,7) = a;
            DEFORMATION_PARAMETERS(jj,ii,8) = b;
            DEFORMATION_PARAMETERS(jj,ii,9) = 1-C;
            

            % CHECKING IF WE NEED SUBSET SPLITTING
            
            % If the standard deviation of (f-g).^2 is 100 times larger than usual, 
            % and if the "C" value is 10 times larger than the current average "C" value, 
            % subset splitting is required.
            %if std(f_g_sq_test) > 50*stand_dev && C > 5*mean_C
                split_subset = true;
            %end
            
            if split_subset == false        % If it's a good correlation, update the tolerances
                
                mean_C    = (mean_C*(num_good_corr) + C)/(num_good_corr+1);                     % Since this is a good correlation, update the average of "C"
                stand_dev = (stand_dev*(num_good_corr) + std(f_g_sq_test))/(num_good_corr+1);   % Since this is a good correlation, update the std of (f-g)^2
                f_g_tol   = (f_g_tol*(num_good_corr) + 10*max(f_g_sq_test))/(num_good_corr+1);  % Since this is a good correlation, update the tol of (f-g)^2
                q_good    = q_k;                                                                % Since this is a good correlation, update save the q_k vector
                % Add this correlation to the counter
                num_good_corr = num_good_corr + 1;
                    
            else    % Record information about the current point in order to perform subset splitting later
                
                % Update the number of subsets that need splitting
                num_subsets_split = num_subsets_split + 1;
                             
                % Record the (x,y) positions, as well as the indices (jj,ii), and the counter
                Xsplit(num_subsets_split,1) = Xp;
                Ysplit(num_subsets_split,1) = Yp;
                JJsplit(num_subsets_split,1) = jj;
                IIsplit(num_subsets_split,1) = ii;
                cnt_split(num_subsets_split,1) = counter;
                
                % Define a logical matrix where 1 means the value is bad
                Bad_Values = reshape(f_g_sq_test > 0.0075, subset_size, subset_size);% f_g_tol, subset_size, subset_size);
                
                % Using the tolerance, find the indices of the bad values
                indices_of_Bad_values = find(Bad_Values);
                
                % Check if the subset mostly contains good points or bad points, or if the center is a bad point 
                % Knowing this will tell us on which side of the discontinuity our subset center is located
                if length(indices_of_Bad_values) >= N/2 || Bad_Values(round(subset_size/2),round(subset_size/2)) == true
                    Invert(num_subsets_split,1) = true;
                else
                    Invert(num_subsets_split,1) = false;   % more good than bad
                    % For the first point, save the current q_k as initial guess
                    if first_point_1 == true
                        qsplit1 = q_good;
                        first_point_1 = false;
                    end
                end

            end % if split_subset
    end % switch
    

     %_______PREPARE INDICES OF NEXT SUBSET__________________________________ 

    % Prepare/Track the movement of the subset center
    ii = ii + (-1).^(mod(jj,2)+1);
    if ( mod(counter,num_subsets_X) == 0 )
        ii = ii - (-1).^(mod(jj,2)+1);
        jj = jj + 1;
    end
    %_________________________________________________________________________

end % End the looping once all subsets are evaluated


%---------------------PREPARE FOR SUBSET SPLITTING--------------------------------

% The amount of points that need subset splitting is the difference between
% those that were well correlated and the total amount of subsets
% num_subsets_split = total_num_subsets - num_good_corr;

% Before we begin subset splitting, we need to determine a good initial
% guess for the displacements of the first point which has more bad values than good.

% Find the indices of all the points that had more bad than good values
indices = find(Invert);

% Reset the (x,y) and (ii,jj) from the first point
X_1st = Xsplit(indices(1));
Y_1st = Ysplit(indices(1));
ii_1st = IIsplit(indices(1));
jj_1st = JJsplit(indices(1));

% Define the results we obtained from regular DIC as a starting point
qsplit2(1,1) = DEFORMATION_PARAMETERS(jj_1st,ii_1st,1);
qsplit2(2,1) = DEFORMATION_PARAMETERS(jj_1st,ii_1st,2);

%_________________COARSE INITIAL GUESS SEARCH____________________________
% Perform a coarse search for the best "u" and "v" values within a region
range = 10;
u_check = (round(qsplit2(1)) - range):(round(qsplit2(1)) + range);
v_check = (round(qsplit2(2)) - range):(round(qsplit2(2)) + range);

% Define the intensities of the reference subset
subref = ref_image(Y_1st-floor(subset_size/2):Y_1st+floor(subset_size/2), ...
                   X_1st-floor(subset_size/2):X_1st+floor(subset_size/2));

% Preallocate some matrix space               
sum_diff_sq = zeros(numel(u_check), numel(v_check));

% Check every value of u and v and see where the best match occurs
for iter1 = 1:numel(u_check);
    for iter2 = 1:numel(v_check);
        subdef = def_image( (Y_1st-floor(subset_size/2)+v_check(iter2)):(Y_1st+floor(subset_size/2)+v_check(iter2)), ...
                            (X_1st-floor(subset_size/2)+u_check(iter1)):(X_1st+floor(subset_size/2)+u_check(iter1)) );
        sum_diff_sq(iter2,iter1) = sum(sum( (subref - subdef).^2));
    end
end
[TMP1,OFFSET1] = min(min(sum_diff_sq,[],2));
[TMP2,OFFSET2] = min(min(sum_diff_sq,[],1));
qsplit2(1) = u_check(OFFSET2);
qsplit2(2) = v_check(OFFSET1);
clear u_check v_check iter1 iter2 subref subdef sum_diff_sq TMP1 TMP2 OFFSET1 OFFSET2;

%_________________FINE INITIAL GUESS SEARCH____________________________
% Now refine the results with a fine search for the best "u" and "v" guesses
n = 0;
[C_last, GRAD_last, HESS ] = C_Zeroth_Order(qsplit2);
optim_completed = false;

while optim_completed == false

    % Compute the next guess and update the values
    delta_q = HESS\(-GRAD_last);                     % Find the difference between q_k+1 and q_k
    qsplit2 = qsplit2 + delta_q;                     % q_k+1 = q_k + delta_q
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
%_________________________________________________________________________

% Make the gradient terms zero
qsplit2(3:6,1) = 0;


% Restart the timer
tic
%---------------------SUBSET SPLITTING--------------------------------

% MAIN SUBSET SPLITTING LOOP -- CORRELATE THE POINTS THAT NEED SUBSET SPLITTING
for counter = 1:num_subsets_split
    
    % Initialize some useful values
    Xp = Xsplit(counter);
    Yp = Ysplit(counter);
    ii = IIsplit(counter);
    jj = JJsplit(counter);
    invert = Invert(counter);
    cnt = cnt_split(counter);
    
    t_tmp = toc;
    %__________UPDATE THE PROGRESS BAR_________________________________
    % Display correlation's progress in the progress bar
    if mod(counter,floor(num_subsets_split*update_every)) == 0;
        progbar = roundn((counter/num_subsets_split).*100,-2);
        % Compute an estimate to see how much time remains
        t_now = toc;
        t_left = ((100/progbar - 1)*t_now);
        t_left_min = floor(t_left/60);
        t_left_sec = roundn(mod(t_left,60),-2);
        BarText = sprintf('Performing subset splitting:  %s out of %s,          Estimated Time: %s min, %s sec\n%4.1f%% Complete', ...
                num2str(counter), num2str(num_subsets_split), num2str(t_left_min), num2str(t_left_sec), progbar);
        ProgressBar;
    end
    %_________________________________________________________________________ 
    t_prog(cnt) = toc - t_tmp;      % Save the amount of time it took to update the progress bar

    if invert == false;    % This case is when we had more good values than bad
        % Use the results from the last correlaion done on this side as intial guess
        q_k = qsplit1;
    else
        % Use the results from the last correlaion done on the other side as intial guess
        q_k = qsplit2;
    end
        
    t_tmp = toc;
    %__________FIT SPLINE ONTO DEFORMED SUBSET________________________
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
    t_interp(cnt) = toc - t_tmp;    % Save the amount of time it took to interpolate


    t_tmp = toc;
    %__________OPTIMIZATION ROUTINE: FIND BEST FIT____________________________
    % Initialize some values
    n = 0;
    
    % Find a starting value for "a" and "b" using the matrix of bad values
    [a, b] = Optimize_a_b(q_k);
    
    % Refine this guess using a loop that checks nearby values of "a" and "b"
    [a, b] = Optimize_a_b(q_k, [a, b]);
    [C_last, GRAD_last, HESS] = C_First_Split_Jeff(q_k, a, b);   % q_k was the result from last point or the user's guess
    optim_completed = false;

    while optim_completed == false

        % Compute the next guess and update the values
        delta_q = HESS\(-GRAD_last);                            % Find the difference between q_k+1 and q_k
        q_k = q_k + delta_q;                                    % q_k+1 = q_k + delta_q
        [a,b] = Optimize_a_b(q_k, [a,b]);                       % Using only bad values, find the line pararmeters
        [C, GRAD, HESS] = C_First_Split_Jeff(q_k, a, b);        % Compute new values


        % Add one to the iteration counter
        n = n + 1;                                       % Keep track of the number of iterations

        % Check to see if the values have converged according to the stopping criteria
        if n > Max_num_iter+15 || ( abs(C-C_last) < TOL(1) && all(abs(delta_q) < TOL(2)) )
            optim_completed = true;
        end

        C_last = C;                                      % Save the C value for comparison in the next iteration
        GRAD_last = GRAD;                                % Save the GRAD value for comparison in the next iteration
    end
    %_________________________________________________________________________
    t_optim(cnt) = toc - t_tmp;
    iters(cnt) = n;


    %_______STORE RESULTS_____________________________________________________
    % Store the current displacements
    DEFORMATION_PARAMETERS(jj,ii,1) = q_k(1);
    DEFORMATION_PARAMETERS(jj,ii,2) = q_k(2);
    DEFORMATION_PARAMETERS(jj,ii,3) = q_k(3);
    DEFORMATION_PARAMETERS(jj,ii,4) = q_k(4);
    DEFORMATION_PARAMETERS(jj,ii,5) = q_k(5);
    DEFORMATION_PARAMETERS(jj,ii,6) = q_k(6);
    DEFORMATION_PARAMETERS(jj,ii,7) = a;
    DEFORMATION_PARAMETERS(jj,ii,8) = b;
    DEFORMATION_PARAMETERS(jj,ii,9) = 1-C;
        
    if invert == false;    % This case is when we had more good values than bad
        % Use the results from the last correlaion done on this side as intial guess
        qsplit1 = q_k;
    else
        % Use the results from the last correlaion done on the other side as intial guess
        qsplit2 = q_k;
    end
        
end % End the looping once all subsets have successfully been split

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
close(findobj('Name','ProgressBar'));

%_______________END COMPUTATIONS________________


End_Correlation_Processing(DEFORMATION_PARAMETERS, run_time, t_total_bar, t_total_optim, t_total_interp, Ave_iter, q_0  );


return;
end % function
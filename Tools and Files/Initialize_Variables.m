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


% Digital Image Correlation: Initialization of Variables
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  July 18, 2007
% Modified on: July 18, 2007


---------------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: INITIALIZATION OF VARIABLES    |
---------------------------------------------------------------

This M-File is a script (a set of Matlab commands), which is common
to all of the DIC functions in the file GUI_DIC_Computations
To avoid having to write these several times, they have been placed here
%}


%_____________Initialize the Variables______________________

% Read in the reference and deformed images
global ref_image;
global def_image;

% Size of the subset (MUST BE ODD)
global subset_size;

% Spacing between points to correlate
global subset_space;

% Initial Guess (q is the vector of deformation variables)
global qo;
q_0 = qo;

% Xp and Yp represent the subset center coordinates during each
% optimization. Initialize them with the first values.
global Xp_first;
global Yp_first;
global Xp_last;
global Yp_last;
global Xp;
global Yp;
Xp = Xp_first;
Yp = Yp_first;

% def_interp is the struct containing the interpolation surface. def_interp_x
% is the first derivitive with respect to x, and likewise for def_interp_y.
global def_interp;
global def_interp_x;
global def_interp_y;

% Define the order of the interpolating spline
global interp_order;
switch interp_order
    case 'Linear (1st order)'
        spline_order = 2;
    case 'Cubic (3rd order)'
        spline_order = 4;
    case 'Quintic (5th order)'
        spline_order = 6;
    case '(7th Order)'
        spline_order = 8;
    case '(9th Order)'
        spline_order = 10;
    case '(11th Order)'
        spline_order = 12;
end

% Find the buffer selected for the interpolation sector
global interp_buffer;

% Optimization Options
global TOL;
global optim_method;
global Max_num_iter;

% The following is for fmincon, the Matlab function... this section will eventually be removed.
if isequal(optim_method, 'fmincon')
    % The following represents options for Matlab's optimization (fmincon)
    options = optimset( 'LargeScale',    'off',...
                        'GradObj', 'off',...
                        'Hessian','off',...
                        'DiffMaxChange', 1e-1,...
                        'DiffMinChange', 1e-10,...
                        'Display', 'off',...
                        'TolFun', 1e-8,...
                        'TolX', 1e-8,...
                        'TolCon', 1e-8);
end


%___________________________________________________________




%_____________Define some Useful Quantities______________________

% Define the number of subsets along "X" and "Y".
num_subsets_X = floor( (Xp_last-Xp_first)/subset_space ) + 1;
num_subsets_Y = floor( (Yp_last-Yp_first)/subset_space ) + 1;

% Define the total number of subsets to correlate
total_num_subsets = num_subsets_X.*num_subsets_Y;



% ii counts the columns (along the X direction), jj the rows (along the Y direction)
ii = 1;
jj = 1;

%_____________________________________________________________





%_____________Automatic Initial Guess______________________

% Automatic Initial Guess
% The initial guess must lie between -range to range in pixels
range = 15;%35;
u_check = (round(q_0(1)) - range):(round(q_0(1)) + range);
v_check = (round(q_0(2)) - range):(round(q_0(2)) + range);

% Define the intensities of the first reference subset
subref = ref_image(Yp_first-floor(subset_size/2):Yp_first+floor(subset_size/2), ...
                   Xp_first-floor(subset_size/2):Xp_first+floor(subset_size/2));
% Preallocate some matrix space               
sum_diff_sq = zeros(numel(u_check), numel(v_check));
% Check every value of u and v and see where the best match occurs
for iter1 = 1:numel(u_check)
    for iter2 = 1:numel(v_check)
        subdef = def_image( (Yp_first-floor(subset_size/2)+v_check(iter2)):(Yp_first+floor(subset_size/2)+v_check(iter2)), ...
                            (Xp_first-floor(subset_size/2)+u_check(iter1)):(Xp_first+floor(subset_size/2)+u_check(iter1)) );
        sum_diff_sq(iter2,iter1) = sum(sum( (subref - subdef).^2));
    end
end
[TMP1,OFFSET1] = min(min(sum_diff_sq,[],2));
[TMP2,OFFSET2] = min(min(sum_diff_sq,[],1));
q_0(1) = u_check(OFFSET2);
q_0(2) = v_check(OFFSET1);
clear u_check v_check iter1 iter2 subref subdef sum_diff_sq TMP1 TMP2 OFFSET1 OFFSET2;





%_____________________________________________________________




%_______________Initialize the ProgressBar and Timers________________

% Define values for the progress bar that will track the correlations
%global progbar;
%global BarText;
progbar = 0;
update_every = 0.001;        % the ProgressBar will update every 1% complete
BarText = sprintf('Correlating subset:  %s out of %s,          Estimated Time: %s min, %s sec\n%4.2f%% Complete', ...
                  num2str(0), num2str(total_num_subsets), '--', '--', progbar);
%ProgressBar;
if exist('h_wait', 'var') == true
    if ishandle(h_wait) == true
        close(h_wait);
    end
end
h_wait = waitbar(0, BarText, 'Name', 'Progress Bar: Performing Digital Image Correlation', 'Units', 'normalized');
set(h_wait, 'Position', [0.3 0.5 0.45 0.11] );
h_child = get(h_wait, 'Children');
h_child_title = get(h_child, 'Title');
set(h_child, 'Units', 'normalized', 'Position', [0.1, 0.25, 0.8, 0.15]);
set(h_child_title, 'FontName', 'Arial', 'FontWeight', 'Bold');
              
% Preallocate a variable to hold optimization times
t_optim = zeros(1, total_num_subsets);

% Preallocate a variable to hold number of iterations. n counts the iterations
iters = zeros(1, total_num_subsets);
n = 0;

% Preallocate a variable to hold interpolation times
t_interp = zeros(1, total_num_subsets);

% Preallocate a variable to hold progressBar times (to make sure it doesn't swamp the computations
% (This term might be removed in the future)
t_prog = zeros(1, total_num_subsets);


%_____________________________________________________________

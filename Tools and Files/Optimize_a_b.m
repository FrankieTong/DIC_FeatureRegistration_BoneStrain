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


% Digital Image Correlation: Optimizing "a" and "b"
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  August 12, 2007
% Modified on: August 27, 2007


-----------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: OPTIMIZING "a" AND "b"     |
-----------------------------------------------------------

The following function will determine a best match for two line
parameters "a" and "b". These parameteres will define a line along
which the subset will be cut in order to improve the correlation.
%}

function [a, b, top, bottom, main] = Optimize_a_b(q, Bad_Values, a_b)

% q is the vector of deformation variables, rename the ones we need for clarity
u1           = q(1);             % Displacement in "x" for deformation 1
v1           = q(2);             % Displacement in "y" for deformation 1 
u2           = q(3);             % Displacement in "x" for deformation 2
v2           = q(4);             % Displacement in "y" for deformation 2

%-SPLITTING LINE ---------------------------------------------------
% The first step in subset splitting is to define a line along
% which the correlation breaks down. This will seperate the badly
% correlated points from the good ones. To do this, find which points
% are above the mean value of the variance of f and g. Then, locate the
% points along the interface of the ones and zeros to help define a line

global subset_size;
%global ref_image;
%global def_interp_1;
%global def_interp_2;
%global Xp;
%global Yp;
%global f_g_tol;

% i and j will define the subset points to be compared.
i = -floor(subset_size/2) : 1 : floor(subset_size/2);
j = -floor(subset_size/2) : 1 : floor(subset_size/2);

% I_matrix and J_matrix are the grid of data points formed by vectors i and j
[I_matrix,J_matrix] = meshgrid(i,j);

% Store the number of points in the subset, and the midpoint of the subset
%N = subset_size.*subset_size;
mid = round(subset_size/2);

% Reshape I and J from grid matrices into vectors containing the (x,y) coordinates of each point
%I = reshape(I_matrix, 1,N);
%J = reshape(J_matrix, 1,N);

% Since the deformed subset is not a rectangular grid this forces us to write out 
% every x coordinate in vector X and every corresponding y in vector Y
%X = Xp + u + I;
%Y = Yp + v + J;

if nargin == 2
    
    % Find out if there are more ones on the top or bottom half of the subset
    ind_top = find(Bad_Values(1:mid-1,:));
    ind_bot = find(Bad_Values(mid+1:end,:));
    if length(ind_bot) >= length(ind_top)
        ones_Ylocation = 'start';
    else
        ones_Ylocation = 'end';
    end
    
    % Find out if there are more ones on the left or right half of the subset
    ind_left = find(Bad_Values(:,end));
    ind_right = find(Bad_Values(end,:));
    if length(ind_right) >= length(ind_left)
        ones_Xlocation = 'start';
    else
        ones_Xlocation = 'end';
    end
  
    % Define some iterators
    iter_row = 1;
    iter_col = 1;
    
    % For each row and column of Bad_Values, store the coordinates of the
    % first "1" that you come across. "_row" values are the "1's" found while
    % inspecting the rows, and vice-versa for "_col" 
    for kk = 1:subset_size
        row = find(Bad_Values(:,kk));
        col = find(Bad_Values(kk,:));
        if isempty(row) == false
            X_row(iter_row) = kk - round(subset_size/2);
            if isequal(ones_Ylocation, 'end') == true
                Y_row(iter_row) = row(end) - round(subset_size/2);
            else
                Y_row(iter_row) = row(1) - round(subset_size/2);
            end
            iter_row = iter_row + 1;
        end
        if isempty(col) == false
            if isequal(ones_Xlocation, 'end') == true
                X_col(iter_col) = col(end) - round(subset_size/2);
            else
                X_col(iter_col) = col(1) - round(subset_size/2);
            end
            Y_col(iter_col) = kk - round(subset_size/2);
            iter_col = iter_col + 1;
        end

    end
        

    % The inspection that yielded the most point coordinates will be used
    % to find the line equation --> ("_row" finds flat, horizontal lines, "_col"
    % finds steep, vertical lines
    if iter_row >= iter_col
        
        if exist('X_row') == false
            % The Bad Values matrix is full of zeros
            a = 0;
            b = subset_size + 5;
            [f, g, top, bottom, main] = Subset_Splitting( u1, v1, u2, v2, a, b, i, j, I_matrix, J_matrix);
            return;
        end
                
                
        % The line is mostly horizontal
        X_val = X_row';
        Y_val = Y_row';

        % Filter out any bad values
        finished = false;
        while finished == false
            [X_tmp, Y_tmp] = filter_outliers('Y', X_val, Y_val);
            if length(Y_tmp) == length(Y_val)
                Y_ones = Y_tmp;
                X_ones = X_tmp;
                finished = true;
            else
                Y_val = Y_tmp;
                X_val = X_tmp;
            end
        end

    else
        % The line is mostly vertical
        X_val = X_col';
        Y_val = Y_col';

        % Filter out any bad values
        finished = false;
        while finished == false
            [X_tmp, Y_tmp] = filter_outliers('X', X_val, Y_val);
            if length(Y_tmp) == length(Y_val)
                Y_ones = Y_tmp;
                X_ones = X_tmp;
                finished = true;
            else
                Y_val = Y_tmp;
                X_val = X_tmp;
            end
        end


    end


    % Define the line equation by performing a least-squares fit.
    % However, if the X values are along the same line, define a custom
    % "vertical" line with a large slope.
    if min(X_ones) ~= max(X_ones)
        A = [X_ones, ones(size(X_ones))];
        a_b = A\Y_ones;
        a = a_b(1);
        b = a_b(2);
    else
        a = -(subset_size + 5);
        b = -min(X_ones).*a;
    end
%--------------------------------------------------------------------------

    [f, g, top, bottom, main] = Subset_Splitting( u1, v1, u2, v2, a, b, i, j, I_matrix, J_matrix);

end


if nargin > 2
    % Relabel the inputs
    a = a_b(1);
    b = a_b(2);
    
    % Perform autoguess to find the best match for the line parameters
    % Start by optimizing "a" because "b" is largely affected by "a"
    range = 0.5;
    division = 0.45/floor(subset_size/2);
    a_check = (a - range):division:(a + range);

    % Preallocate some matrix space               
    sum_diff_sq_a = zeros(numel(a_check), 1);
    
    % Check every value of "a" and see where the best match occurs
    for iter1 = 1:numel(a_check);
        [f, g] = Subset_Splitting( u1, v1, u2, v2, a_check(iter1), b, i, j, I_matrix, J_matrix);
        sum_diff_sq_a(iter1, 1) = sum(sum( (f - g).^2));
    end
    [TMP1,OFFSETa] = min(sum_diff_sq_a); 

    a = a_check(OFFSETa);
    %figure; plot(a_check,sum_diff_sq_a);

    
     % Now optimize "b", using the "a" we just found
    range = 1;
    division = 0.05;
    b_check = (b - range):division:(b + range);

    % Preallocate some matrix space               
    sum_diff_sq_b = zeros(numel(b_check), 1);
    
    % Check every value of "b" and see where the best match occurs
    for iter2 = 1:numel(b_check);
        [f, g] = Subset_Splitting( u1, v1, u2, v2, a, b_check(iter2), i, j, I_matrix, J_matrix);
        sum_diff_sq_b(iter2, 1) = sum(sum( (f - g).^2));
    end
    [TMP1,OFFSETb] = min(sum_diff_sq_b); 

    b = b_check(OFFSETb);
    %figure; plot(b_check,sum_diff_sq_b);

    [f, g, top, bottom, main] = Subset_Splitting( u1, v1, u2, v2, a, b, i, j, I_matrix, J_matrix);
end % if nargin

end % function



function [X_tmp, Y_tmp] = filter_outliers(Y_or_X, X_val, Y_val)

if isequal(Y_or_X, 'Y') == true
    STD = std(Y_val);
    MEAN = mean(Y_val);
    iter_good = 1;
    for iter = 1:length(Y_val)
        if Y_val(iter) >= (MEAN - 2*STD) && Y_val(iter) <= (MEAN + 2*STD)
            Y_tmp(iter_good,1) = Y_val(iter);
            X_tmp(iter_good,1) = X_val(iter);
            iter_good = iter_good + 1;
        end
    end
elseif isequal(Y_or_X, 'X') == true
    STD = std(X_val);
    MEAN = mean(X_val);
    iter_good = 1;
    for iter = 1:length(X_val)
        if X_val(iter) >= (MEAN - 2*STD) && X_val(iter) <= (MEAN + 2*STD)
            Y_tmp(iter_good,1) = Y_val(iter);
            X_tmp(iter_good,1) = X_val(iter);
            iter_good = iter_good + 1;
        end
    end
end

end % function






% Subset splitting occurs here
function [f, g, top, bottom, main] = Subset_Splitting( u1, v1, u2, v2, a, b, i, j, I_matrix, J_matrix)
    
    global subset_size;
    global ref_image;
    global def_interp_1;
    global def_interp_2;
    global Xp;
    global Yp;
    
    top = zeros(subset_size,subset_size);
    bottom = zeros(subset_size,subset_size);
    % Loop through all the points and see which are above the line, and which are below
    for ii = 1:subset_size
        for jj = 1:subset_size
            if (J_matrix(ii,jj)+0.5) <= a*(I_matrix(ii,jj) - 0.5)+b && (J_matrix(ii,jj)+0.5) <= a*(I_matrix(ii,jj) + 0.5)+b
                top(ii,jj) = 1;
                bottom(ii,jj) = 0;
            elseif (J_matrix(ii,jj)-0.5) > a*(I_matrix(ii,jj) - 0.5)+b && (J_matrix(ii,jj)-0.5) > a*(I_matrix(ii,jj) + 0.5)+b
                top(ii,jj) = 0;
                bottom(ii,jj) = 1;
            else
                top(ii,jj) = 0;
                bottom(ii,jj) = 0;
            end
        end
    end
    
    % Make a matrix that defines the pixels that are off the line
    Valid = top + bottom;
    
    %figure; imshow(Valid); title(sprintf('a = %g, b = %g', a,b));
    %saveas(gcf, sprintf('Subset at Xp = %g, Yp = %g.jpg',Xp,Yp));
    %close(findobj('Name', ''));
    
    ind_top = find(top);
    ind_bottom = find(bottom);
    if numel(ind_top) >= numel(ind_bottom)
        main = 1;
    else
        main = 2;
    end
    
    % Extract the reference intensities and zero-out the invalid pixels along the line
    f = ref_image(Yp+j, Xp+i).*Valid;

    % Extract the deformed intensities for both deformations
    g_top    = fnval(def_interp_1, {Yp+j+v1, Xp+i+u1}).*top;
    g_bottom = fnval(def_interp_2, {Yp+j+v2, Xp+i+u2}).*bottom;
    
    % Recombine the two parts to form the total deformation matrix
    g = g_top + g_bottom;
    
end % function




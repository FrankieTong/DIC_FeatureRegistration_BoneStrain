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


% Digital Image Correlation: Cross-Correlation Coefficient, 
%                            Objective Function, 
%                            Zeroth Split
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  July 25, 2007
% Modified on: August 9, 2007


------------------------------------------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: CROSS-CORRELATION COEFF. ZEROTH ORDER SUBSET SPLITTING    |
------------------------------------------------------------------------------------------

The following function is the least squares coefficient 
(objective function) that will be used in the DIC optimization stage.

This particular function is zeroth order because it uses displacements
"u" and "v" only. However, it also incorporates an extra parameter to represent a discontinuity
%}
function [C, GRAD, HESS, a, b, Inverse] = C_Zeroth_Split_Jeff( q )
% q is the vector of deformation variables, rename them for clarity
    u           = q(1);             % Displacement in "x" of center pixel
    v           = q(2);             % Displacement in "y" of center pixel
    u_jump      = q(3);             % Rigid displacement between the subsets in "x" direction
    v_jump      = q(4);             % Rigid displacement between the subsets in "y" direction
    %a           = q(5);             % Variable defining the discontinuity (split) line
    %b           = q(6);             % Variable defining the discontinuity (split) line
    
    
%-SPLITTING LINE ---------------------------------------------------
    % The first step in subset splitting is to define a line along
    % which the correlation breaks down. This will seperate the badly
    % correlated points from the good ones. To do this, find which points
    % are above the mean value of the variance of f and g. Then, locate the
    % points along the interface of the ones and zeros to help define a line
    
    global subset_size;
    global ref_image;
    global def_interp;
    global Xp;
    global Yp;

    % i and j will define the subset points to be compared.
    i = -floor(subset_size/2) : 1 : floor(subset_size/2);
    j = -floor(subset_size/2) : 1 : floor(subset_size/2);
    
	% Extract the two subsets completly and compute (f-g)^2
    f_test = ref_image(Yp+j, Xp+i);
    g_test = fnval( def_interp, {Yp+v+j, Xp+u+i});
    f_g_sq_test = (f_test-g_test).^2;
    
    figure; imshow(f_test);
    figure; imshow(g_test);
    
    
    % Find the mean of this matrix and label anything above the mean as a bad value
       %match = f_g_sq_test(1,1);
    Bad_Values = f_g_sq_test > 0.0075;
       
    % Define some iterators
    iter_row = 1;
    iter_col = 1;
    
    % For each row and column of Bad_Values, store the coordinates of the
    % first "1" that you come across. "_row" values are the "1's" found while
    % inspecting the rows of each column, and vice-versa for "_col" 
    for kk = 1:subset_size
        row = find(Bad_Values(:,kk));
        col = find(Bad_Values(kk,:));
        if isempty(row) == false
            X_row(iter_row) = kk - round(subset_size/2);
            Y_row(iter_row) = row(1) - round(subset_size/2);
            iter_row = iter_row + 1;
        end
        if isempty(col) == false
            X_col(iter_col) = col(1) - round(subset_size/2);
            Y_col(iter_col) = kk - round(subset_size/2);
            iter_col = iter_col + 1;
        end
        
    end
    
    % The inspection that yielded the most points coordinates will be used
    % to find the line equation --> ("_row" finds flat, horizontal lines, "_col"
    % finds steep, vertical lines
    if iter_row >= iter_col
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

%-SUBSET SPLITTING---------------------------------------------------
    % Now that we know where to split the subset we need to compute how it should deform,
    % and what the values at these positions. Start by checking the initial
    % guess, then split the subset and pass it to the rest of the Newton Raphson Method
    % to optimize the parameters.

    % Compute the relevant terms using the Subset_Splitting function
    [f, g, dg_dX, dg_dY, secondary, Inverse]  = Subset_Splitting( u, v, a, b, u_jump, v_jump );
    
%--------------------------------------------------------------------------
    

%-OBJECTIVE FUNCTION "C"---------------------------------------------------
    % f represents intensities of the discrete points in the ref subset
    % g represents the corresponding intensities from the continuous splined def sector
    
    % The following represents the double sums of C, 
    %(The summation limits are from -floor(subset_size/2) to floor(subset_size/2)
    SS_f_g = sum(sum( ((f-g).^2) ));
    SS_f_sq = sum(sum( (f.^2) ));
    
    
    C = SS_f_g./SS_f_sq;
%--------------------------------------------------------------------------
 
if nargout > 1
%-GRADIENT OF "C"----------------------------------------------------------

    % Determine the derivitives of the coordinate terms (i.e. suppose that
    % the coordinates of "f" are f(X,Y) = f(Xp+i-u+..., Yp+j-v+...)
    dX_du = 1;
    dX_dv = 0;
    dX_du_jump = ones(subset_size, subset_size).*secondary;
    dX_dv_jump = 0;
    
    dY_du = 0;
    dY_dv = 1;
    dY_du_jump = 0;
    dY_dv_jump = ones(subset_size, subset_size).*secondary;

    
    % Express the chain rule for partial derivites on "g"
    dg_du   = dg_dX.*dX_du + dg_dY.*dY_du;
    dg_dv   = dg_dX.*dX_dv + dg_dY.*dY_dv;
    dg_du_jump = dg_dX.*dX_du_jump + dg_dY.*dY_du_jump;
    dg_dv_jump = dg_dX.*dX_dv_jump + dg_dY.*dY_dv_jump;
    
    % Write out each value in the gradient vector
    dC_du = sum(sum( (g-f).*(dg_du) ));
    dC_dv = sum(sum( (g-f).*(dg_dv) ));
    dC_du_jump = sum(sum( (g-f).*(dg_du_jump) ));
    dC_dv_jump = sum(sum( (g-f).*(dg_dv_jump) ));
    
    GRAD = (2/SS_f_sq).*[ dC_du, dC_dv, dC_du_jump, dC_dv_jump ]';
        
%--------------------------------------------------------------------------

if nargout > 2
%-HESSIAN OF "C"-----------------------------------------------------------   

    % Write out each value in the Hessian Matrix (remember, it's symmetric,
    % so only half of the entries are need), using Knauss' approximation
    d2C_du2 = sum(sum( (dg_du).*(dg_du) ));               
    d2C_dv2 = sum(sum( (dg_dv).*(dg_dv) ));
    d2C_du_jump2 = sum(sum( (dg_du_jump).*(dg_du_jump) ));
    d2C_dv_jump2 = sum(sum( (dg_dv_jump).*(dg_dv_jump) ));
    
    d2C_dudv = sum(sum( (dg_du).*(dg_dv) ));
    d2C_dudu_jump = sum(sum( (dg_du).*(dg_du_jump) ));
    d2C_dudv_jump = sum(sum( (dg_du).*(dg_dv_jump) ));
    
    d2C_dvdu_jump = sum(sum( (dg_dv).*(dg_du_jump) ));
    d2C_dvdv_jump = sum(sum( (dg_dv).*(dg_dv_jump) ));
    
    d2C_du_jumpdv_jump = sum(sum( (dg_du_jump).*(dg_dv_jump) ));
             
             
    HESS = (2/SS_f_sq).* [  d2C_du2,       d2C_dudv,      d2C_dudu_jump,      d2C_dudv_jump; ...
                            d2C_dudv,      d2C_dv2,       d2C_dvdu_jump,      d2C_dvdv_jump; ...
                            d2C_dudu_jump, d2C_dvdu_jump, d2C_du_jump2,       d2C_du_jumpdv_jump; ...
                            d2C_dudv_jump, d2C_dvdv_jump, d2C_du_jumpdv_jump, d2C_dv_jump2];
%--------------------------------------------------------------------------

end % if nargout > 2
end % if nargout > 1

end % function



% Subset splitting occurs here
function [f, g, dg_dX, dg_dY, secondary, Inverse] = Subset_Splitting( u, v, a, b, u_jump, v_jump )
    
    global subset_size;
    global ref_image;
    global def_interp;
    global def_interp_x;
    global def_interp_y;
    global Xp;
    global Yp;
    
    % i and j will define the subset points to be compared.
    i = -floor(subset_size/2) : 1 : floor(subset_size/2);
    j = -floor(subset_size/2) : 1 : floor(subset_size/2);
    
    % I_matrix and J_matrix are the grid of data points formed by vectors i and j
    [I_matrix, J_matrix] = meshgrid(i,j);
    
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
    
    figure; imshow(Valid); title(sprintf('a = %g, b = %g', a,b));
    %saveas(gcf, sprintf('Subset at Xp = %g, Yp = %g.jpg',Xp,Yp));
    %close(findobj('Name', ''));
    
    if top(round(subset_size/2), round(subset_size/2)) == 0
        Inverse = true;
    else
        Inverse = false;
    end
    
    % Extract the reference intensities and zero-out the pixels on the line with "Valid"
    f = ref_image(Yp+j, Xp+i).*Valid;
    
    % Extract two matrices for the deformed subsets
    g_main       = fnval( def_interp, {Yp+v+j, Xp+u+i});
    g_second     = fnval( def_interp, {Yp+v+j+v_jump, Xp+u+i+u_jump});
    
    % Find who has the most ones (top or bottom) --> who gets deformed by u and v only
    %ind_top = find(top);
    %ind_bottom = find(bottom);
    %if numel(ind_top) >= numel(ind_bottom)
        g_main = g_main.*top;
        g_second = g_second.*bottom;
    %else
    %    g_main = g_main.*bottom;
    %    g_second = g_second.*top;
    %end
    
    % Combine the two matrices into one matrix
    g = g_main + g_second;
    
    if nargout > 2
        % Evaluate the derivitives at the points of interest in the main and secondary positions
        dg_dX_main      = fnval(def_interp_x, {Yp+v+j, Xp+u+i});
        dg_dX_second    = fnval(def_interp_x, {Yp+v+j+v_jump, Xp+u+i+u_jump});
        
        dg_dY_main      = fnval(def_interp_y, {Yp+v+j, Xp+u+i});
        dg_dY_second    = fnval(def_interp_y, {Yp+v+j+v_jump, Xp+u+i+u_jump});
        
        % Determine who is the main and who is the secondary section
        %if numel(ind_top) >= numel(ind_bottom)
            dg_dX_main = dg_dX_main.*top;
            dg_dX_second = dg_dX_second.*bottom;
            dg_dY_main = dg_dY_main.*top;
            dg_dY_second = dg_dY_second.*bottom;
            secondary = bottom;
        %else
        %    dg_dX_main = dg_dX_main.*bottom;
        %    dg_dX_second = dg_dX_second.*top;
        %    dg_dY_main = dg_dY_main.*bottom;
        %    dg_dY_second = dg_dY_second.*top;
        %    secondary = top;
        %end
        
        % Combine the main and secondary matrices into one matrix
        dg_dX = dg_dX_main + dg_dX_second;
        dg_dY = dg_dY_main + dg_dY_second;   
    end
    
end % function

%{
% Subset splitting occurs here (no pixels eliminated)
function [f, g, dg_dX, dg_dY, secondary] = Subset_Splitting( u, v, a, b, u_jump, v_jump )
    
    global subset_size;
    global ref_image;
    global def_interp;
    global def_interp_x;
    global def_interp_y;
    global Xp;
    global Yp;
    
    % i and j will define the subset points to be compared.
    i = -floor(subset_size/2) : 1 : floor(subset_size/2);
    j = -floor(subset_size/2) : 1 : floor(subset_size/2);
    
    % Extract the reference intensities
    f = ref_image(Yp+j, Xp+i);
    
    % I_matrix and J_matrix are the grid of data points formed by vectors i and j
    [I_matrix, J_matrix] = meshgrid(i,j);
    
    % Loop through all the points and see which are above the line, and which are below
    top = J_matrix < (a*I_matrix + b);
    bottom = J_matrix > (a*I_matrix + b);
    
    % Extract two matrices for the deformed subsets
    g_main       = fnval( def_interp, {Yp+v+j, Xp+u+i});
    g_second     = fnval( def_interp, {Yp+v+j+v_jump, Xp+u+i+u_jump});
    
    % Find who has the most ones (top or bottom) --> who gets deformed by u and v only
    ind_top = find(top);
    ind_bottom = find(bottom);
    if numel(ind_top) >= numel(ind_bottom)
        g_main = g_main.*top;
        g_second = g_second.*bottom;
    else
        g_main = g_main.*bottom;
        g_second = g_second.*top;
    end
    
    % Combine the two matrices into one matrix
    g = g_main + g_second;
    
    if nargout > 2
        % Evaluate the derivitives at the points of interest in the main and secondary positions
        dg_dX_main      = fnval(def_interp_x, {Yp+v+j, Xp+u+i});
        dg_dX_second    = fnval(def_interp_x, {Yp+v+j+v_jump, Xp+u+i+u_jump});
        
        dg_dY_main      = fnval(def_interp_y, {Yp+v+j, Xp+u+i});
        dg_dY_second    = fnval(def_interp_y, {Yp+v+j+v_jump, Xp+u+i+u_jump});
        
        % Determine who is the main and who is the secondary section
        if numel(ind_top) >= numel(ind_bottom)
            dg_dX_main = dg_dX_main.*top;
            dg_dX_second = dg_dX_second.*bottom;
            dg_dY_main = dg_dY_main.*top;
            dg_dY_second = dg_dY_second.*bottom;
            secondary = bottom;
        else
            dg_dX_main = dg_dX_main.*bottom;
            dg_dX_second = dg_dX_second.*top;
            dg_dY_main = dg_dY_main.*bottom;
            dg_dY_second = dg_dY_second.*top;
            secondary = top;
        end
        
        % Combine the main and secondary matrices into one matrix
        dg_dX = dg_dX_main + dg_dX_second;
        dg_dY = dg_dY_main + dg_dY_second;   
    end
    
end % function
%}
    
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
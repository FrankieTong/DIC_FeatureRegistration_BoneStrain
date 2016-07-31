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
% Modified on: August 3, 2007


------------------------------------------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: CROSS-CORRELATION COEFF. ZEROTH ORDER SUBSET SPLITTING    |
------------------------------------------------------------------------------------------

The following function is the least squares coefficient 
(objective function) that will be used in the DIC optimization stage.

This particular function is zeroth order because it uses displacements
"u" and "v" only. However, it also incorporates an extra parameter to represent a discontinuity
%}

function [C, GRAD, HESS] = C_Zeroth_Split_with_Hess( q )
% q is the vector of deformation variables, rename them for clarity
    u           = q(1);             % Displacement in "x" of center pixel
    v           = q(2);             % Displacement in "y" of center pixel
    u_jump      = q(3);             % Rigid displacement between the subsets in "x" direction
    v_jump      = q(4);             % Rigid displacement between the subsets in "y" direction
    a           = q(5);             % Variable defining the discontinuity (split) line
    b           = q(6);             % Variable defining the discontinuity (split) line
       
    global subset_size;
    global ref_image;
    global def_interp;
    global Xp;
    global Yp;
    
    
    % i and j will define the subset points to be compared.
    i = -floor(subset_size/2) : 1 : floor(subset_size/2);
    j = -floor(subset_size/2) : 1 : floor(subset_size/2);
    
    %f_test = ref_image(Yp+j, Xp+i);
    %g_test = fnval( def_interp, {Yp+v+j, Xp+u+i});
    %f_g_sq_test = (f_test-g_test).^2;
    %STD = std(std(f_g_sq_test));
    %if STD <= 5e-3
        %safe = true;
    %else
        %safe = false;
    %end
    
    % Compute the relevant terms using the Subset_Splitting method
    [f, g, dg_dX, dg_dY, secondary, Valid]  = Subset_Splitting( u, v, a, b, u_jump, v_jump );
    
    % To do the numerical derivatives of "a" and "b" find the min change required
    [delta_a, delta_b] = Min_Change( a, b, Valid );
    
    % Compute the relevant terms using the Subset_Splitting method
    [f_ada, g_ada, dg_dX_ada, dg_dY_ada, secondary_ada, Valid_ada]  = Subset_Splitting( u, v, a+delta_a, b, u_jump, v_jump );
    
    % To do the numerical derivatives of "a+delta_a" and "b" find the min change required
    [delta_a_ada, delta_b_ada] = Min_Change( a+delta_a, b, Valid_ada );
    
    % Compute the relevant terms using the Subset_Splitting method
    [f_bdb, g_bdb, dg_dX_bdb, dg_dY_bdb, secondary_bdb, Valid_bdb]  = Subset_Splitting( u, v, a, b+delta_b, u_jump, v_jump );
    
    % To do the numerical derivatives of "a" and "b+delta_b" find the min change required
    [delta_a_bdb, delta_b_bdb] = Min_Change( a, b+delta_b, Valid_bdb );
    
    
    
    
    
    
    
%-OBJECTIVE FUNCTION "C"---------------------------------------------------
    % f represents intensities of the discrete points in the ref subset
    % g represents the intensities of the continuous splined def sector
    
    
    % The following represents the double sums of C, 
    %(The summation limits are from -floor(subset_size/2) to floor(subset_size/2)
    SS_f_g = sum(sum( ((f-g).^2) ));
    SS_f_sq = sum(sum( (f.^2) ));
    
    
    C = SS_f_g./SS_f_sq;
%--------------------------------------------------------------------------
 
if nargout > 1
%-GRADIENT OF "C"----------------------------------------------------------

    % To compute the numerical derivatives of dC/da and dC/db, we need to
    % find C(..., a+delta_a, b ) and C(..., a, b+delta_b).
    SS_f_sq_ada = sum(sum( (f_ada.^2) ));
    SS_f_sq_bdb = sum(sum( (f_bdb.^2) ));
    C_ada = sum(sum( ((f_ada-g_ada).^2) ))./SS_f_sq_ada;
    C_bdb = sum(sum( ((f_bdb-g_bdb).^2) ))./SS_f_sq_bdb;
    
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
    
    GRAD = (2/SS_f_sq).*[ dC_du, dC_dv, dC_du_jump, dC_dv_jump, (C_ada - C)/delta_a, (C_bdb - C)/delta_b ]';
    
    
    % GRAD|( ..., a+delta_a, b) --> This is required in order to numerically solve for the Hessian Matrix
    
    % To compute the numerical derivatives of dC/d(a+delta_a) and dC/d(b+delta_b), we need to
    % find C(..., a+delta_a, b ) and C(..., a, b+delta_b).
    [f_a_ada,  g_a_ada] = Subset_Splitting( u, v, a+delta_a+delta_a_ada, b,             u_jump, v_jump );
    [f_b_ada,  g_b_ada] = Subset_Splitting( u, v, a+delta_a,             b+delta_b_ada, u_jump, v_jump );
    C_a_ada = sum(sum( ((f_a_ada-g_a_ada).^2) ))./sum(sum( (f_a_ada.^2) ));
    C_b_ada = sum(sum( ((f_b_ada-g_b_ada).^2) ))./sum(sum( (f_b_ada.^2) ));
    
    % Determine the derivitives of the coordinate terms (i.e. suppose that
    % the coordinates of "f" are f(X,Y) = f(Xp+i-u+..., Yp+j-v+...)
    dX_du_ada = 1;
    dX_dv_ada = 0;
    dX_du_jump_ada = ones(subset_size, subset_size).*secondary_ada;
    dX_dv_jump_ada = 0;
    
    dY_du_ada = 0;
    dY_dv_ada = 1;
    dY_du_jump_ada = 0;
    dY_dv_jump_ada = ones(subset_size, subset_size).*secondary_ada;

    
    % Express the chain rule for partial derivites on "g"
    dg_du_ada      = dg_dX_ada.*dX_du_ada         + dg_dY_ada.*dY_du_ada;
    dg_dv_ada      = dg_dX_ada.*dX_dv_ada         + dg_dY_ada.*dY_dv_ada;
    dg_du_jump_ada = dg_dX_ada.*dX_du_jump_ada    + dg_dY_ada.*dY_du_jump_ada;
    dg_dv_jump_ada = dg_dX_ada.*dX_dv_jump_ada    + dg_dY_ada.*dY_dv_jump_ada;
    
    % Write out each value in the gradient vector
    dC_du_ada = sum(sum( (g_ada-f_ada).*(dg_du_ada) ));
    dC_dv_ada = sum(sum( (g_ada-f_ada).*(dg_dv_ada) ));
    dC_du_jump_ada = sum(sum( (g_ada-f_ada).*(dg_du_jump_ada) ));
    dC_dv_jump_ada = sum(sum( (g_ada-f_ada).*(dg_dv_jump_ada) ));
    
    GRAD_ada = (2/SS_f_sq_ada).*[ dC_du_ada, dC_dv_ada, dC_du_jump_ada, dC_dv_jump_ada, (C_a_ada - C_ada)/delta_a_ada, (C_b_ada - C_ada)/delta_b_ada ]';
    
    
    % GRAD| (..., a, b+delta_b) --> This is required in order to numerically solve for the Hessian Matrix
    
    % To compute the numerical derivatives of dC/d(a+delta_a) and dC/d(b+delta_b), we need to
    % find C(..., a+delta_a, b ) and C(..., a, b+delta_b).
    [f_a_bdb,  g_a_bdb] = Subset_Splitting( u, v, a+delta_a_bdb, b+delta_b,             u_jump, v_jump );
    [f_b_bdb,  g_b_bdb] = Subset_Splitting( u, v, a,             b+delta_b+delta_b_bdb, u_jump, v_jump );
    C_a_bdb = sum(sum( ((f_a_bdb-g_a_bdb).^2) ))./sum(sum( (f_a_bdb.^2) ));
    C_b_bdb = sum(sum( ((f_b_bdb-g_b_bdb).^2) ))./sum(sum( (f_b_bdb.^2) ));
    
    % Determine the derivitives of the coordinate terms (i.e. suppose that
    % the coordinates of "f" are f(X,Y) = f(Xp+i-u+..., Yp+j-v+...)
    dX_du_bdb = 1;
    dX_dv_bdb = 0;
    dX_du_jump_bdb = ones(subset_size, subset_size).*secondary_bdb;
    dX_dv_jump_bdb = 0;
    
    dY_du_bdb = 0;
    dY_dv_bdb = 1;
    dY_du_jump_bdb = 0;
    dY_dv_jump_bdb = ones(subset_size, subset_size).*secondary_bdb;

    
    % Express the chain rule for partial derivites on "g"
    dg_du_bdb      = dg_dX_bdb.*dX_du_bdb         + dg_dY_bdb.*dY_du_bdb;
    dg_dv_bdb      = dg_dX_bdb.*dX_dv_bdb         + dg_dY_bdb.*dY_dv_bdb;
    dg_du_jump_bdb = dg_dX_bdb.*dX_du_jump_bdb    + dg_dY_bdb.*dY_du_jump_bdb;
    dg_dv_jump_bdb = dg_dX_bdb.*dX_dv_jump_bdb    + dg_dY_bdb.*dY_dv_jump_bdb;
    
    % Write out each value in the gradient vector
    dC_du_bdb = sum(sum( (g_bdb-f_bdb).*(dg_du_bdb) ));
    dC_dv_bdb = sum(sum( (g_bdb-f_bdb).*(dg_dv_bdb) ));
    dC_du_jump_bdb = sum(sum( (g_bdb-f_bdb).*(dg_du_jump_bdb) ));
    dC_dv_jump_bdb = sum(sum( (g_bdb-f_bdb).*(dg_dv_jump_bdb) ));
    
    GRAD_bdb = (2/SS_f_sq_bdb).*[ dC_du_bdb, dC_dv_bdb, dC_du_jump_bdb, dC_dv_jump_bdb, (C_a_bdb - C_bdb)/delta_a_bdb, (C_b_bdb - C_bdb)/delta_b_bdb ]';
    
        
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
    
    
    % Some parts of this Hessian must be determined numerically (  d(GRAD)/da, and d(GRAD)/db  )
    dGRAD_da = (GRAD_ada - GRAD)./delta_a;
    dGRAD_db = (GRAD_bdb - GRAD)./delta_b;
             
    % This is the Hessian Matrix. Notice that for the term d2C/dadb, 
    % I took the average value of the numerically found d( dC/da )/db and d( dC/db )/da       
    HESS = (2/SS_f_sq).* [  d2C_du2,       d2C_dudv,      d2C_dudu_jump,      d2C_dudv_jump,      dGRAD_da(1),                 dGRAD_db(1); ...
                            d2C_dudv,      d2C_dv2,       d2C_dvdu_jump,      d2C_dvdv_jump,      dGRAD_da(2),                 dGRAD_db(2); ...
                            d2C_dudu_jump, d2C_dvdu_jump, d2C_du_jump2,       d2C_du_jumpdv_jump, dGRAD_da(3),                 dGRAD_db(3); ...
                            d2C_dudv_jump, d2C_dvdv_jump, d2C_du_jumpdv_jump, d2C_dv_jump2,       dGRAD_da(4),                 dGRAD_db(4); ...
                            dGRAD_da(1),   dGRAD_da(2),   dGRAD_da(3),        dGRAD_da(4),        dGRAD_da(5),                 (dGRAD_da(6)+dGRAD_db(5))./2; ...
                            dGRAD_db(1),   dGRAD_db(2),   dGRAD_db(3),        dGRAD_db(4),        (dGRAD_da(6)+dGRAD_db(5))./2, dGRAD_db(6)];
%--------------------------------------------------------------------------

end % if nargout > 2
end % if nargout > 1

end % function





% Subset splitting occurs here
function [f, g, dg_dX, dg_dY, secondary, Valid] = Subset_Splitting( u, v, a, b, u_jump, v_jump )
    
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
    
    %top = J_matrix < round(a*I_matrix + b);
    %bottom = J_matrix > round(a*I_matrix + b);
    %dead_pixels = J_matrix == round(a*I_matrix + b);
    
    % Make a matrix that defines the pixels that are off the line
    Valid = top + bottom;
    
    figure; imshow(Valid); title(sprintf('a = %g, b = %g', a,b));
    
    % Extract the reference intensities and zero-out the pixels on the line with "Valid"
    f = ref_image(Yp+j, Xp+i).*Valid;
    
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




% Determine the minimum changes in "a" and "b" to produce a change (used in numerical derivatives)
function [delta_a, delta_b] = Min_Change( a, b, Valid )
    
% In order to find the effect of a and b on the Correlation
% Coefficient, we need to take numerical derivatives, since analytic
% ones are not possible. (Can't pass d()/da or d()/db into the
% summations in C(u,v,uj,vj,a,b). However, if a and b are not shifted
% by a large enough amount, the line will remain almost the same, and
% the pixels that are removed from the subset/sum will be the same.
% Therefore, we need to find the smallest value required to offset "a"
% and "b" while ensuring a change in C.

global subset_size;

% i and j will define the subset points to be compared.
i = -floor(subset_size/2) : 1 : floor(subset_size/2);
j = -floor(subset_size/2) : 1 : floor(subset_size/2);

% I_matrix and J_matrix are the grid of data points formed by vectors i and j
[I_matrix, J_matrix] = meshgrid(i,j);

dead_pixels = -(Valid - 1);
[row, col] = find(dead_pixels);

Vert_Shift = NaN*zeros(numel(row), 1);
Slope_Shift = NaN*zeros(numel(row), 1);

for i = 1:numel(row)
    
    if (J_matrix(row(i),col(i))+0.5) >= (a*(I_matrix(row(i),col(i))-0.5)+b) && ...
       (J_matrix(row(i),col(i))+0.5)-(a*(I_matrix(row(i),col(i))-0.5)+b) <= 0.5
        
        Vert_Shift(i) = (J_matrix(row(i),col(i))+0.5) - (a*(I_matrix(row(i),col(i))-0.5)+b);
        I_shift = -0.5;
    else
        Vert_Shift(i) = (J_matrix(row(i),col(i))+0.5) - (a*(I_matrix(row(i),col(i))+0.5)+b);
        I_shift = 0.5;
    end

    %if a*(I_matrix(row(i),col(i))-0.5)+b > subset_size
        %Shift_up(i) = abs( (J_matrix(row(i),col(i))+0.5) - (a*(I_matrix(row(i),col(i))-0.5)+b) );
    %else
        %Shift_up(i) = abs( (J_matrix(row(i),col(i))-0.5) - (a*(I_matrix(row(i),col(i))-0.5)+b) );
    %end
    
    Shift_down = 1-Vert_Shift(i);

            if col(i) > round(subset_size/2)
                Slope_Shift(i) = Shift_down/abs(I_matrix(row(i),col(i)) + I_shift);
            elseif col(i) < round(subset_size/2)
                Slope_Shift(i) = Vert_Shift(i)/abs(I_matrix(row(i),col(i)) + I_shift);
            end

end

if (J_matrix(row(i),col(i))+0.5) >= (a*(I_matrix(row(i),col(i))+0.5)+b) && ...
   (J_matrix(row(i),col(i))+0.5)-(a*(I_matrix(row(i),col(i))+0.5)+b)<=0.5
    
    Vert_Shift(i+1) = (J_matrix(row(i),col(i))+0.5) - (a*(I_matrix(row(i),col(i))+0.5)+b);
    Slope_Shift(i+1) = Vert_Shift(i)/abs(I_matrix(row(i),col(i)) + 0.5);
end



delta_b = min(Vert_Shift);

if delta_b == 0
    su = nonzeros(Vert_Shift);
    if isempty(su) == false
        delta_b = min(su);
    else
        delta_b = 1;
    end
end

delta_a = min( Slope_Shift );

if delta_a == 0
    su = nonzeros(Slope_Shift);
    if isempty(su) == false
        delta_a = min(su);
    else
        delta_a = 0.5/floor(subset_size/2);
    end
end
            

end % function




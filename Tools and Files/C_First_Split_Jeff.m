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


% Digital Image Correlation: Cross-Correlation Coefficient, 
%                            Objective Function, 
%                            First Split
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  July 25, 2007
% Modified on: August 12, 2007


------------------------------------------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: CROSS-CORRELATION COEFF. FIRST ORDER SUBSET SPLITTING     |
------------------------------------------------------------------------------------------

The following function is the least squares coefficient 
(objective function) that will be used in the DIC optimization stage.

This particular function is first order because it uses displacements
"u", "v", "du/dx", "dv/dy", "du/dy", "dv/dx".
%}
function [C, GRAD, HESS] = C_First_Split_Jeff( q, a, b )
% q is the vector of deformation variables, rename them for clarity
    u           = q(1);             % Displacement in "x" of center pixel
    v           = q(2);             % Displacement in "y" of center pixel
    du_dx       = q(3);             % Rate of change of "u" in "x"
    dv_dy       = q(4);             % Rate of change of "v" in "y"
    du_dy       = q(5);             % Rate of change of "u" in "y"
    dv_dx       = q(6);             % Rate of change of "v" in "x"
    
    global subset_size;
    
    % i and j will define the subset points to be compared.
    i = -floor(subset_size/2) : 1 : floor(subset_size/2);
    j = -floor(subset_size/2) : 1 : floor(subset_size/2);
    
    % I_matrix and J_matrix are the grid of data points formed by vectors i and j
    [I_matrix,J_matrix] = meshgrid(i,j);
    
    % Store the number of points in the subset
    N = subset_size.*subset_size;
    
    % Reshape the I and J from grid matrices into vectors containing the (x,y) coordinates of each point
    I = reshape(I_matrix, 1,N);
    J = reshape(J_matrix, 1,N);
    

%-SUBSET SPLITTING---------------------------------------------------
    % Now that we know where to split the subset we need to compute how it should deform,
    % and what the values at these positions. Start by checking the initial
    % guess, then split the subset and pass it to the rest of the Newton Raphson Method
    % to optimize the parameters.

    % Compute the relevant terms using the Subset_Splitting function
    [f, g, dg_dX, dg_dY, main]  = Subset_Removing( u, v, du_dx, dv_dy, du_dy, dv_dx, a, b, i, j, I, J, I_matrix, J_matrix);
    
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
    dX_dudx = I_matrix.*main;
    dX_dvdy = 0;
    dX_dudy = J_matrix.*main;
    dX_dvdx = 0;
    
    dY_du = 0;
    dY_dv = 1;
    dY_dudx = 0;
    dY_dvdy = J_matrix.*main;
    dY_dudy = 0;
    dY_dvdx = I_matrix.*main;

    
    % Express the chain rule for partial derivites on "g"
    dg_du   = dg_dX.*dX_du + dg_dY.*dY_du;
    dg_dv   = dg_dX.*dX_dv + dg_dY.*dY_dv;
    dg_dudx = dg_dX.*dX_dudx + dg_dY.*dY_dudx;
    dg_dvdy = dg_dX.*dX_dvdy + dg_dY.*dY_dvdy;
    dg_dudy = dg_dX.*dX_dudy + dg_dY.*dY_dudy;
    dg_dvdx = dg_dX.*dX_dvdx + dg_dY.*dY_dvdx;
    
    % Write out each value in the gradient vector
    dC_du = sum(sum( (g-f).*(dg_du) ));
    dC_dv = sum(sum( (g-f).*(dg_dv) ));
    dC_dudx = sum(sum( (g-f).*(dg_dudx) ));
    dC_dvdy = sum(sum( (g-f).*(dg_dvdy) ));
    dC_dudy = sum(sum( (g-f).*(dg_dudy) ));
    dC_dvdx = sum(sum( (g-f).*(dg_dvdx) ));
    
    GRAD = (2/SS_f_sq).*[ dC_du, dC_dv, dC_dudx, dC_dvdy, dC_dudy, dC_dvdx ]';
        
%--------------------------------------------------------------------------

if nargout > 2
%-HESSIAN OF "C"-----------------------------------------------------------   

    % Write out each value in the Hessian Matrix (remember, it's symmetric,
    % so only half of the entries are need), using Knauss' approximation
    d2C_du2 = sum(sum( (dg_du).*(dg_du) ));               
    d2C_dv2 = sum(sum( (dg_dv).*(dg_dv) ));
    d2C_dudx2 = sum(sum( (dg_dudx).*(dg_dudx) ));
    d2C_dvdy2 = sum(sum( (dg_dvdy).*(dg_dvdy) ));
    d2C_dudy2 = sum(sum( (dg_dudy).*(dg_dudy) ));
    d2C_dvdx2 = sum(sum( (dg_dvdx).*(dg_dvdx) ));
    
    d2C_dudv = sum(sum( (dg_du).*(dg_dv) ));
    d2C_dududx = sum(sum( (dg_du).*(dg_dudx) ));
    d2C_dudvdy = sum(sum( (dg_du).*(dg_dvdy) ));
    d2C_dududy = sum(sum( (dg_du).*(dg_dudy) ));
    d2C_dudvdx = sum(sum( (dg_du).*(dg_dvdx) ));
    
    d2C_dvdudx = sum(sum( (dg_dv).*(dg_dudx) ));
    d2C_dvdvdy = sum(sum( (dg_dv).*(dg_dvdy) ));
    d2C_dvdudy = sum(sum( (dg_dv).*(dg_dudy) ));
    d2C_dvdvdx = sum(sum( (dg_dv).*(dg_dvdx) ));
    
    d2C_dudxdvdy = sum(sum( (dg_dudx).*(dg_dvdy) ));
    d2C_dudxdudy = sum(sum( (dg_dudx).*(dg_dudy) ));
    d2C_dudxdvdx = sum(sum( (dg_dudx).*(dg_dvdx) ));
    
    d2C_dvdydudy = sum(sum( (dg_dvdy).*(dg_dudy) ));
    d2C_dvdydvdx = sum(sum( (dg_dvdy).*(dg_dvdx) ));
    
    d2C_dudydvdx = sum(sum( (dg_dudy).*(dg_dvdx) ));
             
             
    HESS = (2/SS_f_sq).* [  d2C_du2,    d2C_dudv,   d2C_dududx,   d2C_dudvdy,   d2C_dududy,   d2C_dudvdx   ; ...
                            d2C_dudv,   d2C_dv2,    d2C_dvdudx,   d2C_dvdvdy,   d2C_dvdudy,   d2C_dvdvdx   ; ...
                            d2C_dududx, d2C_dvdudx, d2C_dudx2,    d2C_dudxdvdy, d2C_dudxdudy, d2C_dudxdvdx ; ...
                            d2C_dudvdy, d2C_dvdvdy, d2C_dudxdvdy, d2C_dvdy2,    d2C_dvdydudy, d2C_dvdydvdx ; ...
                            d2C_dududy, d2C_dvdudy, d2C_dudxdudy, d2C_dvdydudy, d2C_dudy2,    d2C_dudydvdx ; ...
                            d2C_dudvdx, d2C_dvdvdx, d2C_dudxdvdx, d2C_dvdydvdx, d2C_dudydvdx, d2C_dvdx2   ];
%--------------------------------------------------------------------------
end % if nargout > 2
end % if nargout > 1

end % function



% Subset splitting occurs here
function [f, g, dg_dX, dg_dY, main] = Subset_Removing( u, v, du_dx, dv_dy, du_dy, dv_dx, a, b, i, j, I, J, I_matrix, J_matrix)
    
    global subset_size;
    global ref_image;
    global def_interp;
    global def_interp_x;
    global def_interp_y;
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
        main = top;
    else
        main = bottom;
    end
    
    % Define the deformed postions
    X = Xp + u + I + I.*du_dx + J.*du_dy;
    Y = Yp + v + J + J.*dv_dy + I.*dv_dx;    
    
    % Extract the reference intensities and zero-out the pixels with bad values
    f = ref_image(Yp+j, Xp+i).*main;
    
    % Extract the deformed intensities and zero-out the same bad pixels
    g = reshape( fnval(def_interp, [Y;X]), subset_size, subset_size ).*main;
    
    if nargout > 2
        % Evaluate the derivitives at the points of interest in the main and secondary positions
        dg_dX = reshape( fnval(def_interp_x, [Y;X]), subset_size, subset_size ).*main;
        dg_dY = reshape( fnval(def_interp_y, [Y;X]), subset_size, subset_size ).*main;
        
    end
    
end % function

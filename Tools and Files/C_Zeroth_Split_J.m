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
% Modified on: August 27, 2007


------------------------------------------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: CROSS-CORRELATION COEFF. ZEROTH ORDER SUBSET SPLITTING    |
------------------------------------------------------------------------------------------

The following function is the least squares coefficient 
(objective function) that will be used in the DIC optimization stage.

This particular function is zeroth order because it uses displacements
"u" and "v" only. However, it also incorporates an extra parameter to represent a discontinuity
%}

function [C, GRAD, HESS] = C_Zeroth_Split_J( q, good, bad )
    % q is the vector of deformation variables, rename them for clarity
    u           = q(1);             % First displacement in "x"
    v           = q(2);             % First displacement in "y"
    uJ          = q(3);             % Rigid displacement between the subsets in "x" direction
    vJ          = q(4);             % Rigid displacement between the subsets in "y" direction
    
    global subset_size;
    global ref_image;
    global def_interp_G;
    global def_interp_B;
    global def_interp_x_G;
    global def_interp_y_G;
    global def_interp_x_B;
    global def_interp_y_B;
    global Xp;
    global Yp;
    
    
    % i and j will define the subset points to be compared.
    i = -floor(subset_size/2) : 1 : floor(subset_size/2);
    j = -floor(subset_size/2) : 1 : floor(subset_size/2);
    
    % Compute the relevant terms using the Subset_Splitting method
    %[f, g, dg_dX, dg_dY, main]  = Subset_Splitting( u1, v1, u2, v2, a, b);
    
    
%-OBJECTIVE FUNCTION "C"---------------------------------------------------
    % f represents intensities of the discrete points in the ref subset
    % g represents the intensities of the continuous splined def sector
    
    % Extract the reference intensities and zero-out the pixels on the line with "Valid"
    f = ref_image(Yp+j, Xp+i).*(good+bad);
    
    % Extract two matrices for the deformed subsets
    g_G       = fnval( def_interp_G, {Yp+v+j, Xp+u+i}).*good;
    g_B       = fnval( def_interp_B, {Yp+v+j+vJ, Xp+u+i+uJ}).*bad;
    
    % Combine the two matrices into one matrix
    g = g_G + g_B;
    
    % The following represents the double sums of C, 
    %(The summation limits are from -floor(subset_size/2) to floor(subset_size/2)
    SS_f_g = sum(sum( ((f-g).^2) ));
    SS_f_sq = sum(sum( (f.^2) ));
    
    
    C = SS_f_g./SS_f_sq;
%--------------------------------------------------------------------------
 
if nargout > 1
%-GRADIENT OF "C"----------------------------------------------------------
    
    % Evaluate the derivitives at the points of interest in the main and secondary positions
    dg_dX_G    = fnval(def_interp_x_G, {Yp+v+j, Xp+u+i}).*good;
    dg_dX_B    = fnval(def_interp_x_B, {Yp+v+j+vJ, Xp+u+i+uJ}).*bad;

    dg_dY_G    = fnval(def_interp_y_G, {Yp+v+j, Xp+u+i}).*good;
    dg_dY_B    = fnval(def_interp_y_B, {Yp+v+j+vJ, Xp+u+i+uJ}).*bad;

    % Combine the main and secondary matrices into one matrix
    dg_dX = dg_dX_G + dg_dX_B;
    dg_dY = dg_dY_G + dg_dY_B; 
    
    
    % Determine the derivitives of the coordinate terms (i.e. suppose that
    % the coordinates of "f" are f(X,Y) = f(Xp+i-u+..., Yp+j-v+...)
    dX_du  = 1;
    dX_dv  = 0;
    dX_duJ = bad;
    dX_dvJ = 0;
    
    dY_du  = 0;
    dY_dv  = 1;
    dY_duJ = 0;
    dY_dvJ = bad;

    
    % Express the chain rule for partial derivites on "g"
    dg_du    = dg_dX.*dX_du  + dg_dY.*dY_du;
    dg_dv    = dg_dX.*dX_dv  + dg_dY.*dY_dv;
    dg_duJ   = dg_dX.*dX_duJ + dg_dY.*dY_duJ;
    dg_dvJ   = dg_dX.*dX_dvJ + dg_dY.*dY_dvJ;
    
    % Write out each value in the gradient vector
    dC_du  = sum(sum( (g-f).*(dg_du) ));
    dC_dv  = sum(sum( (g-f).*(dg_dv) ));
    dC_duJ = sum(sum( (g-f).*(dg_duJ) ));
    dC_dvJ = sum(sum( (g-f).*(dg_dvJ) ));
    
    GRAD = (2/SS_f_sq).*[ dC_du, dC_dv, dC_duJ, dC_dvJ ]';        
%--------------------------------------------------------------------------

if nargout > 2
%-HESSIAN OF "C"-----------------------------------------------------------   

    % Write out each value in the Hessian Matrix (remember, it's symmetric,
    % so only half of the entries are need), using Knauss' approximation
    d2C_du2  = sum(sum( (dg_du).*(dg_du) ));               
    d2C_dv2  = sum(sum( (dg_dv).*(dg_dv) ));
    d2C_duJ2 = sum(sum( (dg_duJ).*(dg_duJ) ));
    d2C_dvJ2 = sum(sum( (dg_dvJ).*(dg_dvJ) ));
    
    d2C_dudv  = sum(sum( (dg_du).*(dg_dv) ));
    d2C_duduJ = sum(sum( (dg_du).*(dg_duJ) ));
    d2C_dudvJ = sum(sum( (dg_du).*(dg_dvJ) ));
    
    d2C_dvduJ = sum(sum( (dg_dv).*(dg_duJ) ));
    d2C_dvdvJ = sum(sum( (dg_dv).*(dg_dvJ) ));
    
    d2C_duJdvJ = sum(sum( (dg_duJ).*(dg_dvJ) ));
             
             
    HESS = (2/SS_f_sq).* [  d2C_du2,   d2C_dudv,  d2C_duduJ,  d2C_dudvJ; ...
                            d2C_dudv,  d2C_dv2,   d2C_dvduJ,  d2C_dvdvJ; ...
                            d2C_duduJ, d2C_dvduJ, d2C_duJ2,   d2C_duJdvJ; ...
                            d2C_dudvJ, d2C_dvdvJ, d2C_duJdvJ, d2C_dvJ2 ];
%--------------------------------------------------------------------------
end % if nargout > 2
end % if nargout > 1

end % function



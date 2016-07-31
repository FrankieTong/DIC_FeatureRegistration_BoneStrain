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
%                            Zeroth Order
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  May 28, 2007
% Modified on: May 31, 2007


------------------------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: CROSS-CORRELATION COEFF. ZEROTH ORDER   |
------------------------------------------------------------------------

The following function is the least squares coefficient 
(objective function) that will be used in the DIC optimization stage.

This particular function is zeroth order because it only uses displacements
"u" and "v" as variables.
%}

function [C, GRAD, HESS] = C_Zeroth_Order( q )

    % q is the vector of deformation variables, rename them for clarity
    u           = q(1);
    v           = q(2);
    
    global subset_size;
    global ref_image;
    global def_interp;
    global Xp;
    global Yp;
    global def_interp_x;
    global def_interp_y;    

    
    % i and j will define the subset points to be compared.
    i = -floor(subset_size/2) : 1 : floor(subset_size/2);
    j = -floor(subset_size/2) : 1 : floor(subset_size/2);
    
    
%-OBJECTIVE FUNCTION "C"---------------------------------------------------
    % f represents intensities of the discrete points in the ref image
    f = ref_image( Yp+j, Xp+i);
    
    % g represents the intensities of the continuous points in the def image
    g = fnval(def_interp, {Yp+j+v, Xp+i+u});
   
    % The following represents the double sums of C, 
    %(The summation limits are from -floor(subset_size/2) to floor(subset_size/2)
    SS_f_g = sum(sum( ((f-g).^2) ));
    SS_f_sq = sum(sum( (f.^2) ));
    
    % C is made negative since the optimization searches for the minimum
    C = SS_f_g/SS_f_sq;
%--------------------------------------------------------------------------
 
if nargout > 1
%-GRADIENT OF "C"----------------------------------------------------------  
    % Evaluate the derivitives at the points of interest
    dg_dX = fnval(def_interp_x, {Yp+j+v, Xp+i+u});
    dg_dY = fnval(def_interp_y, {Yp+j+v, Xp+i+u});
    
    % Determine the derivitives of the coordinate terms (i.e. suppose that
    % the coordinates of "g" are g(X,Y) = g(Xp+i+u+..., Yp+j+v+...)
    dX_du = 1;
    dY_du = 0;
    dY_dv = 1;
    dX_dv = 0;
    
    % Express the chain rule for partial derivites on "g"
    dg_du = (dg_dX.*dX_du + dg_dY.*dY_du);
    dg_dv = (dg_dX.*dX_dv + dg_dY.*dY_dv);
    
    % Write out each value in the gradient vector
    dC_du = 2*sum(sum( (g-f).*(dg_du) ))/SS_f_sq;
    dC_dv = 2*sum(sum( (g-f).*(dg_dv) ))/SS_f_sq;
    
    GRAD = [ dC_du, dC_dv ]';
%--------------------------------------------------------------------------

if nargout > 2
%-HESSIAN OF "C"-----------------------------------------------------------   

    % Write out each value in the Hessian Matrix (remember, it's symmetric,
    % so only half of the entries are need), using Knauss' approximation
    d2C_du2 = (2/SS_f_sq)*sum(sum( (dg_du).*(dg_du) ));
                
    d2C_dv2 = (2/SS_f_sq)*sum(sum( (dg_dv).*(dg_dv) ));
             
    d2C_dudv = (2/SS_f_sq)*sum(sum( (dg_du).*(dg_dv) ));
             
             
    HESS = [ d2C_du2 , d2C_dudv ; d2C_dudv , d2C_dv2 ];
%--------------------------------------------------------------------------
end % if nargout > 2
end % if nargout > 1

end % function
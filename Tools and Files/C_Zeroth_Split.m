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

function [C, GRAD, HESS] = C_Zeroth_Split( q, a, b, top, bottom )
    % q is the vector of deformation variables, rename them for clarity
    u1          = q(1);             % First displacement in "x"
    v1          = q(2);             % First displacement in "y"
    u2          = q(3);             % Rigid displacement between the subsets in "x" direction
    v2          = q(4);             % Rigid displacement between the subsets in "y" direction
    %a           = q(5);             % Variable defining the discontinuity (split) line
    %b           = q(6);             % Variable defining the discontinuity (split) line
    
    %figure; imshow(top+bottom-.25); title(sprintf('a = %g, b = %g', a,b));
    
    %{
    % This is a debug tool to see what happens as "q" changes.
    % Start with the perfect guess
    q(1) = 0;
    q(2) = 0;
    q(3) = 0;
    q(4) = 2;
    q(5) = 0;
    q(6) = 5;
    variable_plotter( q );
    
    
    
    
    % Now try a bad value for b
    q(1) = 0;
    q(2) = 0;
    q(3) = 0;
    q(4) = 2;
    q(5) = 0;
    q(6) = 5.501;
    variable_plotter( q );
    

    % Now try a bad value for a
    q(1) = 0;
    q(2) = 0;
    q(3) = 0;
    q(4) = 2;
    q(5) = 0.501;
    q(6) = 5;
    variable_plotter( q );
    

    
    % Now try a bad value for a and b
    q(1) = 0;
    q(2) = 0;
    q(3) = 0;
    q(4) = 2;
    q(5) = -0.501;
    q(6) = 5.501;
    variable_plotter( q );
    
    
    
    % Now try a bad value for u_jump, v_jump
    q(1) = 0;
    q(2) = 0;
    q(3) = -0.35;
    q(4) = 2.15;
    q(5) = 0;
    q(6) = 5;
    variable_plotter( q );
    
    
    
    % Now try a small change in a
    q(1) = 0;
    q(2) = 0;
    q(3) = 0;
    q(4) = 2;
    q(5) = 0.05;
    q(6) = 5;
    variable_plotter( q );
    %}
    
    global subset_size;
    global ref_image;
    global def_interp_1;
    global def_interp_2;
    global def_interp_x_1;
    global def_interp_x_2;
    global def_interp_y_1;
    global def_interp_y_2;
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
    f = ref_image(Yp+j, Xp+i).*(top+bottom);
    
    % Extract two matrices for the deformed subsets
    g_1       = fnval( def_interp_1, {Yp+v1+j, Xp+u1+i}).*top;
    g_2       = fnval( def_interp_2, {Yp+v2+j, Xp+u2+i}).*bottom;
    
    % Combine the two matrices into one matrix
    g = g_1 + g_2;
    
    % The following represents the double sums of C, 
    %(The summation limits are from -floor(subset_size/2) to floor(subset_size/2)
    SS_f_g = sum(sum( ((f-g).^2) ));
    SS_f_sq = sum(sum( (f.^2) ));
    
    
    C = SS_f_g./SS_f_sq;
%--------------------------------------------------------------------------
 
if nargout > 1
%-GRADIENT OF "C"----------------------------------------------------------
    
    % Evaluate the derivitives at the points of interest in the main and secondary positions
    dg_dX_1    = fnval(def_interp_x_1, {Yp+v1+j, Xp+u1+i}).*top;
    dg_dX_2    = fnval(def_interp_x_2, {Yp+v2+j, Xp+u2+i}).*bottom;

    dg_dY_1    = fnval(def_interp_y_1, {Yp+v1+j, Xp+u1+i}).*top;
    dg_dY_2    = fnval(def_interp_y_2, {Yp+v2+j, Xp+u2+i}).*bottom;

    % Combine the main and secondary matrices into one matrix
    dg_dX = dg_dX_1 + dg_dX_2;
    dg_dY = dg_dY_1 + dg_dY_2; 
    
    
    % Determine the derivitives of the coordinate terms (i.e. suppose that
    % the coordinates of "f" are f(X,Y) = f(Xp+i-u+..., Yp+j-v+...)
    dX_du1 = top;
    dX_dv1 = 0;
    dX_du2 = bottom;
    dX_dv2 = 0;
    
    dY_du1 = 0;
    dY_dv1 = top;
    dY_du2 = 0;
    dY_dv2 = bottom;

    
    % Express the chain rule for partial derivites on "g"
    dg_du1   = dg_dX.*dX_du1 + dg_dY.*dY_du1;
    dg_dv1   = dg_dX.*dX_dv1 + dg_dY.*dY_dv1;
    dg_du2   = dg_dX.*dX_du2 + dg_dY.*dY_du2;
    dg_dv2   = dg_dX.*dX_dv2 + dg_dY.*dY_dv2;
    
    % Write out each value in the gradient vector
    dC_du1 = sum(sum( (g-f).*(dg_du1) ));
    dC_dv1 = sum(sum( (g-f).*(dg_dv1) ));
    dC_du2 = sum(sum( (g-f).*(dg_du2) ));
    dC_dv2 = sum(sum( (g-f).*(dg_dv2) ));
    
    GRAD = (2/SS_f_sq).*[ dC_du1, dC_dv1, dC_du2, dC_dv2 ]';
        
%--------------------------------------------------------------------------

if nargout > 2
%-HESSIAN OF "C"-----------------------------------------------------------   

    % Write out each value in the Hessian Matrix (remember, it's symmetric,
    % so only half of the entries are need), using Knauss' approximation
    d2C_du12 = sum(sum( (dg_du1).*(dg_du1) ));               
    d2C_dv12 = sum(sum( (dg_dv1).*(dg_dv1) ));
    d2C_du22 = sum(sum( (dg_du2).*(dg_du2) ));
    d2C_dv22 = sum(sum( (dg_dv2).*(dg_dv2) ));
    
    d2C_du1dv1 = sum(sum( (dg_du1).*(dg_dv1) ));
    d2C_du1du2 = sum(sum( (dg_du1).*(dg_du2) ));
    d2C_du1dv2 = sum(sum( (dg_du1).*(dg_dv2) ));
    
    d2C_dv1du2 = sum(sum( (dg_dv1).*(dg_du2) ));
    d2C_dv1dv2 = sum(sum( (dg_dv1).*(dg_dv2) ));
    
    d2C_du2dv2 = sum(sum( (dg_du2).*(dg_dv2) ));
             
             
    HESS = (2/SS_f_sq).* [  d2C_du12,   d2C_du1dv1, d2C_du1du2, d2C_du1dv2; ...
                            d2C_du1dv1, d2C_dv12,   d2C_dv1du2, d2C_dv1dv2; ...
                            d2C_du1du2, d2C_dv1du2, d2C_du22,   d2C_du2dv2; ...
                            d2C_du1dv2, d2C_dv1dv2, d2C_du2dv2, d2C_dv22 ];
%--------------------------------------------------------------------------
end % if nargout > 2
end % if nargout > 1

end % function



%{
% Subset splitting occurs here
function [f, g, dg_dX, dg_dY, main] = Subset_Splitting( u1, v1, u2, v2, a, b)
    
    global subset_size;
    global ref_image;
    global def_interp_1;
    global def_interp_2;
    global def_interp_x_1;
    global def_interp_x_2;
    global def_interp_y_1;
    global def_interp_y_2;
    global Xp;
    global Yp;
    
    % i and j will define the subset points to be compared.
    i = -floor(subset_size/2) : 1 : floor(subset_size/2);
    j = -floor(subset_size/2) : 1 : floor(subset_size/2);
    
    % I_matrix and J_matrix are the grid of data points formed by vectors i and j
    [I_matrix, J_matrix] = meshgrid(i,j);
    
    %{
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
    %}
    % Make a matrix that defines the pixels that are off the line
    Valid = top + bottom;
    
    %figure; 
    %imshow( Valid-0.15 );
    %s = sprintf('Subset used when b = %g', b);
    %title(s);

    %saveas(gcf, strcat(s,'.jpg'));
    %close(findobj('Name', ''));
    
    %figure; imshow(Valid); title(sprintf('a = %g, b = %g', a,b));
    
    % Extract the reference intensities and zero-out the pixels on the line with "Valid"
    f = ref_image(Yp+j, Xp+i).*Valid;
    
    % Extract two matrices for the deformed subsets
    g_1       = fnval( def_interp_1, {Yp+v1+j, Xp+u1+i}).*top;
    g_2       = fnval( def_interp_2, {Yp+v2+j, Xp+u2+i}).*bottom;
    
    % Find who has the most ones (top or bottom) --> who gets deformed by u and v only
    ind_top = find(top);
    ind_bottom = find(bottom);
    if numel(ind_top) >= numel(ind_bottom)
        main = 1;
    else
        main = 2;
    end
    
    % Combine the two matrices into one matrix
    g = g_1 + g_2;
    
    if nargout > 2
        % Evaluate the derivitives at the points of interest in the main and secondary positions
        dg_dX_1    = fnval(def_interp_x_1, {Yp+v1+j, Xp+u1+i}).*top;
        dg_dX_2    = fnval(def_interp_x_2, {Yp+v2+j, Xp+u2+i}).*bottom;
        
        dg_dY_1    = fnval(def_interp_y_1, {Yp+v1+j, Xp+u1+i}).*top;
        dg_dY_2    = fnval(def_interp_y_2, {Yp+v2+j, Xp+u2+i}).*bottom;
        
        % Combine the main and secondary matrices into one matrix
        dg_dX = dg_dX_1 + dg_dX_2;
        dg_dY = dg_dY_1 + dg_dY_2;   
    end
    
end % function
%}

%{
% Subset splitting occurs here
function [f, g, main] = Subset_Splitting( u1, v1, u2, v2, a, b, i, j, I_matrix, J_matrix)
    
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
        main = top;
    else
        main = bottom;
    end
    
    % Extract the reference intensities and zero-out the invalid pixels along the line
    f = ref_image(Yp+j, Xp+i).*(1-Valid);

    % Extract the deformed intensities for both deformations
    g_top    = fnval(def_interp_1, {Yp+j+v1, Xp+i+u1}).*top;
    g_bottom = fnval(def_interp_2, {Yp+j+v2, Xp+i+u2}).*bottom;
    
    % Recombine the two parts to form the total deformation matrix
    g = g_top + g_bottom;
    
end % function
%}


%{
% Determine the minimum changes in "a" and "b" to produce a change (used in numerical derivatives)
function [a_up, a_down, b_up, b_down] = Min_Change( a, b )
    
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

dead_pixels = J_matrix == round(a.*I_matrix + b);
[row, col] = find(dead_pixels);

Shift_down = NaN*zeros(numel(row), 1);
Shift_up = NaN*zeros(numel(row), 1);
Rotate_down = NaN*zeros(numel(row), 1);
Rotate_up = NaN*zeros(numel(row), 1);

for i = 1:numel(row)
        Shift_down(i) = abs((a.*I_matrix(row(i),col(i))+b) - (J_matrix(row(i),col(i)) - 0.5001));
        Shift_up(i) = abs((a.*I_matrix(row(i),col(i))+b) - (J_matrix(row(i),col(i)) + 0.5001));
        
        if I_matrix(1,i) ~= 0
            
            if col(i) < round(subset_size/2)
                Rotate_down(i) = Shift_up(i)/abs(I_matrix(1,i));
                Rotate_up(i) = Shift_down(i)/abs(I_matrix(1,i));
            elseif col(i) > round(subset_size/2)
                Rotate_down(i) = Shift_down(i)/abs(I_matrix(1,i));
                Rotate_up(i) = Shift_up(i)/abs(I_matrix(1,i));
            end
            
        end
end

b_down = -min(Shift_down);
b_up = min(Shift_up);


a_down = -min( Rotate_down );
a_up = min( Rotate_up );
            

end % function


function variable_plotter( q )

u           = q(1);             % Displacement in "x" of center pixel
v           = q(2);             % Displacement in "y" of center pixel
u_jump      = q(3);             % Rigid displacement between the subsets in "x" direction
v_jump      = q(4);             % Rigid displacement between the subsets in "y" direction
a           = q(5);             % Variable defining the discontinuity (split) line
b           = q(6);             % Variable defining the discontinuity (split) line

half_range = 2;

b_min = b - half_range;
b_max = b + half_range;

a_min = a - half_range;
a_max = a + half_range;
global subset_size;
% i and j will define the subset points to be compared.
I = -floor(subset_size/2) : 1 : floor(subset_size/2);
J = -floor(subset_size/2) : 1 : floor(subset_size/2);

% I_matrix and J_matrix are the grid of data points formed by vectors i and j
[I_matrix, J_matrix] = meshgrid(I,J);
    

j = b_min:0.1:b_max;
k = a_min:0.1:a_max;
for i = 1:length(j)
    [f_b,   g_b] = Subset_Splitting( u, v, a, j(i), u_jump, v_jump );
    %[f_a,   g_a] = Subset_Splitting( u, v, k(i), b, u_jump, v_jump );
    C_b(i) = sum(sum( ((f_b-g_b).^2) ))./sum(sum( (f_b.^2) ));
    %C_a(i) = sum(sum( ((f_a-g_a).^2) ))./sum(sum( (f_a.^2) ));
    %dead_pixels = J_matrix == round(a*I_matrix + j(i));
    %live_pixels = -(dead_pixels - 1);
    
    %num_used(i) = length(find(live_pixels));
    
    
    %figure; 
    %imshow( live_pixels-0.15 );
    %s = sprintf('Subset used when b = %g', j(i));
    %title(s);

    %saveas(gcf, strcat(s,'.jpg'));
    %close(findobj('Name', ''));
end

figure; 
plot(j,C_b, 'LineWidth', 2); 
s = sprintf('C vs b with intitial guesses uj = %g, vj = %g, a = %g, b = %g', u_jump, v_jump, a, b);
title(s);
xlabel('b');
ylabel('C');

saveas(gcf, strcat(s,'.jpg'));

%{
figure; 
plot(k,C_a, 'LineWidth', 2); 
t = sprintf('C vs a with with intitial guesses uj = %g, vj = %g, a = %g, b = %g', u_jump, v_jump, a, b);
title(t);
xlabel('a');
ylabel('C');

saveas(gcf, strcat(t,'.jpg'));
%}
figure; 
plot(j,num_used, 'LineWidth', 2); 
t = sprintf('number of pixels used to correlate vs. b');
title(t);
xlabel('b');
ylabel('num pixels used');

saveas(gcf, strcat(t,'.jpg'));
%{
figure; 
plot(num_used,C_b, 'LineWidth', 2); 
t = sprintf('C vs number of pixels used to correlate');
title(t);
xlabel('num pixels used');
ylabel('C');

saveas(gcf, strcat(t,'.jpg'));
%}


end % function
%}


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


% Digital Image Correlation: Small Bad_Value Subset Split
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  November 10, 2007
% Modified on: November 10, 2007


--------------------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: Small Bad_Value Subset Split        |
--------------------------------------------------------------------

The following function will be called whenever the subset splitting method
splits a subset with very few Bad_Values. Rather than running through the 
entire method, it will simply remove the Bad_Values, and correlate using the
rest of the points. This should prove useful espcially near the edges of 
subset splitting boundaries and near the crack tip.
%}

function results = Few_Bad_Values_Subset_Splitting( q_1, Bad_Values )

global TOL;
global Max_num_iter;

%__________OPTIMIZATION ROUTINE: FIND BEST FIT____________________________

% Perform regular 1st order DIC, removing "Bad_Values" from the guess
n = 0;
[C_last, GRAD_last, HESS ] = C_First_Few_Split( q_1, Bad_Values );
optim_completed = false;

while optim_completed == false

    % Compute the next guess and update the values
    delta_q = HESS\(-GRAD_last);                     % Find the difference between q_k+1 and q_k
    q_1 = q_1 + delta_q;                             % q_k+1 = q_k + delta_q
    [C, GRAD, HESS] = C_First_Few_Split(q_1, Bad_Values);        % Compute new values

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

results = [q_1(1); q_1(2); q_1(3); q_1(4); q_1(5);  q_1(6); C_last];

end % function
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


% Digital Image Correlation: "NaN" value averaging
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  October 28, 2007
% Modified on: October 28, 2007


-----------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: NAN Value Averaging        |
-----------------------------------------------------------

The following function will be called whenever the subset splitting method
splits a subset across the center pixel. In this situation, the program should
not look for a displacements because either half of the subset could represent
a valid displacement. Therefore, this function will look at the results around 
such a point and average the displacement to get a valid numerical value.
%}

function [DEFORMATION_PARAMETERS, good_corr] = NaN_Value_Averaging(good_corr, DEFORMATION_PARAMETERS)

% Store the size of good_corr, to see the limits of ii and jj.
[j_max, i_max] = size(good_corr);

% Find all the "NaN" displacements in DEFORMATION_PARAMETERS
[j_nan, i_nan] = find(isnan(DEFORMATION_PARAMETERS(:,:,1)));

% The number of points with NaN found
num_nan_points = length(i_nan);

% Start looping through all the points to average everything at once
for counter = 1:num_nan_points
    
    % Create a temporary storage value that will be used to find the average
    % And a counter to see how many numbers were added.
    tmp_value = 0;
    N = 0;
    
    % Store the matrix coordinates of the current "NaN" point being worked on
    ii = i_nan(counter);
    jj = j_nan(counter);
    
    % Make sure that we are not near a boundary and that the nearby value was a
    % good correlation. If these two conditions are met, then add to the
    % averaging value.

    % Check the solution one subset up.
    if jj ~= 1
        jj_up = jj - 1;
        if good_corr(jj_up, ii) == 1
            tmp_value = tmp_value + DEFORMATION_PARAMETERS(jj_up,ii, :);
            N = N + 1;
        end
    end

    % Check the solution one subset left.
    if ii ~= 1
        ii_left = ii - 1;
        if good_corr(jj, ii_left) == 1
            tmp_value = tmp_value + DEFORMATION_PARAMETERS(jj,ii_left, :);
            N = N + 1;
        end
    end

    % Check the solution one subset down.
    if jj ~= j_max
        jj_down = jj + 1;
        if good_corr(jj_down, ii) == 1
            tmp_value = tmp_value + DEFORMATION_PARAMETERS(jj_down,ii, :);
            N = N + 1;
        end
    end

    % Check the solution one subset right.
    if ii ~= i_max
        ii_right = ii + 1;
        if good_corr(jj, ii_right) == 1
            tmp_value = tmp_value + DEFORMATION_PARAMETERS(jj,ii_right, :);
            N = N + 1;
        end
    end

    % Check the solution up-left.
    if ii ~= 1 && jj ~= 1
        if good_corr(jj_up, ii_left) == 1
            tmp_value = tmp_value + DEFORMATION_PARAMETERS(jj_up, ii_left, :);
            N = N + 1;
        end
    end

    % Check the solution up-right.
    if ii ~= i_max && jj ~= 1
        if good_corr(jj_up, ii_right) == 1
            tmp_value = tmp_value + DEFORMATION_PARAMETERS(jj_up, ii_right, :);
            N = N + 1;
        end
    end

    % Check the solution down-left.
    if ii ~= 1 && jj ~= j_max
        if good_corr(jj_down, ii_left) == 1
            tmp_value = tmp_value + DEFORMATION_PARAMETERS(jj_down, ii_left, :);
            N = N + 1;
        end
    end

    % Check the solution down-right.
    if ii ~= i_max && jj ~= j_max
        if good_corr(jj_down, ii_right) == 1
            tmp_value = tmp_value + DEFORMATION_PARAMETERS(jj_down, ii_right, :);
            N = N + 1;
        end
    end
    
    % Divide by the total number of additions made to get the average.
    DEFORMATION_PARAMETERS(jj, ii, :) = tmp_value./N;
    
    % good_corr(jj, ii) = 1;
    
end


end % function

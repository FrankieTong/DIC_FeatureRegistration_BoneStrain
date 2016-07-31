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


% Digital Image Correlation: Finding the best initial guess
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  August 30, 2007
% Modified on: August 30, 2007


------------------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: BEST INITIAL GUESS, SPLITTING     |
------------------------------------------------------------------

The following function will determine where the best initial guess 
for subset splitting can be found based on the results of correlation.
%}

function q = Initial_Guess_Good(good_corr, ii, jj, DEFORMATION_PARAMETERS)

% Store the size of good_corr, to see the limits of ii and jj.
[j_max, i_max] = size(good_corr);

% Start by assuming that all the C values are bad (i.e. = 1)
C(1:8) = 1;

% Make sure that we are not near a boundary and that the nearby value was a
% good correlation. If these two conditions are met, then store the "C"
% value for later comparison.

% Check the solution one subset up.
if jj ~= 1
    jj_up = jj - 1;
    if good_corr(jj_up, ii) == 1 || good_corr(jj_up, ii) == 0.5 || good_corr(jj_up, ii) > 0
        C(1) = 1 - DEFORMATION_PARAMETERS(jj_up,ii,end);
    end
end

% Check the solution one subset left.
if ii ~= 1
    ii_left = ii - 1;
    if good_corr(jj, ii_left) == 1 || good_corr(jj, ii_left) == 0.5 || good_corr(jj, ii_left) > 0
        C(2) = 1 - DEFORMATION_PARAMETERS(jj,ii_left,end);
    end
end

% Check the solution one subset down.
if jj ~= j_max
    jj_down = jj + 1;
    if good_corr(jj_down, ii) == 1 || good_corr(jj_down, ii) == 0.5 || good_corr(jj_down, ii) > 0
        C(3) = 1 - DEFORMATION_PARAMETERS(jj_down,ii,end);
    end
end

% Check the solution one subset right.
if ii ~= i_max
    ii_right = ii + 1;
    if good_corr(jj, ii_right) == 1 || good_corr(jj, ii_right) == 0.5 || good_corr(jj, ii_right) > 0
        C(4) = 1 - DEFORMATION_PARAMETERS(jj,ii_right,end);
    end
end

% Check the solution up-left.
if ii ~= 1 && jj ~= 1
    if good_corr(jj_up, ii_left) == 1 || good_corr(jj_up, ii_left) == 0.5 || good_corr(jj_up, ii_left) > 0
        C(5) = 1 - DEFORMATION_PARAMETERS(jj_up, ii_left, end);
    end
end

% Check the solution up-right.
if ii ~= i_max && jj ~= 1
    if good_corr(jj_up, ii_right) == 1 || good_corr(jj_up, ii_right) == 0.5 || good_corr(jj_up, ii_right) > 0
        C(6) = 1 - DEFORMATION_PARAMETERS(jj_up, ii_right, end);
    end
end

% Check the solution down-left.
if ii ~= 1 && jj ~= j_max
    if good_corr(jj_down, ii_left) == 1 || good_corr(jj_down, ii_left) == 0.5 || good_corr(jj_down, ii_left) > 0
        C(7) = 1 - DEFORMATION_PARAMETERS(jj_down, ii_left, end);
    end
end

% Check the solution down-right.
if ii ~= i_max && jj ~= j_max
    if good_corr(jj_down, ii_right) == 1 || good_corr(jj_down, ii_right) == 0.5 || good_corr(jj_down, ii_right) > 0
        C(8) = 1 - DEFORMATION_PARAMETERS(jj_down, ii_right, end);
    end
end


% Make sure that at least one point was valid, otherwise look further away.
if any(C ~= 1)
    % Now search at the valid positions to see if there is a well correlated solution
    [minC, index] = min(C);
else
    index = 9;
end

switch index
    case 1
        q(1:6,1) = DEFORMATION_PARAMETERS(jj_up,   ii,         1:6);
    case 2
        q(1:6,1) = DEFORMATION_PARAMETERS(jj,      ii_left,    1:6);
    case 3
        q(1:6,1) = DEFORMATION_PARAMETERS(jj_down, ii,         1:6);
    case 4
        q(1:6,1) = DEFORMATION_PARAMETERS(jj,      ii_right,   1:6);
    case 5
        q(1:6,1) = DEFORMATION_PARAMETERS(jj_up,   ii_left,    1:6);
    case 6
        q(1:6,1) = DEFORMATION_PARAMETERS(jj_up,   ii_right,   1:6);
    case 7
        q(1:6,1) = DEFORMATION_PARAMETERS(jj_down, ii_left,    1:6);
    case 8
        q(1:6,1) = DEFORMATION_PARAMETERS(jj_down, ii_right,   1:6);
    case 9
        % We need to look further, the nearby points are no good. Probably
        % because some points were removed.
        % Check the solution two subsets up.
        if jj > 2
            jj_up_2 = jj - 2;
            if good_corr(jj_up_2, ii) == 1 || good_corr(jj_up_2, ii) == 0.5 || good_corr(jj_up_2, ii) > 0
                C(1) = 1 - DEFORMATION_PARAMETERS(jj_up_2,ii,end);
            end
        end

        % Check the solution two subsets left.
        if ii > 2
            ii_left_2 = ii - 2;
            if good_corr(jj, ii_left_2) == 1 || good_corr(jj, ii_left_2) == 0.5 || good_corr(jj, ii_left_2) > 0
                C(2) = 1 - DEFORMATION_PARAMETERS(jj,ii_left_2,end);
            end
        end

        % Check the solution two subsets right.
        if ii < i_max-1
            ii_right_2 = ii + 2;
            if good_corr(jj, ii_right_2) == 1 || good_corr(jj, ii_right_2) == 0.5 || good_corr(jj, ii_right_2) > 0
                C(3) = 1 - DEFORMATION_PARAMETERS(jj,ii_right_2,end);
            end
        end
        
        [minC, index] = min(C);
        switch index
            case 1
                q(1:6,1) = DEFORMATION_PARAMETERS(jj_up_2,   ii,         1:6);
            case 2
                q(1:6,1) = DEFORMATION_PARAMETERS(jj,      ii_left_2,    1:6);
            case 3
                q(1:6,1) = DEFORMATION_PARAMETERS(jj,      ii_right_2,   1:6);
        end
        
end
        
    
end % function




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


% Digital Image Correlation: Finding good initial guess for Bad section
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  November 12, 2007
% Modified on: November 12, 2007


------------------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: INITIAL GUESS FOR BAD SECTION     |
------------------------------------------------------------------

The following function will determine a reasonable initial guess for the 
bad section of the splitting subset, based on the slope of the splitting line.
%}

function q_0_B = Initial_Guess_Bad(good_corr, ii, jj, DEFORMATION_PARAMETERS, bad_up_or_down, a_new )

global subset_size;


% Initialize some important variables
jj_test = jj;
ii_test = ii;
[size_m, size_n] = size(good_corr);
intial_guess_found = false;

counter = 0;

% First, find out if the bad_section is above or below the splitting line
switch bad_up_or_down
    
    case 'up' % Assuming it is above...
        
        if roundn(a_new,-2) == 0 % ... and the splitting line is mostly horizontal
            
            while intial_guess_found == false % keep checking upwards until a good value is found
                jj_test = jj_test - 1; 
                if jj_test < 1
                    jj_test = 0;
                end
                if jj_test > 0
                    if good_corr(jj_test, ii_test) == 1 % until a good value is found
                        jj_found = jj_test;
                        ii_found = ii_test;
                        intial_guess_found = true;
                    end
                else
                    q_0_B = zeros(6,1);
                    return;
                end
            end
        
        elseif abs(a_new) > subset_size % ... and the splitting line is mostly vertical
            
            while intial_guess_found == false % keep looking to the...
                
                if a_new > 0 % ... right if the line is like this \
                    ii_test = ii_test + 1;
                    if ii_test > size_n
                        ii_test = size_n+1;
                    end
                else         % ... left if the line is like this /
                    ii_test = ii_test - 1;
                    if ii_test < 1
                        ii_test = 0;
                    end
                end
                if ii_test > 0 && ii_test < size_n+1
                    if good_corr(jj_test, ii_test) == 1 % until a good value is found
                        jj_found = jj_test;
                        ii_found = ii_test;
                        intial_guess_found = true;
                    end
                else
                    q_0_B = zeros(6,1);
                    return;
                end
            end
        
        else % ... and the splitting line is between horizontal and vertical
            
            % Find the angle between the horizontal and the normal of the
            % direction of the splitting line
            theta = atan(-1/a_new);
            i_iter = cos(theta); % while searching, x values will change by this much
            j_iter = abs(sin(theta)); % while searching, y values will change by this much
            
            while intial_guess_found == false % keep looking...
                if a_new > 0                  % up and to the right for a line like this \
                    ii_test = ii_test + i_iter;
                    jj_test = jj_test - j_iter;
                    if round(ii_test) > size_n
                        ii_test = size_n;
                    end
                    if round(jj_test) <= 0
                        jj_test = 1;
                    end
                else                        % up and to the left for a line like this /
                    ii_test = ii_test - i_iter;
                    jj_test = jj_test - j_iter;
                    if round(ii_test) <= 0
                        ii_test = 1;
                    end
                    if round(jj_test) <= 0
                        jj_test = 1;
                    end
                end
                if (round(ii_test) ~= 1 || round(ii_test) ~= size_n) && (round(jj_test) ~= 1 || round(jj_test) ~= size_m)
                    if good_corr(round(jj_test), round(ii_test)) == 1 % until a good value is found
                        jj_found = jj_test;
                        ii_found = ii_test;
                        intial_guess_found = true;
                    end
                else
                    q_0_B = zeros(6,1);
                    return;
                end % if
                
                counter = counter + 1;
                
                if counter > 50
                    fprintf(1,'there may be a problem\n\n');
                end
            end % while initial_guess_found
        end


    % Assuming it is below...
    case 'down'
        
        if roundn(a_new,-2) == 0 % ... and the splitting line is mostly horizontal
            
            while intial_guess_found == false % keep checking downwards until a good value is found
                jj_test = jj_test + 1;
                if jj_test > size_m
                        jj_test = size_m+1;
                end
                if jj_test < size_m+1
                    if good_corr(jj_test, ii_test) == 1 % until a good value is found
                        jj_found = jj_test;
                        ii_found = ii_test;
                        intial_guess_found = true;
                    end
                else
                    q_0_B = zeros(6,1);
                    return;
                end
            end
         
         elseif abs(a_new) > subset_size % ... and the splitting line is mostly vertical
             
            while intial_guess_found == false % keep looking to the...
                
                if a_new > 0                 % ... left if the line is like this \
                    ii_test = ii_test - 1;
                    if ii_test < 1
                        ii_test = 0;
                    end
                else                         % ... left if the line is like this /
                    ii_test = ii_test + 1;
                    if ii_test > size_n
                        ii_test = size_n+1;
                    end
                end
                if ii_test > 0 && ii_test < size_n+1
                    if good_corr(jj_test, ii_test) == 1 % until a good value is found
                        jj_found = jj_test;
                        ii_found = ii_test;
                        intial_guess_found = true;
                    end
                else
                    q_0_B = zeros(6,1);
                    return;
                end
            end
        
        else % ... and the splitting line is between horizontal and vertical
            
            % Find the angle between the horizontal and the normal of the
            % direction of the splitting line
            theta = atan(-1/a_new);
            i_iter = cos(theta); % while searching, x values will change by this much
            j_iter = abs(sin(theta)); % while searching, y values will change by this much
            
            countter = 0;
            
            while intial_guess_found == false % keep looking...
                
                if a_new > 0                    % down and to the left for a line like this \
                    ii_test = ii_test - i_iter;
                    jj_test = jj_test + j_iter;
                    if round(ii_test) <= 0
                        ii_test = 1;
                    end
                    if round(jj_test) > size_m
                        jj_test = size_m;
                    end
                else                            % down and to the right for a line like this /
                    ii_test = ii_test + i_iter;
                    jj_test = jj_test + j_iter;
                    if round(ii_test) > size_n
                        ii_test = size_n;
                    end
                    if round(jj_test) > size_m
                        jj_test = size_m;
                    end
                end
                if (round(ii_test) ~= 1 || round(ii_test) ~= size_n) && (round(jj_test) ~= 1 || round(jj_test) ~= size_m)
                    if good_corr(round(jj_test), round(ii_test)) == 1 % until a good value is found
                        jj_found = jj_test;
                        ii_found = ii_test;
                        intial_guess_found = true;
                    end
                else
                    q_0_B = zeros(6,1);
                    return;
                end
                
                countter = countter + 1;
                
                if countter >= 1000
                    q_0_B = zeros(6,1);
                    return;
                end
                
             end % while
        end
    otherwise
        q_0_B = zeros(6,1);
        return;
end

% Having found the best initial guess, store it as the answer
q_0_B(1:6,1) = DEFORMATION_PARAMETERS(round(jj_found), round(ii_found), 1:6);

end % function
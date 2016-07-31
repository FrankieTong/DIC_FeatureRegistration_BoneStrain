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


% Digital Image Correlation: Max-Min Filter
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  Novemeber 1, 2007
% Modified on: Novemeber 1, 2007


-----------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: Max-Min Filter             |
-----------------------------------------------------------

The following function will be called to filter the Bad_Values matrix and fill in any gaps.
%}

function Bad_Values = Max_Min_filter(Bad_Values, subset_size, max_or_min)


if isequal(max_or_min, 'max') == true
    
    % All values touching a "1" are turned into "1".
    [row_ind, col_ind] = find(Bad_Values);
    
    for iter = 1:length(row_ind)
        jj = row_ind(iter);
        ii = col_ind(iter);
        
        position(:,1) = 1:8;
        
        if ii == 1
            position(1) = 0;
            position(4) = 0;
            position(6) = 0;
        elseif ii == subset_size
            position(3) = 0;
            position(5) = 0;
            position(8) = 0;
        end
        
        if jj == 1
            position(1) = 0;
            position(2) = 0;
            position(3) = 0;
        elseif jj == subset_size
            position(6) = 0;
            position(7) = 0;
            position(8) = 0;
        end
        
        for pos_iter = 1:8
            switch position(pos_iter)
                case 1
                    Bad_Values(jj-1,ii-1) = 1;
                case 2
                    Bad_Values(jj-1,ii) = 1;
                case 3
                    Bad_Values(jj-1,ii+1) = 1;
                case 4
                    Bad_Values(jj,ii-1) = 1;
                case 5
                    Bad_Values(jj,ii+1) = 1;
                case 6
                    Bad_Values(jj+1,ii-1) = 1;
                case 7
                    Bad_Values(jj+1,ii) = 1;
                case 8
                    Bad_Values(jj+1,ii+1) = 1;
                otherwise
                    % Do Nothing
            end % end switch
        end % end for pos_iter
    end % end for iter
    
elseif isequal(max_or_min, 'min') == true
    
    % All values touching a "0" are turned into "0".
    [row_ind, col_ind] = find(~Bad_Values);
    
    for iter = 1:length(row_ind)
        jj = row_ind(iter);
        ii = col_ind(iter);
        
        position(:,1) = 1:8;
        
        if ii == 1
            position(1) = 0;
            position(4) = 0;
            position(6) = 0;
        elseif ii == subset_size
            position(3) = 0;
            position(5) = 0;
            position(8) = 0;
        end
        
        if jj == 1
            position(1) = 0;
            position(2) = 0;
            position(3) = 0;
        elseif jj == subset_size
            position(6) = 0;
            position(7) = 0;
            position(8) = 0;
        end
        
        for pos_iter = 1:8
            switch position(pos_iter)
                case 1
                    Bad_Values(jj-1,ii-1) = 0;
                case 2
                    Bad_Values(jj-1,ii) = 0;
                case 3
                    Bad_Values(jj-1,ii+1) = 0;
                case 4
                    Bad_Values(jj,ii-1) = 0;
                case 5
                    Bad_Values(jj,ii+1) = 0;
                case 6
                    Bad_Values(jj+1,ii-1) = 0;
                case 7
                    Bad_Values(jj+1,ii) = 0;
                case 8
                    Bad_Values(jj+1,ii+1) = 0;
                otherwise
                    % Do Nothing
            end % end switch
        end % end for pos_iter
    end % end for iter
    
end % if


return;
end % function
    
        
            
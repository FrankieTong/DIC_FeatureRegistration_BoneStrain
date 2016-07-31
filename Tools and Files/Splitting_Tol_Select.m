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


% Digital Image Correlation: Subset Splitting Tolerance Selector
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  October 29, 2007
% Modified on: February 12, 2008


------------------------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: Subset Splitting Tolerance Selector     |
------------------------------------------------------------------------

This function will display the results of normal DIC before going on to 
subset splitting. Here the user can choose tolerances for subset splitting.

%}

function Selected_Subsets = Splitting_Tol_Select(mesh_col, mesh_row, DEFORMATION_PARAMETERS, split_tol, i_j_region)

% Create a grid to represent the subset centers of the current correlation
[X_def_grid, Y_def_grid] = meshgrid( mesh_col, mesh_row );



% Check the value of split_tol... if it's empty, less than or equal to zero or 
% greater than or equal to 1, ask the user on the spot for a splitting tolerance 
% by showing them the displacements and correlation quality.
if isempty(split_tol) == true || split_tol <= 0 || split_tol >= 1 

    
    % Plot the displacements u, v, and C from basic DIC to see where subset splitting needs to occur.

    % Plotting options for U
    H_u = figure('Units', 'normalized');
    Pos_u = get(H_u, 'Position');
    set(H_u, 'Position', [0.04,0.04,Pos_u(3), Pos_u(4)]);
    surf(X_def_grid, Y_def_grid, DEFORMATION_PARAMETERS(:,:,1), 'LineStyle', 'none');
    s_tmp = sprintf('u displacement');
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([X_def_grid(1,1), X_def_grid(end,end)]);    ylim([Y_def_grid(1,1), Y_def_grid(end,end)]);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);

    % Plotting options for V
    H_v = figure('Units', 'normalized');
    Pos_v = get(H_u, 'Position');
    set(H_v, 'Position', [0.04,0.54,Pos_v(3), Pos_v(4)]);surf(X_def_grid, Y_def_grid, DEFORMATION_PARAMETERS(:,:,2), 'LineStyle', 'none');
    s_tmp = sprintf('v displacement');
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([X_def_grid(1,1), X_def_grid(end,end)]);    ylim([Y_def_grid(1,1), Y_def_grid(end,end)]);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);

    % Plotting options for C
    H_c = figure('Units', 'normalized');
    Pos_c = get(H_c, 'Position');
    set(H_c, 'Position', [0.54,0.54,Pos_c(3), Pos_c(4)]); surf(X_def_grid, Y_def_grid, DEFORMATION_PARAMETERS(:,:,end), 'LineStyle', 'none');
    s_tmp = sprintf('Correlation Quality');
    view(0,90);     title(s_tmp, 'FontName', 'Arial', 'FontSize', 14, 'FontAngle', 'italic');        colorbar;
    xlim([X_def_grid(1,1), X_def_grid(end,end)]);    ylim([Y_def_grid(1,1), Y_def_grid(end,end)]);
    set(gca,'XAxisLocation', 'top', 'YDir', 'reverse', 'FontName', 'Palatino Linotype', 'FontSize', 13, 'DataAspectRatio', [10000 10000 1]);

    % Instructions for choosing a subset splitting tolerance
    fprintf(1, strcat('\nRefer to the correlation quality to decide what points must be subset split\n', ...
                      'When a tolerance has been chosen, press any key to continue\n\n') );

    % This pause statement will allow the above plots to load completly. Otherwise, they stay as empty windows.
    pause;      

    % Instructions for inputting a subset splitting tolerance
    fprintf(1, strcat('\nPlease Input the Splitting Tolerance\n') );
    split_tol = input('Splitting Tolerance = ');

    
else
    
    % The value stored within split_tol, is the tolerance
    
end
    
% This first if statement is a fail safe in case the user doesn't input a
% valid number for the subset spitting tolerance.
if isempty(split_tol) == true || isnumeric(split_tol) == false
    % Try closing the plots from above, don't crash if the user closed them
    % before reaching this point
    try
        close(H_u);
    catch
    end
    try
        close(H_v);
    catch
    end
    try
        close(H_c);
    catch
    end
    % Return an empty Selected_Subsets variable.
    Selected_Subsets = [];
    return;
else
    % Try closing the plots from above, don't crash if the user closed them
    % before reaching this point
    try
        close(H_u);
    catch
    end
    try
        close(H_v);
    catch
    end
    try
        close(H_c);
    catch
    end

    % Start by setting all the points that DO NOT need to be split to 1
    Selected_Subsets.good_corr = double( DEFORMATION_PARAMETERS(:,:,end) > split_tol );
    
    
    % Ignore points outside the designated subset splitting region
    [m,n] = size( DEFORMATION_PARAMETERS(:,:,end) );
    
    % If the i_j_region parameter was created correctly, use it to define
    % a rectangular region where subset splitting should take place (i.e.
    % everything around it should be set it 1).
    if isempty(i_j_region) == false && isnumeric(split_tol) == true
        if all(all(i_j_region > 0)) && all(i_j_region(:,1) <= n) && all(i_j_region(:,2) <= m)
            Selected_Subsets.good_corr(1:i_j_region(1,2), :) = 1;
            Selected_Subsets.good_corr(i_j_region(2,2):end, :) = 1;

            Selected_Subsets.good_corr(:, 1:i_j_region(1,1)) = 1;
            Selected_Subsets.good_corr(:, i_j_region(2,1):end) = 1;
        end
    end
    %{
    iii = 0;
    jjj = 0;
    
    for iii = 1:x_high
        for jjj = y_low:201
            
            if jjj >= (-65/99)*iii+(150.656565656565) && jjj <= (-80/114)*iii+(190.7017544) && Selected_Subsets.good_corr(jjj,iii) == false
                Selected_Subsets.good_corr(jjj,iii) = false;
            else
                Selected_Subsets.good_corr(jjj,iii) = true;
            end
                        
        end
    end
    
    
    %}
    % If the entire result is good, subset splitting is not needed.
    if all(all(Selected_Subsets.good_corr)) == true
        
        % Return an empty Selected_Subsets variable.
        Selected_Subsets = [];
        return;
        
    else % Otherwise, if there is at least 1 point to subset split...
        
        % "Snake through" the values to find the points going into subset splitting.
        
        % Start by initializing values that are needed in the upcoming loop
        ii = 1;
        jj = 1;
        num_subsets_X = floor( (X_def_grid(end,end)-X_def_grid(1,1))/(X_def_grid(1,2)-X_def_grid(1,1)) ) + 1;
        iter = 1;

        % New loop that will process the subset splitting points in the
        % following order: The furtherest points from the crack inwards
        % towards the crack. That way, "bad points" found near the crack
        % face should not affect results as severly.
        tmp_good_corr = Selected_Subsets.good_corr; % This matrix holds the current iteration's good_corr
        mod_good_corr = Selected_Subsets.good_corr; % This matrix will be modified when points are found
        
        while (all(all(tmp_good_corr)) == false)
                    
            % Reset the loop iterators
            ii = 1;
            jj = 1;
            
            % Loop through all the points in 'good_corr' and find the zeros by "snaking"
            % This loop is used to ensure that the zeros in 'good_corr' are captured in the
            % same order as the points being processed in standard DIC.
            for counter = 1:numel(Selected_Subsets.good_corr)

                % If it's a zero and there are good answers nearby, store information about the point and iterate "iter"
                if (tmp_good_corr(jj,ii) == false) && (Has_Good_Answers_Nearby(ii, jj, tmp_good_corr) == true)
                    
                    Selected_Subsets.IIsplit(iter,1) = ii;
                    Selected_Subsets.JJsplit(iter,1) = jj;
                    Selected_Subsets.Xsplit(iter,1) = X_def_grid(jj,ii);
                    Selected_Subsets.Ysplit(iter,1) = Y_def_grid(jj,ii);
                    Selected_Subsets.cnt_split(iter,1) = counter;
                    iter = iter + 1;
                    mod_good_corr(jj,ii) = 1;
                end

                % Iterate the ii and jj values for "snaking"
                ii = ii + (-1).^(mod(jj,2)+1);
                if ( mod(counter,num_subsets_X) == 0 )
                    ii = ii - (-1).^(mod(jj,2)+1);
                    jj = jj + 1;
                end
            end % for
            
            tmp_good_corr = mod_good_corr;
            
        end % while
        
        %{
        % Loop through all the points in 'good_corr' and find the zeros by "snaking"
        % This loop is used to ensure that the zeros in 'good_corr' are captured in the
        % same order as the points being processed in standard DIC.
        for counter = 1:numel(Selected_Subsets.good_corr)

            % If it's a zero, store information about the point and iterate "iter"
            if Selected_Subsets.good_corr(jj,ii) == false
                Selected_Subsets.IIsplit(iter,1) = ii;
                Selected_Subsets.JJsplit(iter,1) = jj;
                Selected_Subsets.Xsplit(iter,1) = X_def_grid(jj,ii);
                Selected_Subsets.Ysplit(iter,1) = Y_def_grid(jj,ii);
                Selected_Subsets.cnt_split(iter,1) = counter;
                iter = iter + 1;
            end

            % Iterate the ii and jj values for "snaking"
            ii = ii + (-1).^(mod(jj,2)+1);
            if ( mod(counter,num_subsets_X) == 0 )
                ii = ii - (-1).^(mod(jj,2)+1);
                jj = jj + 1;
            end
        end % for
        %}

        % Save the splitting tolerance
        Selected_Subsets.split_tol = split_tol;

        % Save the number of subsets that need to be split
        Selected_Subsets.num_subsets_split = length(Selected_Subsets.Xsplit);

    end % if there's at least one point that needs subset splitting
    
end % if split_tol is an invalid quantity



return;
end % function


function good_answers_found = Has_Good_Answers_Nearby(ii, jj, good_corr)

[m,n] = size(good_corr);
good_subset_counter = 0;

% Check the subset in the top-left
if ii ~= 1 && jj ~= 1
    good_subset_counter = good_subset_counter + good_corr(jj-1,ii-1);
end

% Check the subset on the left
if ii ~= 1
    good_subset_counter = good_subset_counter + good_corr(jj,ii-1);
end

% Check the subset on the bottom-left
if ii ~= 1 && jj ~= m
    good_subset_counter = good_subset_counter + good_corr(jj+1,ii-1);
end

% Check the subset on the top
if jj ~= 1
    good_subset_counter = good_subset_counter + good_corr(jj-1,ii);
end

% Check the subset on the bottom
if jj ~= m
    good_subset_counter = good_subset_counter + good_corr(jj+1,ii);
end

% Check the subset in the top-right
if ii ~= n && jj ~= 1
    good_subset_counter = good_subset_counter + good_corr(jj-1,ii+1);
end

% Check the subset on the right
if ii ~= n
    good_subset_counter = good_subset_counter + good_corr(jj,ii+1);
end

% Check the subset on the bottom-right
if ii ~= n && jj ~= m
    good_subset_counter = good_subset_counter + good_corr(jj+1,ii+1);
end



if good_subset_counter >= 2
    good_answers_found = true;
else
    good_answers_found = false;
end

return;
end % function

%{
This script displays the plots and images that are generated when running the main DIC_Scripting_for_Feature_Registration.m script. Useful for retirving these plots from a saved workspace.

%}

if Skeletonization_Only == false
    %% Statistics for DVC raw data

	%% Setup to ploting displacement and strain values of DVC
	
    % last_WS.mesh_col(i) = X grid value
    % last_WS.mesh_row(j) = y grid value
    % last_WS.DEFORMATION_PARAMETERS(j,i,1) = deformation x value in grid
    % last_WS.DEFORMATION_PARAMETERS(j,1,2) = deformation y value in grid

    % Generate a list of feature points and their corresponding displacement
    % vectors based on the DVC results
	fixed_points_DVC = [];
	displacement_DVC = [];
	fixed_points_xx_DVC = [];
	fixed_points_yy_DVC = [];
	strain_xx_DVC = [];
	strain_yy_DVC = [];

	% Get DVC displacement and fixed point locations
	for i = 1:length(last_WS.mesh_col)
		for j = 1:length(last_WS.mesh_row)
			fixed_points_DVC = [fixed_points_DVC; last_WS.mesh_col(i) last_WS.mesh_row(j)];
			displacement_DVC = [displacement_DVC; last_WS.DEFORMATION_PARAMETERS(j,i,1) last_WS.DEFORMATION_PARAMETERS(j,i,2)];
		end
	end

	% Get DVC fixed point locations for calculated strain values (values lie inbetween image grid points)
	strain_x_coordinates_EPSxx = strains_DVC_Xgrids{3}(1,:);
	strain_y_coordinates_EPSxx = strains_DVC_Ygrids{3}(:,1)';

	strain_x_coordinates_EPSyy = strains_DVC_Xgrids{4}(1,:);
	strain_y_coordinates_EPSyy = strains_DVC_Ygrids{4}(:,1)';

	for i = 1:length(strain_x_coordinates_EPSxx)
		for j = 1:length(strain_y_coordinates_EPSxx)
			fixed_points_xx_DVC = [fixed_points_xx_DVC; strain_x_coordinates_EPSxx(i) strain_y_coordinates_EPSxx(j)];
			strain_xx_DVC = [strain_xx_DVC; strains_DVC{4}(j,i)];
		end
	end

	for i = 1:length(strain_x_coordinates_EPSyy)
		for j = 1:length(strain_y_coordinates_EPSyy)
			fixed_points_yy_DVC = [fixed_points_yy_DVC; strain_x_coordinates_EPSyy(i) strain_y_coordinates_EPSyy(j)];
			strain_yy_DVC = [strain_yy_DVC; strains_DVC{5}(j,i)];
		end
	end

    % Convert the current values measured in pixel locations back to real space
    for i_m = 1:size(fixed_points_DVC,1)
        fixed_points_DVC(i_m,:) = ((fixed_points_DVC(i_m,:) - ones(1,size(fixed_points_DVC,2))) .* SpacingSize + Origin);
    end
    for i_m = 1:size(displacement_DVC,1)
        displacement_DVC(i_m,:) = displacement_DVC(i_m,:) .* SpacingSize;
    end
    for i_m = 1:size(fixed_points_xx_DVC,1)
        fixed_points_xx_DVC(i_m,:) = ((fixed_points_xx_DVC(i_m,:) - ones(1,size(fixed_points_xx_DVC,2))) .* SpacingSize + Origin);
    end
    for i_m = 1:size(fixed_points_yy_DVC,1)
        fixed_points_yy_DVC(i_m,:) = ((fixed_points_yy_DVC(i_m,:) - ones(1,size(fixed_points_yy_DVC,2))) .* SpacingSize + Origin);
    end



    %% Create images for viewing DVC results
    Skeletonization_Display_Figure(fixed_image, Origin, SpacingSize, DimensionSize, 'Fixed Image with Matched Feature Points for DVC');
    Skeletonization_Add_Points(fixed_points_DVC, 10.5, 'r.');

    Skeletonization_Display_Figure(fixed_image, Origin, SpacingSize, DimensionSize, 'Fixed Image with Matched Feature Point Vectors for DVC');
    Skeletonization_Add_Points(fixed_points_DVC, 10.5, 'r.');
    Skeletonization_Add_Vectors(fixed_points_DVC, displacement_DVC, 10.5, 'y');
    
    Skeletonization_Display_Figure(fixed_image, Origin, SpacingSize, DimensionSize, 'Fixed Image with Matched Feature Point Vectors for DVC');
    Skeletonization_Add_Points(fixed_points_DVC, 10.5, 'r.');
    Skeletonization_Add_Vectors(fixed_points_DVC, displacement_DVC, 10.5, 'y');
    Skeletonization_Add_Index_At_Points(fixed_points_DVC, 10, 'r')
    
    Skeletonization_Display_Figure(fixed_image, Origin, SpacingSize, DimensionSize, 'Fixed Image with Scaled Matched Feature Point Vectors for DVC');
    Skeletonization_Add_Points(fixed_points_DVC, 10.5, 'r.');
    Skeletonization_Add_Vectors_Scaled(fixed_points_DVC, displacement_DVC, 10.5, 'b');

    %% Plot DVC displacement and strain vs. location and vs. actual values 
    
	%% DVC displacement plots and statistics
	
	% Displacement actual vs position
    FarCorner = Origin + SpacingSize.*(DimensionSize-1);
    x_axis_limits = [Origin(ImageDimensionality), FarCorner(ImageDimensionality)];

    points = fixed_points_DVC(:,ImageDimensionality)';
    values = displacement_DVC(:,ImageDimensionality)';

    % Finds the ideal location at x = 0
    ideal_points_location = ones(100,ImageDimensionality);
    for i = 1:ImageDimensionality
        if i == ImageDimensionality
            ideal_points_location(:,i) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
        else
            ideal_points_location(:,i) = ideal_points_location(:,i).*(FarCorner(i) - Origin(i))/2;
        end
    end
    ideal_values_location = displacement_eq(ideal_points_location);

    ideal_points_array = ideal_points_location(:,ImageDimensionality);
    ideal_values_array = ideal_values_location(:,ImageDimensionality);

    title_str = 'Displacement Values (Calculated) vs. Y-Position for DVC';
    title_x_axis = 'Y-Position (um)';
    title_y_axis = 'Displacement Values (Calculated) (um)';

    Skeletonization_Display_Graphs(points, values, ideal_points_array, ideal_values_array, x_axis_limits, title_str, title_x_axis, title_y_axis)

    % Displacement actual vs displacement ideal
    FarCorner = Origin + SpacingSize.*(DimensionSize-1);

    ideal_points_wrt_nodal_points = displacement_eq(fixed_points_DVC);
    points = ideal_points_wrt_nodal_points(:,ImageDimensionality);
    values = displacement_DVC(:,ImageDimensionality);

    ideal_points_location = ones(100,ImageDimensionality);
    for i = 1:ImageDimensionality
        if i == ImageDimensionality
            ideal_points_location(:,i) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
        else
            ideal_points_location(:,i) = ideal_points_location(:,i).*(FarCorner(i) - Origin(i))/2;
        end
    end
    ideal_values_location = displacement_eq(ideal_points_location);

    ideal_points_array = ideal_values_location(:,ImageDimensionality);
    ideal_values_array = ideal_values_location(:,ImageDimensionality);

    x_axis_limits = [min(ideal_points_array) max(ideal_points_array)];

    title_str = 'Displacement Values (Calculated) vs. Displacement Values (Ideal) for DVC';
    title_x_axis = 'Displacement Values (Ideal) (um)';
    title_y_axis = 'Displacement Values (Calculated) (um)';

    Skeletonization_Display_Graphs(points, values, ideal_points_array, ideal_values_array, x_axis_limits, title_str, title_x_axis, title_y_axis)

    % Display R squared, offset and slope on plot
    [displacement_stats.r2, displacement_stats.offset, displacement_stats.slope] = Skeletonization_Linear_Model(points,values);

    dim = [0.2 0.5 0.3 0.3];
    str = {sprintf('r squared = %f', displacement_stats.r2),sprintf('offset = %f', displacement_stats.offset), sprintf('slope = %f', displacement_stats.slope)};
    annotation('textbox',dim,'String',str,'FitBoxToText','on');

    line = refline(displacement_stats.slope, displacement_stats.offset);
    line.Color = 'g';

    % Display displacement error statistics on plot
    [displacement_stats.mean_error, displacement_stats.std_deviation, displacement_stats.ten_percentile, displacement_stats.ninety_percentile, displacement_stats.directional_similarity, displacement_stats.difference_of_magnitude, displacement_stats.magnitude_of_difference] = Skeletonization_Error(points, values);

    dim = [0.5 0.1 0.3 0.3];
    str = {sprintf('mean error = %f', displacement_stats.mean_error),sprintf('std deviation = %f', displacement_stats.std_deviation), sprintf('10 percentile = %f', displacement_stats.ten_percentile) ...
                    ,sprintf('90 percentile = %f', displacement_stats.ninety_percentile), sprintf('directional similarity = %f', displacement_stats.directional_similarity), sprintf('difference of magnitude = %f', displacement_stats.difference_of_magnitude) ...
                        , sprintf('magnitude of difference = %f', displacement_stats.magnitude_of_difference)};
    annotation('textbox',dim,'String',str,'FitBoxToText','on');

	%% DVC strain plots and statistics

    % Strain actual vs strain ideal
    FarCorner = Origin + SpacingSize.*(DimensionSize-1);

    ideal_points_wrt_nodal_points = strain_eq(fixed_points_yy_DVC);
    points = ideal_points_wrt_nodal_points(:,ImageDimensionality);
    values = strain_yy_DVC;

    ideal_points_location = ones(100,ImageDimensionality);
    for i = 1:ImageDimensionality
        if i == ImageDimensionality
            ideal_points_location(:,i) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
        else
            ideal_points_location(:,i) = ideal_points_location(:,i).*(FarCorner(i) - Origin(i))/2;
        end
    end
    ideal_values_location = strain_eq(ideal_points_location);

    ideal_points_array = ideal_values_location(:,ImageDimensionality);
    ideal_values_array = ideal_values_location(:,ImageDimensionality);

    x_axis_limits = [min(ideal_points_array) max(ideal_points_array)];

    title_str = 'Strain Values (Calculated) vs. Strain Values (Ideal) for DVC';
    title_x_axis = 'Absolute Strain Values (Ideal)';
    title_y_axis = 'Absolute Strain Values (Calculated)';

    Skeletonization_Display_Graphs(points, values, ideal_points_array, ideal_values_array, x_axis_limits, title_str, title_x_axis, title_y_axis)

    % Display R squared, offset and slope on plot
    [strain_stats.r2, strain_stats.offset, strain_stats.slope] = Skeletonization_Linear_Model(points,values);

    dim = [0.2 0.5 0.3 0.3];
    str = {sprintf('r squared = %f', strain_stats.r2),sprintf('offset = %f', strain_stats.offset), sprintf('slope = %f', strain_stats.slope)};
    annotation('textbox',dim,'String',str,'FitBoxToText','on');

    line = refline(strain_stats.slope, strain_stats.offset);
    line.Color = 'g';

    % Display strain error statistics on plot
    [strain_stats.mean_error, strain_stats.std_deviation, strain_stats.ten_percentile, strain_stats.ninety_percentile, strain_stats.directional_similarity, strain_stats.difference_of_magnitude, strain_stats.magnitude_of_difference] = Skeletonization_Error(points, values);

    dim = [0.5 0.1 0.3 0.3];
    str = {sprintf('mean error = %f', strain_stats.mean_error),sprintf('std deviation = %f', strain_stats.std_deviation), sprintf('10 percentile = %f', strain_stats.ten_percentile) ...
                    ,sprintf('90 percentile = %f', strain_stats.ninety_percentile), sprintf('directional similarity = %f', strain_stats.directional_similarity), sprintf('difference of magnitude = %f', strain_stats.difference_of_magnitude) ...
                        , sprintf('magnitude of difference = %f', strain_stats.magnitude_of_difference)};
    annotation('textbox',dim,'String',str,'FitBoxToText','on');

end


if DVC_Only == false
	%% Statistics for Feature Registration using Meshless Methods

	%% Create images for viewing DVC results
    Skeletonization_Display_Figure(fixed_image, Origin, SpacingSize, DimensionSize, 'Fixed Image with Matched Feature Points for Feature Reg');
    Skeletonization_Add_Points(fixed_points_MLS, 10.5, 'r.');

    Skeletonization_Display_Figure(moving_image, Origin, SpacingSize, DimensionSize, 'Moving Image with Matched Feature Points for Feature Reg');
    Skeletonization_Add_Points(moving_points_MLS, 10.5, 'r.');

    Skeletonization_Display_Figure(fixed_image, Origin, SpacingSize, DimensionSize, 'Fixed Image with Matched Feature Point Vectors for Feature Reg');
    Skeletonization_Add_Points(fixed_points_MLS, 10.5, 'r.');
    Skeletonization_Add_Vectors(fixed_points_MLS, moving_points_MLS-fixed_points_MLS, 10.5, 'y');
    
    Skeletonization_Display_Figure(fixed_image, Origin, SpacingSize, DimensionSize, 'Fixed Image with Matched Feature Point Vectors for Feature Reg');
    Skeletonization_Add_Points(fixed_points_MLS, 10.5, 'r.');
    Skeletonization_Add_Vectors(fixed_points_MLS, moving_points_MLS-fixed_points_MLS, 10.5, 'y');
    Skeletonization_Add_Index_At_Points(fixed_points_MLS, 10, 'r')
    
    Skeletonization_Display_Figure(fixed_image, Origin, SpacingSize, DimensionSize, 'Fixed Image with Scaled Matched Feature Point Vectors for Feature Reg');
    Skeletonization_Add_Points(fixed_points_MLS, 10.5, 'r.');
    Skeletonization_Add_Vectors_Scaled(fixed_points_MLS, moving_points_MLS-fixed_points_MLS, 10.5, 'b');

    %% Plot feature registration displacement and strain vs. location and vs. actual values 
    
	%% Feature registration displacement plots and statistics

    % Displacement actual vs position
    FarCorner = Origin + SpacingSize.*(DimensionSize-1);
    x_axis_limits = [Origin(ImageDimensionality), FarCorner(ImageDimensionality)];

    points = fixed_points_MLS(:,ImageDimensionality)';
    values = displacement(:,ImageDimensionality)';

    ideal_points_location = ones(100,ImageDimensionality);
    for i = 1:ImageDimensionality
        if i == ImageDimensionality
            ideal_points_location(:,i) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
        else
            ideal_points_location(:,i) = ideal_points_location(:,i).*(FarCorner(i) - Origin(i))/2;
        end
    end
    ideal_values_location = displacement_eq(ideal_points_location);

    ideal_points_array = ideal_points_location(:,ImageDimensionality);
    ideal_values_array = ideal_values_location(:,ImageDimensionality);

    title_str = 'Displacement Values (Calculated) vs. Y-Position for Feature Reg';
    title_x_axis = 'Y-Position (um)';
    title_y_axis = 'Displacement Values (Calculated) (um)';

    Skeletonization_Display_Graphs(points, values, ideal_points_array, ideal_values_array, x_axis_limits, title_str, title_x_axis, title_y_axis)


    % Strain actual vs position on plot
    FarCorner = Origin + SpacingSize.*(DimensionSize-1);
    x_axis_limits = [Origin(ImageDimensionality), FarCorner(ImageDimensionality)];

    points = fixed_points_MLS(:,ImageDimensionality)';
    values = strain(:,ImageDimensionality)';

    ideal_points_location = ones(100,ImageDimensionality);
    for i = 1:ImageDimensionality
        if i == ImageDimensionality
            ideal_points_location(:,i) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
        else
            ideal_points_location(:,i) = ideal_points_location(:,i).*(FarCorner(i) - Origin(i))/2;
        end
    end
    ideal_values_location = strain_eq(ideal_points_location);

    ideal_points_array = ideal_points_location(:,ImageDimensionality);
    ideal_values_array = ideal_values_location(:,ImageDimensionality);

    title_str = 'Strain Values (Calculated) vs. Y-Position for Feature Reg';
    title_x_axis = 'Y-Position (um)';
    title_y_axis = 'Absolute Strain Values (Calculated)';

    Skeletonization_Display_Graphs(points, values, ideal_points_array, ideal_values_array, x_axis_limits, title_str, title_x_axis, title_y_axis)

    % Displacement actual vs displacement ideal
    FarCorner = Origin + SpacingSize.*(DimensionSize-1);

    ideal_points_wrt_nodal_points = displacement_eq(fixed_points_MLS);
    points = ideal_points_wrt_nodal_points(:,ImageDimensionality);
    values = displacement(:,ImageDimensionality);

    ideal_points_location = ones(100,ImageDimensionality);
    for i = 1:ImageDimensionality
        if i == ImageDimensionality
            ideal_points_location(:,i) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
        else
            ideal_points_location(:,i) = ideal_points_location(:,i).*(FarCorner(i) - Origin(i))/2;
        end
    end
    ideal_values_location = displacement_eq(ideal_points_location);

    ideal_points_array = ideal_values_location(:,ImageDimensionality);
    ideal_values_array = ideal_values_location(:,ImageDimensionality);

    x_axis_limits = [min(ideal_points_array) max(ideal_points_array)];

    title_str = 'Displacement Values (Calculated) vs. Displacement Values (Ideal) for Feature Reg';
    title_x_axis = 'Displacement Values (Ideal) (um)';
    title_y_axis = 'Displacement Values (Calculated) (um)';

    Skeletonization_Display_Graphs(points, values, ideal_points_array, ideal_values_array, x_axis_limits, title_str, title_x_axis, title_y_axis)

    % Display R squared, offset and slope on plot
    [displacement_stats.r2, displacement_stats.offset, displacement_stats.slope] = Skeletonization_Linear_Model(points,values);

    dim = [0.2 0.5 0.3 0.3];
    str = {sprintf('r squared = %f', displacement_stats.r2),sprintf('offset = %f', displacement_stats.offset), sprintf('slope = %f', displacement_stats.slope)};
    annotation('textbox',dim,'String',str,'FitBoxToText','on');

    line = refline(displacement_stats.slope, displacement_stats.offset);
    line.Color = 'g';

    % Display displacement error statistics on plot
    [displacement_stats.mean_error, displacement_stats.std_deviation, displacement_stats.ten_percentile, displacement_stats.ninety_percentile, displacement_stats.directional_similarity, displacement_stats.difference_of_magnitude, displacement_stats.magnitude_of_difference] = Skeletonization_Error(points, values);

    dim = [0.5 0.1 0.3 0.3];
    str = {sprintf('mean error = %f', displacement_stats.mean_error),sprintf('std deviation = %f', displacement_stats.std_deviation), sprintf('10 percentile = %f', displacement_stats.ten_percentile) ...
                    ,sprintf('90 percentile = %f', displacement_stats.ninety_percentile), sprintf('directional similarity = %f', displacement_stats.directional_similarity), sprintf('difference of magnitude = %f', displacement_stats.difference_of_magnitude) ...
                        , sprintf('magnitude of difference = %f', displacement_stats.magnitude_of_difference)};
    annotation('textbox',dim,'String',str,'FitBoxToText','on');

    %% Feature registration strain plots and statistics

    % Strain actual vs position
    FarCorner = Origin + SpacingSize.*(DimensionSize-1);

    ideal_points_wrt_nodal_points = strain_eq(fixed_points_MLS);
    points = ideal_points_wrt_nodal_points(:,ImageDimensionality);
    values = strain(:,ImageDimensionality);

    ideal_points_location = ones(100,ImageDimensionality);
    for i = 1:ImageDimensionality
        if i == ImageDimensionality
            ideal_points_location(:,i) = linspace(Origin(ImageDimensionality),FarCorner(ImageDimensionality),100)';
        else
            ideal_points_location(:,i) = ideal_points_location(:,i).*(FarCorner(i) - Origin(i))/2;
        end
    end
    ideal_values_location = strain_eq(ideal_points_location);

    ideal_points_array = ideal_values_location(:,ImageDimensionality);
    ideal_values_array = ideal_values_location(:,ImageDimensionality);

    x_axis_limits = [min(ideal_points_array) max(ideal_points_array)];

    title_str = 'Strain Values (Calculated) vs. Strain Values (Ideal) for Feature Reg';
    title_x_axis = 'Absolute Strain Values (Ideal)';
    title_y_axis = 'Absolute Strain Values (Calculated)';

    Skeletonization_Display_Graphs(points, values, ideal_points_array, ideal_values_array, x_axis_limits, title_str, title_x_axis, title_y_axis)

    % Display R squared, offset and slope on plot
    [strain_stats.r2, strain_stats.offset, strain_stats.slope] = Skeletonization_Linear_Model(points,values);

    dim = [0.2 0.5 0.3 0.3];
    str = {sprintf('r squared = %f', strain_stats.r2),sprintf('offset = %f', strain_stats.offset), sprintf('slope = %f', strain_stats.slope)};
    annotation('textbox',dim,'String',str,'FitBoxToText','on');

    line = refline(strain_stats.slope, strain_stats.offset);
    line.Color = 'g';

    % Display strain error statistics on plot
    [strain_stats.mean_error, strain_stats.std_deviation, strain_stats.ten_percentile, strain_stats.ninety_percentile, strain_stats.directional_similarity, strain_stats.difference_of_magnitude, strain_stats.magnitude_of_difference] = Skeletonization_Error(points, values);

    dim = [0.5 0.1 0.3 0.3];
    str = {sprintf('mean error = %f', strain_stats.mean_error),sprintf('std deviation = %f', strain_stats.std_deviation), sprintf('10 percentile = %f', strain_stats.ten_percentile) ...
                    ,sprintf('90 percentile = %f', strain_stats.ninety_percentile), sprintf('directional similarity = %f', strain_stats.directional_similarity), sprintf('difference of magnitude = %f', strain_stats.difference_of_magnitude) ...
                        , sprintf('magnitude of difference = %f', strain_stats.magnitude_of_difference)};
    annotation('textbox',dim,'String',str,'FitBoxToText','on');

end

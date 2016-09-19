function [matched_fixed_points, matched_moving_points, matchedPoints_matchMetric, matchedPoints_maxRatio, matchedPoints_subpixelCorrect] = corrmatch3(fixed_points, moving_points, upsample_scaling, MaxRatio, MatchThreshold, BlockSizeAtOriginalResolution, image_setup)
%{  
    This function performs feature matching given fixed and moving points using normalized correlation applied to neighbouring image intensity values. It returns the set of
	matched feature points and their locations on the fixed and moving image as well as their match quailty and best match to second best match ratio value.
    
    Function will always remove potential matches where part of its image descriptor lies outside the image boundary.
	
	The function itself is not polished as it was created to replace "Skeletonization_Feature_Match_Clear.m" to perform feature matching. Please refer to its use in "DIC_Scripting_for_Feature_Registration.m" for more information on how to use this function.
	
	Inputs (in this order):
	
	fixed_points (2xn float array) - locations of feature points found in the fixed image
	moving_points (2xn float array) - locations of feature points found in the moving image
    upsample_scaling (float) - Upsample factor used to upsample the input images in order to improve spatial resolution of feature matching. Range = (1,infinity), but stick to multiples of 2  
    MaxRatio (float) - Taking the ratio of the the best Q over the second best Q for a particular feature point, MaxRatio defines the highest this ratio can go before attempt to match feature point is rejected due to ambigous matching. Range = (0,1]
	MatchThreshold (float) - Each match possiblity between feature descriptor generates a quality factor Q with the best matches having Q=0. This parameter defines the highest Q can get for a potential match before it is discarded. Range = (0,100]
	BlockSize (int) - Size of the neighbourhood surronding the feature point used as descritor in pixels. Must be Odd and smaller than block size of DVC
	image_setup (v2struct) - Contains image information needed to handle the images properly. Refer to this function's use in "DIC_Scripting_for_Feature_Registration.m" for details.
	
	Outputs:
	
	All returned results are matched by index value.
	
	matched_fixed_points (2xn float array) - locations of matched feature points found in the fixed image
	matched_moving_points (2xn float array) - locations of matched feature points found in the moving image
	matchedPoints_matchMetric (2xn float array) - Match metric quality value of matched feature points
	matchedPoints_maxRatio (2xn float array) - Match best metric quality value over second best match metric quality value ratio for matched feature points
	
%}
	%% Parameter initialization
	
	% Some parameters that adjust the behaviour of the matching 
    absolute_correlation = false;	% Determine whether to treat negative correlation the same as positive correlation value or to use the actual value correlation values.
	cross_corr_neighbourhood = 3;
     
    % Preinitalize empty arrays to store matched points and their match
    % metric value.
    matched_fixed_points = [];
    matched_moving_points = [];
    matchedPoints_matchMetric = [];
    matchedPoints_maxRatio = [];
	matchedPoints_subpixelCorrect = [];
    
	% Quick check to determine if tthere are points to match
    if isempty(fixed_points) || isempty(moving_points)
        return
    end
    
	%% Attempt to read in enviromental variables needed to process fixed and moving images.
    if ischar(image_setup)
        try
            run(image_setup);
        catch
            load(image_setup);
        end
    else
        v2struct(image_setup);
    end
    
    %% Start of program

	%% Calculate fixed and moving image axis based on origin and spacing size.
    BlockSize = 2*round((BlockSizeAtOriginalResolution .* upsample_scaling + 1) / 2) - 1;

    image_x_axis = linspace(Origin(1),Origin(1)+ SpacingSize(1)*(DimensionSize(1)-1), DimensionSize(1));
    image_y_axis = linspace(Origin(2),Origin(2)+ SpacingSize(2)*(DimensionSize(2)-1), DimensionSize(2));
    
    %%

    % Readjust fixed_points and moving_points to match upscaled image positions
    for i = 1:size(fixed_points,1)
        fixed_points(i,:) = round(((fixed_points(i,:) - Origin)./SpacingSize).*upsample_scaling);
    end

    for i = 1:size(moving_points,1)
        moving_points(i,:) = round(((moving_points(i,:) - Origin)./SpacingSize).*upsample_scaling);
    end


    %Change image resolution if needed
    if upsample_scaling ~= 1

         %Set up rearrange of order using permute
        order = length(size(fixed_image));

        order = [1:order];

        order(1) = 2;
        order(2) = 1;

        %Generate the grid vectors for the image

        FarCorner = Origin + SpacingSize.*(DimensionSize-1);

        fixed_image_grid_vectors = {};

        for i = 1:ImageDimensionality
           fixed_image_grid_vectors{i} = [Origin(i):SpacingSize(i):FarCorner(i)];
        end

        %Generate interpolant for each point
        fixed_image_interpolator = griddedInterpolant(fixed_image_grid_vectors,permute(fixed_image,order),'cubic');

        %Generate the new grid of points for the resampled image

        fixed_image_grid_vectors_resample = {};

        for i = 1:ImageDimensionality
           fixed_image_grid_vectors_resample{i} = [Origin(i):SpacingSize(i)/upsample_scaling:FarCorner(i)];
        end

        fixed_image = permute(fixed_image_interpolator(fixed_image_grid_vectors_resample),order);




        %Set up rearrange of order using permute
        order = length(size(moving_image));

        order = [1:order];

        order(1) = 2;
        order(2) = 1;

        %Generate the grid vectors for the image

        FarCorner = Origin + SpacingSize.*(DimensionSize-1);

        moving_image_grid_vectors = {};

        for i = 1:ImageDimensionality
           moving_image_grid_vectors{i} = [Origin(i):SpacingSize(i):FarCorner(i)];
        end

        %Generate interpolant for each point
        moving_image_interpolator = griddedInterpolant(moving_image_grid_vectors,permute(moving_image,order),'cubic');

        %Generate the new grid of points for the resampled image

        moving_image_grid_vectors_resample = {};

        for i = 1:ImageDimensionality
           moving_image_grid_vectors_resample{i} = [Origin(i):SpacingSize(i)/upsample_scaling:FarCorner(i)];
        end

        %moving_image_new_coordinates = ndgrid(moving_image_grid_vectors_resample{:});

        moving_image = permute(moving_image_interpolator(moving_image_grid_vectors_resample),order);


        %Resize spacing and dimension size to resampled image
        SpacingSize = SpacingSize/upsample_scaling;
        DimensionSize = size(fixed_image);
        DimensionSize = [DimensionSize(2) DimensionSize(1) DimensionSize(3:length(DimensionSize))];
    end
    
    %% Prepare for correlation calculation by calculating the standard deviation and the zero averaged feature descriptors beforehand
    
    % Define same block size across all image dimensions if only a number was given
    if length(BlockSize) == 1
        BlockSize(1:size(fixed_points,2)) = BlockSize;
    end
    
    length_descriptor = prod(BlockSize);
    
    zero_averaged_fixed_descriptor = cell(size(fixed_points,1),1);
    zero_averaged_moving_descriptor = cell(size(moving_points,1),1);
    std_fixed_descriptor = zeros(size(fixed_points,1),1);
    std_moving_descriptor = zeros(size(moving_points,1),1);
    
    % For fixed feature descriptors
    for i = 1:size(fixed_points,1)
        
        %Cut out the image we want to use from fixed image
        center = fixed_points(i,:);
        
        fixed_subimage = getsubimage(fixed_image, center, BlockSize, NaN);
        
        if any(isnan(fixed_subimage(:)))
            zero_averaged_fixed_descriptor{i} = NaN;
            std_fixed_descriptor(i) = NaN;
            continue
        end
        
        %Rearange to a single column vector
        fixed_subimage = reshape(fixed_subimage,[],1);
        
        % Calculate the mean of the descriptor 
        avg = mean(fixed_subimage);
        
        % Calculate the standard deviation of the feature descriptor
        std_fixed_descriptor(i) = std(fixed_subimage);
        
        % Calculate the zero averaged feature descriptor
        zero_averaged_fixed_descriptor{i} = fixed_subimage - avg;
        
    end
    
    % For moving feature descriptors
    for i = 1:size(moving_points,1)
        
        %Cut out the image we want to use from moving image
        center = moving_points(i,:);
        
        moving_subimage = getsubimage(moving_image, center, BlockSize, NaN);
        
        if any(isnan(moving_subimage(:)))
            zero_averaged_moving_descriptor{i} = NaN;
            std_moving_descriptor(i) = NaN;
            continue
        end
        
        %Rearange to a single column vector
        moving_subimage = reshape(moving_subimage,[],1);
        
        % Calculate the mean of the descriptor 
        avg = mean(moving_subimage);
        
        % Calculate the standard deviation of the feature descriptor
        std_moving_descriptor(i) = std(moving_subimage);
        
        % Calculate the zero averaged feature descriptor
        zero_averaged_moving_descriptor{i} = moving_subimage - avg;
        
    end
    
    %% Perform feature matching using normalized correlation
    for i = 1:size(fixed_points,1)
    
        %Prepare to save best match forward and second best match forward
        bestMatchForward = {fixed_points(i,:), moving_points(1,:), 1};
        secondMatchForward = {fixed_points(i,:), moving_points(1,:), 1};
        
        bestMovingIndex = 1;
        
        %Skip if feature descriptor has points lying outside hte image
        %boudnary
        if isnan(zero_averaged_fixed_descriptor{i})
            continue
        end
    
        %Compare to moving feature points
        for j = 1:size(moving_points,1)
            
            %Skip if feature descriptor has points lying outside the image
            %boudnary
            if isnan(zero_averaged_moving_descriptor{j})
                continue
            end
            
            %find correlation
            correlation_coefficent = (1/(length_descriptor-1))*(zero_averaged_fixed_descriptor{i}'*zero_averaged_moving_descriptor{j})/(std_fixed_descriptor(i)*std_moving_descriptor(j));

            if absolute_correlation
                inv_correlation_coefficent = 1-abs(correlation_coefficent);
            else
                if correlation_coefficent < 0
                    inv_correlation_coefficent = 1;
                else
                    inv_correlation_coefficent = 1-correlation_coefficent;
                end
            end
            
            %Save best match and second best match for later processing
            if bestMatchForward{3} >= inv_correlation_coefficent
                secondMatchForward = bestMatchForward;
                bestMatchForward = {fixed_points(i,:), moving_points(j,:), inv_correlation_coefficent};
                bestMovingIndex = j;
            end
            
        end
        
        % Apply minimum threshold for possible match
        if isnan(bestMatchForward{3})|| bestMatchForward{3} * 100 > MatchThreshold 
            continue;
        end
        
        % Apply maximum ratio threshold for possible match
        if bestMatchForward{3}/secondMatchForward{3} > MaxRatio
            continue;
        end
        
        
        % Do the reverse search for best match starting from moving point
        
        %Cut out the image we want to use from fixed image
        
        %Skip if feature descriptor has points lying outside the image
        %boudnary
        if isnan(zero_averaged_moving_descriptor{bestMovingIndex})
            continue
        end
        
        %Prepare to save best match backward
        bestMatchBackward = {fixed_points(1,:), bestMatchForward{2}, 1};
        secondMatchBackward = {fixed_points(1,:), bestMatchForward{2}, 1};
        
        for k = 1:size(fixed_points,1)
            
            %Skip if feature descriptor has points lying outside the image
            %boudnary
            if isnan(zero_averaged_fixed_descriptor{k})
                continue
            end
            
            %find correlation
            correlation_coefficent = (1/(length_descriptor-1))*(zero_averaged_fixed_descriptor{k}'*zero_averaged_moving_descriptor{bestMovingIndex})/(std_fixed_descriptor(k)*std_moving_descriptor(bestMovingIndex));

            if absolute_correlation
                inv_correlation_coefficent = 1-abs(correlation_coefficent);
            else
                if correlation_coefficent < 0
                    inv_correlation_coefficent = 1;
                else
                    inv_correlation_coefficent = 1-correlation_coefficent;
                end
            end
            
            %Save best match and second best match for later processing
            if bestMatchBackward{3} >= inv_correlation_coefficent
                secondMatchBackward = bestMatchBackward;
                bestMatchBackward = {fixed_points(k,:), bestMatchBackward{2}, inv_correlation_coefficent};
            end
        end
        
        % Apply minimum threshold for possible match
        if isnan(bestMatchBackward{3})|| bestMatchBackward{3} * 100 > MatchThreshold 
            continue;
        end
        
        % Apply maximum ratio threshold for possible match
        if bestMatchBackward{3}/secondMatchBackward{3} > MaxRatio
            continue;
        end
        
        % If backward match does not match forward match reject match
        if ~isequal(bestMatchForward{1},bestMatchBackward{1}) || ~isequal(bestMatchForward{2},bestMatchBackward{2})
            continue;
        end
		
		
		%% Calculate the subpixel correction displacement from approximated second order approximation of the cross correlation field about each feature point
	
		% Create a 3x3x..x3 (n times) array with [1,1] as the center of the cross correlation field
		cross_corr_corrdinates_min = bestMatchForward{2} - (cross_corr_neighbourhood - 1)/2;
		cross_corr_corrdinates_max = bestMatchForward{2} + (cross_corr_neighbourhood - 1)/2;
		
		for j = 1:length(bestMatchForward{2})
			corr_grid_values{j} = [cross_corr_corrdinates_min(j):cross_corr_corrdinates_max(j)];
		end
		corr_grid = cell(size(corr_grid_values)); %make sure I have the right number of outputs
		[corr_grid{:}] = ndgrid(corr_grid_values{:});
				
		% Calculate cross correlation
		linear_index_max = numel(corr_grid{1});
		cross_corr = NaN*ones(size(corr_grid{1}));
		
        for linear_index = 1:linear_index_max
		
			moving_center = zeros(1,length(corr_grid));
			
			for corr_grid_dim = 1:length(corr_grid)
				moving_center(corr_grid_dim) = corr_grid{corr_grid_dim}(linear_index);
			end
			
			moving_subimage = getsubimage(moving_image, moving_center, BlockSize, NaN);
		
			if any(isnan(moving_subimage(:)))
				continue
			end
			
			%Rearange to a single column vector
			moving_subimage = reshape(moving_subimage,[],1);
			
			% Calculate the mean of the descriptor 
			avg = mean(moving_subimage);
			
			% Calculate the standard deviation of the feature descriptor
			std_moving_descriptor_corr_match = std(moving_subimage);
			
			% Calculate the zero averaged feature descriptor
			zero_averaged_moving_descriptor_corr_match = moving_subimage - avg;
			
			%find correlation
			cross_corr(linear_index) = (1/(length_descriptor-1))*(zero_averaged_fixed_descriptor{i}'*zero_averaged_moving_descriptor_corr_match)/(std_fixed_descriptor(i)*std_moving_descriptor_corr_match);

        end
		
		% Reject if correlation values could not be calculated about the neighbourhood of moving point
		if any(isnan(reshape(cross_corr,1,[])))
			continue
		end
		
		% Reject if correlation value at center is not local maximum
		center_index = num2cell(((cross_corr_neighbourhood+1)/2)*ones(1,length(corr_grid)));
        center_index = sub2ind(size(cross_corr),center_index{:});
		if any(cross_corr(center_index) < reshape(cross_corr,1,[]))
			continue
		end
		
		% Approximate first order derivative
		first_order_grad = zeros(length(corr_grid),1);
        increment_index = ((cross_corr_neighbourhood+1)/2)*ones(1,length(corr_grid));
		
		for corr_grid_dim = 1:length(corr_grid)
			positive_increment = increment_index;
			positive_increment(corr_grid_dim) = positive_increment(corr_grid_dim) + 1;
            positive_increment = num2cell(positive_increment);
            positive_increment = sub2ind(size(cross_corr), positive_increment{:});
			
			negative_increment = increment_index;
			negative_increment(corr_grid_dim) = negative_increment(corr_grid_dim) - 1;
            negative_increment = num2cell(negative_increment);
            negative_increment = sub2ind(size(cross_corr), negative_increment{:});
			
			first_order_grad(corr_grid_dim) = (0.5/SpacingSize(corr_grid_dim))*(cross_corr(positive_increment)-cross_corr(negative_increment));
		end
		
		% Approximate second order derivative/hessian
		hessian_matrix = zeros(length(corr_grid));
		increment_index = ((cross_corr_neighbourhood+1)/2)*ones(1,length(corr_grid));
		
		% Calculate hessian only if first order gradient is not a zero vector
		if ~isequal(first_order_grad, zeros(size(first_order_grad)))
		
			for hessian_grid_dim_first = 1:size(hessian_matrix,1)
				for hessian_grid_dim_second = 1:size(hessian_matrix,2)
					
					if hessian_grid_dim_first == hessian_grid_dim_second
						positive_increment = increment_index;
						positive_increment(hessian_grid_dim_first) = positive_increment(hessian_grid_dim_first) + 1;
                        positive_increment = num2cell(positive_increment);
                        positive_increment = sub2ind(size(cross_corr), positive_increment{:});
						
						negative_increment = increment_index;
						negative_increment(hessian_grid_dim_first) = negative_increment(hessian_grid_dim_first) - 1;
                        negative_increment = num2cell(negative_increment);
                        negative_increment = sub2ind(size(cross_corr), negative_increment{:});
                        
                        increment_index_tmp = num2cell(increment_index);
                        increment_index_tmp = sub2ind(size(cross_corr), increment_index_tmp{:});
						
						hessian_matrix(hessian_grid_dim_first,hessian_grid_dim_second) = (1/(SpacingSize(hessian_grid_dim_first)*SpacingSize(hessian_grid_dim_first)))*(cross_corr(positive_increment)-2*cross_corr(increment_index_tmp) + cross_corr(negative_increment));
						
					else
						positive_positive_increment = increment_index;
						positive_positive_increment(hessian_grid_dim_first) = positive_positive_increment(hessian_grid_dim_first) + 1;
						positive_positive_increment(hessian_grid_dim_second) = positive_positive_increment(hessian_grid_dim_second) + 1;
                        positive_positive_increment = num2cell(positive_positive_increment);
                        positive_positive_increment = sub2ind(size(cross_corr), positive_positive_increment{:});
						
						positive_negative_increment = increment_index;
						positive_negative_increment(hessian_grid_dim_first) = positive_negative_increment(hessian_grid_dim_first) + 1;
						positive_negative_increment(hessian_grid_dim_second) = positive_negative_increment(hessian_grid_dim_second) - 1;
                        positive_negative_increment = num2cell(positive_negative_increment);
                        positive_negative_increment = sub2ind(size(cross_corr), positive_negative_increment{:});
						
						negative_positive_increment = increment_index;
						negative_positive_increment(hessian_grid_dim_first) = negative_positive_increment(hessian_grid_dim_first) - 1;
						negative_positive_increment(hessian_grid_dim_second) = negative_positive_increment(hessian_grid_dim_second) + 1;
                        negative_positive_increment = num2cell(negative_positive_increment);
                        negative_positive_increment = sub2ind(size(cross_corr), negative_positive_increment{:});
						
						negative_negative_increment = increment_index;
						negative_negative_increment(hessian_grid_dim_first) = negative_negative_increment(hessian_grid_dim_first) - 1;
						negative_negative_increment(hessian_grid_dim_second) = negative_negative_increment(hessian_grid_dim_second) - 1;
                        negative_negative_increment = num2cell(negative_negative_increment);
                        negative_negative_increment = sub2ind(size(cross_corr), negative_negative_increment{:});
						
						hessian_matrix(hessian_grid_dim_first,hessian_grid_dim_second) = (0.25/(SpacingSize(hessian_grid_dim_first)*SpacingSize(hessian_grid_dim_second)))*(cross_corr(positive_positive_increment) - cross_corr(positive_negative_increment) - cross_corr(negative_positive_increment) + cross_corr(negative_negative_increment));
						
					end
				end
				
			end
			
			% Calculate offset
			offset_displacement = -(hessian_matrix\first_order_grad);
            offset_displacement = offset_displacement';

		end

		
		% If offset displacement calculate fails (when hessian could not be calculated but first order gradient is not a zero vector) reject match
		if ~isequal(first_order_grad, zeros(size(first_order_grad))) && any(isnan(offset_displacement(:)))
			continue
		end
		
		
		% Passed all matching checks, store match
		matched_fixed_points = [matched_fixed_points; bestMatchForward{1}];
		matched_moving_points = [matched_moving_points; bestMatchForward{2}];
		matchedPoints_matchMetric = [matchedPoints_matchMetric; bestMatchForward{3}];
		matchedPoints_maxRatio = [matchedPoints_maxRatio; bestMatchForward{3}/secondMatchForward{3}];
		matchedPoints_subpixelCorrect = [matchedPoints_subpixelCorrect; offset_displacement];
        
    end

    %Readjust the matched feature point locations back to global
    %coordinates
    
    if ~isempty(matched_fixed_points)
        matched_fixed_points = matched_fixed_points.*repmat(SpacingSize,size(matched_fixed_points,1),1) + repmat(Origin,size(matched_fixed_points,1),1);
    end
    
    if ~isempty(matched_moving_points)
        matched_moving_points =  matched_moving_points.*repmat(SpacingSize,size(matched_moving_points,1),1) + repmat(Origin,size(matched_moving_points,1),1);
    end

    
end
function [matched_fixed_points, matched_moving_points, matchedPoints_matchMetric, matchedPoints_maxRatio] = corrmatch2(fixed_points, moving_points, upsample_scaling, MaxRatio, MatchThreshold, BlockSizeAtOriginalResolution, image_setup)
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
     
    % Preinitalize empty arrays to store matched points and their match
    % metric value.
    matched_fixed_points = [];
    matched_moving_points = [];
    matchedPoints_matchMetric = [];
    matchedPoints_maxRatio = [];
    
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
        
        bestMovingIndex = 0;
        
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
            
            %Skip if feature descriptor has points lying outside hte image
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
        
        % If backward match matches forward match, store the match
        if (isequal(bestMatchForward{1},bestMatchBackward{1})) && (isequal(bestMatchForward{2},bestMatchBackward{2}))
            matched_fixed_points = [matched_fixed_points; bestMatchForward{1}];
            matched_moving_points = [matched_moving_points; bestMatchForward{2}];
            matchedPoints_matchMetric = [matchedPoints_matchMetric; bestMatchForward{3}];
            matchedPoints_maxRatio = [matchedPoints_maxRatio; bestMatchForward{3}/secondMatchForward{3}];
        end
        
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
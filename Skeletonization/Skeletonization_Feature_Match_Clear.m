function [matched_fixed_points, matched_moving_points, matchedPoints_matchMetric] = Skeletonization_Feature_Match_Clear(varargin)


if nargin == 0
    
    %Fixed Image Parameters
    fixed_image_param.threshold_method = 'histogram';  %input
    fixed_image_param.threshold = 0.375;   %input

    %Moving Image Parameters
    moving_image_param.threshold_method = 'histogram'; %input
    moving_image_param.threshold = 0.375;  %input


    BlockSizeAtOriginalResolution = 23; %Must be Odd     %input
    MaxRatio = 0.6; %input
    MaxThreshold = 10;  %input

    clean_up_images = true; %input

    upsample_scaling = 1;   %input

    segment_refine = 100;   %input

    use_active_contour = true;
    
    display_figures = true;
    
    calculate_strain = false;   %input
    
    %Load in input images

    % Dump the no trabeculae

    image_setup = [
    
    %'zeroStrain_Deconv'
    %'zeroStrain_Deconv_Trabeculae'
    %'zeroStrain_Deconv_Trabeculae_NoGrowthPlates'
    %'linearly02_Deconv'
    %'linearly02_Deconv_Trabeculae'
    %'linearly02_Deconv_Trabeculae_NoGrowthPlates'
    %'linearly20_Deconv'
    %'linearly20_Deconv_Trabeculae'
    %'linearly20_Deconv_Trabeculae_NoGrowthPlates'

    %'linearly02_zeroStrain_Deconv'
    %'linearly02_zeroStrain_Deconv_Trabeculae'
    'linearly02_zeroStrain_Deconv_Trabeculae_NoGrowthPlates'

    %'standardResampleScaleMatch_1p1and2_subpixel_alligned'
    
    ];
    
elseif nargin == 15
    
    fixed_points = varargin{1};
    moving_points = varargin{2};
    
    %Fixed Image Parameters
    fixed_image_param.threshold_method = varargin{3};  %input
    fixed_image_param.threshold = varargin{4};   %input

    %Moving Image Parameters
    moving_image_param.threshold_method = varargin{5}; %input
    moving_image_param.threshold = varargin{6};  %input
    
    upsample_scaling = varargin{7};   %input
    
    use_active_contour = varargin{8};   %input
    segment_refine = varargin{9};   %input
    clean_up_images = varargin{10}; %input
    
    MaxRatio = varargin{11}; %input
    MaxThreshold = varargin{12};  %input
    
    BlockSizeAtOriginalResolution = varargin{13}; %Must be Odd     %input
    
    display_figures = varargin{14};
    
    image_setup = varargin{15};
    
else
    display 'Inncorrrect number of variables.'
    matched_fixed_points = [NaN];
    matched_moving_points = [NaN];
    return
end

% fixed_image_param.threshold_method = 40;
% fixed_image_param.threshold = 20;
% 
% BlockSize = 11;
% MaxRatio = 0.5;
% MaxThreshold = 1;
% 
% morph_close = false;
% morph_endpoints = true;
% 
% upsample_scaling = 1;
% 
% clean_up_images = 1;

if ischar(image_setup)
    try
        run(image_setup);
    catch
        load(image_setup);
    end
else
    v2struct(image_setup);
end

%%


BlockSize = 2*round((BlockSizeAtOriginalResolution * upsample_scaling + 1) / 2) - 1;

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
    fixed_image_interpolator = griddedInterpolant(fixed_image_grid_vectors,permute(fixed_image,order),'spline');

    %Generate the new grid of points for the resampled image

    fixed_image_grid_vectors_resample = {};

    for i = 1:ImageDimensionality
       fixed_image_grid_vectors_resample{i} = [Origin(i):SpacingSize(i)/upsample_scaling:FarCorner(i)];
    end

    %fixed_image_new_coordinates = ndgrid(fixed_image_grid_vectors_resample{:});

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
    moving_image_interpolator = griddedInterpolant(moving_image_grid_vectors,permute(moving_image,order),'spline');

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





%%

if clean_up_images == true
    
    
    %Perfrom block matching with matched points

    %Replace image used for matching with original image

    %Check if manual segmentation is done. If not, perform our own segmentation
    %(2D only)

    % if exist('moving_image_skeletonize_segment','var') == true
    %     bw_bone = moving_image_skeletonize_segment;
    % else

    if use_active_contour
    
        mask = zeros(size(fixed_image));
        mask( 5:end-5, 5:end-5) = 1;

        bw_bone = activecontour(fixed_image, mask, segment_refine); %generates a binary mask
    else
        bw_bone = fixed_image;
    end
    % end

    %Go through entire masked region and find minimum in the image. Set the
    %image region outside the mask to this minimum value.
    
    if strcmp(fixed_image_param.threshold_method,'histogram')
    
        fixed_image_linear = reshape(fixed_image,1,[]);
        bw_bone_linear = reshape(bw_bone,1,[]);
        
        clear bw_bone;

        fixed_image_background = inf;

        for i = 1:length(fixed_image_linear)
            if bw_bone_linear(i) ~= 0
                if fixed_image_linear(i) < fixed_image_background
                    fixed_image_background = fixed_image_linear(i);
                end
            end
        end

        for i = 1:length(fixed_image_linear)
            if bw_bone_linear(i) == 0
               fixed_image_linear(i) = fixed_image_background;
            end
        end
        
        clear bw_bone_linear;

        fixed_image2 = reshape(fixed_image_linear,size(fixed_image));
        threshold_ratio = fixed_image_param.threshold;
        threshold_fixed = threshold_ratio*(max(reshape(fixed_image2,1,[])) - min(reshape(fixed_image2,1,[]))) + min(reshape(fixed_image2,1,[]));
        
        clear fixed_image2;


        fixed_image = fixed_image .* (fixed_image > threshold_fixed);
        
    else
        
        fixed_image = fixed_image .* (fixed_image > fixed_image_param.threshold);
        clear bw_bone;
        
    end

    
    if use_active_contour
        mask = zeros(size(moving_image));
        mask( 5:end-5, 5:end-5) = 1;

        bw_bone = activecontour(moving_image, mask, segment_refine); %generates a binary mask
    else
        bw_bone = moving_image;
    end

    if strcmp(moving_image_param.threshold_method,'histogram')
        
        moving_image_linear = reshape(moving_image,1,[]);
        bw_bone_linear = reshape(bw_bone,1,[]);
        
        clear bw_bone;

        moving_image_background = inf;

        for i = 1:length(moving_image_linear)
            if bw_bone_linear(i) ~= 0
                if moving_image_linear(i) < moving_image_background
                    moving_image_background = moving_image_linear(i);
                end
            end
        end

        for i = 1:length(moving_image_linear)
            if bw_bone_linear(i) == 0
               moving_image_linear(i) = moving_image_background;
            end
        end
        
        clear bw_bone_linear

        moving_image2 = reshape(moving_image_linear,size(moving_image));

        clear moving_image_linear;


        threshold_ratio = moving_image_param.threshold/moving_image_param.threshold_method;
        threshold_moving = threshold_ratio*(max(reshape(moving_image2,1,[])) - min(reshape(moving_image2,1,[]))) + min(reshape(moving_image2,1,[]));
        
        clear moving_image2;


        moving_image = moving_image .* (moving_image > threshold_moving);
    else
        
        moving_image = moving_image .* (moving_image > moving_image_param.threshold);
        
        clear bw_bone;
    end
end

branchpts_fixed = fixed_points;
branchpts_moving = moving_points;

matchedPoints1 = [];
matchedPoints2 = [];

if size(branchpts_fixed,1) > 0 && size(branchpts_moving,1) > 0

    [features_fixed,validPoints_fixed] = extractFeatures(fixed_image,branchpts_fixed,'Method','Block', 'BlockSize', BlockSize);
    [features_moving,validPoints_moving] = extractFeatures(moving_image,branchpts_moving,'Method','Block','BlockSize', BlockSize);

    [indexPairs, matchMetric] = matchFeatures(features_fixed, features_moving, 'Unique', true, 'MaxRatio', MaxRatio, 'MatchThreshold', MaxThreshold);

    matchedPoints1 = validPoints_fixed(indexPairs(:, 1),:);
    matchedPoints2 = validPoints_moving(indexPairs(:, 2),:);
    
end

matchedPoints_fixed = [];
matchedPoints_moving = [];
matchedPoints_matchMetric = [];

for i = 1:size(matchedPoints1,1)
    matchedPoints_fixed(i,:) = Origin + matchedPoints1(i,:).*SpacingSize;
    matchedPoints_moving(i,:) = Origin + matchedPoints2(i,:).*SpacingSize;
    matchedPoints_matchMetric = [matchedPoints_matchMetric; matchMetric(i)];
end

if display_figures

figure
hold on
imagesc(image_x_axis, image_y_axis, fixed_image)
colormap('gray')
h = plot(matchedPoints_fixed(:,1),matchedPoints_fixed(:,2),'r.');
set(h,'MarkerSize',10.5);
axis image;
title('Fixed Image');

figure
hold on
imagesc(image_x_axis, image_y_axis, moving_image)
colormap('gray')
h = plot(matchedPoints_moving(:,1),matchedPoints_moving(:,2),'r.');
set(h,'MarkerSize',10.5);
axis image;
title('Moving Image');


displacement_vectors = matchedPoints_moving - matchedPoints_fixed;


figure
hold on
imagesc(image_x_axis, image_y_axis, fixed_image)
colormap('gray')
h = quiver(matchedPoints_fixed(:,1),matchedPoints_fixed(:,2),displacement_vectors(:,1), displacement_vectors(:,2),0,'y');
set(h,'MarkerSize',10.5);
h = plot(matchedPoints_fixed(:,1),matchedPoints_fixed(:,2),'r.');
set(h,'MarkerSize',10.5);
axis image;
%axis off
title('SIFT Displacement Vectors (Original)');

end

% 
% figure; imshow(fixed_image, []);
% hold on
% set(gca,'YDir','normal')
% plot(matchedPoints1(:,1), matchedPoints1(:,2), 'r.')
% set(gca,'YDir','normal')
% 
% figure; imshow(moving_image, []);
% hold on
% set(gca,'YDir','normal')
% plot(matchedPoints2(:,1), matchedPoints2(:,2), 'r.')
% set(gca,'YDir','normal')


matched_fixed_points = matchedPoints_fixed;
matched_moving_points = matchedPoints_moving;

if false
   %%
   
   
    disp('fixed_points = [');
    for i = 1:size(matchedPoints_fixed,1)
        fprintf('%.15e\t' , [matchedPoints_fixed(i,:) 0]);
        fprintf(';\n');
    end
    disp('];');
    fprintf(';\n');
    
    disp('moving_points = [');
    for i = 1:size(matchedPoints_moving,1)
        fprintf('%.15e\t' , [matchedPoints_moving(i,:) 0]);
        fprintf(';\n');
    end
    disp('];');
    
    fprintf('\n%%Skeleton Parameters:\n');
    fprintf('%%fixed_image_param.threshold_method = %d;\n',fixed_image_param.threshold_method);
    fprintf('%%fixed_image_param.threshold = %d;\n',fixed_image_param.threshold);
    fprintf('\n');
    fprintf('%%moving_image_param.threshold_method = %d;\n',moving_image_param.threshold_method);
    fprintf('%%moving_image_param.threshold = %d;\n',moving_image_param.threshold);
    fprintf('\n');
    fprintf('%%BlockSizeAtOriginalResolution = %d;\n',BlockSizeAtOriginalResolution);
    fprintf('%%MaxRatio = %f;\n',MaxRatio);
    fprintf('%%MaxThreshold = %d;\n',MaxThreshold);
    fprintf('\n');
    fprintf('%%morph_close = %d;\n',morph_close);
    fprintf('%%morph_endpoints = %d;\n',morph_endpoints);
    fprintf('\n');
    fprintf('%%clean_up_images = %d;\n',clean_up_images);
    fprintf('\n');
    fprintf('%%upsample_scaling = %f;\n',upsample_scaling);
    fprintf('\n');
    fprintf('%%segment_refine = %f;\n',segment_refine);
    
end


end
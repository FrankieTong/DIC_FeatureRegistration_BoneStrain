function [fixed_points, moving_points, skel_fixed, skel_moving, bin_fixed_image, bin_moving_image] = Skeletonization_Feature_Registration(varargin)


if nargin == 0
    
    %Fixed Image Parameters
    fixed_image_param.thresh_num = 40;  %input
    fixed_image_param.threshold = 15;   %input

    %Moving Image Parameters
    moving_image_param.thresh_num = 40; %input
    moving_image_param.threshold = 15;  %input


    BlockSizeAtOriginalResolution = 23; %Must be Odd     %input
    MaxRatio = 0.6; %input
    MaxThreshold = 10;  %input

    morph_close = false;    %input
    morph_endpoints = false;    %input

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
    
    %Fixed Image Parameters
    fixed_image_param.thresh_num = varargin{1};  %input
    fixed_image_param.threshold = varargin{2};   %input

    %Moving Image Parameters
    moving_image_param.thresh_num = varargin{3}; %input
    moving_image_param.threshold = varargin{4};  %input


    BlockSizeAtOriginalResolution = varargin{5}; %Must be Odd     %input
    MaxRatio = varargin{6}; %input
    MaxThreshold = varargin{7};  %input

    morph_close = varargin{8};   %input
    morph_endpoints = varargin{9};   %input

    clean_up_images = varargin{10}; %input

    upsample_scaling = varargin{11};   %input

    segment_refine = varargin{12};   %input

    display_figures = varargin{13};

    use_active_contour = varargin{14};   %input
    
    image_setup = varargin{15};
    
else
    display 'Inncorrrect number of variables.'
    fixed_points = [NaN];
    moving_points = [NaN];
    return
end

tic;           % help us to see the time required for each step
% fixed_image_param.thresh_num = 40;
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

image_x_axis = linspace(Origin(1),Origin(1)+ SpacingSize(1)*DimensionSize(1), DimensionSize(1));
image_y_axis = linspace(Origin(2),Origin(2)+ SpacingSize(2)*DimensionSize(2), DimensionSize(2));

if exist('fixed_image_skeletonize', 'var') == false
    fixed_image_skeletonize = fixed_image;
end

if exist('moving_image_skeletonize', 'var') == false
    moving_image_skeletonize = moving_image;
end

if display_figures

figure
hold on
imagesc(image_x_axis, image_y_axis, fixed_image_skeletonize)
colormap('gray')
axis image;
axis off;
title('Fixed Image');

figure
hold on
imagesc(image_x_axis, image_y_axis, moving_image_skeletonize)
colormap('gray')
axis image;
axis off;
title('Moving Image');

end
%%

%Change image resolution if needed
if upsample_scaling ~= 1
    
    %Set up rearrange of order using permute
    order = length(size(fixed_image_skeletonize));
    
    order = [1:order];
    
    order(1) = 2;
    order(2) = 1;
    
    %Generate the grid vectors for the image
    
    FarCorner = Origin + SpacingSize.*(DimensionSize-1);
    
    fixed_image_skeletonize_grid_vectors = {};
    
    for i = 1:ImageDimensionality
       fixed_image_skeletonize_grid_vectors{i} = [Origin(i):SpacingSize(i):FarCorner(i)];
    end

    %Generate interpolant for each point
    fixed_image_skeletonize_interpolator = griddedInterpolant(fixed_image_skeletonize_grid_vectors,permute(fixed_image_skeletonize,order),'spline');
    
    %Generate the new grid of points for the resampled image
    
    fixed_image_skeletonize_grid_vectors_resample = {};
    
    for i = 1:ImageDimensionality
       fixed_image_skeletonize_grid_vectors_resample{i} = [Origin(i):SpacingSize(i)/upsample_scaling:FarCorner(i)];
    end
    
    %fixed_image_skeletonize_new_coordinates = ndgrid(fixed_image_skeletonize_grid_vectors_resample{:});
    
    fixed_image_skeletonize = permute(fixed_image_skeletonize_interpolator(fixed_image_skeletonize_grid_vectors_resample),order);
    
    

    
    
    
    
    %Set up rearrange of order using permute
    order = length(size(moving_image_skeletonize));
    
    order = [1:order];
    
    order(1) = 2;
    order(2) = 1;
    
    %Generate the grid vectors for the image
    
    FarCorner = Origin + SpacingSize.*(DimensionSize-1);
    
    moving_image_skeletonize_grid_vectors = {};
    
    for i = 1:ImageDimensionality
       moving_image_skeletonize_grid_vectors{i} = [Origin(i):SpacingSize(i):FarCorner(i)];
    end

    %Generate interpolant for each point
    moving_image_skeletonize_interpolator = griddedInterpolant(moving_image_skeletonize_grid_vectors,permute(moving_image_skeletonize,order),'spline');
    
    %Generate the new grid of points for the resampled image
    
    moving_image_skeletonize_grid_vectors_resample = {};
    
    for i = 1:ImageDimensionality
       moving_image_skeletonize_grid_vectors_resample{i} = [Origin(i):SpacingSize(i)/upsample_scaling:FarCorner(i)];
    end
    
    %fixed_image_skeletonize_new_coordinates = ndgrid(fixed_image_skeletonize_grid_vectors_resample{:});
    
    moving_image_skeletonize = permute(moving_image_skeletonize_interpolator(moving_image_skeletonize_grid_vectors_resample),order);



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
    DimensionSize = size(fixed_image_skeletonize);
    DimensionSize = [DimensionSize(2) DimensionSize(1) DimensionSize(3:length(DimensionSize))];
end


%Check if manual segmentation is done. If not, perform our own segmentation
%(2D only)

%if exist('fixed_image_skeletonize_segment','var') == true
%    bw_bone = fixed_image_skeletonize_segment;
%else

if use_active_contour
   
    mask = ones(size(fixed_image_skeletonize));
    mask( 5:end-5, 5:end-5) = 1; %% Frankie: Something needs to be done about the mask starting size...

    bw_bone = activecontour(fixed_image_skeletonize, mask, segment_refine); %generates a binary mask
end
%end



%Go through entire masked region and find minimum in the image. Set the
%image region outside the mask to this minimum value.

fixed_image_skeletonize_linear = reshape(fixed_image_skeletonize,1,[]);
bw_bone_linear = reshape(bw_bone,1,[]);

fixed_image_skeletonize_background = inf;

for i = 1:length(fixed_image_skeletonize_linear)
    if bw_bone_linear(i) ~= 0
        if fixed_image_skeletonize_linear(i) < fixed_image_skeletonize_background
            fixed_image_skeletonize_background = fixed_image_skeletonize_linear(i);
        end
    end
end

for i = 1:length(fixed_image_skeletonize_linear)
    if bw_bone_linear(i) == 0
       fixed_image_skeletonize_linear(i) = fixed_image_skeletonize_background;
    end
end

fixed_image_skeletonize2 = reshape(fixed_image_skeletonize_linear,size(fixed_image_skeletonize));

%figure, imshow(fixed_image_skeletonize2, []);

%%
% try 
%     thresh = multithresh(fixed_image_skeletonize2, fixed_image_param.thresh_num); %Segment the image into three levels (7/20) using imquantize .
% catch
%     thresh = multithresh(fixed_image_skeletonize2,1);
% end
% 
% seg_I = imquantize(fixed_image_skeletonize2, thresh);
% 
% %Convert segmented image into color image using label2rgb and display it.
% 
% RGB = label2rgb(seg_I);
% figure; imshow(RGB); %colorbar
% set(gca,'YDir','normal')
% axis off
% title(['RGB Segmented Image - fixed_image_param.threshold #: ', num2str(fixed_image_param.thresh_num)])


%%

%bone = fixed_image_skeletonize2 > thresh(fixed_image_param.threshold);

%Normalize input image intensity between 0 and 1
fixed_image_skeletonize3 = (fixed_image_skeletonize2 - min(reshape(fixed_image_skeletonize2,1,[])))/(max(reshape(fixed_image_skeletonize2,1,[])) - min(reshape(fixed_image_skeletonize2,1,[])));

%Histogram based Segmentation
bone = im2bw(fixed_image_skeletonize3, fixed_image_param.threshold/fixed_image_param.thresh_num);

if morph_close == true
    bone = bwmorph(bone,'close');
end

if display_figures
figure; imshow(bone)
set(gca,'YDir','normal')
title('Bone Segmented')
end
%%

bin_fixed_image = bone;

BW_skel = bwmorph(bone,'skel',Inf);

skel_pts = find(BW_skel);

if display_figures
figure; imshow(BW_skel)
set(gca,'YDir','normal')
end
%%

BW_branch = bwmorph(BW_skel,'branchpoints');
STATS = regionprops(BW_branch, 'PixelList');
branchpts_fixed = cat(1, STATS.PixelList);

if morph_endpoints == true
   BW_skel = bwmorph(BW_skel, 'spur');
   BW_endpoints = bwmorph(BW_skel,'endpoints');
   
   STATS = regionprops(BW_endpoints, 'PixelList');
   branchpts_fixed_endpoints = cat(1, STATS.PixelList);
   
   branchpts_fixed = [branchpts_fixed; branchpts_fixed_endpoints];
end

skel_fixed = BW_skel;

% figure; imshow(BW_branch)
if display_figures
figure; imshow(BW_skel)
hold on
set(gca,'YDir','normal')
h = plot(branchpts_fixed(:,1), branchpts_fixed(:,2), 'r.');
set(h,'MarkerSize',10.5);
end
%%

if display_figures
figure; imshow(fixed_image_skeletonize, []);
hold on
set(gca,'YDir','normal')
h = plot(branchpts_fixed(:,1), branchpts_fixed(:,2), 'r.');
set(h,'MarkerSize',10.5);
end

%% Do the same for moving images
%Check if manual segmentation is done. If not, perform our own segmentation
%(2D only)

% if exist('moving_image_skeletonize_segment','var') == true
%     bw_bone = moving_image_skeletonize_segment;
% else
   
if use_active_contour
    mask = zeros(size(moving_image_skeletonize));
    mask( 5:end-5, 5:end-5) = 1;

    bw_bone = activecontour(moving_image_skeletonize, mask, segment_refine); %generates a binary mask
end   
% end

%Go through entire masked region and find minimum in the image. Set the
%image region outside the mask to this minimum value.



moving_image_skeletonize_linear = reshape(moving_image_skeletonize,1,[]);
bw_bone_linear = reshape(bw_bone,1,[]);

moving_image_skeletonize_background = inf;

for i = 1:length(moving_image_skeletonize_linear)
    if bw_bone_linear(i) ~= 0
        if moving_image_skeletonize_linear(i) < moving_image_skeletonize_background
            moving_image_skeletonize_background = moving_image_skeletonize_linear(i);
        end
    end
end

for i = 1:length(moving_image_skeletonize_linear)
    if bw_bone_linear(i) == 0
       moving_image_skeletonize_linear(i) = moving_image_skeletonize_background;
    end
end

moving_image_skeletonize2 = reshape(moving_image_skeletonize_linear,size(moving_image_skeletonize));

%figure, imshow(moving_image_skeletonize2, []);

%%
% 
% fixed_image_param.thresh_num = 20;
% try 
%     thresh = multithresh(moving_image_skeletonize2, moving_image_param.thresh_num); %Segment the image into three levels (7/20) using imquantize .
% catch
%     thresh = multithresh(moving_image_skeletonize2,1);
% end
% 
% seg_I = imquantize(moving_image_skeletonize2, thresh);
% 
% %Convert segmented image into color image using label2rgb and display it.
% 
% RGB = label2rgb(seg_I);
% figure; imshow(RGB); %colorbar
% set(gca,'YDir','normal')
% axis off
% title(['RGB Segmented Image - moving_image_param.threshold #: ', num2str(moving_image_param.thresh_num)])

%%

% bone = moving_image_skeletonize2 > thresh(moving_image_param.threshold);

moving_image_skeletonize3 = (moving_image_skeletonize2 - min(reshape(moving_image_skeletonize2,1,[])))/(max(reshape(moving_image_skeletonize2,1,[])) - min(reshape(moving_image_skeletonize2,1,[])));

bone = im2bw(moving_image_skeletonize3, moving_image_param.threshold/moving_image_param.thresh_num);
bone_moving = bone;

if morph_close == true
    bone = bwmorph(bone,'close');
end

if display_figures
figure; imshow(bone)
set(gca,'YDir','normal')
title('Bone Segmented')
end
%%

bin_moving_image = bone;

BW_skel = bwmorph(bone,'skel',Inf);

skel_pts = find(BW_skel);

if display_figures
figure; imshow(BW_skel)
set(gca,'YDir','normal')
end
%%

BW_branch = bwmorph(BW_skel,'branchpoints');
STATS = regionprops(BW_branch, 'PixelList');
branchpts_moving = cat(1, STATS.PixelList);

if morph_endpoints == true 
   BW_skel = bwmorph(BW_skel, 'spur');
   BW_endpoints = bwmorph(BW_skel,'endpoints');
   
   STATS = regionprops(BW_endpoints, 'PixelList');
   branchpts_moving_endpoints = cat(1, STATS.PixelList);
   branchpts_moving = [branchpts_moving; branchpts_moving_endpoints];
end

skel_moving = BW_skel;

% figure; imshow(BW_branch)
if display_figures
figure; imshow(BW_skel)
set(gca,'YDir','normal')
hold on
h = plot(branchpts_moving(:,1), branchpts_moving(:,2), 'r.');
set(h,'MarkerSize',10.5);
end

%%

if display_figures
figure; imshow(moving_image_skeletonize, []);
hold on
set(gca,'YDir','normal')
h = plot(branchpts_moving(:,1), branchpts_moving(:,2), 'r.');
set(h,'MarkerSize',10.5);
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

    % end

        %Go through entire masked region and find minimum in the image. Set the
        %image region outside the mask to this minimum value.



        fixed_image_linear = reshape(fixed_image,1,[]);
        bw_bone_linear = reshape(bw_bone,1,[]);

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

        fixed_image2 = reshape(fixed_image_linear,size(fixed_image_skeletonize));

    else
        
        fixed_image2 = fixed_image;
        
    end



    %Check if manual segmentation is done. If not, perform our own segmentation
    %(2D only)

    % if exist('moving_image_skeletonize_segment','var') == true
    %     bw_bone = moving_image_skeletonize_segment;
    % else

        mask = zeros(size(moving_image));
        mask( 5:end-5, 5:end-5) = 1;

        bw_bone = activecontour(moving_image, mask, segment_refine); %generates a binary mask

    % end

    %Go through entire masked region and find minimum in the image. Set the
    %image region outside the mask to this minimum value.


    if use_active_contour

        moving_image_linear = reshape(moving_image,1,[]);
        bw_bone_linear = reshape(bw_bone,1,[]);

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

        moving_image2 = reshape(moving_image_linear,size(moving_image_skeletonize));
    else
        moving_image2 = moving_image;
    end

    
    threshold_ratio = fixed_image_param.threshold/fixed_image_param.thresh_num;
    threshold_fixed = threshold_ratio*(max(reshape(fixed_image2,1,[])) - min(reshape(fixed_image2,1,[]))) + min(reshape(fixed_image2,1,[]));
    
    threshold_ratio = moving_image_param.threshold/moving_image_param.thresh_num;
    threshold_moving = threshold_ratio*(max(reshape(moving_image2,1,[])) - min(reshape(moving_image2,1,[]))) + min(reshape(moving_image2,1,[]));
    
    fixed_image = fixed_image .* (fixed_image > threshold_fixed);
    moving_image = moving_image .* (moving_image > threshold_moving);
    
end

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

for i = 1:size(matchedPoints1,1)
    matchedPoints_fixed(i,:) = Origin + matchedPoints1(i,:).*SpacingSize;
    matchedPoints_moving(i,:) = Origin + matchedPoints2(i,:).*SpacingSize;
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


fixed_points = matchedPoints_fixed;
moving_points = matchedPoints_moving;

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
    fprintf('%%fixed_image_param.thresh_num = %d;\n',fixed_image_param.thresh_num);
    fprintf('%%fixed_image_param.threshold = %d;\n',fixed_image_param.threshold);
    fprintf('\n');
    fprintf('%%moving_image_param.thresh_num = %d;\n',moving_image_param.thresh_num);
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


if calculate_strain == true
    
    main
    
end

end
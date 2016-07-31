function [fixed_points, moving_points, skel_fixed, skel_moving, bin_fixed_image, bin_moving_image] = Skeletonization_Feature_Find(varargin)
%{  This function performs skeletonization and feature finding on the input given fixed and moving images. It returns the feature points found
	in the fixed and moving images as well as the skeletonized fixed and moving images and the binarized fixed and moving images (downsampled
	back to the original image resolution if upsampling was needed).
	
	The function itself is not polished as it was ported over to a function format from a script format for use. Please refer to its use in "DIC_Scripting_for_Feature_Registration.m" for more information on how to use this function.
	
	Inputs (in this order):
	
    fixed_image_param.threshold_method (str) - Method for binarizing the fixed image. 'histogram' uses histogram percentile value, 'none' uses intensity percentage value from total range of intensities
    fixed_image_param.threshold (float) - Percenage at which any intensity value above this value is part of bone and any below is not part of bone. Range = (0,1)
	moving_image_param.threshold_method (str) - Method for binarizing the moving image. 'histogram' uses histogram percentile value, 'none' uses intensity percentage value from total range of intensities
    moving_image_param.threshold (float) - Percenage at which any intensity value above this value is part of bone and any below is not part of bone. Range = (0,1)
    upsample_scaling (float) - Upsample factor used to upsample the input images in order to improve spatial resolution of feature matching. Range = (1,infinity), but stick to multiples of 2  
    use_active_contour (bool) - Identifies whether to use activecontour on the fixed and moving images first before binarizing
    segment_refine (int) - Number of iterations to use for active contour. Default = 1000
    morph_close (bool)- Applies a morphological close operation to remove 1 pixel spaces in the binary images. Default = true
    morph_endpoints (bool) - Treats end points of the skeleton as potential feature points as well. Default = false
    morph_remove_branches (bool) - Remove branches in the skeleton before finding branch points. Default = false
    display_figures (bool) - Identify whether to output figures used for debugging or not. Default = false
    image_setup (v2struct) - Contains image information needed to handle the images properly. Refer to this function's use in "DIC_Scripting_for_Feature_Registration.m" for details.
	
	Outputs:
	
	fixed_points (2xn float array) - locations of feature points found in the fixed image
	moving_points (2xn float array) - locations of feature points found in the moving image
	skel_fixed (size(fixed_image) bool array) - skeletonized and downsampled image of the skeleton generated from the fixed image 
	skel_moving (size(moving_image) bool array) - skeletonized and downsampled image of the skeleton generated from the moving image 
	bin_fixed_image (size(fixed_image) bool array) - binarized and downsampled image generated from the fixed image 
	bin_moving_image (size(moving_image) bool array) - binarized and downsampled image generated from the moving image 
%}

%% For use if running as a script
if nargin == 0
    
    %Fixed Image Parameters
    fixed_image_param.threshold_method = 'historgram';  %input
    fixed_image_param.threshold = 0.375;   %input

    %Moving Image Parameters
    moving_image_param.threshold_method = 'historgram'; %input
    moving_image_param.threshold = 0.375;  %input


    BlockSizeAtOriginalResolution = 23; %Must be Odd     %input

    morph_close = false;    %input
    morph_endpoints = false;    %input
    morph_remove_branches = false;

    upsample_scaling = 2;   %input

    segment_refine = 100;   %input

    use_active_contour = true;
    
    display_figures = true;
    
    %Load in input images

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

%% For use if running as a function
elseif nargin == 12
    
    %Fixed Image Parameters
    fixed_image_param.threshold_method = varargin{1};  %input
    fixed_image_param.threshold = varargin{2};   %input

    %Moving Image Parameters
    moving_image_param.threshold_method = varargin{3}; %input
    moving_image_param.threshold = varargin{4};  %input
    
    upsample_scaling = varargin{5};   %input
    
    use_active_contour = varargin{6};   %input
    segment_refine = varargin{7};   %input

    morph_close = varargin{8};   %input
    morph_endpoints = varargin{9};   %input
    morph_remove_branches = varargin{10};
    
    display_figures = varargin{11};
    
    image_setup = varargin{12};
    
else
    display 'Inncorrrect number of variables.'
    fixed_points = [NaN];
    moving_points = [NaN];
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
image_x_axis = linspace(Origin(1),Origin(1)+ SpacingSize(1)*(DimensionSize(1)-1), DimensionSize(1));
image_y_axis = linspace(Origin(2),Origin(2)+ SpacingSize(2)*(DimensionSize(2)-1), DimensionSize(2));

%% If there us not a seperate image to use for skeletonization, use the default fixed and moving image for skeletonization
if exist('fixed_image_skeletonize', 'var') == false
    fixed_image_skeletonize = fixed_image;
end
if exist('moving_image_skeletonize', 'var') == false
    moving_image_skeletonize = moving_image;
end

if display_figures
	%% Display fixed and moving images
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

%%Change image resolution of fixed and moving images if needed
if upsample_scaling ~= 1
    
	%% Upsample fixed image to be skeletonized
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
    
    

    
    
    
    %% Upsample moving image to be skeletonized
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
    
    moving_image_skeletonize = permute(moving_image_skeletonize_interpolator(moving_image_skeletonize_grid_vectors_resample),order);


    %Resize spacing and dimension size to resampled image
    SpacingSize = SpacingSize/upsample_scaling;
    DimensionSize = size(fixed_image_skeletonize);
    DimensionSize = [DimensionSize(2) DimensionSize(1) DimensionSize(3:length(DimensionSize))];
end



%% Binarize and skeletonize fixed image

%% Generate an active contour mask as a preliminary binarization to remove noise if needed
if use_active_contour
    mask = ones(size(fixed_image_skeletonize));
    mask( 5:end-5, 5:end-5) = 1;

    bw_bone = activecontour(fixed_image_skeletonize, mask, segment_refine); %generates a binary mask
else
    bw_bone = fixed_image_skeletonize;
end


%% Binarize and rescale image intensity values between [0,1] based on remaining intensity image values in the masked area
if strcmp(fixed_image_param.threshold_method, 'histogram')
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


	%Normalize input image intensity between 0 and 1
	fixed_image_skeletonize3 = (fixed_image_skeletonize2 - min(reshape(fixed_image_skeletonize2,1,[])))/(max(reshape(fixed_image_skeletonize2,1,[])) - min(reshape(fixed_image_skeletonize2,1,[])));

	%Histogram based Segmentation
	bone = im2bw(fixed_image_skeletonize3, fixed_image_param.threshold);
    
else
    %Default: use normal hard threshold value
    bone = bw_bone > fixed_image_param.threshold;
end

%% Apply morphological closing to remove 1 pixel gaps in binarized fixed image
if morph_close == true
    bone = bwmorph(bone,'close');
end

% Display the binarized fixed image
if display_figures
	figure; imshow(bone)
	set(gca,'YDir','normal')
	title('Bone Segmented')
end

%% Skeletonize the fixed image and find the feature points
bin_fixed_image = bone;
BW_skel = bwmorph(bone,'skel',Inf);
skel_pts = find(BW_skel);

% Display the skeletonized fixed image
if display_figures
figure; imshow(BW_skel)
set(gca,'YDir','normal')
end

%% Remove branches if needed
if morph_remove_branches
    BW_skel = Skeletonization_Remove_Branches(BW_skel);
end

%% Find the locations of intersection point in the skeleton
BW_branch = bwmorph(BW_skel,'branchpoints');
STATS = regionprops(BW_branch, 'PixelList');
branchpts_fixed = cat(1, STATS.PixelList);

%% Add the end points of the skeleton to the list of branch points in the skeleton
if morph_endpoints == true
   BW_skel = bwmorph(BW_skel, 'spur');
   BW_endpoints = bwmorph(BW_skel,'endpoints');
   
   STATS = regionprops(BW_endpoints, 'PixelList');
   branchpts_fixed_endpoints = cat(1, STATS.PixelList);
   
   branchpts_fixed = [branchpts_fixed; branchpts_fixed_endpoints];
end

skel_fixed = BW_skel;

% Display the skeletonized fixed image with branch points highlighted
if display_figures
	figure; imshow(BW_skel)
	hold on
	set(gca,'YDir','normal')
	h = plot(branchpts_fixed(:,1), branchpts_fixed(:,2), 'r.');
	set(h,'MarkerSize',10.5);
end

% Display the fixed image with branch points highlighted
if display_figures
figure; imshow(fixed_image_skeletonize, []);
hold on
set(gca,'YDir','normal')
h = plot(branchpts_fixed(:,1), branchpts_fixed(:,2), 'r.');
set(h,'MarkerSize',10.5);
end

%% Binarize and skeletonize moving image

%% Generate an active contour mask as a preliminary binarization to remove noise if needed
if use_active_contour
   
    mask = ones(size(moving_image_skeletonize));
    mask( 5:end-5, 5:end-5) = 1; %% Frankie: Something needs to be done about the mask starting size...

    bw_bone = activecontour(moving_image_skeletonize, mask, segment_refine); %generates a binary mask
else
    bw_bone = moving_image_skeletonize;
end

%% Binarize and rescale image intensity values between [0,1] based on remaining intensity image values in the masked area
if strcmp(moving_image_param.threshold_method, 'histogram')
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

    moving_image_skeletonize3 = (moving_image_skeletonize2 - min(reshape(moving_image_skeletonize2,1,[])))/(max(reshape(moving_image_skeletonize2,1,[])) - min(reshape(moving_image_skeletonize2,1,[])));

    bone = im2bw(moving_image_skeletonize3, moving_image_param.threshold);

else
    %Default: use normal hard threshold value
    bone = bw_bone > moving_image_param.threshold;
end
    
%% Apply morphological closing to remove 1 pixel gaps in binarized moving image
if morph_close == true
    bone = bwmorph(bone,'close');
end

% Display the binarized moving image
if display_figures
	figure; imshow(bone)
	set(gca,'YDir','normal')
	title('Bone Segmented')
end

%% Skeletonize the moving image and find the feature points
bin_moving_image = bone;
BW_skel = bwmorph(bone,'skel',Inf);
skel_pts = find(BW_skel);

% Display the skeletonized moving image
if display_figures
	figure; imshow(BW_skel)
	set(gca,'YDir','normal')
end

%% Remove branches if needed
if morph_remove_branches
    BW_skel = Skeletonization_Remove_Branches(BW_skel);
end


%% Find the locations of intersection point in the skeleton
BW_branch = bwmorph(BW_skel,'branchpoints');
STATS = regionprops(BW_branch, 'PixelList');
branchpts_moving = cat(1, STATS.PixelList);

%% Add the end points of the skeleton to the list of branch points in the skeleton
if morph_endpoints == true 
   BW_skel = bwmorph(BW_skel, 'spur');
   BW_endpoints = bwmorph(BW_skel,'endpoints');
   
   STATS = regionprops(BW_endpoints, 'PixelList');
   branchpts_moving_endpoints = cat(1, STATS.PixelList);
   branchpts_moving = [branchpts_moving; branchpts_moving_endpoints];
end

skel_moving = BW_skel;

% Display the skeletonized fixed image with branch points highlighted
if display_figures
	figure; imshow(BW_skel)
	set(gca,'YDir','normal')
	hold on
	h = plot(branchpts_moving(:,1), branchpts_moving(:,2), 'r.');
	set(h,'MarkerSize',10.5);
end


% Display the fixed image with branch points highlighted
if display_figures
	figure; imshow(moving_image_skeletonize, []);
	hold on
	set(gca,'YDir','normal')
	h = plot(branchpts_moving(:,1), branchpts_moving(:,2), 'r.');
	set(h,'MarkerSize',10.5);
end


%% Downsample skel and bin images back to normal resolution before passing it back to calling function

%% Downsample skeleton for fixed image

%Set up rearrange of order using permute
order = length(size(skel_fixed));

order = [1:order];

order(1) = 2;
order(2) = 1;

%Generate the grid vectors for the image

FarCorner = Origin + SpacingSize.*(DimensionSize-1);

skel_fixed_image_grid_vectors = {};

for i = 1:ImageDimensionality
   skel_fixed_image_grid_vectors{i} = [Origin(i):SpacingSize(i):FarCorner(i)];
end

%Generate interpolant for each point
skel_fixed_image_interpolator = griddedInterpolant(skel_fixed_image_grid_vectors,single(permute(skel_fixed,order)),'spline');

%Generate the new grid of points for the resampled image

skel_fixed_image_grid_vectors_resample = {};

for i = 1:ImageDimensionality
   skel_fixed_image_grid_vectors_resample{i} = [Origin(i):SpacingSize(i)*upsample_scaling:FarCorner(i)];
end

skel_fixed = permute(skel_fixed_image_interpolator(skel_fixed_image_grid_vectors_resample),order);

%% Downsample skeleton for moving image

%Set up rearrange of order using permute
order = length(size(skel_moving));

order = [1:order];

order(1) = 2;
order(2) = 1;

%Generate the grid vectors for the image

FarCorner = Origin + SpacingSize.*(DimensionSize-1);

skel_moving_image_grid_vectors = {};

for i = 1:ImageDimensionality
   skel_moving_image_grid_vectors{i} = [Origin(i):SpacingSize(i):FarCorner(i)];
end

%Generate interpolant for each point
skel_moving_image_interpolator = griddedInterpolant(skel_moving_image_grid_vectors,single(permute(skel_moving,order)),'spline');

%Generate the new grid of points for the resampled image

skel_moving_image_grid_vectors_resample = {};

for i = 1:ImageDimensionality
   skel_moving_image_grid_vectors_resample{i} = [Origin(i):SpacingSize(i)*upsample_scaling:FarCorner(i)];
end

skel_moving = permute(skel_moving_image_interpolator(skel_moving_image_grid_vectors_resample),order);


%% Downsample binarized image for fixed image

%Set up rearrange of order using permute
order = length(size(bin_fixed_image));

order = [1:order];

order(1) = 2;
order(2) = 1;

%Generate the grid vectors for the image

FarCorner = Origin + SpacingSize.*(DimensionSize-1);

bin_fixed_image_grid_vectors = {};

for i = 1:ImageDimensionality
   bin_fixed_image_grid_vectors{i} = [Origin(i):SpacingSize(i):FarCorner(i)];
end

%Generate interpolant for each point
bin_fixed_image_interpolator = griddedInterpolant(bin_fixed_image_grid_vectors,single(permute(bin_fixed_image,order)),'spline');

%Generate the new grid of points for the resampled image

bin_fixed_image_grid_vectors_resample = {};

for i = 1:ImageDimensionality
   bin_fixed_image_grid_vectors_resample{i} = [Origin(i):SpacingSize(i)*upsample_scaling:FarCorner(i)];
end

bin_fixed_image = permute(bin_fixed_image_interpolator(bin_fixed_image_grid_vectors_resample),order);

%% Downsample binarized image for moving image

%Set up rearrange of order using permute
order = length(size(bin_moving_image));

order = [1:order];

order(1) = 2;
order(2) = 1;

%Generate the grid vectors for the image

FarCorner = Origin + SpacingSize.*(DimensionSize-1);

bin_moving_image_grid_vectors = {};

for i = 1:ImageDimensionality
   bin_moving_image_grid_vectors{i} = [Origin(i):SpacingSize(i):FarCorner(i)];
end

%Generate interpolant for each point
bin_moving_image_interpolator = griddedInterpolant(bin_moving_image_grid_vectors,single(permute(bin_moving_image,order)),'spline');

%Generate the new grid of points for the resampled image

bin_moving_image_grid_vectors_resample = {};

for i = 1:ImageDimensionality
   bin_moving_image_grid_vectors_resample{i} = [Origin(i):SpacingSize(i)*upsample_scaling:FarCorner(i)];
end

bin_moving_image = permute(bin_moving_image_interpolator(bin_moving_image_grid_vectors_resample),order);


% Additional step to threshold the binary images to ensure they are binary
skel_fixed = skel_fixed >= 0.25;
skel_moving = skel_moving >= 0.25;
bin_fixed_image = bin_fixed_image >= 0.25;
bin_moving_image = bin_moving_image >= 0.25;


% Adjust found points in fixed and moving iamges back to original image resolution
for i = 1:size(branchpts_fixed,1)
    branchpts_fixed(i,:) = Origin + branchpts_fixed(i,:).*(SpacingSize);
end
for i = 1:size(branchpts_moving,1)
    branchpts_moving(i,:) = Origin + branchpts_moving(i,:).*(SpacingSize);
end

% Return the branch points found in fixed and moving images as potential candidates for feature matching
fixed_points = branchpts_fixed;
moving_points = branchpts_moving;

end
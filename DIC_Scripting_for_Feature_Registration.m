%{
This script applies Feature Registration ontop of DIC registration in order to calculate strain in bone.

Only works for 2D images at the moment.

DIC implementation utilized in this work was the McGill Digital Image Correlation Research Tool (MDICRT).
Copyright © 2008, Jeffrey Poissant, Francois Barthelat

Feature registration used for further registration utilizes Matlab's morphological operations to apply skeletonization
to find feature points at locations of trabeculae intersection. Local image intensities about each feature point is then
used as a feature descriptor for matching using normalized correlation as the optimization metric.

Strain is calculated using a minimum least squares implementation of meshless methods strain calculation found in
TWO DIMENSIONAL ELEMENT FREE GALERKIN CODE by Nguyen Vinh Phu, LTDS, ENISE, July 2006.

v2struct developed by Adi Navve, 2014 was also used for packing and unpacking enviromental variables between functions.

%}

%% Path initialization for support functions for this script
addpath('Skeletonization')
addpath('v2struct')
addpath('Tools and Files')
addpath('Utility')

%% General Input Parameters
clear
 
% Configuration file with images to be registered and analyzed for strain
image_script_file = 'zero_strain_rescan.m';
run(image_script_file);

if (~exist('fixed_image_name','var') || ~exist('fixed_image_name','var'))
	display 'Image file names for DVC were not defined.')
	return
end

%% DVC Parameters
DVC_Only = false;	%Toggle on to run DVC only
subsetSizeS = 81; 	%Size of the DVC subset image size. Must be odd
percentage_overlap = 0.75;	%Percentage of subset that overlaps neighbouring subsets. Range = (0,1)
subsetSpaceS = ceil(subsetSizeS-subsetSizeS*percentage_overlap);

% Other DVC parameters that are left as default
interp_orderS = 'Quintic (5th order)';
TOLS = [1.00E-08, 5.00E-06];
optim_methodS = 'Newton Raphson';
Max_num_iterS = 40;
iterations = 30;
qoS = [0;0;0;0;0;0];    				%qoS(1) = inital u displacement guess (pixels); qoS(2) = inital v displacement guess (pixels);


%% DVC Strain Calculation Parameters
Compute_Strain  = 1;    %1 = Use finite differences to approximate derivatives, 2 = Use a smoothing spline and evaluate derivatives (tol defines spline tolerance), 3 = Use subset derivative terms obtained with DIC
Filter_uv       = 0;    %0 = Do not filter input displacements, 1 = Filter input displacements by convolving displacement field with a window matrix size of Conv1 
Conv1           = '15'; %Input displacement convolution matrix size if Filter_uv is 1
Filter_strains  = 1;    %0 = Do not filter output strains, 1 = Filter output strains by convolving strain field with a window matrix size of Conv2 
Conv2           = '1';  %Output strain convolution matrix size if Filter_uv is 1
tol             = 0.01; %Smoothing spline tolerance level that applies when Compute_Strain = 2;

total_or_increm = 'Total'; %Can be 'Total' or 'Increm'. Will always default to total in this test scenario

%% Skeletonization Parameters
Skeletonization_Only = false; %Toggle on to run skeletonization only

% Parameters for initial active contour applied to the fixed and moving images to setup for binarization before skeleotnization
segment_refine = 1000; %Number of iterations to use for active contour
use_active_contour = false; %Apply active contour on image before skeletonization

% Image binarization parameters
% Fixed Image Parameters
% Parameters used for inital binarizing to remove marrow from the image
fixed_image_threshold_method = 'none'; %'histogram' uses histogram percentile value, 'none' uses intensity percentage value from total range of intensities
fixed_image_threshold = 0.5; %Percenage at which any intensity value above this value is part of bone and any below is not part of bone

% Moving Image Parameters
moving_image_threshold_method = 'none'; %'histogram' uses histogram percentile value, 'none' uses intensity percentage value from total range of intensities
moving_image_threshold = 0.5; %Percenage at which any intensity value above this value is part of bone and any below is not part of bone. Range = (0,1)


% Feature descriptor matching criteria
BlockSize = 23; 			%Size of the neighbourhood surronding the feature point used as descritor in pixels. Must be Odd and smaller than block size of DVC
MatchThreshold = 10;  		%Each match possiblity between feature descriptor generates a quality factor Q with the best matches having Q=0. This parameter defines the highest Q can get for a potential match before it is discarded. Range = (0,100]
MaxRatio = 0.1; 			%Taking the ratio of the the best Q over the second best Q for a particular feature point, MaxRatio defines the highest this ratio can go before attempt to match feature point is rejected due to ambigous matching. Range = (0,1]
MatchMetricMinimize = true; %Apply MatchThreshold and MaxRatio between all points found using DVC and feature registration. Default = true

upsample_scaling = 8;  % Upsample factor used to upsample the input images in order to improve spatial resolution of feature matching. Range = (1,infinity), but stick to multiples of 2

% Some other skeletonization that I left here as default.
morph_close = true;    % Applies a morphological close operation to remove 1 pixel spaces in the binary image
morph_endpoints = false; %Treats end points of the skeleton as potential feature points as well
morph_remove_branches = false; %Remove branches in the skeleton before finding branch points
clean_up_images = false; % Apply binary thresholding and active contour before skeletonization.

%% Meshless Method (MLS) Parameters
beta = 3;								% Multiplicative factor applied to the average nodal density used to define the size of the domain of influence each node has on neighbouring nodes. range = (0,infinite), but should be around [2,3] (Belinha, 2014)
neighbouring_points_min = 5;			% Number of nodal points each possible nodal point should affect before it is to be used in part of displacement and strain calculation. range = (0,infinite)
use_calculated_displacement = false;	% Use the displacement calculated from MLS as the input for calculating strain using MLS. Otherwise, strain is calcualted from the raw displacement values. Provides a smoothing affect on the strain field.

% Additional MLS paramters that are left as default
display_figures = false;				% Toggle to determine if we want to display figures from the feature registration routine. May be useful for debugging, but should be left off when used with DVC as it clutters the screan.
use_image_grid = false;					% Toggle to determine whether to use the feature point locations to calculate displacement and strain or use the input image grid to calcualte displacement and strain.


%% MAIN PROGRAM STARTS HERE %%

%% Apply active contour and finding the proper threshold number for the whole image before running DVC

% Generate mask to define where to apply active contour on fixed image
mask = ones(size(fixed_image));
mask( 5:end-5, 5:end-5) = 1;

%Apply active contour on fixed image to retrieve initial binary mask of the bone in the image
activecontour_fixed_image = activecontour(fixed_image, mask, segment_refine); 

% Generate mask to define where to apply active contour on fixed image
mask = ones(size(moving_image));
mask( 5:end-5, 5:end-5) = 1; %% Frankie: Something needs to be done about the mask starting size...

% Apply active contour on moving image to retrieve initial binary mask of the bone in the image
activecontour_moving_image = activecontour(moving_image, mask, segment_refine); %generates a binary mask

%% Apply mask back to the original fixed and moving images, then
% adjust all values deemed as background to the minimum value in the
% masked part of the image for both fixed and moving active contour masked images.
min_fixed_image = inf;
min_moving_image = inf;

% Find maximum and minimum values in the masked portion of the image
for i = 1:size(fixed_image,1)
    for j = 1:size(fixed_image,2)
        if (activecontour_fixed_image(i,j) == 1) && (min_fixed_image > fixed_image(i,j))
            min_fixed_image = fixed_image(i,j);
        end
        if (activecontour_moving_image(i,j) == 1) && (min_moving_image > moving_image(i,j))
            min_moving_image = moving_image(i,j);
        end
    end
end
rescaled_activecontour_fixed_image = fixed_image;
rescaled_activecontour_moving_image = moving_image;

% Rescale the fixed and moving active contour masked images to have intensity values between [0,1]

% Find maximum and minimum values in the masked portion of the image
for i = 1:size(fixed_image,1)
    for j = 1:size(fixed_image,2)
        if activecontour_fixed_image(i,j) == 0
            rescaled_activecontour_fixed_image(i,j)= min_fixed_image;
        end
        if activecontour_moving_image(i,j) == 0
            rescaled_activecontour_moving_image(i,j)= min_moving_image;
        end
    end
end
max_fixed_image = max(rescaled_activecontour_fixed_image(:));
max_moving_image = max(rescaled_activecontour_moving_image(:));
rescaled_activecontour_fixed_image = (rescaled_activecontour_fixed_image - min_fixed_image)./(max_fixed_image - min_fixed_image);
rescaled_activecontour_moving_image = (rescaled_activecontour_moving_image - min_moving_image)./(max_moving_image - min_moving_image);

% Calculate the absolute threshold value based on the maximum and minimum value
% inside the masked area (which is the same as the percentage value since
% we readjusted the input images to scale between 0 and 1)
rescaled_fixed_image_threshold = fixed_image_threshold;
rescaled_moving_image_threshold = moving_image_threshold;


%% Start of DVC
if Skeletonization_Only == false

	% Place the name of the fixed and moving images (in .tif format) into a data structure
    dirList = cell(1,1);
    dirList{1,1} = fixed_image_name;
    dirList{2,1} = moving_image_name;

    ref_image_FileS = dirList{1};
    ind = 1;
    indS = 1;
    fileList{ind} = dirList(2:end);

	% Run DVC on the fixed and moving images.
    success = mcGillDIC(ref_image_FileS,fileList{ind},subsetSizeS(indS),subsetSpaceS,qoS,Xp_firstS(ind),Yp_firstS(ind), Xp_lastS(ind), Yp_lastS(ind),interp_orderS,TOLS,optim_methodS,iterations,false,0);
    display('Finished DVC')
    
    %% Retrive output_folder_path from global variable
    global last_WS;

    %% Strain calculation for DVC
    % Set up dummy class structure to enable get and set for particular
    % properties needed for strain calculation parameter passing
    handles.CompStrain_DropBox = dummyClass;
    handles.Filter_uv_CheckBox = dummyClass;
    handles.Conv1Edit = dummyClass;
    handles.Filter_strains_CheckBox = dummyClass;
    handles.Conv2Edit = dummyClass;
    handles.SplineTolEdit = dummyClass;

    set(handles.CompStrain_DropBox, 'Value', Compute_Strain);
    set(handles.Filter_uv_CheckBox, 'Value', Filter_uv);    
    set(handles.Conv1Edit, 'string', Conv1);
    set(handles.Filter_strains_CheckBox, 'Value', Filter_strains);
    set(handles.Conv2Edit, 'string', Conv2);
    set(handles.SplineTolEdit, 'string', tol);

	% Load in raw data from initial output generated by DVC in order to calculate strain
    RD = Load_Data(strcat(last_WS.output_folder_path,'\Raw Data\Raw Data',last_WS.date_time_short,'.txt'));

	% Calculate strain of the DVC displacement field
    [strains_DVC, strains_DVC_Xgrids, strains_DVC_Ygrids] = Compute_Strains(total_or_increm, RD, handles);

    %% Remove output folder from DVC (for convience)
    rmdir(last_WS.output_folder_path,'s');

end

%% Start Feature Registration
if DVC_Only == false

	% Setting up some variables used to store information
    fixed_points = [];	%Stores all matched feature points found in the fixed image
    moving_points = [];	%Stores all matched feature points found in the moving image
    match_metric = [];  %Stores all feasture desciptor match quality for matched feature points
    match_ratio = [];	%Stores all feature descirptor quality ratio metrics for matched feature points
    match_metric_DVC = [];	%Stores all match quality metrics from DVC 

    fixed_points_all_found = [];	%Stores all feature points found in the fixed image
    moving_points_all_found = [];	%Stores all feature points found in the moving image

    fixed_image_feature_find_subimages_boundary = [];	%Stores the bounding box points for all initial subimages in the fixed image used by DVC
    fixed_image_reconstruct_subimages_boundary  = [];	%Stores the bounding box points for all matched  subimages in the fixed image used by DVC

    moving_image_feature_find_subimages_boundary  = [];	%Stores the bounding box points for all initial subimages in the moving image used by DVC
    moving_image_reconstruct_subimages_boundary  = [];	%Stores the bounding box points for all matched  subimages in the moving image used by DVC

	% Some variables used to store messages to indicate how far along we are with the feature registration process on the main screan
    msg = [];
    reverseStr = [];

	% Setup of some variables to store reconstructed images (most are obsolete or not that useful in general)
    moving_image_wrt_fixed_image = zeros(size(fixed_image));
    bin_fixed_image = zeros(size(fixed_image));
    bin_moving_image = zeros(size(fixed_image));
    skel_fixed_image = zeros(size(fixed_image));
    skel_moving_image = zeros(size(moving_image));

    %% Run skeletonization and find fixed and moving images in both fixed and
    % moving images on the global scale
    if Skeletonization_Only == true
        
        %% Run Skeletonization on entire image. Treats the entire image as the subimage.

        %First save the variables, then adjust the variable values that
        %need to be changed
        Skeletonization_Find_Param.fixed_image = rescaled_activecontour_fixed_image;
        Skeletonization_Find_Param.moving_image = rescaled_activecontour_moving_image;
        Skeletonization_Find_Param.DimensionSize = size(rescaled_activecontour_fixed_image');
        Skeletonization_Find_Param.ImageDimensionality = ImageDimensionality;
        Skeletonization_Find_Param.Origin = Origin.*0;
        Skeletonization_Find_Param.PixelDimensionality = PixelDimensionality;
        Skeletonization_Find_Param.SpacingSize = size(rescaled_activecontour_fixed_image)./ size(rescaled_activecontour_fixed_image);
        Skeletonization_Find_Param.displacement_eq = displacement_eq;
        Skeletonization_Find_Param.image_x_axis = 0:size(rescaled_activecontour_fixed_image,1)-1;
        Skeletonization_Find_Param.image_y_axis = 0:size(rescaled_activecontour_fixed_image,2)-1;
        Skeletonization_Find_Param.strain_eq = strain_eq;
        Skeletonization_Find_Param.units_of_measurement_adjust = units_of_measurement_adjust;

        % Find feature points in fixed and moving images
        [fixed_points_subset_found, moving_points_subset_found, skel_fixed_image_subset, skel_moving_image_subset, bin_fixed_image_subset, bin_moving_image_subset] = Skeletonization_Feature_Find_Clear(fixed_image_threshold_method, rescaled_fixed_image_threshold ,moving_image_threshold_method, rescaled_moving_image_threshold, upsample_scaling, use_active_contour, segment_refine, morph_close, morph_endpoints, morph_remove_branches, display_figures,Skeletonization_Find_Param);

		% Add feature points found during the feature registration of this subimage to the global list
        for k = 1:size(fixed_points_subset_found,1)
            fixed_points_all_found = [fixed_points_all_found; fixed_points_subset_found(k,:)];
        end
        for k = 1:size(moving_points_subset_found,1)
            moving_points_all_found = [moving_points_all_found; moving_points_subset_found(k,:)];
        end

		%% Perform feature descriptor matching between feature points found in the feature registration of this subimage.
        Skeletonization_Match_Param.fixed_image = fixed_image;
        Skeletonization_Match_Param.moving_image = moving_image;
        Skeletonization_Match_Param.DimensionSize = size(fixed_image');
        Skeletonization_Match_Param.ImageDimensionality = ImageDimensionality;
        Skeletonization_Match_Param.Origin = Origin.*0;
        Skeletonization_Match_Param.PixelDimensionality = PixelDimensionality;
        Skeletonization_Match_Param.SpacingSize = size(fixed_image)./ size(fixed_image);
        Skeletonization_Match_Param.displacement_eq = displacement_eq;
        Skeletonization_Match_Param.image_x_axis = 0:size(fixed_image,1)-1;
        Skeletonization_Match_Param.image_y_axis = 0:size(fixed_image,2)-1;
        Skeletonization_Match_Param.strain_eq = strain_eq;
        Skeletonization_Match_Param.units_of_measurement_adjust = units_of_measurement_adjust;

        % Match feature points between fixed and moving images using sum of squares difference of intensity values as the matching metric (obsolete)
        %[fixed_points_subset_matched, moving_points_subset_matched, matchMetric] = Skeletonization_Feature_Match_Clear(fixed_points_subset_found, moving_points_subset_found, fixed_image_threshold_method, rescaled_fixed_image_threshold ,moving_image_threshold_method, rescaled_moving_image_threshold, upsample_scaling, use_active_contour, segment_refine, clean_up_images, MaxRatio, MatchThreshold, BlockSize, display_figures, Skeletonization_Match_Param);
                
        % Match feature points between fixed and moving images using sum of normalized correlation as the matching metric 
        [fixed_points_subset_matched, moving_points_subset_matched, matchMetric, matchRatio] = corrmatch(fixed_points_subset_found, moving_points_subset_found, upsample_scaling, MaxRatio, MatchThreshold, BlockSize, Skeletonization_Match_Param);
     
        %% Store relevant information about matching this subset into global variables

        %First adjust fixed_points_subset and moving_points_subset back to 
        %the global position wrt the fixed image.
        fixed_points_subset_wrt_fixed_image = [];
        moving_points_subset_wrt_fixed_image = [];
        for k = 1:size(fixed_points_subset_matched,1)
            fixed_points_subset_wrt_fixed_image(k,:) = fixed_points_subset_matched(k,:); 
            moving_points_subset_wrt_fixed_image(k,:) = moving_points_subset_matched(k,:);
        end

        %Append both adjusted list of points to the total list of points
        fixed_points = [fixed_points; fixed_points_subset_wrt_fixed_image];
        moving_points = [moving_points; moving_points_subset_wrt_fixed_image];
        match_metric = [match_metric; matchMetric];
        match_ratio = [match_ratio; matchRatio];
        
    else
        
        %%Go through each DVC image subset and apply feature registration on it
        for i = 1:length(last_WS.mesh_col)
            for j = 1:length(last_WS.mesh_row)

                %%Generate the fixed image subset to be processed using feature registration
                
                %Each subimage is defined to have a 0 origin with a spacing
                %of 1 for convience when finding and matching feature
                %points
                
				%Calculate distance from middle of DVC subset to the edge of the subset
                offset_size = floor((last_WS.subset_size-1)/2);
                
                %Fixed image is found through index shifting
                
                %Moving image has to be resampled to incorporate the index
                %shift PLUS the displacement vector from DVC
                
                %Resample the moving image using the displacement values from
                %last_WS.DEFORMATION_PARAMETERS{:,:,1} and
                %last_WS.DEFORMATION_PARAMETERS{:,:,2}. 
                [moving_image_X,moving_image_Y] = meshgrid(1:size(moving_image,2), 1:size(moving_image,1));
                moving_image_subset_deform_X = last_WS.mesh_col(i) + last_WS.DEFORMATION_PARAMETERS(j,i,1);
                moving_image_subset_deform_Y = last_WS.mesh_row(j) + last_WS.DEFORMATION_PARAMETERS(j,i,2); 
                [moving_image_subset_deform_X_a,moving_image_subset_deform_Y_a] = meshgrid(moving_image_subset_deform_X-offset_size:1:moving_image_subset_deform_X+offset_size,moving_image_subset_deform_Y-offset_size:1:moving_image_subset_deform_Y+offset_size);

				%Create DVC image subsets on fixed and moving images. Creating moving image subset invovles interpolation as DVC displacement places the subset matched on the moving image off of the image grid
                fixed_image_subset_find = rescaled_activecontour_fixed_image(last_WS.mesh_row(j)-offset_size:last_WS.mesh_row(j)+offset_size,last_WS.mesh_col(i)-offset_size:last_WS.mesh_col(i)+offset_size);
                moving_image_subset_find = interp2(moving_image_X, moving_image_Y, rescaled_activecontour_moving_image, moving_image_subset_deform_X_a,moving_image_subset_deform_Y_a,'spline');

                fixed_image_subset_match = fixed_image(last_WS.mesh_row(j)-offset_size:last_WS.mesh_row(j)+offset_size,last_WS.mesh_col(i)-offset_size:last_WS.mesh_col(i)+offset_size);
                moving_image_subset_match = interp2(moving_image_X, moving_image_Y, moving_image, moving_image_subset_deform_X_a,moving_image_subset_deform_Y_a,'spline');

                %Assigning the values for the subimage boundary boxes for the fixed and moving image subsets
                fixed_image_feature_find_subimages_boundary = [fixed_image_feature_find_subimages_boundary; last_WS.mesh_row(j)-offset_size last_WS.mesh_col(i)-offset_size last_WS.subset_size last_WS.subset_size];
                moving_image_feature_find_subimages_boundary  = [moving_image_feature_find_subimages_boundary; moving_image_subset_deform_Y-offset_size moving_image_subset_deform_X-offset_size last_WS.subset_size last_WS.subset_size];


                %%Now that we have the individual images set up, we can run
                %skeletonization on each subimage to find matched feature points.

				%First save the variables, then adjust the variable values that
				%need to be changed
                Skeletonization_Find_Param.fixed_image = fixed_image_subset_find;
                Skeletonization_Find_Param.moving_image = moving_image_subset_find;
                Skeletonization_Find_Param.DimensionSize = size(fixed_image_subset_find');
                Skeletonization_Find_Param.ImageDimensionality = ImageDimensionality;
                Skeletonization_Find_Param.Origin = Origin.*0;
                Skeletonization_Find_Param.PixelDimensionality = PixelDimensionality;
                Skeletonization_Find_Param.SpacingSize = size(fixed_image_subset_find)./ size(fixed_image_subset_find);
                Skeletonization_Find_Param.displacement_eq = displacement_eq;
                Skeletonization_Find_Param.image_x_axis = 0:size(fixed_image_subset_find,1)-1;
                Skeletonization_Find_Param.image_y_axis = 0:size(fixed_image_subset_find,2)-1;
                Skeletonization_Find_Param.strain_eq = strain_eq;
                Skeletonization_Find_Param.units_of_measurement_adjust = units_of_measurement_adjust;


                % Find feature points in fixed and moving images
                [fixed_points_subset_found, moving_points_subset_found, skel_fixed_image_subset, skel_moving_image_subset, bin_fixed_image_subset, bin_moving_image_subset] = Skeletonization_Feature_Find(fixed_image_threshold_method, rescaled_fixed_image_threshold ,moving_image_threshold_method, rescaled_moving_image_threshold, upsample_scaling, use_active_contour, segment_refine, morph_close, morph_endpoints, morph_remove_branches, display_figures,Skeletonization_Find_Param);

				% Add feature points found during the feature registration of this subimage to the global list
                if ~isempty(fixed_points_subset_found)
                    temp = fixed_points_subset_found + repmat([(last_WS.mesh_col(i)-offset_size) (last_WS.mesh_row(j)-offset_size)], size(fixed_points_subset_found,1),1);
                    fixed_points_all_found = [fixed_points_all_found; temp];
                end
                
                if ~isempty(moving_points_subset_found)
                    temp = moving_points_subset_found + repmat([(last_WS.mesh_col(i)+last_WS.DEFORMATION_PARAMETERS(j,i,1)-offset_size) (last_WS.mesh_row(j)+last_WS.DEFORMATION_PARAMETERS(j,i,2)-offset_size)], size(moving_points_subset_found,1),1);
                    moving_points_all_found = [moving_points_all_found; temp];
                end

				%% Perform feature descriptor matching between feature points found in the feature registration of this subimage.
                Skeletonization_Match_Param.fixed_image = fixed_image_subset_match;
                Skeletonization_Match_Param.moving_image = moving_image_subset_match;
                Skeletonization_Match_Param.DimensionSize = size(fixed_image_subset_match');
                Skeletonization_Match_Param.ImageDimensionality = ImageDimensionality;
                Skeletonization_Match_Param.Origin = Origin.*0;
                Skeletonization_Match_Param.PixelDimensionality = PixelDimensionality;
                Skeletonization_Match_Param.SpacingSize = size(fixed_image_subset_match)./ size(fixed_image_subset_match);
                Skeletonization_Match_Param.displacement_eq = displacement_eq;
                Skeletonization_Match_Param.image_x_axis = 0:size(fixed_image_subset_match,1)-1;
                Skeletonization_Match_Param.image_y_axis = 0:size(fixed_image_subset_match,2)-1;
                Skeletonization_Match_Param.strain_eq = strain_eq;
                Skeletonization_Match_Param.units_of_measurement_adjust = units_of_measurement_adjust;


                % Match feature points between fixed and moving images using sum of squares difference of intensity values as the matching metric (obsolete)
                %[fixed_points_subset_matched, moving_points_subset_matched, matchMetric] = Skeletonization_Feature_Match_Clear(fixed_points_subset_found, moving_points_subset_found, fixed_image_threshold_method, rescaled_fixed_image_threshold ,moving_image_threshold_method, rescaled_moving_image_threshold, upsample_scaling, use_active_contour, segment_refine, clean_up_images, MaxRatio, MatchThreshold, BlockSize, display_figures, Skeletonization_Match_Param);
                
				% Match feature points between fixed and moving images using sum of normalized correlation as the matching metric 
                [fixed_points_subset_matched, moving_points_subset_matched, matchMetric, matchRatio] = corrmatch(fixed_points_subset_found, moving_points_subset_found, upsample_scaling, MaxRatio, MatchThreshold, BlockSize, Skeletonization_Match_Param);
                
                %% Store relevant information about matching this subset into global variables

				%First adjust fixed_points_subset and moving_points_subset back to 
				%the global position wrt the fixed image.
                fixed_points_subset_wrt_fixed_image = [];
                moving_points_subset_wrt_fixed_image = [];

                % Fixed points is adjusted back to originl fixed image
                % coordinates by adding back the subimage coordinate
                
                % Moving points is adjusted back to the original fixed
                % image coordinates by adding back the subimage coordinate
                % AND the displacement DVC vector
                if ~isempty(fixed_points_subset_matched)
                    fixed_points_subset_wrt_fixed_image = fixed_points_subset_matched + repmat([(last_WS.mesh_col(i)-offset_size) (last_WS.mesh_row(j)-offset_size)],size(fixed_points_subset_matched,1),1);
                end
                
                if ~isempty(moving_points_subset_matched)
                    moving_points_subset_wrt_fixed_image = moving_points_subset_matched + repmat([(last_WS.mesh_col(i)+last_WS.DEFORMATION_PARAMETERS(j,i,1)-offset_size) (last_WS.mesh_row(j)+last_WS.DEFORMATION_PARAMETERS(j,i,2)-offset_size)],size(fixed_points_subset_matched,1),1);
                end
                    
                %Append both adjusted list of points to the total list of points
                if ~isempty(fixed_points_subset_wrt_fixed_image)
                    fixed_points = [fixed_points; fixed_points_subset_wrt_fixed_image];
                end
                if ~isempty(moving_points_subset_wrt_fixed_image)
                    moving_points = [moving_points; moving_points_subset_wrt_fixed_image];
                end
                if ~isempty(matchMetric)
                    match_metric = [match_metric; matchMetric];
                end
                if ~isempty(matchRatio)
                    match_ratio = [match_ratio; matchRatio];
                end
				
                %Reconstruct moving image back to global cordinates
                offset_spacing = floor((last_WS.subset_space)/2);
                image_range_shift = [-offset_spacing:offset_spacing];
                image_subset_range = [(ceil((last_WS.subset_size)/2)-offset_spacing):(ceil((last_WS.subset_size)/2)+offset_spacing)];

                moving_image_wrt_fixed_image(last_WS.mesh_row(j) + image_range_shift,last_WS.mesh_col(i) + image_range_shift) = moving_image_subset_find(image_subset_range,image_subset_range);
                
                % Reconstruct the fixed and moving binary images and image 
                % skeletons back to the global coordinates

                bin_fixed_image(last_WS.mesh_row(j) + image_range_shift,last_WS.mesh_col(i) + image_range_shift) = bin_fixed_image_subset(image_subset_range,image_subset_range);
                bin_moving_image(last_WS.mesh_row(j) + image_range_shift,last_WS.mesh_col(i) + image_range_shift) = bin_moving_image_subset(image_subset_range,image_subset_range); % Not ideal, compare with fixed image and will be streched

                skel_fixed_image(last_WS.mesh_row(j) + image_range_shift,last_WS.mesh_col(i) + image_range_shift) = skel_fixed_image_subset(image_subset_range,image_subset_range);
                skel_moving_image(last_WS.mesh_row(j) + image_range_shift,last_WS.mesh_col(i) + image_range_shift) = skel_moving_image_subset(image_subset_range,image_subset_range); % Not ideal, compare with fixed image and will be streched

                % Assigning the values for the image reconstruction bounday boxes
                fixed_image_reconstruct_subimages_boundary  = [fixed_image_reconstruct_subimages_boundary; (last_WS.mesh_row(j)+image_range_shift(1)), (last_WS.mesh_col(i)+image_range_shift(1)), (last_WS.subset_space), (last_WS.subset_space)];
                moving_image_reconstruct_subimages_boundary  = [moving_image_reconstruct_subimages_boundary; (last_WS.mesh_row(j)+image_range_shift(1)), (last_WS.mesh_col(i)+image_range_shift(1)), (last_WS.subset_space), (last_WS.subset_space)]; % debatable if useful or not...

				% Output message to main screan to tell user how far along we are with performing feature registration
                msg = sprintf('Skeletonization %d percent done (row %d column %d)', round(((i-1)*length(last_WS.mesh_row) + (j-1))/(length(last_WS.mesh_row)*length(last_WS.mesh_col))* 100), j, i);
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));

            end
        end
    end

    fprintf('\n');
    display('Finished Skeletonization');
	
	% Readjust the image boundaries for each subimage to match the original images' origin and spacing sizes
    fixed_image_feature_find_subimages_boundary_MLS = fixed_image_feature_find_subimages_boundary;
    fixed_image_reconstruct_subimages_boundary_MLS = fixed_image_reconstruct_subimages_boundary;

    moving_image_feature_find_subimages_boundary_MLS = moving_image_feature_find_subimages_boundary;
    moving_image_reconstruct_subimages_boundary_MLS = moving_image_reconstruct_subimages_boundary;

    for i_m = 1:size(fixed_image_feature_find_subimages_boundary,1)
        fixed_image_feature_find_subimages_boundary_MLS(i_m,:) = [fliplr((fixed_image_feature_find_subimages_boundary(i_m,1:2).* SpacingSize + Origin)) (fixed_image_feature_find_subimages_boundary(i_m,3:4).*SpacingSize)];
        fixed_image_reconstruct_subimages_boundary_MLS(i_m,:) = [fliplr((fixed_image_reconstruct_subimages_boundary(i_m,1:2).* SpacingSize + Origin)) (fixed_image_reconstruct_subimages_boundary(i_m,3:4).*SpacingSize)];

        moving_image_feature_find_subimages_boundary_MLS(i_m,:) = [fliplr((moving_image_feature_find_subimages_boundary(i_m,1:2).* SpacingSize + Origin)) (moving_image_feature_find_subimages_boundary(i_m,3:4).*SpacingSize)];
        moving_image_reconstruct_subimages_boundary_MLS(i_m,:) = [fliplr((moving_image_reconstruct_subimages_boundary(i_m,1:2).* SpacingSize + Origin)) (moving_image_reconstruct_subimages_boundary(i_m,3:4).*SpacingSize)];
    end

	%% Feature registration matched point clean up
	
	% We currently only applied the feature point match quality metrics on feature points matched within the same DVC subset. We now apply these match metrics across all remaining matched feature points.
    
	% Identify if we have no matched feature points
	if size(fixed_points,1) == 0 || size(moving_points,1) == 0
        display('No matched points were found.');
        return
    end

	%% Readjust the feature point locations to match the original images' origin and spacing sizes
    fixed_points_MLS = [];
    moving_points_MLS = [];
    for i_m = 1:size(fixed_points,1)
        fixed_points_MLS(i_m,:) = ((fixed_points(i_m,:)- ones(1,size(fixed_points,2))) .* SpacingSize + Origin);
    end
    for i_m = 1:size(moving_points,1)
        moving_points_MLS(i_m,:) = ((moving_points(i_m,:)- ones(1,size(moving_points,2))) .* SpacingSize + Origin);
    end

    %% Go through list to remove all matches that have the same fixed and moving point locations   
	% Resort all feature points in the list to be ascending order according
    points_MLS = sortrows([fixed_points_MLS moving_points_MLS match_metric match_ratio]);
    
	% Go through each feature point match and take the last unique match.
    new_points_MLS = points_MLS(1,:);
    for i_m = 2:1:size(points_MLS,1)
        if ~isequal(new_points_MLS(end,1:2*size(fixed_points_MLS,2)), points_MLS(i_m,1:2*size(fixed_points_MLS,2)))
            new_points_MLS = [new_points_MLS; points_MLS(i_m,:)];
        end
    end
    
	% Assign the new matched points list back to the old variable
    points_MLS = new_points_MLS;
    clear new_points_MLS;
    
    if MatchMetricMinimize
        %% Do another minimization of all matches to remove all matched points with conflicting fixed and/or moving points
        
        %% Matching from fixed point to moving point
        new_points_MLS = points_MLS(1,:);
        second_best_match_metric = inf;
        
        for i_m = 2:1:size(points_MLS,1)
            if isequal(new_points_MLS(end,1:size(fixed_points_MLS, 2)), points_MLS(i_m,1:1:size(fixed_points_MLS, 2)))
                %If fixed_point matches, take the one with the lower
                %MatchedPoint value and save the second_best_match_metric
                %value
                if new_points_MLS(end,2*size(fixed_points_MLS,2)+1) > points_MLS(i_m, 2*size(fixed_points_MLS,2)+1)
                    second_best_match_metric = new_points_MLS(end,2*size(fixed_points_MLS,2)+1);
                    new_points_MLS(end,:) = points_MLS(i_m,:);
                end
            else
                %Check if the MaxRatio ratio is exceeded. If it is discard the match from the list.
                if (new_points_MLS(end,2*size(fixed_points_MLS,2)+1)/second_best_match_metric) > MaxRatio
                    new_points_MLS(end,:) = [];
                end
                
                %New fixed_point, add to list
                new_points_MLS = [new_points_MLS; points_MLS(i_m,:)];
                second_best_match_metric = inf;
            end
        end
        
		% Assign the new matched points list back to the old variable
        points_MLS = new_points_MLS;
        clear second_best_match_metric;
        clear new_points_MLS;
        
        %% Do another minimization of all matches to remove all matched points with conflicting fixed and/or moving points
        
        % Resort according to moving_point list in ascending order
        points_MLS = sortrows(points_MLS, [size(fixed_points_MLS, 2)+1:size(fixed_points_MLS, 2)+size(moving_points_MLS, 2)]);
        
        new_points_MLS = points_MLS(1,:);
        second_best_match_metric = inf;
        
        for i_m = 2:1:size(points_MLS,1)
            if isequal(new_points_MLS(end,size(fixed_points_MLS, 2)+1:size(fixed_points_MLS, 2)+size(moving_points_MLS, 2)), points_MLS(i_m,size(fixed_points_MLS, 2)+1:size(fixed_points_MLS, 2)+size(moving_points_MLS, 2)))
                %If moving_point matches, take the one with the lower
                %MatchedPoint value and save the second_best_match_metric
                %value
                if new_points_MLS(end,2*size(fixed_points_MLS,2)+1) > points_MLS(i_m, 2*size(fixed_points_MLS,2)+1)
                    second_best_match_metric = new_points_MLS(end,2*size(fixed_points_MLS,2)+1);
                    new_points_MLS(end,:) = points_MLS(i_m,:);
                end
            else
                
                %Check if the MaxRatio ratio is exceeded. If it is discard the match from the list.
                if (new_points_MLS(end,2*size(fixed_points_MLS,2)+1)/second_best_match_metric) > MaxRatio
                    new_points_MLS(end,:) = [];
                end
                
                %New moving_point, add to list
                new_points_MLS = [new_points_MLS; points_MLS(i_m,:)];
                second_best_match_metric = inf;
            end
        end
        
		% Assign the new matched points list back to the old variable
        points_MLS = new_points_MLS;
        match_metric = points_MLS(:,2*size(fixed_points_MLS,2)+1);
        match_ratio = points_MLS(:,end);
        clear second_best_match_metric;
        clear new_points_MLS;
        
    end
    
	%% Calculate displacement and strain using moving least squares meshless method
    fixed_points_MLS = points_MLS(:,1:size(fixed_points_MLS, 2));
    moving_points_MLS = points_MLS(:,size(fixed_points_MLS, 2)+1:size(fixed_points_MLS, 2)+size(moving_points_MLS, 2));
    clear points_MLS;

    fixed_points_all_MLS = [];
    moving_points_all_MLS = [];
    
	% Adjust all match point locations back to the original image origin an spacing
    for i_m = 1:size(fixed_points_all_found,1)
        fixed_points_all_MLS(i_m,:) = ((fixed_points_all_found(i_m,:)- ones(1,size(fixed_points,2))) .* SpacingSize + Origin);
    end
    
    for i_m = 1:size(moving_points_all_found,1)
        moving_points_all_MLS(i_m,:) = ((moving_points_all_found(i_m,:)- ones(1,size(fixed_points,2))) .* SpacingSize + Origin);
    end
    
    %Calculate the average nodal spacing between point
    nodal_points_average_spacing = (prod([(Xp_lastS-Xp_firstS) (Yp_lastS-Yp_firstS)].*SpacingSize)^(1/ImageDimensionality))/(size(fixed_points_MLS,1)^(1/ImageDimensionality) - 1);

    %First save the variables, then adjust the variable values that
    %need to be changed
    MLS_Param.fixed_image = fixed_image;
    MLS_Param.moving_image = moving_image;
    MLS_Param.DimensionSize = DimensionSize;
    MLS_Param.ImageDimensionality = ImageDimensionality;
    MLS_Param.Origin = Origin;
    MLS_Param.PixelDimensionality = PixelDimensionality;
    MLS_Param.SpacingSize = SpacingSize;
    MLS_Param.displacement_eq = displacement_eq;
    MLS_Param.image_x_axis = image_x_axis;
    MLS_Param.image_y_axis = image_y_axis;
    MLS_Param.strain_eq = strain_eq;
    MLS_Param.units_of_measurement_adjust = units_of_measurement_adjust;

    %% Run Meshless Method and retireve values for displacement and strain.
    if use_image_grid
        [displacement,strain] = Meshless_Method_MLS(fixed_points_MLS,moving_points_MLS,beta,neighbouring_points_min,nodal_points_average_spacing,use_calculated_displacement,display_figures,MLS_Param);
    else
        [displacement,strain] = Meshless_Method_MLS(fixed_points_MLS,moving_points_MLS,beta,neighbouring_points_min,use_calculated_displacement,display_figures,MLS_Param);
    end
    
    display('Finished Meshless Method')

end

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
    Skeletonization_Draw_Boundary_Box(fixed_image_feature_find_subimages_boundary_MLS,0.5,['r','g']);

    Skeletonization_Display_Figure(moving_image, Origin, SpacingSize, DimensionSize, 'Moving Image with Matched Feature Points for Feature Reg');
    Skeletonization_Add_Points(moving_points_MLS, 10.5, 'r.');
    Skeletonization_Draw_Boundary_Box(moving_image_feature_find_subimages_boundary_MLS,0.5,['r','g']);

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

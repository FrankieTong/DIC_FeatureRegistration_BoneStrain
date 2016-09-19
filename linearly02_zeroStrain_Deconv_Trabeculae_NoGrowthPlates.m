
%Skeleton Parameters:
%fixed_image_param.thresh_num = 40;
%fixed_image_param.threshold = 15;

%moving_image_param.thresh_num = 40;
%moving_image_param.threshold = 13;

%BlockSize = 93;
%MaxRatio = 0.600000;
%MaxThreshold = 10;

%morph_close = 0;
%morph_endpoints = 0;

%clean_up_images = 1;

%downsample_scaling = 2.000000;

%segment_refine = 1000.000000;

%%
%Additional image information that will be useful when displaying
%information

%Input Image
%PixelType float
PixelDimensionality = 1;
ImageDimensionality = 2;
DimensionSize = [349 563];
SpacingSize = [0.00175 0.00175];
Origin = [0 0];
%HeaderSize 0
%ByteOrder little


units_of_measurement_adjust = 10000;

%Read in image files related to these positions

%fid=fopen('B2R2_0Turns_Centred_Aligned_Float.am-Orthoslice.raw');
fid=fopen('B2R2_0Turns_Centred_Aligned_Float.scaled_Deconv-Trabeculae-NoGrowthPlates.am-OrthoSlice.raw');
fixed_image = fread(fid, DimensionSize, 'float32=>float32').';

%fid=fopen('Linearly02_Deformed_Scan_ZeroStrain.am-OrthoSlice.raw');
fid=fopen('Linearly02_Deformed_Scan_ZeroStrain_Deconv_Trabeculae_NoGrowthPlates.am-OrthoSlice.raw');
moving_image = fread(fid, DimensionSize, 'float32=>float32').';

% fid=fopen('B2R2_0Turns_Centred_Aligned_Float.scaled_Deconv-Trabeculae-NoGrowthPlates.am-OrthoSlice.raw');
% fixed_image_skeletonize = fread(fid, DimensionSize, 'float32=>float32').';
% 
% fid=fopen('Linearly02_Deformed_Scan_ZeroStrain_Deconv_Trabeculae_NoGrowthPlates.am-OrthoSlice.raw');
% moving_image_skeletonize = fread(fid, DimensionSize, 'float32=>float32').';

%fid=fopen('B2R2_0Turns_Centred_Aligned_Res_Float.am-OrthoSlice.raw');
%fixed_image_bin = fread(fid, DimensionSize, 'float32=>float32').';

%fid=fopen('Lineary02_DeformedScan.am-OrthoSlice.raw');
%moving_image_bin = fread(fid, DimensionSize, 'float32=>float32').';

image_x_axis = linspace(Origin(1),Origin(1)+ SpacingSize(1)*(DimensionSize(1)-1), DimensionSize(1));
image_y_axis = linspace(Origin(2),Origin(2)+ SpacingSize(2)*(DimensionSize(2)-1), DimensionSize(2));



%moving_points_ideal = fixed_points;
%moving_points_ideal(:,2) = fixed_points(:,2) + 0.5*(1/(DimensionSize(2)*SpacingSize(2)))*linearly_increasing_strain*fixed_points(:,2).^2;

%displacement_vectors_ideal = moving_points_ideal - fixed_points;

%strain_vectors_ideal = zeros(size(fixed_points,1),2);
%strain_vectors_ideal(:,2) = (1/(DimensionSize(2)*SpacingSize(2)))*linearly_increasing_strain*fixed_points(:,2);


linearly_increasing_strain = -0.02;
displacement_offset = 0.009835;

if exist('units_of_measurement_adjust','var')
    SpacingSize = SpacingSize.*units_of_measurement_adjust;
    Origin = Origin.*units_of_measurement_adjust;
    displacement_offset = displacement_offset.*units_of_measurement_adjust;
    image_x_axis = image_x_axis.*units_of_measurement_adjust;
    image_y_axis = image_y_axis.*units_of_measurement_adjust;
end

% moving_points_ideal = fixed_points;
% moving_points_ideal(:,2) = fixed_points(:,2) + 0.5*(1/(DimensionSize(2)*SpacingSize(2)))*linearly_increasing_strain*fixed_points(:,2).^2+displacement_offset;
% 
% displacement_vectors_ideal = moving_points_ideal - fixed_points;
% 
% strain_vectors_ideal = zeros(size(fixed_points,1),2);
% strain_vectors_ideal(:,2) = (1/(DimensionSize(2)*SpacingSize(2)))*linearly_increasing_strain*fixed_points(:,2);

displacement_eq = @(x) [zeros(size(x,1),1) -(0.5*(1/(DimensionSize(2)*SpacingSize(2)))*linearly_increasing_strain*x(:,2).^2+displacement_offset) zeros(size(x,1),size(x,2)-2)];
strain_eq = @(x) [zeros(size(x,1),1) -(1/(DimensionSize(2)*SpacingSize(2)))*linearly_increasing_strain.*x(:,2) zeros(size(x,1),size(x,2)-2)];
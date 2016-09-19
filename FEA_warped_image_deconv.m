
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

fid=fopen('B2R2_0Turns_Centred_Aligned_Float.am-Orthoslice.raw');
%fid=fopen('B2R2_0Turns_Centred_Aligned_Float.scaled_Deconv-Trabeculae-NoGrowthPlates.am-OrthoSlice.raw');
fixed_image = fread(fid, DimensionSize, 'float32=>float32').';

%fid=fopen('Linearly02_Deformed_Scan_ZeroStrain.am-OrthoSlice.raw');
%fid=fopen('FEA_warped_image_deconv.raw');
fid = fopen('FEA_warped_image.raw');
moving_image = fread(fid, DimensionSize, 'float32=>float32').';

image_x_axis = linspace(Origin(1),Origin(1)+ SpacingSize(1)*(DimensionSize(1)-1), DimensionSize(1));
image_y_axis = linspace(Origin(2),Origin(2)+ SpacingSize(2)*(DimensionSize(2)-1), DimensionSize(2));

clear fixed_image_name;
clear moving_image_name;

fixed_image_name = 'B2R2_0Turns_Centred_Aligned_Float.am-OrthoSlice.tif';
moving_image_name = 'FEA_warped_image.tif';



% Define the region of the image to be registerted (corner pixel locations
% of the region of interest)
clear Xp_firstS;
clear Yp_firstS;
clear Xp_lastS;
clear Yp_lastS;

Xp_firstS(1) =	80;
Yp_firstS(1) =	150;
Xp_lastS(1) =	290;
Yp_lastS(1) =	450;


%Read in displacement (and strain) fields that applied the deformation
fid = fopen('FEA_disp_original.raw');
displacement_field_readin = fread(fid, 'float32=>float32');
displacement_field_readin = reshape(displacement_field_readin, [ImageDimensionality, DimensionSize]);
displacement_field_readin = permute(displacement_field_readin, [3,2,1]);

fid = fopen('FEA_strain_original.raw');
strain_field_readin = fread(fid, 'float32=>float32');
strain_field_readin = reshape(strain_field_readin, [ImageDimensionality, DimensionSize]);
strain_field_readin = permute(strain_field_readin, [3,2,1]);

if exist('units_of_measurement_adjust','var')
    SpacingSize = SpacingSize.*units_of_measurement_adjust;
    Origin = Origin.*units_of_measurement_adjust;
    displacement_field_readin = displacement_field_readin.*units_of_measurement_adjust;
    image_x_axis = image_x_axis.*units_of_measurement_adjust;
    image_y_axis = image_y_axis.*units_of_measurement_adjust;
end

%Generate the interpolating function for the displacement field in order to
%get ideal displacement values when calculating error

% use interp2 instead individually on the 2 layers...

[X_grid,Y_grid] = meshgrid(image_x_axis,image_y_axis);

displacement_eq = @(n) [interp2(X_grid,Y_grid,displacement_field_readin(:,:,1),n(:,1),n(:,2),'spline'), interp2(X_grid,Y_grid,displacement_field_readin(:,:,2),n(:,1),n(:,2),'spline'), zeros(size(n,1),size(n,2)-2)];
strain_eq = @(n) [interp2(X_grid,Y_grid,strain_field_readin(:,:,1),n(:,1),n(:,2),'spline'), interp2(X_grid,Y_grid,strain_field_readin(:,:,2),n(:,1),n(:,2),'spline'), zeros(size(n,1),size(n,2)-2)];

clear Xgrid;
clear Ygrid;
clear displacement_field_readin;
clear strain_field_readin;


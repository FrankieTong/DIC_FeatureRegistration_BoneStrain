%load standardResampleScaleMatch_1p1and2_subpixel_Skeleton

load standardResampleScaleMatch_1p1and2_subpixel_alligned
%load standardResampleScaleMatch_1p1and2_subpixel

%Additional image information that will be useful when displaying
%information

% Input Image
% PixelType float
% PixelDimensionality = 1;
% ImageDimensionality = 3;
% DimensionSize = [211 229 1];
% SpacingSize = [0.0007 0.0007 0.0007];
% Origin = [0 0 0];
% HeaderSize 0
% ByteOrder little

%Input Image
%PixelType float
PixelDimensionality = 1;
ImageDimensionality = 2;
DimensionSize = [211 229];
SpacingSize = [0.0007 0.0007];
Origin = [0 0];
%HeaderSize 0
%ByteOrder little

units_of_measurement_adjust = 10000;



fid=fopen('Mik_Rat713_L1-L3_crop.nii-OrthoSlice.raw');
fixed_image = fread(fid, DimensionSize, 'float32=>float32').';

fid=fopen('Mik_Rat713_L1-L3_crop.nii-OrthoSlice_20.raw');
moving_image = fread(fid, DimensionSize, 'float32=>float32').';


image_x_axis = linspace(Origin(1),Origin(1)+ SpacingSize(1)*DimensionSize(1), DimensionSize(1));
image_y_axis = linspace(Origin(2),Origin(2)+ SpacingSize(2)*DimensionSize(2), DimensionSize(2));

linear_strain = -0.2;
displacement_offset = 0;

if exist('units_of_measurement_adjust','var')
    SpacingSize = SpacingSize.*units_of_measurement_adjust;
    Origin = Origin.*units_of_measurement_adjust;
    displacement_offset = displacement_offset.*units_of_measurement_adjust;
    image_x_axis = image_x_axis.*units_of_measurement_adjust;
    image_y_axis = image_y_axis.*units_of_measurement_adjust;
end

displacement_eq = @(x) [zeros(size(x,1),1) linear_strain.*x(:,2) zeros(size(x,1),size(x,2)-2)];
strain_eq = @(x) [zeros(size(x,1),1) linear_strain*ones(size(x,1),1) zeros(size(x,1),size(x,2)-2)];

% %Read in image files related to these positions
% 
% fid=fopen('Mik_Rat713_L1-L3_crop.nii-OrthoSlice.raw');
% %fixed_image = fread(fid, DimensionSize, 'float32=>float32').';
% fixed_image_raw = fread(fid, matrix_size_total, 'float32=>float32');
% fixed_image = reshape(fixed_image_raw, DimensionSize)';
% fixed_image = shiftdim(fixed_image,2);
% 
% fid=fopen('Mik_Rat713_L1-L3_crop.nii-OrthoSlice_20.raw');
% %moving_image = fread(fid, DimensionSize, 'float32=>float32').';
% moving_image_raw = fread(fid, matrix_size_total, 'float32=>float32');
% moving_image = reshape(moving_image_raw, DimensionSize)';
% moving_image = shiftdim(moving_image,2);
% 
% fid=fopen('Mik_Rat713_L1-L3_crop_Deconv-OrthoSlice_Binary_4000_islands.raw');
% %fixed_image_bin = fread(fid, DimensionSize, 'float32=>float32').';
% fixed_image_bin_raw = fread(fid, matrix_size_total, 'float32=>float32');
% fixed_image_bin = reshape(fixed_image_bin_raw, DimensionSize)';
% fixed_image_bin = shiftdim(fixed_image_bin,2);
% 
% fid=fopen('Mik_Rat713_L1-L3_crop_Deconv-OrthoSlice_20_Binary_4000_islands.raw');
% %moving_image_bin = fread(fid, DimensionSize, 'float32=>float32').';
% moving_image_bin_raw = fread(fid, matrix_size_total, 'float32=>float32');
% moving_image_bin = reshape(moving_image_bin_raw, DimensionSize)';
% moving_image_bin = shiftdim(moving_image_bin,2);
% 
% image_x_axis = linspace(Origin(1),Origin(1)+ SpacingSize(1)*DimensionSize(1), DimensionSize(1));
% image_y_axis = linspace(Origin(2),Origin(2)+ SpacingSize(2)*DimensionSize(2), DimensionSize(2));
% 
% moving_points_ideal = fixed_points;
% moving_points_ideal(:,2) = 0.9*fixed_points(:,2);
% 
% 

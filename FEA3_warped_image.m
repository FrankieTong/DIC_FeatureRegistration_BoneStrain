
%%
%Additional image information that will be useful when displaying
%information

%Input Image
%PixelType float
PixelDimensionality = 1;
ImageDimensionality = 2;
DimensionSize = [357 462];
SpacingSize = [0.002 0.002];
Origin = [0 0];
%HeaderSize 0
%ByteOrder little


units_of_measurement_adjust = 10000;

%Read in image files related to these positions

fid=fopen('5-300.am-OrthoSlice.raw');
fixed_image = fread(fid, DimensionSize, 'float32=>float32').';

fid=fopen('FEA3_warped_original.raw');
moving_image = fread(fid, DimensionSize, 'float32=>float32').';

image_x_axis = linspace(Origin(1),Origin(1)+ SpacingSize(1)*(DimensionSize(1)-1), DimensionSize(1));
image_y_axis = linspace(Origin(2),Origin(2)+ SpacingSize(2)*(DimensionSize(2)-1), DimensionSize(2));

%Overwrite fixed image and moving image variable names
clear fixed_image_name;
clear moving_image_name;

fixed_image_name = '5-300.am-OrthoSlice.tif';
moving_image_name = 'FEA3_warped_original.tif';


% Define the region of the image to be registerted (corner pixel locations
% of the region of interest)
clear Xp_firstS;
clear Yp_firstS;
clear Xp_lastS;
clear Yp_lastS;

Xp_firstS(1) =	145;
Yp_firstS(1) =	200;
Xp_lastS(1) =	260;
Yp_lastS(1) =	400;

%Define initial displacement guesses for the image (in pixels)
% clear qoS;
% qoS = [0;0;0;0;0;0];
% qoS(1) = -57; %u displacement initial guess
% qoS(2) = 38; %v displacement initial guess
% 
% Xp_firstS(1) =	145;
% Yp_firstS(1) =	50;

%Read in displacement (and strain) fields that applied the deformation
fid = fopen('FEA3_disp_original.raw');
displacement_field_readin = fread(fid, 'float32=>float32');
displacement_field_readin = reshape(displacement_field_readin, [ImageDimensionality, DimensionSize]);
displacement_field_readin = permute(displacement_field_readin, [3,2,1]);

fid = fopen('FEA3_strain_original.raw');
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


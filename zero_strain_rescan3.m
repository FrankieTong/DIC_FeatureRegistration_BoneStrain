
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

fid=fopen('6-300.Resampled.am-OrthoSlice.raw');
moving_image = fread(fid, DimensionSize, 'float32=>float32').';

image_x_axis = linspace(Origin(1),Origin(1)+ SpacingSize(1)*(DimensionSize(1)-1), DimensionSize(1));
image_y_axis = linspace(Origin(2),Origin(2)+ SpacingSize(2)*(DimensionSize(2)-1), DimensionSize(2));

%Overwrite fixed image and moving image variable names
clear fixed_image_name;
clear moving_image_name;

fixed_image_name = '5-300.am-OrthoSlice.tif';
moving_image_name = '6-300.Resampled.am-OrthoSlice.tif';


% Define the region of the image to be registerted (corner pixel locations
% of the region of interest)
clear Xp_firstS;
clear Yp_firstS;
clear Xp_lastS;
clear Yp_lastS;

Xp_firstS(1) =	130;
Yp_firstS(1) =	60;
Xp_lastS(1) =	250;
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
if exist('units_of_measurement_adjust','var')
    SpacingSize = SpacingSize.*units_of_measurement_adjust;
    Origin = Origin.*units_of_measurement_adjust;
    image_x_axis = image_x_axis.*units_of_measurement_adjust;
    image_y_axis = image_y_axis.*units_of_measurement_adjust;
end

displacement_eq = @(x) [zeros(size(x,1),size(x,2))];
strain_eq = @(x) [zeros(size(x,1),size(x,2))];

clear Xgrid;
clear Ygrid;
clear displacement_field_readin;
clear strain_field_readin;


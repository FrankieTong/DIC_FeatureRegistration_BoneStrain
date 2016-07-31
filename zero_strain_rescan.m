%{
This script defines image parameters for fixed and moving images to be used with the main DIC_Scripting_for_Feature_Registration.m script.

Fixed and moving images have to be present in both .raw format (float32) and in .tif format as feature registration uses .raw image format
while DVC uses .tif format.

This script is specifically for a zero strain test example.

%}


%% Defining parameters for fixed and moving images.

%Input Image Parameters (fixed and moving images)
PixelDimensionality = 1;			%Pixel dimension size. Has to be 1 since program only uses scalar images.
ImageDimensionality = 2;			%Image dimension size. Has to be 2 since program only uses 2D images.
DimensionSize = [349 563];			%X and Y dimension size of the image. In pixels.
SpacingSize = [0.00175 0.00175];	%Spacing size of the images. Can use units_of_measurement_adjust to adjust it to other units of measure.
Origin = [0 0];						%Location of origin of the images. Can use units_of_measurement_adjust to adjust it to other units of measure.

units_of_measurement_adjust = 10000;	%Adjusts the orgin and spacing size using this value as a multiplicative factor (ie: NewOrigin = Origin*units_of_measurement_adjust and NewSpacingSize = SpacingSize*units_of_measurement_adjust)

%Read in image files

% Read in fixed image in raw format for feature registraiton
fid=fopen('B2R2_0Turns_Centred_Aligned_Float.am-OrthoSlice.raw');
fixed_image = fread(fid, DimensionSize, 'float32=>float32').';

% Read in moving image in raw format for feature registraiton
fid=fopen('B2R2_0Turns2_ReRecon_Realligned.am-OrthoSlice.raw');
moving_image = fread(fid, DimensionSize, 'float32=>float32').';

% Provide names for fixed and moving image in tif format for DVC matching
fixed_image_name = 'B2R2_0Turns_Centred_Aligned_Float.am-OrthoSlice.tif';
moving_image_name = 'B2R2_0Turns2_ReRecon_Realligned.am-OrthoSlice.tif';

%% Define the region of the image to be registerted (corner pixel locations of the region of interest)
clear Xp_firstS;
clear Yp_firstS;
clear Xp_lastS;
clear Yp_lastS;

% Define top left corner of the region of interest (in pixels)
Xp_firstS(1) =	100; 
Yp_firstS(1) =	100;

% Define bottom right corner of the region of interest (in pixels)
Xp_lastS(1) =	260;
Yp_lastS(1) =	485;

%% Adjust the spacing size and origin with the multiplicative factor (if neccessary)
if exist('units_of_measurement_adjust','var')
    SpacingSize = SpacingSize.*units_of_measurement_adjust;
    Origin = Origin.*units_of_measurement_adjust;
end

%% Calculate the locations of the x and y axis of the iamge grid
image_x_axis = linspace(Origin(1),Origin(1)+ SpacingSize(1)*(DimensionSize(1)-1), DimensionSize(1));
image_y_axis = linspace(Origin(2),Origin(2)+ SpacingSize(2)*(DimensionSize(2)-1), DimensionSize(2));

%% Give the equations for the ideal displacement and strain. Since this is a zero strain test case, the values for both displacement and strain are zero.
displacement_eq = @(x) [zeros(size(x,1),size(x,2))];
strain_eq = @(x) [zeros(size(x,1),size(x,2))];



function [movingRegisteredVolume, r_reg] = registerVolumes(movingImage, staticImage)
%Function registers two scan essentially just hides details of imregister
%Michael Hardisty February 2014

%commented out as this required building which I am still working on
%not needed as matlab native image registration routine worked
%Options = struct('Registration', 'Affine', 'Similarity', 'gd');    %Affine corresponds to the registration being an affine registration.  gd corresponds to similarity.  this all makes a structure under options
%[registeredImage,Grid,Spacing,M,B,F] = image_registration(staticImage,beforeLoading_image,Options);

%[movingImage, preLoading_info] = ReadData3D;
%[staticImage, afterLoading_info] = ReadData3D;

centerFixed = int16(size(staticImage)/2);
centerMoving = int16(size(movingImage)/2);
figure, title('Unregistered Axial slice');
imshowpair(movingImage(:,:,centerMoving(3)), staticImage(:,:,centerFixed(3)));


[optimizer,metric] = imregconfig('monomodal');
%Rfixed  = imref3d(size(staticImage),preLoading_info.PixelDimensions(2),preLoading_info.PixelDimensions(1),preLoading_info.SliceThickness);
%Rmoving = imref3d(size(movingImage),preLoading_info.PixelDimensions(2),preLoading_info.PixelDimensions(1),preLoading_info.SliceThickness);
%optimizer.InitialRadius = 0.004;


optimizer.MaximumStepLength  = optimizer.MaximumStepLength * 10

[movingRegisteredVolume, r_reg] = imregister('DisplayOptimization',1, movingImage,staticImage, 'rigid', optimizer, metric);

figure, title('Axial slice of registered volume.');
imshowpair(movingRegisteredVolume(:,:,centerFixed(3)), staticImage(:,:,centerFixed(3)));
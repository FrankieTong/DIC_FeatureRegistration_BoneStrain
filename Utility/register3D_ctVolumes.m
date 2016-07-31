% Register 2 DicomScans write out the scans in a subdir within original
% path

%commented out as this required building which I am still working on
%Options = struct('Registration', 'Affine', 'Similarity', 'gd');    %Affine corresponds to the registration being an affine registration.  gd corresponds to similarity.  this all makes a structure under options
%[registeredImage,Grid,Spacing,M,B,F] = image_registration(afterLoading_image,beforeLoading_image,Options);

%[preLoading_image, preLoading_info] = ReadData3D;
%[afterLoading_image, afterLoading_info] = ReadData3D;

centerFixed = int16(size(afterLoading_image)/2);
centerMoving = int16(size(preLoading_image)/2);
figure, title('Unregistered Axial slice');
imshowpair(preLoading_image(:,:,centerMoving(3)), afterLoading_image(:,:,centerFixed(3)));


[optimizer,metric] = imregconfig('monomodal');
%Rfixed  = imref3d(size(afterLoading_image),preLoading_info.PixelDimensions(2),preLoading_info.PixelDimensions(1),preLoading_info.SliceThickness);
%Rmoving = imref3d(size(preLoading_image),preLoading_info.PixelDimensions(2),preLoading_info.PixelDimensions(1),preLoading_info.SliceThickness);
%optimizer.InitialRadius = 0.004;
movingRegisteredVolume = imregister(preLoading_image,afterLoading_image, 'rigid', optimizer, metric);

figure, title('Axial slice of registered volume.');
imshowpair(movingRegisteredVolume(:,:,centerFixed(3)), afterLoading_image(:,:,centerFixed(3)));
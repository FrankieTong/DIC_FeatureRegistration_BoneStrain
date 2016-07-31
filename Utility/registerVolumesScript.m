%registerVolumes
%Michael Hardisty February 2014

%load images
[afterLoading_image, afterLoading_info] = ReadData3D;
[preLoading_image, prerLoading_info] = ReadData3D;

%focus on ROI in centre to reduce the size
afterLoading_image = afterLoading_image(:,:,400:1100);
preLoading_image = preLoading_image(:,:,400:1100);

%downsample 
afterLoadingDownSampled = image_downsample(afterLoading_image,2);
preLoadingDownSampled = image_downsample(preLoading_image,2);

%downsample more - not necessary
%afterLoadingDownSampled = image_downsample(afterLoadingDownSampled,2);
%preLoadingDownSampled = image_downsample(preLoadingDownSampled,2);

[preLoadingRegistered, r_reg] = registerVolumes(preLoadingDownSampled,afterLoadingDownSampled);

figure('Name', 'preLoadingDownSampled');
imshow(preLoadingDownSampled(:,:,100),'DisplayRange', [0,10000]);

figure('Name', 'afterLoadingDownSampled');
imshow(afterLoadingDownSampled(:,:,100),'DisplayRange', [0,10000]);

figure('Name', 'preLoadingRegistered');
imshow(preLoadingRegistered(:,:,100),'DisplayRange', [0,10000]);
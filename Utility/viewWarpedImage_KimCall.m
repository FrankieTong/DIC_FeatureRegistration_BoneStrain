global parent_path
specNum = 4; % group 5 and 7
parent_path = 'D:\users\hardisty\Data\mike\Dropbox\DIC_2010_06\DIC_Outputs_for_2012-07-05_Specimen4\DIC_Outputs_for_2012-08-13_S4_DiffGroup5';

WSpath = [parent_path,'\Copy of Workspace\'];
pic_nameW = [parent_path,'\warpedImage.tif'];
pic_nameT = [parent_path,'\targetImage.tif'];
        
if specNum == 1
    refImage = imread('D:\users\hardisty\Data\mike\Dropbox\DIC_2010_06\Frames_Specimen1\100increm_ENTIRE_cropped_nonhist\100increm_ENTIRE_cropped_nonhist_00.tif');
    numofFrames = 20;
elseif specNum == 2
    refImage = imread('D:\users\hardisty\Data\mike\Dropbox\DIC_2010_06\Frames_Specimen2\100increm_ENTIRE_cropped_nonhist\100increm_ENTIRE_cropped_nonhist_00.tif');
    numofFrames = 18;
elseif specNum == 4
    refImage = imread('D:\users\hardisty\Data\mike\Dropbox\DIC_2010_06\Frames_Specimen4\100increm_ENTIRE_cropped_nonhist\100increm_ENTIRE_cropped_nonhist_00.tif');
    numofFrames = 9;
elseif specNum == 5
    refImage = imread('D:\users\hardisty\Data\mike\Dropbox\DIC_2010_06\Frames_Specimen5\100increm_ENTIRE_cropped_nonhist\100increm_ENTIRE_cropped_nonhist_00.tif');
    numofFrames = 23;
end

global pic_nameW pic_nameT
for t=1:numofFrames;
    WSpath_full = [WSpath,'Workspace',num2str(t),'.mat'];
    viewWarpedImage_Kim(refImage,WSpath_full,[false false false],[true true true]);
        % measure correlation values between the warped and target images
    Rsq(t) = viewWarpedImage_Kim_CorrImages (pic_nameW,pic_nameT);  
    frames(t) = 100*t;
end

clear CorrImages
CorrImages = [frames' Rsq'];

close all
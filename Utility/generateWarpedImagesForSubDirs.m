%create Warped Images for all jobs that don't have any that are subdirs of
%the current directory

 matFileList = dir_matlab('*.mat');
 
 numMatFiles = size(matFileList,1);
 
 
 %load appropriate orgImage
 indFile = 0;
 matData = struct([]);
 while isempty(fieldnames(matData))
    indFile = indFile + 1;
    matData = load(matFileList{indFile},'Input_info');
 end
 
 [pathstrOrg, nameOrg, extOrg] = fileparts(matData.Input_info{1});
 %currentOrgImageDrive = pathstrOrg(1:3);
 currentDir = pwd;
 currentDrive = currentDir(1:3);
 cd(currentDrive);
 currentOrgImageFileName = dir_matlab([nameOrg extOrg]);
 cd(currentDir);
 currentOrgImage = imread(currentOrgImageFileName{1});
 
 while indFile < numMatFiles
     
     [pathstr, filestr] = fileparts(matFileList{indFile});
     [pathstrNext, filestrNext] = fileparts(matFileList{indFile+1});
     
     currentDir = pwd;
     [orgImageROI, warpedImageROI,targetImageROI] = viewWarpedImage(currentOrgImage, matFileList{indFile}, [false false false],[false false false]);
     cd(pathstr);
     imwrite(uint8(orgImageROI),['orgImageROI' filestr(10:end) '.tif']);
     imwrite(uint8(warpedImageROI),['warpedImageROI' filestr(10:end) '.tif']);
     imwrite(uint8(targetImageROI),['targetImageROI' filestr(10:end) '.tif']);
     cd(currentDir);
     
     if strcmp(pathstrNext,pathstr) ~= 1
         %assume that it is the last matfile in the dir and that the warped
         %images should be ouput
         %[orgImageROI, warpedImageROI,targetImageROI] = viewWarpedImage(currentOrgImage, matFileList{indFile}, [true true true],[false false false]);

         
         matData = load(matFileList{indFile+1},'Input_info');
         while isempty(fieldnames(matData))
            indFile = indFile + 1;
            matData = load(matFileList{indFile+1},'Input_info');
         end
         [pathstrOrg, nameOrg, extOrg] = fileparts(matData.Input_info{1});
         %currentOrgImageDrive = pathstrOrg(1:3);
         currentDir = pwd;
         currentDrive = currentDir(1:3);
         cd(currentDrive);
         currentOrgImageFileName = dir_matlab([nameOrg extOrg]);
         cd(currentDir);
         currentOrgImage = imread(currentOrgImageFileName{1});
     end
     indFile = indFile +1; 
 end
 
 [orgImageROI, warpedImageROI,targetImageROI] = viewWarpedImage(currentOrgImage, matFileList{numMatFiles}, [true true true],[false false false]);
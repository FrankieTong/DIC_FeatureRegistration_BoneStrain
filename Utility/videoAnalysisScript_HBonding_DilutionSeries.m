%Analyse Files for DIC video
%assuming
%o background
%1 bone
%2 dot area
%3 second dot area out of plane

%[ndata, previousFileList, ~] = xlsread('C:\Documents and Settings\hardisty\My Documents\Mike\Dropbox\HydrogenBondingStiffness\Segmentation\whitening_Size_Summary_Save.xlsx', 'a:a');
%[~, ~, alldata] = xlsread('C:\Documents and Settings\hardisty\My Documents\Mike\Dropbox\HydrogenBondingStiffness\Segmentation\whitening_Size_Summary_Save.xlsx', 'c:d');


dir = 'C:\Mike\Dropbox\Whitening_Demin\HydrogenBondingStiffness\Extracted_Video_Data\Segmentation\311_Descending_Segmentation_only_Cam2';
%segList = dir_matlab( [dir '\*P10_80*.labels.tif'] );

fileList = dir_matlab( [dir '\*.labels.tif'] );

segList = fileList;

imageList = dir_matlab( [dir '\*avg.tif'] );

fileCount = size(fileList,1);

%segList = cell(fileCount,1);
%imageList = cell(fileCount,1);
thresholdGuesses = cell(fileCount,2);
dotThresholds = ones(fileCount,2);


for ind = 1:fileCount
	%segList{ind} = [dir '\' fileList{ind+1} '.labels.tif'];
    %imageList{ind} = [dir '\' fileList{ind+1} '.tif'];
    dotThresholds(ind,1)= NaN;
    dotThresholds(ind,2)= NaN;
end

%imageCount = 1;
%mageList{imageCount} = 'C:\Documents and Settings\hardisty\My Documents\Mike\Dropbox\HydrogenBondingStiffness\MH_MS_2510_MD_Test_HBonding_camera1_P10_90_C001S0001\MH_MS_2510_MD_Test_HBonding_camera1_P10_90_C001S00010000.tif';
%segList{imageCount} = 'C:\Documents and Settings\hardisty\My Documents\Mike\Dropbox\HydrogenBondingStiffness\MH_MS_2510_MD_Test_HBonding_camera1_P10_90_C001S0001\MH_MS_2510_MD_Test_HBonding_camera1_P10_90_C001S00010000.labels.tif';
%imageCount = imageCount +1;
%imageList{imageCount} = 'C:\Documents and Settings\hardisty\My Documents\Mike\Dropbox\HydrogenBondingStiffness\MH_MS_2510_MD_Test_HBonding_camera1_P10_90_C001S0001\MH_MS_2510_MD_Test_HBonding_camera1_P10_90_C001S00010577.tif';
%segList{imageCount} = 'C:\Documents and Settings\hardisty\My Documents\Mike\Dropbox\HydrogenBondingStiffness\MH_MS_2510_MD_Test_HBonding_camera1_P10_90_C001S0001\MH_MS_2510_MD_Test_HBonding_camera1_P10_90_C001S00010577.labels.tif';
%imageCount = imageCount +1;
%imageList{imageCount} = 'C:\Documents and Settings\hardisty\My Documents\Mike\Dropbox\HydrogenBondingStiffness\MH_MS_2510_MD_Test_HBonding_camera1_P10_90_C001S0001\MH_MS_2510_MD_Test_HBonding_camera1_P10_90_C001S00010793.tif';
%segList{imageCount} = 'C:\Documents and Settings\hardisty\My Documents\Mike\Dropbox\HydrogenBondingStiffness\MH_MS_2510_MD_Test_HBonding_camera1_P10_90_C001S0001\MH_MS_2510_MD_Test_HBonding_camera1_P10_90_C001S00010793.labels.tif';
%imageCount = imageCount +1;
%check image and segmentation





ouputSummary = cell(2,6);

ouputSummary{1,1} = 'fileName';
ouputSummary{1,2} = 'Bone_Thickness';
ouputSummary{1,3} = 'dotTheshold1';
ouputSummary{1,4} = 'dotTheshold2';

for indLabel = 1:5
    ouputSummary{1,(indLabel-1)*3+5} = sprintf('Area_%d',indLabel);
    ouputSummary{1,(indLabel-1)*3+6} = sprintf('Avg_%d',indLabel);
    ouputSummary{1,(indLabel-1)*3+7} = sprintf('Std_%d',indLabel);
end



for ind = 1:fileCount
    seg = imread([segList{ind}]);
    image = imread([imageList{ind}]);
    %figure('Name',['segmentation - ' segList{ind}]);
    %imshow(seg,[0 4]);
    %choice1 = questdlg('is this correct?');
    %figure('Name',['image - ' imageList{ind}]);
    %imshow(image,[1 255]);
    %choice2 = questdlg('is this correct?');
	choice1 = 'Yes';
	choice2	= 'Yes';
    
    [image_pathstr, image_name, image_ext] = fileparts(imageList{ind});
    
    ouputSummary{ind+1,1} = image_name;
    
    if strcmp(choice1,'Yes') && strcmp(choice2,'Yes') 
        imgMaskBone = seg==1;
        
		dotThreshold1 = dotThresholds(ind,1);
		dotThreshold2 = dotThresholds(ind,2);
		
        if isnan(dotThreshold1)
            dotsMultImage1 = (seg==2) .* double(image);
            dotThreshold1 = thresh_tool(uint8(dotsMultImage1));
        end
        if isnan(dotThreshold2)
            dotsMultImage2 = (seg==3) .* double(image);
            dotThreshold2 = thresh_tool(uint8(dotsMultImage2));
        end
        
		
        %new definition
        %o background
        %1 bone
        %2 black dot area
        %3 white dot area
        %4 second black dot area out of plane
        %5 second white dot area out of plane

        newSeg = (seg == 2).*(((double(image) > dotThreshold1) .* 3 + 2 .* (double(image) < dotThreshold1)))...
            + (seg == 3).*(((double(image) > dotThreshold2) .* 5 + 4 .* (double(image) < dotThreshold2)))...
            + ((seg ~= 2) .* (seg ~= 3)) .* double(seg);
               
        [ avgDensity, stdDensity, area ] = calc_Avg_STD_Area( image, newSeg);
        thicknessByRow = avgThicknessImgMask(imgMaskBone, 1, 0);
        
        
        
        ouputSummary{ind+1,2} = mean(thicknessByRow(:,5));
        ouputSummary{ind+1,3} = dotThreshold1;
        ouputSummary{ind+1,4} = dotThreshold2;

        for indLabel = 1:5
            ouputSummary{ind+1,(indLabel-1)*3+5} = area(indLabel);
            ouputSummary{ind+1,(indLabel-1)*3+6} = avgDensity(indLabel);
            ouputSummary{ind+1,(indLabel-1)*3+7} = stdDensity(indLabel);
        end 
    end
end

[image_pathstr, image_name, image_ext] = fileparts(imageList{1});

xlswrite([image_pathstr '\whitening_Size_Summary.xlsx'],ouputSummary);
    
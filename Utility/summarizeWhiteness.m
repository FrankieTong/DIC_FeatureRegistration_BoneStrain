function [ whitenessSummaryTable ] = summarizeWhiteness(dir, orgFileNameSuffix, segmentationFileNameSuffix, filetype, dotThresholdsPredefined)

%Analyse Files for DIC video
%assuming
%o background
%1 bone
%2 dot area
%3 second dot area out of plane








%[ndata, previousFileList, ~] = xlsread('C:\Documents and Settings\hardisty\My Documents\Mike\Dropbox\HydrogenBondingStiffness\Segmentation\whitening_Size_Summary_Save.xlsx', 'a:a');
%[~, ~, alldata] = xlsread('C:\Documents and Settings\hardisty\My Documents\Mike\Dropbox\HydrogenBondingStiffness\Segmentation\whitening_Size_Summary_Save.xlsx', 'c:d');


%dir = 'C:\Mike\Dropbox\Whitening_Demin\HydrogenBondingStiffness\Extracted_Video_Data\Segmentation\311_Descending_Segmentation_only_Cam2';
%segList = dir_matlab( [dir '\*P10_80*.labels.tif'] );
if(exist('filetype','var'))
    fileTypeCriteria = ['*.' filetype];
else
    fileTypeCriteria = '*.tif';
end

if ~isempty(orgFileNameSuffix);
	orgSegmentationFileNameList = dir_matlab( [dir '\*' orgFileNameSuffix] );
	orgFileCount = size(orgSegmentationFileNameList,1);
else
	orgSegmentationFileNameList ='';
	orgFileCount = 0;
end	

if isempty(segmentationFileNameSuffix)
    autoSegmentedFileCount = 0;
else
    
    autoSegmentedFileList = dir_matlab( [dir '\*' segmentationFileNameSuffix] );
    autoSegmentedFileCount = size(autoSegmentedFileList,1);
    if autoSegmentedFileCount <2 
        if ~iscell(autoSegmentedFileList)
            autoSegmentedFileCount = 0;
        end
    end

end


masterFileCount = orgFileCount+autoSegmentedFileCount;
masterImageList = cell(masterFileCount,1);
masterSegmentationList = cell(masterFileCount,1);

%assumption that the images have the same file names as the segmentation
%just without the suffix
for ind_file_gen=1:orgFileCount
    currentSearchCriteria = orgSegmentationFileNameList{ind_file_gen}(1:strfind(orgSegmentationFileNameList{ind_file_gen},orgFileNameSuffix)-1);
    currentImageList = dir_matlab( [currentSearchCriteria fileTypeCriteria] );
    newImageList = cell(size(currentImageList,1)-1);
    currentCounter=1;
    for current_index = 1:size(currentImageList,1)
        if strcmp(orgSegmentationFileNameList{ind_file_gen},currentImageList{current_index})==0
            newImageList{currentCounter,1} = currentImageList{current_index,1};
            currentCounter=currentCounter+1;
        end
    end
    masterImageList{ind_file_gen} = newImageList{1};
    masterSegmentationList{ind_file_gen} = orgSegmentationFileNameList{ind_file_gen};
end

%if orgFileCount == 0
%	counter = 0;
%else
	counter = orgFileCount;
%end
	
for ind_file_gen=1:autoSegmentedFileCount
    currentSearchCriteria = autoSegmentedFileList{ind_file_gen}(1:strfind(autoSegmentedFileList{ind_file_gen},segmentationFileNameSuffix)-1);
    currentImageList = dir_matlab( [currentSearchCriteria fileTypeCriteria] );
    %imageList{ind_file_gen} = currentImageList{1};
    currentCounter=1;
    for current_index = 1:size(currentImageList,1)
        if strcmp(autoSegmentedFileList{ind_file_gen},currentImageList{current_index})==0
            newImageList{currentCounter,1} = currentImageList{current_index,1};
            currentCounter=currentCounter+1;
        end
    end
    counter = counter +1;
    masterImageList{counter} = newImageList{1};
    masterSegmentationList{counter} = autoSegmentedFileList{ind_file_gen};
end









%segList = cell(fileCount,1);
%imageList = cell(fileCount,1);
%thresholdGuesses = cell(masterFileCount,2);

dotThresholds = ones(masterFileCount,2);

     


for ind = 1:masterFileCount
    %segList{ind} = [dir '\' fileList{ind+1} '.labels.tif'];
    %imageList{ind} = [dir '\' fileList{ind+1} '.tif'];
    dotThresholds(ind,1)= NaN;
    dotThresholds(ind,2)= NaN;
end
if(exist('dotThresholdsPredefined','var'))
    numDotsThresholds = size(dotThresholdsPredefined,1);
    for dots_ind = 1:numDotsThresholds;
        dotThresholds(ind,1)= dotThresholdsPredefined(ind,1);
        dotThresholds(ind,2)= dotThresholdsPredefined(ind,2);
    end
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



%[image_pathstr, image_name, image_ext] = fileparts(masterImageList{1});



for ind = 1:masterFileCount
    seg = imread([masterSegmentationList{ind}]);
    image = imread([masterImageList{ind}]);
    %figure('Name',['segmentation - ' segList{ind}]);
    %imshow(seg,[0 4]);
    %choice1 = questdlg('is this correct?');
    %figure('Name',['image - ' imageList{ind}]);
    %imshow(image,[1 255]);
    %choice2 = questdlg('is this correct?');
	choice1 = 'Yes';
	choice2	= 'Yes';
    
    [image_pathstr, image_name, image_ext] = fileparts(masterImageList{ind});
    
    ouputSummary{ind+1,1} = image_name;
    
    if strcmp(choice1,'Yes') && strcmp(choice2,'Yes') 
        imgMaskBone = seg==1;
        
        if ind<=orgFileCount
            
            
                dotThreshold1 = dotThresholds(ind,1);
                dotThreshold2 = dotThresholds(ind,2);

                if isnan(dotThreshold1)
                    dotsMultImage1 = (seg==2) .* double(image);
                    if max(max(dotsMultImage1))~= min(min(dotsMultImage1))
						dotThreshold1 = thresh_tool(uint8(dotsMultImage1));
					else
						dotThreshold1 = 0;
                    end
                end
                if isnan(dotThreshold2)
                    dotsMultImage2 = (seg==3) .* double(image);
					if max(max(dotsMultImage2))~= min(min(dotsMultImage2))
						dotThreshold2 = thresh_tool(uint8(dotsMultImage2));
					else
						dotThreshold2 =0;
					end
                end
            
            
            
        else
            dotThreshold1=255;
            dotThreshold2=255;
        end
        
		
        %new definition
        %o background
        %1 bone
        %2 black dot area
        %3 white dot area
        %4 second black dot area out of plane
        %5 second white dot area out of plane
        
        if size(image,3) > 1
            image = image(:,:,1);
        end

        newSeg = (seg == 2).*(((double(image) > dotThreshold1) .* 3 + 2 .* (double(image) < dotThreshold1)))...
            + (seg == 3).*(((double(image) > dotThreshold2) .* 5 + 4 .* (double(image) < dotThreshold2)))...
            + ((seg ~= 2) .* (seg ~= 3)) .* double(seg);
               
        [ avgDensity, stdDensity, area ] = calc_Avg_STD_Area( image, newSeg);
        thicknessByRow = avgThicknessImgMask(imgMaskBone, 1, 0);
        
        
        
        ouputSummary{ind+1,2} = mean(thicknessByRow(:,5));
        ouputSummary{ind+1,3} = dotThreshold1;
        ouputSummary{ind+1,4} = dotThreshold2;
        
        numLabelFields = size(area,1);
        
        for indLabel = 1:numLabelFields
            ouputSummary{ind+1,(indLabel-1)*3+5} = area(indLabel);
            ouputSummary{ind+1,(indLabel-1)*3+6} = avgDensity(indLabel);
            ouputSummary{ind+1,(indLabel-1)*3+7} = stdDensity(indLabel);
        end 
    end
    xlswrite([image_pathstr '\whitening_Size_Summary_WithDots.xlsx'],ouputSummary);
	
end
if ~exist([image_pathstr '\whitening_Size_Summary.xlsx'],'file')
		xlswrite([image_pathstr '\whitening_Size_Summary.xlsx'],ouputSummary);
	end
whitenessSummaryTable = ouputSummary;
end
    
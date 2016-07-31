%script will caluclate optical height, thickness, whitening, and put these
%values on a grid consisten with

%numberOfSecondsToPause = 25*60;

%pause on

%pause(numberOfSecondsToPause);

%batch creation of combined MTS Video Data
%rootVideoDir = 'F:\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data';
rootVideoDir = 'F:\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data\Round2';
%mtsDataFolder = 'C:\Users\hardisty\Dropbox\Whitening_Demin\Demineralized_DIC_to_failure\MTS_Data\Analyzed_Included_In_Database';
analysisIndex = 0;




%1
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2466_s333_Eth_1mm_failure_c1'; 
mtsDataFile{analysisIndex} = 'MH2466_s333_Eth_1mm_failure.xlsx';

%2
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2466_s422_1mm_failure_c1'; 
mtsDataFile{analysisIndex} = 'MH2466_s422_1mm_failure.xlsx';

%3
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2490_Orthog11_1mm_failure_c1';
mtsDataFile{analysisIndex} = 'MH2490_Orthog11_1mm_failure.xlsx';

%4
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2490_Orthog21_1mm_failure_500fps_c1';
mtsDataFile{analysisIndex} = 'MH2490_Orthog21_1mm_failure.xlsx';

%5
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2490_s212_Eth_1mm_failure_c1';
mtsDataFile{analysisIndex} = 'MH2490_s212_Eth_1mm_failure.xlsx';

%6
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2490_s512_1mm_failure_c1';
mtsDataFile{analysisIndex} = 'MH2490_s512_1mm_failure.xlsx';

%7
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2526_Orthog11_1mm_failure_500fps';
mtsDataFile{analysisIndex} = 'MH2526_Orthog_11_1mm_failure.xlsx';

%8
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2526_Orthog31_1mm_nofailure_c1';
mtsDataFile{analysisIndex} = 'MH2526_Orthog31_1mm_failure.xlsx';

%9
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2526_s223_Eth_1mm_failure_c1';
mtsDataFile{analysisIndex} = 'MH2526_s223_Eth_1mm_failure.xlsx';

%10
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2526_s231_1mm_failure_c1';
mtsDataFile{analysisIndex} = 'MH2526_s231_1mm_failure_trial2.xlsx';

%11
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2526_s413_1mm_failure_c1';
mtsDataFile{analysisIndex} = 'MH2526_s413_1mm_failure_trial2.xlsx';

%12
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2526_s432_Eth_1mm_failure_c1';
mtsDataFile{analysisIndex} = 'MH2526_s432_Eth_1mm_failure.xlsx';


    


%make a loop for all values of analysisIndex*********

transformFileList = cell(analysisIndex,1);

%assumption about file structure
%unalignedFrames are in \Frames
%The target to be used for alignment are in the directory TargetUsed
	%targetVideoImage.tif is the target from the video
	%standardUsed075mmCrop.tif is the original target 
    
startIndex = 1;

whitenessSummaryTable = cell(analysisIndex,2)

for hieghtThicknessInd = startIndex:analysisIndex
    
    thicknessSummaryXlsx = 'thicknessSummary.xlsx';
    heightSummaryXlsx = 'heightSummary.xlsx';
    whiteningDataFile = 'whitening_Size_Summary.xlsx';
    combinedDataFile = 'combined_MTS_whitening_thickness_height.xlsx';
    %mtsDataFolder = 'd:\users\hardisty\Data\mike\Dropbox\Whitening_Demin\Demineralized_DIC_to_failure\MTS_Data\Analyzed_Included_In_Database';
    
    alignedDir = [rootVideoDir '\' videoFolder{hieghtThicknessInd} '\Aligned']
    hieghtThicknessInd
    
    
    
    inputFileName = dir_matlab([alignedDir '\*labels.tif']);
    
    %if ~exist([alignedDir '\' whiteningDataFile],'file')
    if ~exist([alignedDir '\whitening_Size_Summary_WithDots.xlsx'])
        currentSummaryTable = summarizeWhiteness(alignedDir, '.labels.tif', '', 'tif');
        
    end
    
    [blackWhiteTargetNumerical,blackWhiteTargetText,blackWhiteTargetRaw] = xlsread([alignedDir '\whitening_Size_Summary_WithDots.xlsx']);
    whitenessSummaryTable{hieghtThicknessInd+1,1} = videoFolder{hieghtThicknessInd};
    whitenessSummaryTable{1,1} = 'videoFolder{hieghtThicknessInd}';
    for col_index = 1:19
        whitenessSummaryTable{hieghtThicknessInd+1,1+col_index} = blackWhiteTargetRaw{2,col_index};
        whitenessSummaryTable{1,1+col_index} = blackWhiteTargetRaw{1,col_index};
    end
	
	
	
    %end
 
end

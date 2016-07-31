%script will caluclate optical height, thickness, whitening, and put these
%values on a grid consisten with

%numberOfSecondsToPause = 25*60;

%pause on

%pause(numberOfSecondsToPause);

%batch creation of combined MTS Video Data
%rootVideoDir = 'F:\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data';
rootVideoDir = 'f:\Justin';
%mtsDataFolder = 'C:\Users\hardisty\Dropbox\Whitening_Demin\Demineralized_DIC_to_failure\MTS_Data\Analyzed_Included_In_Database';
analysisIndex = 0;




%1
%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = 'MH2466_s123';
%mtsDataFile{analysisIndex} = 'MH2466_s123_40Eth_1mm_failure.xlsx';


%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = 'MH2466_s323';
%mtsDataFile{analysisIndex} = 'MH2466_s323_40Eth_1mm_failure_trial2.xlsx';



%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = 'MH2490_s222';
%mtsDataFile{analysisIndex} = 'MH2490_s222_70Eth_1mm_failure.xlsx';


%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = 'MH2490_s332';
%mtsDataFile{analysisIndex} = 'MH2526_s422_40Eth_1mm_failure_trial2_supposedtobwe2490_s332.xlsx';

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = 'MH2526_s342';
%mtsDataFile{analysisIndex} = 'MH2526_s342_70Eth_1mm_failure.xlsx';


   
%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = 'MH2526_s422';
%mtsDataFile{analysisIndex} = 'MH2526_s422_40Eth_1mm_failure.xlsx';


analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2526_s333';
mtsDataFile{analysisIndex} = 'MH2526_s333_70Eth_1mm_failure_MayHaveSLipped.xlsx';


analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2466_s232';
mtsDataFile{analysisIndex} = 'MH2466_s232_70Eth_1mm_failure.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2490_s312';



    


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

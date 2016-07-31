%script will caluclate optical height, thickness, whitening, and put these
%values on a grid consisten with

%numberOfSecondsToPause = 25*60;

%pause on

%pause(numberOfSecondsToPause);

%batch creation of combined MTS Video Data
%rootVideoDir = 'F:\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data';
rootVideoDir = 'F:\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data';
%mtsDataFolder = 'C:\Users\hardisty\Dropbox\Whitening_Demin\Demineralized_DIC_to_failure\MTS_Data\Analyzed_Included_In_Database';
analysisIndex = 0;




%*****Saline Standard*****
%no target in shot
%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = '2510MD3-2-2_fail_cam2_C002S0001\Frames'; %verified
%wrong mts file mtsDataFile{analysisIndex} = 'MH_2509MD_322_Saline_To_Failure1.xlsx'
%imageFromVideoList{analysisIndex} = 
%matchingStandardGridFromVideo{analysisIndex} =

%no target in shot
%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = '2510MD2-2-2_cam2_C002S0001\Frames'; %verified
%mtsDataFile{analysisIndex} = 'MH_2510_MD-2-2-2_dots and cameras.xlsx';
%imageFromVideoList{analysisIndex} = 
%matchingStandardGridFromVideo{analysisIndex} =

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2509_322_Sal'; 
mtsDataFile{analysisIndex} = 'MH_2509MD_322_Saline_To_Failure1.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 's422_Saline_1mm_c1'; 
mtsDataFile{analysisIndex} = 'MH_2510_MD-4-2-2_dots and cameras.xlsx';


%811 - note that no analysis has been done
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2490_811_Sal_demin';
mtsDataFile{analysisIndex} = 'shouldbe_MH_2490_811_MH_2400MD_8-1_Saline_To_Failure1.xlsx';


%****Ethanol********


analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = '2510MD-P1_etoh_fail_cam2_C002S0001';
mtsDataFile{analysisIndex} = 'MH_2510_MD-P1ethanol.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'S321_Ethanol_1mm_ToFail_c1'; 
mtsDataFile{analysisIndex} = 'MH_2510_MD_3-2-1_ethanol_To_Failure1.xlsx';






%****Orthogonal********


%analysisIndex = 1+analysisIndex;

%labels are not aligned
%so need to produce them


analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2440_41_Sal_demin_orthog_C1_C001S0001';
mtsDataFile{analysisIndex} = 'MH_2440MD_4-1_Ortho_Saline_To_Failure1.xlsx';



analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2440_s44_sal_Orthog';
mtsDataFile{analysisIndex} = 'MH_2440MD_4-4_Ortho_Saline_To_Failure3.xlsx';





%****Saline0p5******


analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'p10_Saline_cam1_C001S0001';
mtsDataFile{analysisIndex} = 'MH_2510_MD_P10_Saline_To_Failure2.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'p10_Slipped_cam1_C001S0001';
mtsDataFile{analysisIndex} = 'MH_2510_MD_P10_Saline_To_Failure2.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = '2510MD-1-1-2saline_cam2_C002S0001';
mtsDataFile{analysisIndex} = 'MH_2510_MD-1-1-2_saline circWaist.xlsx';






%******Ethanol0p5*****

%CANNOT GET THIS TO REGISTER
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'p11_trial2_Eth_Success_cam1';
mtsDataFile{analysisIndex} = 'MH_2510_MD_P11_Ethanol_To_Failure2.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = '2510MD_P2_etoh_cam2_C002S0001';
mtsDataFile{analysisIndex} = 'MH_2510_MD-P2-ethanol.xlsx';





%*****Saline2p5*****

%no target present
%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = '2510MD3-2-2_fail_cam2_C002S0001';
%mtsDataFile{analysisIndex} = 'MH_2510_MD-3-2-2_dots and cameras.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'S531_Saline_Failure1_c1';
mtsDataFile{analysisIndex} = 'MH_2510_MD_5-3-1_Saline_To_Failure1.xlsx';




%*****Ethanol2p5

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = '2510MD_P3_etoh_cam2_C002S0001';
mtsDataFile{analysisIndex} = 'MH_2510_MD-P3-ethanol.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'S211_Ethanol_2_5mm_c1';
mtsDataFile{analysisIndex} = 'MH_2510_MD_2-1-1_ethanol_To_Failure1.xlsx';


analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = '2510MD_3-3-2etoh_cam2_C002S0001';
mtsDataFile{analysisIndex} = 'MH_2510_MD-3-3-2ethanol.xlsx';


    


%make a loop for all values of analysisIndex*********

transformFileList = cell(analysisIndex,1);

%assumption about file structure
%unalignedFrames are in \Frames
%The target to be used for alignment are in the directory TargetUsed
	%targetVideoImage.tif is the target from the video
	%standardUsed075mmCrop.tif is the original target 
    
startIndex = 1;

whitenessSummaryTable = cell(analysisIndex,20)

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

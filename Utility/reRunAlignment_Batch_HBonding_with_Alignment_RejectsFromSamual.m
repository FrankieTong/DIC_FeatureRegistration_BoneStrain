%script will caluclate optical height, thickness, whitening, and put these
%values on a grid consisten with

%really only need alignment for one video from each set

%still need to do all the xls based analysis


%batch creation of combined MTS Video Data
rootVideoDir = 'I:\HBondStiffness\Extracted_Video_Data';
mtsDataFolder = 'C:\Users\hardisty\Dropbox\Whitening_Demin\HydrogenBondingStiffness\MTS_Data';
analysisIndex = 0;

%rerunning rejects with improved segmentation code
%E:\HBondStiffness\Extracted_Video_Data\Round2\Sample3_MH_2466_s321_HBonding_2466_s432\MH_2466_s321_HBonding_2466_s432_Asc20Eh_22pFormic\Frames
sampleDir = 'Round2\Sample3_MH_2466_s321_HBonding_2466_s432';
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_2466_s432_Asc20Eh_22pFormic']; 
mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Asc20pEth_22pFormic_abs.xlsx'];




sampleDir = 'Round2\Sample4_MH_2466_s321_HBonding_Desc0Eth_22pFormic';
%E:\HBondStiffness\Extracted_Video_Data\Round2\Sample4_MH_2466_s321_HBonding_Desc0Eth_22pFormic\MH_2466_s321_HBonding_Desc20Eth_22pFormic_abs_c1\Frames
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_Desc20Eth_22pFormic_abs_c1']; 
mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Desc20pEth_22pFormic_abs.xlsx'];

%E:\HBondStiffness\Extracted_Video_Data\Round2\Sample4_MH_2466_s321_HBonding_Desc0Eth_22pFormic\MH_2466_s321_HBonding_Desc33Eth_22pFormic_abs_c1\Frames
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_Desc33Eth_22pFormic_abs_c1']; 
mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Desc33pEth_22pFormic_abs.xlsx'];

%E:\HBondStiffness\Extracted_Video_Data\Round2\Sample4_MH_2466_s321_HBonding_Desc0Eth_22pFormic\MH_2466_s321_HBonding_Desc46_5Eth_22pFormic_abs_c1\Frames
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_Desc46_5Eth_22pFormic_abs_c1']; 
mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Desc46_5pEth_22pFormic_abs.xlsx'];


%E:\HBondStiffness\Extracted_Video_Data\Round2\Sample4_MH_2466_s321_HBonding_Desc0Eth_22pFormic\MH_2466_s321_HBonding_Desc60Eth_22pFormic_abs_c1\Frames
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_Desc60Eth_22pFormic_abs_c1']; 
mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Desc60pEth_22pFormic_abs.xlsx'];


%E:\HBondStiffness\Extracted_Video_Data\Round2\Sample4_MH_2466_s321_HBonding_Desc0Eth_22pFormic\MH_2466_s321_HBonding_Desc73p2Eth_22pFormic_abs_c1\Frames
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_Desc73p2Eth_22pFormic_abs_c1']; 
mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Desc73p2pEth_22pFormic_abs.xlsx'];





sampleDir = 'Round2\Sample5_MH_2466_s432_HBonding_Desc_formic';
%E:\HBondStiffness\Extracted_Video_Data\Round2\Sample5_MH_2466_s432_HBonding_Desc_formic\MH_2466_s432_HBonding_Desc20Eh_22pFormic_c1\Frames
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s432_HBonding_Desc20Eh_22pFormic_c1']; 
mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s432_H_Bonding_Desc20pEth_22pFormic_abs.xlsx'];

%E:\HBondStiffness\Extracted_Video_Data\Round2\Sample5_MH_2466_s432_HBonding_Desc_formic\MH_2466_s432_HBonding_Desc33Eh_22pFormic_c1\Frames
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s432_HBonding_Desc33Eh_22pFormic_c1']; 
mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s432_H_Bonding_Desc33pEth_22pFormic_abs.xlsx'];

%E:\HBondStiffness\Extracted_Video_Data\Round2\Sample5_MH_2466_s432_HBonding_Desc_formic\MH_2466_s432_HBonding_Desc73_2Eh_22pFormic_c1\Frames
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s432_HBonding_Desc73_2Eh_22pFormic_c1']; 
mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s432_H_Bonding_Desc73-2pEth_22pFormic_abs.xlsx'];

%E:\HBondStiffness\Extracted_Video_Data\Round2\Sample5_MH_2466_s432_HBonding_Desc_formic\MH_2466_s432_HBonding_Desc100Eh_22pFormic_c1\Frames
analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s432_HBonding_Desc100Eh_22pFormic_c1']; 
mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s432_H_Bonding_Desc100pEth_abs.xlsx'];

%These will need to also be rerun but I think this is an issue with the alignment script - so more complicated
%Not done: E:\HBondStiffness\Extracted_Video_Data\Round2\Sample6_MH_MS_2466_s432_Asc_Eth\MH_MS_2466_MD_s432_H_Bond_0Eth_Trial3_c1\Frames
%Not done: E:\HBondStiffness\Extracted_Video_Data\Round2\Sample3_MH_2466_s321_HBonding_2466_s432\MH_2466_s321_HBonding_2466_s432_Asc0Eh_22pFormic\Frames
%Not done: E:\HBondStiffness\Extracted_Video_Data\Round2\Sample4_MH_2466_s321_HBonding_Desc0Eth_22pFormic\MH_2466_s321_HBonding_Desc0Eth_22pFormic_abs_c1\Frames
%Not done: E:\HBondStiffness\Extracted_Video_Data\Round2\Sample5_MH_2466_s432_HBonding_Desc_formic\MH_2466_s432_HBonding_Desc0Eh_22pFormic_c1\Frames






%Sample1_2510_311
%sampleDir = 'Sample1_2510_311';

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_311_100_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_3-1-1_H_Bonding_100Eth_trial5.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_311_100_trial4_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_3-1-1_H_Bonding_100Eth_trial4.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_311_95_trial1_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_3-1-1_H_Bonding_95Eth_trial1.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_311_85_trial1_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_3-1-1_H_Bonding_85-Eth_trial1.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_311_80_trial1_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_3-1-1_H_Bonding_80-Eth_trial1.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_311_75_trial1_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_3-1-1_H_Bonding_75-Eth_trial1.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_311_70_trial1_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_3-1-1_H_Bonding_70-Eth_trial1.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_311_65_trial1_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_3-1-1_H_Bonding_65-Eth_trial1.xlsx'];




%Sample2_2510_P10
%sampleDir = 'Sample2_2510_P10';

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_P10_0_trial7_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_P10_H_Bonding_0-Eth_trial7.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_P10_10_trial7_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_P10_H_Bonding_10-Eth.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_P10_20_trial7_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_P10_H_Bonding_20-Eth.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_P10_30_trial1_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_P10_H_Bonding_30-Eth.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_P10_40_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_P10_H_Bonding_40-Eth.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_P10_50_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_P10_H_Bonding_50-Eth_Trial1.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_P10_60_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_P10_H_Bonding_60-Eth_Trial1.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_P10_70_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_P10_H_Bonding_70-Eth_Trial1.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_P10_80_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_P10_H_Bonding_80-Eth_Trial1.xlsx'];


%slipped already
%%analysisIndex = 1+analysisIndex;
%%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_P10_90_C001S0001']; 
%mtsDataFile{analysisIndex} = '';

%%analysisIndex = 1+analysisIndex;
%%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_P10_100_C001S0001']; 
%mtsDataFile{analysisIndex} = '';



%Sample3_MH_2466_s321_HBonding_2466_s432
%sampleDir = 'Round2\Sample3_MH_2466_s321_HBonding_2466_s432';



%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_2466_s432_Asc33Eh_22pFormic']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Asc33pEth_22pFormic_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_2466_s432_Asc46-5Eh_22pFormic']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Asc46-5pEth_22pFormic_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_2466_s432_Asc60Eh_22pFormic']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Asc60pEth_22pFormic_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_2466_s432_Asc73-3Eh_22pFormic']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Asc73-3pEth_22pFormic_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_2466_s432_Asc100Eh_22pFormic']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Asc100pEth_22pFormic_abs.xlsx'];






%Sample4_MH_2466_s321_HBonding_Desc0Eth_22pFormic
%sampleDir = 'Round2\Sample4_MH_2466_s321_HBonding_Desc0Eth_22pFormic';

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_Desc20Eth_22pFormic_abs_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Desc20pEth_22pFormic_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_Desc33Eth_22pFormic_abs_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Desc33pEth_22pFormic_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_Desc46_5Eth_22pFormic_abs_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Desc46_5pEth_22pFormic_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_Desc60Eth_22pFormic_abs_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Desc60pEth_22pFormic_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_Desc73p2Eth_22pFormic_abs_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Desc73p2pEth_22pFormic_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s321_HBonding_Desc100Eth_22pFormic_abs_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s321_H_Bonding_Desc100pEth_abs.xlsx'];



%Sample5_MH_2466_s432_HBonding_Desc_formic
%sampleDir = 'Round2\Sample5_MH_2466_s432_HBonding_Desc_formic';

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s432_HBonding_Desc20Eh_22pFormic_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s432_H_Bonding_Desc20pEth_22pFormic_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s432_HBonding_Desc33Eh_22pFormic_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s432_H_Bonding_Desc33pEth_22pFormic_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s432_HBonding_Desc46-5Eh_22pFormic_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s432_H_Bonding_Desc46-5pEth_22pFormic_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s432_HBonding_Desc60Eh_22pFormic_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s432_H_Bonding_Desc60pEth_22pFormic_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s432_HBonding_Desc73_2Eh_22pFormic_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s432_H_Bonding_Desc73-2pEth_22pFormic_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_2466_s432_HBonding_Desc100Eh_22pFormic_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_s432_H_Bonding_Desc100pEth_abs.xlsx'];




%Sample6_MH_MS_2466_s432_Asc_Eth
%sampleDir = 'Round2\Sample6_MH_MS_2466_s432_Asc_Eth';

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bond_20Eth_Trial1_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bonding_20-Eth_trial1.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bond_40Eth_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bonding_40-Eth_trial1.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bond_40Eth_Trial2_dimmed_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bonding_40-Eth_trial2_VidMadeDimmer.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bond_50Eth_dimmed_Trial2_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bonding_50-Eth_trial1_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bond_50Eth_Trial1_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bonding_50-Eth_trial2_rel_dimmed.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bond_60Eth_Trial1_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bonding_60-Eth_trial2_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bond_60Eth_Trial2_dimmed_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bonding_60-Eth_trial2_rel_Dimmed.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bond_70Eth_Trial1_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bonding_70-Eth_trial1_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bond_70Eth_Trial2_dimmed_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bonding_70-Eth_trial2_really_Dimmed.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bond_80Eth_abs_Trial1_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bonding_80-Eth_trial1_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bond_80Eth_rel_dimmed_Trial2_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bonding_80-Eth_trial2_relative_dimmed.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bond_100Eth_abs_Trial3_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bonding_100-Eth_trial3_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bond_100Eth_rel_dimmed_Trial1_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2466_MD_s432_H_Bonding_100-Eth_trial1_rel.xlsx'];



%Sample7_MH_MS_2490_s322_Asc_Eth
%sampleDir = 'Round2\Sample7_MH_MS_2490_s322_Asc_Eth';

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2490_s322_H_Bond_20pEth_am_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2490_MD_s322_H_Bonding__20pEth_trial1_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2490_s322_H_Bond_40pEth_am_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2490_MD_s322_H_Bonding__40pEth_trial1_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2490_s322_H_Bond_50pEth_am_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2490_MD_s322_H_Bonding__50pEth_trial1_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2490_s322_H_Bond_60pEth_am_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2490_MD_s322_H_Bonding__60pEth_trial2_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2490_s322_H_Bond_70pEth_am_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2490_MD_s322_H_Bonding__70pEth_trial2_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2490_s322_H_Bond_80pEth_am_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2490_MD_s322_H_Bonding__80pEth_trial3_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2490_s322_H_Bond_100pEth_am_c1']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2490_MD_s322_H_Bonding__100pEth_trial3_abs.xlsx'];




%Sample8_MH2526_s713_Desc_Eth
%sampleDir = 'Round2\Sample8_MH2526_s713_Desc_Eth';

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH2526_s713_Desc20Eth']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_s713_H_Bonding_Desc20pEth_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH2526_s713_Desc40Eth']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_s713_H_Bonding_Desc40pEth_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH2526_s713_Desc50Eth']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_s713_H_Bonding_Desc50pEth_abs_Trial2.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH2526_s713_Desc60Eth']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_s713_H_Bonding_Desc60pEth_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH2526_s713_Desc70Eth']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_s713_H_Bonding_Desc70pEth_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH2526_s713_Desc80Eth']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_s713_H_Bonding_Desc80pEth_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH2526_s713_Desc100Eth']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_s713_H_Bonding_Desc100pEth_abs.xlsx'];




%Sample9_MH_MS_2490_s322_Asc_Formic
%sampleDir = 'Round2\Sample9_MH_MS_2490_s322_Asc_Formic';

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2490_s322_H_Bond_22pFormic_with20eth_abs']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2490_MD_s322_H_Bonding_22pformic_with20%Eth_trial1_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2490_s322_H_Bond_22pFormic_with33eth_abs']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2490_MD_s322_H_Bonding_22pformic_with33pEth_trial1_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2490_s322_H_Bond_22pFormic_with46_5eth']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2490_MD_s322_H_Bonding_22pformic_with46_5pEth_trial1_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2490_s322_H_Bond_22pFormic_with60eth']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2490_MD_s322_H_Bonding_22pformic_with60pEth_trial1_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2490_s322_H_Bond_no22pFormic_with73_3eth']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2490_MD_s322_H_Bonding__22pformic_73_3pEth_trial1_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2490_s322_H_Bond_no22pFormic_with100eth']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2490_MD_s322_H_Bonding_after_formic_100pEth_trial1_abs.xlsx'];




%Sample10_MH_MS_2526_MD_s713_Asc_Eth
%sampleDir = 'Round2\Sample10_MH_MS_2526_MD_s713_Asc_Eth';

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bond_40Eth_rel']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bonding_40-Eth_trial2_rel_dimmed.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bond_50Eth_abs']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bonding_50-Eth_trial3_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bond_50Eth_rel']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bonding_50-Eth_trial1_rel.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bond_60Eth_abs']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bonding_60-Eth_trial1_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bond_60Eth_rel']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bonding_60-Eth_trial2_rel.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bond_70Eth_abs']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bonding_70-Eth_trial2_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bond_70Eth_rel']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bonding_70-Eth_trial1_rel.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bond_80Eth_abs']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bonding_80-Eth_trial1_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bond_80Eth_rel']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bonding_80-Eth_trial2_rel.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bond_100Eth_abs']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bonding_100-Eth_trial1_abs.xlsx'];

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bond_100Eth_rel']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2526_MD_s713_H_Bonding_100-Eth_trial2_rel.xlsx'];












%make a loop for all values of analysisIndex*********

transformFileList = cell(analysisIndex,1);

%assumption about file structure
%unalignedFrames are in \Frames
%The target to be used for alignment are in the directory TargetUsed
	%targetVideoImage.tif is the target from the video
	%standardUsed075mmCrop.tif is the original target 
    
startIndex = 1;


%need to:

%-check if original_labels exists
    %if it does then transform the labels
%-if they dont
    %then segment the aligned directories
    
%check for the 
    %whiteness data
    %height data
    %thickness data

%need to figure out organize all the labels to be transofrmed into a common
%directory structure
for hieghtThicknessInd = startIndex:analysisIndex
    
    thicknessSummaryXlsx = 'thicknessSummary.xlsx';
    heightSummaryXlsx = 'heightSummary.xlsx';
    whiteningDataFile = 'whitening_Size_Summary_WithDots.xlsx';
    combinedDataFile = 'combined_MTS_whitening_thickness_height.xlsx';
    %mtsDataFolder = 'd:\users\hardisty\Data\mike\Dropbox\Whitening_Demin\Demineralized_DIC_to_failure\MTS_Data\Analyzed_Included_In_Database';
    
	%note line changed as no aligned will exist
    alignedDir = [rootVideoDir '\' videoFolder{hieghtThicknessInd} '\Frames']
    hieghtThicknessInd
    
    
    
    
    
    
    
    
    
    %*************Checking and Segmenting Frames***************
    %
    %
    fileStep = 5;
    ind_imgStack = 0;
    %convention will be that manually segmented frames will have commonprefix*.labels.tif
    %all tifs must have the same commonprefix
    
    wholeVideoStack = [alignedDir '\*.tif'];
    tifFileNames = dir_matlab(wholeVideoStack);
    [ commonPrefixLocal, remainder1Local, remainder2Local]= determineCommonPrefix( tifFileNames{1}, tifFileNames{end});
    
    currentLabelFieldList = dir_matlab([alignedDir '\*.labels.tif']);
    
    if iscell(currentLabelFieldList) == false
        currentLabelFieldList = dir_matlab([alignedDir '\*-labels.tif']);
    end
    currentLabelFieldName = currentLabelFieldList{1};
    
    initialGuessSegmentation=(imread(currentLabelFieldName)==1)*1.0;
    
    currentPossibleFileListToSegment = dir_matlab([alignedDir '\*' sprintf('%04d',ind_imgStack) '.tif']);
        numFileList = size(currentPossibleFileListToSegment,1);
        if numFileList == 1
            %assume that only the frame has been identified
            currentImageFileName = currentPossibleFileListToSegment{1};
        else
            frameIndex = 1;
            while (strfind(currentPossibleFileListToSegment{frameIndex}, '.lablels.tif') == [] && strfind(currentPossibleFileListToSegment{frameIndex}, 'lbl.tif') == []) == false
                frameIndex = frameIndex +1;
            end
            currentImageFileName = currentPossibleFileListToSegment{frameIndex};    
        end
    
    while exist(currentImageFileName,'file')
        
        [pathstr, name, ext] = fileparts(currentImageFileName);
        currentSegmentationFileName = [pathstr '\' name 'lbl' ext];
        
        
        %****
        if (exist(currentSegmentationFileName,'file'))
            currentImageFileNameNext = [commonPrefixLocal sprintf('%04d',ind_imgStack+fileStep) '.tif'];
            [pathstrNext, nameNext, extNext] = fileparts(currentImageFileNameNext);
            currentSegmentationFileNameNext = [pathstrNext '\' nameNext 'lbl' extNext];
            if (~exist(currentSegmentationFileNameNext,'file'))
                initialGuessSegmentation = double(imread(currentSegmentationFileName));
            end
        else
                    
            currentImage = imread(currentImageFileName);

            timestep=5;
            iter_inner=5;
            iter_outer=5;
            lambda=5; % coefficient of the weighted length term L(phi)
            alfa=-3;  % coefficient of the weighted area term A(phi)
            epsilon=1.5;
            sigma=1.5;
            potential=2;
            iter_refine = 10;

            edgeDetector = 1;
            alpha_s =5;
            beta_s = 75;

            currentSegmentation = levelSetSegmentation_Li( currentImage,initialGuessSegmentation,0,timestep,iter_inner,iter_outer,lambda,alfa,epsilon,sigma,potential,iter_refine,edgeDetector,alpha_s,beta_s);

            alfa=3;
            %figure(2);
            %imagesc(currentImage,[0, 255]); axis off; axis equal; hold on;  contour(currentSegmentation, [0.5,0.5], 'r');

            currentSegmentation2 = levelSetSegmentation_Li( currentImage,currentSegmentation,0,timestep,iter_inner,iter_outer,lambda,alfa,epsilon,sigma,potential,iter_refine,edgeDetector,alpha_s,beta_s);

            %figure(3);
            %imagesc(currentImage,[0, 255]); axis off; axis equal; hold on;  contour(currentSegmentation2, [0.5,0.5], 'r');


            imwrite(uint8(currentSegmentation2), currentSegmentationFileName);

            initialGuessSegmentation = currentSegmentation2;
        end
        
        
        ind_imgStack = ind_imgStack+fileStep;
        currentImageFileName = [commonPrefixLocal sprintf('%04d',ind_imgStack) '.tif'];
        
    end
        
        
     %   
     %   
     %   
     %*************End of Checking and Segmenting Frames***************
        
        
        
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    if ~exist([alignedDir '\' thicknessSummaryXlsx],'file')
        avgThicknessImgMaskSequence( alignedDir, 'lbl.tif', thicknessSummaryXlsx, 1, 0);
    end
    if ~exist([alignedDir '\' heightSummaryXlsx],'file')
        avgThicknessImgMaskSequence( alignedDir, 'lbl.tif', heightSummaryXlsx, 0, 0);
    end
    if ~exist([alignedDir '\' whiteningDataFile],'file')
        summarizeWhiteness(alignedDir, '', 'lbl.tif', 'tif');
    end
    
    
    if ~exist([mtsDataFolder '\' mtsDataFile{hieghtThicknessInd} '_combinedVideoMtsTable.xlsx'],'file')
        %interpolate them onto one grid
        [rawWhiteningNumerical,rawWhiteningNumericalHeader] = extractNumericalTableFromFrameXlsx([alignedDir '\' whiteningDataFile],1);
        rawWhiteningNumerical = removeRowsWithNaN(rawWhiteningNumerical, 1);
        rawHeightNumerical = extractNumericalTableFromFrameXlsx([alignedDir '\' heightSummaryXlsx]);
        rawHeightNumerical = removeRowsWithNaN( rawHeightNumerical, 1 );
        rawHeightNumericalHeader = {'Frame','Height'};
        rawThicknessNumerical = extractNumericalTableFromFrameXlsx([alignedDir '\' thicknessSummaryXlsx]);
        rawThicknessNumerical = removeRowsWithNaN( rawThicknessNumerical ,1);
        rawThicknessNumericalHeader = {'Frame', 'Thickness'};
        
        
        [mtsNumerical,mtsText] = xlsread([mtsDataFolder '\' mtsDataFile{hieghtThicknessInd}]);
        %note line changed for h-Bonding will need to change in other
        %batches
        mtsNumericalHeader = mtsText(5,1:11);
        mtsNumerical = mtsNumerical(4:size(mtsNumerical,1),1:14);
        mtsNumerical = removeRowsWithNaN( mtsNumerical,1);
        tableList = cell(4,1);
        tableList{1} = mtsNumerical;
        tableList{2} = rawWhiteningNumerical;
        tableList{3} = rawHeightNumerical;
        tableList{4} = rawThicknessNumerical;
        
        headerList = cell(4,1);
        headerList{1} = mtsNumericalHeader;
        headerList{2} = rawWhiteningNumericalHeader;
        headerList{3} = rawHeightNumericalHeader;
        headerList{4} = rawThicknessNumericalHeader;
        
        offsetList = cell(4,1);
        offsetList{1} = 0;
        offsetList{2} = 1;
        offsetList{3} = 1;
        offsetList{4} = 1;

        coeffecientList = cell(4,1);
        coeffecientList{1} = 1;
        coeffecientList{2} = 1/1000;
        coeffecientList{3} = 1/1000;
        coeffecientList{4} = 1/1000;

        [combinedVideoMtsTable, combinedHeader,dataWithHeader] = combineTables(tableList,headerList,offsetList,coeffecientList);
        
        [~,mtsFileName,~ ] = fileparts(mtsDataFile{hieghtThicknessInd});
        
        xlswrite([mtsDataFolder '\' mtsFileName '_combinedVideoMtsTable.xlsx'],dataWithHeader);
        xlswrite([alignedDir '\' mtsFileName '.xlsx'],dataWithHeader);
    end
end

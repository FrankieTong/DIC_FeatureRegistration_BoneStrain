
directory{1} = 'C:\Users\hardisty\Documents\mike\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data\2510MD3-2-2_fail_cam2_C002S0001\Frames';
%orglblFileNameSuffix{1} = '-labels.tif';

directory{2} = 'C:\Users\hardisty\Documents\mike\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data\2510MD2-2-2_cam2_C002S0001\Frames';


directory{3} = 'C:\Users\hardisty\Documents\mike\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data\s422_Saline_1mm_c1';


directory{4} = 'C:\Users\hardisty\Documents\mike\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data\2510MD-P1_etoh_fail_cam2_C002S0001\Frames';
directory{5} = 'C:\Users\hardisty\Documents\mike\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data\S321_Ethanol_1mm_ToFail_c1';
directory{6} = 'C:\Users\hardisty\Documents\mike\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data\p10_Slipped_cam1_C001S0001\Frame';
directory{7} = 'C:\Users\hardisty\Documents\mike\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data\p11_trial2_Eth_Success_cam1';
directory{8} = 'C:\Users\hardisty\Documents\mike\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data\S531_Saline_Failure1_c1';
directory{9} = 'C:\Users\hardisty\Documents\mike\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data\S211_Ethanol_2_5mm_c1';
%directory{4} = 'C:\Users\hardisty\Documents\mike\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data\2510MD-P1_etoh_fail_cam2_C002S0001\Frames';


orglblFileNameSuffix = '-labels.tif';
autoSegmentedLabelFieldSuffix = 'lbl.tif';
filetype = 'tif';
thicknessSummaryXlsx = 'thicknessSummary.xlsx';
heightSummaryXlsx = 'heightSummary.xlsx';


for i=6:9
	i
    allOutput = whiteness_Height_Thickness_Summaries( directory{i},orglblFileNameSuffix, autoSegmentedLabelFieldSuffix, filetype, thicknessSummaryXlsx,heightSummaryXlsx)
end
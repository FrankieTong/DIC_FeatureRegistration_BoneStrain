directory{1} = 'C:\Mike\OutsideDropBox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data\2510MD-1-1-2saline_cam2_C002S0001\Frames';
orglblFileNameSuffix{1} = '-labels.tif';

directory{2} = 'C:\Mike\OutsideDropBox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data\2510MD_3-3-2etoh_cam2_C002S0001\Frames';
orglblFileNameSuffix{2} = '-labels.tif';

directory{3} = 'C:\Mike\OutsideDropBox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data\2510MD_P2_etoh_cam2_C002S0001\Tif_Slices';
orglblFileNameSuffix{3} = '-labels.tif';

directory{4} = 'C:\Mike\OutsideDropBox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data\2510MD_P3_etoh_cam2_C002S0001\Frames';
orglblFileNameSuffix{4} = '-labels.tif';


autoSegmentedLabelFieldSuffix = 'lbl.tif';
filetype = 'tif';
thicknessSummaryXlsx = 'thicknessSummary.xlsx';
heightSummaryXlsx = 'heightSummary.xlsx';


for i=1:3
    i
    allOutput = whiteness_Height_Thickness_Summaries( directory{i},orglblFileNameSuffix{i}, autoSegmentedLabelFieldSuffix, filetype, thicknessSummaryXlsx,heightSummaryXlsx)
end
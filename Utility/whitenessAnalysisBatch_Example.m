

%common values not needing to change

orglblFileNameSuffix = '-labels.tif';
autoSegmentedLabelFieldSuffix = 'lbl.tif';
filetype = 'tif';
thicknessSummaryXlsx = 'thicknessSummary.xlsx';
heightSummaryXlsx = 'heightSummary.xlsx';
rootVideoDir = 'F:\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data'



%first case

videoFolder = '2510MD3-2-2_fail_cam2_C002S0001\Frames'; %verified
baseDir = [rootVideoDir  '\' videoFolder];

summarizeWhiteness(basedir, orglblFileNameSuffix, autoSegmentedLabelFieldSuffix, filetype)

avgThicknessImgMaskSequence( [basedir '\aligned_labels'], autoSegmentedLabelFieldSuffix, thicknessSummaryXlsx, 1, 0);
avgThicknessImgMaskSequence( [basedir '\aligned_labels'], autoSegmentedLabelFieldSuffix, heightSummaryXlsx, 0, 0);




%second case

videoFolder{analysisIndex} = '2510MD2-2-2_cam2_C002S0001\Frames'; %verified
baseDir = [rootVideoDir  '\' videoFolder];

summarizeWhiteness(basedir, orglblFileNameSuffix, autoSegmentedLabelFieldSuffix, filetype)

avgThicknessImgMaskSequence( [basedir '\aligned_labels'], autoSegmentedLabelFieldSuffix, thicknessSummaryXlsx, 1, 0);
avgThicknessImgMaskSequence( [basedir '\aligned_labels'], autoSegmentedLabelFieldSuffix, heightSummaryXlsx, 0, 0);

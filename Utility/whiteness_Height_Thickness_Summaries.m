function allOutput = whiteness_Height_Thickness_Summaries( directory,orglblFileNameSuffix, autoSegmentedLabelFieldSuffix, filetype, thicknessSummaryXlsx,heightSummaryXlsx,dotThresholdsPredefined)

allOutput=cell(3,1);
allOutput{1} = avgThicknessImgMaskSequence( directory, autoSegmentedLabelFieldSuffix, thicknessSummaryXlsx, 1, 0)
allOutput{2}= avgThicknessImgMaskSequence( directory, autoSegmentedLabelFieldSuffix, heightSummaryXlsx, 0, 0)
if(exist('dotThresholdsPredefined','var')==0)
    allOutput{3}= summarizeWhiteness(directory, orglblFileNameSuffix, autoSegmentedLabelFieldSuffix, filetype)
else
    allOutput{3} = summarizeWhiteness(directory, orglblFileNameSuffix, autoSegmentedLabelFieldSuffix, filetype, dotThresholdsPredefined)
end

end


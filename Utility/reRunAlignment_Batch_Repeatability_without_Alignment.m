%script will caluclate optical height, thickness, whitening, and put these
%values on a grid consisten with

%really only need alignment for one video from each set

%still need to do all the xls based analysis


%batch creation of combined MTS Video Data
rootVideoDir = 'C:\Users\hardisty.SVM\repeatedLoading\';
mtsDataFolder = 'C:\Users\hardisty\Dropbox\Whitening_Demin\HydrogenBondingStiffness\MTS_Data';
analysisIndex = 0;

%FirstBatch

videoFolder = dir_matlab([rootVideoDir '*.labels.tif']);

numberOfVideos = size(videoFolder,1);

mtsDataFile = cell(numberOfVideos,1);

for videoIndex = 1:numberOfVideos
    [pathstr, name, ext] = fileparts(videoFolder{videoIndex});
    videoFolder{videoIndex} = pathstr;
    namePrefixPosition = strfind(name,'_c');
    mtsDataFile{videoIndex} = [name(1:namePrefixPosition(1)-1) '.xls'];
end

sampleDir = '';

analysisIndex = numberOfVideos;

if false

    analysisIndex = 1+analysisIndex;
    videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2440_s221_RepeatedLoading1_c2_C002S0001']; 
    mtsDataFile{analysisIndex} = [sampleDir  ''];

    analysisIndex = 1+analysisIndex;
    videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2440_s221_RepeatedLoading8_c2_C002S0001']; 
    mtsDataFile{analysisIndex} = [sampleDir  ''];

    analysisIndex = 1+analysisIndex;
    videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2466_s121_RepeatedLoading1_c2_C002S0001']; 
    mtsDataFile{analysisIndex} = [sampleDir  ''];

    analysisIndex = 1+analysisIndex;
    videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2466_s423_RepeatedLoading1_c2_C002S0001']; 
    mtsDataFile{analysisIndex} = [sampleDir  ''];

    analysisIndex = 1+analysisIndex;
    videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2490_s63_RepeatedLoading8_c2_C002S0001']; 
    mtsDataFile{analysisIndex} = [sampleDir  ''];

    analysisIndex = 1+analysisIndex;
    videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2466_s513_RepeatedLoading8_c2_C002S0001']; 
    mtsDataFile{analysisIndex} = [sampleDir  ''];

    analysisIndex = 1+analysisIndex;
    videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2509_s131_RepeatedLoading1_c2_C002S0001']; 
    mtsDataFile{analysisIndex} = [sampleDir  ''];

    analysisIndex = 1+analysisIndex;
    videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2509_s131_RepeatedLoading8_c2_C002S0001']; 
    mtsDataFile{analysisIndex} = [sampleDir  ''];

    analysisIndex = 1+analysisIndex;
    videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2526_s142_RepeatedLoading1_c2_C001S0001']; 
    mtsDataFile{analysisIndex} = [sampleDir  ''];

    analysisIndex = 1+analysisIndex;
    videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2526_s513_RepeatedLoading1_c2_C002S0001']; 
    mtsDataFile{analysisIndex} = [sampleDir  ''];

    analysisIndex = 1+analysisIndex;
    videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2526_s513_RepeatedLoading8_c2_C002S0001']; 
    mtsDataFile{analysisIndex} = [sampleDir  ''];

end
















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
    alignedDir = [videoFolder{hieghtThicknessInd}];
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

            alfa=2;
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

%script will caluclate optical height, thickness, whitening, and put these
%values on a grid consisten with

%numberOfSecondsToPause = 25*60;

%pause on

%pause(numberOfSecondsToPause);

%batch creation of combined MTS Video Data
rootVideoDir = 'C:\Users\hardisty\Mike\OutsideDropbox\Round2';
mtsDataFolder = 'C:\Users\hardisty\Mike\Dropbox\Whitening_Demin\Demineralized_DIC_to_failure\MTS_Data\Analyzed_Included_In_Database';
analysisIndex = 0;





analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2466_s333_Eth_1mm_failure_c1'; 
mtsDataFile{analysisIndex} = 'MH2466_s333_Eth_1mm_failure.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2466_s422_1mm_failure_c1'; 
mtsDataFile{analysisIndex} = 'MH2466_s422_1mm_failure.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2490_Orthog11_1mm_failure_c1';
mtsDataFile{analysisIndex} = 'MH2490_Orthog11_1mm_failure.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2490_Orthog21_1mm_failure_500fps_c1';
mtsDataFile{analysisIndex} = 'MH2490_Orthog21_1mm_failure.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2490_s212_Eth_1mm_failure_c1';
mtsDataFile{analysisIndex} = 'MH2490_s212_Eth_1mm_failure.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2490_s512_1mm_failure_c1';
mtsDataFile{analysisIndex} = 'MH2490_s512_1mm_failure.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2526_Orthog11_1mm_failure_500fps';
mtsDataFile{analysisIndex} = 'MH2526_Orthog_11_1mm_failure.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2526_Orthog31_1mm_nofailure_c1';
mtsDataFile{analysisIndex} = 'MH2526_Orthog31_1mm_failure.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2526_s223_Eth_1mm_failure_c1';
mtsDataFile{analysisIndex} = 'MH2526_s223_Eth_1mm_failure.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2526_s231_1mm_failure_c1';
mtsDataFile{analysisIndex} = 'MH2526_s231_1mm_failure_trial2.xlsx';

analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = 'MH2526_s413_1mm_failure_c1';
mtsDataFile{analysisIndex} = 'MH2526_s413_1mm_failure_trial2.xlsx';

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
    
startIndex = 9;
%going straight to segmentation of aligned frames as I know the other
%analysis has been completed
if false
%while 0
%****  Registration Loop ********
for localInd = startIndex:analysisIndex

    %need todo initial alignment for frame zero

    baseDir = [rootVideoDir  '\' videoFolder{localInd}];
    degrees = 0;
    scaleFactor = 2;
    if exist([baseDir  '\TargetUsed'],'dir')

        pixelSizeFileName = [baseDir '\Aligned\pixelSize.txt']
        if ~exist(pixelSizeFileName,'file')

            imageFromVideo = imread([baseDir  '\TargetUsed\targetVideoImage.tif']);
            standardGrid = imread([baseDir '\TargetUsed\standardUsed075mmCrop.tif']);
            wholeVideoStack = [baseDir '\Frames\*.tif'];

            inputFileName = dir_matlab(wholeVideoStack);

            [ firstPath,firstFileName_noPath,firstExt ] = fileparts(inputFileName{1});
                              
            inputFileNamePrefix = firstFileName_noPath(1:(strfind(firstFileName_noPath,'00')-1));

            registeredImageFileName = [baseDir '\Aligned\' inputFileNamePrefix '_Aligned'];
            [registeredImage, resultingTransform, pixelSizeFile] = imageRegistration([firstPath '\' firstFileName_noPath(1:(size(firstFileName_noPath,2)-1)) '*' firstExt], imageFromVideo, standardGrid, registeredImageFileName, degrees,scaleFactor);

            transformFileList{localInd} = pixelSizeFile;
        else
            transformFileList{localInd} = pixelSizeFileName;
        end
    end
end


%****  Alignment Loop ********
%then transform all frames with found transform
for localInd = startIndex:analysisIndex
    
    baseDir = [rootVideoDir '\' videoFolder{localInd}];
    if exist([baseDir  '\TargetUsed'],'dir')
        wholeVideoStack = [baseDir '\Frames\*.tif'];

        inputFileName = dir_matlab(wholeVideoStack);
        stackSize = size(inputFileName,1);
        localTransform = pixelSizeFileToTransform(transformFileList{localInd});

        [ firstPath,firstFileName_noPath,firstExt ] = fileparts(inputFileName{1});

        %inputFileNamePrefix = firstFileName_noPath(1:(strfind(firstFileName_noPath,'00')-1));



        %if files already exist don't bother as it has already been done
        %probably
        %if size(dir_matlab([registeredImageFileName '*']),1) < 15
        inputFileName{1}
        [path,fileName,ext ] = fileparts(inputFileName{1});
        localInd
        [lastPath,lastFileName,lastExt ] = fileparts(inputFileName{end});
        [ commonPrefix, remainder1, remainder2]= determineCommonPrefix( fileName, lastFileName );

        
            indFrame = 1;
            while indFrame <stackSize+1
            %for indFrame = 1:stackSize
                
                %currentoutputfile = [registeredImageFileName sprintf('%04d', indFrame) '.tif'];

                [path,fileName,ext ] = fileparts(inputFileName{indFrame});
                %if indFrame < stackSize
                %    [nextPath,nextFileName,nextExt] = fileparts(inputFileName{indFrame+1});
                %    [ commonPrefix, remainder1, remainder2]= determineCommonPrefix( fileName, nextFileName );
                %else
                %    [path,fileName,ext ] = fileparts(inputFileName{indFrame});
                %    [prevPath,prevFileName,prevExt] = fileparts(inputFileName{indFrame-1});
                %    [ commonPrefix, remainder1, remainder2]= determineCommonPrefix( fileName, prevFileName );
                %end 
                [ commonPrefixLocal, remainder1Local, remainder2Local]= determineCommonPrefix( fileName, commonPrefix);
                registeredImageFileName = [baseDir '\Aligned\' commonPrefix '_Aligned'];
                currentoutputfile = [registeredImageFileName remainder1Local '.tif'];
                %still getting 000_Aligned
                if ~exist(currentoutputfile,'file')
                    [correctedImageStack, pixelSize] = alignWithStndWithCorrectPixelSize(inputFileName{indFrame},localTransform, true);
                    imwrite(uint8(correctedImageStack),currentoutputfile ,'tif');
                    indFrame = indFrame+1;
                else
                    alreadyWrittenAlignedFiles = dir_matlab([registeredImageFileName '*']);
                    numberOfAlignedFiles = size(alreadyWrittenAlignedFiles,1);
                    if numberOfAlignedFiles > indFrame
                        indFrame = numberOfAlignedFiles+1;
                    else
                        indFrame = indFrame+1;
                    end
                end
            end
        %end
    end
end
%end
%need to:
end
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
    whiteningDataFile = 'whitening_Size_Summary.xlsx';
    combinedDataFile = 'combined_MTS_whitening_thickness_height.xlsx';
    %mtsDataFolder = 'd:\users\hardisty\Data\mike\Dropbox\Whitening_Demin\Demineralized_DIC_to_failure\MTS_Data\Analyzed_Included_In_Database';
    
    alignedDir = [rootVideoDir '\' videoFolder{hieghtThicknessInd} '\Aligned']
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
    currentLabelFieldName = currentLabelFieldList{1};
    
    initialGuessSegmentation=(imread(currentLabelFieldName)==1)*1.0;
    
    currentPossibleFileListToSegment = dir_matlab([alignedDir '\*' sprintf('%04d',ind_imgStack) '.tif']);
        numFileList = size(currentPossibleFileListToSegment,1);
        if numFileList == 1
            %assume that only the frame has been identified
            currentImageFileName = currentPossibleFileListToSegment{1};
        else
            frameIndex = 1;
            %while (strfind(currentPossibleFileListToSegment{frameIndex}, '.lablels.tif') == [] && strfind(currentPossibleFileListToSegment{frameIndex}, 'lbl.tif') == []) == false
            while (isempty(strfind(currentPossibleFileListToSegment{frameIndex}, '.lablels.tif')) == true && isempty(strfind(currentPossibleFileListToSegment{frameIndex}, 'lbl.tif') == []) == false)
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
        mtsNumericalHeader = mtsText(5,1:14);
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
        xlswrite([alignedDir '\' mtsFileName '_combinedVideoMtsTable.xlsx'],dataWithHeader);
    end
end

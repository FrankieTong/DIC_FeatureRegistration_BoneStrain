%script will caluclate optical height, thickness, whitening, and put these
%values on a grid consisten with


%batch creation of combined MTS Video Data
rootVideoDir = 'G:\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data';
mtsDataFolder = 'd:\users\hardisty\Data\mike\Dropbox\Whitening_Demin\Demineralized_DIC_to_failure\MTS_Data\Analyzed_Included_In_Database';
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
    
startIndex = 16;

%commenting out these loops in this batch so that I can more quickly  goto
%the only loop remaining
if false

%****  Registration Loop ********
for localInd = startIndex:analysisIndex

    %need todo initial alignment for frame zero

    baseDir = [rootVideoDir  '\' videoFolder{localInd}]
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


end
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
    
    %loading the manual segmentation if one exists - note that it doesn't
    %matter if there is already autogenerated content
    
    currentLabelFieldList = dir_matlab([alignedDir '\*.labels.tif']);
    
    if iscell(currentLabelFieldList)
        currentLabelFieldName = currentLabelFieldList{1};
    
        initialGuessSegmentation=(imread(currentLabelFieldName)==1)*1.0;
    end
    %if there is no manual seg and no auto seg then
    %initialGeussSegmentation will not get set generating an error
    
    numDigits = 4;
    currentPossibleFileListToSegment = dir_matlab([alignedDir '\*' sprintf(['%0' numDigits 'd'],ind_imgStack) '.tif']);
    while iscell(currentPossibleFileListToSegment) == false && numDigits > 0
        numDigits = numDigits-1;
        currentPossibleFileListToSegment = dir_matlab([alignedDir '\*' sprintf(['%0' numDigits 'd'],ind_imgStack) '.tif']);
    end
    
    %currentPossibleFileListToSegment = dir_matlab([alignedDir '\*' sprintf('%04d',ind_imgStack) '.tif']);
        numFileList = size(currentPossibleFileListToSegment,1);
        if numFileList == 1
            %assume that only the frame has been identified
            currentImageFileName = currentPossibleFileListToSegment{1};
        else
            frameIndex = 1;
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
            currentImageFileNameNext = [commonPrefixLocal sprintf(['%0' numDigits 'd'],ind_imgStack+fileStep) '.tif'];
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
        currentImageFileName = [commonPrefixLocal sprintf(['%0' numDigits 'd'],ind_imgStack) '.tif'];
        
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
    
    [~,mtsFileName,~ ] = fileparts(mtsDataFile{hieghtThicknessInd});
    combinedVideoMtsFileName = [mtsDataFolder '\' mtsFileName '_combinedVideoMtsTable.xlsx'];
        
    
    if ~exist(combinedVideoMtsFileName,'file')
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
        
        
        xlswrite(combinedVideoMtsFileName,dataWithHeader);
        xlswrite([alignedDir '\' mtsFileName '_combinedVideoMtsTable.xlsx'],dataWithHeader);
    end
end

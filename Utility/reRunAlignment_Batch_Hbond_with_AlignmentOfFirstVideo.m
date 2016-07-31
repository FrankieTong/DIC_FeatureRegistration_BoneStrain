%script will caluclate optical height, thickness, whitening, and put these
%values on a grid consisten with

%really only need alignment for one video from each set

%still need to do all the xls based analysis


%batch creation of combined MTS Video Data

rootVideoDir = 'F:\HBndStiff';
mtsDataFolder = 'D:\mike\Documents\Dropbox\Whitening_Demin\HydrogenBondingStiffness\MTS_Data';
analysisIndex = 0;



%Sample1_2510_311
sampleDir = 'Sample1_2510_311';

%Camera1

cameraDir = ''


analysisIndex = 1+analysisIndex;
videoFolder{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_Test_HBonding_camera1_311_60_trial1_C001S0001']; 
mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_3-1-1_H_Bonding_60-Eth_trial1.xlsx'];



%Sample1_2510_311
%sampleDir = 'Sample2_2510_P10';

%Camera1

%cameraDir = ''

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = [sampleDir '\MH_MS_2510_MD_Test_HBonding_camera1_P10_0_trial5_C001S0001']; 
%mtsDataFile{analysisIndex} = [sampleDir  '\MH_MS_2510_MD_P10_H_Bonding_0-Eth_trial5.xlsx'];


%Round2

%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = ['Round2' '\Sample3_MH_2466_s321_HBonding_2466_s432\MH_2466_s321_HBonding_2466_s432_Asc0Eh_22pFormic']; 
%mtsDataFile{analysisIndex} = ['Round2' '\Sample3_MH_2466_s321_HBonding_2466_s432\MH_MS_2466_s321_H_Bonding_Asc0pEth_22pFormic_abs.xlsx'];


%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = ['Round2' '\Sample4_MH_2466_s321_HBonding_Desc0Eth_22pFormic\MH_2466_s321_HBonding_Desc0Eth_22pFormic_abs_c1']; 
%mtsDataFile{analysisIndex} = ['Round2' '\Sample4_MH_2466_s321_HBonding_Desc0Eth_22pFormic\MH_MS_2466_s321_H_Bonding_Desc0pEth_22pFormic_abs.xlsx'];


%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = ['Round2' '\Sample5_MH_2466_s432_HBonding_Desc_formic\MH_2466_s432_HBonding_Desc0Eh_22pFormic_c1']; 
%mtsDataFile{analysisIndex} = ['Round2' '\Sample5_MH_2466_s432_HBonding_Desc_formic\MH_MS_2466_s432_H_Bonding_Desc0pEth_22pFormic_abs.xlsx'];


%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = ['Round2' '\Sample6_MH_MS_2466_s432_Asc_Eth\MH_MS_2466_MD_s432_H_Bond_0Eth_Trial3_c1']; 
%mtsDataFile{analysisIndex} = ['Round2' '\Sample6_MH_MS_2466_s432_Asc_Eth\MH_MS_2466_MD_s432_H_Bonding_60-Eth_trial3_rel_Dimmed.xlsx'];


%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = ['Round2' '\Sample7_MH_MS_2490_s322_Asc_Eth\MH_MS_2490_s322_H_Bond_0pEth_am_c1']; 
%mtsDataFile{analysisIndex} = ['Round2' '\Sample7_MH_MS_2490_s322_Asc_Eth\MH_MS_2490_MD_s322_H_Bonding__0pEth_trial1_abs.xlsx'];


%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = ['Round2' '\Sample8_MH2526_s713_Desc_Eth\MH2526_s713_Desc0Eth']; 
%mtsDataFile{analysisIndex} = ['Round2' '\Sample8_MH2526_s713_Desc_Eth\MH_MS_2526_s713_H_Bonding_Desc0pEth_abs_OnlyAscent.xlsx'];


%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = ['Round2' '\Sample9_MH_MS_2490_s322_Asc_Formic\MH_MS_2490_MD_s322_H_Bond_22pFormic_abs']; 
%mtsDataFile{analysisIndex} = ['Round2' '\Sample9_MH_MS_2490_s322_Asc_Formic\MH_MS_2490_MD_s322_H_Bonding_22pformic_trial1_abs.xlsx'];


%analysisIndex = 1+analysisIndex;
%videoFolder{analysisIndex} = ['Round2' '\Sample10_MH_MS_2526_MD_s713_Asc_Eth\MH_MS_2526_MD_s713_H_Bond_40Eth_abs']; 
%mtsDataFile{analysisIndex} = ['Round2' '\Sample10_MH_MS_2526_MD_s713_Asc_Eth\MH_MS_2526_MD_s713_H_Bonding_40-Eth_trial1_abs.xlsx'];


%make a loop for all values of analysisIndex*********

transformFileList = cell(analysisIndex,1);

%assumption about file structure
%unalignedFrames are in \Frames
%The target to be used for alignment are in the directory TargetUsed
	%targetVideoImage.tif is the target from the video
	%standardUsed075mmCrop.tif is the original target 
    
startIndex = 1;

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
    if iscell(currentLabelFieldList)
        currentLabelFieldName = currentLabelFieldList{1};
    else
        currentLabelFieldList = dir_matlab([alignedDir '\*-labels.tif']);
        currentLabelFieldName = currentLabelFieldList{1};
    end
    
    initialGuessSegmentation=(imread(currentLabelFieldName)==1)*1.0;
    
    currentPossibleFileListToSegment = dir_matlab([alignedDir '\*' sprintf('%04d',ind_imgStack) '.tif']);
    
    if iscell(currentPossibleFileListToSegment) == 0
        currentPossibleFileListToSegment = dir_matlab([alignedDir '\*' sprintf('%03d',ind_imgStack) '.tif']);
    end
    
        numFileList = size(currentPossibleFileListToSegment,1);
        if numFileList == 1
            %assume that only the frame has been identified
            currentImageFileName = currentPossibleFileListToSegment{1};
        else
            frameIndex = 1;
            while (isempty(strfind(currentPossibleFileListToSegment{frameIndex}, '.lablels.tif')) && isempty(strfind(currentPossibleFileListToSegment{frameIndex}, 'lbl.tif'))) == false
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

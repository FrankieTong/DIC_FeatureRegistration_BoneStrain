%

initialGuessSegmentation=(imread(currentLabelFieldName)==1)*1.0;
currentImage = imread(currentImageFileName);

timestep=5;
iter_inner=5;
iter_outer=5;
lambda=5; % coefficient of the weighted length term L(phi)

epsilon=1.5;
sigma=1.5;
potential=2;
iter_refine = 10;

edgeDetector = 1;
alpha_s =5;
beta_s = 75;


alfa=-3;  % coefficient of the weighted area term A(phi)
currentSegmentation = levelSetSegmentation_Li( currentImage,initialGuessSegmentation,0,timestep,iter_inner,iter_outer,lambda,alfa,epsilon,sigma,potential,iter_refine,edgeDetector,alpha_s,beta_s);



%note the change in the sign of alpha causes the surface to contract rather than expand
%note the output of the previous call to levelSetSegmentation_Li is now  the input guess segmentation.
alfa=3;           
currentSegmentation2 = levelSetSegmentation_Li( currentImage,currentSegmentation,0,timestep,iter_inner,iter_outer,lambda,alfa,epsilon,sigma,potential,iter_refine,edgeDetector,alpha_s,beta_s);



imwrite(uint8(currentSegmentation2), currentSegmentationFileName);
















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
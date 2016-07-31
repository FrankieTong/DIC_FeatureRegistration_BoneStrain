function [ finalSegmentation ] = levelSetSegmentation_Li_sequence( directory, imageFilePrefix,labelFieldFileName,fileStep, timestep,iter_inner,iter_outer,lambda,alfa1,alfa2,epsilon,sigma,potential,iter_refine,edgeDetector,alpha_s,beta_s, numberOfDigits)



if nargin < 18
    numberOfDigits = 4;
end

%dir_matlab([directory '\' imageFilelocalSearchCriteria]);

%timestep=5;
%iter_inner=5;
%iter_outer=5;
%lambda=5; % coefficient of the weighted length term L(phi)
%alfa=-3;  % coefficient of the weighted area term A(phi)
%epsilon=1.5;
%sigma=1.5;
%potential=2;
%iter_refine = 10;

%edgeDetector = 1;
%alpha_s =5;
%beta_s = 75;



%for ind_imgStack = startFileNum:endFileNum

    %currentImage = imread(imageFileList{2});

    %initialGuessSegmentation = zeros(size(currentImage));
    %initialGuessSegmentation(250:270,355:375)=1; 
    
    %currentLabelFieldName = [directory '\' labelFieldFileName];
    
    initialGuessSegmentation=(imread([directory '\' labelFieldFileName])==1)*1.0;

    %figure(1);
    %imagesc(currentImage,[0, 255]); axis off; axis equal; hold on;  contour(initialGuessSegmentation, [0.5,0.5], 'r');

    %fileNum = numStacks(ind_imgStack);

    %for ind_file = 0:fileStep:fileNum-fileStep % I figure I'll try every 5th to improve the speed
    ind_file = 0;
    currentImageFileName = [directory '\' imageFilePrefix sprintf(['%0' num2str(numberOfDigits) 'd'],ind_file) '.tif'];
    
    while exist(currentImageFileName,'file')
        
        [pathstr, name, ext] = fileparts(currentImageFileName);
        currentSegmentationFileName = [pathstr '\' name 'lbl' ext];
        
        if (exist(currentSegmentationFileName,'file'))
            currentImageFileNameNext = [directory '\' imageFilePrefix sprintf(['%0' num2str(numberOfDigits) 'd'],ind_file+fileStep) '.tif'];
            [pathstrNext, nameNext, extNext] = fileparts(currentImageFileNameNext);
            currentSegmentationFileNameNext = [pathstrNext '\' nameNext 'lbl' extNext];
            if (~exist(currentSegmentationFileNameNext,'file'))
                initialGuessSegmentation = double(imread(currentSegmentationFileName));
            end
        else
                    
            currentImage = imread(currentImageFileName);

            alfa=alfa1;

            currentSegmentation = levelSetSegmentation_Li( currentImage,initialGuessSegmentation,0,timestep,iter_inner,iter_outer,lambda,alfa,epsilon,sigma,potential,iter_refine,edgeDetector,alpha_s,beta_s);
            
            alfa=alfa2;
            %alfa=2;
            %figure(2);
            %imagesc(currentImage,[0, 255]); axis off; axis equal; hold on;  contour(currentSegmentation, [0.5,0.5], 'r');

            currentSegmentation2 = levelSetSegmentation_Li( currentImage,currentSegmentation,0,timestep,iter_inner,iter_outer,lambda,alfa,epsilon,sigma,potential,iter_refine,edgeDetector,alpha_s,beta_s);

            %figure(3);
            %imagesc(currentImage,[0, 255]); axis off; axis equal; hold on;  contour(currentSegmentation2, [0.5,0.5], 'r');


            imwrite(uint8(currentSegmentation2), currentSegmentationFileName);
            finalSegmentation=currentSegmentation2;
            initialGuessSegmentation = currentSegmentation2;
        end
        ind_file = ind_file + fileStep;
        currentImageFileName = [directory '\' imageFilePrefix sprintf(['%0' num2str(numberOfDigits) 'd'],ind_file) '.tif'];
    end

end
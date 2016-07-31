function [registeredImage, resultingTransform, pixelSizeTransformFile] = imageRegistration(wholeVideoStack, imageFromVideo, standardGrid, registeredImageFileName, degrees,scaleFactor)
%Inputs:
    %wholeVideoStack - wild card for dir that needs to return all frames
	%                - note the function assumes that all files pointed to 
    %                  by wholeVideoStack are frames that are have numbers 
    %                  at the end of the file name denoting their order. 
    
    %imageFromVideo - the cropped region of the first frame of the video
    %                 that shows the target to be registered
    
    %standardGrid   - the cropped region of the true standard target.
    %                 imageFromVideo is registered to this target and the 
    %                 resultingTransform is used to align the 
    %                 wholeVideoStack
    
    %registeredImageFileName - The prefix of the aligned files output.  The
    %                          frame number is determined from the files 
    %                          pointed to by wholeVideoStack
    %degrees - initial guess used for registration of targets
    %scaleFactor - initial guess used for scale factor for the registration
    %              of targets
%Outputs:
    %regiseredImage - the image that results from registering imageFromVideo.
    %resultingTransform - the affine transform that registers
    %                     imageFromVideo to standardGrid
    %pixelSizeTransformFile - the location of a text file that contains the
    %                         derived pixel size in the aligned images and 
    %                         the transform that aligns
    %                         the images.
    %
    %Files are also output.  The files output are the main result of this
    %function.  The files are ouput based upon the filename  prefix
    %established in registeredImageFileName
    
    
    %file_list is created earlier so that if wholevideoStack does not
    %result in any frames that can be transformed, no time is waisted
    %figuring out how to transform them.
    file_list = dir_matlab(wholeVideoStack);
     numberOfFrames = size(file_list,1);
    
    correctlyRegistered = 0;
	scaleFactorX = scaleFactor;
	scaleFactorY = scaleFactor;
    test = [scaleFactorX 0 0; 0 scaleFactorY 0; 0 0 1] * [cosd(degrees) -sind(degrees) 0; sind(degrees) cosd(degrees) 0; 0 0 1];    %need to rotate image from video, so use this matrix
    
    manualRegistration = true;
    
    
    %Adding the reading of Pixelsize file to avoid registration if
    %possible
    [pathstr, name, ext] = fileparts(registeredImageFileName);
     pixelSizeTransformFile = [pathstr '\pixelSize.txt'];
     if exist(pixelSizeTransformFile ,'file')
        tform = pixelSizeFileToTransform(pixelSizeTransformFile);
     else
    
    
    
    while correctlyRegistered == 0
        tform = maketform('affine',[1 0 0; 0 1 0; 0 0 1]);   %don't change the standard grid image, but it goes into imtransform function below                            
        %standardGrid1 = imtransform(standardGrid,tform, 'size', [146 145], 'XYScale', [1 1]);
        standardGrid1 = imtransform(standardGrid,tform,'XData',[1 145],'YData',[1 146], 'XYScale', [1 1]);
        
        tform1 = maketform('affine',test);  %insert rotational matrix into function
        %imageFromVideo1 = imtransform(imageFromVideo,tform1, 'size', [146 145], 'XYScale', [1 1]);
        if size(imageFromVideo,3) > 1
            imageFromVideo = imageFromVideo(:,:,1);
        end
        imageFromVideo = uint8((double(imageFromVideo)-double(min(min(imageFromVideo))))*255.0/max(max(double(imageFromVideo)*1.0)));
        imageFromVideo1 = imtransform(imageFromVideo,tform1, 'XData',[1 145],'YData',[1 146], 'XYScale', [1 1]);
        standardGrid1 = standardGrid1(:,:,1);  %need to make images 2-dimensional, not 3-dimensional
        imageFromVideo1 = imageFromVideo1(:,:,1);
        
        
        
        % % Register the images affine
        
        %
        Options = struct('Registration', 'Affine', 'Similarity', 'gd');    %Affine corresponds to the registration being an affine registration.  gd corresponds to similarity.  this all makes a structure under options
        
        if manualRegistration == false 
        
            [registeredImage,Grid,Spacing,M,B,F] = image_registration(imageFromVideo1,standardGrid1,Options);
            [fOrgPoints, fDestPoints] = controlPointsFromVectorField(B,true);
		
		
            %just for debugging
            %xlswrite('d:\users\hardisty\Data\mike\Dropbox\DIC_2010_06\TestingImageRegistration\fOrgPoint.xlsx',fOrgPoints);
            %xlswrite('d:\users\hardisty\Data\mike\Dropbox\DIC_2010_06\TestingImageRegistration\fDestPoint.xlsx',fDestPoints);




            %affineMovingToTargetResult = affineRegistration( imageFromVideo1, standardGrid1, 0)

            affineMovingToTargetResult = cp2tform(fOrgPoints, fDestPoints, 'affine');

            

            
        else
            affineMovingToTargetResult = maketform('affine',[1 0 0; 0 1 0; 0 0 1]);
        end
        %trying a new method
		%F is vector field from moving to static image
		%
		
        M=affineMovingToTargetResult.tdata.Tinv
        %   % Show the registration result
        affineMovingToTargetResultInverse = maketform('affine',M);
        newTest = M * test;
        tform = maketform('affine',newTest);    
        
        resultingTransform = newTest;
        
        
        imageFromVideo1H = figure('Name', 'imageFromVideo1');
        imshow(imageFromVideo1);
        %registereImageH = figure('Name', 'registeredImage');
        %imshow(registeredImage,[1 255]);
        standardGrid1H = figure('Name', 'standardGrid1');
        imshow(standardGrid1,[1 255]);
        
        
        %[manuallyWarpedImage, affineViaWarp] = vectorFieldToWarpedImage( F, imageFromVideo1 )
        
        %figure('Name', 'manuallyWarpedImage');
        %results2 = imshow(manuallyWarpedImage,[1 255]);
        
        image_affine = imtransform(imageFromVideo1,affineMovingToTargetResultInverse,'XData',[1 145],'YData',[1 146],'XYScale', [1 1]);
        
        image_affineH = figure('Name', 'affineViaWarp');
        imshow(image_affine,[1 255]);
        
        difImage =image_affine - standardGrid1;
        difImageH = figure('Name', 'difImage');
        imshow(histeq(difImage));
        
        %Mrot=M(1:2,1:2)
        %Mrot(3,1:2)= zeros(1,2);
        %Mrot(1:3,3)= zeros(3,1);
        %Mrot(3,3)=1;
        %Mrot(3,1:2)=M(3,1:2);
        %figure('Name', 'imageFromVideo1_M_tranpose');
        %manuallyRegisteredImage = imtransform(imageFromVideo1,maketform('affine',Mrot'),'XData',[1 145],'YData',[1 146],'XYScale', [1 1])
        
        %results2 = imshow(manuallyRegisteredImage,[1 255]);
        %figure('Name', 'Registered-ManRegistered');
        %results2 = imshow(registeredImage - manuallyRegisteredImage,[1 255]);
        
        %extraShiftNeeded = ([1,0,0; 0,1,0; 0,0,1]- M')*[ size(standardGrid1,2)/2 ; size(standardGrid1,2)/2 ; 0 ]
        %M_replacement_accounting_for_centre_used =M;
        %M_replacement_accounting_for_centre_used(1:2,3)=extraShiftNeeded(1:2);
        
        %figure('Name', 'ImageFromVideo1_usingInverse_no_Shifting');
        
        Mrot=M(1:2,1:2);
        %Mrot(3,1:2)= zeros(1,2);
        %Mrot(1:3,3)= zeros(3,1);
        %Mrot(3,3)=1;
        
        %figure('Name', 'ManRegistered_no_shifting');
        %manuallyRegisteredImageNoShifting = imtransform(imageFromVideo1,maketform('affine',Mrot'),'XData',[1 145],'YData',[1 146],'XYScale', [1 1])
        %results2 = imshow(manuallyRegisteredImageNoShifting,[1 255]);
        
        %MrotInverse = inv(Mrot)
        %MrotInverseInverted(1,1)=MrotInverse(2,2);
        %MrotInverseInverted(2,2)=MrotInverse(1,1);
        %MrotInverseInverted(1,2)=MrotInverse(2,1);
        %MrotInverseInverted(2,1)=MrotInverse(1,2);
        %MrotInverseInverted(3,1:2)= zeros(1,2);
        %MrotInverseInverted(1:3,3)= zeros(3,1);
        %MrotInverseInverted(3,3)=1;
        
        %results2 = imshow(imtransform(imageFromVideo1,maketform('affine',MrotInverseInverted'),'XData',[1 145],'YData',[1 146],'XYScale', [1 1]),[min(min(difImage)) max(max(difImage))]);
        
        %figure('Name', 'ImageFromVideo1_usingInverse_extra_Shifting');
        
        %extraShiftNeededInverse = ([1,0,0; 0,1,0; 0,0,1]- MrotInverseInverted')*[ size(standardGrid1,2)/2 ; size(standardGrid1,2)/2 ; 0 ]
        %MrotInverseInverted_extraShift=MrotInverseInverted;
        %MrotInverseInverted_extraShift(1:2,3)=extraShiftNeededInverse(1:2);
        
        %results2 = imshow(imtransform(imageFromVideo1,maketform('affine',MrotInverseInverted_extraShift'),'XData',[1 145],'YData',[1 146],'XYScale', [1 1]),[min(min(difImage)) max(max(difImage))]);
        
        %get input from user on the result
        %prompt = {'Did the Registration Work (Y/N):','X Scale Factor Guess:','Y Scale Factor Guess:', 'Degree Guess:'};
        prompt = {'Did the Registration Work (Y/N):','M11','M12', 'M13','M21','M22', 'M23','M31','M32', 'M33','manual mode(Y/N):'};
        dlg_title = 'Checking if Registration worked';
        num_lines = 1;
        manRegPrompt = 'n';
        if manualRegistration == true
            manRegPrompt = 'y'
        end
        def = {'n', num2str(newTest(1,1)),num2str(newTest(1,2)),num2str(newTest(1,3)),num2str(newTest(2,1)),num2str(newTest(2,2)),num2str(newTest(2,3)),num2str(newTest(3,1)),num2str(newTest(3,2)),num2str(newTest(3,3)),manRegPrompt};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        
        %remove the figures created
        delete(imageFromVideo1H);
        %delete(registereImageH);
        delete(standardGrid1H);
        delete(image_affineH);
        delete(difImageH);
        
        if strcmp(answer{1},'y')
            correctlyRegistered=1;
        else
            
            %scaleFactorX=str2num(answer{2});
			%scaleFactorY=str2num(answer{3});
            %degrees=str2num(answer{4});
            %translationX=str2num(answer{4});
            test = [str2num(answer{2}) str2num(answer{3}) str2num(answer{4}); str2num(answer{5}) str2num(answer{6}) str2num(answer{7}); str2num(answer{8}) str2num(answer{9}) str2num(answer{10})];
        end
        if strcmp(answer{11},'y')
            manualRegistration = true;
        else
            manualRegistration = false;
        end
    end
    
    
    
    

   
    
    
    
     end
     
     
     
    
   %writing initial Frame
    
     i=1;
     currentoutputfile = [registeredImageFileName sprintf('%04d', i-1) '.tif'];    %goes from the first frame to the last frame/ you are concatenating here with the 3 spaces joinign together to make the file name.  the ticker up by 1 for each image 0001-->0002
     currentFrame = imread(file_list{i}, 'tif');    %reads each of the images from the video
     [correctedImageStack, pixelSize] = alignWithStndWithCorrectPixelSize(currentFrame,tform); %runs the whole video's frames/ run 1000 frames, instead of 4096
        
               
        [pathstr, name, ext] = fileparts(registeredImageFileName);
    mkdir(pathstr);
    
    
     %Writing the Initial Frame and pixelsize.txt because pixelSize should
    %always be written regardless of the size of the stack passed
    
    pixelSizeTransformFile = [pathstr '\pixelSize.txt'];
    fid = fopen(pixelSizeTransformFile, 'w');
     fprintf(fid, 'PixelSize %f\n', pixelSize);
     fprintf(fid, 'M %f\n', M);
     fprintf(fid, 'test %f\n', test);
    fclose(fid);
     
     imwrite(uint8(correctedImageStack),currentoutputfile ,'tif');   %writes correctedImageStack to wherever we tell it to go
    
    
    
    
    
    
    
    commonPrefix = determineCommonPrefix(file_list{1},file_list{end});
    sizeOfComonPrefix = length(commonPrefix);
    
    
    for i = 2:numberOfFrames    
        
        currentFileName = file_list{i};
        currentoutputfile = [registeredImageFileName  currentFileName(sizeOfComonPrefix+1:end)];    %goes from the first frame to the last frame/ you are concatenating here with the 3 spaces joinign together to make the file name.  the ticker up by 1 for each image 0001-->0002
        currentFrame = imread(file_list{i}, 'tif');    %reads each of the images from the video
        [correctedImageStack, pixelSize] = alignWithStndWithCorrectPixelSize(currentFrame,tform); %runs the whole video's frames/ run 1000 frames, instead of 4096
        
        
        %fid = fopen(pixelSizeTransformFile, 'w');
        %fprintf(fid, 'PixelSize %f\n', pixelSize);
        %fprintf(fid, 'M %f\n', M);
        %fprintf(fid, 'test %f\n', test);
        
        %fclose(fid);
        imwrite(uint8(correctedImageStack),currentoutputfile ,'tif');   %writes correctedImageStack to wherever we tell it to go
    end
end
   
   
   
  
  
   
   
   
   
   







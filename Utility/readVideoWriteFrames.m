function [ success ] = readVideoWriteFrames( videoFile, frameNamePrefix, fileType, numberOfDigits)
%reads in video files (tested on avi), writes out frames
    
    videoObj = VideoReader(videoFile);
    
    for frameIndex = 1:videoObj.NumberOfFrames
        currentFrame = read(videoObj,frameIndex);
        currentFrameFileName = [frameNamePrefix sprintf(['%0' num2str(numberOfDigits) 'd'],frameIndex) '.tif'];
        imwrite(currentFrame, currentFrameFileName);
    end
        
    

    
    success = 1;
end


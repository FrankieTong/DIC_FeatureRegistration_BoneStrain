function [ imageStack ] = readImageStack( fileList )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    numFiles = size(fileList,1);

    frame1 = imread(fileList{1});
    imageStack = ones(size(frame1,1),size(frame1,2),numFiles);
    imageStack(:,:,1) = frame1;
    for indFrame = 2:numFiles
        imageStack(:,:,indFrame) = imread(fileList{indFrame});
    end
    
    
end


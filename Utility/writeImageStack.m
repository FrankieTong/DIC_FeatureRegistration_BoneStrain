function [ imageStack ] = writeImageStack( imageStack, fileList, fmt )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    numFiles = size(fileList,1);

    %frame1 = imread(fileList{1});
    %imageStack = ones(size(frame1,1),size(frame1,2),numFiles);
    %(:,:,1) = frame1;
    for indFrame = 1:numFiles
        imwrite(imageStack(:,:,indFrame), fileList{indFrame},fmt);
    end
    
    
end


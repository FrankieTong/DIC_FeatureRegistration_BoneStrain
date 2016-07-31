function [ processedStack ] = processStack( imageStack, functionToProcessStack)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    numSlices = size(imageStack,3);
    for indSlices = 1:numSlices
        processedStack(:,:,indSlices) = functionToProcessStack(imageStack(:,:,indSlices));
    end

end


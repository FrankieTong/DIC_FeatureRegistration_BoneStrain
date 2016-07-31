
stringToBeRemoved = '_c2_C002S0001'
filesToBeRenamed = dir_matlab(['Z:\AeroFS\repeatedLoading\MH_MS_2526_s513_RepeatedLoading8\Frames\*' stringToBeRemoved '*.tif']);


numberOfFiles = size(filesToBeRenamed,1);

for fileIndex = 1:numberOfFiles
    currentFile = filesToBeRenamed{fileIndex}
    begCharIndex = strfind(currentFile, stringToBeRemoved);
    numberOfOmmittedChars = size(stringToBeRemoved,2);
    newName = [currentFile(1:begCharIndex-1) currentFile(begCharIndex+numberOfOmmittedChars:end)]
    movefile(currentFile,newName,'f');
end
    
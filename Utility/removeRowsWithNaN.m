function [ dataArrayWithoutNaN ] = removeRowsWithNaN( dataArray, onlyCheckColumn )
%creates a new array from dataArray by removing all rows within dataArray that contain NaN

numRows = size(dataArray,1);
numCols = size(dataArray,2);

if ~exist('onlyCheckColumn','var')
    startColumn = 1;
    
    
    endColumn = numCols;
else
    startColumn = onlyCheckColumn;
    endColumn = onlyCheckColumn;
end

currentRow = 1;

for indRow = 1:numRows
    nanFlag = false;
    for indCol = startColumn:endColumn
        if isnan(dataArray(indRow,indCol))
            nanFlag = true;
        end
    end
    if nanFlag == false
        dataArrayWithoutNaN(currentRow,:) = dataArray(indRow,:);
        currentRow = currentRow + 1;
    end
end

end
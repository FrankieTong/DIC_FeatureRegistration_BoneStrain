function [ numericalTable, header ] = extractNumericalTableFromFrameXlsx(xlsxFile,headerRows)

   [~,~,rawWhitening] = xlsread(xlsxFile);
   numberOfRows = size(rawWhitening,1);
   numberOfColumns = size(rawWhitening,2);
   
   
   if exist('headerRows','var')
       indRowStart = headerRows +1;
       header = rawWhitening(1,:);
   else
       indRowStart = 1;
       headerRows = 0;
       header ='';
   end
   
   rawWhiteningNumerical = zeros(numberOfRows-headerRows,numberOfColumns);
   
   [ commonPrefix, remainder1, remainder2]= determineCommonPrefix( rawWhitening{indRowStart,1}, rawWhitening{numberOfRows,1});
   
   
   numericRowIndex =1;
   
   
   
   for ind_row = indRowStart:numberOfRows
       col1Value = rawWhitening{ind_row,1};
       [~,col1ValueNumeric,~] = determineCommonPrefix( col1Value, commonPrefix);
       digitEncoding = isstrprop(col1ValueNumeric, 'digit');
       maxDigits = size(col1ValueNumeric,2);
       ind=1;
       while ind<=maxDigits && digitEncoding(ind)
           ind = ind+1;
       end
       numDigits = ind-1;
       if numDigits>0
           rawWhiteningNumerical(numericRowIndex,1)=str2num(col1ValueNumeric(1:numDigits));
           for ind_col = 2:numberOfColumns
               rawWhiteningNumerical(numericRowIndex,ind_col)=rawWhitening{ind_row,ind_col};
           end
            numericRowIndex=1+numericRowIndex;
       end
   end
   numericalTable = rawWhiteningNumerical(1:numericRowIndex-1,:);
end


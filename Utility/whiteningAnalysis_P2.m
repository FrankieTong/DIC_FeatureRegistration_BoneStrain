%s231
orgImage = imread('d:\users\hardisty\Data\Mike\Dropbox\DIC_Test\2510MD_2-3-1etoh_notch_cam2_C002S0001\DIC0000.tif');
finalImage = imread('d:\users\hardisty\Data\Mike\Dropbox\DIC_Test\2510MD_2-3-1etoh_notch_cam2_C002S0001\DIC2750.tif');
%importedData =  importdata('d:\users\hardisty\Data\Mike\Dropbox\DIC_2010_06\2-3-1etoh_notch\DIC_Outputs_for_2011-07-08_08_36_20_okTill2750\Post-Process Outputs for 2011-08-23_16_10_01\Processed_Data\Total Data_2011-07-08_09_01_50.txt');

totalDefFileList = dir_matlab('d:\users\hardisty\Data\Mike\Dropbox\DIC_2010_06\2-3-1etoh_notch\DIC_Outputs_for_2011-07-08_08_36_20_okTill2750\*Total*');

fileNum = size(totalDefFileList,1);

for indFile = 1:fileNum
    
    currentFileName = totalDefFileList{indFile};
    [pathstr, name, ext] =fileparts(currentFileName);
    importedData =  importdata(currentFileName);
    subsetSize = 2;
    [ xlsxReady nodeDataWithWhiteningAndStrainComponents colHeaders ] = createWhitingStrainNodes( importedData.data,importedData.colheaders, orgImage ,finalImage , subsetSize);
    xlswrite([pathstr '\WhiteningAnalysis_subset' sprintf('%d',subsetSize) '.xlsx'],xlsxReady);

    subsetSize = 5;
    [ xlsxReady nodeDataWithWhiteningAndStrainComponents colHeaders ] = createWhitingStrainNodes( importedData.data,importedData.colheaders, orgImage ,finalImage , subsetSize);
    xlswrite([pathstr '\WhiteningAnalysis_subset' sprintf('%d',subsetSize) '.xlsx'],xlsxReady)
    
    subsetSize = 10;
    [ xlsxReady nodeDataWithWhiteningAndStrainComponents colHeaders ] = createWhitingStrainNodes( importedData.data,importedData.colheaders, orgImage ,finalImage , subsetSize);
    xlswrite([pathstr '\WhiteningAnalysis_subset' sprintf('%d',subsetSize) '.xlsx'],xlsxReady)

    subsetSize = 25;
    [ xlsxReady nodeDataWithWhiteningAndStrainComponents colHeaders ] = createWhitingStrainNodes( importedData.data,importedData.colheaders, orgImage ,finalImage , subsetSize);
    xlswrite([pathstr '\WhiteningAnalysis_subset' sprintf('%d',subsetSize) '.xlsx'],xlsxReady)
end


%s112
orgImage = imread('d:\users\hardisty\Data\Mike\Dropbox\DIC_Test\2510MD-1-1-2saline_cam2_C002S0001\DICb0000.tif');
finalImage = imread('d:\users\hardisty\Data\Mike\Dropbox\DIC_Test\2510MD-1-1-2saline_cam2_C002S0001\DICb1750.tif');
%importedData =  importdata('d:\users\hardisty\Data\Mike\Dropbox\DIC_2010_06\2-3-1etoh_notch\DIC_Outputs_for_2011-07-08_08_36_20_okTill2750\Post-Process Outputs for 2011-08-23_16_10_01\Processed_Data\Total Data_2011-07-08_09_01_50.txt');

totalDefFileList = dir_matlab('d:\users\hardisty\Data\Mike\Dropbox\DIC_2010_06\1-1-2saline_aka_DICb\DIC_Outputs_for_2011-07-31_13_24_50\*Total*');

fileNum = size(totalDefFileList,1);

for indFile = 1:fileNum
    
    currentFileName = totalDefFileList{indFile};
    [pathstr, name, ext] =fileparts(currentFileName);
    importedData =  importdata(currentFileName);
    subsetSize = 2;
    [ xlsxReady nodeDataWithWhiteningAndStrainComponents colHeaders ] = createWhitingStrainNodes( importedData.data,importedData.colheaders, orgImage ,finalImage , subsetSize);
    xlswrite([pathstr '\WhiteningAnalysis_subset' sprintf('%d',subsetSize) '.xlsx'],xlsxReady);

    subsetSize = 5;
    [ xlsxReady nodeDataWithWhiteningAndStrainComponents colHeaders ] = createWhitingStrainNodes( importedData.data,importedData.colheaders, orgImage ,finalImage , subsetSize);
    xlswrite([pathstr '\WhiteningAnalysis_subset' sprintf('%d',subsetSize) '.xlsx'],xlsxReady)
    
    subsetSize = 10;
    [ xlsxReady nodeDataWithWhiteningAndStrainComponents colHeaders ] = createWhitingStrainNodes( importedData.data,importedData.colheaders, orgImage ,finalImage , subsetSize);
    xlswrite([pathstr '\WhiteningAnalysis_subset' sprintf('%d',subsetSize) '.xlsx'],xlsxReady)

    subsetSize = 25;
    [ xlsxReady nodeDataWithWhiteningAndStrainComponents colHeaders ] = createWhitingStrainNodes( importedData.data,importedData.colheaders, orgImage ,finalImage , subsetSize);
    xlswrite([pathstr '\WhiteningAnalysis_subset' sprintf('%d',subsetSize) '.xlsx'],xlsxReady)
end



%test0000_histeq = imread('D:\Users\hardisty\Data\Mike\Dropbox\DIC_Test\Enhanced_Images\test0000_histeq.tif');
%test0000_histeq_wien3=wiener2(test0000_histeq,[3 3]);
%imwrite(test0000_histeq,'D:\Users\hardisty\Data\Mike\Dropbox\DIC_Test\Enhanced_Images\test0000_histeq_wien3.tif');
%test0000_histeq_wien5=wiener2(test0000_histeq,[5 5]);
%imwrite(test0000_histeq,'D:\Users\hardisty\Data\Mike\Dropbox\DIC_Test\Enhanced_Images\test0000_histeq_wien5.tif');

dropboxDIR = '..\..\..\';

%prefix = [dropboxDIR '\DIC_Test\Enhanced_Images\test'];
%suffixes = '.tif';
suffixes_histeq = '_histeq.tif';

%fileDIR = [dropboxDIR 'DIC_Test\2510MD-1-1-2saline_cam2_C002S0001\']
fileDIR = 'C:\Documents and Settings\hardisty\My Documents\Mike\Dropbox\DIC_Test\Preliminary_Video_Slice_Segmentations\tobe_Reanalysed\';
fileList = dir_matlab( [fileDIR '*.tif'] );
nFiles = size(fileList,1);

thicknessSummary = cell(nFiles,2);

for ind = 1:nFiles
	%orgFileName=[prefix sprintf('%04d',ind) suffixes];
	%histeqFileName=[prefix sprintf('%04d',ind) suffixes];
	orgFileName = fileList{ind};
	[pathstr, name, ext] = fileparts(orgFileName) ;
	%histeqFileName = [pathstr '\' name suffixes_histeq]
	currentDIR = pwd;
    cd(pathstr);
    currentLabels = imread(orgFileName,'tif');
    currentLabels = abs(currentLabels == 1);
    
    horizontalThicknessFlag = 0;
    viewFlag = 0;
    
    currentThickness = avgThicknessImgMask(currentLabels, horizontalThicknessFlag, viewFlag);
    thicknessSummary{ind,1} = orgFileName;
    thicknessSummary{ind,2} = mean(currentThickness(:,5));
    %cd(currentDIR);
	%testHisteq = histeq(testReg);
	%imwrite(testHisteq,histeqFileName);
end
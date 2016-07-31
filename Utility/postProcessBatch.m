%postProcessBatch

dropboxDIR = '..\..\..';

dirofWorkspaceFiles = cell(4,1);
dirofWorkspaceFiles{1} = 'jobsOf2011-06-24.txt';
dirofWorkspaceFiles{2} = 'jobsOf2011-06-25.txt';
dirofWorkspaceFiles{3} = 'jobsOf2011-06-26.txt';
dirofWorkspaceFiles{4} = 'jobsOf2011-06-27.txt';

nSummaryFiles = size(dirofWorkspaceFiles,1);

allMatFiles = cell(nSummaryFiles,1);
allMat_counter = 1;




for indSum = 1:nSummaryFiles
    fid = fopen(dirofWorkspaceFiles{indSum});

        %tline{1,1} = fgets(fid);
        
        while ~feof(fid)
            allMatFiles{allMat_counter} = fgets(fid);
            allMat_counter = allMat_counter + 1;
        end
        fclose(fid);
end



matFileListToBeAnalysed = cell(1,2);

matFileListToBeAnalysed = select_last_file_perDir(allMatFiles);


%matFileListToBeAnalysed{1,1} = [dropboxDIR '\SSDIC\DIC Workshop Package\DIC_2010_06\DIC Outputs for  2011-06-21, 10''26''36\Workspace\Workspace 2011-06-21, 10''30''40.mat'];
%matFileListToBeAnalysed{end+1,1} = [dropboxDIR '\SSDIC\DIC Workshop Package\DIC_2010_06\DIC Outputs for  2011-06-21, 10''26''36\Workspace\Workspace 2011-06-21, 10''39''21.mat'];



nFileNum = size(matFileListToBeAnalysed,1);
resultsBrokenUpByPath = cell(2,2,4);
dirIndex = 0;
previousPathstr = '''';
orgImage=imread([dropboxDIR '\DIC_Test\Enhanced_Images\test0000.tif']);

for ind = 1:nFileNum
	[orgImageROI, warpedImageROI,targetImageROI] = viewWarpedImage(orgImage, matFileListToBeAnalysed{ind,1}, [true true true],[false false false]);
    
    [subset_size, Max_num_iter] = load(matFileListToBeAnalysed{ind,1},'subset_size','Max_num_iter')
    
	normalisedAvgDifference = mean(mean(((double(orgImageROI)-double(warpedImageROI)).^2).^(0.5)))/mean(mean(((double(orgImageROI)-double(targetImageROI)).^2).^(0.5)));
	matFileListToBeAnalysed{ind,2} = normalisedAvgDifference;
	[pathstr, name, ext] = fileparts(matFileListToBeAnalysed{ind,1});
	if strcmp(previousPathstr,pathstr) ~= 1
		dirIndex = dirIndex+1;
		dirFileIndex = 0;
        previousPathstr = pathstr;
    end
    dirFileIndex = dirFileIndex + 1;
	resultsBrokenUpByPath{dirIndex,dirFileIndex,1}=matFileListToBeAnalysed{ind,1};
	resultsBrokenUpByPath{dirIndex,dirFileIndex,2}=normalisedAvgDifference;
    resultsBrokenUpByPath{dirIndex,dirFileIndex,3}= subset_size;
    resultsBrokenUpByPath{dirIndex,dirFileIndex,3}= Max_num_iter;
end

xlswrite('Batch_Result_2011_06_27.xls',resultsBrokenUpByPath(:,:,2));
xlswrite('Batch_Results_fileNames_2011_06_27.xls',resultsBrokenUpByPath(:,:,1));
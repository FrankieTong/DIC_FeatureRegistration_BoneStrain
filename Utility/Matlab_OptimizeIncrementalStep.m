% Objective:
% Find the incremental step with the highest correlation to the 3rd decimal
%	 
% % ARBITRARY
stInc = 50;     	% start incremental step
incStep = 1;   	% incremental steps (5,10,15,20,25,..., <= 250)
endInc = 50;    	% end incremental step
fNumTest = 1;   	% arbitrary, intial frame number(roughly)
num_DIC_runs = 15;	% arbitrary number of DIC runs/test frames
                    	% (assume < 100, Num of Workspaces = numTesFr - 1)

% % SPECIMEN INFO
specID = '2466_s612';                                                   	% specimen ID
fPathLoc = ['E:\DIC_Copy_2' '\'];                                     	% path based on LOCATION
fFail = 1874;                                                           	% frame number at onset of failure
xCropCoord = 210;   	yCropCoord = 107;                               	% x- and y-coordinates for cropping
wCrop = 238;        	hCrop = 300;                                    	% width and height for crop

% % DIC GUI INFO
extraNotes = '-';
x_i = 89 + 1;       	y_i = 88 + 1;   	x_f = 145 + 1;  	y_f = 95 + 1;
subsetSize = 7;     	subsetSpcg = 2;

% % POST PROCESS INFO
xx_x_crop_coord = 158;
xx_y_crop_coord = 393;
xx_crop_width = 816;
xx_crop_height = 84;

xy_x_crop_coord = 158;
xy_y_crop_coord = 407;
xy_crop_width = 816;
xy_crop_height = 54;

yy_x_crop_coord = 158;
yy_y_crop_coord = 408;
yy_crop_width = 816;
yy_crop_height = 51;


% % SCRIPT
global I fPathSF fPathSpec fPrefix fPrefix2 fPathDIC fPathTF wsNameList runN dicoutFolMove disout_I_FolPath

% for I = stInc:incStep:endInc;
I = stInc; %%%%%%
fPrefix = [specID '_DIC-to_Failure'];                                   	% prefix for increm folders
fPrefix2 = ['MH_KJ_' fPrefix];                                          	% MH_KJ prefix
fPathSF = [fPathLoc 'Specimen_Frames\'];                                	% path to all Specimen Frame folders
fPathDIC = [fPathLoc 'DIC Files\'];                                     	% path to DIC Files
fFrame = [fPrefix2 '0001'];                                             	% first frame name w/o extension
fPathSpec = [fPrefix2 '\'];                                             	% path based on specimen (for all increm folders)
fPath = [fPathSF fPathSpec fPrefix2 '_All\'];                           	% path to Main Image folder
fInc = [fPathSF fPathSpec fPrefix '_INC_' num2str(I) '\'];              	% path to Incremental Image folder
fPathTF = [fPathDIC 'Tools and Files\'];                                	% path to Tools and Files
order = log10(I);                                                       	% order of increment (ex: 100, order = 2)
dirPath = fPath;
numTesFr = num_DIC_runs + 1;                                            	% number of test frames
numDefIm = numTesFr-1;                                                  	% number of Deformed Images

n=1;
  Iname = fFrame;
  Ipath = [dirPath Iname '.tif'];
  fName = [dirPath fPrefix '_INC_' num2str(I) '\'];  % folder name for incremental images
  mkdir(fName);
  copyfile(Ipath,fName);

  numI = fFail - 1;                	% total number of specimen before failure

  for n=1:floor((numI./I));
  	Inum = I*n;	% number of incremental image
  	prefix = fFrame(1:end-4);
  	if length(num2str(Inum))==1
      	Iname = [prefix '000' num2str(Inum)];  % name of incremental image
  	elseif length(num2str(Inum))==2
      	Iname = [prefix '00' num2str(Inum)];  % name of incremental image
  	elseif length(num2str(Inum))==3
      	Iname = [prefix '0' num2str(Inum)];  % name of incremental image
  	elseif length(num2str(Inum))==4
      	Iname = [prefix num2str(Inum)];  % name of incremental image
  	end
  	Ipath = [dirPath Iname '.tif'];	% path of incremental image
  	copyfile(Ipath,fName);
  end
 
fMove = [fPathSF fPathSpec];
movefile(fName,fMove);

% creates the complete list of increm frame numbers
lenIList = floor(fFail./I);     	% length of Ilist (starting at I, not 1)
Ilist = zeros(length(lenIList),1);  	% creating Ilist
for i=1:lenIList
	Ilist(i) = i.*I;                	% multiplies of I
end

% % creates list of frame numbers only for images being tested
% for lists with FEW frame numbers
if length(find(Ilist >= fNumTest)) < numTesFr   	% if few frame numbers exist above the initial Test Frame
	listImTest = Ilist(end-(numTesFr-1):end);           	% list of frame numbers for test run
% 	listImTest = zeros(numTesFr,1);
% 	for i=0:(numTesFr-1)                        	% going backwards
%     	listImTest(i) = Ilist(end)-(i.*I);  % list of frame numbers for test run
% 	end
    
% for lists with MANY frame numbers
else   
	fImNumTes_Factor = find(Ilist >= fNumTest,1,'first');   % index of the First Image of the Test Run
	listImTest = zeros(numTesFr,1);
	for i=1:numTesFr
    	listImTest(i) = I.*((fImNumTes_Factor-1) + i);
	end
end

% cropping selected images for test run
for i=1:numTesFr
	incFolName = [fMove fPrefix '_INC_' num2str(I) '\'];              	% increm folder name
	% if listImTest has numbers with <4 digits
	% single digit
	if numel(num2str(listImTest(i))) == 1
    	incImUpPath = [incFolName fPrefix2 '000' num2str(listImTest(i)) '.tif'];  	% image path
	% double digit
	elseif numel(num2str(listImTest(i))) == 2
    	incImUpPath = [incFolName fPrefix2 '00' num2str(listImTest(i)) '.tif'];  	% image path
	% triple digit
	elseif numel(num2str(listImTest(i))) == 3
    	incImUpPath = [incFolName fPrefix2 '0' num2str(listImTest(i)) '.tif'];  	% image path
	end
	imUp = imread(incImUpPath);                                       	% image upload
	imUpCrop = imcrop(imUp,[xCropCoord,yCropCoord,wCrop,hCrop]);      	% crop uploaded image
	if i >= 1 && i < 10                                                	% single digit
    	cropImName = [incFolName fPrefix2 '00' num2str(i) '.tif'];    	% name of cropped image (starts at 1)
	else                                                              	% assume double digit
    	cropImName = [incFolName fPrefix2 '0' num2str(i) '.tif'];     	% "
	end
	imwrite(imUpCrop,cropImName);                                     	% save image to file
end

% % moving originals to "Originals" folder
% for first image (0001)
fImPath = [fInc fPrefix2 '0001.tif'];                                   	% first image path
orFolPath = [fInc 'Originals\'];                                        	% "Originals" folder path
if exist(orFolPath,'dir') == 0
	mkdir(orFolPath);                                                   	% new folder
end
fMoveOr = [orFolPath fPrefix2 '0001.tif'];                              	% new image path (to Or fold)
movefile(fImPath,fMoveOr);                                              	% move first image to Originals folder

% for remaining images
for i=1:length(Ilist)
	endNum = Ilist(i);
	if length(num2str(endNum)) == 1                                     	% single digit
    	fImPath = [fInc fPrefix2 '000' num2str(endNum) '.tif'];         	% previous Image path
    	fMoveOr = [orFolPath fPrefix2 '000' num2str(endNum) '.tif'];    	% new 'Image to Originals folder' path
	elseif length(num2str(endNum)) == 2                                 	% double digit
    	fImPath = [fInc fPrefix2 '00' num2str(endNum) '.tif'];
    	fMoveOr = [orFolPath fPrefix2 '00' num2str(endNum) '.tif'];
	elseif length(num2str(endNum)) == 3                                 	% triple digit
    	fImPath = [fInc fPrefix2 '0' num2str(endNum) '.tif'];
    	fMoveOr = [orFolPath fPrefix2 '0' num2str(endNum) '.tif'];
	elseif length(num2str(endNum)) == 4                                 	% quadruple digit
    	fImPath = [fInc fPrefix2 num2str(endNum) '.tif'];
    	fMoveOr = [orFolPath fPrefix2 num2str(endNum) '.tif'];
	end
	movefile(fImPath,fMoveOr);                                          	% moving images to Originals folder
end


% % % DIC GUI PREP

sID = specID;
pathFirstFrame = [fInc fPrefix2 '001.tif'];                             	% path to First Frame for DIC Test Run
incNum = 1;                                                             	% increm of Frame NAMES
stNum = 1;                                                              	% start frame number
lastFrameNum = numTesFr;                                                       	% last frame number
groupSize = 1;                                                          	% number of DIC runs per group
nGroups = numTesFr;                                                            	% number of groups

pathwayRef = pathFirstFrame;
pathway1=pathwayRef(1:end-5);
pathway2=pathwayRef(1:end-6);
pathway3=pathwayRef(1:end-7);
pathway4=pathwayRef(1:end-8);

mydefName = ['mydef_image_fileListP_' sID];
mydefSt = [mydefName '={'];

for n=stNum:incNum:lastFrameNum
	if n < lastFrameNum
    	if n >= 1 && n < 10  % single digit
        	mydef_DefIm = ['''',pathway1,num2str(n),'.tif'';'];
    	elseif n > 9 && n < 100  % double digit
        	mydef_DefIm = ['''',pathway2,num2str(n),'.tif'';'];
    	elseif n > 99 && n < 1000  % triple digit
        	mydef_DefIm = ['''',pathway3,num2str(n),'.tif'';'];
    	elseif n > 999 && n < 10000  % quadruple digit
        	mydef_DefIm = ['''',pathway4,num2str(n),'.tif'';'];
    	end
	elseif n == lastFrameNum
    	if n >= 1 && n < 10  % single digit
        	mydef_DefIm = ['''',pathway1,num2str(n),'.tif''};'];
    	elseif n > 9 && n < 100  % double digit
        	mydef_DefIm = ['''',pathway2,num2str(n),'.tif''};'];
    	elseif n > 99 && n < 1000  % triple digit
        	mydef_DefIm = ['''',pathway3,num2str(n),'.tif''};'];
    	elseif n > 999 && n < 10000  % quadruple digit
        	mydef_DefIm = ['''',pathway4,num2str(n),'.tif''};'];
    	end
	end
	mydef_length = length(mydef_DefIm);
	mydefSt(end+1:end+mydef_length) = mydef_DefIm;
	mydefImList = mydefSt;
end

if groupSize == 1
	mcGillpath = ['mcGillDIC(''',pathwayRef,''',',mydefName,',',num2str(subsetSize),',',num2str(subsetSpcg),',[0;0;0;0;0;0],',num2str(x_i),',',num2str(y_i),',',num2str(x_f),',',num2str(y_f),',''Quintic (5th order)'',[1.00E-08,5.00E-06],''Newton Raphson'',40,true,1:' num2str(numDefIm)];
elseif groupSize == 2
	gList = '1,1,';
	for x=1:nGroups
    	if x < 10                                                       	% single digit
        	gList(end+1:end+4)=[num2str(x) ',' num2str(x) ','];
    	elseif x > 9 && x < 100                                          	% double digit
        	gList(end+1:end+6)=[num2str(x) ',' num2str(x) ','];
    	elseif x > 99 && x < 1000                                        	% triple digit
        	gList(end+1:end+8)=[num2str(x) ',' num2str(x) ','];
    	end
	end
	gList=['[' gList(1:end-1) ']'];                                     	% takes away extra (last) comma
	mcGillpath = ['mcGillDIC(''',pathwayRef,''',',mydefName,',',num2str(subsetSize),',',num2str(subsetSpcg),',[0;0;0;0;0;0],',num2str(x_i),',',num2str(y_i),',',num2str(x_f),',',num2str(y_f),',''Quintic (5th order)'',[1.00E-08,5.00E-06],''Newton Raphson'',40,true,' gList ');'];
end

% creating and writing DIC Test Run INFO into a Text File (.txt)
txtFilName = [fInc 'DIC_INFO_' num2str(subsetSize) '_' num2str(subsetSpcg) '.txt']; 	% text file (.txt) name
txtFil = fopen(txtFilName,'w');                                                     	% write in text file
fprintf(txtFil,'s%s, incNum: %d, sSize: %d, sSpacing: %d, extra: %s\n\n%s\n\n%s\n',sID,I,subsetSize,subsetSpcg,extraNotes,mydefImList,mcGillpath);  % text written in text file
fclose(txtFil);                                                                     	% close text file


% % % DIC GUI

fprintf('%%s%s, incNum: %d, sSize: %d, sSpacing: %d, extra: %s\n\n%s\n\n%s\n',sID,I,subsetSize,subsetSpcg,extraNotes,mydefImList,mcGillpath);   % Comment
listDefIm = cell(numTesFr-1,1);

for i=2:numTesFr                                                        	% Writing the list of Deformed Images for the DIC Test Run
	if length(num2str(i)) == 1                                      	% single digit
    	imiPath = [fInc fPrefix2 '00' num2str(i) '.tif'];               	% path for 'i'th Cropped Image for DIC Test Run
	elseif length(num2str(i)) == 2                                  	% double digit
    	imiPath = [fInc fPrefix2 '0' num2str(i) '.tif'];
	end
	listDefIm{i-1,1} = char(imiPath);                                   	% list of Deformed Images for DIC Test Run
end

% checking if output folder already exists
date = now;
	dateStr = datestr(date, 'yyyy-mm-dd');
	dic_output_date_path = [fPathDIC 'DIC Outputs\DIC_Outputs_for_' dateStr '_' specID '\'];
	dic_output_orig_path = [fPathDIC 'DIC Outputs\DIC_Outputs_for_' dateStr '_' num2str(I) '\'];
	dic_output_origRef_path = [dic_output_date_path 'Output_for_INC_' num2str(I) '\Original_Reference_Output\'];

% if exist(dic_output_origRef_path,'dir') == 0  % if no output folder
	mcGillDIC(char(pathFirstFrame),listDefIm,subsetSize,subsetSpcg,[0;0;0;0;0;0],x_i,y_i,x_f,y_f,'Quintic (5th order)',[1.00E-08,5.00E-06],'Newton Raphson',40,true,1:(length(listDefIm)));

% moving DIC Output Data folders
	if exist(dic_output_date_path,'dir')==0
    	mkdir(dic_output_date_path)
	end
	if exist(dic_output_origRef_path,'dir')==0
    	mkdir(dic_output_origRef_path)
	end
	% moves Inputs and Performance
	inp_perf_orig_path = [dic_output_orig_path 'Inputs_and_Performance\'];
	movefile(inp_perf_orig_path,dic_output_origRef_path);
	% moves Raw Data
	raw_data_orig_path = [dic_output_orig_path 'Raw_Data\'];
	movefile(raw_data_orig_path,dic_output_origRef_path);
	% moves Workspace
	workspace_orig_path = [dic_output_orig_path 'Workspace\'];
	movefile(workspace_orig_path,dic_output_origRef_path);
	cd('..')
	% clear old DIC Output inc# folder (contents moved elsewhere)
	rmdir(dic_output_orig_path);

dicOutStr = dir([fPathDIC 'DIC Outputs\']);                             	% Structure for DIC folder names
isub = [dicOutStr(:).isdir];
dicOutFol = {dicOutStr(isub).name};                                     	% List of DIC Output folder names
dicOutI = char(dicOutFol(end));                                         	% Assuming increments will increase
wsListPath = [fPathDIC 'DIC Outputs\DIC_Outputs_for_' dateStr '_' specID '\Output_for_INC_' num2str(I) '\Original_Reference_Output\Workspace\'];
wsListStru = dir(fullfile(wsListPath,'*.mat'));                         	% Structure for Workspace file names
wsNameList = {wsListStru.name}';                                        	% List of Workspace file names

% % % VIEW WARPED IMAGE
for runN=1:(numTesFr-1)
	if numel(num2str(runN))==1                                                                      	% single digit
    	orgImPath = [fPathSF fPathSpec fPrefix '_INC_' num2str(I) '\' fPrefix2 '00' num2str(runN) '.tif'];   % Path to original image
	elseif numel(num2str(runN))==2                                                                  	% double digit
    	orgImPath = [fPathSF fPathSpec fPrefix '_INC_' num2str(I) '\' fPrefix2 '0' num2str(runN) '.tif'];	% "
	end
	currentOrgImage = imread(orgImPath);
	workSpaceResultFile = [char(wsListPath) char(wsNameList(runN))];
	viewWarpedImage(currentOrgImage, workSpaceResultFile, [true true true],[false false false],1);
end


% % % ADJUST WARPED IMAGES
% (black background for new test, "deformed" images)
blackBGPath = [fPathSF fPathSpec 'blackBG.tif'];                        	% creating black background image
blackBG_beforeResize = imread(blackBGPath);
blackBG = imresize(blackBG_beforeResize,size(rgb2gray(currentOrgImage)));
blBGWarpFolPath = [fPathSF fPathSpec fPrefix '_INC_' num2str(I) '\Test Deformed Images (Black BG)\']; 	% folder path to Black BG Warped Images
if exist(blBGWarpFolPath,'dir')==0
	mkdir(blBGWarpFolPath)                                                                   	% Make Originals folder inside WTO folder
end
wtoFolPath = [fPathSF fPathSpec fPrefix '_INC_' num2str(I) '\Warped_Target_Original_1st\'];
wtoImStr = dir(wtoFolPath);                                                 	% Structure for vWI Warped Images
wtoImFol = {wtoImStr.name};                                                 	% List of vWI Warped Image names
for ind = 1:numTesFr-1
    	warpImPath = [wtoFolPath char(wtoImFol(ind.*2+2))];
        	% WTO contains Target and Warped; warped image is second in each target/warped set//VWI run, +2 b/c first and second entries are '.' and '..'
    	warpIm = imread(warpImPath);
    	warpImHist = histeq(warpIm);                        	% adjust intensity to arbitrary scale
    	[rowOrg colOrg] = size(rgb2gray(currentOrgImage));
    	[rowWarp colWarp] = size(rgb2gray(currentOrgImage));
    	blackBGWarped = rgb2gray(blackBG);
    	blackBGWarped(y_i:y_f-1,x_i:x_f) = warpImHist;                       	% place image in the same region as the subset region of original image
    	blBGImPath = [blBGWarpFolPath fPrefix2 '_blackBG_00' num2str(ind) '.tif'];  % path to folder with black BG, "deformed" images
    	imwrite(uint8(blackBGWarped),blBGImPath);
end


% % DIC GUI (with Test Def / Warped Image)
blackBGImStr = dir(blBGWarpFolPath);                                            	% Structure for Black BG, "Deformed" Images
blackBGImFol = {blackBGImStr.name};
listDefImBlack = cell(numDefIm,1);
for ind=1:numDefIm
	listDefImBlack{ind} = [blBGWarpFolPath blackBGImFol{1,ind+2}];              	% Putting "deformed," test images (with paths) into matrix
end
% rmdir([fPathDIC 'DIC Outputs\' dicOutI],'s');                                   	% removes previous DIC Output Inc folder
refIm2D_folPath = [fPathSF fPathSpec fPrefix '_INC_' num2str(I) '\2D Ref Images\']; % path to folder containing 2D ref images
if exist(refIm2D_folPath,'dir')==0
	mkdir(refIm2D_folPath)
end

	% % ADJUSTING REFERENCE IMAGES
for runNum=1:(numTesFr-1)
	% cropping reference images for test run
	if runNum < 10
	% single digit (runNum)
    	refImPath = [fPathSF fPathSpec fPrefix '_INC_' num2str(I) '\' fPrefix2 '00' num2str(runNum) '.tif'];   % path of reference images
	else
	% double digit (runNum)
    	refImPath = [fPathSF fPathSpec fPrefix '_INC_' num2str(I) '\' fPrefix2 '0' num2str(runNum) '.tif'];   % path of reference images
	end
    	refImImport = imread(refImPath);
	refImCrop = imcrop(refImImport,[x_i,y_i,(x_f - x_i - 1),(y_f - y_i - 1)]);      	% crop uploaded image
    	refImCrop_path = [refIm2D_folPath fPrefix2 '00' num2str(runNum) '.tif'];    	% path to cropped image
    	imwrite(refImCrop,refImCrop_path);                             	% put cropped image in the 2D Ref Images folder
	% matching intensity of ref and "def"/warped images
    	refImCrop2D = rgb2gray(refImCrop);
	refImCrop2D_hist = histeq(refImCrop2D);
 	% placing cropped image onto consistent background
    	% = replacing part of consistent BG with cropped image
	blackBGWarped(y_i:y_f-1,x_i:x_f-1) = refImCrop2D_hist;
    	imwrite(uint8(blackBGWarped),refImCrop_path);

	% DIC Run on 2D images (original-warped images)
	mcGillDIC(refImCrop_path,cellstr(listDefImBlack{runNum}),subsetSize,subsetSpcg,[0;0;0;0;0;0],x_i,y_i,x_f,y_f,'Quintic (5th order)',[1.00E-08,5.00E-06],'Newton Raphson',40,true,1);

% moving DIC Output Data folders
	dic_output_origWarp_path = [dic_output_date_path 'Output_for_INC_' num2str(I) '\Original_Warped_Output\'];
	if exist(dic_output_origWarp_path,'dir')==0
    	mkdir(dic_output_origWarp_path)
	end
	% moves Inputs and Performance
	inp_perf_orig_path = [dic_output_orig_path 'Inputs_and_Performance\'];
	movefile(inp_perf_orig_path,dic_output_origWarp_path);
	% moves Raw Data
	raw_data_orig_path = [dic_output_orig_path 'Raw_Data\'];
	movefile(raw_data_orig_path,dic_output_origWarp_path);
	% moves Workspace
	workspace_orig_path = [dic_output_orig_path 'Workspace\'];
	movefile(workspace_orig_path,dic_output_origWarp_path);
	cd('..')
	% removes DIC output folder (all contents moved elsewhere)
end
rmdir(dic_output_orig_path);

dicOutStr = dir([fPathDIC 'DIC Outputs\']);                             	% Structure for DIC folder names
dicOutFol = {dicOutStr.name};                                           	% List of DIC Output folder names
dicOutI = char(dicOutFol(end));                                         	% Assuming increments will increase
wsListPath = [fPathDIC 'DIC Outputs\' dicOutI '\Workspace\'];           	% Path to Workspace folder
wsListStru = dir(fullfile(wsListPath,'*.mat'));                         	% Structure for Workspace file names
wsNameList = {wsListStru.name}';

% % RUNNING POST-PROCESSING GUI
for runNumber = 1:num_DIC_runs
	incremStepOptimal_PP(dic_output_origRef_path,runNumber,listImTest)
	incremStepOptimal_PP(dic_output_origWarp_path,runNumber,listImTest)
end

% % % % % % % VIEW WARPED IMAGE (with test "deformed" images)
% % % % for runN=1:(numTesFr-1)
% % % % 	if length(num2str(numTesFr))==1                                                                      	% single digit
% % % %     	orgImPath = [fPathSF fPathSpec fPrefix '_INC_' num2str(I) '\' fPrefix2 '00' num2str(runN) '.tif'];   % Path to original image
% % % % 	elseif length(num2str(numTesFr))==2                                                                  	% double digit
% % % %     	orgImPath = [fPathSF fPathSpec fPrefix '_INC_' num2str(I) '\' fPrefix2 '0' num2str(runN) '.tif'];	% "
% % % % 	end
% % % % 	currentOrgImage = imread(orgImPath);
% % % % 	workSpaceResultFile = [char(wsListPath) char(wsNameList(runN))];
% % % % 	defIm1 = currentOrgImage;                                                                            	% "original" image is the test "deformed" image
% % % % 	viewWarpedImage(defIm1, workSpaceResultFile, [true true true],[false false false],2);
% % % % end

% % MEASURE CORRELATIONS
numInc = length(stInc:incStep:endInc);            	% number of increment steps
indNI = find(numInc > endInc); numInc(indNI) = [];	% delete values > endInc

% Correlation Value Table:
% INC STEP - Frame Number - Corr XX - Corr XY - Corr YY - Corr Ave
% corr_table:
% (row 1) INC STEP - Frame Number - Corr XX - Corr XY - Corr YY - Corr Ave
% - Ave of all Corr Aves
% corr_table always starts at row 1 because it gets cleared every increment
% change --> thus, each corr_table for a given increment step gets put into
% the Excel spreadsheet for "Correlation Value Table" (Excel_corr_table)
% numCol_corr_table = 7;
% listInc = stInc:incStep:endInc;
% corr_table = zeros(num_DIC_runs,numCol_corr_table);
%
% % labeling increment step
% corr_table(:,1) = I;
%
% % labeling frame numbers
% for i = 1:num_DIC_runs
% 	corr_table(i,2) = listImTest(i+1);
% end
%%%%%%%%%

% mean strain values in the yy dir
mean_strain_yy = zeros(num_DIC_runs,4);

for i = 1:num_DIC_runs
	% Original/Ref Image
	refPD_dir_path = [dic_output_date_path 'Output_for_INC_' num2str(I) '\Original_Reference_Output\Post-Process_Outputs\Frame_Number_' num2str(listImTest(i+1)) '\Processed_Data\'];
    
	% Original/Warped Image
	warpPD_dir_path = [dic_output_date_path 'Output_for_INC_' num2str(I) '\Original_Warped_Output\Post-Process_Outputs\Frame_Number_' num2str(listImTest(i+1)) '\Processed_Data\'];

	% inputting strain field data from "processed_data" folder
	% orig/ref data
	refPD_dir = dir(refPD_dir_path);
	refPD_filename = refPD_dir(3,1).name;
	refPD_path = [refPD_dir_path refPD_filename];
	refPD_str = importdata(refPD_path);
	refPD_matrix = refPD_str.data;
    
	% orig/warp data
	warpPD_dir = dir(warpPD_dir_path);
	warpPD_filename = warpPD_dir(3,1).name;
	warpPD_path = [warpPD_dir_path warpPD_filename];
	warpPD_str = importdata(warpPD_path);
	warpPD_matrix = warpPD_str.data;
    
	% Measuring Error b/t Orig/Ref and Orig/Warp Data
% 	refPD_xx = refPD_matrix(:,6); warpPD_xx = warpPD_matrix(:,6);
	refPD_yy = refPD_matrix(:,7); warpPD_yy = warpPD_matrix(:,7);
% 	refPD_xy = refPD_matrix(:,8); warpPD_xy = warpPD_matrix(:,8);
    
% 	% find row indices with NaN values
% 	ind_NaN_xx = find(isnan(refPD_xx));
% 	ind_NaN_xy = find(isnan(refPD_xy));
	ind_NaN_yy = find(isnan(refPD_yy));
% 	ind_NaN_all = [ind_NaN_xx' ind_NaN_xy' ind_NaN_yy']';
% 	% remove row indices with NaN values
% 	refPD_xx(ind_NaN_all) = [];
% 	refPD_xy(ind_NaN_all) = [];
% 	refPD_yy(ind_NaN_all) = [];
	refPD_yy(ind_NaN_yy) = [];
% 	warpPD_xx(ind_NaN_all) = [];
% 	warpPD_xy(ind_NaN_all) = [];
% 	warpPD_yy(ind_NaN_all) = [];
	warpPD_yy(ind_NaN_yy) = [];
    
% 	error_matrix = zeros(length(refPD_yy),3);
	error_matrix = zeros(length(refPD_yy),1);
	for ind = 1:length(refPD_xx)
%     	% 1st col = xx
%     	error_matrix(ind,1) = abs(refPD_xx(ind) - warpPD_xx(ind));
%     	% 2nd col = xy
%     	error_matrix(ind,2) = abs(refPD_xy(ind) - warpPD_xy(ind));
    	% 3rd col = yy
    	error_matrix(ind,3) = abs(refPD_yy(ind) - warpPD_yy(ind));
	end
    
	% mean strain values in the yy dir
	% 1st col - frame #
	mean_strain_yy(i,1) = listImTest(i+1);
	% 2nd col - strain yy of orig/ref DIC run
	mean_strain_yy(i,2) = mean(refPD_yy);
	% 3rd col - strain yy of orig/warp DIC run
	mean_strain_yy(i,3) = mean(warpPD_yy);
	% 4th col - expected strain yy
	mean_strain_yy(i,4) = listImTest(i+1)./1000;
    
% 	% XX Error
% 	corr_table(i,3) = corr2(rgb2gray(targ_img_xx),rgb2gray(warp_img_xx)).^2;
%
% 	% Target - Epsilon XX
% 	targIm_dir_path_xx = [targIm_dir_path_prefix 'Total Epsilon xx\'];
% 	targIm_directory_xx = dir(targIm_dir_path_xx);
% 	targIm_filename_xx = targIm_directory_xx(3,1).name;
% 	targIm_img_path_xx = [targIm_dir_path_xx targIm_filename_xx];
% 	targ_img_xx_upload = imread(targIm_img_path_xx);
% 	% crop out white background
% 	targ_img_xx = imcrop(targ_img_xx_upload,[xx_x_crop_coord,xx_y_crop_coord,xx_crop_width,xx_crop_height]);
%	 
% 	% Warped - Epsilon XX
% 	warpIm_dir_path_xx = [warpIm_dir_path_prefix 'Total Epsilon xx\'];
% 	warpIm_directory_xx = dir(warpIm_dir_path_xx);
% 	warpIm_filename_xx = warpIm_directory_xx(3,1).name;
% 	warpIm_img_path_xx = [warpIm_dir_path_xx warpIm_filename_xx];
% 	warp_img_xx_upload = imread(warpIm_img_path_xx);
% 	% crop out white background
% 	warp_img_xx = imcrop(warp_img_xx_upload,[xx_x_crop_coord,xx_y_crop_coord,xx_crop_width,xx_crop_height]);
%	 
% 	% XX R^2
% 	corr_table(i,3) = corr2(rgb2gray(targ_img_xx),rgb2gray(warp_img_xx)).^2;
%	 
% 	% Target - Epsilon XY
% 	targIm_dir_path_xy = [targIm_dir_path_prefix 'Total Epsilon xy\'];
% 	targIm_directory_xy = dir(targIm_dir_path_xy);
% 	targIm_filename_xy = targIm_directory_xy(3,1).name;
% 	targIm_img_path_xy = [targIm_dir_path_xy targIm_filename_xy];
% 	targ_img_xy_upload = imread(targIm_img_path_xy);
% 	% crop out white background
% 	targ_img_xy = imcrop(targ_img_xy_upload,[xy_x_crop_coord,xy_y_crop_coord,xy_crop_width,xy_crop_height]);
%	 
% 	% Warped - Epsilon XY
% 	warpIm_dir_path_xy = [warpIm_dir_path_prefix 'Total Epsilon xy\'];
% 	warpIm_directory_xy = dir(warpIm_dir_path_xy);
% 	warpIm_filename_xy = warpIm_directory_xy(3,1).name;
% 	warpIm_img_path_xy = [warpIm_dir_path_xy warpIm_filename_xy];
% 	warp_img_xy_upload = imread(warpIm_img_path_xy);
% 	% crop out white background
% 	warp_img_xy = imcrop(warp_img_xy_upload,[xy_x_crop_coord,xy_y_crop_coord,xy_crop_width,xy_crop_height]);
%	 
% 	% XY R^2
% 	corr_table(i,4) = corr2(rgb2gray(targ_img_xy),rgb2gray(warp_img_xy)).^2;
%	 
% 	% Target - Epsilon YY
% 	targIm_dir_path_yy = [targIm_dir_path_prefix 'Total Epsilon yy\'];
% 	targIm_directory_yy = dir(targIm_dir_path_yy);
% 	targIm_filename_yy = targIm_directory_yy(3,1).name;
% 	targIm_img_path_yy = [targIm_dir_path_yy targIm_filename_yy];
% 	targ_img_yy_upload = imread(targIm_img_path_yy);
% 	% crop out white background
% 	targ_img_yy = imcrop(targ_img_yy_upload,[yy_x_crop_coord,yy_y_crop_coord,yy_crop_width,yy_crop_height]);
%	 
% 	% Warped - Epsilon YY
% 	warpIm_dir_path_yy = [warpIm_dir_path_prefix 'Total Epsilon yy\'];
% 	warpIm_directory_yy = dir(warpIm_dir_path_yy);
% 	warpIm_filename_yy = warpIm_directory_yy(3,1).name;
% 	warpIm_img_path_yy = [warpIm_dir_path_yy warpIm_filename_yy];
% 	warp_img_yy_upload = imread(warpIm_img_path_yy);
% 	% crop out white background
% 	warp_img_yy = imcrop(warp_img_yy_upload,[yy_x_crop_coord,yy_y_crop_coord,yy_crop_width,yy_crop_height]);
%	 
% 	% YY R^2
% 	corr_table(i,5) = corr2(rgb2gray(targ_img_yy),rgb2gray(warp_img_yy)).^2;
%	 
% 	% mean correlation value
% 	corr_table(i,6) = mean(corr_table(i,3:5));
% 	clear targIm_dir_path_prefix targ_img_xx targ_img_xy targ_img_yy warp_img_xx warp_img_xy warp_img_yy
end

% fprintf('Inc. step: %d, Error in XX dir: %.4f\n',I,sum(error_matrix(:,1)));
% fprintf('Inc. step: %d, Error in XY dir: %.4f\n',I,sum(error_matrix(:,2)));
fprintf('Inc. step: %d, Error in YY dir: %.4f\n',I,sum(error_matrix(:,3)));

% end

% abs_num_inc = find(listInc == I);
% for n = 0:num_DIC_runs-1
% 	% label incremental step
% 	corr_table((1+abs_num_inc.*num_DIC_runs)+n,1) = I;
% 	% label label frame number
% 	corr_table((1+abs_num_inc.*num_DIC_runs)+n,2) = listImTest(n+2);
% end

% % placing the mean correlation of all xx/xy/yy correlation values, for a
% % given inc step
% corr_table(1,7) = mean(corr_table(:,6));
%
% % placing correlation values into Excel spreadsheet (multiple frames per
% % increment step)
% % first row of top entry of corr_table inside Excel_corr_table
% first_row_Excel_corr_table = 1 + abs_num_inc.*num_DIC_runs;
% % path to Increment Step Excel spreadsheet
% xlsPath = [fPathSF fPathSpec fPrefix '_IncrementStep.xlsx'];
% % top left box to write corr_table values in Excel spreadsheet
% stXLSInd = ['A' num2str(first_row_Excel_corr_table)];
% % bottom right box to write corr_table values in Excel spreadsheet
% end_row_Excel_corr_table = first_row_Excel_corr_table + num_DIC_runs - 1;
% endXLSInd = ['G' num2str(end_row_Excel_corr_table)];  % 'G' because it has 7 cols
% % range for writing corr_table values in Excel spreadsheet
% rangeXLS = [stXLSInd ':' endXLSInd];
% xlswrite(xlsPath,corr_table,char(rangeXLS));
% % headers above data
% % corr_table_headers{1} = 'Inc Step';
% % corr_table_headers{2} = 'Frame #';
% % corr_table_headers{3} = 'R^2 Eps XX';
% % corr_table_headers{4} = 'R^2 Eps XY';
% % corr_table_headers{5} = 'R^2 Eps YY';
% % corr_table_headers{6} = 'Mean R^2';
% clear corr_table
% % % % clearvars -except I fPathSF fPathSpec fPathDIC fPrefix fPrefix2 fPathTF wsNameList runN stInc incStep endInc fNumTest numTesFr specID fPathLoc fFail xCropCoord yCropCoord wCrop hCrop extraNotes x_i y_i x_f y_f subsetSize subsetSpcg xlsPath dicoutFolMove disout_I_FolPath
% end % if no output folder / "output folder doesn't exist"
% thus, if the output folder does exist, then...
% end


% FINDING MAX CORR VALUE
% corr_table_xls = xlsread(xlsPath);                             	% Excel spreadsheet containing corr_table
% maxCorr = max(corr_table_xls(:,end));                          	% max Corr value
% [maxCorrR maxCorrC] = find(corr_table_xls == maxCorr);         	% Find max correlation value (row and col)
% optimal_inc_step = corr_table_xls(maxCorrR,1);
% fprintf('Optimal incremental step: %d\nCorrelation Produced: %.4f\n',optimal_inc_step,maxCorr);

cd(fPathDIC);

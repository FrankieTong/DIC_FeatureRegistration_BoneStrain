%creating batches of McGill DIC ref to Run

def_fileNames=cell(1,1);

% subsetSizeS = [45,55];
% subsetSpaceS = 2;

subsetSizeS = 21;
subsetSpaceS = 5;

qoS = [0;0;0;0;0;0];

%defining window for 2510MD_2-3-1etoh_notch_cam2_C002S0001
% Xp_firstS(1) =	70;
% Yp_firstS(1) =	38;
% Xp_lastS(1) =	116;
% Yp_lastS(1) =	255;

Xp_firstS(1) =	225;
Yp_firstS(1) =	500;
Xp_lastS(1) =	275;
Yp_lastS(1) =	600;

%defining window for 2510MD-1-1-2saline_cam2_C002S0001
% Xp_firstS(2) =	70;
% Yp_firstS(2) =	38;
% Xp_lastS(2) =	116;
% Yp_lastS(2) =	255;

Xp_firstS(2) =	229;
Yp_firstS(2) =	493;
Xp_lastS(2) =	279;
Yp_lastS(2) =	593;


interp_orderS = 'Cubic (3rd order)';
TOLS = [1.00E-08, 5.00E-06];
optim_methodS = 'Newton Raphson';
Max_num_iterS = 40;

iterations = 30;

dirList = cell(1,1);
%dirList{1,1} = ['..\DIC_Test\2510MD_P2_etoh_cam2_C002S0001\Frames_for_DIC\'];
%dirList{2,1} = ['..\DIC_Test\2510MD-1-1-2saline_cam2_C002S0001\'];
dirList{1,1} = ['C:\Users\Frankie\Documents\MATLAB\SSDIC_MH_mod\SSDIC_MH_mod\DIC Workshop Package\Exercise_1\DIC\DogBone_ref.tif'];
dirList{2,1} = ['C:\Users\Frankie\Documents\MATLAB\SSDIC_MH_mod\SSDIC_MH_mod\DIC Workshop Package\Exercise_1\DIC\DogBone_def1.tif'];
	
%currentFileList = dir_matlab( [dirList{ind} '*_noLine_histeq.tif'] );
ref_image_FileS = dirList{1};
ind = 1;
indS = 1;
fileList{ind} = dirList(2:end);


success = mcGillDIC(ref_image_FileS,fileList{ind},subsetSizeS(indS),subsetSpaceS,qoS,Xp_firstS(ind),Yp_firstS(ind), Xp_lastS(ind), Yp_lastS(ind),interp_orderS,TOLS,optim_methodS,iterations,false,0);



%Retrive output_folder_path from global
global output_folder_path;

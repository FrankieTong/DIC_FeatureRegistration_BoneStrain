% Prepping the call for the DIC GUI command

% INPUT
Snum = 8;
x_i = 71;
y_i = 138;
x_f = 105;
y_f = 198;
subsetSize = 21;
subsetSpcg = 6;
groupSize = 1;

if Snum ==1
    numofFrames = 22;
    pathwayRef='D:\users\hardisty\Data\mike\Dropbox\DIC_2010_06\Frames_Specimen1\S1_50inc\C_H\C_H_00.tif';
elseif Snum == 2
    numofFrames = 16;
    pathwayRef='D:\users\hardisty\Data\mike\Dropbox\DIC_2010_06\Frames_Specimen2\S2_50inc\C_H\C_H_00.tif';
elseif Snum == 4
    numofFrames = 9;
    pathwayRef='D:\users\hardisty\Data\mike\Dropbox\DIC_2010_06\Frames_Specimen4\100increm_C_H\S4_C_H_00.tif';
elseif Snum == 5
    numofFrames = 15;
    pathwayRef='D:\users\hardisty\Data\mike\Dropbox\DIC_2010_06\Frames_Specimen5\S5_50inc\C_H\C_H_00.tif';
elseif Snum == 6
    numofFrames = 18;
    increm = 50;
    pathwayRef='D:\Frames_Spcm6_2510MD_1-1-2saline_cam2_C002S0001\50_inc_C_H_S\C_H_S_00.tif';

% Snum == 7 goes here!

 elseif Snum == 8
    numofFrames = 18;
    increm = 50;
    pathwayRef='D:\Frames_Spcm8_MH2440_s44_sal_Orthog\75-81\C_nonH_S_00.tif';
end
pathway1=pathwayRef(1:end-5);
pathway2=pathwayRef(1:end-6);


for n=1:numofFrames % number of total frames - 1 (not including 00 here)
    mydef = ['mydef_image_fileListP_S',num2str(Snum),'='];    
    if n == 1
        mydef_addon = [mydef,'{''',pathway1,num2str(n),'.tif'';'];
    elseif n < 10 & n < numofFrames      % cannot have the '}' at the end
        mydef_addon = [mydef_addon,'''',pathway1,num2str(n),'.tif'';'];
    elseif n >= 10 & n < numofFrames
        mydef_addon = [mydef_addon,'''',pathway2,num2str(n),'.tif'';'];
    elseif n < 10 & n == numofFrames     % must have the '}' at the end, dpd on nFrames (can be a single digit)
        mydef_addon = [mydef_addon,'''',pathway1,num2str(n),'.tif''};'];
    elseif n >= 10 & n == numofFrames
        mydef_addon = [mydef_addon,'''',pathway2,num2str(n),'.tif''};'];
    end
    
end


if groupSize ==1
    mcGillpath = ['mcGillDIC(''',pathwayRef,''',',mydef(1:end-1),',',num2str(subsetSize),',',num2str(subsetSpcg),',[0;0;0;0;0;0],',num2str(x_i),',',num2str(y_i),',',num2str(x_f),',',num2str(y_f),',''Quintic (5th order)'',[1.00E-08,5.00E-06],''Newton Raphson'',40,true,1:(length(',mydef(1:end-1),')));'];
elseif groupSize == 5
    mcGillpath = ['mcGillDIC(''',pathwayRef,''',',mydef(1:end-1),',',num2str(subsetSize),',',num2str(subsetSpcg),',[0;0;0;0;0;0],',num2str(x_i),',',num2str(y_i),',',num2str(x_f),',',num2str(y_f),',''Quintic (5th order)'',[1.00E-08,5.00E-06],''Newton Raphson'',40,true,[1,1,1,1,1,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5'];
    subt=(25-numofFrames).*2;
    mcGillpath = [mcGillpath(1:end-subt),']);'];
elseif groupSize == 7
    mcGillpath = ['mcGillDIC(''',pathwayRef,''',',mydef(1:end-1),',',num2str(subsetSize),',',num2str(subsetSpcg),',[0;0;0;0;0;0],',num2str(x_i),',',num2str(y_i),',',num2str(x_f),',',num2str(y_f),',''Quintic (5th order)'',[1.00E-08,5.00E-06],''Newton Raphson'',40,true,[1,1,1,1,1,1,1,2,2,2,2,2,2,2,3,3,3,3,3,3,3,4,4,4,4'];
    subt=(25-numofFrames).*2;
    mcGillpath = [mcGillpath(1:end-subt),']);'];
elseif groupSize == 9
    mcGillpath = ['mcGillDIC(''',pathwayRef,''',',mydef(1:end-1),',',num2str(subsetSize),',',num2str(subsetSpcg),',[0;0;0;0;0;0],',num2str(x_i),',',num2str(y_i),',',num2str(x_f),',',num2str(y_f),',''Quintic (5th order)'',[1.00E-08,5.00E-06],''Newton Raphson'',40,true,[1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3'];
    subt=(25-numofFrames).*2;
    mcGillpath = [mcGillpath(1:end-subt),']);'];
end

comment=['% spec ',num2str(Snum),', subset size: ',num2str(subsetSize),', subset spacing: ',num2str(subsetSpcg),', frames: "48" - end, ' num2str(increm) ' increm'];
disp(comment);
disp(mydef_addon);
fprintf('\n');
disp(mcGillpath);
fprintf('\n\n');
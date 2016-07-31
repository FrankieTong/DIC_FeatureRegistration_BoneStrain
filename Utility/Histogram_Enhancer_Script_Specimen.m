% Script for histogram correction
d = ['D:\Frames_Spcm9_S531_Saline_Failure1_c1\50_inc_C_H_S' '\'];

for t=0:81                              % # of images
    root = 'C_nonH_S_';
    if length(num2str(t)) == 1
        file_name = [root '0'];         %for 0-9 ORIGINAL
    elseif length(num2str(t)) == 2
        file_name = root;
    end
    file_name_full = [file_name,num2str(t),'.tif'];
    I = imread(file_name_full);
    J = histeq(I);
    root2 = 'C_H_S_';
    if length(num2str(t)) == 1
        save_file_name = [root2 '0'];   %for HISTOGRAM ENHANCED
    elseif length(num2str(t)) == 2
        save_file_name = root2;   
    end
    save_file_full = [d save_file_name,num2str(t),'.tif'];
    imwrite(J,save_file_full);
end
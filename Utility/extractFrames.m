% Directory of the files, extracting Frames from Original images
d = ['D:\Frames_Spcm9_S531_Saline_Failure1_c1\All Frames_50 inc' '\'];

for t=0:50:2375            % 0:increm=50;lastFrame=3295
    root = 'S531_Saline_Failure1_c1_Aligned';
    if length(num2str(t)) == 1
        file_name = [root '000'];           %ORIGINAL
    elseif length(num2str(t)) == 2
        file_name = [root '00'];
    elseif length(num2str(t)) == 3
        file_name = [root '0'];
    elseif length(num2str(t)) == 4
        file_name = root;
    end
    file_name_full = [file_name,num2str(t),'.tif'];
    I = imread(file_name_full);
    J = I;
    root2 = 'S531_Aligned';
    if length(num2str(t)) == 1
        save_file_name = [root2 '000'];      %for HISTOGRAM ENHANCED
    elseif length(num2str(t)) == 2
        save_file_name = [root2 '00'];
    elseif length(num2str(t)) == 3
        save_file_name = [root2 '0'];   
    elseif length(num2str(t)) == 4
        save_file_name = root2;
    end
    save_file_full = [d save_file_name,num2str(t),'.tif'];
    imwrite(J,save_file_full);
end
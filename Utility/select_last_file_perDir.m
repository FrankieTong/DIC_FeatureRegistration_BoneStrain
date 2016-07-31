function [ last_files ] = select_last_file_perDir( fileList )
    %fileList a cell array containing a list of files with path information
    %embedded absolute or relative it does not matter
    nFiles = size(fileList,1);
    last_files = cell(50,1);
    last_files_counter = 1;
    for ind_File = 1:nFiles-1
        [current_pathstr, current_fileName, current_ext] = fileparts(fileList{ind_File});
        [next_pathstr, next_fileName, next_ext] = fileparts(fileList{ind_File+1});
        if strcmp(current_pathstr,next_pathstr) == 0
            last_files(last_files_counter) = fileList(ind_File);
            last_files_counter = last_files_counter +1;
        end
    end
    last_files(last_files_counter) = fileList(nFiles);
end


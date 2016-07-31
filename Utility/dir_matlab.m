function [ file_list ] = dir_matlab( search_text )

    [status,allFilesStr] = system(['dir "' search_text '" /s /b']);
    if status == 0
        beg_new_files = strfind(allFilesStr, ':\');
        nFileNum = size(beg_new_files,2);
        file_list = cell(nFileNum,1);
    
        for indFile = 1:(nFileNum-1)
            file_list{indFile} = strtrim(allFilesStr(beg_new_files(indFile)-1:beg_new_files(indFile+1)-2));
        end
        file_list{nFileNum}=strtrim(allFilesStr(beg_new_files(nFileNum)-1:end));
    else
        file_list = strtrim(allFilesStr);
    end
    
end


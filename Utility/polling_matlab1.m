%polling
global waitTime;
waitTime = 5;

global polling_flag;
polling_flag = true;
!dumBat.bat &
%diary on
handle = actxserver('matlab.application');
tline = cell(400,1);

while polling_flag == true
   
	try
        system('del currentLog1.txt');
        diary('currentLog1.txt')
        handle.Execute('cd ''C:\Documents and Settings\hardisty\My Documents\Mike\Dropbox\SSDIC\DIC Workshop Package\DIC_2010_06''');
		handle.Execute('clear cons_script1');
        handle.Execute('cons_script1')
		%j=batch('cons_script');
        %system('"C:\Program Files\MATLAB\R2011a\bin\matlab.exe" -r "C:\Documents and Settings\hardisty\My Documents\Mike\Dropbox\SSDIC\DIC Workshop Package\DIC_2010_06\cons_script.m" -wait -sd "C:\Documents and Settings\hardisty\My Documents\Mike\Dropbox\SSDIC\DIC Workshop Package\DIC_2010_06" -nosplash -logfile "C:\Documents and Settings\hardisty\My Documents\Mike\Dropbox\SSDIC\DIC Workshop Package\DIC_2010_06\matlabLog.txt" ')
        %seeWhatsHappening = 1;
        diary off
    catch err
	
    end
    
    try
        fid = fopen('currentLog1.txt');

        %tline{1,1} = fgets(fid);
        tline_counter = 1;
        while ~feof(fid)
            tline{tline_counter} = fgets(fid);
            tline_counter = tline_counter +1;
        end
        fclose(fid);

        fidW = fopen('wholeLog1.txt','a');
        for line_index = 1:(tline_counter-1)
            fprintf(fidW, tline{line_index});
        end

        fclose(fidW);
    catch err
    end
   
    
	pause(waitTime);
end
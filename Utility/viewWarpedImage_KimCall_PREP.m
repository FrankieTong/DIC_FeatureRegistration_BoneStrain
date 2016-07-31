% Directory of the files
% d = 'D:\users\hardisty\Data\mike\Dropbox\DIC_2010_06\Post-Process_Outputs_for_2012-07-11_Specimen5\Post-Process_Outputs_for_2012-08-08_S5_DiffGroup4\Processed_Data_Abbrev';

dirData = dir('*.mat');         %# Get the selected file data
fileNames = {dirData.name};     %# Create a cell array of file names
for iFile = 1:numel(fileNames)  %# Loop over the file names
  newName = sprintf('Workspace%.0f.mat',iFile);  %# Make the new name
  movefile(fileNames{iFile},newName,'f');        %# Rename the file
end

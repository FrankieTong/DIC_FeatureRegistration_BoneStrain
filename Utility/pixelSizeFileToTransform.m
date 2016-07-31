function [ matlabAffineTform ] = pixelSizeFileToTransform( pixelSizeFileName )
%recover alignment transform from pixelsize file output by
%imageregistration


%load M and test from pixelSize.txt
fid = fopen(pixelSizeFileName);
rawTxtData = textscan(fid, '%s %f');
fclose(fid);

dataColumn = rawTxtData{2};
M=zeros(3,3);
test=zeros(3,3);
counter= 0;
for c = 1:3
    for r= 1:3
        counter=counter +1;
        M(r,c)=dataColumn(counter+1);
        test(r,c)=dataColumn(counter+10);
    end
end


matlabAffineTform = maketform('affine',M * test);

end


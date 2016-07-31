function [Rsq] = viewWarpedImage_Kim_CorrImages(pathWarped,pathTarget)

%%% warped %%%

Iwarped_three = imread(pathWarped);
Iwarpedraw = rgb2gray(Iwarped_three);

[sizex sizey] = size(Iwarpedraw);
Wrow=1;
for t=2:sizex;
    if Iwarpedraw(t,:)==255
        Wrow(end+1)=t;
    end
end
Iwarpedraw(Wrow,:)=[];

Wcol=1;
for t=2:sizey;
    if Iwarpedraw(:,t)==255
        Wcol(end+1)=t;
    end
end

Iwarpedraw(:,Wcol)=[];
Iwarped = imresize(Iwarpedraw,4);
Jwarped = histeq(Iwarped);

%%% target %%%

Itarget_three = imread(pathTarget);
Itargetraw = rgb2gray(Itarget_three);
 
[sizex sizey] = size(Itargetraw);
Wrow=1;
for t=2:sizex;
    if Itargetraw(t,:)==255
        Wrow(end+1)=t;
    end
end
Itargetraw(Wrow,:)=[];
 
Wcol=1;
for t=2:sizey;
    if Itargetraw(:,t)==255
        Wcol(end+1)=t;
    end
end
 
Itargetraw(:,Wcol)=[];
Itarget = imresize(Itargetraw,4);
Jtarget = histeq(Itarget);

R=corrcoef(cov(double(Jwarped)),cov(double(Jtarget)));
Rval=R(1,2);
Rsq=Rval.^2;

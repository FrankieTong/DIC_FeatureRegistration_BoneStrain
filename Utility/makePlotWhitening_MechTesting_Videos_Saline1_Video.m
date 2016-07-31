%Generating Videos for ORS - plots will appear on videos of both Whitening
%and Stress vs Strain

%Inputs
%frames - or at least the names of the frames
%List of - Frame , Strain , Stress
%        - Frame Whitening




totalCases = 2;
startFileNum=1;
endFileNum=1;

fileStep = 5;

dirNames = cell(totalCases,1);
dirNames{1} = 'F:\OutsideDropbox\Whitening_Demin\Demineralized_DIC_to_failure\Extracted_Video_Data\2510MD2-2-2_cam2_C002S0001\Frames';
videoTragetFile = [dirNames{1} '\matlabSummaryVideo.avi']

videoWriterInstance = VideoWriter(videoTragetFile);
videoWriterInstance.FrameRate = 350/fileStep;
open(videoWriterInstance);


imageFilePrefixList = cell(totalCases,1);
numStacks = ones(totalCases,1);

for ind_dir = startFileNum:endFileNum
	%[pathstr1, name1, ext1] = fileparts(dirNames{ind_dir});
	%[pathstr2, name2, ext2] = fileparts(pathstr1);
	imageFilePrefixList{ind_dir} = '2510MD2-2-2_v1_'; %name2;
	tifFileList = dir_matlab([dirNames{ind_dir} '\' name2 '.tif']);
	%note I am assuming the only other tif is one labelfield file
	numStacks(ind_dir) = size(tifFileList,1);%-1;   
end


ind_imgStack =1;
fileNum=3000;
frameNumber=fileNum;

imageBoundingBox = [240,80;400,425];
%imageBoundingBox =[1,1;400,400]


verticalAxisPixelSize = 100;
horizontalAxisPixelSize = 100;
tickMarkPeriod=25;
%origin = [310,430];
origin = [265-imageBoundingBox(1,1),400-imageBoundingBox(1,2)];
stressMax = 15;
stressMin = 0;
    
strainMin=0;
strainMax=0.3;
    
whiteningMin=0;
whiteningMax=0.4;

maxNumberOfStressRecords=370;



frameStrainStressData = csvread('d:\users\hardisty\Data\mike\Dropbox\Whitening_Demin\Demineralized_DIC_to_failure\MTS_Data\MH_2510_MD-2-2-2_FrameStrainStress.csv');

frameStrainStressData=frameStrainStressData(1:maxNumberOfStressRecords,:);

frameStrainWhiteningData = csvread('d:\users\hardisty\Data\mike\Dropbox\Whitening_Demin\Demineralized_DIC_to_failure\MTS_Data\MH_2510_MD-2-2-2_FrameStrainWhitening.csv');


%Intermediate Interpolation

numberOfStrainLevels=2000;
interpFrameStrainWhiteningData=zeros(numberOfStrainLevels,3);
tempArray=strainMin:((strainMax-strainMin)/numberOfStrainLevels)*(numberOfStrainLevels+1)/numberOfStrainLevels:strainMax;
interpFrameStrainWhiteningData(:,2)=tempArray;
interpFrameStrainWhiteningData(:,1)=interp1(frameStrainWhiteningData(:,2),frameStrainWhiteningData(:,1),interpFrameStrainWhiteningData(:,2),'cubic');
interpFrameStrainWhiteningData(:,3)=interp1(frameStrainWhiteningData(:,2),frameStrainWhiteningData(:,3),interpFrameStrainWhiteningData(:,2),'cubic');
%interpFrameStrainWhiteningData(:,3)
interpFrameStrainWhiteningData(:,3)=smooth(interpFrameStrainWhiteningData(:,3));
frameStrainWhiteningData=interpFrameStrainWhiteningData;


scaledFrameStrainWhiteningData = frameStrainWhiteningData;
scaledFrameStrainWhiteningData(:,2) = ((frameStrainWhiteningData(:,2)-strainMin)/(strainMax-strainMin))*horizontalAxisPixelSize+origin(1);
scaledFrameStrainWhiteningData(:,3) = -1*((frameStrainWhiteningData(:,3)-whiteningMin)/(whiteningMax-whiteningMin))*verticalAxisPixelSize+origin(2);


scaledFrameStrainStressData = frameStrainStressData;
scaledFrameStrainStressData(:,2) = ((frameStrainStressData(:,2)-strainMin)/(strainMax-strainMin))*horizontalAxisPixelSize+origin(1);
scaledFrameStrainStressData(:,3) = -1*((frameStrainStressData(:,3)-stressMin)/(stressMax-stressMin))*verticalAxisPixelSize+origin(2);


%interpolatedScaled

interpolatedFrameStrainWhiteningStress=zeros(frameNumber,4);
interpolatedFrameStrainWhiteningStress(:,1)=0:frameNumber-1;
interpolatedFrameStrainWhiteningStress(:,2)=interp1(scaledFrameStrainWhiteningData(:,1),scaledFrameStrainWhiteningData(:,2),interpolatedFrameStrainWhiteningStress(:,1),'cubic');
interpolatedFrameStrainWhiteningStress(:,3)=interp1(scaledFrameStrainWhiteningData(:,1),scaledFrameStrainWhiteningData(:,3),interpolatedFrameStrainWhiteningStress(:,1),'cubic');
interpolatedFrameStrainWhiteningStress(:,4)=interp1(scaledFrameStrainStressData(:,1),scaledFrameStrainStressData(:,3),interpolatedFrameStrainWhiteningStress(:,1),'cubic');



%load frame
 for ind_file = 0:fileStep:fileNum-fileStep
     ind_file
     currentImageFileName = [dirNames{ind_imgStack} '\' imageFilePrefixList{ind_imgStack} sprintf('%04d',ind_file) '.tif'];
     currentImage = imread(currentImageFileName);
    
     imshow(currentImage(imageBoundingBox(1,2):imageBoundingBox(2,2),imageBoundingBox(1,1):imageBoundingBox(2,1)));
     hold on;
     
    %insert text into frame
    
    
    
    
    
    
    
    

    %Draw Whitening Data
        
    plot(scaledFrameStrainWhiteningData(:,2),scaledFrameStrainWhiteningData(:,3),'y','LineWidth',1);
    
    
    %Draw Stress Strain Data
    
    %plot(interpolatedFrameStrainWhiteningStress(:,2),interpolatedFrameStrainWhiteningStress(:,4),'b','LineWidth',2);
    plot(scaledFrameStrainStressData(:,2),scaledFrameStrainStressData(:,3),'b','LineWidth',2);
    
    
    %Draw Vertical Axis
    %need to specify starting and ending point
    %- for the Stress
    
    endpointVerticalAxis1=origin-[0,verticalAxisPixelSize];
    successFlag = createAxis( origin, endpointVerticalAxis1, 'b', 2, tickMarkPeriod);
    text(origin(1)-10,origin(2)+5,['0      Stress     ' num2str(stressMax)],'color','b','rotation',90,'FontSize',10,'FontWeight','bold')
    
    %Draw Vertical Axis
    %need to specify starting and ending point
    %- for Whitening

    startPointVerticalAxis2=origin+[horizontalAxisPixelSize,0];
    endpointVerticalAxis2=origin+[horizontalAxisPixelSize,-1*verticalAxisPixelSize];
    successFlag = createAxis( startPointVerticalAxis2, endpointVerticalAxis2, 'y', 2, tickMarkPeriod);
    text(origin(1)+120,origin(2)+5,['0   Whitening   ' num2str(whiteningMax)],'color','y','rotation',90,'FontSize',10,'FontWeight','bold')
    
    %Draw Horizonal Axis
    %need to specify starting and ending point
    %- for strain

    successFlag = createAxis( origin, startPointVerticalAxis2, 'r', 2, tickMarkPeriod);
    text(origin(1)-5,origin(2)+15,['0      Strain     ' num2str(strainMax)],'color','r','rotation',0,'FontSize',10,'FontWeight','bold')
    
    %Draw current stress Strain Data
    
    
    %Need to code the plotting of the current data, just found the
    %interpolated data
    currentDotColor = 'w';
    currentDotOutlineColor ='k';
    currentDotSize=6;
    %,'o','LineWidth',2,'MarkerEdgeColor',currentDotOutlineColor,'MarkerFaceColor',currentDotColor,'MarkerSize',currentDotSize)
    plot(interpolatedFrameStrainWhiteningStress(ind_file+1,2),interpolatedFrameStrainWhiteningStress(ind_file+1,3),'o','LineWidth',2,'MarkerEdgeColor',currentDotOutlineColor,'MarkerFaceColor',currentDotColor,'MarkerSize',currentDotSize);
    currentDotOutlineColor ='w';
    currentDotColor = 'c';
    plot(interpolatedFrameStrainWhiteningStress(ind_file+1,2),interpolatedFrameStrainWhiteningStress(ind_file+1,4),'o','LineWidth',2,'MarkerEdgeColor',currentDotOutlineColor,'MarkerFaceColor',currentDotColor,'MarkerSize',currentDotSize);
    hold off;
    
    currFrame = getframe;
    writeVideo(videoWriterInstance,currFrame);
    
 end
 
 close(videoWriterInstance);
function [ finalSegmentation ] = levelSetSegmentation_Li( Img,initGuess,figureFlag,timestep,iter_inner,iter_outer,lambda,alfa,epsilon,sigma,potential,iter_refine,edgeDetector,alpha_s,beta_s)
    %  This Matlab code demonstrates an edge-based active contour model as an application of 
    %  the Distance Regularized Level Set Evolution (DRLSE) formulation in the following paper:
    %
    %  C. Li, C. Xu, C. Gui, M. D. Fox, "Distance Regularized Level Set Evolution and Its Application to Image Segmentation", 
    %     IEEE Trans. Image Processing, vol. 19 (12), pp. 3243-3254, 2010.
    %
    % Author: Chunming Li, all rights reserved
    % E-mail: lchunming@gmail.com   
    %         li_chunming@hotmail.com 
    % URL:  http://www.engr.uconn.edu/~cmli/

    %clear all;
    %close all;

    %Img = imread('twocells.bmp'); % real miscroscope image of cells
    Img=double(Img(:,:,1));
    %% parameter setting
    if ~exist('timestep','var'), timestep=5; end
      % time step
    mu=0.2/timestep;  % coefficient of the distance regularization term R(phi)
    
    if ~exist('iter_inner','var'), iter_inner=5; end
    
    if ~exist('iter_outer','var'), iter_outer=40; end
    
    if ~exist('lambda','var'), lambda=5; end % coefficient of the weighted length term L(phi)
        
    if ~exist('alfa','var'), alfa=1.5; end  % coefficient of the weighted area term A(phi)
        
    if ~exist('epsilon','var'), epsilon=1.5; end % papramater that specifies the width of the DiracDelta function

    if ~exist('sigma','var'), sigma=1.5; end    % scale parameter in Gaussian kernel
    
    if ~exist('edgeDetector','var'), edgeDetector=1; end    
    
    if edgeDetector==1
        G=fspecial('gaussian',15,sigma);
        Img_smooth=conv2(Img,G,'same');  % smooth image by Gaussiin convolution
        [Ix,Iy]=gradient(Img_smooth);
        f=Ix.^2+Iy.^2;
        g=1./(1+f);  % edge indicator function.
    else
        if ~exist('beta_s','var'), beta_s=65; end  
        if ~exist('alpha_s','var'), alpha_s=25; end
        %G=fspecial('gaussian',15,sigma);
        %Img_smooth=conv2(Img,G,'same');  % smooth image by Gaussiin convolution
        Img_smooth=Img;
        %g=1./(1+exp(-(Img_smooth-beta_s)/alpha_s));
        g=double(Img>beta_s)*1.0
    end
    

    % initialize LSF as binary step function
    c0=2;
    %initialLSF=c0*ones(size(Img));
    % generate the initial region R0 as a rectangle
    %initialLSF(10:290, 10:180)=-c0;
    %we want -2 inside and 2 outside so 1->-2 0=>2
    initialLSF=-c0*c0*double(initGuess)+c0;

    phi=initialLSF;

    if figureFlag==1
        figure(1);
        mesh(-phi);   % for a better view, the LSF is displayed upside down
        hold on;  contour(phi, [0,0], 'r','LineWidth',2);
        title('Initial level set function');
        VIEW([-80 35]);

        figure(2);
        imagesc(Img,[0, 255]); axis off; axis equal; hold on;  contour(phi, [0,0], 'r');
        title('Initial zero level contour');
        pause(0.5);
    end
    
    if ~exist('potential','var'), potential=2; end
    
    
    if potential ==1
        potentialFunction = 'single-well';  % use single well potential p1(s)=0.5*(s-1)^2, which is good for region-based model 
    elseif potential == 2
        potentialFunction = 'double-well';  % use double-well potential in Eq. (16), which is good for both edge and region based models
    else
        potentialFunction = 'double-well';  % default choice of potential function
    end


    % start level set evolution
    for n=1:iter_outer
        phi = drlse_edge(phi, g, lambda, mu, alfa, epsilon, timestep, iter_inner, potentialFunction);
        if figureFlag==1
            if mod(n,2)==0
                figure(2);
                imagesc(Img,[0, 255]); axis off; axis equal; hold on;  contour(phi, [0,0], 'r');
            end
        end
    end

    % refine the zero level contour by further level set evolution with alfa=0
    alfa=0;
    
    if ~exist('iter_refine','var'), iter_refine=10; end
    
    phi = drlse_edge(phi, g, lambda, mu, alfa, epsilon, timestep, iter_inner, potentialFunction);

    %finalLSF=phi;
    
    finalSegmentation = (phi<0)*1;
    
    if figureFlag==1
        figure(2);
        imagesc(Img(:,:),[0, 255]); axis off; axis equal; hold on;  contour(phi, [0,0], 'r');
        hold on;  contour(phi, [0,0], 'r');
        str=['Final zero level contour, ', num2str(iter_outer*iter_inner+iter_refine), ' iterations'];
        title(str);

        pause(1);
        figure;
        mesh(-finalLSF); % for a better view, the LSF is displayed upside down
        hold on;  contour(phi, [0,0], 'r','LineWidth',2);
        str=['Final level set function, ', num2str(iter_outer*iter_inner+iter_refine), ' iterations'];
        title(str);
        axis on;
    end
end



global t XYPosSS EPSyyRW dirParent numofHoles

spacing = 2;
ssposX = XYPosSS{t}(:,1);  % position of subsets outside of black dots
ssposY = XYPosSS{t}(:,2);
rw_data = EPSyyRW{t}(:,2);
numssX = length(unique(XYPosSS{t}(:,1)));  % number of subset in X dir
numssY = length(unique(XYPosSS{t}(:,2)));  % number of subset in Y dir 

clear x_plotRW
for u=1:numssX-1; 
    x_plotRW(1:numssY,u) = min(ssposX)+spacing*(u-1);   % make x matrix such that each column has the same value (since they have the same x value)
end
    if x_plotRW(1,end) ~= max(ssposX)
     x_plotRW(:,end+1) = x_plotRW(1,end) + spacing;
    end

clear y_plotRW
for u=1:numssY-1;
    y_plotRW(u,1:numssX) = min(ssposY)+spacing*(u-1);   % make y matrix such that each row has the same value (same y value)
end
    if y_plotRW(end,1) ~= max(ssposY);
     y_plotRW(end+1,:) = y_plotRW(end,1) + spacing;
    end
                                       
y_plotRW = flipud(y_plotRW);                            % flip y coordinates b/c they are upside down > should be lower numbers on bottom

% we must put the RW values into the correct cells

for u=1:length(ssposX);
    [r colx] = find (x_plotRW == ssposX(u));    % 1 colx vector equal to indices of x matrix equal to col number (for 60, 62, 64, colx = 1, 2, 3, . . .)
    [rowy c] = find (y_plotRW == ssposY(u));    % 1 rowy vector equal to indices of y matrix equal to row number (for 82, 80, 78, rowy = 1, 2, 3, . . .)
    % position of RW value in rw matrix = (rowy,colx)
        if numel(rowy) == 0
        else 
             rw_plotRW(rowy(1),colx(1)) = rw_data(u);    % color matrix
        end
end

% subplot(1,2,1)
RW = pcolor (x_plotRW,y_plotRW,rw_plotRW); caxis([0 .4]); colormap jet; colorbar
set(RW, 'EdgeColor', 'none');
% axes('Position', [20 30 40 200]);

% plot polygons on pcolor
for hole = 1:numofHoles;         % for each hole
    col_x = 3*hole - 2;
    col_y = 3*hole - 1;
    x{hole} = BlackDots_allFr{1,10}(:,col_x);
    y{hole} = BlackDots_allFr{1,10}(:,col_y);
end

%   plot points on white graph
%     hold on; subplot(1,2,1)
    hold on; plot(x{1},y{1},'r-'); 
    hold on; plot(x{2},y{2},'r-'); 
    hold on; plot(x{3},y{3},'r-');
    hold on; plot(x{4},y{4},'r-');
    hold on; plot(x{5},y{5},'r-');
 
%     connect dots on white graph
%     hold on; subplot(1,2,1)
    hold on; plot(x{1},y{1},'b.');
    hold on; plot(x{2},y{2},'b.'); 
    hold on; plot(x{3},y{3},'b.'); 
    hold on; plot(x{4},y{4},'b.'); 
    hold on; plot(x{5},y{5},'b.'); 
    hold on; plot(x{5},y{5},'b.');
    
% save images of black dot polygons
    dirPath = [dirParent '\RW Field Plots'];
    if exist(dirPath,'dir') == 0    
        mkdir(dirParent,'RW Field Plots');
    end
    picname = [dirParent '\RW Field Plots\RWfield_fr_' num2str(t) '.tif'];
    saveas(gcf, picname);
    
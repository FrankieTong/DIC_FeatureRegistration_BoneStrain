[rawWhiteningNumerical,rawWhiteningNumericalHeader] = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2440_c1_421_1_rep1_C001S0001\Aligned\whitening_Size_Summary.xlsx',1);
        rawWhiteningNumerical = removeRowsWithNaN(rawWhiteningNumerical, 1);
        
        rawHeightNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2440_c1_421_1_rep1_C001S0001\Aligned\heightSummary.xls');
        rawHeightNumerical = removeRowsWithNaN( rawHeightNumerical, 1 );
        rawHeightNumericalHeader = {'Frame','Height'};
        
        rawThicknessNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2440_c1_421_1_rep1_C001S0001\Aligned\thicknessSummary.xls');
        rawThicknessNumerical = removeRowsWithNaN( rawThicknessNumerical ,1);
        rawThicknessNumericalHeader = {'Frame', 'Thickness'};
        
          
        [mtsNumerical,mtsText] = xlsread('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2440MD_421_Saline_Creep_rep1.xlsx');
        mtsNumericalHeader = mtsText(5,1:4);
        mtsNumerical = mtsNumerical(4:size(mtsNumerical,1),1:4);
        mtsNumerical = removeRowsWithNaN( mtsNumerical,1);
        tableList = cell(4,1);
        tableList{1} = mtsNumerical;
        tableList{2} = rawWhiteningNumerical;
        tableList{3} = rawHeightNumerical;
        tableList{4} = rawThicknessNumerical;
        
          headerList = cell(4,1);
        headerList{1} = mtsNumericalHeader;
        headerList{2} = rawWhiteningNumericalHeader;
        headerList{3} = rawHeightNumericalHeader;
        headerList{4} = rawThicknessNumericalHeader;
        
        offsetList = cell(4,1);
        offsetList{1} = 0;
        offsetList{2} = 1;
        offsetList{3} = 1;
        offsetList{4} = 1;
 
        coeffecientList = cell(4,1);
        coeffecientList{1} = 1;
        coeffecientList{2} = 1/60;
        coeffecientList{3} = 1/60;
        coeffecientList{4} = 1/60;
 
        [combinedVideoMtsTable, combinedHeader,dataWithHeader] = combineTables(tableList,headerList,offsetList,coeffecientList);
        
        [~,mtsFileName,~ ] = fileparts('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2440MD_421_Saline_Creep_rep1.xlsx');
        mtsDataFolder = 'F:\OutsideDropbox\Whitening_Demin\Run3\creep\MTS Excel Finished'
        xlswrite([mtsDataFolder '\' mtsFileName '_combinedVideoMtsTable.xlsx'],dataWithHeader);
        
        
        
        
        
        
        
        
        
        [rawWhiteningNumerical,rawWhiteningNumericalHeader] = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2440_c1_421_2_rep1_C001S0001\Aligned\whitening_Size_Summary.xlsx',1);
        rawWhiteningNumerical = removeRowsWithNaN(rawWhiteningNumerical, 1);
        
        rawHeightNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2440_c1_421_2_rep1_C001S0001\Aligned\heightSummary.xls');
        rawHeightNumerical = removeRowsWithNaN( rawHeightNumerical, 1 );
        rawHeightNumericalHeader = {'Frame','Height'};
        
        rawThicknessNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2440_c1_421_2_rep1_C001S0001\Aligned\thicknessSummary.xls');
        rawThicknessNumerical = removeRowsWithNaN( rawThicknessNumerical ,1);
        rawThicknessNumericalHeader = {'Frame', 'Thickness'};
        
          
        [mtsNumerical,mtsText] = xlsread('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2440MD_421_Saline_Creep_rep1.xlsx');
        mtsNumericalHeader = mtsText(5,1:4);
        mtsNumerical = mtsNumerical(4:size(mtsNumerical,1),1:4);
        mtsNumerical = removeRowsWithNaN( mtsNumerical,1);
        tableList = cell(4,1);
        tableList{1} = mtsNumerical;
        tableList{2} = rawWhiteningNumerical;
        tableList{3} = rawHeightNumerical;
        tableList{4} = rawThicknessNumerical;
        
          headerList = cell(4,1);
        headerList{1} = mtsNumericalHeader;
        headerList{2} = rawWhiteningNumericalHeader;
        headerList{3} = rawHeightNumericalHeader;
        headerList{4} = rawThicknessNumericalHeader;
        
        offsetList = cell(4,1);
        offsetList{1} = 0;
        offsetList{2} = 1+900;
        offsetList{3} = 1+900;
        offsetList{4} = 1+900;
 
        coeffecientList = cell(4,1);
        coeffecientList{1} = 1;
        coeffecientList{2} = 1/60;
        coeffecientList{3} = 1/60;
        coeffecientList{4} = 1/60;
 
        [combinedVideoMtsTable, combinedHeader,dataWithHeader] = combineTables(tableList,headerList,offsetList,coeffecientList);
        
        [~,mtsFileName,~ ] = fileparts('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2440MD_421_Saline_Creep_rep1.xlsx');
        mtsDataFolder = 'F:\OutsideDropbox\Whitening_Demin\Run3\creep\MTS Excel Finished2'
        xlswrite([mtsDataFolder '\' mtsFileName '_combinedVideoMtsTable.xlsx'],dataWithHeader);
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        [rawWhiteningNumerical,rawWhiteningNumericalHeader] = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2440_c1_421_1_rep2_C001S0001\Aligned\whitening_Size_Summary.xlsx',1);
        rawWhiteningNumerical = removeRowsWithNaN(rawWhiteningNumerical, 1);
        
        rawHeightNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2440_c1_421_1_rep2_C001S0001\Aligned\heightSummary.xls');
        rawHeightNumerical = removeRowsWithNaN( rawHeightNumerical, 1 );
        rawHeightNumericalHeader = {'Frame','Height'};
        
        rawThicknessNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2440_c1_421_1_rep2_C001S0001\Aligned\thicknessSummary.xls');
        rawThicknessNumerical = removeRowsWithNaN( rawThicknessNumerical ,1);
        rawThicknessNumericalHeader = {'Frame', 'Thickness'};
        
          
        [mtsNumerical,mtsText] = xlsread('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2440MD_421_Saline_Creep_rep2.xlsx');
        mtsNumericalHeader = mtsText(5,1:4);
        mtsNumerical = mtsNumerical(4:size(mtsNumerical,1),1:4);
        mtsNumerical = removeRowsWithNaN( mtsNumerical,1);
        tableList = cell(4,1);
        tableList{1} = mtsNumerical;
        tableList{2} = rawWhiteningNumerical;
        tableList{3} = rawHeightNumerical;
        tableList{4} = rawThicknessNumerical;
        
          headerList = cell(4,1);
        headerList{1} = mtsNumericalHeader;
        headerList{2} = rawWhiteningNumericalHeader;
        headerList{3} = rawHeightNumericalHeader;
        headerList{4} = rawThicknessNumericalHeader;
        
        offsetList = cell(4,1);
        offsetList{1} = 0;
        offsetList{2} = 1;
        offsetList{3} = 1;
        offsetList{4} = 1;
 
        coeffecientList = cell(4,1);
        coeffecientList{1} = 1;
        coeffecientList{2} = 1/60;
        coeffecientList{3} = 1/60;
        coeffecientList{4} = 1/60;
 
        [combinedVideoMtsTable, combinedHeader,dataWithHeader] = combineTables(tableList,headerList,offsetList,coeffecientList);
        
        [~,mtsFileName,~ ] = fileparts('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2440MD_421_Saline_Creep_rep2.xlsx');
        mtsDataFolder = 'F:\OutsideDropbox\Whitening_Demin\Run3\creep\MTS Excel Finished3'
        xlswrite([mtsDataFolder '\' mtsFileName '_combinedVideoMtsTable.xlsx'],dataWithHeader);
        
        
        
        
        
        
        
        
        
        [rawWhiteningNumerical,rawWhiteningNumericalHeader] = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2440_c1_421_2_rep2_C001S0001\Aligned\whitening_Size_Summary.xlsx',1);
        rawWhiteningNumerical = removeRowsWithNaN(rawWhiteningNumerical, 1);
        
        rawHeightNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2440_c1_421_2_rep2_C001S0001\Aligned\heightSummary.xls');
        rawHeightNumerical = removeRowsWithNaN( rawHeightNumerical, 1 );
        rawHeightNumericalHeader = {'Frame','Height'};
        
        rawThicknessNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2440_c1_421_2_rep2_C001S0001\Aligned\thicknessSummary.xls');
        rawThicknessNumerical = removeRowsWithNaN( rawThicknessNumerical ,1);
        rawThicknessNumericalHeader = {'Frame', 'Thickness'};
        
          
        [mtsNumerical,mtsText] = xlsread('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2440MD_421_Saline_Creep_rep2.xlsx');
        mtsNumericalHeader = mtsText(5,1:4);
        mtsNumerical = mtsNumerical(4:size(mtsNumerical,1),1:4);
        mtsNumerical = removeRowsWithNaN( mtsNumerical,1);
        tableList = cell(4,1);
        tableList{1} = mtsNumerical;
        tableList{2} = rawWhiteningNumerical;
        tableList{3} = rawHeightNumerical;
        tableList{4} = rawThicknessNumerical;
        
          headerList = cell(4,1);
        headerList{1} = mtsNumericalHeader;
        headerList{2} = rawWhiteningNumericalHeader;
        headerList{3} = rawHeightNumericalHeader;
        headerList{4} = rawThicknessNumericalHeader;
        
        offsetList = cell(4,1);
        offsetList{1} = 0;
        offsetList{2} = 1+900;
        offsetList{3} = 1+900;
        offsetList{4} = 1+900;
 
        coeffecientList = cell(4,1);
        coeffecientList{1} = 1;
        coeffecientList{2} = 1/60;
        coeffecientList{3} = 1/60;
        coeffecientList{4} = 1/60;
 
        [combinedVideoMtsTable, combinedHeader,dataWithHeader] = combineTables(tableList,headerList,offsetList,coeffecientList);
        
        [~,mtsFileName,~ ] = fileparts('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2440MD_421_Saline_Creep_rep2.xlsx');
        mtsDataFolder = 'F:\OutsideDropbox\Whitening_Demin\Run3\creep\MTS Excel Finished4'
        xlswrite([mtsDataFolder '\' mtsFileName '_combinedVideoMtsTable.xlsx'],dataWithHeader);
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
         [rawWhiteningNumerical,rawWhiteningNumericalHeader] = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2490_c1_43_1_rep1_C001S0001\Aligned\whitening_Size_Summary.xlsx',1);
        rawWhiteningNumerical = removeRowsWithNaN(rawWhiteningNumerical, 1);
        
        rawHeightNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2490_c1_43_1_rep1_C001S0001\Aligned\heightSummary.xls');
        rawHeightNumerical = removeRowsWithNaN( rawHeightNumerical, 1 );
        rawHeightNumericalHeader = {'Frame','Height'};
        
        rawThicknessNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2490_c1_43_1_rep1_C001S0001\Aligned\thicknessSummary.xls');
        rawThicknessNumerical = removeRowsWithNaN( rawThicknessNumerical ,1);
        rawThicknessNumericalHeader = {'Frame', 'Thickness'};
        
          
        [mtsNumerical,mtsText] = xlsread('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2490MD_43_Saline_Creep_rep1.xlsx');
        mtsNumericalHeader = mtsText(5,1:4);
        mtsNumerical = mtsNumerical(4:size(mtsNumerical,1),1:4);
        mtsNumerical = removeRowsWithNaN( mtsNumerical,1);
        tableList = cell(4,1);
        tableList{1} = mtsNumerical;
        tableList{2} = rawWhiteningNumerical;
        tableList{3} = rawHeightNumerical;
        tableList{4} = rawThicknessNumerical;
        
          headerList = cell(4,1);
        headerList{1} = mtsNumericalHeader;
        headerList{2} = rawWhiteningNumericalHeader;
        headerList{3} = rawHeightNumericalHeader;
        headerList{4} = rawThicknessNumericalHeader;
        
        offsetList = cell(4,1);
        offsetList{1} = 0;
        offsetList{2} = 1;
        offsetList{3} = 1;
        offsetList{4} = 1;
 
        coeffecientList = cell(4,1);
        coeffecientList{1} = 1;
        coeffecientList{2} = 1/60;
        coeffecientList{3} = 1/60;
        coeffecientList{4} = 1/60;
 
        [combinedVideoMtsTable, combinedHeader,dataWithHeader] = combineTables(tableList,headerList,offsetList,coeffecientList);
        
        [~,mtsFileName,~ ] = fileparts('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2490MD_43_Saline_Creep_rep1.xlsx');
        mtsDataFolder = 'F:\OutsideDropbox\Whitening_Demin\Run3\creep\MTS Excel Finished5'
        xlswrite([mtsDataFolder '\' mtsFileName '_combinedVideoMtsTable.xlsx'],dataWithHeader);
        
        
        
        
        
        
        
        
        
        [rawWhiteningNumerical,rawWhiteningNumericalHeader] = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2490_c1_43_2_rep1_C001S0001\Aligned\whitening_Size_Summary.xlsx',1);
        rawWhiteningNumerical = removeRowsWithNaN(rawWhiteningNumerical, 1);
        
        rawHeightNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2490_c1_43_2_rep1_C001S0001\Aligned\heightSummary.xls');
        rawHeightNumerical = removeRowsWithNaN( rawHeightNumerical, 1 );
        rawHeightNumericalHeader = {'Frame','Height'};
        
        rawThicknessNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2490_c1_43_2_rep1_C001S0001\Aligned\thicknessSummary.xls');
        rawThicknessNumerical = removeRowsWithNaN( rawThicknessNumerical ,1);
        rawThicknessNumericalHeader = {'Frame', 'Thickness'};
        
          
        [mtsNumerical,mtsText] = xlsread('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2490MD_43_Saline_Creep_rep1.xlsx');
        mtsNumericalHeader = mtsText(5,1:4);
        mtsNumerical = mtsNumerical(4:size(mtsNumerical,1),1:4);
        mtsNumerical = removeRowsWithNaN( mtsNumerical,1);
        tableList = cell(4,1);
        tableList{1} = mtsNumerical;
        tableList{2} = rawWhiteningNumerical;
        tableList{3} = rawHeightNumerical;
        tableList{4} = rawThicknessNumerical;
        
          headerList = cell(4,1);
        headerList{1} = mtsNumericalHeader;
        headerList{2} = rawWhiteningNumericalHeader;
        headerList{3} = rawHeightNumericalHeader;
        headerList{4} = rawThicknessNumericalHeader;
        
        offsetList = cell(4,1);
        offsetList{1} = 0;
        offsetList{2} = 1+900;
        offsetList{3} = 1+900;
        offsetList{4} = 1+900;
 
        coeffecientList = cell(4,1);
        coeffecientList{1} = 1;
        coeffecientList{2} = 1/60;
        coeffecientList{3} = 1/60;
        coeffecientList{4} = 1/60;
 
        [combinedVideoMtsTable, combinedHeader,dataWithHeader] = combineTables(tableList,headerList,offsetList,coeffecientList);
        
        [~,mtsFileName,~ ] = fileparts('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2490MD_43_Saline_Creep_rep1.xlsx');
        mtsDataFolder = 'F:\OutsideDropbox\Whitening_Demin\Run3\creep\MTS Excel Finished6'
        xlswrite([mtsDataFolder '\' mtsFileName '_combinedVideoMtsTable.xlsx'],dataWithHeader);
        
        
        
        
        
        
        
        
        
        
       
        
        
        
        
        
        
        
        [rawWhiteningNumerical,rawWhiteningNumericalHeader] = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2490_c1_43_1_rep2_C001S0001\Aligned\whitening_Size_Summary.xlsx',1);
        rawWhiteningNumerical = removeRowsWithNaN(rawWhiteningNumerical, 1);
        
        rawHeightNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2490_c1_43_1_rep2_C001S0001\Aligned\heightSummary.xls');
        rawHeightNumerical = removeRowsWithNaN( rawHeightNumerical, 1 );
        rawHeightNumericalHeader = {'Frame','Height'};
        
        rawThicknessNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2490_c1_43_1_rep2_C001S0001\Aligned\thicknessSummary.xls');
        rawThicknessNumerical = removeRowsWithNaN( rawThicknessNumerical ,1);
        rawThicknessNumericalHeader = {'Frame', 'Thickness'};
        
          
        [mtsNumerical,mtsText] = xlsread('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2490MD_43_Saline_Creep_rep2.xlsx');
        mtsNumericalHeader = mtsText(5,1:4);
        mtsNumerical = mtsNumerical(4:size(mtsNumerical,1),1:4);
        mtsNumerical = removeRowsWithNaN( mtsNumerical,1);
        tableList = cell(4,1);
        tableList{1} = mtsNumerical;
        tableList{2} = rawWhiteningNumerical;
        tableList{3} = rawHeightNumerical;
        tableList{4} = rawThicknessNumerical;
        
          headerList = cell(4,1);
        headerList{1} = mtsNumericalHeader;
        headerList{2} = rawWhiteningNumericalHeader;
        headerList{3} = rawHeightNumericalHeader;
        headerList{4} = rawThicknessNumericalHeader;
        
        offsetList = cell(4,1);
        offsetList{1} = 0;
        offsetList{2} = 1;
        offsetList{3} = 1;
        offsetList{4} = 1;
 
        coeffecientList = cell(4,1);
        coeffecientList{1} = 1;
        coeffecientList{2} = 1/60;
        coeffecientList{3} = 1/60;
        coeffecientList{4} = 1/60;
 
        [combinedVideoMtsTable, combinedHeader,dataWithHeader] = combineTables(tableList,headerList,offsetList,coeffecientList);
        
        [~,mtsFileName,~ ] = fileparts('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2490MD_43_Saline_Creep_rep2.xlsx');
        mtsDataFolder = 'F:\OutsideDropbox\Whitening_Demin\Run3\creep\MTS Excel Finished7'
        xlswrite([mtsDataFolder '\' mtsFileName '_combinedVideoMtsTable.xlsx'],dataWithHeader);
        
        
        
        
        
        
        
        
        
        [rawWhiteningNumerical,rawWhiteningNumericalHeader] = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2490_c1_43_2_rep2_C001S0001\Aligned\whitening_Size_Summary.xlsx',1);
        rawWhiteningNumerical = removeRowsWithNaN(rawWhiteningNumerical, 1);
        
        rawHeightNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2490_c1_43_2_rep2_C001S0001\Aligned\heightSummary.xls');
        rawHeightNumerical = removeRowsWithNaN( rawHeightNumerical, 1 );
        rawHeightNumericalHeader = {'Frame','Height'};
        
        rawThicknessNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2490_c1_43_2_rep2_C001S0001\Aligned\thicknessSummary.xls');
        rawThicknessNumerical = removeRowsWithNaN( rawThicknessNumerical ,1);
        rawThicknessNumericalHeader = {'Frame', 'Thickness'};
        
          
        [mtsNumerical,mtsText] = xlsread('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2490MD_43_Saline_Creep_rep2.xlsx');
        mtsNumericalHeader = mtsText(5,1:4);
        mtsNumerical = mtsNumerical(4:size(mtsNumerical,1),1:4);
        mtsNumerical = removeRowsWithNaN( mtsNumerical,1);
        tableList = cell(4,1);
        tableList{1} = mtsNumerical;
        tableList{2} = rawWhiteningNumerical;
        tableList{3} = rawHeightNumerical;
        tableList{4} = rawThicknessNumerical;
        
          headerList = cell(4,1);
        headerList{1} = mtsNumericalHeader;
        headerList{2} = rawWhiteningNumericalHeader;
        headerList{3} = rawHeightNumericalHeader;
        headerList{4} = rawThicknessNumericalHeader;
        
        offsetList = cell(4,1);
        offsetList{1} = 0;
        offsetList{2} = 1+900;
        offsetList{3} = 1+900;
        offsetList{4} = 1+900;
 
        coeffecientList = cell(4,1);
        coeffecientList{1} = 1;
        coeffecientList{2} = 1/60;
        coeffecientList{3} = 1/60;
        coeffecientList{4} = 1/60;
 
        [combinedVideoMtsTable, combinedHeader,dataWithHeader] = combineTables(tableList,headerList,offsetList,coeffecientList);
        
        [~,mtsFileName,~ ] = fileparts('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2490MD_43_Saline_Creep_rep2.xlsx');
        mtsDataFolder = 'F:\OutsideDropbox\Whitening_Demin\Run3\creep\MTS Excel Finished8'
        xlswrite([mtsDataFolder '\' mtsFileName '_combinedVideoMtsTable.xlsx'],dataWithHeader);
        
        
        
        
        
        
        
     
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
         [rawWhiteningNumerical,rawWhiteningNumericalHeader] = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2526_c1_313_1_rep1_C001S0001\Aligned\whitening_Size_Summary.xlsx',1);
        rawWhiteningNumerical = removeRowsWithNaN(rawWhiteningNumerical, 1);
        
        rawHeightNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2526_c1_313_1_rep1_C001S0001\Aligned\heightSummary.xls');
        rawHeightNumerical = removeRowsWithNaN( rawHeightNumerical, 1 );
        rawHeightNumericalHeader = {'Frame','Height'};
        
        rawThicknessNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2526_c1_313_1_rep1_C001S0001\Aligned\thicknessSummary.xls');
        rawThicknessNumerical = removeRowsWithNaN( rawThicknessNumerical ,1);
        rawThicknessNumericalHeader = {'Frame', 'Thickness'};
        
          
        [mtsNumerical,mtsText] = xlsread('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2526MD_313_Saline_Creep_rep1.xlsx');
        mtsNumericalHeader = mtsText(5,1:4);
        mtsNumerical = mtsNumerical(4:size(mtsNumerical,1),1:4);
        mtsNumerical = removeRowsWithNaN( mtsNumerical,1);
        tableList = cell(4,1);
        tableList{1} = mtsNumerical;
        tableList{2} = rawWhiteningNumerical;
        tableList{3} = rawHeightNumerical;
        tableList{4} = rawThicknessNumerical;
        
          headerList = cell(4,1);
        headerList{1} = mtsNumericalHeader;
        headerList{2} = rawWhiteningNumericalHeader;
        headerList{3} = rawHeightNumericalHeader;
        headerList{4} = rawThicknessNumericalHeader;
        
        offsetList = cell(4,1);
        offsetList{1} = 0;
        offsetList{2} = 1;
        offsetList{3} = 1;
        offsetList{4} = 1;
 
        coeffecientList = cell(4,1);
        coeffecientList{1} = 1;
        coeffecientList{2} = 1/60;
        coeffecientList{3} = 1/60;
        coeffecientList{4} = 1/60;
 
        [combinedVideoMtsTable, combinedHeader,dataWithHeader] = combineTables(tableList,headerList,offsetList,coeffecientList);
        
        [~,mtsFileName,~ ] = fileparts('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2526MD_313_Saline_Creep_rep1.xlsx');
        mtsDataFolder = 'F:\OutsideDropbox\Whitening_Demin\Run3\creep\MTS Excel Finished9'
        xlswrite([mtsDataFolder '\' mtsFileName '_combinedVideoMtsTable.xlsx'],dataWithHeader);
        
        
        
        
        
        
        
        
        
        [rawWhiteningNumerical,rawWhiteningNumericalHeader] = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2526_c1_313_2_rep1_C001S0001\Aligned\whitening_Size_Summary.xlsx',1);
        rawWhiteningNumerical = removeRowsWithNaN(rawWhiteningNumerical, 1);
        
        rawHeightNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2526_c1_313_2_rep1_C001S0001\Aligned\heightSummary.xls');
        rawHeightNumerical = removeRowsWithNaN( rawHeightNumerical, 1 );
        rawHeightNumericalHeader = {'Frame','Height'};
        
        rawThicknessNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2526_c1_313_2_rep1_C001S0001\Aligned\thicknessSummary.xls');
        rawThicknessNumerical = removeRowsWithNaN( rawThicknessNumerical ,1);
        rawThicknessNumericalHeader = {'Frame', 'Thickness'};
        
          
        [mtsNumerical,mtsText] = xlsread('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2526MD_313_Saline_Creep_rep1.xlsx');
        mtsNumericalHeader = mtsText(5,1:4);
        mtsNumerical = mtsNumerical(4:size(mtsNumerical,1),1:4);
        mtsNumerical = removeRowsWithNaN( mtsNumerical,1);
        tableList = cell(4,1);
        tableList{1} = mtsNumerical;
        tableList{2} = rawWhiteningNumerical;
        tableList{3} = rawHeightNumerical;
        tableList{4} = rawThicknessNumerical;
        
          headerList = cell(4,1);
        headerList{1} = mtsNumericalHeader;
        headerList{2} = rawWhiteningNumericalHeader;
        headerList{3} = rawHeightNumericalHeader;
        headerList{4} = rawThicknessNumericalHeader;
        
        offsetList = cell(4,1);
        offsetList{1} = 0;
        offsetList{2} = 1+900;
        offsetList{3} = 1+900;
        offsetList{4} = 1+900;
 
        coeffecientList = cell(4,1);
        coeffecientList{1} = 1;
        coeffecientList{2} = 1/60;
        coeffecientList{3} = 1/60;
        coeffecientList{4} = 1/60;
 
        [combinedVideoMtsTable, combinedHeader,dataWithHeader] = combineTables(tableList,headerList,offsetList,coeffecientList);
        
        [~,mtsFileName,~ ] = fileparts('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2526MD_313_Saline_Creep_rep1.xlsx');
        mtsDataFolder = 'F:\OutsideDropbox\Whitening_Demin\Run3\creep\MTS Excel Finished10'
        xlswrite([mtsDataFolder '\' mtsFileName '_combinedVideoMtsTable.xlsx'],dataWithHeader);
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        [rawWhiteningNumerical,rawWhiteningNumericalHeader] = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2526_c1_313_1_rep2_C001S0001\Aligned\whitening_Size_Summary.xlsx',1);
        rawWhiteningNumerical = removeRowsWithNaN(rawWhiteningNumerical, 1);
        
        rawHeightNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2526_c1_313_1_rep2_C001S0001\Aligned\heightSummary.xls');
        rawHeightNumerical = removeRowsWithNaN( rawHeightNumerical, 1 );
        rawHeightNumericalHeader = {'Frame','Height'};
        
        rawThicknessNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2526_c1_313_1_rep2_C001S0001\Aligned\thicknessSummary.xls');
        rawThicknessNumerical = removeRowsWithNaN( rawThicknessNumerical ,1);
        rawThicknessNumericalHeader = {'Frame', 'Thickness'};
        
          
        [mtsNumerical,mtsText] = xlsread('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2526MD_313_Saline_Creep_rep2.xlsx');
        mtsNumericalHeader = mtsText(5,1:4);
        mtsNumerical = mtsNumerical(4:size(mtsNumerical,1),1:4);
        mtsNumerical = removeRowsWithNaN( mtsNumerical,1);
        tableList = cell(4,1);
        tableList{1} = mtsNumerical;
        tableList{2} = rawWhiteningNumerical;
        tableList{3} = rawHeightNumerical;
        tableList{4} = rawThicknessNumerical;
        
          headerList = cell(4,1);
        headerList{1} = mtsNumericalHeader;
        headerList{2} = rawWhiteningNumericalHeader;
        headerList{3} = rawHeightNumericalHeader;
        headerList{4} = rawThicknessNumericalHeader;
        
        offsetList = cell(4,1);
        offsetList{1} = 0;
        offsetList{2} = 1;
        offsetList{3} = 1;
        offsetList{4} = 1;
 
        coeffecientList = cell(4,1);
        coeffecientList{1} = 1;
        coeffecientList{2} = 1/60;
        coeffecientList{3} = 1/60;
        coeffecientList{4} = 1/60;
 
        [combinedVideoMtsTable, combinedHeader,dataWithHeader] = combineTables(tableList,headerList,offsetList,coeffecientList);
        
        [~,mtsFileName,~ ] = fileparts('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2526MD_313_Saline_Creep_rep2.xlsx');
        mtsDataFolder = 'F:\OutsideDropbox\Whitening_Demin\Run3\creep\MTS Excel Finished11'
        xlswrite([mtsDataFolder '\' mtsFileName '_combinedVideoMtsTable.xlsx'],dataWithHeader);
        
        
        
        
        
        
        
        
        
        [rawWhiteningNumerical,rawWhiteningNumericalHeader] = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2526_c1_313_2_rep2_C001S0001\Aligned\whitening_Size_Summary.xlsx',1);
        rawWhiteningNumerical = removeRowsWithNaN(rawWhiteningNumerical, 1);
        
        rawHeightNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2526_c1_313_2_rep2_C001S0001\Aligned\heightSummary.xls');
        rawHeightNumerical = removeRowsWithNaN( rawHeightNumerical, 1 );
        rawHeightNumericalHeader = {'Frame','Height'};
        
        rawThicknessNumerical = extractNumericalTableFromFrameXlsx('F:\OutsideDropbox\Whitening_Demin\Run3\creep\creep2526_c1_313_2_rep2_C001S0001\Aligned\thicknessSummary.xls');
        rawThicknessNumerical = removeRowsWithNaN( rawThicknessNumerical ,1);
        rawThicknessNumericalHeader = {'Frame', 'Thickness'};
        
          
        [mtsNumerical,mtsText] = xlsread('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2526MD_313_Saline_Creep_rep2.xlsx');
        mtsNumericalHeader = mtsText(5,1:4);
        mtsNumerical = mtsNumerical(4:size(mtsNumerical,1),1:4);
        mtsNumerical = removeRowsWithNaN( mtsNumerical,1);
        tableList = cell(4,1);
        tableList{1} = mtsNumerical;
        tableList{2} = rawWhiteningNumerical;
        tableList{3} = rawHeightNumerical;
        tableList{4} = rawThicknessNumerical;
        
          headerList = cell(4,1);
        headerList{1} = mtsNumericalHeader;
        headerList{2} = rawWhiteningNumericalHeader;
        headerList{3} = rawHeightNumericalHeader;
        headerList{4} = rawThicknessNumericalHeader;
        
        offsetList = cell(4,1);
        offsetList{1} = 0;
        offsetList{2} = 1+900;
        offsetList{3} = 1+900;
        offsetList{4} = 1+900;
 
        coeffecientList = cell(4,1);
        coeffecientList{1} = 1;
        coeffecientList{2} = 1/60;
        coeffecientList{3} = 1/60;
        coeffecientList{4} = 1/60;
 
        [combinedVideoMtsTable, combinedHeader,dataWithHeader] = combineTables(tableList,headerList,offsetList,coeffecientList);
        
        [~,mtsFileName,~ ] = fileparts('F:\OutsideDropbox\Whitening_Demin\Run3\CreepSpecific\MH_2526MD_313_Saline_Creep_rep2.xlsx');
        mtsDataFolder = 'F:\OutsideDropbox\Whitening_Demin\Run3\creep\MTS Excel Finished12'
        xlswrite([mtsDataFolder '\' mtsFileName '_combinedVideoMtsTable.xlsx'],dataWithHeader);
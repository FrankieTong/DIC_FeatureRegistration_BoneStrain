%testing CorrectStressWhiteningSignal for the initial cases

fileNameIndex = 1;
fileNames{fileNameIndex}='C:\Users\hardisty\Dropbox\Sam_visoelasticity\ProblemsForFilter\CombinedMH2440_711_Creep_c1_C001S0001.xlsx';
fileNameIndex = 1+fileNameIndex;
fileNames{fileNameIndex}='C:\Users\hardisty\Dropbox\Sam_visoelasticity\ProblemsForFilter\CombinedMH2440_811_Sal_demin_Stress_Relaxation3Higherload_C1_C001S0001.xlsx';
fileNameIndex = 1+fileNameIndex;
fileNames{fileNameIndex}='C:\Users\hardisty\Dropbox\Sam_visoelasticity\ProblemsForFilter\CombinedMH2509_232_StressRelax1_c1_C001S0001.xlsx';
fileNameIndex = 1+fileNameIndex;
fileNames{fileNameIndex}='C:\Users\hardisty\Dropbox\Sam_visoelasticity\ProblemsForFilter\CombinedMH2509_432_Creep_c1_C001S0001.xlsx';


for fileIndex = 1:size(fileNames,2)
    
    fileName=fileNames{fileIndex};
    num = xlsread(fileName,1);

    samplingFrequency =  1/mean(num(2:end,1)-num(1:end-1,1))
    Avgbackground = num(:,2);
    Avgsample = num(:,3);
    backgroundWithoutNaN = removeRowsWithNaN(Avgbackground);
    sampleWithoutNaN = removeRowsWithNaN(Avgsample);
    checkResult = correctStressWhiteningSignal(sampleWithoutNaN,backgroundWithoutNaN,samplingFrequency);
    figure
    plot(sampleWithoutNaN);figure(gcf);
    title(['Sample-' fileName])
    figure
    plot(checkResult);figure(gcf);
    title(['Result-' fileName]);
end
%fitting Viscoelastic Data
%creepJ

%xdataCreep,ydataCreep, xdataStressRelax and ydataStressRelax should be obtained from the excel files with creep and
%stres relaxation

%initial Guess
x0 =[10;10;0.1];

%fitting
[E1E2TauCreepResults,resnorm] = lsqcurvefit(@creepJ,x0,timeCreep,ydataCreep);



%fitting Stress Relaxation
%initial Guess
x0 =[10;10;0.1];
%fitting
[E1E2TauCreepResults,resnorm] = lsqcurvefit(@stressRelaxationE,x0,timeStressRelaxation,ydataStressRelax);
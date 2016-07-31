
timestep=5
iter_inner=5
iter_outer=5
lambda=5
alfa=-3
epsilon=1.5
alfa1=-3
alfa2=3
sigma=1.5
potential=2
iter_refine = 10
edgeDetector = 1
alpha_s = 5;
beta_s = 75;
directory = 'F:\OutsideDropbox\Whitening_Demin\Viscoelastic_Mechanical_Testing\MH2440_811_Sal_demin_stressRelax1_C1_C001S0001\Frames'
imageFilePrefix = 'MH2440_811_Sal_demin_stressRelax1_C1_C001S0001'
labelFieldFileName = 'MH2440_811_Sal_demin_stressRelax1_C1_C001S00010000.labels.tif'
fileStep = 5
levelSetSegmentation_Li_sequence( directory, imageFilePrefix,labelFieldFileName,fileStep, timestep,iter_inner,iter_outer,lambda,alfa1,alfa2,epsilon,sigma,potential,iter_refine,edgeDetector,alpha_s,beta_s)

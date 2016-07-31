function F = stressRelaxationE(E1E2Tau,xdata)
F = E1E2Tau(2)+;E1E2Tau(1)*exp(-xdata/E1E2Tau(3));
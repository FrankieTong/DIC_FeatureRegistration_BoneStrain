funtion correctedSignal = correctStressWhiteningSignal(stressWhiteningSignal, backgroundSignal,samplingFrequency)
%algorthm to filter and correct the stressWhitening signal obtained from
%high/regular speed videos
%-remove contribution from background
%-low pass filter
[parametersToMapMagnitudesOfBackgroundToStressWhitening,resnorm] = lsqcurvefit(@stressWhiteningBackgroundRelationShip,[1;1;1],backgroundSignal,stressWhiteningSignal);
scaledBackground = stressWhiteningBackgroundRelationShip(parametersToMapMagnitudesOfBackgroundToStressWhitening,backgroundSignal);


zeroOffSetBackground = scaledBackground - mean(scaledBackground(1:10));
stressWhitening_backgroundRemoved= stressWhiteningSignal-zeroOffSetBackground;

%implimenting lowpass filter with Butterworth 
nyquistFrequency = samplingFrequency/2;
wp=1/nyquistFrequency;%1hz passband and 
ws=5/nyquistFrequency;%5hz stopband
rp=1;%1db ripple in passband
rs=80;%80db attenuation
[n,Wn] = buttord(wp,ws,3,60);

[b,a] = butter(n,Wn);
Hd = dfilt.df1(b,a)
correctedSignal = filter(Hd,stressWhitening_backgroundRemoved)




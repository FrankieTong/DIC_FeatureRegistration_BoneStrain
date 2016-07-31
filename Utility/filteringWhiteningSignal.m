hlms2 = dsp.LMSFilter('Length', 1000, ...
   'Method', 'Normalized LMS',...
   'AdaptInputPort', true, ...
   'StepSizeSource', 'Input port', ...
   'WeightsOutputPort', false);
%hfilt2 = dsp.DigitalFilter(...
   %'TransferFunction', 'FIR (all zeros)', ...
   %'Numerator', fir1(10, [.5, .75]));
%noiseArtificial = randn(1000,1); % Noise
%mySignal = step(hfilt2, noiseArtificial) + sin(0:.05:49.95)'; % Noise + Signal
a = 1; % adaptation control
mu = 0.05; % step size
%[y, recoveredSignal] = step(hlms2, noiseArtificial, mySignal, mu, a);
%subplot(2,1,1), plot(d), title('Noise + Signal');
%subplot(2,1,2),plot(recoveredSignal), title('Signal');

[y, recoveredSignal] = step(hlms2, normalizedBackground, normalizedStressWhitening, mu, a);
subplot(3,1,1), plot(normalizedStressWhitening), title('StressWhitening');
subplot(3,1,2), plot(normalizedBackground), title('Background');
subplot(3,1,3),plot(recoveredSignal), title('recovered StressWhitening');
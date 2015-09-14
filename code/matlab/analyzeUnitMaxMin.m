% this script will find local maxima and minima and calculate peak-to-trough
% width (ms) and maxima/minima ratio

% first, run concatDataIncludeSpeed.m

% set unit height threshold
unit_thres = 4;

% name things appropriately
svg_unit_pt_name = strcat(trace_name, '_unit_pt.svg');

% find out data's mode so that we know what to compare peak and trough to
rec_concat_mode = mode(rec_concat);

% find local maxima in concatenated recording using findpeaks function
xmax=findpeaks(rec_concat, unit_thres); % last number is threshold (mV)         % find indices
rec_concat_peaks = rec_concat(xmax.loc);                    % find peak values

% plot local maxima on recording and check
figure(1)
plot(rec_concat, '-r')
hold on
plot(xmax.loc, rec_concat_peaks, '*k')                      % black = peaks

% find local minima within a given time window (2 ms) after the maxima
for i = 1:length(xmax.loc)
    rec_concat_temp = rec_concat((xmax.loc(i)+1):(xmax.loc(i)+20)); % 20 is # of indices during 2 ms (at 10,000 Hz sampling freq)
    [minValue(i), minIndex(i)] = min(rec_concat_temp);
    minIndexTrue(i) = minIndex(i) + xmax.loc(i);
end

% plot local minima on recording and check
plot(minIndexTrue, minValue, '*b')                           % blue = troughs
hold off

% calculate peak-to-trough width (ms)
peakTroughWidthSec = minIndex * (1 / 10000);
peakTroughWidthMs = peakTroughWidthSec * 1000;
peakTroughWidthMs_mean = mean(peakTroughWidthMs);

% calculate peak-to-trough amplitude ratio
peakTroughRatio = (rec_concat_peaks-rec_concat_mode) ./ (abs(minValue')-rec_concat_mode);
peakTroughRatio_mean = mean(peakTroughRatio);

% calculate peak-to-trough amplitude (mV)
peakTroughAmplitude = rec_concat_peaks - minValue';
peakTroughAmplitude_mean = mean(peakTroughAmplitude);

% plot width vs. ratio
figure(2)
plot(peakTroughWidthMs, peakTroughRatio, '.k')
hold on
plot(peakTroughWidthMs_mean, peakTroughRatio_mean, 'ok', 'MarkerSize',10, 'LineWidth', 3)
xlabel('unit peak-trough width (ms)')
ylabel('unit peak-trough amplitude ratio')
xlim([0 2])
ylim([0 15])

% save plot
plot2svg(svg_unit_pt_name);

fprintf('mode of data (should be close to 0 mV) = %.2f \n', rec_concat_mode);
fprintf('mean unit peak-trough width (ms) = %.2f \n', peakTroughWidthMs_mean);
fprintf('mean unit peak-trough amplitude ratio = %.2f \n', peakTroughRatio_mean);
fprintf('mean unit peak-trough amplitude = %.2f \n', peakTroughAmplitude_mean);

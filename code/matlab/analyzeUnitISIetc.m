% this script will further analyze stuff after finding local maxima and minima 
% (using analyzeUnitMaxMin to produce ISI histogram and incorporate ISI
% information into peak-trough measures, among other things

% first, run concatDataIncludeSpeed.m 
% then, run analyzeUnitMaxMin.m

% name things appropriately
svg_unit_isi_100ms_name = strcat(trace_name, '_unit_isi_100ms.svg');
svg_unit_isi_10ms_name = strcat(trace_name, '_unit_isi_10ms.svg');
svg_unit_ptwidth_isi_name = strcat(trace_name, '_unit_ptwidth_isi.svg');

% calculate ISI on local maxima already detected
% we will ignore the very first maxima detected (no ISI available)
ISIindices = diff(xmax.loc); 
ISIsec = ISIindices * (1 / 10000);

% plot ISI histogram; build 3 histograms at diff levels of zooming in

% 10s histogram (bin size: 10ms)
binMax1=10; %in sec; use 10.0 when looking at pyramidal cells or other sparsely-firing cells, but 1.0 otherwise
binInterval1=0.01; %in sec; use 0.01 when looking at pyramidal cells, but 0.001 otherwise
xTickUnit1=1; %in sec; use 1.0 when looking at pyramidal cells, but 0.1 otherwise
binMin=0;
[isiHistogram1,isiBinCenter1]=hist(ISIsec,binMin:binInterval1:binMax1);
isiHistogramNorm1=isiHistogram1/sum(isiHistogram1); %normalize y values to probability

figure(1)
bar(isiBinCenter1,isiHistogram1,'FaceColor','k','EdgeColor','w')
%bar(isiBinCenter1,isiHistogramNorm1,'FaceColor','k','EdgeColor','w')
set(gca,'xlim',[binMin binMax1]);
set(gca,'xtick',binMin:xTickUnit1:binMax1);
xlabel('ISI (sec)')
ylabel('number of spikes')

% 1s histogram zoomed into first 100ms (bin size: 1ms)
binMax2=1; %in sec; use 10.0 when looking at pyramidal cells or other sparsely-firing cells, but 1.0 otherwise
binInterval2=0.001; %in sec; use 0.01 when looking at pyramidal cells, but 0.001 otherwise
xTickUnit2=0.1; %in sec; use 1.0 when looking at pyramidal cells, but 0.1 otherwise
binMin=0;
[isiHistogram2,isiBinCenter2]=hist(ISIsec,binMin:binInterval2:binMax2);
isiHistogramNorm2=isiHistogram2/sum(isiHistogram2); %normalize y values to probability

figure(2)
bar(isiBinCenter2,isiHistogram2,'FaceColor','k','EdgeColor','w')
%bar(isiBinCenter2,isiHistogramNorm2,'FaceColor','k','EdgeColor','w')
set(gca,'xlim',[binMin 0.1]);
set(gca,'xtick',binMin:0.01:0.1);
set(gca, 'xticklabel', (binMin:0.01:0.1)*1000);
xlabel('ISI (ms)')
ylabel('number of spikes')

% save plot
plot2svg(svg_unit_isi_100ms_name);

% 1s histogram zoomed into first 10ms (bin size: 1ms)
figure(3)
bar(isiBinCenter2,isiHistogram2,'FaceColor','k','EdgeColor','w')
%bar(isiBinCenter2,isiHistogramNorm2,'FaceColor','k','EdgeColor','w')
set(gca,'xlim',[binMin 0.01]);
set(gca,'xtick',binMin:0.001:0.01);
set(gca, 'xticklabel', (binMin:0.001:0.01)*1000);
xlabel('ISI (ms)')
ylabel('number of spikes')

% save plot
plot2svg(svg_unit_isi_10ms_name);

% plot ISI vs width
figure(4)
semilogy(peakTroughWidthMs(2:end), ISIsec*1000, '.k')
xlim([0 2])
xlabel('unit peak-trough width (ms)')
ylabel('unit ISI (ms)')

% save plot
plot2svg(svg_unit_ptwidth_isi_name);

% for binarizing burst vs. non-burst spikes
% plot local maxima on recording again with different colours for diff ISI
% to check raw data
% (blue for peaks that happen with ISI from previous peaks =>15ms,
% red for peaks that happen with ISI from previous peaks <15ms)

% divide ISI values into the 2 ranges and get those indices
ISILongIndices = find(ISIsec >= 0.015); % 0.015 s = 15 ms
ISIShortIndices = find(ISIsec < 0.015);
% correct ISI indices to match local maxima indices (places in the list)
peakIndicesLongISI = ISILongIndices +1;
peakIndicesShortISI = ISIShortIndices +1;
% finally put these indices into real indices in data
peaksLongISI = xmax.loc(peakIndicesLongISI);
peaksShortISI = xmax.loc(peakIndicesShortISI);

figure(5)
plot(rec_concat, '-k')
hold on
plot(peaksLongISI, rec_concat_peaks(peakIndicesLongISI), '*b')     % blue = peaks with long ISI
plot(peaksShortISI, rec_concat_peaks(peakIndicesShortISI), '*r')   % red = peaks with short ISI

% calculate mean width, ratio and height values for 2 ranges
peakTroughWidthMs_mean_longISI = mean(peakTroughWidthMs(peakIndicesLongISI));
peakTroughWidthMs_mean_shortISI = mean(peakTroughWidthMs(peakIndicesShortISI));

peakTroughRatio_mean_longISI = mean(peakTroughRatio(peakIndicesLongISI));
peakTroughRatio_mean_shortISI = mean(peakTroughRatio(peakIndicesShortISI));

peakTroughAmplitude_mean_longISI = mean(peakTroughAmplitude(peakIndicesLongISI));
peakTroughAmplitude_mean_shortISI = mean(peakTroughAmplitude(peakIndicesShortISI));

% plot width vs. ratio again but with diff colours for diff ISI
figure(6)
plot(peakTroughWidthMs(peakIndicesLongISI), peakTroughRatio(peakIndicesLongISI), '.b') % blue = spikes with long ISI
hold on
plot(peakTroughWidthMs(peakIndicesShortISI), peakTroughRatio(peakIndicesShortISI), '.r') % red = spikes with short ISI
plot(peakTroughWidthMs_mean, peakTroughRatio_mean, 'ok', 'MarkerSize',10, 'LineWidth', 3)
plot(peakTroughWidthMs_mean_longISI, peakTroughRatio_mean_longISI, 'ob', 'MarkerSize',10, 'LineWidth', 3)
plot(peakTroughWidthMs_mean_shortISI, peakTroughRatio_mean_shortISI, 'or', 'MarkerSize',10, 'LineWidth', 3)
xlabel('unit peak-trough width (ms)')
ylabel('unit peak-trough amplitude ratio')
xlim([0 2])
ylim([0 15])

% print some numbers

%fprintf('Long ISI: mean unit peak-trough width (ms) = %.2f \n', peakTroughWidthMs_mean_longISI);
%fprintf('Long ISI: mean unit peak-trough amplitude ratio = %.2f \n', peakTroughRatio_mean_longISI);
%fprintf('Long ISI: mean unit peak-trough amplitude = %.2f \n \n', peakTroughAmplitude_mean_longISI);

%fprintf('Short ISI: mean unit peak-trough width (ms) = %.2f \n', peakTroughWidthMs_mean_shortISI);
%fprintf('Short ISI: mean unit peak-trough amplitude ratio = %.2f \n', peakTroughRatio_mean_shortISI);
%fprintf('Short ISI: mean unit peak-trough amplitude = %.2f \n \n', peakTroughAmplitude_mean_shortISI);

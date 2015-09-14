% this script should calculate firing rate for 
% 9 diff vis stim = 1 gray screen + 8 OD's
% 2015-5-04: changed ODdeg so that it starts from 0 deg

% TODO: probably need to fit a function on the data

% first, run findspikesTrials, then you get "spikemat"

% spikemat = findspikesTrials(rec, 10, false, 3, 0.4); %for units

% name things appropriately
svg_ODtuning_name = strcat(trace_name, '_ODtuning.svg');

% define number of conditions
num_cond = 9;

% define sampling point ranges for 1 window

presStart = 15001;
presEnd = 35000;

% collect spikemat info for the window of interest
spikematStim = spikemat(presStart:presEnd,:);

% count the number of times data contains 1 within those windows
%e.g., sum(X(rownumber,columnnumber)~=0)
spikeNumStim = sum(spikematStim(:,:)~=0);

% divide the number of times with length of time in each window to get
% firing rate in spikes/sec for each trial
% FRStim is firing rate for each trial <------------------------- note
FRStim = spikeNumStim / ((presEnd - presStart)/10000); % 10000 is sampling rate in Hz

% collect firing rates for each condition
% first, figure out how many trials there would be if all conditions were
% run the same number of times (perfect scenario) and fill an array of NaNs
numTrials = length(FRStim);
numRepetitions = ceil(length(FRStim)/num_cond); % some conditions have completed (NumRepetitions - 1)
numTrialsPerfect = num_cond*numRepetitions;
FRStimNaN = NaN(1, numTrialsPerfect);
% second, paste in the FRStim values into the array, padded with NaNs
FRStimNaN(1:numTrials) = FRStim; 
% reshape this array into dimension of rows x columns (num_cond x numReps)
FRcond = reshape(FRStimNaN, num_cond, []);

% get mean, std and SEM for the firing rate per condition
FRcond_mean = nanmean(FRcond,2);
FRcond_std = nanstd(FRcond,[],2);
FRcond_size = sum(~isnan(FRcond),2); % this figures out number of non-NaN elements in each row
FRcond_sem = FRcond_std ./ sqrt(FRcond_size);

% Special for orientations; sort orientations in an ascending order and match the firing rates, etc.
ODdeg = [-40, 0, 45, 90, 135, 180, 225, 270, 315];
[ODdegSort, ODdegSortOrder] = sort(ODdeg);
FRcond_mean_sorted = FRcond_mean(ODdegSortOrder);
FRcond_sem_sorted = FRcond_sem(ODdegSortOrder);

% plot mean firing rate for each condition

figure(1)
errorbar(ODdeg(2:9), FRcond_mean_sorted(2:9), FRcond_sem_sorted(2:9), 'k', 'LineWidth',2.5)
hold on
line([ODdeg(2) ODdeg(9)],[FRcond_mean_sorted(1) FRcond_mean_sorted(1)], 'Color','b', 'LineWidth',2.5)
line([ODdeg(2) ODdeg(9)],[(FRcond_mean_sorted(1)-FRcond_sem_sorted(1)) (FRcond_mean_sorted(1)-FRcond_sem_sorted(1))], 'LineStyle','--', 'Color','b', 'LineWidth',2.5)
line([ODdeg(2) ODdeg(9)],[(FRcond_mean_sorted(1)+FRcond_sem_sorted(1)) (FRcond_mean_sorted(1)+FRcond_sem_sorted(1))], 'LineStyle','--', 'Color','b', 'LineWidth',2.5)
hold off

% label plot properly
ylim([-0.2 (max(FRcond_mean_sorted(2:9)+max(FRcond_sem_sorted(2:9))))+0.2])
set(gca, 'XTick', ODdegSort(2:9))
set(gca, 'XTickLabel', ODdeg(2:9))
xlabel(gca, 'OD (deg)')
ylabel(gca, 'firing rate (Hz)')

% save plot
plot2svg(svg_ODtuning_name);

% MAY NOT NEED THE NEXT PART !!!!!!!!!!!!

% collect speed data for the window
speedStim = speed(presStart:presEnd,:);

% get mean, std and SEM for speed across every 9th sweep for each stim
meanSpeedStim = zeros(1,9);
stdSpeedStim = zeros(1,9);
semSpeedStim = zeros(1,9);
maxSpeedStim = zeros(1,9);

for i = 1:9
    loopSpeedStim = speedStim(:, i:9:end);
    meanLoopSpeedStim = mean(loopSpeedStim,1);
    meanSpeedStim(i) = mean(meanLoopSpeedStim);
    stdSpeedStim(i) = std(meanLoopSpeedStim);
    semSpeedStim(i) = std(meanLoopSpeedStim) / sqrt(size(meanLoopSpeedStim,2));
    maxSpeedStim(i) = max(meanLoopSpeedStim);
end

meanSpeedStimSort = meanSpeedStim(ODdegSortOrder);
stdSpeedStimSort = stdSpeedStim(ODdegSortOrder);
semSpeedStimSort = semSpeedStim(ODdegSortOrder);

% plot mean speed for each OD and a line for baseline

figure(2)
errorbar(ODdeg(2:9), meanSpeedStimSort(2:9), semSpeedStimSort(2:9), 'k', 'LineWidth',2.5)
hold on
line([ODdeg(2) ODdeg(9)],[meanSpeedStimSort(1) meanSpeedStimSort(1)], 'Color','b', 'LineWidth',2.5)
line([ODdeg(2) ODdeg(9)],[(meanSpeedStimSort(1)-semSpeedStimSort(1)) (meanSpeedStimSort(1)-semSpeedStimSort(1))], 'LineStyle','--', 'Color','b', 'LineWidth',2.5)
line([ODdeg(2) ODdeg(9)],[(meanSpeedStimSort(1)+semSpeedStimSort(1)) (meanSpeedStimSort(1)+semSpeedStimSort(1))], 'LineStyle','--', 'Color','b', 'LineWidth',2.5)
hold off

% label plot properly
set(gca, 'XTick', ODdegSort(2:9))
set(gca, 'XTickLabel', ODdeg(2:9))
xlabel(gca, 'OD (deg)')
ylabel(gca, 'running speed (cm/s)')


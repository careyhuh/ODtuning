% this script should calculate orientation/direction tuning measures
% TODO: fit a function on the data and re-calculate all measures
% TODO: fix bug so that orthoOrient and oppositeDir do not go out of range

% first you should have run the plotODtuning_9cond.m

% name things appropriately
csv_FR_mean_cond_name = strcat(trace_name, '_FR_mean_cond.csv');
mat_name = strcat(trace_name, '_data.mat');

%%% Orientation selectivity

% find preferred orientation and firing rate for that stim
[maxFR, maxIndex] = max(FRcond_mean(2:9)); % maxFR = FR for pref stim in Hz
ODdeg = [NaN, 0, 45, 90, 135, 180, 225, 270, 315];
prefOrientAng = ODdeg(maxIndex+1); % pref orient in deg

% find orthogonal orientation from preferred and firing rate for that stim
% orthogonal orient = preferred orient +/- 90 deg
orthoOrientAng1 = prefOrientAng - 90;
orthoOrientAng2 = prefOrientAng + 90;

orthoFR(1) = FRcond_mean(find(ODdeg == orthoOrientAng1));
orthoFR(2) = FRcond_mean(find(ODdeg == orthoOrientAng2));

meanOrthoFR = mean(orthoFR);

% calculate orientation selectivity index (OSI)
% OSI = (Rpref - Rortho) / (Rpref + Rortho)
OSI = abs(maxFR - meanOrthoFR) / (maxFR + meanOrthoFR);

%%% Direction selectivity

% find opposite direction from preferred direction and firing rate for that
% opposite direction = preferred orient + 180 deg
oppositeDirAng = prefOrientAng + 180;
oppositeDirFR = FRcond_mean(find(ODdeg == oppositeDirAng));

% calculate direction selectivity sindex (DSI)
% DSI = (Rpref = Ropposite) / (Rpref + Ropposite)
DSI = abs(maxFR - oppositeDirFR) / (maxFR + oppositeDirFR);

% find mean running speed for during vis stim
meanRunningSpeedVisStim = mean(meanSpeedStim(2:9));

% display values
fprintf('baseline mean firing rate (Hz) = %.2f \n', FRcond_mean(1));
fprintf('baseline mean running speed (cm/s) = %.2f \n', meanSpeedStim(1));
fprintf('preferred orientation and mean firing rate for that stim (deg, Hz) = %0.f and %.2f \n', prefOrientAng, maxFR);
fprintf('orthogonal orientation mean firing rate (Hz) = %.2f \n', meanOrthoFR);
fprintf('OSI = %.2f \n', OSI);
fprintf('opposite direction and mean firing rate for that stim (deg, Hz) = %0.f and %.2f \n', oppositeDirAng, oppositeDirFR);
fprintf('Direction selectivity = %.2f \n', DSI);
fprintf('mean running speed during vis stim (cm/s) = %.2f \n', meanRunningSpeedVisStim);

% save mean FR for each condition as .csv
csvwrite(csv_FR_mean_cond_name, FRcond_mean)

% save as .mat
save(mat_name)
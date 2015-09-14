% this script concatenates data and displays calculated speed as well

% name things appropriately
trace_name = input('s');
png_concat_name = strcat(trace_name, '_concat');

samplingRate = 10000;                % CHANGE this value if need be!

% load data
[data, digitalChannels, time] = readIgor_withDigital2();

% reorganize/rename data
% reduce number of dimensions so that it's usable:
rec = squeeze(data(1, :, :));
dio = squeeze(data(2, :, :));
ballx = squeeze(data(3, :, :));
bally = squeeze(data(4, :, :));

% calculate speed of mouse on ball, using analyzeBallData script
[ballx bally speed] = analyzeBallData_modified(data, 10, 100, 3, 4);

% concatenate data
rec_concat = reshape(rec, [], 1);
dio_concat = reshape(dio, [], 1);
speed_concat = reshape(speed, [], 1);
time_sec = time/1000;
time_sec_concat_total = length(rec_concat)/samplingRate;
time_sec_concat = [0:time_sec(2):(time_sec_concat_total-time_sec(2))];

% produces plot
figure(1)
ax1 = subplot(3,1,1); plot(time_sec_concat, rec_concat,'r'); ylabel(ax1, 'mV')
ax2 = subplot(3,1,2); plot(time_sec_concat, dio_concat,'g'); ylabel(ax2, 'diode')
ax3 = subplot(3,1,3); plot(time_sec_concat, speed_concat,'k'); ylabel(ax3, 'running speed (cm/s)')
linkaxes([ax1,ax2,ax3], 'x')
xlabel(ax3, 'time (s)')

% save plot
print(png_concat_name,'-dpng')

% calculate mean speed over entire recording
speed_concat_mean = mean(speed_concat);
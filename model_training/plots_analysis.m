dataFolder = "C:\Users\Abhijith_Kumble\Desktop\project_files\data_modified";  
window_size = 50;
stride = 1;

% Initialize containers
X = {};
Y = [];

% Load all CSVs and extract yaw-duration windows
files = dir(fullfile(dataFolder, '*.csv'));

for k = 1:length(files)
    filePath = fullfile(dataFolder, files(k).name);
    data = readtable(filePath);
    time_ms = data.Time_ms;
    yaw = data.yaw;

    if length(yaw) < window_size || any(isnan(yaw))
        continue;
    end
    
end

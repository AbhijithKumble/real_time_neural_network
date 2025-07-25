%% 1. Load Trained Model
load("C:\Users\Abhijith_Kumble\Desktop\project_files\model_training\trained_yaw_duration_model_tap_delay_small_window_ard_2_final.mat");  % loads: net, mu, sigma

%% 2. Load and Prepare Test Data
dataFolder = "C:\Users\Abhijith_Kumble\Desktop\project_files\data_modified";  
window_size = 25;
stride = 1;

X = {};
Y = [];
file_used = "";

files = dir(fullfile(dataFolder, '*.csv'));
for k = 1:length(files)
    filePath = fullfile(dataFolder, files(k).name);
    data = readtable(filePath);
    time_ms = data.Time_ms;
    yaw = data.yaw;

    if length(yaw) < window_size || any(isnan(yaw))
        continue;
    end

    for i = 1:stride:(length(yaw) - window_size + 1)
        segment = yaw(i:i+window_size-1);
        segment = reshape(segment, 1, []);  % [1 x window_size]
        duration = (time_ms(i+window_size-1) - time_ms(i)) / 1000;

        norm_segment = (segment - mu) ./ sigma;

        X{end+1,1} = norm_segment;
        Y(end+1,1) = duration;
    end

    % Save last valid file
    file_used = filePath;
end

%% 3. Predict on All Test Data
YPred = zeros(size(Y));

for i = 1:numel(X)
    segment = reshape(X{i}, 1, []);  % already normalized
    YPred(i) = predict(net, segment);
end

%% 4. Evaluation Metrics
rmse_val = sqrt(mean((YPred - Y).^2));
mae_val = mean(abs(YPred - Y));
r2_val = 1 - sum((YPred - Y).^2) / sum((Y - mean(Y)).^2);

fprintf('\n--- Test Set Evaluation ---\n');
fprintf('RMSE: %.4f seconds\n', rmse_val);
fprintf('MAE : %.4f seconds\n', mae_val);
fprintf('R^2 : %.4f\n', r2_val);

%% 5. Single Segment Prediction Demo
data = readtable(file_used);
yaw = data.yaw;
time_ms = data.Time_ms;

start_idx = 300;
if start_idx + window_size - 1 > length(yaw)
    error('start_idx + window_size exceeds signal length.');
end

yaw_segment = yaw(start_idx:start_idx+window_size-1);
yaw_segment = reshape(yaw_segment, 1, []);
yaw_segment_norm = (yaw_segment - mu) ./ sigma;

duration_pred = predict(net, yaw_segment_norm);
duration_actual = (time_ms(start_idx+window_size-1) - time_ms(start_idx)) / 1000;

fprintf('\n--- Single Segment Prediction ---\n');
fprintf('Predicted Duration : %.4f seconds\n', duration_pred);
fprintf('Actual Duration    : %.4f seconds\n', duration_actual);
fprintf('Difference         : %.4f seconds\n', duration_actual - duration_pred);

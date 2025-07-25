%% 3. Load trained model
load('trained_yaw_duration_model.mat');  % loads: net, mu, sigma

%% 4. Evaluate model performance on training data
YPred = zeros(size(YVal));
for i = 1:numel(XVal)
    YPred(i) = predict(net, XVal(i));
end

% Calculate evaluation metrics
rmse_val = sqrt(mean((YPred - YVal).^2));
mae_val = mean(abs(YPred - YVal));
r2_val = 1 - sum((YPred - YVal).^2) / sum((YVal - mean(YVal)).^2);

% Display training performance
fprintf('--- Model Evaluation on Validation Data ---\n');
fprintf('RMSE: %.4f seconds\n', rmse_val);
fprintf('MAE : %.4f seconds\n', mae_val);
fprintf('R^2 : %.4f\n\n', r2_val);

%% 5. Select and normalize test segment
window_size = 50;  % must match training window
yaw_segment = yaw(300:(300+window_size-1))';  % [1 x 50]
time_segment = time_ms(300:(300+window_size-1));  % [50 x 1]

% Normalize
yaw_segment = (yaw_segment - mu) / sigma;

%% 6. Predict
Xtest = {yaw_segment};  % wrap in cell for predict()
duration_pred = predict(net, Xtest);

%% 7. Compare with ground truth
duration_actual = (time_segment(end) - time_segment(1)) / 1000;  % convert ms to sec

% Display prediction vs actual
fprintf('--- Test Segment Prediction ---\n');
fprintf('Predicted Duration : %.4f seconds\n', duration_pred);
fprintf('Actual Duration    : %.4f seconds\n', duration_actual);
fprintf('differ: %.4f\n',duration_actual-duration_pred);

%% Parameters
window_size = 50;
stride = 50;  % or 1 for denser predictions

start_idx = 200;
end_idx = 4000;  % Predict from index 200 to 1000

predicted_durations = [];

for i = start_idx : stride : (end_idx - window_size + 1)
    % Extract windowed segment
    yaw_segment = yaw(i : i + window_size - 1)';
    time_segment = time_ms(i : i + window_size - 1);

    % Normalize
    yaw_segment = (yaw_segment - mu) / sigma;

    % Predict duration
    Xtest = {yaw_segment};
    duration_pred = predict(net, Xtest);

    predicted_durations(end+1) = duration_pred;
end

% Total predicted duration
total_predicted = sum(predicted_durations);

% Actual duration
duration_actual = (time_ms(end_idx) - time_ms(start_idx)) / 1000;

% Display results
fprintf('--- Long Range Duration Prediction ---\n');
fprintf('Start Index         : %d\n', start_idx);
fprintf('End Index           : %d\n', end_idx);
fprintf('Total Predicted     : %.4f seconds\n', total_predicted);
fprintf('Actual Duration     : %.4f seconds\n', duration_actual);
fprintf('Difference          : %.4f seconds\n', duration_actual - total_predicted);

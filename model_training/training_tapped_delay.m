%% 1. Configuration
dataFolder = "C:\Users\Abhijith_Kumble\Desktop\project_files\data_modified";  
window_size = 10;
stride = 3;

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

    for i = 1:stride:(length(yaw) - window_size + 1)
        segment = yaw(i:i+window_size-1)';
        duration = (time_ms(i+window_size-1) - time_ms(i)) / 1000;

        X{end+1,1} = segment;
        Y(end+1,1) = duration;
    end
end

%% 2. Normalize
allYaw = cell2mat(X);
mu = mean(allYaw);
sigma = std(allYaw);

for i = 1:numel(X)
    X{i} = (X{i} - mu) ./ sigma;
end

%% 3. Split into Train, Validation, Test
N = numel(X);
idx = randperm(N);

train_ratio = 0.7;
val_ratio = 0.15;

idxTrain = idx(1:round(train_ratio*N));
idxVal   = idx(round(train_ratio*N)+1 : round((train_ratio+val_ratio)*N));
idxTest  = idx(round((train_ratio+val_ratio)*N)+1 : end);

XTrain = X(idxTrain);
YTrain = Y(idxTrain);

XVal = X(idxVal);
YVal = Y(idxVal);

XTest = X(idxTest);
YTest = Y(idxTest);

% Convert cell arrays to numeric matrices for training
XTrainMat = cell2mat(XTrain);
XValMat   = cell2mat(XVal);

%% 4. Define and Train Model
inputSize = window_size;

layers = [
    featureInputLayer(inputSize)
    fullyConnectedLayer(8)
    reluLayer
    fullyConnectedLayer(1)
    regressionLayer
];


options = trainingOptions('adam', ...
    'MaxEpochs', 100, ...
    'MiniBatchSize', 32, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', {XValMat, YVal}, ...
    'ValidationFrequency', 50, ...
    'Plots', 'training-progress', ...
    'Verbose', false);

net = trainNetwork(XTrainMat, YTrain, layers, options);

% Save the trained model and normalization parameters
save('trained_yaw_duration_model_tap_delay_small_window_ard_2.mat', 'net', 'mu', 'sigma');

%% 5. Evaluate on Test Set
YPred = zeros(size(YTest));
for i = 1:numel(XTest)
    % Normalize test segment
    segment = (XTest{i} - mu) ./ sigma;
    YPred(i) = predict(net, segment);
end

% Evaluation Metrics
rmse_val = sqrt(mean((YPred - YTest).^2));
mae_val = mean(abs(YPred - YTest));
r2_val = 1 - sum((YPred - YTest).^2) / sum((YTest - mean(YTest)).^2);

fprintf('\n--- Test Set Evaluation ---\n');
fprintf('RMSE: %.4f seconds\n', rmse_val);
fprintf('MAE : %.4f seconds\n', mae_val);
fprintf('R^2 : %.4f\n', r2_val);

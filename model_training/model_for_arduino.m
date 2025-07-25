%% 1. Configuration
dataFolder = "C:\Users\Abhijith_Kumble\Desktop\project_files\data_modified";  
window_size = 4;
stride = 1;

X = {};
Y = [];

% Load CSVs and extract yaw-duration windows
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

%% 2. Normalize Data
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
XVal   = X(idxVal);
YVal   = Y(idxVal);
XTest  = X(idxTest);
YTest  = Y(idxTest);

% Convert to matrix format
XTrainMat = cell2mat(XTrain);  % size: [N x 4]
XValMat   = cell2mat(XVal);
XTestMat  = cell2mat(XTest);

%% 4. Define a Small Feedforward Model
inputSize = window_size;

layers = [
    featureInputLayer(inputSize, 'Name', 'input')
    fullyConnectedLayer(8, 'Name', 'fc1')       % Small hidden layer
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(1, 'Name', 'fc_out')    % Single output
    regressionLayer('Name', 'regression')
];

options = trainingOptions('adam', ...
    'MaxEpochs', 100, ...
    'MiniBatchSize', 16, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', {XValMat, YVal}, ...
    'ValidationFrequency', 20, ...
    'Plots', 'training-progress', ...
    'Verbose', false);

net = trainNetwork(XTrainMat, YTrain, layers, options);
save('tiny_ffnn_yaw_model.mat', 'net', 'mu', 'sigma');

%% 5. Evaluate on Test Set
YPred = predict(net, XTestMat);

rmse_val = sqrt(mean((YPred - YTest).^2));
mae_val = mean(abs(YPred - YTest));
r2_val = 1 - sum((YPred - YTest).^2) / sum((YTest - mean(YTest)).^2);

fprintf('\n--- Tiny FFNN Test Evaluation ---\n');
fprintf('RMSE: %.4f seconds\n', rmse_val);
fprintf('MAE : %.4f seconds\n', mae_val);
fprintf('R^2 : %.4f\n', r2_val);

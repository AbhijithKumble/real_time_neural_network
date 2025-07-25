% Read and normalize data%% 1. Load and Normalize Data
data = readmatrix('Xy_combined.csv');

% Split input and output
X = data(:, 1:end-1);
y = data(:, end);

% Check for NaN/Inf in raw data
fprintf('Any NaN in raw X: %d\n', any(isnan(X(:))));
fprintf('Any Inf in raw X: %d\n', any(isinf(X(:))));
fprintf('Any NaN in raw y: %d\n', any(isnan(y(:))));
fprintf('Any Inf in raw y: %d\n\n', any(isinf(y(:))));

% Normalize inputs and outputs
[X, ps] = mapminmax(X', 0, 1);  % X: [features x samples]
X = X';                         % X: [samples x features]
[y, ps_y] = mapminmax(y', 0, 1);
y = y';

%2. Create & Train Network
net = fitnet(10, 'trainscg');   % Scaled Conjugate Gradient

% Train/Validation/Test split
net.divideParam.trainRatio = 0.7;
net.divideParam.valRatio   = 0.15;
net.divideParam.testRatio  = 0.15;

% Training parameters
net.trainParam.epochs = 50;
net.trainParam.max_fail = 20;

% Train network
[net, tr] = train(net, X', y');  % transpose X and y for training

% 3. Get Predictions and Check for NaNs/Infs
y_pred = net(X');
y_pred = y_pred';  % Make it [samples x 1] for indexing

% Check for NaNs/Infs in predictions
fprintf('Any NaN in y_pred: %d\n', any(isnan(y_pred)));
fprintf('Any Inf in y_pred: %d\n', any(isinf(y_pred)));
fprintf('Any NaN in y: %d\n', any(isnan(y)));
fprintf('Any Inf in y: %d\n', any(isinf(y)));

% Check index sizes
fprintf('\ntrainInd size: %d\n', length(tr.trainInd));
fprintf('valInd size:   %d\n', length(tr.valInd));
fprintf('testInd size:  %d\n\n', length(tr.testInd));

% Check standard deviation (for correlation safety)
fprintf('std(y_pred(train)) = %f\n', std(y_pred(tr.trainInd)));
fprintf('std(y(train)) =      %f\n\n', std(y(tr.trainInd)));

% 4. Compute Metrics (if no NaNs)
if all(~isnan(y_pred)) && all(~isnan(y))
    % MSE
    train_mse = perform(net, y(tr.trainInd)', y_pred(tr.trainInd)');
    val_mse   = perform(net, y(tr.valInd)', y_pred(tr.valInd)');
    test_mse  = perform(net, y(tr.testInd)', y_pred(tr.testInd)');

    % R² function
    r2 = @(y_true, y_hat) 1 - sum((y_true - y_hat).^2) / sum((y_true - mean(y_true)).^2);

    R2_train = r2(y(tr.trainInd), y_pred(tr.trainInd));
    R2_val   = r2(y(tr.valInd), y_pred(tr.valInd));
    R2_test  = r2(y(tr.testInd), y_pred(tr.testInd));

    % Correlation Coefficient (R)
    R_train = corr(y(tr.trainInd), y_pred(tr.trainInd));
    R_val   = corr(y(tr.valInd), y_pred(tr.valInd));
    R_test  = corr(y(tr.testInd), y_pred(tr.testInd));

    % Print metrics
    fprintf('--- Performance Metrics ---\n');
    fprintf('Train MSE: %.6f | R²: %.4f | R: %.4f\n', train_mse, R2_train, R_train);
    fprintf('Val   MSE: %.6f | R²: %.4f | R: %.4f\n', val_mse, R2_val, R_val);
    fprintf('Test  MSE: %.6f | R²: %.4f | R: %.4f\n\n', test_mse, R2_test, R_test);
else
    fprintf('❌ Skipping metrics: NaN or Inf detected in y or y_pred.\n');
end

% 5. Visualize

% Error Histogram
figure;
ploterrhist(y - y_pred);
title('Error Histogram');

% True vs Predicted
figure;
plot(y, y_pred, 'bo');
hold on; refline(1,0);  % y = x line
xlabel('True Target');
ylabel('Predicted Output');
title('True vs Predicted Output');
grid on;

% Training performance over epochs
figure;
plotperform(tr);

%%
% data = readmatrix('Xy_combined_with_weights.csv');
% X = data(:, 1:end-1);
% y = data(:, end);
% [X, ps] = mapminmax(X', 0, 1);   % normalize each feature to [0, 1]
% X = X';                          % transpose back
% 
% [y, ps_y] = mapminmax(y', 0, 1);
% y = y';
% 
% net = fitnet(10, 'trainscg');  % 10 neurons, Scaled Conjugate Gradient
% 
% net.divideParam.trainRatio = 0.7;
% net.divideParam.valRatio   = 0.15;
% net.divideParam.testRatio  = 0.15;
% 
% net.trainParam.epochs = 50;
% net.trainParam.max_fail = 20;
% 
% % Train the network
% [net, tr] = train(net, X', y');   

% Save the trained network
% save('trained_regression_net.mat', 'net');

% ====== save('trained_regression_net.mat', 'net', 'tr', 'ps', 'ps_y');

% Plot prediction vs actual
% figure;
% plot(y_actual, y_pred_actual, 'o');
% xlabel('Actual Duration');
% ylabel('Predicted Duration');
% title('Neural Network Regression');
% grid on;

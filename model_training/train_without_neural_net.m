%% 1. Load and Normalize Data
data = readmatrix('Xy_combined_with_weights.csv');
X = data(:, 1:end-1);
y = data(:, end);

% Normalize X and y to [0,1]
[X_norm, ps] = mapminmax(X', 0, 1);
X_norm = X_norm';
[y_norm, ps_y] = mapminmax(y', 0, 1);
y_norm = y_norm';

% Split into train/test
cv = cvpartition(size(X_norm,1), 'HoldOut', 0.2);
Xtrain = X_norm(training(cv), :);
ytrain = y_norm(training(cv), :);
Xtest  = X_norm(test(cv), :);
ytest  = y_norm(test(cv), :);

% Evaluation function
r2_score = @(yt, yp) 1 - sum((yt - yp).^2) / sum((yt - mean(yt)).^2);

% 2. Train Models and Predict
models = {};
names = {};
metrics = [];

% 1. Linear Regression
mdl = fitlm(Xtrain, ytrain);
ypred = predict(mdl, Xtest);
models{end+1} = mdl;
names{end+1} = 'Linear';
metrics(end+1, :) = [mean((ytest - ypred).^2), r2_score(ytest, ypred), corr(ytest, ypred)];

% 2. Ridge Regression
B = ridge(ytrain, Xtrain, 1, 0); % λ = 1
Xtest_ridge = [ones(size(Xtest,1),1), Xtest];
ypred = Xtest_ridge * B;
models{end+1} = B;
names{end+1} = 'Ridge';
metrics(end+1, :) = [mean((ytest - ypred).^2), r2_score(ytest, ypred), corr(ytest, ypred)];

% 3. SVR
svm = fitrsvm(Xtrain, ytrain, 'KernelFunction', 'gaussian');
ypred = predict(svm, Xtest);
models{end+1} = svm;
names{end+1} = 'SVR';
metrics(end+1, :) = [mean((ytest - ypred).^2), r2_score(ytest, ypred), corr(ytest, ypred)];

% 4. Decision Tree
tree = fitrtree(Xtrain, ytrain);
ypred = predict(tree, Xtest);
models{end+1} = tree;
names{end+1} = 'Tree';
metrics(end+1, :) = [mean((ytest - ypred).^2), r2_score(ytest, ypred), corr(ytest, ypred)];

% 5. Ensemble (Bagging)
ens = fitrensemble(Xtrain, ytrain, 'Method', 'Bag');
ypred = predict(ens, Xtest);
models{end+1} = ens;
names{end+1} = 'Ensemble';
metrics(end+1, :) = [mean((ytest - ypred).^2), r2_score(ytest, ypred), corr(ytest, ypred)];

% 6. Gaussian Process
gpr = fitrgp(Xtrain, ytrain, 'KernelFunction', 'squaredexponential');
ypred = predict(gpr, Xtest);
models{end+1} = gpr;
names{end+1} = 'GPR';
metrics(end+1, :) = [mean((ytest - ypred).^2), r2_score(ytest, ypred), corr(ytest, ypred)];

% 3. Display Results
fprintf('\n--- Regression Model Comparison ---\n');
fprintf('%-10s | %-10s | %-10s | %-10s\n', 'Model', 'MSE', 'R²', 'R');
fprintf('-----------------------------------------------\n');
for i = 1:length(names)
    fprintf('%-10s | %-10.6f | %-10.4f | %-10.4f\n', ...
        names{i}, metrics(i,1), metrics(i,2), metrics(i,3));
end

% 4. Optional: Plot Best Model Prediction
[~, best_idx] = min(metrics(:,1));
best_model = models{best_idx};
ypred_best = predict(best_model, Xtest);

figure;
plot(ytest, ypred_best, 'bo');
hold on; refline(1, 0);
xlabel('True Target');
ylabel('Predicted Output');
title(['Best Model: ', names{best_idx}, ' - True vs Predicted']);
grid on;

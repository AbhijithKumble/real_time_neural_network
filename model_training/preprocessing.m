% Configuration
N = 20500;                % Resampled signal length
output_size = 1;          % One label: duration
base_path = "C:\Users\Abhijith_Kumble\Desktop\project_files\resampled_data\with_weight_param";

% CSV Files to process
files = {
    fullfile(base_path, 'speed_17.csv');
    fullfile(base_path, 'speed_30.csv');
    fullfile(base_path, 'speed_36.csv');
    fullfile(base_path, 'speed_17_w.csv');
    fullfile(base_path, 'speed_17_w_2.csv');
};

% ----------------------
% Step 1: Count total segments
total_segments = 0;
for k = 1:length(files)
    data = readmatrix(files{k});
    total_segments = total_segments + size(data, 1);
end

% ----------------------
% Step 2: Preallocate final matrix
all_data = zeros(total_segments, N + 2);  % Only one label (duration), skipping weight

% ----------------------
% Step 3: Combine all data
row_idx = 1;
for k = 1:length(files)
    data = readmatrix(files{k});  % Each row = [yq_1,...,yq_N, weight, duration]
    
    % Extract yq and duration only
    yq = data(:, 1:N+1);
    duration = data(:, end);  % Assuming last column is duration
    weight_label = data(:, N+1);
    num_rows = size(data, 1);
    all_data(row_idx:row_idx+num_rows-1, :) = [yq, duration];
    row_idx = row_idx + num_rows;
end

% ----------------------
% Step 4: Remove specific rows (e.g., 14 and 17)
rows_to_drop = [14, 17];
all_data(rows_to_drop, :) = [];

% ----------------------
% Step 5: Separate features and target
X = all_data(:, 1:N+1);
y = all_data(:, end);

% ----------------------
% Step 6: Save combined data to CSV
data_combined = [X, y];
writematrix(data_combined, fullfile('./Xy_combined_with_weights.csv'));






















%% =======================================
% % Configuration
% N = 20500;                % Resampled signal length
% output_size = 1;          % Just one target: time duration
% base_path = "C:\Users\Abhijith_Kumble\Desktop\project_files\resampled_data\with_weight_param";
% 
% % Files to process
% files = {
%     fullfile(base_path, 'speed_17.mat');
%     fullfile(base_path, 'speed_30.mat');
%     fullfile(base_path, 'speed_36.mat');
%     fullfile(base_path, 'speed_17_w.mat');
%     fullfile(base_path, 'speed_17_w_2.mat');
% 
% };
% 
% % ----------------------
% % Step 1: Count valid segments
% total_segments = 0;
% 
% for k = 1:size(files,1)
%     data = load(files{k});
%     segments = data.segments;
%     valid = sum(cellfun(@(s) ~isempty(s) && size(s,2) >= 2, segments));  % at least [time, signal]
%     total_segments = total_segments + valid;
% end
% 
% % ----------------------
% % Step 2: Preallocate matrix [resampled signal (N) + weight + label (1)]
% all_data = zeros(total_segments, N + 2);
% 
% % ----------------------
% % Step 3: Process segments
% row_idx = 1;
% 
% for k = 1:size(files,1)
%     data = load(files{k});
%     segments = data.segments;
% 
%     for i = 1:length(segments)
%         seg = segments{i};
% 
%         % Skip invalid segments
%         if isempty(seg) || size(seg,2) < 2
%             continue;
%         end
%         seg(:,2)
%         t = seg(:,1);             % time vector
%         x = seg(:,2:end);         % signal(s)
% 
%         % Compute regression label: duration
%         label = t(end) - t(1);    % duration in same units as time vector
% 
%         % Collapse multiple signal channels to 1D
%         if size(x,2) > 1
%             x = mean(x, 2);
%         end
% 
%         % Interpolate signal to fixed length N
%         tq = linspace(t(1), t(end), N);
%         yq = interp1(t, x, tq, 'linear');
% 
%         % Combine: [resampled signal, duration label]
%         all_data(row_idx, :) = [yq, label];
%         row_idx = row_idx + 1;
%     end
% end
% 
% % ----------------------
% % Step 4: Save
% % save('regression_dataset_duration_label.mat', 'all_data');
% % writematrix(all_data, 'regression_dataset_duration_label.csv');
% 
% % Optional: separate X and y
% X = all_data(:, 1:N);
% y = all_data(:, end);
% 
% % Specify row indexes to drop (index 14 and 17)
% rows_to_drop = [14, 17];
% 
% % Drop from all_data first
% all_data(rows_to_drop, :) = [];
% 
% % Recompute X and y after dropping
% X = all_data(:, 1:N);
% y = all_data(:, end);
% % Concatenate features and label
% data_combined = [X, y];
% 
% % Save to CSV
% % writematrix(data_combined, 'Xy_combined_with_weigth_param.csv');

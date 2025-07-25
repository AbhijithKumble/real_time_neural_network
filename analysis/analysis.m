% file_speed_36="C:\Users\Abhijith_Kumble\Desktop\project_files\data_recorded\motor_speed_36.csv";
% file_speed_30="C:\Users\Abhijith_Kumble\Desktop\project_files\data_recorded\motor_speed_30.csv";
% file_speed_17_w_2="C:\Users\Abhijith_Kumble\Desktop\project_files\data_recorded\motor_speed_17_weight_x_2.csv";
% file_speed_17_w="C:\Users\Abhijith_Kumble\Desktop\project_files\data_recorded\motor_speed_17_weight.csv";
file_speed_17="C:\Users\Abhijith_Kumble\Desktop\project_files\data_recorded\motor_speed_17.csv";
file_path=file_speed_17;
data = readtable(file_path);
disp(data(1:10, :));

% --- Read data ---
mx = data.mx;
my = data.my;
gz_rad = data.gz;
time_ms = data.Time_ms;

% --- Convert gyroscope to degrees/sec ---
gz = gz_rad * (180 / pi);

% --- Initialize ---
n = length(time_ms);
yaw = zeros(n, 1);
alpha = 0.95;

% --- Compute magnetometer-based yaw in [0°, 360°) ---
yaw_mag_all = mod(atan2d(my, mx), 360);

% --- Initialize yaw with corrected magnetometer angle ---
yaw(1) = yaw_mag_all(1);

% --- Complementary filter loop ---
for i = 2:n
    dt = (time_ms(i) - time_ms(i-1)) / 1000;  % ms → sec

    % Gyroscope integration
    yaw_gyro = yaw(i-1) + gz(i) * dt;

    % Complementary filter
    yaw(i) = alpha * yaw_gyro + (1 - alpha) * yaw_mag_all(i);
end

% --- Optional correction (disable or adjust as needed) ---
yaw = (yaw - 125.0)*1.13;

% --- Adjust theoretical angle if needed ---
data.theo_angle = -1.00 * data.theo_angle + 40;

% --- Plot results ---
plot(time_ms / 1000, yaw, 'b');
hold on;
plot(time_ms / 1000, data.theo_angle, 'r');
xlabel('Time (s)');
ylabel('Yaw (degrees)');
title('Yaw Estimation using Complementary Filter');
legend('Estimated Yaw', 'Theoretical Yaw');
grid on;
hold off;


data.yaw = yaw;
yaw
% writetable(data,  "C:\Users\Abhijith_Kumble\Desktop\project_files\data_modified\motor_speed_36.csv");
#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_HMC5883_U.h>
#include <Stepper.h>

// --- MPU6050 Setup ---
Adafruit_MPU6050 mpu;

// --- Magnetometer Setup ---
Adafruit_HMC5883_Unified mag = Adafruit_HMC5883_Unified(12345);

// --- Stepper Setup ---
const int steps_per_revolution = 456;
const float angle_per_step = 360.0 / 2046;
const float start_angle = 40.0;
Stepper my_stepper(steps_per_revolution, 8, 10, 9, 11);

unsigned long startTime;
int stepCount = 0;
int steps = 1;

int rpm = 17;
int delay_between_steps;

float prevYaw = 138;
float alpha = 0.985;
unsigned long prevTime = 0;

void setup() {
  Serial.begin(115200);
  while (!Serial);

  Wire.begin();
  Wire.setClock(100000);

  Wire.beginTransmission(0x68);
  Wire.write(0x6B);
  Wire.write(0x00);
  Wire.endTransmission(true);

  if (!mpu.begin(0x68)) {
    Serial.println("MPU6050 init failed");
  } else {
    Serial.println("MPU6050 initialized");
  }

  mpu.setAccelerometerRange(MPU6050_RANGE_2_G);
  mpu.setGyroRange(MPU6050_RANGE_250_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);

  if (!mag.begin()) {
    Serial.println("HMC5883L magnetometer init failed. Check wiring.");
  } else {
    Serial.println("HMC5883L magnetometer initialized.");
  }

  delay(1000);
  delay_between_steps = 60000 / (rpm * steps_per_revolution);

  // Print header
  Serial.println("Time(ms),Step,Angle,ax,ay,az,gx,gy,gz,Pitch,Roll,magX,magY,magZ,Yaw");

  startTime = millis();
  prevTime = startTime;
}

void loop() {
  // --- Stepper control ---
  if (stepCount >= 456) steps = -1;
  if (stepCount <= 0)   steps = 1;
  my_stepper.step(steps);
  stepCount += steps;

  float currentAngle = start_angle - stepCount * angle_per_step;

  // --- Read sensor data ---
  sensors_event_t a, g, t;
  mpu.getEvent(&a, &g, &t);

  float ax = a.acceleration.x;
  float ay = a.acceleration.y;
  float az = a.acceleration.z;
  float gx = g.gyro.x;
  float gy = g.gyro.y;
  float gz = g.gyro.z;

  sensors_event_t mag_event;
  float mx = 0, my = 0, mz = 0;
  if (mag.getEvent(&mag_event)) {
    mx = mag_event.magnetic.x;
    my = mag_event.magnetic.y;
    mz = mag_event.magnetic.z;
  }

  // --- Time and delta time ---
  unsigned long now = millis();
  float dt = (now - prevTime) / 1000.0;
  prevTime = now;

  // --- Complementary filter for Yaw ---
  float yaw_mag = atan2(my, mx) * (180.0 / PI);

  float gz_deg = gz * (180.0 / PI);
  if (yaw_mag < 0) yaw_mag += 360;
  float yaw_gyro = prevYaw + gz_deg * dt;
  float yaw = alpha * yaw_gyro + (1 - alpha) * yaw_mag;
  prevYaw = yaw;
  yaw-=125.0;
  // --- Print all data including yaw ---
  Serial.print(now - startTime); Serial.print(",");
  Serial.print(stepCount); Serial.print(",");
  Serial.print(currentAngle, 6); Serial.print(",");
  Serial.print(ax, 6); Serial.print(",");
  Serial.print(ay, 6); Serial.print(",");
  Serial.print(az, 6); Serial.print(",");
  Serial.print(gx, 6); Serial.print(",");
  Serial.print(gy, 6); Serial.print(",");
  Serial.print(gz, 6); Serial.print(",");
  Serial.print(mx, 6); Serial.print(",");
  Serial.print(my, 6); Serial.print(",");
  Serial.print(mz, 6); Serial.print(",");
  Serial.println(yaw, 6);

  delay(delay_between_steps);
}

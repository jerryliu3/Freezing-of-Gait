//Library Imports
#include <Wire.h>
#include <math.h>

//IMU variables
const int MPU_addr=0x68;  // I2C address of the MPU-6050
int motorPin = 11;

//Variables needed for signal reading and analysis
long tempAcX,tempAcY,tempAcZ,Tmp,tempGyX,tempGyY,tempGyZ;
long GyZ [3];
int numFoGPeaks = 0;
boolean newSection = true;
int zeroCounter = 0;

//Arduino setup
void setup() {
  Serial.begin(9600);
  pinMode(motorPin, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);
  analogWrite(motorPin, 0);
  Wire.begin(1);

  Wire.beginTransmission(MPU_addr);
  Wire.write(0x6B);  // PWR_MGMT_1 register
  Wire.write(0);     // set to zero (wakes up the MPU-6050)
  Wire.endTransmission(true);
  
  //Read first three points
  updateGy(0);
  updateGy(1);
  updateGy(2);
}

//Continuous loop
void loop() {
  
  //Translate values over
  GyZ[0] = GyZ[1];
  GyZ[1] = GyZ[2];
  updateGy(2);

  //Reset values if user stopped
  if(zeroCounter >= 35)
  {
    numFoGPeaks = 0;
    zeroCounter = 0;
  }
  //Check for new island
  if(GyZ[0] ==0 && GyZ[1] == 0 && GyZ[2] ==0)
  {
    newSection = true;
  }
  //Increment stopping counter
  if(GyZ[2] == 0)
  {
    zeroCounter++;
  }
  else
  {
    zeroCounter = 0;
  }
  //Check for normal walking
  if(GyZ[1] > 27500)
  {
    numFoGPeaks = 0;
  }
  else if(newSection && isMaxZ(GyZ) && isFoGZZero(GyZ[1]))
  {
    newSection = false;
    numFoGPeaks++;
    //Check for freezing
    if(numFoGPeaks > 1)
    {
      //Turn motor on and LED
      analogWrite(motorPin, 150);
      digitalWrite(LED_BUILTIN, HIGH);
      int motorCounter = 0;
      //Check if motor should be turned off
      while(GyZ[1] < 27500 && motorCounter < 1000)
      {
        GyZ[0] = GyZ[1];
        GyZ[1] = GyZ[2];
        updateGy(2);
        motorCounter++;
      }
      analogWrite(motorPin, 0);
      digitalWrite(LED_BUILTIN, LOW);
      numFoGPeaks = 0;
      zeroCounter = 0;
    }
  }
  delay(10);
}

//Read new value and update array
void updateGy(int pos)
{
  Wire.beginTransmission(MPU_addr);
  Wire.write(0x3B);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_addr,14,true);  // request a total of 14 registers
  tempAcX=Wire.read()<<8|Wire.read();  // 0x3B (ACCEL_XOUT_H) & 0x3C (ACCEL_XOUT_L)    
  tempAcY=Wire.read()<<8|Wire.read();  // 0x3D (ACCEL_YOUT_H) & 0x3E (ACCEL_YOUT_L)
  tempAcZ=Wire.read()<<8|Wire.read();  // 0x3F (ACCEL_ZOUT_H) & 0x40 (ACCEL_ZOUT_L)
  Tmp=Wire.read()<<8|Wire.read();  // 0x41 (TEMP_OUT_H) & 0x42 (TEMP_OUT_L)
  tempGyX=Wire.read()<<8|Wire.read();  // 0x43 (GYRO_XOUT_H) & 0x44 (GYRO_XOUT_L)
  tempGyY=Wire.read()<<8|Wire.read();  // 0x45 (GYRO_YOUT_H) & 0x46 (GYRO_YOUT_L)
  tempGyZ=Wire.read()<<8|Wire.read();  // 0x47 (GYRO_ZOUT_H) & 0x48 (GYRO_ZOUT_L)
  Serial.print(String(tempGyZ) + ", ");
  if(tempGyZ <= 150)
  {
    tempGyZ = 0;
  }
  GyZ[pos] = tempGyZ;
}

//Method to check that there is a peak
boolean isMaxZ(long values[])
{
  return (values[1] - values[0] > 500 && values[1] - values[2] > 500);
}

//Method to check that peak is in threshold region
boolean isFoGZZero(long z)
{
  return (z > 2000 && z < 20000);
}

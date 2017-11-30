#include <Wire.h>
#include <math.h>

const int MPU_addr=0x68;  // I2C address of the MPU-6050
int motorPin = 11;

long tempAcX,tempAcY,tempAcZ,Tmp,tempGyX,tempGyY,tempGyZ;
long GyX [3];
long GyY [3];
long GyZ [3];

boolean normalStep = false;
int FoGCounter = 0;
int numPeaks = 0;

void setup() {
  Serial.begin(9600);
  pinMode(motorPin, OUTPUT);
  analogWrite(motorPin, 0);
  Wire.begin(1);

  Wire.beginTransmission(MPU_addr);
  Wire.write(0x6B);  // PWR_MGMT_1 register
  Wire.write(0);     // set to zero (wakes up the MPU-6050)
  Wire.endTransmission(true);

  updateGy(0);
  updateGy(1);
  updateGy(2);

  if(GyY[0] < 0)
  {
    GyY[0] = 0;
  }
  if(GyY[1] < 0)
  {
    GyY[1] = 0;
  }
  if(GyY[2] < 0)
  {
    GyY[2] = 0;
  }

  if(GyZ[0] < 0)
  {
    GyZ[0] = 0;
  }
  if(GyZ[1] < 0)
  {
    GyZ[1] = 0;
  }
  if(GyZ[2] < 0)
  {
    GyZ[2] = 0;
  }
}

void loop() {
  if(FoGCounter != 0)
  {
    FoGCounter ++;
  }
  GyX[0] = GyX[1];
  GyY[0] = GyY[1];
  GyZ[0] = GyZ[1];
  GyX[1] = GyX[2];
  GyY[1] = GyY[2];
  GyZ[1] = GyZ[2];
  updateGy(2);

  if(GyZ[2] < 0)
  {
    GyZ[2] = 0;
  }
  if(isMaxZ(GyZ) && GyZ[1] > 20000)
  {
    numPeaks = 0;
    FoGCounter = 0;
  }
  else if(isMaxZ(GyZ) && isFoGZZero(GyZ[1]))
  {
    numPeaks++;
    if(FoGCounter == 0)
    {
      FoGCounter++;
    }
    else if(FoGCounter >= 101)
    {
      numPeaks = 0;
      FoGCounter = 0;
    }
    if(numPeaks > 2)
    {
      Serial.println("Freezing");
      analogWrite(motorPin, 123);
      while(GyZ[1] < 20000)
      {
        updateGy(2);
      }
      analogWrite(motorPin, 0);
      numPeaks = 0;
    }
  }
  delay(10);
}

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
  GyX[pos] = tempGyX;
  GyY[pos] = -tempGyY;
  GyZ[pos] = tempGyZ;
}

boolean isMaxZ(long values[])
{
  return (values[1] - values[0] > 500 && values[1] - values[2] > 500);
}

boolean isFoGZZero(long z)
{
  return (z > 2000 && z < 20000);
}

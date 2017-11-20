#include <Wire.h>
#include <math.h>

const int MPU_addr=0x68;  // I2C address of the MPU-6050
long tempAcX,tempAcY,tempAcZ,Tmp,tempGyX,tempGyY,tempGyZ;
//int AcX [1000];
//int AcY [1000];
//int AcZ [1000];
int GyX [3];
int GyY [3];
long GyZ [3];

boolean normalStep = false;
int counter = 0;
int numPeaks = 0;

void setup() {
  Serial.begin(9600);
  Wire.begin(1);

  Wire.beginTransmission(MPU_addr);
  Wire.write(0x6B);  // PWR_MGMT_1 register
  Wire.write(0);     // set to zero (wakes up the MPU-6050)
  Wire.endTransmission(true);

  updateGy(0);

  updateGy(1);

  updateGy(2);

}

void loop() {

  GyX[0] = GyX[1];
  GyY[0] = GyY[1];
  GyZ[0] = GyZ[1];
  GyX[1] = GyX[2];
  GyY[1] = GyY[2];
  GyZ[1] = GyZ[2];
  updateGy(2);

  long add[] = {abs(GyY[0]) + abs(GyZ[0]), abs(GyY[1]) + abs(GyZ[1]), abs(GyY[2]) + abs(GyZ[2]) };
  long mult[] = {abs(GyY[0]) * abs(GyZ[0]), abs(GyY[1]) * abs(GyZ[1]), abs(GyY[2]) * abs(GyZ[2]) };
  long square[] = {abs(GyZ[0]) * abs(GyZ[0]), abs(GyZ[1]) * abs(GyZ[1]), abs(GyZ[2]) * abs(GyZ[2]) };
  
  if( isMax(square) && square[1] > 400000000 && !normalStep)
  {
    normalStep = true;
    numPeaks = 0;
  }
  if(normalStep)
  {
    counter++;
  }

  //Serial.println(square[1]);
  if(counter == 15)
  {
    normalStep = false;
    counter = 0;
  }
  if(counter==0 && isMax(square)) // throw out ten points after normal step
  {
    // add threshold
    
    // mult threshold

    // square threshold
    if (isFogSq(square[1]))
    {
      numPeaks++;
      if(numPeaks > 5)
      {
        Serial.println("Freezing");
        numPeaks = 0;
      }
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
  GyY[pos] = tempGyY;
  GyZ[pos] = tempGyZ;
}

boolean isMax(long square[])
{
  return (square[1] - square[0] > 2000000 && square[1] - square[2] > 2000000);
}

boolean isFogAdd(int add[])
{
  
}

boolean isFogMult(int mult[])
{
  
}

boolean isFogSq(long square)
{
  return (square > 10000000 && square < 150000000);
}



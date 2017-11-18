#include <Wire.h>
#include <math.h>

const int MPU_addr=0x68;  // I2C address of the MPU-6050
int tempAcX,tempAcY,tempAcZ,Tmp,tempGyX,tempGyY,tempGyZ;

int [] AcX = new int[1000];
int [] AcY = new int[1000];
int [] AcZ = new int[1000];
int [] GyX = new int[1000];
int [] GyY = new int[1000];
int [] GyZ = new int[1000];

int countdown = 10;
boolean startCountdown = false;
int last_classification = 0; //don't think I need this, test taking out
int pos = 0;

void setup() {
  Serial.begin(9600);
  Wire.begin(1);

  Wire.beginTransmission(MPU_addr);
  Wire.write(0x6B);  // PWR_MGMT_1 register
  Wire.write(0);     // set to zero (wakes up the MPU-6050)
  Wire.endTransmission(true);

//matlab code
while(countdown > 0)
{
    if(startCountdown)
    {
        countdown = countdown - 1;
    }
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
    AcX[pos] = tempAcX;
    AcY[pos] = tempAcY;
    AcZ[pos] = tempAcZ;
    GyX[pos] = tempGyX;
    GyY[pos] = tempGyY;
    GyZ[pos] = tempGyZ;
    pos++;
    if(tempGyZ > 20000)
    {
        start_countdown = true;
        last_classification = length(GyZ);
    }
 
}

%1 = positive, -1 = negative
int derivative = 0;
int counter = 0;
int GyZMax = 0;
int GyZMin = 0;
boolean minFound = false;
int numPeaks = 0;
int averageValue = 0;


void loop() {
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
  
  AcX[pos] = tempAcX;
  AcY[pos] = tempAcY;
  AcZ[pos] = tempAcZ;
  GyX[pos] = tempGyX;
  GyY[pos] = tempGyY;
  GyZ[pos] = tempGyZ;
  pos++;

  
  if (pos == GyZ.length()) 
  {
    int [] newAcX = new int[AcX.length() * 2];
    int [] newAcY = new int[AcY.length() * 2];
    int [] newAcZ = new int[AcZ.length() * 2];
    int [] newGyX = new int[GyX.length() * 2];
    int [] newGyY = new int[GyY.length() * 2];
    int [] newGyZ = new int[GyZ.length() * 2];
  
    for(int x=0;x<AcX.length();x++)
    {
      newAcX [x] = AcX [x];
      newAcY [x] = AcY [x]; 
      newAcZ [x] = AcZ [x];
      newGyX [x] = GyX [x];
      newGyY [x] = GyY [x];
      newGyZ [x] = GyZ [x];
    }
    delete [] AcX;
    delete [] AcY;
    delete [] AcZ;
    delete [] GyX;
    delete [] GyY;
    delete [] GyZ;

    AcX = newAcX;
    AcY = newAcY;
    AcZ = newAcZ;
    GyX = newGyX;
    GyY = newGyY;
    GyZ = newGyZ;

    delete [] newAcX;
    delete [] newAcY;
    delete [] newAcZ;
    delete [] newGyX;
    delete [] newGyY;
    delete [] newGyZ;
  }  

    //begining of matlab copy
    //if they are not taking a normal step
    if(tempGyZ < 20000)
    {
        if(minFound)
        {
            averageValue = (averageValue * counter + tempGyZ)/(counter + 1);
        }
        //calculate if new max or min
        if(tempGyZ > GyZMax && minFound)
        {
            GyZMax = tempGyZ;
        }
        else if(tempGyZ < GyZMin)
        {
            GyZMin = tempGyZ;
            minFound = true;
        }
        
        //ignore when values are constant because saddle points are useless
        //so derivative of 0 has no impact
        if(GyZ(pos)-GyZ(pos-1) > 500)
        {
            if(derivative == -1)
            {
                %numPeaks = numPeaks+1;
            }
            derivative = 1;
        }
        else if(GyZ(pos_in_signal)-GyZ(pos_in_signal-1) < -500)
        {
            if(derivative == 1)
            {
                numPeaks = numPeaks+1;
                averageValue = (averageValue * counter + tempGyZ)/(counter + 1);
            }
            derivative = -1;
        }
        if(numPeaks >= 3)
        {
            if(averageValue < 2000 && averageValue > -1000 && GyZMax - GyZMin > 2000 && GyZMax < 14000 && GyZMin > -14000)
            {
                Serial.println("Freezing");
                //administer cue
            }
            elseif(GyZMax - GyZMin < 1500 && GyZMax < 5000 && GyZMin > -5000 || averageValue < 0 || GyZMax - GyZMin > 20000)
            {
                Serial.println("Stopping or walking");
            }
            counter = 0;
            GyZMax = 0;
            GyZMin = 0;
            minFound = false;
            numPeaks = 0;
            averageValue = 0;
        }
        else if(counter >= 40)
        {
            Serial.println("Either normal walking or stopping");
        }
    else
    {
        Serial.println("Normal step");
        //reset everything since normal step
        counter = 0;
        GyZMax = 0;
        GyZMin = 0;
        minFound = false;
        numPeaks = 0;
        averageValue = 0;
    }
    counter++;
//end of matlab copy

  
  delay(10);
}

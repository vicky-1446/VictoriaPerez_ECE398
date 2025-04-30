//This code was done in collaboration with SSR Undergraduate Researher Brian Mmari. Most information was taken from his previous experimental trials for straight-line swimming 


#include <WiFi.h>
#include <ESPmDNS.h>
#include <WiFiUdp.h>
#include <ArduinoOTA.h>
#include "driver/adc.h"
#include <esp_bt.h>
#include <esp_now.h>
#include <ctype.h>
#include "esp_wifi.h"

int state = 1; // DEFAULT STATE
int t_wait = 20; // specify frequency
int maneuverPhase = 0; // Current phase of the maneuver
int startFishPhase = 0; // Current phase of the operation within startFish
// int timeFlapping = 240000; // time for flapping
uint8_t broadcastAddress[] = {0x34, 0x85, 0x18, 0x7B, 0xD4, 0x00}; // THE MAC Address for central device

// Variable to store if sending data was successful
String success;

#define enA 23
#define in3 2
#define in4 3


int PWM = round(0.99*255); // from 0 to 255

typedef struct struct_message {
  char leftChar;
  char rightChar;
  char sent;
  int frequency;

} struct_message;

// Initialize data
struct_message test;

// Store peer information
esp_now_peer_info_t peerInfo;

// callback function when message is sent
void OnDataSent(const uint8_t *mac_addr, esp_now_send_status_t status) {
  if (status ==0){
    success = "Delivery Success :)";
  }
  else{
    success = "Delivery Fail :(";
  }
}

// callback function that will be executed when data is received
void OnDataRecv(const uint8_t *mac_addr, const uint8_t *incomingData, int len){
  // Clear the test variable before copying new data
  memset(&test, 0, sizeof(test));
  memcpy(&test, incomingData, sizeof(test));

  Serial.println("Received Data: ");
  Serial.println(test.sent);
  
  // State transitions based on received data
  if (test.sent == '0') {
    state = 0;
    Serial.println("State is 0, stop received.");
  } else if (test.sent == '3') {
    state = 3;
    Serial.println("State is 3, deep sleep mode.");
  } else if (isdigit(test.leftChar) && isdigit(test.rightChar)) {
    state = 2;
    Serial.println("State is 2, valid leftChar and rightChar received.");
  } else if (test.sent == '1') {
    state = 1;
    Serial.println("State is 1, single character input.");
  }
}

void setup() {
  Serial.begin(9600);
  WiFi.mode(WIFI_STA);
  
  esp_sleep_enable_ext0_wakeup(GPIO_NUM_1,0);

  // Set the states of pins
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(LED_RED, OUTPUT);
  pinMode(A0, OUTPUT);
  pinMode(enA, OUTPUT);
  pinMode(in3, OUTPUT);
  pinMode(in4, OUTPUT);

  // Set the pins
  digitalWrite(LED_BUILTIN, HIGH);  
  digitalWrite(A0, LOW);

   // Init ESP-NOW
  if (esp_now_init() != ESP_OK) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }

    // Register peer
  memcpy(peerInfo.peer_addr, broadcastAddress, 6);
  peerInfo.channel = 0;  
  peerInfo.encrypt = false;

    
    // Add peer        
  if (esp_now_add_peer(&peerInfo) != ESP_OK){
    Serial.println("Failed to add peer");
  return;
  }

  // Check status of received message
  esp_now_register_recv_cb(OnDataRecv);

}

void startFish(int state) {
    unsigned long startTime = millis();  // Store the start time
    unsigned long flapDuration = 1200000; // 20 minutes (1,200,000)
    
    // Continue flapping for 4 minutes
    while (millis() - startTime < flapDuration) {
        // Move forward
        digitalWrite(A0, LOW);
        digitalWrite(enA, HIGH);
        analogWrite(in3, PWM);
        analogWrite(in4, 0);
        digitalWrite(LED_RED, LOW);
        
        delay(t_wait);  // Flap forward for `t_wait` milliseconds

        // Move backward
        analogWrite(in3, 0);
        analogWrite(in4, PWM); 
        digitalWrite(LED_RED, HIGH);

        delay(t_wait);  // Flap backward for `t_wait` milliseconds
    }

    // Stop after 20 minutes
    stopFish();
}
void stopFish(){
    digitalWrite(A0, HIGH);
    digitalWrite(enA, LOW);
    analogWrite(in3, 0);
    analogWrite(in4, 0);
    digitalWrite(LED_GREEN, LOW); // turn off  
}

void maneuverFish(){
  int leftDelay = (test.leftChar - '0') * test.frequency; // Convert char digit to delay time
  int rightDelay = (test.rightChar - '0') * test.frequency; // Convert char digit to delay time

  if(maneuverPhase == 0){

   digitalWrite(A0, LOW);
   digitalWrite(enA, HIGH);

   // Forward direction
   analogWrite(in3,PWM);
   analogWrite(in4,0);
   digitalWrite(LED_RED, LOW);
   maneuverPhase = 1;

    // Delay for the left character delay time
    delay(leftDelay);

    // After the delay, switch to the reverse direction
    analogWrite(in3, 0);
    analogWrite(in4, PWM);
    digitalWrite(LED_RED, HIGH);
    maneuverPhase = 2;
    
    // Delay for the right character delay time
    delay(rightDelay);

    // Complete the cycle and reset the phase
    maneuverPhase = 0;
    stopFish();
  }
 
}

void loop(){
  if (state == 0){
    stopFish();
  } else if(state == 1 || state == 2){
    startFish(state);
  }
    else if(state == 3){
      esp_deep_sleep_start();
    }
}
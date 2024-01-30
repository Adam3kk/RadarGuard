#include <Servo.h>
//Deklaracja pinów trigger(wyzywalający), echo(odbierający) oraz deklracja pinu dla leda
const int trigPin = 10;
const int echoPin = 11;
const int ledPin = 9;  

//Zmienne dla czasu trwania i odległości
long duration;
int distance;

//Próg odległości
int distanceThreshold = 200;

//Deklracja obiektu Servo
Servo myServo;

//Zmienna do detekcji śledzenia ruchu
bool motionDetected = false;

void setup() {
  //Deklaracja pinow na wartosci wyjsciowe oraz wejsciowe
  pinMode(trigPin, OUTPUT); 
  pinMode(echoPin, INPUT);   
  pinMode(ledPin, OUTPUT);  
  Serial.begin(9600); //Inicjalizacja komunikacje szeregowa z predkoscia 9600 bitow
  myServo.attach(12);  //Inicjalizacja serwa na pinie 12
}

void loop() {
  //Obrocenie serwomechanizmu od 15 do 165 stopni
  for (int i = 15; i <= 165; i++) {
    myServo.write(i);
    delay(30);
    distance = calculateDistance();  //Wywołanie funkcji, ktora liczy odleglosc mierzonej przez czujnik dla kazdego stopnia

    //Zapalenie diody jesli wykryje ruch 
    if (distance < distanceThreshold) {
      motionDetected = true;
      digitalWrite(ledPin, HIGH);  //Zapala diode LED
    } else {
      if (motionDetected) {
        motionDetected = false;
        digitalWrite(ledPin, LOW);   //Zgasza diode LED
      }
    }
      Serial.print(i);
      Serial.print(",");
      Serial.print(distance);
      Serial.println();
  }

  //Serwomechanizm wykonuej ruch od 165 do 15 stopni
  for (int i = 165; i > 15; i--) {
    myServo.write(i);
    delay(30);
    distance = calculateDistance();
   
    if (distance < distanceThreshold) {
      motionDetected = true;
      digitalWrite(ledPin, HIGH);    //Zapala diode LED
    } else {
      if (motionDetected) {
        motionDetected = false;
        digitalWrite(ledPin, LOW);   //Zgasza diode LED
      }
    }
      Serial.print(i);
      Serial.print(",");
      Serial.print(distance);
      Serial.println(); 
  }
}

//Funkcja do obliczenia odległości mierzonej przez czujnik
int calculateDistance() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);

  // Ustawia pin trigPin w stanie HIGH przez 10 mikrosekund
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  duration = pulseIn(echoPin, HIGH);  //Odczytuje pin echoPin, zwraca czas podróży fali dźwiękowej w mikrosekundach
  distance = duration * 0.034 / 2;
  return distance;
}

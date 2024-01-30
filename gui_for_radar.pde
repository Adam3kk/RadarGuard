import processing.serial.*;

Serial myPort;

int lastAngle = 0; // Kąt ostatniej otrzymanej informacji
int lastDistance = 0; // Dystans ostatniej otrzymanej informacji
float scale = 2.0; // Powiększanie wykres radaru
int fontSize = 18; //zmiana rozmiaru czcionki
int maxValidDistance = 200; //maksymalna odległość


//Funkcja Inicjalizuje ustawienia projektu, takie jak rozmiar okna,
//czcionkę oraz komunikację szeregową z określonym portem przy prędkości 9600,
void setup() {
  size(900, 700);
  myPort = new Serial(this, "COM4", 9600);
  myPort.bufferUntil('\n');
   textFont(createFont("Arial", fontSize));
}

//Funkcja draw jest wywoływana ciągle, aby odświeżać ekran, a nastepnię wywołuję inna funkcje drawRadar()
void draw() {
  background(0);
  translate(width / 2, height); //Przesunięcie punktu odniesienia do środka ekranu
  drawRadar();
}

//Funkcja rysuje półkole,oznacza kąty co 30 stopni. Oznacza wykryte cele na kolor czerwony oraz przypisuje
// nad nimi dystans. Rysuje również zielona linie pół okręgu która określa nam maksymalny dystans skanowania.
void drawRadar() {
  // Narysuj półkole
  noFill(); //ustawia brak wypełnienia dla kształtów rysowanych po tej instrukcji
  stroke(#00FF00); //Kolor zielony
  strokeWeight(2);// grubosc lini krawedzi
//rysowanie 180 podpunktów na okręgu, tworząc efekt półkola
  for (int i = 0; i <= 180; i++) {
    float x = cos(radians(i)) * 200 * scale; // Dostosowane dla 200 cm
    float y = sin(radians(i)) * 200 * scale; // Dostosowane dla 200 cm
    point(x, -y);
  }

  // Oznacz kąty co 30 stopni
  fill(255);// ustawienie koloru na biały
  noStroke();//wyłącza rysowanie krawędzi dla kolejnych kształtów.
  textAlign(CENTER, CENTER);

//Pętla służy do rysowania tekstu kątów na wykresie.
  for (int i = 0; i <= 180; i += 30) {
    float labelRadius = 190 * scale; // Dostosowane dla 200 cm
    if (i == 0 || i == 180) {
      labelRadius += 20; //przesuniecie etykiety na zewnątrz
    }
    float x = cos(radians(i)) * labelRadius;
    float y = sin(radians(i)) * labelRadius;
    text(str(i), x, -y);
  }

  //Wyświetli ostatni kąt i odległość, jeśli są w zakresie poprawności
  if (lastDistance <= maxValidDistance) {
    fill(#FF0000); //kolor Czerwony
    ellipse(lastX() * scale, lastY() * scale, 10, 10);
    text(lastDistance, lastX() * scale, lastY() * scale - 15);
  }
}

// Funkcja wywoływuje się automatycznie za każdym razem, gdy dane są odbierane z portu szeregowego.
//Odczytuje dane, usuwa białe znaki i dzieli je na wartości kąta i odległości
//Aktualizuje lastAngle i lastDistance najnowszymi otrzymanymi wartościami
void serialEvent(Serial myPort) {
  String data = myPort.readStringUntil('\n');
  if (data != null) {
    data = data.trim();
    String[] values = split(data, ',');
    if (values.length == 2) {
      lastAngle = int(values[0]);
      lastDistance = int(values[1]);
    }
  }
}

//Oblicza współrzędną x ostatniego otrzymanego punktu
//danych na podstawie współrzędnych biegunowych (kąt i odległość).
float lastX() {
  return cos(radians(lastAngle)) * lastDistance;
}
//Oblicza współrzędną y ostatniego otrzymanego punktu 
//danych na podstawie współrzędnych biegunowych (kąt i odległość).
float lastY() {
  return -sin(radians(lastAngle)) * lastDistance;
}

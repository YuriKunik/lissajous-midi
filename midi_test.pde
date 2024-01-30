import themidibus.*; //Import the library
import javax.sound.midi.MidiMessage;

MidiBus myBus;

int nota_izq = 48;
int nota_der = 72;
int rango = nota_der - nota_izq;
int currentColor = 0;
int midiDevice  = 1;
float desp_angulo = 0;
float rota;
float longitud;
int[] notas;
float[] notas_freq;
float velocidad = 0.1;
float velocidad_angular = 0.1;
float do_medio = 261.625565;
float a = 0;
float b = 0;
float c = 0;
float tam = 100;
int n_puntos = 1000;

int puntos_totales = 4000;

float punto_inicial = 0; 



void setup() {
  size(1920, 1080);
  MidiBus.list();
  myBus = new MidiBus(this, midiDevice, 1);
  notas = new int[73-48];
  notas_freq = new float[73-48];
  for (int i = 0; i < notas_freq.length; ++i) {
    notas_freq[i] = do_medio * (float)Math.pow(2, float(i)/12);
  }
}

void draw() {
  background(20, 50);
  translate(width/2, height/2);
  noFill();

  stroke(225);
  // rotate(rota);
  beginShape();
  for (float i = punto_inicial; i < punto_inicial + n_puntos; ++i) {
    float t = map(i, 0, puntos_totales, 0, PI);
    float coord_x = tam * sin(desp_angulo + a*t);
    float coord_y = tam * sin(b*t);
    vertex(coord_x, coord_y);
  }
  endShape();
  desp_angulo += velocidad_angular;
  punto_inicial+= velocidad;
  punto_inicial = punto_inicial % (puntos_totales-n_puntos);
  desp_angulo = desp_angulo % (2*PI);
}

void midiMessage(MidiMessage message, long timestamp, String bus_name) {
  int note = (int)(message.getMessage()[1] & 0xFF);
  int vel = (int)(message.getMessage()[2] & 0xFF);

  println("Bus " + bus_name + ": Note "+ note + ", vel " + vel);

  if(note == 18) n_puntos = (int)map(vel, 0, 127, 20, puntos_totales - punto_inicial);
  if(note == 19) tam = map(vel, 0, 127, 0, 1000);
  if(note == 16) puntos_totales = (int)map(vel, 0, 127, 600, 6000);
  if(note == 17) velocidad = map(vel, 0, 127, 0, 2);
  if(note == 91) velocidad_angular = map(vel, 0, 127, 0, 1);
   
  if (note > nota_izq-1 && note < nota_der + 1) {
    if (vel > 0) {
      if (a == 0){
        a = notas_freq[note-nota_izq];
        notas[note-nota_izq] = 1;
        if (b == 0) b = a;
        print(a + "\n");
      }
      else if(b == 0){
        b = notas_freq[note-nota_izq];
        notas[note-nota_izq] = 2;
        print(b + "\n");
      }
      else if (a != 0) {
        b = notas_freq[note-nota_izq];
        for (int i = 0; i < notas.length; ++i) {
          if(notas[i] == 2) notas[i] = 0;  
        }
        notas[note-nota_izq] = 2;
      }
    } else {
      if(notas[note-nota_izq] == 1) a = 0;
      else if(notas[note-nota_izq] == 2) b = 0;
      else if(notas[note-nota_izq] == 3) c = 0;
      notas[note-nota_izq] = 0;
    }
  }
}
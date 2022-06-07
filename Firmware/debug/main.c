#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#include "notes/notes.h"

#define C0_FREQUENCY 16.3516015625 //hz (4186.01/(2^8))

double determineNote(double frequency, char *output_note_string, char *output_octave_string){
  double octaves_over_C0 = log2l(frequency/C0_FREQUENCY);
  double semitones_over_C0 = octaves_over_C0*12.0;
  int closest_whole_semitones_over_C0 = round(semitones_over_C0);
  char *closestnote = notes_in_an_octave[closest_whole_semitones_over_C0%12];
  char *octaveString = (char*)malloc(2 * sizeof(char));
  sprintf(octaveString,"%i", (int)(floor(round(semitones_over_C0)/12)));
  strcpy(output_note_string,closestnote);
  strcpy(output_octave_string,octaveString);
  return (semitones_over_C0-closest_whole_semitones_over_C0);
}


int main() {
    char *output_note_string = (char*)malloc(6 * sizeof(char));
    char *output_octave_string = (char*)malloc(6 * sizeof(char));
    double note_semitones_offset = determineNote(43.65,output_note_string,output_octave_string);
    printf("%s\n",output_note_string);
    printf("%s\n",output_octave_string);
    printf("%lf\n",note_semitones_offset);
    return 0;
}




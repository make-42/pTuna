/////////////////////////////////////////////////////////////////////////////////////////
// Filename:    main.c
// Filetype:    javascript
// Author:      Louis Dalibard
// Created On:  May 29th 2022 @ 11:18PM
// Description: pTuna : α 1.01
/////////////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#include "pico/stdlib.h"
#include "pico/pdm_microphone.h"
#include "hardware/i2c.h"

#include "libssd1306/ssd1306.h"

#include "bitmaps/splashScreen.h"
#include "bitmaps/mainUI.h"
#include "bitmaps/overclockFail.h"

#include "notes/notes.h"

#include "kiss/kiss_fftr.h"

#define SPLASHSCREEN_DURATION 1200 //ms
#define C0_FREQUENCY 16.3515978313 //hz C8(4186.01hz) / 4186.01/(2^8) (440/(2^(9/12+4)) would be more exact though)
#define CUTOFF_FREQUENCY 8.17580078125 //hz
#define SEMITONE_OFFSET_SENSITIVITY 1.24 // cents per pixel (64-2)/50
#define MIC_BUFFER_SIZE 4096 // samples
#define MIC_SAMPLERATE 8192 // no unit
#define MIC_GAIN 1.0 // multiplier
#define BOOT_ANIMATION_FRAMES 60
#define SHOW_BOOT_ANIMATION false

#define OSCILLOSCOPE_SAMPLES 50
#define OSCILLOSCOPE_GAIN 15

// configuration
const struct pdm_microphone_config config = {
  .gpio_data = 2,
  .gpio_clk = 3,
  .pio = pio0,
  .pio_sm = 0,
  .sample_rate = MIC_SAMPLERATE,
  .sample_buffer_size = MIC_BUFFER_SIZE,
};

// variables
int16_t sample_buffer[MIC_BUFFER_SIZE];
volatile int samples_read = 0;
float freqs[MIC_BUFFER_SIZE];

// functions
void setup_gpios(void);
void setup_microphone(void);
void splashscreen(ssd1306_t disp);
void overclockFail(ssd1306_t disp);
void showMainUI(ssd1306_t disp);
double U64ToDoubleConverter(uint64_t val);
double determineNote(double frequency, char * output_note_string, char * output_octave_string);
void drawGuitarStringIndicator(ssd1306_t* disp, int stringIndex);
void drawOscilloscope(ssd1306_t* disp, float max_freq);

int main() {
  // Overclock Pico
  bool overclockingSuccess = true;
  if (!set_sys_clock_khz(150000, true)) {
    set_sys_clock_khz(125000, true);
    overclockingSuccess = false;
  }
  // STDIO
  stdio_init_all();

  printf("configuring pins...\n");
  setup_gpios();
  printf("display init...\n");
  ssd1306_t disp;
  disp.external_vcc = false;
  ssd1306_init( & disp, 128, 64, 0x3C, i2c0);
  if (!overclockingSuccess) {
    printf("overclock failed...\n");
    overclockFail(disp);
    return 0;
  }
  splashscreen(disp);
  // initialize the PDM microphone
  printf("microphone init...\n");
  setup_microphone();
  // Start main UI.
  showMainUI(disp);
  return 0;
}

void on_pdm_samples_ready(void) {
  // callback from library when all the samples in the library
  // internal sample buffer are ready for reading
  samples_read = pdm_microphone_read(sample_buffer, MIC_BUFFER_SIZE);
}

void setup_microphone(void) {
  // set callback that is called when all the samples in the library
  // internal sample buffer are ready for reading
  if (pdm_microphone_init( & config) < 0) {
    printf("PDM microphone initialization failed!\n");
  }
  pdm_microphone_set_samples_ready_handler(on_pdm_samples_ready);
  // start capturing data from the PDM microphone
  if (pdm_microphone_start() < 0) {
    printf("PDM microphone start failed!\n");
  }
}

void setup_gpios(void) {
  i2c_init(i2c0, 400000);
  gpio_set_function(17, GPIO_FUNC_I2C);
  gpio_set_function(16, GPIO_FUNC_I2C);
  gpio_pull_up(17);
  gpio_pull_up(16);
}

void splashscreen(ssd1306_t disp) {
  ssd1306_clear( & disp);
  printf("Showing splash screen!\n");
  ssd1306_bmp_show_image( & disp, splash_screen_image_data, splash_screen_image_size);
  ssd1306_show( & disp);
  sleep_ms(SPLASHSCREEN_DURATION);
}

void overclockFail(ssd1306_t disp) {
  ssd1306_clear( & disp);
  printf("Showing overclock fail screen!\n");
  ssd1306_bmp_show_image( & disp, overclockfail_screen_image_data, overclockfail_screen_image_size);
  ssd1306_show( & disp);
}

double U64ToDoubleConverter(uint64_t val) {
  double convertedValue = 0.0;
  memcpy( & convertedValue, & val, sizeof(convertedValue));
  return convertedValue;
}

double determineNote(double frequency, char * output_note_string, char * output_octave_string) {
  if (frequency < CUTOFF_FREQUENCY) {
    strcpy(output_note_string, "L");
    strcpy(output_octave_string, "-");
    return (0);
  } else {
    double octaves_over_C0 = log2l(frequency / C0_FREQUENCY);
    double semitones_over_C0 = octaves_over_C0 * 12.0;
    int closest_whole_semitones_over_C0 = round(semitones_over_C0);
    char * closestnote = (char * ) malloc(2 * sizeof(char));
    char * octaveString = (char * ) malloc(2 * sizeof(char));
    strcpy(closestnote, notes_in_an_octave[closest_whole_semitones_over_C0 % 12]);
    sprintf(octaveString, "%i", (int)(floor(round(semitones_over_C0) / 12)));
    strcpy(output_note_string, closestnote);
    strcpy(output_octave_string, octaveString);
    free(closestnote); // no memory leaks here 😅...
    free(octaveString); // no memory leaks here 😅...
    return (semitones_over_C0 - closest_whole_semitones_over_C0);
  }
}

void drawGuitarStringIndicator(ssd1306_t* disp, int stringIndex) {
  ssd1306_draw_square(disp, 3 + stringIndex * 5, 35, 3, 3); // 3, 35
}

void drawOscilloscope(ssd1306_t* disp, float max_freq){
  int samples_to_read = OSCILLOSCOPE_SAMPLES;
  if (max_freq != 0){
  samples_to_read = round(2/max_freq*MIC_SAMPLERATE);
  }
  if (samples_to_read<=MIC_BUFFER_SIZE){
  float sample_offset = (float)samples_to_read/OSCILLOSCOPE_SAMPLES;
  int16_t max_value = 1;
  for (int i = 0; i < OSCILLOSCOPE_SAMPLES; ++i) {
      if (abs(sample_buffer[(int)round(sample_offset*i)]) > max_value) {
        max_value=abs(sample_buffer[(int)round(sample_offset*i)]);
      }
    }
  for (int i = 0; i < OSCILLOSCOPE_SAMPLES; ++i) {
      ssd1306_draw_pixel(disp,125-i,35+round(((float)sample_buffer[(int)round(sample_offset*i)])/((float)max_value)*OSCILLOSCOPE_GAIN));
    }
  }
  }

void displayTunerResults(ssd1306_t disp, char * output_note_letter, char * output_note_string, char * output_octave_string, char * output_cents_offset_string, double note_semitones_offset, float max_freq) {
  // Draw UI background skin
  ssd1306_bmp_show_image( & disp, main_ui_image_data, main_ui_image_size);
  // Display closest note
  ssd1306_draw_string( & disp, 59, 24, 2, output_note_letter); // (128-10)/2, (64-16)/2
  ssd1306_draw_string( & disp, 69, 20, 1, & (output_note_string[1])); // (128-10)/2+10+4, (64-16)/2-4
  ssd1306_draw_string( & disp, 69, 36, 1, output_octave_string); // (128-10)/2+10, (64-16)/2+12
  // Draw the offset bar
  if (note_semitones_offset < 0) {
    sprintf(output_cents_offset_string, "%dc", (int)(round(note_semitones_offset * 100)));
    ssd1306_draw_string( & disp, 28, 48, 1, output_cents_offset_string); // 128/2-4*5-16, 64-2-6-8
    ssd1306_draw_square( & disp, (int)(round(64 + (note_semitones_offset * 100 * SEMITONE_OFFSET_SENSITIVITY))), 56, (int)(round(fabs(note_semitones_offset * 100 * SEMITONE_OFFSET_SENSITIVITY))), 6); // 128/2, 64-2-6
  } else {
    sprintf(output_cents_offset_string, "+%dc", (int)(round(note_semitones_offset * 100)));
    ssd1306_draw_string( & disp, 80, 48, 1, output_cents_offset_string); // 128/2+16, 64-2-6-8
    ssd1306_draw_square( & disp, 64, 56, (int)(round(fabs(note_semitones_offset * 100 * SEMITONE_OFFSET_SENSITIVITY))), 6); // 128/2, 64-2-6
  }
  if (strcmp(output_octave_string, "2") == 0) {
    if (strcmp(output_note_string, "E") == 0) {
      drawGuitarStringIndicator(&disp, 0);
    }
    if (strcmp(output_note_string, "A") == 0) {
      drawGuitarStringIndicator(&disp, 1);
    }
  }
  if (strcmp(output_octave_string, "3") == 0) {
    if (strcmp(output_note_string, "D") == 0) {
      drawGuitarStringIndicator(&disp, 2);
    }
    if (strcmp(output_note_string, "G") == 0) {
      drawGuitarStringIndicator(&disp, 3);
    }
    if (strcmp(output_note_string, "B") == 0) {
      drawGuitarStringIndicator(&disp, 4);
    }
  }
  if (strcmp(output_octave_string, "4") == 0) {
    if (strcmp(output_note_string, "E") == 0) {
      drawGuitarStringIndicator(&disp, 5);
    }
  }
  drawOscilloscope(&disp,max_freq);
  // Display result
  ssd1306_show( & disp);
  ssd1306_clear( & disp);
}

double signnum_c(double x) {
  if (x > 0.0) return 1.0;
  if (x < 0.0) return -1.0;
  return x;
}

void showMainUI(ssd1306_t disp) {
  // FFT setup start.
  // calculate frequencies of each bin
  float f_max = MIC_SAMPLERATE;
  float f_res = f_max / MIC_BUFFER_SIZE;
  for (int i = 0; i < MIC_BUFFER_SIZE; i++) {
    freqs[i] = f_res * i;
  }
  kiss_fft_scalar fft_in[MIC_BUFFER_SIZE]; // kiss_fft_scalar is a float
  kiss_fft_cpx fft_out[MIC_BUFFER_SIZE];
  kiss_fftr_cfg cfg = kiss_fftr_alloc(MIC_BUFFER_SIZE, false, 0, 0);
  // FFT setup end.
  ssd1306_clear( & disp);
  char * old_output_note_string = (char * ) malloc(6 * sizeof(char));
  char * old_output_octave_string = (char * ) malloc(6 * sizeof(char));
  double old_note_semitones_offset = 0;
  bool is_this_the_first_output_note = true;
  // Allocate memory for temporary variables
  char * output_note_letter = (char * ) malloc(1 * sizeof(char));
  char * output_cents_offset_string = (char * ) malloc(4 * sizeof(char));
  char * output_note_string = (char * ) malloc(6 * sizeof(char));
  char * output_octave_string = (char * ) malloc(6 * sizeof(char));
  double note_semitones_offset = 0.0;
  // Boot animation
  if (SHOW_BOOT_ANIMATION) {
    double boot_animation_position = -0.5;
    double boot_velocity = 0.0;
    for (int i = 0; i < BOOT_ANIMATION_FRAMES; ++i) {
      displayTunerResults(disp, "L+", "L", "0", output_cents_offset_string, boot_animation_position, 0);
      boot_velocity += -signnum_c(boot_animation_position) / (boot_animation_position * boot_animation_position + 0.1) / 2000.0;
      boot_animation_position += boot_velocity;
    }
  }
  for (;;) {
    // wait for new samples
    while (samples_read == 0) {}
    // store and clear the samples read from the callback
    int sample_count = samples_read;
    samples_read = 0;
    // FFT calculations (Dear future self, it's 4AM as I'm writing this. Please forgive me for any bugs, memory leaks or thermonuclear war (see what I did there?))
    // fill fourier transform input while subtracting DC component
    uint64_t sum = 0;
    for (int i = 0; i < MIC_BUFFER_SIZE; i++) {
      sum += sample_buffer[i] * MIC_GAIN;
    }
    float avg = ((float)(sum)) / ((double) MIC_BUFFER_SIZE);

    for (int i = 0; i < MIC_BUFFER_SIZE; i++) {
      fft_in[i] = sample_buffer[i] * MIC_GAIN - avg;
    }
    // compute fast fourier transform
    kiss_fftr(cfg, fft_in, fft_out);

    // compute power and calculate max freq component
    float max_power = 0;
    int max_idx = 0;
    // any frequency bin over MIC_BUFFER_SIZE/2 is aliased (nyquist sampling theorum)
    for (int i = 0; i < MIC_BUFFER_SIZE / 2; i++) {
      float power = fft_out[i].r * fft_out[i].r + fft_out[i].i * fft_out[i].i;
      if (power > max_power) {
        max_power = power;
        max_idx = i;
      }
    }

    float max_freq = freqs[max_idx];
    printf("Greatest Frequency Component: %0.1f Hz\n", max_freq);
    // Determine played note and offset
    note_semitones_offset = determineNote(max_freq, output_note_string, output_octave_string);
    if (is_this_the_first_output_note) {
      is_this_the_first_output_note = false;
      sprintf(old_output_note_string, "%s", output_note_string);
      sprintf(old_output_octave_string, "%s", output_octave_string);
      old_note_semitones_offset = note_semitones_offset;
    } else {
      if (strcmp(output_note_string, "L") == 0) {
        sprintf(output_note_string, "%s", old_output_note_string);
        sprintf(output_octave_string, "%s", old_output_octave_string);
        note_semitones_offset = old_note_semitones_offset;
      } else {
        sprintf(old_output_note_string, "%s", output_note_string);
        sprintf(old_output_octave_string, "%s", output_octave_string);
        old_note_semitones_offset = note_semitones_offset;
      }
    }
    sprintf(output_note_letter, "%c", output_note_string[0]);
    displayTunerResults(disp, output_note_letter, output_note_string, output_octave_string, output_cents_offset_string, note_semitones_offset, max_freq);
  }
}

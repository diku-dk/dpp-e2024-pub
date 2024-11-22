#include <assert.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <termios.h>
#include "ising.h"

struct termios orig_termios;

void cooked_mode() {
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios);
  printf("\e[?25h");
}

void raw_mode() {
  printf("\e[?25l");

  tcgetattr(STDIN_FILENO, &orig_termios);
  atexit(cooked_mode);

  struct termios raw = orig_termios;
  raw.c_iflag &= ~(IXON);
  raw.c_lflag &= ~(ECHO | ICANON | ISIG);
  raw.c_cc[VMIN] = 0;
  raw.c_cc[VTIME] = 0;
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
}

void blue() {
  printf("\e[34;44m");
}

void red() {
  printf("\e[31;41m");
}

void def() {
  printf("\e[39;49m");
}

void clear_line() {
  printf("%c[2K", 27);
}

void render_state(struct futhark_context *ctx, struct futhark_opaque_state *state) {
  struct futhark_i8_2d *screen_arr;
  int err;

  err = futhark_entry_tui_render(ctx, &screen_arr, state);
  assert(err == 0);

  int height = futhark_shape_i8_2d(ctx, screen_arr)[0];
  int width = futhark_shape_i8_2d(ctx, screen_arr)[1];

  int8_t *pixels = malloc(height*width*sizeof(int8_t));

  futhark_values_i8_2d(ctx, screen_arr, pixels);
  assert(err == 0);

  for (int i = 0; i < height; i++) {
    for (int j = 0; j < width; j++) {
      uint32_t pixel = pixels[i*width+j];
      if (pixel == 1) {
        blue();
      } else {
        red();
      }
       printf(" ");
    }
    printf("\n");
  }
  def();
  fflush(stdout);
  free(pixels);
}

int main() {
  struct winsize w;
  ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);

  int height = w.ws_row-1;
  int width = w.ws_col;
  int err;

  struct futhark_context_config *cfg = futhark_context_config_new();
  assert(cfg != NULL);

#ifdef FUTHARK_BACKEND_opencl
  futhark_context_config_select_device_interactively(cfg);
#endif

  struct futhark_context *ctx = futhark_context_new(cfg);
  assert(ctx != NULL);

  struct futhark_opaque_state *state;
  uint32_t seed = 123;

  err = futhark_entry_tui_init(ctx, &state, seed, height, width);
  assert(err == 0);

  int buffer_size = height*(width+1);
  char buffer[height*(width+1)];

  raw_mode();
  setvbuf(stdout, buffer, _IOFBF, buffer_size);

  float abs_temp = 0.5;
  float samplerate = 0.1;

  printf("\033[2"); // Clear screen.
  while (1) {
    render_state(ctx, state);

    struct futhark_opaque_state *new_state;
    err = futhark_entry_tui_step(ctx, &new_state, abs_temp, samplerate, state);
    assert(err == 0);

    err = futhark_free_opaque_state(ctx, state);
    assert(err == 0);

    state = new_state;

    char c;
    if (read(STDIN_FILENO, &c, 1) != 0) {
      if (c == 'q') {
        break;
      } else if (c == 'z') {
        samplerate *= 0.99;
      } else if (c == 'x') {
        samplerate *= 1.01;
      } else if (c == 'a') {
        abs_temp *= 0.99;
      } else if (c == 's') {
        abs_temp *= 1.01;
      }
    }
    clear_line();
    printf(" temp (a/s): %.3f        samplerate (z/x): %.3f        quit (q)", abs_temp, samplerate);
    fflush(stdout);
    printf("\r\033[%dA", height); // Move up.
  }
  printf("\n");

  futhark_context_free(ctx);
  futhark_context_config_free(cfg);
}

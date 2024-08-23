#include <stdlib.h>

#define HEIGHT 3
#define WIDTH 8

char *map[] = {
    "###.#...",
    "...L..##",
    ".#######"
};

int lambdaManInit() {
  // Initialize the lambdaMan
  return 0;
}

int lambdaManGetWidth() {
  // Get the width of the lambdaMan
  return WIDTH;
}

int lambdaManGetHeight() {
  // Get the height of the lambdaMan
  return HEIGHT;
}

char lambdaManGetField(int row, int col) {
  
  if (row < 0 || row >= HEIGHT || col < 0 || col >= WIDTH) {
    abort();
  }

  return map[row][col];
}

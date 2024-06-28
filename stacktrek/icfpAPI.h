#include <stdlib.h>

#define HEIGHT 3
#define WIDTH 9

char grid[HEIGHT][WIDTH] = {
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

char lambdaManGetToken(int row, int col) {
  
  if (row < 0 || row >= WIDTH || col < 0 || col >= HEIGHT) {
    abort();
  }

  return grid[row][col];
}
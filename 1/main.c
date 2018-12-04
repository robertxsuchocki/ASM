#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "libpnmio/src/pnmio.h"

extern void decolour(int** matrix, int x, int y);

int main(int argc, char *argv[]) {
	FILE *input, *output;
	char path[100];
	int x, y, lvl, ascii;


	if (argc != 2) {
		printf("Usage: ./main /path/to/file\n");
		exit(1);
	}

	strcpy(path, argv[1]);

	if ((input = fopen(path, "r")) == NULL) {
		 printf("Wrong path to file: %s\n", argv[1]);
		 exit(1);
	}

	read_ppm_header(input, &x, &y, &lvl, &ascii);

	int *values = (int *) malloc(3 * x * y * sizeof(int));
	int **matrix = (int **) malloc(y * sizeof(int *));
	for (int i = 0; i < y; i++) {
		matrix[i] = (int *) malloc(3 * x * sizeof(int));
	}

	read_ppm_data(input, values, ascii);

	for (int j = 0; j < y; j++) {
		for (int i = 0; i < 3 * x; i++) {
			matrix[j][i] = values[(3 * x) * j + i];
		}
	}

	decolour(matrix, x, y);

	for (int j = 0; j < y; j++) {
		for (int i = 0; i < x; i++) {
			values[x * j + i] = matrix[j][i];
		}
	}

	strncpy(&path[strlen(path)-4], ".pgm", 4);
	output = fopen(path, "w");

	write_pgm_file(output, values, "", x, y, 1, 1, lvl, x, ascii);

	fclose(input);
	fclose(output);

	return 0;
}

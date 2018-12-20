#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

struct Matrixes {
   float *current;
	 float *spare;
};

extern void start(int x, int y, float *M, float *G, float *C, float w);
extern void step();

int main(int argc, char *argv[]) {
	char buf[256], path[256];
	FILE *f;
	int x, y, n;
	float w;
	struct Matrixes M;
	float *M1, *M2, *G, *C;

	if (argc != 4) {
		printf("Usage: ./main /path/to/file flow_multiplier number_of_rounds\n");
		exit(1);
	}

	if ((f = fopen(argv[1], "r")) == NULL) {
		 printf("Wrong path to file: %s\n", argv[1]);
		 exit(1);
	}

	w = strtof(argv[2], (char **) NULL);
	n = strtol(argv[3], (char **) NULL, 10);

	fscanf(f, "%s", buf);
	x = strtol(buf, (char **) NULL, 10);

	fscanf(f, "%s", buf);
	y = strtol(buf, (char **) NULL, 10);


	M1 = (float *) malloc(x * y * sizeof(float));
	M2 = (float *) malloc(x * y * sizeof(float));
	for (int j = 0; j < y; j++) {
		for (int i = 0; i < x; i++) {
			fscanf(f, "%s", buf);
			M1[(j * x) + i] = strtof(buf, (char **) NULL);
		}
	}

	G = (float *) malloc(x * sizeof(float));
	for (int i = 0; i < x; i++) {
		fscanf(f, "%s", buf);
		G[i] = strtof(buf, (char **) NULL);
	}

	C = (float *) malloc(y * sizeof(float));
	for (int j = 0; j < y; j++) {
		fscanf(f, "%s", buf);
		C[j] = strtof(buf, (char **) NULL);
	}

	M.current = M1;
	M.spare = M2;

	start(x, y, (float *) &M, G, C, w);

	for (int i = 0; i < n; i++) {
		step();

		for (int j = 0; j < y; j++) {
			for (int i = 0; i < x; i++) {
				printf("%f ", M.current[(j * x) + i]);
			}
			printf("\n");
		}
		printf("\n");
	}

	fclose(f);

	return 0;
}

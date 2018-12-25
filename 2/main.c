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

void print(float *M, int x, int x_real, int y) {
	for (int j = 0; j < y; j++) {
		for (int i = 0; i < x; i++) {
			printf("%f ", M[(j * x_real) + i]);
		}
        for (int i = x; i < x_real; i++) {
            M[(j * x_real) + i] = 0;
        }
		printf("\n");
	}
	printf("\n");
}

int main(int argc, char *argv[]) {
	char buf[256], path[256];
	FILE *f;
	int x, x_real, y, n;
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

    x_real = (x % 4 == 0) ? x : (x + 4 - (x % 4));

	fscanf(f, "%s", buf);
	y = strtol(buf, (char **) NULL, 10);


	M1 = (float *) malloc(x_real * y * sizeof(float));
	M2 = (float *) malloc(x_real * y * sizeof(float));
	for (int j = 0; j < y; j++) {
		for (int i = 0; i < x; i++) {
			fscanf(f, "%s", buf);
			M1[(j * x_real) + i] = strtof(buf, (char **) NULL);
			M2[(j * x_real) + i] = 0;
		}
        for (int i = x; i < x_real; i++) {
            M1[(j * x_real) + i] = 0;
            M2[(j * x_real) + i] = 0;
        }
	}

	G = (float *) malloc(x_real * sizeof(float));
	for (int i = 0; i < x; i++) {
		fscanf(f, "%s", buf);
		G[i] = strtof(buf, (char **) NULL);
	}
	for (int i = x; i < x_real; i++) {
		G[i] = 0;
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
		print(M.current, x, x_real, y);
		getchar();
	}

	fclose(f);

	return 0;
}

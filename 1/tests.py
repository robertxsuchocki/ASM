#!/usr/bin/python3

import filecmp
import os

EX_DIR = os.path.abspath('examples')
RES_DIR = os.path.abspath('results')

def main():
    ppms = [os.path.join(EX_DIR, p) for p in os.listdir(EX_DIR)\
                    if p.endswith('.ppm')]

    for path in ppms:
        os.system('./main ' + path)

    pgms = [os.path.join(EX_DIR, p) for p in os.listdir(EX_DIR)\
                    if p.endswith('.pgm')]

    results = [p.replace(EX_DIR, RES_DIR) for p in pgms]

    passes = map((lambda t: filecmp.cmp(t[0], t[1])), zip(pgms, results))

    if all(passes):
        print("All tests passed")
    else:
        print("There are FAILED tests!!!")

    for path in pgms:
        os.remove(path)

if __name__ == '__main__':
    main()

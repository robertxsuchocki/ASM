#!/usr/bin/python3

import filecmp
import os

EX_DIR = os.path.abspath('examples')

def main():
    exs = [os.path.join(EX_DIR, p) for p in os.listdir(EX_DIR)\
                    if p.startswith('exmp')]

    for exmp in exs:
        out = exmp.replace('exmp', 'out')
        os.system('./main ' + exmp + ' 0.1 1000 '
                    '<' + EX_DIR + '/enters.txt >' + out)

    outs = [open(os.path.join(EX_DIR, p), 'r').read().split('\n\n')[-2]
                .strip().replace('\n', ' ').replace('  ', ' ')
            for p in sorted(os.listdir(EX_DIR)) if p.startswith('out')]

    ress = [open(os.path.join(EX_DIR, p), 'r').read().split('\n\n')[0]
                .strip().replace('\n', ' ').replace('  ', ' ')
            for p in sorted(os.listdir(EX_DIR)) if p.startswith('res')]

    if outs == ress:
        print("All tests passed")
    else:
        print("There are FAILED tests!!!")

    paths = [os.path.join(EX_DIR, p) for p in os.listdir(EX_DIR)
                if p.startswith('out')]
    for path in paths:
        os.remove(path)

if __name__ == '__main__':
    main()

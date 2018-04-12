import sys

if __name__ == "__main__":
    for line in sys.stdin:
        if line.strip() != "":
            line = line.strip().replace(' ', '').replace('▁▁', ' ').replace('▁', '')

            sys.stdout.write(line + '\n')

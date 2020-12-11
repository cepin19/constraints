import sys
for line in sys.stdin:
    print(' '.join(tok+"|t0" for tok in line.split()))

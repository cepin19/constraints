# takes lemmatized and surface form files for not covered constraints, filters out examples which are in both -> only examples with correct lemma, but incorrect sf are left
import sys
with open(sys.argv[1]) as not_covered_lemm:
    lemm_ids=[line.split('\t')[0].strip() for line in not_covered_lemm]
with open(sys.argv[2]) as not_covered_sf:
    for line in not_covered_sf:
        if line.split('\t')[0].strip() not in lemm_ids:
            print(line,end='')

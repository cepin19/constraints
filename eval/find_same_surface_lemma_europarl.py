""" Prints out sentence pairs and constraints where the surface of constraint in reference is different from the form in dictionary/terminology db."""
import sys, nltk
from nltk.tokenize import word_tokenize

#with open(sys.argv[1]) as source_const, open(sys.argv[2]) as const_lemm, open(sys.argv[3]) as ref, open(sys.argv[4]) as ref_lemm:
#    for line_source, line_const_lemm, line_ref, line_ref_lemm in zip(source_const,const_lemm, ref,ref_lemm):
        # the exact form of the constraint was not found in the reference
 #       if line_source.split("<sep>")[1].strip().lower()+" " not in " ".join(word_tokenize(line_ref.lower())):
            # but the lemma is present
 #           if  line_const_lemm.strip() in line_ref_lemm:
#                print("{}\t{}".format(line_source.strip(),line_ref.strip()))

with open(sys.argv[1]) as source, open(sys.argv[2]) as const, open(sys.argv[3]) as const_sf, open(sys.argv[4]) as ref:
    for line_source, line_const, line_const_sf, line_ref in zip(source,const, const_sf, ref):
        if line_const.lower().strip()==line_const_sf.lower().strip():
                print("{}\t{}\t{}\t{}".format(line_source.strip(),line_ref.strip(),line_const.strip(), line_const_sf.strip()))


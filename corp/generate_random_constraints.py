usage="""
Generates random constraint subsequences from reference sentences. Version for not prerprocessed files.

Usage: cat $tab_separated_corpus | generate_random_constraints.py  $outprefix

creates 2 files:
$outprefix.random_constraints -- only the constraint sequences, separated by <c>
$outprefix.random_constraints_suffix -- constraints are appended to the source sentence, separated by <sep> from the sentence and by <c> from each other
"""
import sys
import random
import nltk
import string
if len(sys.argv)!=2:
    print(usage)
    sys.exit(-1)
skip_prob=0.5 # probability of skipping the sentence entirely
start_prob=0.3 # probability of starting a new constraint on each token
end_prob=0.75 # probability of finishing the constraint on each token
shuffle=True

with open(sys.argv[1]+".random_constraints","w") as cf,  open(sys.argv[1]+".random_constraints_suffix","w") as sf:
    for line in sys.stdin:
        constraints=[]
        line_src,line_tgt=line.split('\t')
        if random.random()>skip_prob:
            cf.write("\n")
            sf.write("{} <sep> \n".format(line_src.strip()))
            continue
        line_tgt_tok=nltk.word_tokenize(line_tgt)
        constraint_open=False
        for i,tok in enumerate(line_tgt_tok):
            if not constraint_open:
                if random.random()<start_prob and tok not in string.punctuation:
                    constraint_open=True
                    constraint_tmp=tok
                    #continue
            if constraint_open:
                if random.random()<end_prob:# and (i+1==len(line_tgt_tok) or line_tgt_tok[i+1] in string.punctuation):
                    constraint_open=False
                    if constraint_tmp!=tok:
                        constraint_tmp+=" "+tok
                    constraints.append(constraint_tmp.strip())
                    constraint_tmp=""
                else:
                    if constraint_tmp!=tok:
                        constraint_tmp+=" "+tok
        if shuffle:
            random.shuffle(constraints)

        cf.write(" <c> ".join(constraints).strip()+ "\n")
        sf.write("{} <sep>  {}\n".format(line_src.strip()," <c> ".join(constraints).strip()))



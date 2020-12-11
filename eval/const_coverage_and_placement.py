import sys
import numpy
from nltk.tokenize import word_tokenize
constraints_total=0

constraints_correct=0
placements_output=[]
placements_ref=[]
with open(sys.argv[1]) as constraints, (open(sys.argv[2])) as translations, open(sys.argv[3]) as ref:
    for line_constraints,line_tgt,line_ref in zip(constraints,translations,ref):
        const_list=line_constraints.split('<c>')
        for constraint in const_list:
            constraints_total+=1
            #check on token level, not just substrings
            output_pos=' '.join(word_tokenize(line_tgt.lower().strip())).find(' '.join(word_tokenize(constraint.lower().strip()))+" ")
            ref_pos=' '.join(word_tokenize(line_ref.lower().strip())).find(' '.join(word_tokenize(constraint.lower().strip()))+" ")
            if output_pos!=-1:
                placements_ref.append(ref_pos)
                placements_output.append(output_pos)
                constraints_correct+=1
print(constraints_correct)
print(constraints_total)
print(numpy.corrcoef(placements_output,placements_ref)[1,0])
print(constraints_correct/float(constraints_total))

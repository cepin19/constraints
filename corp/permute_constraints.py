import sys
import random
from nltk.tokenize import TreebankWordTokenizer
tok=TreebankWordTokenizer()
with open(sys.argv[1]) as constraints,open(sys.argv[2]) as translations:
    for line_constraints, line_tgt in zip(constraints, translations):
        #print (line_tgt)
        const_list = line_constraints.split('▁<c>')  # TODO: change to <c> with new constraints
        for constraint in const_list:
            constraint=constraint.strip()
            if constraint in line_tgt.strip():
                line_tgt=line_tgt.replace(constraint,"")

#                print(line_tgt)
 #               print("found constraints {}".format(constraint))
  #              print([span for span in tok.span_tokenize(line_tgt)])
                space_positions=[span[0] for span in tok.span_tokenize(line_tgt)]
   #             for span in tok.span_tokenize(line_tgt):
    #                print(line_tgt[span[0]:span[1]])
                new_pos=random.choice(space_positions)
     #           print("inserting into {}".format(new_pos))
                line_tgt=line_tgt[:new_pos].strip()+" "+constraint+" "+line_tgt[new_pos:].strip()

        print (line_tgt.strip())
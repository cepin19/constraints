"""Finds surface form of constraint in reference. Needs lemmatized constraints, lemmatized reference and surface form reference with same tokenization as the lemmatized one."""
import sys
with open(sys.argv[1]) as constraints, open(sys.argv[2]) as constraints_lemm,  open(sys.argv[3]) as ref_lemm,  open(sys.argv[4]) as ref_tok, open(sys.argv[5]) as ref, open(sys.argv[6]) as source:
    for line_const,line_const_lemm,line_ref_lemm,line_ref_tok,line_ref,line_source in zip(constraints,constraints_lemm,ref_lemm,ref_tok,ref,source):
        #line_const_lemm=line_const_lemm.replace("_","")
        num_tokens=line_const.strip().count(" ")
        lemm_pos_char=line_ref_lemm.lower().find(line_const.lower().strip())
        if lemm_pos_char==-1:
            lemm_pos_char = line_ref_lemm.lower().find(line_const_lemm.strip().lower())
            if lemm_pos_char == -1:

                #print (line_const.strip())
                #print(line_ref_lemm.strip())
                #print ("NOT FOUND")
                continue
        #input is tokenized, token index=number of preceding spaces
        lemm_pos=line_ref_lemm[:lemm_pos_char].count(" ")
        #get the surface form tokens of the constraint
        sf_tokens=line_ref_tok.split(" ")[lemm_pos:lemm_pos+num_tokens+1]
        print('\t'.join([line_source.strip(),line_ref.strip(),line_const.strip(),line_const_lemm.strip(),' '.join(sf_tokens).strip()]))
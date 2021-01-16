usage="""
THIS VERSION DOES NOT CHECK THE TARGET SIDE
Adds dictionary based constraints as a factors to corresponding source tokens.
Expects all input files to be sentencepiece-processed.
Creates both lemmatized and non-lemmatized version of the constraints.
Corpora are a file with tab-separated source and target sentences.

Usage: add_factors.py $dict_file_original $dict_file_lemmatized $corpus_file_original $corpus_file_lemmatized  $out_prefix $skip_prob

output files:


TODO: rewrite with multiprocessing, so I can only load the dictionary once (each process seems to take about 2.5G of memory, so I can't use all the cores with 64GB mem )
"""

import sys
import random
import nltk
# only works for one token
random.seed(1234)

stop_words = {"▁I", "▁you", "▁when", "▁and", "▁or", "▁a","▁the", "▁is", "▁are", "▁be", "▁so", "▁If", "▁we", "▁were", "▁as", "."}
#dictionary = {}
#dictionary_lemm = {}

#target_lemm = {}
#src_lemm = {}
#tok_terms={}
#tok_terms_lemm={}

def tokens_in_sent(tokens,sent):
    sent=sent.lower()
    tokens = tokens.strip()
    starti = sent.find(tokens)
    # found on a both subword and token level, in surface form target
    if (starti != -1 and (starti == 0 or sent[starti - 1] == " ") and (
            starti + len(tokens) == len(sent) or sent[
        starti + len(tokens)] == " ")):
        return True
    else:
        return False

# for unlemmatized version, src_line=src_line_lemm, tgt_line=tgt_line_lemm
def add_constraints(src_line,src_line_lemm,tgt_line,tgt_line_lemm,dict, tok_terms,outfile, constraintfile):
    src_constraints = ""
    tgt_constraints = ""
    new_src_line = src_line
    new_tgt_line = tgt_line
    src_line_lower = src_line.lower()
    tgt_line_lower = tgt_line.lower()
    dict_keys = dict.keys()

    if random.random() > skip_prob:
        # nltk tokenizer too slow :( I should pretokenize the data before
        tgt_line_detok = tgt_line_lower.replace(" ", "").replace("▁", " ").replace('.', ' .').replace(',',
                                                                                                      ' ,').replace(
            '?',
            ' ?').replace(
            '!', ' !').strip()
        src_line_detok = src_line_lower.replace(" ", "").replace("▁", " ").replace('.', ' .').replace(',',
                                                                                                      ' ,').replace(
            '?',
            ' ?').replace(
            '!', ' !').strip()
        tgt_line_lemm_detok = tgt_line_lemm.replace(" ", "").replace("▁", " ").replace('.', ' .').replace(',',
                                                                                                          ' ,').replace(
            '?',
            ' ?').replace(
            '!', ' !').strip()
        src_line_lemm_detok = src_line_lemm.replace(" ", "").replace("▁", " ").replace('.', ' .').replace(',',
                                                                                                          ' ,').replace(
            '?',
            ' ?').replace(
            '!', ' !').strip()
        src_tokens = src_line_lemm_detok.strip().split(" ")
        #print("src detok")
        #print(src_line_lemm_detok)
        #print(src_tokens)
        possible_keys = set()
        #  produce non lemmatized version first
        for t in src_tokens:
            if t in tok_terms:
                possible_keys = possible_keys.union(tok_terms[t])
            # print(possible_keys)
        #print(possible_keys)

        #=dict.keys()
        for dict_key in possible_keys:

            if not (dict_key in src_line_lemm): continue

            # we are only looking for complete tokens phrases, not substrings
            # found on a subword level, in surface form source
            if tokens_in_sent(dict_key, src_line_lemm):
                # print(dict_key)
                dict_key_detok = dict_key.replace(" ", "").replace("▁", " ").replace('.', ' .').replace(',',
                                                                                                        ' ,').replace(
                    '?', ' ?').replace('!', ' !').strip()

                # found on a token level, in surface form source
                if tokens_in_sent(dict_key_detok, src_line_lemm_detok):

                    # print(dict_key)
                    for dict_value in dict[dict_key]:
                        dict_value = dict_value.strip()

                        dict_value_detok = dict_value.replace(" ", "").replace("▁", " ").replace('.', ' .').replace(',',
                                                                                                                    ' ,').replace(
                            '?', ' ?').replace('!', ' !').strip()
         #               print("Looking for {}  in {}".format(dict_value,tgt_line_lemm))

                        new_src_line = new_src_line.replace(dict_key, '{} {}'.format(
                                dict_key.replace(' ', '|t1 ') + "|t1 ",
                                dict_value.replace(' ', '|t2 ') + "|t2 "), 1)

                        if src_constraints != "":
                            src_constraints += " ▁ <c> "
                            tgt_constraints += " ▁ <c> "

                        src_constraints = "{} {}".format(src_constraints, dict_key)
                        tgt_constraints = "{} {}".format(tgt_constraints, dict_value)

                        break
    constraintfile.write('\t'.join((src_constraints, tgt_constraints)) + '\n')

    # add default factors
    new_src_line_completed = ""
    for token in new_src_line.split():
        if "|" not in token:
            token += "|t0 "
        new_src_line_completed += " " + token
    outfile.write('\t'.join((new_src_line_completed, tgt_line.strip())) + '\n')





if len(sys.argv)!=7:
    sys.sterr.write(usage)
    sys.exit()


#with open("../lexD1reknc.cs-en.tabs.sp") as d, open("../lexD1reknc.cs-en.lemmatized.tabs.sp") as lemmatized_d:
def init_dict(filename):
    dictionary={}
    tok_terms={}
    with open(filename) as d:
        for line in d:
            line = line.lower()

            if len(line.split('\t')[0]) < 5 or len(line.split('\t')[0]) > 20 or line in stop_words: continue
            if line.split('\t')[0] in dictionary:
                dictionary[line.split('\t')[0]].append(line.split('\t')[1])
            else:
                dictionary[line.split('\t')[0]] = [line.split('\t')[1]]

            line_detok=line.split('\t')[0].replace(" ", "").replace("▁", " ").replace('.', ' .').replace(',',
                                                                                                          ' ,').replace(
            '?',
            ' ?').replace(
            '!', ' !').strip()
            # let's make a list of all subwords and all dictionary phrases which contains them
            for tok in line_detok.strip().split(" "):
                tok=tok.strip()#
                #if "▁like" in tok:
                 #   print(tok)
                if tok in tok_terms:
                    tok_terms[tok].add(line.split('\t')[0].strip())
                else:
                    tok_terms[tok]={line.split('\t')[0].strip()}
    return dictionary,tok_terms


skip_prob=float(sys.argv[6])
out_prefix=sys.argv[5]

dictionary,tok_terms=init_dict(sys.argv[1])
dictionary_lemm,tok_terms_lemm=init_dict(sys.argv[2])

#print(dictionary_lemm)
with open(sys.argv[3]) as f, open(sys.argv[4]) as lemm_f,open("{}.constraints_skip_prob{}".format(out_prefix,skip_prob), "w") as c,  open(
        "{}.constraints_skip_prob{}_lemmatized".format(out_prefix,skip_prob), "w")  as cl, \
        open("{}.factors_skip_prob{}".format(out_prefix,skip_prob), "w")  as out, open("{}.factors_skip_prob{}_lemmatized".format(out_prefix,skip_prob), "w") as outl:

    for line,line_lemm in zip(f,lemm_f):

        src_constraints_lemm = ""
        tgt_constraints_lemm = ""
        line = line.replace('|', '&#124;')
        line_lemm = line_lemm.replace('|', '&#124;').lower()

        src_line, tgt_line = line.split('\t')
        src_line_lemm, tgt_line_lemm = line_lemm.split('\t')
        #print(tok_terms["▁like"])
        #exit()
        #print(tgt_line_lemm)
        add_constraints(src_line,src_line.lower(),tgt_line,tgt_line.lower(),dictionary,tok_terms,out,c)
        add_constraints(src_line,src_line_lemm,tgt_line,tgt_line_lemm,dictionary_lemm,tok_terms_lemm,outl,cl)



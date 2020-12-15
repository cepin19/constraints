import os
import pandas as pd
from sacremoses import MosesTokenizer
"""
    Generate pair of sentences in English ||| Czech.
    We use Many Czech References Dataset, which has 50 English sentences and many Czech References.
    Thus, we pair each English sentence with all its references.
    We use the output to perform word alingment.
"""



# Paths.
eng_path = '/home/aires/personal_work_troja/constrained_decoding/datasets/many-czech-references/en.txt'
const_base_path = '/home/aires/personal_work_troja/constrained_decoding/datasets/many-czech-references/constraint_split'
out_path = '/home/aires/personal_work_troja/constrained_decoding/word_alignment/dataset'

# Read English sentences.
eng = pd.read_csv(eng_path, sep='\t')
# Set tokenizer.
mt = MosesTokenizer(lang='en')


def preprocess(line):
    # Remove special characters.
    return line.strip().replace('"', '')

# Run over sentids and write a line.
for sentid in eng['sentid'].unique():
    # Read English sentence.
    eng_sent = eng[eng['sentid'] == sentid]['sent'].values[0]
    # Tokenize eng_sent.
    eng_sent = preprocess(eng_sent)
    eng_sent = mt.tokenize(eng_sent, return_str=True) 
    # Read Czech constraint providers for sentid.
    const_path = os.path.join(const_base_path, str(sentid)+'_constraints.txt')
    const_file = open(const_path, 'r')
    
    # Open out_file.
    out_name = os.path.join(out_path, f'{sentid}.txt')
    out_file = open(out_name, 'w')

    for line in const_file.readlines():
        # Write to file En_sent ||| Cs_sent.
        line = preprocess(line)
        out_file.write(eng_sent + " ||| " + line + "\n")

    out_file.close()



import os
import json
import random

random.seed(12)

# Paths.
file_path = 'datasets/many-czech-references/many-references-datafile_w_ind'
out_folder = 'datasets/many-czech-references/constraint_split'
split = 0.2

sent_dict = dict()
ref_dict = dict()

# Read Many Refences dataset.
with open(file_path, 'r') as r_file:
    while True:
        line = r_file.readline()

        if not line:
            break
        """
        refid - a line counter to identify each sentence in the dataset.
        sentid - id from the paralel data from the dataset (50 in total).
        sent - reference sentence.
        """
        refid, sentid, _, _, sent = line.split('\t')

        # Divide by sentid.
        if sentid not in sent_dict:
            sent_dict[sentid] = [refid]
        else:
            # Store refs by sentid.
            sent_dict[sentid].append(refid)
        if refid not in ref_dict:
            ref_dict[refid] = sent


""" 
For each sentid, divide references into constraint providers ({sentid}_constraints.txt) and evaluation ({sentid}_references.txt).
"""
for sentid in sent_dict:
    c_path = os.path.join(out_folder, f'{sentid}_constraints.txt')
    r_path = os.path.join(out_folder, f'{sentid}_references.txt')
    r_write = open(r_path, 'w')
    c_write = open(c_path, 'w')
    print(f"Processing sent {sentid}")
    random.shuffle(sent_dict[sentid])
    c_range = int(len(sent_dict[sentid])*split) # Calculate the range using the predefined split.
    const = sent_dict[sentid][:c_range] # Constraints.
    refs = sent_dict[sentid][c_range:]  # References for evaluation.

    # Save to file.
    for con in const:
        c_write.write(ref_dict[con])
    for ref in refs:
        r_write.write(ref_dict[ref])
    

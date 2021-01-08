import os
import re
import sys
import time
import string
from sacremoses import MosesTokenizer

"""
    Look for terms from Závazné database in EuroParl sentences.
"""


# Paths
europarl = '/home/aires/personal_work_troja/constrained_decoding/rare_words/europarl/europarl-v7.cs-en.'
rare_cs = '/home/aires/personal_work_troja/constrained_decoding/rare_words/zavazne_database/cs.txt'
rare_en = '/home/aires/personal_work_troja/constrained_decoding/rare_words/zavazne_database/en.txt'

# Output files.
source = open('source.txt', 'w')
constraints = open('constraints.txt', 'w')
translation = open('translation.txt', 'w')
target = open('target.txt', 'w')

# Read rare words.
read_cs = open(rare_cs, 'r')
read_en = open(rare_en, 'r')

# Instantiate tokenizers.
mt_en = MosesTokenizer(lang='en')

# Rule to remove the content between parenthesis.
regex = r"\(.+?\)"

# Get punctuations.
table = str.maketrans(dict.fromkeys(string.punctuation))

n_rows = 646605 # Only for control.


def find_terms(terms, sentence):
    
    found = False
    
    if terms[0] in sentence:
        index = sentence.index(terms[0])
        found = True
        for term in terms[1:]:
            index += 1
            if index < len(sentence):
                if term != sentence[index]:
                    found = False
                    break
            else:
                found = False
                break
    else:
        found = False
    return found


def main():

    terms = {'en': [], 'cs': []}

    while True:
        # Read words from both Czech and English terms.
        en_dict = dict()
        cs_dict = dict()

        cs_line = read_cs.readline()
        if not cs_line:
            break

        cs_dict['cs_line'] = cs_line
        en_line = read_en.readline() 
        en_dict['en_line'] = en_line

        terms['cs'].append(cs_dict)       
        
        # Lower, remove punctuation, and remove between parenthesis info.
        low_en = re.sub(regex, "", en_line.lower().strip())
        low_en = low_en.translate(table)
        low_en = mt_en.tokenize(low_en)
        en_dict['low_en'] = low_en
        terms['en'].append(en_dict)
        

    row = 1
    # Read Czech and English files from EuroParl.
    euro_cs = open(europarl+'cs', 'r')
    euro_en = open(europarl+'en', 'r')
    
    while True:
        # Read line from both Czech and English EuroParl.
        cs_euro_line = euro_cs.readline()
        en_euro_line = euro_en.readline()

        if not cs_euro_line:
            break

        # Lower and remove punctuation.
        low_euro_en = en_euro_line.lower().strip().translate(table)
        low_euro_en = mt_en.tokenize(low_euro_en)

        for i, term in enumerate(terms['en']):
            
            found_en = find_terms(term['low_en'], low_euro_en)
            if not found_en:
                continue

            # If found, write both lines in target and source.
            source.write(en_euro_line)
            target.write(cs_euro_line)
            # Remove between parenthesis info.
            const = re.sub(regex, "", terms['cs'][i]['cs_line'])
            constraints.write(const)
            translation.write(en_euro_line.strip() + '\t' + const)

        source.flush()
        target.flush()
        constraints.flush()
        translation.flush()

        if row % 10000 == 0:
            os.system(f'echo "Processing row {row} out of {n_rows}"')
        row +=1
            
    euro_en.close()
    euro_cs.close()


if __name__ == '__main__':
    main()

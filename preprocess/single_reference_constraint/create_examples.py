import os
import sys
import json
import pandas as pd
from sacremoses import MosesTokenizer
from sklearn.feature_extraction.text import TfidfVectorizer

STOP_WORDS = 'datasets/czech_sw.txt' # Extracted from https://countwordsfree.com/stopwords/czech 
DATA_PATH = 'datasets/many-czech-references/'
CONSTRAINT_PATH = os.path.join(DATA_PATH, 'constraint_split/') # Output folder.
LEMMA = True # If True, create lemmatized constraints.
ID_SPLIT = False # If True, save translation input per sentid. If False, save all inputs to the same file.

if LEMMA:
    tail = '_lemmatized'
else:
    tail = ''

if not ID_SPLIT:
    # Out files.
    dataset_path = '/home/aires/personal_work_troja/constrained_decoding/datasets/many-czech-references/constraint_split'
    source = os.path.join(dataset_path, 'source'+tail+'.txt')
    w_source = open(source, 'w')
    constraints = os.path.join(dataset_path, 'constraints'+tail+'.txt')
    w_constraints = open(constraints, 'w')
    translation = os.path.join(dataset_path, 'translation'+tail+'.txt')
    w_translation = open(translation, 'w')

# Read sentences.
en_path = os.path.join(DATA_PATH, 'en.txt')
en = pd.read_csv(en_path, sep='\t')
# Instantiate tokenizer.
mt = MosesTokenizer(lang='en')
# Read stop words.
sw = open(STOP_WORDS, 'r').read().split('\n')


def select_tokens(tfidf_sents, feature_names, ind):
    # Get sorterd tfidf words for constraint application.
    # Take indexes for words.
    feature_index = tfidf_sents[ind, :].nonzero()[1]
    # Take scores.
    tfidf_scores = zip(feature_index, [tfidf_sents[ind, x] for x in feature_index])
    # Sort them.
    tfidf_scores = sorted(tfidf_scores, key=lambda x: x[1], reverse=True)
    # Take words.
    words = [feature_names[i] for (i, s) in tfidf_scores]

    return words

# Take sentids.
end_id = 'constraints.txt'
if LEMMA:
    end_id += '.lemmatized'

sentids = [int(f.split('_')[0]) for f in os.listdir(CONSTRAINT_PATH) if f.endswith(end_id)]

# Read constraint providers.
for sentid in sentids:

    if ID_SPLIT:
        if LEMMA:
            file_name = f"{sentid}_constraints.txt.lemmatized"
        else:
            file_name = f"{sentid}_constraints.txt"

    file_path = os.path.join(CONSTRAINT_PATH, file_name)
    # Get the English sentence.
    eng_sent = en[en['sentid'] == sentid]['sent'].values[0]#.lower()
    # Tokenize English sentence.
    eng_sent = mt.tokenize(eng_sent, return_str=True)
    # Read constraint providers for sentid.
    providers = open(file_path, 'r').readlines()
    # Calculate TF-IDF over constraint providers. We sort constraints by its importance to the sentence.
    tfidf = TfidfVectorizer(stop_words=sw, token_pattern=u'(?ui)\\b\\w*[a-z]+\\w*\\b') # Avoid numbers.
    tfidf_sents = tfidf.fit_transform(providers) # TFIDF over constraint providers
    feature_names = tfidf.get_feature_names()

    if ID_SPLIT:
        # Set out_file.
        if LEMMA:
            out_name = f"{sentid}_constrained.txt.lemmatized" 
        else:
            out_name = f"{sentid}_constrained.txt"
        out_path = os.path.join(CONSTRAINT_PATH, out_name)
        out_file = open(out_path, 'w')
        out_file.write(eng_sent+'\n') # No constraint example.
    
    for i in range(len(providers)):
        # For each constraint provider, calculate TF-IDF for it.
        tokens = select_tokens(tfidf_sents, feature_names, i)
        #n_tokens += len(tokens)
        # For each token, create a translating example. (eng_sentence + list_of_constraints)
        for t in range(len(tokens)):
            # Select current constraint with the previous ones.
            const = tokens[:t] + [tokens[t]]
            # Save to a file with the name corresponding to the source sentence (sentid).
            if ID_SPLIT:
                out_file.write(eng_sent+'\t'+'\t'.join(const)+'\n')
            else:
                w_source.write(eng_sent + '\n')
                w_constraints.write('\t'.join(const) + '\n')
                w_translation.write(eng_sent+'\t'+'\t'.join(const)+'\n')
    if ID_SPLIT:
        out_file.close()

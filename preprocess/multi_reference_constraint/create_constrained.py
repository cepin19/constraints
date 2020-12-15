import os
import sys
import csv
import random
import logging
from collections import OrderedDict
from sklearn.feature_extraction.text import TfidfVectorizer

"""
    Create a multi-reference constrained input.
    Given an English sentence and multiple Czech references, select positive constraints from different references.
"""

# Set seed.
random.seed(44)

""" 
    Define the output format.
    If ID_SPLIT = False, we will have four output files:
        source.txt - containing only the English sentence.
        constraints.txt - constraints applied to source.
        translation.txt - pair containing English sentence + tab-separated constraints.
        control.txt - for each row, indicates the origin of each sentence and constraint. 
    If IF_SPLIT = True, we will have two files for each ID (50 in our working dataset).
        {id}_constrained.txt - containing the pair English sentence + constraints.
        {id}.txt.control - for each row, indicates the origin of each sentence and constraint.
"""
ID_SPLIT = False # Set True to divide constraints per file ID.

# Paths
base_path = '/home/aires/personal_work_troja/constrained_decoding/word_alignment/dataset'
STOP_WORDS = '/home/aires/personal_work_troja/constrained_decoding/datasets/czech_sw.txt'

if not ID_SPLIT:
    # Output files.
    source = os.path.join(base_path, 'source_big.txt')
    w_source = open(source, 'w')
    constraints = os.path.join(base_path, 'constraints_big.txt')
    w_constraints = open(constraints, 'w')
    translation = os.path.join(base_path, 'translation_big.txt')
    w_translation = open(translation, 'w')
    control_path = os.path.join(base_path, 'control_big.txt')
    control_file = open(control_path, 'w')
    control_wrt = csv.writer(control_file, delimiter=',')


def calculate_tfidf(sents):
    # Calculate TF-IDF for cze sentences.
    sw = open(STOP_WORDS, 'r').read().split('\n') # Read stop words.
    tfidf = TfidfVectorizer(stop_words=sw, token_pattern=u'(?ui)\\b\\w*[a-z]+\\w*\\b') # Avoid numbers.
    tfidf_sents = tfidf.fit_transform(sents) # TFIDF over constraint providers
    feature_names = tfidf.get_feature_names()

    return tfidf_sents, feature_names


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


def dict_align(align_path):
    # Create a list of dicts containing target tokens as keys and source tokens as values.
    with open(align_path) as align_read:
        alignments =  align_read.readlines()
        dicts = []
        for align in alignments:
            a_dict = {}
            # align is a string with a series of alignments separated by spaces ('n1-m2 n7-m4')
            al = align.split()  # After split, we obtain ['n1-m2', 'n7-m4'].
            for a in al:
                s, t = a.split('-')
                if t not in a_dict:
                    a_dict[t] = [s]
                else:
                    a_dict[t].append(s)
            dicts.append(a_dict)
    return dicts


def set_output_files(sentid):
    # Set output file for sentid when ID_SPLIT = True.

    # Set constrained_file to save eng + constraints.
    constrained_path = os.path.join(base_path, f'{sentid}.txt.constrained')
    constrained_file = open(constrained_path, 'w')
    # Set control_file to save the origin of each example in constrained_file.
    control_path = os.path.join(base_path, f'{sentid}.txt.control')
    control_file = open(control_path, 'w')
    control_wrt = csv.writer(control_file, delimiter=',')

    return constrained_file, control_wrt, control_file


def check_alignment(used_refs, ref_aligned, sentences):
    # Identifies whether constraint candidates have the same meaning (alignment) to the ones already selected.
    # Return True if there is an alignment and False otherwise.

    align = False

    for used_ind in used_refs:
        sent = sentences['cze_sents'][used_ind].split()
        if used_refs[used_ind][1] in sent:
            token_ind = sent.index(used_refs[used_ind][1])   # Get token index in sentence.
        else:
            continue
        align_sent = sentences['align_dict'][used_ind]   # Get the alignment for sent.
        
        if str(token_ind) in align_sent:
            aligned = align_sent[str(token_ind)]    # Get the direct alignment of token to the source tokens.
        else:
            continue

        for i in ref_aligned:
            # Check if ref_token and token have different alignments with source tokens. 
            if i in aligned:
                align = True
                break
        if align:
            break
    return align


def find_token(used_refs, ref_ind, sentences):
    # Take tokens from ref_ind.
    ref_tokens = select_tokens(sentences['tfidf_sents'],
        sentences['feature_names'], ref_ind)
    # Take ref_sent.
    ref_sent = sentences['cze_sents'][ref_ind].split()
    # Find constraint token.
    # Find a token in ref_tokens that does not have the same meaning of token.
    # Use alignments to check if token and ref_tokens do not point to the same source word.
    align_ref = sentences['align_dict'][ref_ind]    # Get the alignment for ref_sent.
    
    for ref_token in ref_tokens:
        # For each ref_token in ref_tokens, check if we can use it as a constraint.
        if ref_token in ref_sent:
            r_token_ind = ref_sent.index(ref_token) # Get token index in ref_sent.
        else:
            continue
        if str(r_token_ind) in align_ref:
            ref_aligned = align_ref[str(r_token_ind)] # Get the direct alignment of ref_token to the source tokens.
        else:
            continue
        aligned = check_alignment(used_refs, ref_aligned, sentences)
        
        if not aligned:
            # If not, return the token to be used as a constraint.
            return ref_token

    return False


def write_to_file(used_refs, sentences):
    aux_refs = [str(int(i)+1) for i in map(str, used_refs.keys())][1:]
    aux_inds = [str(used_refs[tok][0]) for tok in used_refs][1:]
    constraints = [used_refs[tok][1] for tok in used_refs]
    main_ref = list(used_refs.keys())[0]
    token_ind = used_refs[list(used_refs.keys())[0]][0]
    
        
    if ID_SPLIT:
        sentences['output_file'].write(
            sentences['eng_sent'] + '\t' + '\t'.join(constraints)+'\n')
        sentences['control'].writerow(
            [sentences['line_count'], main_ref+1, token_ind, '-'.join(aux_refs), '-'.join(aux_inds)])
        sentences['line_count'] += 1
    else:
        w_source.write(sentences['eng_sent'] + '\n')
        w_constraints.write('\t'.join(constraints) + '\n')
        w_translation.write(
            sentences['eng_sent'] + '\t' + '\t'.join(constraints)+'\n'
            )
        control_wrt.writerow(
            [sentences['sentid'], sentences['line_count'], main_ref+1, token_ind, '-'.join(aux_refs),
                '-'.join(aux_inds)])
        sentences['line_count'] += 1
    

def get_constraints(sentences):
    # Select tokens for constraints.
    cze_sents = sentences['cze_sents']
    
    print("Max constraints: %d\n" % sentences['max_const'])
    print("Number of sentences: ", len(cze_sents))

    for ind, cze_sent in enumerate(cze_sents):
        # Get sent tokens.
        sent = cze_sent.split()
        # TF_IDF over sentence.
        tokens = select_tokens(sentences['tfidf_sents'],
            sentences['feature_names'], ind)
        
        indexes = [ind] # Save used indexes.

        limit = 2 # Set a small limit of base tokens.

        if len(tokens) < limit:
            limit = len(tokens)

        for token in tokens[:limit]:
            # For each token in sentence, create a constraint combination of different lengths.
            try:
                ref_ind = random.choice([i for i in range(len(cze_sents)) if i not in indexes])   # Index for a different reference.
            except:
                break
            indexes.append(ref_ind)
            for n_constraints in range(2, sentences['max_const']):
                if token in sent:
                    token_ind = sent.index(token)
                else:
                    break
                used_refs = OrderedDict()
                used_refs[ind] = (token_ind, token)
                
                for i in range(1, n_constraints):
                    while True:
                        const_token = find_token(used_refs, ref_ind, sentences)
                        if const_token:
                            cze_sent = sentences['cze_sents'][ref_ind].split()
                            const_id = cze_sent.index(const_token)
                            used_refs[ref_ind] = (const_id, const_token)                            
                            break

                        try:                                
                            ref_ind = random.choice([i for i in range(len(cze_sents)) if i not in indexes])   # Index for a different reference.
                        except:
                            break
                        indexes.append(ref_ind)
                    try:                                
                        ref_ind = random.choice([i for i in range(len(cze_sents)) if i not in indexes])   # Index for a different reference.
                    except:
                        break
                    indexes.append(ref_ind)

                write_to_file(used_refs, sentences)


def process_file(sentid):
    # Read file and create a dict structure.
    sents_path = os.path.join(base_path, f'{sentid}.txt')
    with open(sents_path, 'r') as sents_read:
        file_info = dict()
        file_info['sentid'] = sentid
        file_info['cze_sents'] = [] # Save Czech sentences in a list.

        while True:
            line = sents_read.readline()
            if not line:
                break
            try:
                eng_sent, cze_sent = line.split(' ||| ')
            except:
                print("Found a problem with sentid: ", sentid)
                sys.exit(1)
            file_info['cze_sents'].append(cze_sent)

        file_info['eng_sent'] = eng_sent
        file_info['max_const'] = int(len(eng_sent.split()) * 0.1) + 2 
        # Read alignment file.
        align_path = os.path.join(base_path, f'{sentid}.txt.align')
        file_info['align_dict'] = dict_align(align_path)
        # Calculate TF-IDF for cze sentences.
        tfidf_sents, feature_names = calculate_tfidf(file_info['cze_sents'])
        file_info['tfidf_sents'] = tfidf_sents
        file_info['feature_names'] = feature_names
        if ID_SPLIT:
            # Set constrained_file to save eng + constraints.
            constrained_file, control_wrt, control_file = set_output_files(sentid)
            file_info['output_file'] = constrained_file
            file_info['control'] = control_wrt
            file_info['control_file'] = control_file 
    return file_info


def create_constraints(sentids):
    # Create a dict to store sentences.
    sentences = dict()
    counter = 1

    if not ID_SPLIT:
        control_wrt.writerow(['sentid', 'line', 'main_ref', 'token_ind',
            'aux_refs', 'aux_inds'])
        line_count = 1

    for sentid in sentids:
        # Read 'eng ||| cze' files.
        os.system(f"echo Processing {sentid}.txt {counter}/{len(sentids)}")
        
        # Sentid file.
        # Create a dict to store all the elements from sentid file.
        sentences = process_file(sentid)

        if ID_SPLIT:
            sentences['control'].writerow(['line','main_ref','token_ind',
                'aux_refs','aux_inds']) # Control header.
            sentences['line_count'] = 1
            # Save constraint-free sentence.
            sentences['output_file'].write(sentences['eng_sent'] + '\n')
            sentences['control'].writerow([sentences['line_count'], '-', '-',
                '-', '-'])
            sentences['line_count'] += 1
        else:
            sentences['line_count'] = line_count
        
        get_constraints(sentences)
        counter += 1
        
        if ID_SPLIT:
            sentences['output_file'].close()
            sentences['control_file'].close()
        else:
            line_count = sentences['line_count']
            w_constraints.flush()
            w_source.flush()
            w_translation.flush()
            control_file.flush()

    if not ID_SPLIT:
        w_constraints.close()
        w_source.close()
        w_translation.close()
        control_file.close()


def main():
    # Get sentids.
    files = os.listdir(base_path)
    files.sort(key=lambda f: os.stat(os.path.join(base_path,f)).st_size)
    sentids = [sentid.split('.')[0] for sentid in files if 'align' in sentid]

    create_constraints(sentids)
            

if __name__ == "__main__":
    main()

import sys
from nltk.stem.snowball import SnowballStemmer
from nltk.tokenize import word_tokenize 

stemmer = SnowballStemmer("english")
for line in sys.stdin:
    line_tok=word_tokenize(line.strip())
    print(' '.join(stemmer.stem(tok) for tok in line_tok))

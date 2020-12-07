#!/bin/bash
#echo "Validating..."

moses_home=/home/big_maggie/usr/moses20161024/mosesdecoder/
date=`date +"%d_%m_%Y_%H:%M"`

cat $1 | /scratch/project/open-20-25/constrained/tools/sentencepiece/build/src/spm_decode --model corp/encs.model |  perl tools/fix-cs-quotes-etc.pl  > data/output.postprocessed.encs.$date



cat data/output.postprocessed.encs.$date   |python3 tools/sacrebleu/sacrebleu/sacrebleu.py corp/news19.cs.snt | cut -f 3 -d ' ' | cut -f 1 -d ',' 


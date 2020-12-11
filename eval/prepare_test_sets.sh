#!/bin/bash
set -e 
# preprocess news20 test
spm_dir="/home/big_maggie/usr/marian_cosmas/marian_1.9.0/marian-dev/build/"
python -m sacrebleu -t wmt20 -l en-cs --echo src > news20.en.snt
python -m sacrebleu -t wmt20 -l en-cs --echo ref > news20.cs.snt
cat news20.cs.snt | bash  lemm_preserve_newlines.sh  > news20.cs.snt.lemmatized
$spm_dir/spm_encode --model ../corp/encs.model  < news20.cs.snt > news20.cs.sp
$spm_dir/spm_encode --model ../corp/encs.model  < news20.en.snt > news20.en.sp
paste -d'\t' news20.en.sp news20.cs.sp >  news20.tabs.sp
../corp/lemmatize_cs.sh news20.cs.snt 
../corp/lemmatize_en.sh news20.en.snt 
$spm_dir/spm_encode --model ../corp/encs.model < news20.en.snt.lemmatized > news20.en.sp.lemmatized
$spm_dir/spm_encode --model ../corp/encs.model < news20.cs.snt.lemmatized > news20.cs.sp.lemmatized
paste news20.en.sp.lemmatized news20.en.sp.lemmatized > news20.lemmatized.tabs.sp

python ../corp/czech_stemmer.py  light <  news20.cs.snt > news20.cs.snt.stemmed
python ../corp/english_stemmer.py <  news20.en.snt > news20.en.snt.stemmed
$spm_dir/spm_encode --model ../corp/encs.model <news20.en.snt.stemmed> news20.en.sp.stemmed
$spm_dir/spm_encode --model ../corp/encs.model <news20.cs.snt.stemmed> news20.cs.sp.stemmed
paste news20.en.sp.stemmed news20.cs.sp.stemmed > news20.stemmed.tabs.sp



# create gold constraint test sets
python ../corp/add_factors.py  ../lexD1reknc.cs-en.tabs.sp ../corp/lexD1reknc.cs-en.lemmatized.tabs.sp  news20.tabs.sp news20.lemmatized.tabs.sp news20.encs 0.0
python ../corp/add_factors.py  ../lexD1reknc.cs-en.tabs.sp ../corp/lexD1reknc.cs-en.stemmed.tabs.sp  news20.tabs.sp news20.stemmed.tabs.sp news20.encs.stemmed 0.0

#
cut -f2 news20.encs.constraints_skip_prob0.0 > news20.encs.constraints_skip_prob0.0_tgt_only.sp
$spm_dir/spm_decode --model ../corp/encs.model < news20.encs.constraints_skip_prob0.0_tgt_only.sp > news20.encs.constraints_skip_prob0.0_tgt_only.snt
paste -d'\t' news20.en.sp news20.encs.constraints_skip_prob0.0_tgt_only.sp | sed 's/\t/ ▁ <sep> /g' > news20.en.suffix_constraints.sp
../corp/lemmatize_cs.sh news20.encs.constraints_skip_prob0.0_tgt_only.snt
$spm_dir/spm_encode --model ../corp/encs.model <  news20.encs.constraints_skip_prob0.0_tgt_only.snt.lemmatized >  news20.encs.constraints_skip_prob0.0_tgt_only.sp.lemmatized
paste -d'\t' news20.en.sp news20.encs.constraints_skip_prob0.0_tgt_only.sp.lemmatized | sed 's/\t/ ▁ <sep> /g' > news20.en.suffix_constraints_lemmatized.sp


python ../corp/czech_stemmer.py light < news20.encs.constraints_skip_prob0.0_tgt_only.snt > news20.encs.constraints_skip_prob0.0_tgt_only.snt.stemmed
$spm_dir/spm_encode --model ../corp/encs.model <  news20.encs.constraints_skip_prob0.0_tgt_only.snt.stemmed >  news20.encs.constraints_skip_prob0.0_tgt_only.sp.stemmed
paste -d'\t' news20.en.sp news20.encs.constraints_skip_prob0.0_tgt_only.sp.stemmed | sed 's/\t/ ▁ <sep> /g' > news20.en.suffix_constraints_stemmed.sp

sed 's/$/ ▁ <sep> /g' news20.en.sp > news20.en.constraint_suffix_empty.sp

#cut -f2 news20.encs.constraints_skip_prob0.0 > news20.encs.constraints.sp
#$spm_dir/spm_decode --model ../corp/encs.model  < news20.encs.constraints.sp  | sed 's/▁<c>/ ▁ <c> /g' > news20.encs.constraints.snt
#at news20.encs.constraints.snt  |bash  lemm_preserve_newlines.sh  | sed 's/▁ < c >/ ▁ <c> /g' >  news20.encs.constraints.snt.lemmatized
#$spm_dir/spm_encode --model ../corp/encs.model  <  news20.encs.constraints.snt.lemmatized | sed 's/▁ < c >/ ▁ <c> /g' > news20.encs.constraints.sp.lemmatized
#paste news20.encs.constraints.sp news20.en.sp | sed 's/\t/ ▁ <sep> /g ' > news20.en.sp.constraint_prefix
#paste news20.en.sp  news20.encs.constraints.sp  | sed 's/\t/ ▁ <sep> /g  ' > news20.en.sp.constraint_suffix
#paste news20.encs.constraints.sp.lemmatized news20.en.sp | sed 's/\t/ ▁ <sep> /g  ' > news20.en.sp.lemmatized_constraint_prefix
#paste news20.en.sp  news20.encs.constraints.sp.lemmatized  | sed 's/\t/ ▁ <sep> /g ' > news20.en.sp.lemmatized_constraint_suffix




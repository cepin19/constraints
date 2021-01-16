#!/bin/sh
set -e
#run sentencepiece preproc first
#./prepreprocess.sh

##add random constraints to the training data
#./create_random_constraints.sh 


#paste czeng20-train.en.sp czeng20-train.cs.sp > czeng20-train.tabs.sp
#paste czeng20-csmono.en.sp czeng20-csmono.cs.sp > czeng20-csmono.tabs.sp

#lemmatize dictionary, training and test data
#./lemmatize_data.sh 

#stem dictionary, training and test data
#./stem_data.sh

wait


#generate dictionary constraints

# create gold constraint test sets
#python add_factors.py  ../lexD1reknc.cs-en.tabs.sp lexD1reknc.cs-en.lemmatized.tabs.sp  news19.tabs.sp news19.lemmatized.tabs.sp news19.encs 0.0
#python add_factors.py  ../lexD1reknc.cs-en.tabs.sp lexD1reknc.cs-en.stemmed.tabs.sp  news19.tabs.sp news19.stemmed.tabs.sp news19.encs.stemmed 0.0

#
#cut -f2 news19.encs.constraints_skip_prob0.0 > news19.encs.constraints_skip_prob0.0_tgt_only.sp
#$spm_dir/spm_decode --model encs.model < news19.encs.constraints_skip_prob0.0_tgt_only.sp > news19.encs.constraints_skip_prob0.0_tgt_only.snt
#paste -d'\t' news19.en.sp news19.encs.constraints_skip_prob0.0_tgt_only.sp | sed 's/\t/ ▁ <sep> /g' > news19.en.suffix_constraints.sp
#./lemmatize_cs.sh news19.encs.constraints_skip_prob0.0_tgt_only.snt
#$spm_dir/spm_encode --model encs.model <  news19.encs.constraints_skip_prob0.0_tgt_only.snt.lemmatized >  news19.encs.constraints_skip_prob0.0_tgt_only.sp.lemmatized
#paste -d'\t' news19.en.sp news19.encs.constraints_skip_prob0.0_tgt_only.sp.lemmatized | sed 's/\t/ ▁ <sep> /g' > news19.en.suffix_constraints_lemmatized.sp


#python czech_stemmer.py light < news19.encs.constraints_skip_prob0.0_tgt_only.snt > news19.encs.constraints_skip_prob0.0_tgt_only.snt.stemmed
#$spm_dir/spm_encode --model encs.model <  news19.encs.constraints_skip_prob0.0_tgt_only.snt.stemmed >  news19.encs.constraints_skip_prob0.0_tgt_only.sp.stemmed
#paste -d'\t' news19.en.sp news19.encs.constraints_skip_prob0.0_tgt_only.sp.stemmed | sed 's/\t/ ▁ <sep> /g' > news19.en.suffix_constraints_stemmed.sp


proc=16
for set in "csmono" "train"
do
#paste -d'\t' czeng20-$set.tabs.sp  czeng20-$set.lemmatized.tabs.sp czeng20-$set.stemmed.tabs.sp   > czeng20-$set.tabs.nonlem+lem+stemmed.sp
#	split -d -n l/32 czeng20-$set.tabs.nonlem+lem.sp  parts/czeng20-$set.tabs.nonlem+lem+stemmed.sp.part
#for i in {00..31}
#do
#	cut -f 1,2 parts/czeng20-$set.tabs.nonlem+lem+stemmed.sp.part$i > parts/czeng20-$set.tabs.sp.part$i
 #       cut -f 3,4 parts/czeng20-$set.tabs.nonlem+lem+stemmed.sp.part$i > parts/czeng20-$set.lemmatized.tabs.sp.part$i
#        cut -f 3,4 parts/czeng20-$set.tabs.nonlem+lem+stemmed.sp.part$i > parts/czeng20-$set.stemmed.tabs.sp.part$i


#done

#skip generating the constraints in 50% of the sentences
#echo {00..31} | sed 's/ /\n/g'| parallel -j $proc  python add_factors.py  ../lexD1reknc.cs-en.tabs.sp ../lexD1reknc.cs-en.lemmatized.tabs.sp  parts/czeng20-$set.tabs.sp.part{}   parts/czeng20-$set.lemmatized.tabs.sp.part{} parts/czeng20-$set.tabs.sp.part{} 0.5
#cat parts/czeng20-$set.tabs.sp.part{00..31}.factors_skip_prob0.5_lemmatized > czeng20-$set.tabs.sp.factors_skip_prob0.5_lemmatized
#cat parts/czeng20-$set.tabs.sp.part{00..31}.factors_skip_prob0.5 > czeng20-$set.tabs.sp.factors_skip_prob0.5
#cat parts/czeng20-$set.tabs.sp.part{00..31}.constraints_skip_prob0.5_lemmatized > czeng20-$set.tabs.sp.dict_constraints_skip_prob0.5_lemmatized
#cat parts/czeng20-$set.tabs.sp.part{00..31}.constraints_skip_prob0.5 > czeng20-$set.tabs.sp.dict_constraints_skip_prob0.5

#generate constraints for all the sentences
#echo {00..31}  | sed 's/ /\n/g' | parallel -j $proc  python add_factors.py  ../lexD1reknc.cs-en.tabs.sp ../lexD1reknc.cs-en.lemmatized.tabs.sp  parts/czeng20-$set.tabs.sp.part{}   parts/czeng20-$set.lemmatized.tabs.sp.part{} parts/czeng20-$set.tabs.sp.part{} 0.0
#cat parts/czeng20-$set.tabs.sp.part{00..31}.factors_skip_prob0.0_lemmatized > czeng20-$set.tabs.sp.factors_skip_prob0.0_lemmatized
#cat parts/czeng20-$set.tabs.sp.part{00..31}.factors_skip_prob0.0 > czeng20-$set.tabs.sp.factors_skip_prob0.0
#cat parts/czeng20-$set.tabs.sp.part{00..31}.constraints_skip_prob0.0_lemmatized > czeng20-$set.tabs.sp.dict_constraints_skip_prob0.0_lemmatized
#cat parts/czeng20-$set.tabs.sp.part{00..31}.constraints_skip_prob0.0 > czeng20-$set.tabs.sp.dict_constraints_skip_prob0.0


#do the same with stemmed corpuse instead of lemmatized

#echo {00..31} | sed 's/ /\n/g'| parallel -j $proc  python add_factors.py  ../lexD1reknc.cs-en.tabs.sp lexD1reknc.cs-en.stemmed.tabs.sp  parts/czeng20-$set.tabs.sp.part{}   parts/czeng20-$set.stemmed.tabs.sp.part{} parts/czeng20-$set.tabs.sp.stemmed.part{} 0.5
#cat parts/czeng20-$set.tabs.sp.stemmed.part{00..31}.factors_skip_prob0.5_lemmatized > czeng20-$set.tabs.sp.factors_skip_prob0.5_stemmed
#cat parts/czeng20-$set.tabs.sp.stemmed.part{00..31}.constraints_skip_prob0.5_lemmatized > czeng20-$set.tabs.sp.dict_constraints_skip_prob0.5_stemmed




#generate constraints for all the sentences
#echo {00..31}  | sed 's/ /\n/g' | parallel -j $proc  python add_factors.py  ../lexD1reknc.cs-en.tabs.sp lexD1reknc.cs-en.stemmed.tabs.sp  parts/czeng20-$set.tabs.sp.part{}   parts/czeng20-$set.stemmed.tabs.sp.part{} parts/czeng20-$set.tabs.sp.stemmed.part{} 0.0
#cat parts/czeng20-$set.tabs.sp.stemmed.part{00..31}.factors_skip_prob0.0_lemmatized > czeng20-$set.tabs.sp.factors_skip_prob0.0_stemmed
#cat parts/czeng20-$set.tabs.sp.stemmed.part{00..31}.constraints_skip_prob0.0_lemmatized > czeng20-$set.tabs.sp.dict_constraints_skip_prob0.0_stemmed

paste -d'\t' czeng20-$set.en.sp <(cut -f2 czeng20-$set.tabs.sp.dict_constraints_skip_prob0.0) | sed 's/\t/ ▁ <sep> /g' >  czeng20-$set.en.dict_constraints_suffix_skip_0.0.sp
paste -d'\t' czeng20-$set.en.sp <(cut -f2 czeng20-$set.tabs.sp.dict_constraints_skip_prob0.0_lemmatized) | sed 's/\t/ ▁ <sep> /g' >  czeng20-$set.en.dict_constraints_suffix_skip_0.0.lemmatized.sp
paste -d'\t' czeng20-$set.en.sp <(cut -f2 czeng20-$set.tabs.sp.dict_constraints_skip_prob0.0_stemmed) | sed 's/\t/ ▁ <sep> /g' >  czeng20-$set.en.dict_constraints_suffix_skip_0.0.stemmed.sp

paste -d'\t' czeng20-$set.en.sp <(cut -f2 czeng20-$set.tabs.sp.dict_constraints_skip_prob0.5) | sed 's/\t/ ▁ <sep> /g' >  czeng20-$set.en.dict_constraints_suffix_skip_0.5.sp
paste -d'\t' czeng20-$set.en.sp <(cut -f2 czeng20-$set.tabs.sp.dict_constraints_skip_prob0.5_lemmatized) | sed 's/\t/ ▁ <sep> /g' >  czeng20-$set.en.dict_constraints_suffix_skip_0.5.lemmatized.sp
paste -d'\t' czeng20-$set.en.sp <(cut -f2 czeng20-$set.tabs.sp.dict_constraints_skip_prob0.5_stemmed) | sed 's/\t/ ▁ <sep> /g' >  czeng20-$set.en.dict_constraints_suffix_skip_0.5.stemmed.sp



head -n 25000000 czeng20-$set.en.dict_constraints_suffix_skip_0.0.sp > czeng20-$set.head25M.en.dict_constraints_suffix_skip_0.0.sp
head -n 25000000 czeng20-$set.en.dict_constraints_suffix_skip_0.0.lemmatized.sp > czeng20-$set.head25M.en.dict_constraints_suffix_skip_0.0.lemmatized.sp
head -n 25000000 czeng20-$set.en.dict_constraints_suffix_skip_0.0.sp > czeng20-$set.head25M.en.dict_constraints_suffix_skip_0.0.stemmed.sp

tail -n +25000000 czeng20-$set.en.dict_constraints_suffix_skip_0.0.sp > czeng20-$set.tail+25M.en.dict_constraints_suffix_skip_0.0.sp
tail -n +25000000 czeng20-$set.en.dict_constraints_suffix_skip_0.0.lemmatized.sp > czeng20-$set.tail+25M.en.dict_constraints_suffix_skip_0.0.lemmatized.sp
tail -n +25000000 czeng20-$set.en.dict_constraints_suffix_skip_0.0.sp > czeng20-$set.tail+25M.en.dict_constraints_suffix_skip_0.0.stemmed.sp

head -n 25000000 czeng20-$set.en.dict_constraints_suffix_skip_0.5.sp > czeng20-$set.head25M.en.dict_constraints_suffix_skip_0.5.sp
head -n 25000000 czeng20-$set.en.dict_constraints_suffix_skip_0.5.lemmatized.sp > czeng20-$set.head25M.en.dict_constraints_suffix_skip_0.5.lemmatized.sp
head -n 25000000 czeng20-$set.en.dict_constraints_suffix_skip_0.5.sp > czeng20-$set.head25M.en.dict_constraints_suffix_skip_0.5.stemmed.sp

tail -n +25000000 czeng20-$set.en.dict_constraints_suffix_skip_0.5.sp > czeng20-$set.tail+25M.en.dict_constraints_suffix_skip_0.5.sp
tail -n +25000000 czeng20-$set.en.dict_constraints_suffix_skip_0.5.lemmatized.sp > czeng20-$set.tail+25M.en.dict_constraints_suffix_skip_0.5.lemmatized.sp
tail -n +25000000 czeng20-$set.en.dict_constraints_suffix_skip_0.5.sp > czeng20-$set.tail+25M.en.dict_constraints_suffix_skip_0.5.stemmed.sp




done

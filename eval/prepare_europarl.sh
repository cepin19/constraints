export spm_dir=/home/big_maggie/usr/marian_cosmas/marian_1.9.0/marian-dev/build/
cd europarl
paste source.txt constraints.txt target.txt | shuf > src_const_trans.shuffled 
python get_valid_n.py  src_const_trans.shuffled 15000 > test_set.tabs
cut -f 1 test_set.tabs > test_set.src_tmp
cut -f 2 test_set.tabs > test_set.constraints_tmp
cut -f 3 test_set.tabs > test_set.tgt_tmp

bash ../../corp/lemmatize_cs.sh  test_set.constraints_tmp
bash ../../corp/lemmatize_cs.sh test_set.tgt_tmp
bash ../../corp/tokenize_cs.sh test_set.tgt_tmp
python ../find_correct_sfc_form_for_lemma.py test_set.constraints_tmp  test_set.constraints_tmp.lemmatized test_set.tgt_tmp.lemmatized  test_set.tgt_tmp.tokenized  test_set.tgt_tmp test_set.src_tmp > found_sfc

cut -f 1 found_sfc > test_set.src
cut -f 2 found_sfc > test_set.tgt
cut -f 3 found_sfc > test_set.constraints
cut -f 4 found_sfc > test_set.constraints_lemm
cut -f 5 found_sfc > test_set.constraints_correct_sf



paste  test_set.src test_set.constraints | sed 's/\t/ <sep> /g' > test_set.src.constraint_suffix

python ../../corp/czech_stemmer.py light < test_set.constraints >test_set.constraints.stemmed
export spm_dir="/home/big_maggie/usr/marian_cosmas/marian_1.9.0/marian-dev/build/"
$spm_dir/spm_encode --model ../../corp/encs.model < test_set.src > test_set.src.sp
$spm_dir/spm_encode --model ../../corp/encs.model < test_set.constraints > test_set.constraints.sp
$spm_dir/spm_encode --model ../../corp/encs.model < test_set.constraints.lemmatized > test_set.constraints.lemmatized.sp
$spm_dir/spm_encode --model ../../corp/encs.model < test_set.constraints.stemmed > test_set.constraints.stemmed.sp
$spm_dir/spm_encode --model ../../corp/encs.model < test_set.constraints_correct_sf > test_set.constraints_correct_sf.sp

$spm_dir/spm_encode --model ../../corp/encs.model < test_set.tgt > test_set.tgt.sp
paste  test_set.src.sp test_set.constraints.sp | sed 's/\t/ ▁ <sep> /g' > test_set.src.constraint_suffix.sp

paste  test_set.src.sp test_set.constraints.lemmatized.sp | sed 's/\t/ ▁ <sep> /g' > test_set.src.constraint_suffix.lemmatized.sp
paste  test_set.src.sp test_set.constraints.stemmed.sp | sed 's/\t/ ▁ <sep> /g' > test_set.src.constraint_suffix.stemmed.sp
paste  test_set.src.sp test_set.constraints_correct_sf.sp | sed 's/\t/ ▁ <sep> /g' > test_set.src.constraint_suffix.correct_sf.sp


$spm_dir/spm_decode --model ../../corp/encs.model < test_set.constraints.sp > test_set.constraints.snt
 python ../find_different_surface_lemma_europarl.py test_set.src test_set.constraints  test_set.constraints_correct_sf test_set.tgt  > test_set_diff.tabs
cut -f1 test_set_diff.tabs > test_set_diff.src
cut -f2 test_set_diff.tabs > test_set_diff.tgt
cut -f3 test_set_diff.tabs > test_set_diff.constraints
cut -f4 test_set_diff.tabs > test_set_diff.constraints_correct_sf
paste  test_set_diff.src test_set_diff.constraints | sed 's/\t/ <sep> /g' > test_set_diff.src.constraint_suffix
paste  test_set_diff.src test_set_diff.constraints_correct_sf | sed 's/\t/ <sep> /g' > test_set_diff.src.constraint_correct_sf_suffix

 $spm_dir/spm_encode --model ../../corp/encs.model < test_set_diff.src > test_set_diff.src.sp
 $spm_dir/spm_encode --model ../../corp/encs.model < test_set_diff.tgt > test_set_diff.tgt.sp
 $spm_dir/spm_encode --model ../../corp/encs.model < test_set_diff.src.constraint_suffix > test_set_diff.src.constraint_suffix.sp
 $spm_dir/spm_encode --model ../../corp/encs.model < test_set_diff.src.constraint_correct_sf_suffix >test_set_diff.src.constraint_correct_sf_suffix.sp



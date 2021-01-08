export spm_dir=/home/big_maggie/usr/marian_cosmas/marian_1.9.0/marian-dev/build/
cd europarl
paste source.txt constraints.txt target.txt | shuf > src_const_trans.shuffled 
python ../get_valid_n.py  src_const_trans.shuffled 10 > test_set.tabs
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
cut -f 4 found_sfc > test_set.constraints.lemmatized
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
ln -s test_set.src.constraint_suffix.correct_sf.sp test_set.src.constraint_correct_sf_suffix.sp
ln -s test_set.src.constraint_suffix.lemmatized.sp test_set.src.constraint_lemmatized_suffix.sp

$spm_dir/spm_decode --model ../../corp/encs.model < test_set.constraints.sp > test_set.constraints.snt
 python ../find_different_surface_lemma_europarl.py test_set.src test_set.constraints  test_set.constraints_correct_sf test_set.tgt  > test_set_diff.tabs
 python ../find_same_surface_lemma_europarl.py test_set.src test_set.constraints  test_set.constraints_correct_sf test_set.tgt  > test_set_same.tabs

cut -f1 test_set_diff.tabs > test_set_diff.src
cut -f2 test_set_diff.tabs > test_set_diff.tgt
cut -f3 test_set_diff.tabs > test_set_diff.constraints
cut -f4 test_set_diff.tabs > test_set_diff.constraints_correct_sf
bash ../../corp/lemmatize_cs.sh test_set_diff.constraints
paste  test_set_diff.src test_set_diff.constraints | sed 's/\t/ <sep> /g' > test_set_diff.src.constraint_suffix
paste  test_set_diff.src test_set_diff.constraints_correct_sf | sed 's/\t/ <sep> /g' > test_set_diff.src.constraint_correct_sf_suffix
paste  test_set_diff.src test_set_diff.constraints.lemmatized | sed 's/\t/ <sep> /g' > test_set_diff.src.constraint_lemmatized_suffix

 $spm_dir/spm_encode --model ../../corp/encs.model < test_set_diff.src > test_set_diff.src.sp
 $spm_dir/spm_encode --model ../../corp/encs.model < test_set_diff.tgt > test_set_diff.tgt.sp
 $spm_dir/spm_encode --model ../../corp/encs.model < test_set_diff.src.constraint_suffix > test_set_diff.src.constraint_suffix.sp
 $spm_dir/spm_encode --model ../../corp/encs.model < test_set_diff.src.constraint_correct_sf_suffix >test_set_diff.src.constraint_correct_sf_suffix.sp
 $spm_dir/spm_encode --model ../../corp/encs.model < test_set_diff.src.constraint_lemmatized_suffix > test_set_diff.src.constraint_lemmatized_suffix.sp

cut -f1 test_set_same.tabs > test_set_same.src
cut -f2 test_set_same.tabs > test_set_same.tgt
cut -f3 test_set_same.tabs > test_set_same.constraints
cut -f4 test_set_same.tabs > test_set_same.constraints_correct_sf
bash ../../corp/lemmatize_cs.sh test_set_same.constraints
paste  test_set_same.src test_set_same.constraints | sed 's/\t/ <sep> /g' > test_set_same.src.constraint_suffix
paste  test_set_same.src test_set_same.constraints_correct_sf | sed 's/\t/ <sep> /g' > test_set_same.src.constraint_correct_sf_suffix
paste  test_set_same.src test_set_same.constraints.lemmatized | sed 's/\t/ <sep> /g' > test_set_same.src.constraint_lemmatized_suffix

 $spm_dir/spm_encode --model ../../corp/encs.model < test_set_same.src > test_set_same.src.sp
 $spm_dir/spm_encode --model ../../corp/encs.model < test_set_same.tgt > test_set_same.tgt.sp
 $spm_dir/spm_encode --model ../../corp/encs.model < test_set_same.src.constraint_suffix > test_set_same.src.constraint_suffix.sp
 $spm_dir/spm_encode --model ../../corp/encs.model < test_set_same.src.constraint_correct_sf_suffix >test_set_same.src.constraint_correct_sf_suffix.sp
 $spm_dir/spm_encode --model ../../corp/encs.model < test_set_same.src.constraint_lemmatized_suffix > test_set_same.src.constraint_lemmatized_suffix.sp

for suff in "_same" "_diff" ""
do
paste test_set"$suff".src.sp test_set"$suff".tgt.sp > test_set"$suff"_const.sp.tabs
bash ../../corp/lemmatize_en.sh test_set"$suff".src
bash ../../corp/lemmatize_cs.sh test_set"$suff".tgt
 $spm_dir/spm_encode --model ../../corp/encs.model < test_set"$suff".src.lemmatized > test_set"$suff".src.lemmatized.sp
 $spm_dir/spm_encode --model ../../corp/encs.model < test_set"$suff".tgt.lemmatized > test_set"$suff".tgt.lemmatized.sp

paste test_set"$suff".src.lemmatized.sp test_set"$suff".tgt.lemmatized.sp > test_set"$suff"_const_lemm.sp.tabs


python ../../corp/add_factors.py  ../../lexD1reknc.cs-en.tabs.sp ../../corp/lexD1reknc.cs-en.lemmatized.tabs.sp  test_set"$suff"_const.sp.tabs test_set"$suff"_const_lemm.sp.tabs  test_set"$suff"_dict 0.0
paste test_set"$suff".src.constraint_correct_sf_suffix.sp  test_set"$suff"_dict.constraints_skip_prob0.0 | sed 's/\t/ ▁ <c> /g' > test_set"$suff".src.constraint_dict+correct_sf_suffix.sp 
paste test_set"$suff".src.constraint_lemmatized_suffix.sp test_set"$suff"_dict.constraints_skip_prob0.0_lemmatized | sed 's/\t/ ▁ <c> /g' > test_set"$suff".src.constraint_dict+lemmatized_suffix.sp
paste test_set"$suff".src.sp test_set"$suff"_dict.constraints_skip_prob0.0 | sed 's/\t/ ▁ <sep> /g' > test_set"$suff".src.constraint_dict.sp
paste test_set"$suff".src.sp test_set"$suff"_dict.constraints_skip_prob0.0_lemmatized | sed 's/\t/ ▁ <sep> /g' > test_set"$suff".src.constraint_dict_lemmatized.sp

done



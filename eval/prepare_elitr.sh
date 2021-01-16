export spm_dir=/home/big_maggie/usr/marian_cosmas/marian_1.9.0/marian-dev/build/
cd elitr

paste  kufre.src kufre.constraints | sed 's/\t/ <sep> /g' > kufre.src.constraint_suffix
ln -s kufre.constraints kufre.constraints_correct_sf


bash ../../corp/lemmatize_cs.sh  kufre.constraints
bash ../../corp/lemmatize_cs.sh kufre.tgt
bash ../../corp/tokenize_cs.sh kufre.tgt

$spm_dir/spm_encode --model ../../corp/encs.model < kufre.src > kufre.src.sp
$spm_dir/spm_encode --model ../../corp/encs.model < kufre.constraints > kufre.constraints.sp
$spm_dir/spm_encode --model ../../corp/encs.model < kufre.constraints.lemmatized > kufre.constraints.lemmatized.sp
$spm_dir/spm_encode --model ../../corp/encs.model < kufre.constraints_correct_sf > kufre.constraints_correct_sf.sp

$spm_dir/spm_encode --model ../../corp/encs.model < kufre.tgt > kufre.tgt.sp
paste  kufre.src.sp kufre.constraints.sp | sed 's/\t/ ▁ <sep> /g' > kufre.src.constraint_suffix.sp

paste  kufre.src.sp kufre.constraints.lemmatized.sp | sed 's/\t/ ▁ <sep> /g' > kufre.src.constraint_suffix.lemmatized.sp
paste  kufre.src.sp kufre.constraints_correct_sf.sp | sed 's/\t/ ▁ <sep> /g' > kufre.src.constraint_suffix.correct_sf.sp
ln -s kufre.src.constraint_suffix.correct_sf.sp kufre.src.constraint_correct_sf_suffix.sp
ln -s kufre.src.constraint_suffix.lemmatized.sp kufre.src.constraint_lemmatized_suffix.sp

$spm_dir/spm_decode --model ../../corp/encs.model < kufre.constraints.sp > kufre.constraints.snt

suff=""
paste kufre"$suff".src.sp kufre"$suff".tgt.sp > kufre"$suff"_const.sp.tabs
bash ../../corp/lemmatize_en.sh kufre"$suff".src
bash ../../corp/lemmatize_cs.sh kufre"$suff".tgt
 $spm_dir/spm_encode --model ../../corp/encs.model < kufre"$suff".src.lemmatized > kufre"$suff".src.lemmatized.sp
 $spm_dir/spm_encode --model ../../corp/encs.model < kufre"$suff".tgt.lemmatized > kufre"$suff".tgt.lemmatized.sp

paste kufre"$suff".src.lemmatized.sp kufre"$suff".tgt.lemmatized.sp > kufre"$suff"_const_lemm.sp.tabs



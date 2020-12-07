#!/bin/bash

# split to parallelize lemmatization, each lemmatizer only uses single core

proc=32
set -e
#for lang in "en" "cs"
#do
#	for part in "train" "csmono"
#	do
#	split -d -n l/32 czeng20-$part.$lang.snt parts/czeng20-$part.$lang.snt.part
#	ls -1 czeng20-$part.$lang.snt.part{00..31} | parallel -j $proc ./lemmatize_$lang.sh {}
#	cat parts/czeng20-$part.sentence.$lang.snt.part*.lemmatized  > czeng20-$part.$lang.snt.lemmatized
#	done
#done

#lemmatize dictionary
cut -f1 ../lexD1reknc.cs-en.tabs > lexD1reknc.cs-en.en
cut -f2 ../lexD1reknc.cs-en.tabs > lexD1reknc.cs-en.cs
./lemmatize_en.sh lexD1reknc.cs-en.en &
./lemmatize_cs.sh lexD1reknc.cs-en.cs &

./lemmatize_cs.sh news19.cs.snt &
./lemmatize_en.sh news19.en.snt &
wait

$spm_dir/spm_encode --model encs.model < news19.en.snt.lemmatized > news19.en.sp.lemmatized
$spm_dir/spm_encode --model encs.model < news19.cs.snt.lemmatized > news19.cs.sp.lemmatized
paste news19.en.sp.lemmatized news19.en.sp.lemmatized > news19.lemmatized.tabs.sp


$spm_dir/spm_encode --model encs.model < lexD1reknc.cs-en.en.lemmatized  > lexD1reknc.cs-en.en.lemmatized.sp
$spm_dir/spm_encode --model encs.model < lexD1reknc.cs-en.cs.lemmatized > lexD1reknc.cs-en.cs.lemmatized.sp

paste lexD1reknc.cs-en.en.lemmatized.sp lexD1reknc.cs-en.cs.lemmatized.sp  >  lexD1reknc.cs-en.lemmatized.tabs.sp



$spm_dir/spm_encode --model encs.model < czeng20-train.en.snt.lemmatized > czeng20-train.en.sp.lemmatized
$spm_dir/spm_encode --model encs.model < czeng20-train.cs.snt.lemmatized > czeng20-train.cs.sp.lemmatized
$spm_dir/spm_encode --model encs.model < czeng20-csmono.en.snt.lemmatized > czeng20-csmono.en.sp.lemmatized
$spm_dir/spm_encode --model encs.model < czeng20-csmono.cs.snt.lemmatized > czeng20-csmono.cs.sp.lemmatized


paste czeng20-train.en.sp.lemmatized czeng20-train.cs.sp.lemmatized > czeng20-train.lemmatized.tabs.sp
paste czeng20-csmono.en.sp.lemmatized czeng20-csmono.cs.sp.lemmatized > czeng20-csmono.lemmatized.tabs.sp


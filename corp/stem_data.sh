#!/bin/bash



#stem dictionary
cut -f1 ../lexD1reknc.cs-en.tabs > lexD1reknc.cs-en.en
cut -f2 ../lexD1reknc.cs-en.tabs > lexD1reknc.cs-en.cs
python english_stemmer.py  < lexD1reknc.cs-en.en > lexD1reknc.cs-en.en.stemmed
python czech_stemmer.py light < lexD1reknc.cs-en.cs > lexD1reknc.cs-en.cs.stemmed
$spm_dir/spm_encode --model encs.model < lexD1reknc.cs-en.en.stemmed > lexD1reknc.cs-en.en.stemmed.sp
$spm_dir/spm_encode --model encs.model < lexD1reknc.cs-en.cs.stemmed > lexD1reknc.cs-en.cs.stemmed.sp



paste lexD1reknc.cs-en.en.stemmed.sp lexD1reknc.cs-en.cs.stemmed.sp  >  lexD1reknc.cs-en.stemmed.tabs.sp
python english_stemmer.py  < czeng20-train.en.snt > czeng20-train.en.snt.stemmed
python english_stemmer.py  < czeng20-csmono.en.snt >czeng20-csmono.en.snt.stemmed 
python czech_stemmer.py light  < czeng20-train.cs.snt > czeng20-train.cs.snt.stemmed
python czech_stemmer.py  light < czeng20-csmono.cs.snt >czeng20-csmono.cs.snt.stemmed






$spm_dir/spm_encode --model encs.model < czeng20-train.en.snt.stemmed > czeng20-train.en.sp.stemmed
$spm_dir/spm_encode --model encs.model < czeng20-train.cs.snt.stemmed > czeng20-train.cs.sp.stemmed
$spm_dir/spm_encode --model encs.model < czeng20-csmono.en.snt.stemmed > czeng20-csmono.en.sp.stemmed
$spm_dir/spm_encode --model encs.model < czeng20-csmono.cs.snt.stemmed > czeng20-csmono.cs.sp.stemmed


paste czeng20-train.en.sp.stemmed czeng20-train.cs.sp.stemmed > czeng20-train.stemmed.tabs.sp
paste czeng20-csmono.en.sp.stemmed czeng20-csmono.cs.sp.stemmed > czeng20-csmono.stemmed.tabs.sp
python czech_stemmer.py  light <  news19.cs.snt > news19.cs.snt.stemmed
python english_stemmer.py  light <  news19.en.snt > news19.en.snt.stemmed
$spm_dir/spm_encode --model encs.model <news19.en.snt.stemmed> news19.en.sp.stemmed
$spm_dir/spm_encode --model encs.model <news19.cs.snt.stemmed> news19.cs.sp.stemmed
paste news19.en.sp.stemmed news19.cs.sp.stemmed > news19.stemmed.tabs.sp

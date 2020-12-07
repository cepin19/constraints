# creates sp models, run before preprocess 

#train sentencepiece model
#cat czeng20-train.sentence.cs.snt czeng20-train.sentence.en.snt czeng20-csmono.sentence.cs.snt czeng20-csmono.sentence.en.snt | shuf > czeng.all.snt.shuf
#$spm_dir/spm_train --vocab_size 32000 --user_defined_symbols="<sep>,<c>" --input_sentence_size=20000000  --input czeng.all.snt.shuf --model_prefix encs

#$spm_dir/spm_encode --model encs.model < czeng20-train.cs.snt > czeng20-train.cs.sp &
#$spm_dir/spm_encode --model encs.model < czeng20-train.en.snt > czeng20-train.en.sp &
#$spm_dir/spm_encode --model encs.model < czeng20-csmono.en.snt > czeng20-csmono.en.sp &
#$spm_dir/spm_encode --model encs.model < czeng20-csmono.cs.snt > czeng20-csmono.cs.sp &

#paste czeng20-train.en.sp czeng20-train.cs.sp > czeng20-train.tabs.sp
#paste czeng20-csmono.en.sp czeng20-csmono.cs.sp > czeng20-csmono.tabs.sp

#cut -f1 lexD1reknc.cs-en.tabs > lexD1reknc.cs-en.en
#cut -f2 lexD1reknc.cs-en.tabs > lexD1reknc.cs-en.cs
#$spm_dir/spm_encode --model encs.model < lexD1reknc.cs-en.en > lexD1reknc.cs-en.en.sp
#$spm_dir/spm_encode --model encs.model < lexD1reknc.cs-en.en.sp > lexD1reknc.cs-en.en.sp
#paste lexD1reknc.cs-en.en.lemmatized.sp lexD1reknc.cs-en.cs.sp  >  lexD1reknc.cs-en.tabs.sp

#$spm_dir/spm_export_vocab --model encs.model > encs.vocab
#cat encs.vocab | python spvocab_to_yml.py  > encs.yml

$spm_dir/spm_encode --model encs.model < news19.en.snt > news19.en.sp
$spm_dir/spm_encode --model encs.model < news19.cs.snt > news19.cs.sp
for set in "csmono" "train"
do
	for lang in "cs" "en"
	do
        head -n 25000000 czeng20-$set.$lang.sp > czeng20-$set.head25M.$lang.sp
	tail -n +25000000 czeng20-$set.$lang.sp > czeng20-$set.tail+25M.$lang.sp
	done
done
paste news19.en.sp news19.cs.sp > news19.tabs.sp






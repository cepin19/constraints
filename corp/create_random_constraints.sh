#!/bin/sh
spm_dir=/home/big_maggie/usr/marian_cosmas/marian_1.9.0/marian-dev/build/
set -e
#paste czeng20-train.en.snt czeng20-train.cs.snt > czeng20-train.tabs.snt
#paste czeng20-csmono.en.snt czeng20-csmono.cs.snt > czeng20-csmono.tabs.snt


#cat czeng20-train.tabs.snt | python generate_random_constraints.py  czeng20-train.en &
#cat czeng20-csmono.tabs.snt | python generate_random_constraints.py  czeng20-csmono.en &
wait


# split to parallelize lemmatization, each lemmatizer only uses single core

proc=16
for part in "train" "csmono"
	do
#	split -d -n l/32 czeng20-$part.en.random_constraints parts/czeng20-$part.en.random_constraints.part
#	ls -1 parts/czeng20-$part.en.random_constraints.part{00..31} | parallel -j $proc ./lemmatize_cs.sh {}
#	cat parts/czeng20-$part.en.random_constraints.part*.lemmatized  > czeng20-$part.en.random_constraints.lemmatized
	python czech_stemmer.py light < czeng20-$part.en.random_constraints  > czeng20-$part.en.random_constraints.stemmed
done



wait

# concat train with lemmatized constraints
#paste czeng20-csmono.en.snt  czeng20-csmono.en.random_constraints.lemmatized | sed 's/\t/ <sep> /g' | sed 's/< c >/ <c> /g' | sed 's/< ce >/ <c> /g' > czeng20-csmono.en.random_constraints_suffix.lemmatized &
#paste czeng20-train.en.snt czeng20-train.en.random_constraints.lemmatized | sed 's/\t/ <sep> /g' | sed 's/< c >/ <c> /g' | sed 's/< ce >/ <c> /g' > czeng20-train.en.random_constraints_suffix.lemmatized &
wait
paste czeng20-csmono.en.snt  czeng20-csmono.en.random_constraints.stemmed | sed 's/\t/ <sep> /g' | sed 's/< c >/ <c> /g' | sed 's/< ce >/ <c> /g' > czeng20-csmono.en.random_constraints_suffix.stemmed &
paste czeng20-train.en.snt czeng20-train.en.random_constraints.stemmed | sed 's/\t/ <sep> /g' | sed 's/< c >/ <c> /g' | sed 's/< ce >/ <c> /g' > czeng20-train.en.random_constraints_suffix.stemmed &
wait

#$spm_dir/spm_encode --model encs.model < czeng20-train.en.random_constraints_suffix.lemmatized > czeng20-train.en.random_constraints_suffix.lemmatized.sp &
#$spm_dir/spm_encode --model encs.model < czeng20-csmono.en.random_constraints_suffix.lemmatized > czeng20-csmono.en.random_constraints_suffix.lemmatized.sp &
$spm_dir/spm_encode --model encs.model < czeng20-train.en.random_constraints_suffix.stemmed > czeng20-train.en.random_constraints_suffix.stemmed.sp &
$spm_dir/spm_encode --model encs.model < czeng20-csmono.en.random_constraints_suffix.stemmed > czeng20-csmono.en.random_constraints_suffix.stemmed.sp &


#$spm_dir/spm_encode --model encs.model < czeng20-train.en.random_constraints_suffix > czeng20-train.en.random_constraints_suffix.sp &
#$spm_dir/spm_encode --model encs.model < czeng20-csmono.en.random_constraints_suffix > czeng20-csmono.en.random_constraints_suffix.sp &
wait

for set in "csmono" "train"
do
        head -n 25000000 czeng20-$set.en.random_constraints_suffix.lemmatized.sp  > czeng20-$set.head25M.en.random_constraints_suffix.lemmatized.sp
        head -n 25000000 czeng20-$set.en.random_constraints_suffix.stemmed.sp  > czeng20-$set.head25M.en.random_constraints_suffix.stemmed.sp
	head -n 25000000 czeng20-$set.en.random_constraints_suffix.sp  > czeng20-$set.head25M.en.random_constraints_suffix.sp
	cat <(head -n 12500000 czeng20-$set.en.random_constraints_suffix.lemmatized.sp) <(head -n 25000000 czeng20-$set.en.random_constraints_suffix.sp| tail -n 12500000)  > czeng20-$set.head25M.en.random_constraints_suffix.halflemmatized.sp
	tail -n +25000000 czeng20-$set.en.random_constraints_suffix.lemmatized.sp > czeng20-$set.tail+25M.en.random_constraints_suffix.lemmatized.sp
	        tail -n +25000000 czeng20-$set.en.random_constraints_suffix.stemmed.sp > czeng20-$set.tail+25M.en.random_constraints_suffix.stemmed.sp
	tail -n +25000000  czeng20-$set.en.random_constraints_suffix.sp > czeng20-$set.tail+25M.en.random_constraints_suffix.sp
	cat <(tail -n +25000000  czeng20-$set.en.random_constraints_suffix.lemmatized.sp | head -n 12500000) <(tail -n +37500000 czeng20-$set.en.random_constraints_suffix.sp) > czeng20-$set.tail+25M.en.random_constraints_suffix.halflemmatized.sp

done


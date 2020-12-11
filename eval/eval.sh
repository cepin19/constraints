#set -e
spm_dir="/home/big_maggie/usr/marian_prometheus/marian_1.9.0/marian-dev/build/"

echo "model, test set, surface bleu, surface coverage, lemma bleu, lemma coverage, placement correlation" > all_results.csv
echo >> all_results.csv

src_vocab="../corp/encs.yml"
tgt_vocab="../corp/encs.yml"
#src_vocab="encs.new.sp.yml.src.fsv"
#tgt_vocab="encs.new.sp.yml.tgt.fsv"
for model in  models/*npz 
do
	echo >> all_results.csv
	echo $model
	full_model=$model
	model=`basename $model`
	for shift in "--shift-token-id 4" ""
	do
		for testset in  "news20.en.sp" "news20.en.suffix_constraints.sp" "news20.en.suffix_constraints_lemmatized.sp" "news20.en.suffix_constraints_stemmed.sp" "news20.en.constraint_suffix_empty.sp" #"news20.en.sp.factors" "news20.en.sp.factors.lemmatized" "news20.en.sp.factors.fake"
		do
		cat $testset | ../marian-constraints_prom/build/marian-decoder -v $src_vocab $tgt_vocab -m models/$model  $shift -d 0 1 2  --mini-batch 64 --max-length-crop --max-length 100 --max-length-factor 2 --maxi-batch-sort=src --maxi-batch=50 | $spm_dir/spm_decode --model ../corp/encs.model  > out/"$model"_"$testset".out
		cat out/"$model"_"$testset".out | bash lemm_preserve_newlines.sh > out/"$model"_"$testset".out.lemmatized
		python3 const_coverage_and_placement.py news20.encs.constraints_skip_prob0.0_tgt_only.snt.lemmatized out/"$model"_"$testset".out.lemmatized news20.cs.snt > out/"$model"_"$testset".lemma_const_coverage
		python3 const_coverage_and_placement.py news20.encs.constraints_skip_prob0.0_tgt_only.snt  out/"$model"_"$testset".out news20.cs.snt > out/"$model"_"$testset".surface_const_coverage
		cat out/"$model"_"$testset".out | python3 -m sacrebleu -t wmt20 -l en-cs >  out/"$model"_"$testset".surface_bleu
		cat out/"$model"_"$testset".out.lemmatized | python3 -m sacrebleu news20.cs.snt.lemmatized >   out/"$model"_"$testset".lemma_bleu
		echo -n "$full_model""$shift", "$testset", >> all_results.csv
		cat out/"$model"_"$testset".surface_bleu  | cut -f 3 -d ' ' | cut -f 1 -d ',' |  tr '\n' ' ' >> all_results.csv
		echo -n , >> all_results.csv
		tail -n 1 out/"$model"_"$testset".surface_const_coverage | tr '\n' ' ' >> all_results.csv
        	echo -n , >> all_results.csv
		cat out/"$model"_"$testset".lemma_bleu  | cut -f 3 -d ' ' | cut -f 1 -d ',' |  tr '\n' ' ' >> all_results.csv
		echo -n , >> all_results.csv
		tail -n 1 out/"$model"_"$testset".lemma_const_coverage |  tr '\n' ' '  >> all_results.csv
		echo -n , >> all_results.csv
	        tail -n 2 out/"$model"_"$testset".surface_const_coverage |head -n 1 | tr '\n' ' ' >> all_results.csv
		echo >> all_results.csv

done
	done
done

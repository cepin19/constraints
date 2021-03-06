#set -e
spm_dir="/home/big_maggie/usr/marian_prometheus/marian_1.9.0/marian-dev/build/"

echo "model, test set, surface bleu, surface coverage, lemma bleu, lemma coverage, placement correlation" > europarl_diff_results.csv
echo >> europarl_diff_results.csv

src_vocab="../corp/encs.yml"
tgt_vocab="../corp/encs.yml"
#src_vocab="encs.new.sp.yml.src.fsv"
#tgt_vocab="encs.new.sp.yml.tgt.fsv"
for model in  models/*npz 
do
	echo >> europarl_diff_results.csv
	echo $model
	full_model=$model
	model=`basename $model`
	for shift in "--shift-token-id 3" ""
	do
	for testset in "test_set_diff.src.constraint_suffix.sp" "test_set_diff.src.sp" "test_set_diff.src.constraint_correct_sf_suffix.sp" "test_set_diff.src.constraint_lemmatized_suffix.sp" "test_set_diff.src.constraint_dict+correct_sf_suffix.sp"	"test_set_diff.src.constraint_dict+lemmatized_suffix.sp" "test_set_diff.src.constraint_dict.sp" "test_set_diff.src.constraint_dict_lemmatized.sp"
	do
		cat europarl/$testset | ../marian-constraints_prom/build/marian-decoder -v $src_vocab $tgt_vocab -m models/$model  $shift -d 2 -n 0.6  --mini-batch 64 --max-length-crop --max-length 100 --max-length-factor 2 --maxi-batch-sort=src --maxi-batch=50 | $spm_dir/spm_decode --model ../corp/encs.model  > out/"$model""$shift"_"$testset".out
		cat out/"$model""$shift"_"$testset".out | bash lemm_preserve_newlines.sh > out/"$model""$shift"_"$testset".out.lemmatized
		python3 const_coverage_and_placement.py europarl/test_set_diff.constraints.lemmatized  out/"$model""$shift"_"$testset".out.lemmatized europarl/test_set_diff.tgt europarl/test_set_diff.src > out/"$model""$shift"_"$testset".lemma_const_coverage 2> out/"$model""$shift"_"$testset".not_covered_constraints_lemm
		python3 const_coverage_and_placement.py europarl/test_set_diff.constraints_correct_sf  out/"$model""$shift"_"$testset".out europarl/test_set_diff.tgt europarl/test_set_diff.src > out/"$model""$shift"_"$testset".surface_const_coverage 2> out/"$model""$shift"_"$testset".not_covered_constraints_sf

		cat out/"$model""$shift"_"$testset".out | python3 -m sacrebleu europarl/test_set_diff.tgt >  out/"$model""$shift"_"$testset".surface_bleu
		cat out/"$model""$shift"_"$testset".out.lemmatized | python3 -m sacrebleu europarl/test_set_diff.tgt.lemmatized >   out/"$model""$shift"_"$testset".lemma_bleu
		echo -n "$full_model""$shift", "$testset", >> europarl_diff_results.csv
		cat out/"$model""$shift"_"$testset".surface_bleu  | cut -f 3 -d ' ' | cut -f 1 -d ',' |  tr '\n' ' ' >> europarl_diff_results.csv
		echo -n , >> europarl_diff_results.csv
		tail -n 1 out/"$model""$shift"_"$testset".surface_const_coverage | tr '\n' ' ' >> europarl_diff_results.csv
        	echo -n , >> europarl_diff_results.csv
		cat out/"$model""$shift"_"$testset".lemma_bleu  | cut -f 3 -d ' ' | cut -f 1 -d ',' |  tr '\n' ' ' >> europarl_diff_results.csv
		echo -n , >> europarl_diff_results.csv
		tail -n 1 out/"$model""$shift"_"$testset".lemma_const_coverage |  tr '\n' ' '  >> europarl_diff_results.csv
		echo -n , >> europarl_diff_results.csv
	        tail -n 2 out/"$model""$shift"_"$testset".surface_const_coverage |head -n 1 | tr '\n' ' ' >> europarl_diff_results.csv
		echo >> europarl_diff_results.csv

done
	done
done

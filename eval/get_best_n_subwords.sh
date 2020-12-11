set -e 
spm_dir="/home/big_maggie/usr/marian_cosmas/marian_1.9.0/marian-dev/build/"
model="model_transformer_base_concat_noen.newvocab.npz.best-translation.npz"
vocab="encs.new.sp.yml"

#echo "n,constraints, surface bleu, surface coverage, lemma bleu, lemma coverage" > find_n_results.csv

#for n in {1..100..5}
#do

#	floatn=$(python -c "print($n/20.0)")
	floatn=0.5
	for constraints in " " " constraints_news20.sp.lemmatized.noc" "constraints_news20.sp.noc"

	do
	cat news20.en.sp  | ../marian-constraints/build/marian-decoder -v $vocab $vocab -m models/$model --negative-constraints $constraints --constraints-modify-scores --constraint-bonus $floatn  -d 0  --mini-batch 1 --max-length-crop --max-length 120 --maxi-batch-sort=src --maxi-batch=1 | $spm_dir/spm_decode --model encs.spm  > "$model"_"$constraints"_"$floatn".out
	cat "$model"_"$constraints"_"$floatn".out | bash lemm_preserve_newlines.sh > "$model"_"$constraints"_"$floatn".out.lemmatized
	python ../corp/const_coverage_and_placement.py news20.encs.constraints.snt.lemmatized  "$model"_"$constraints"_"$floatn".out.lemmatized ../corp/news20.cs.snt > "$model"_"$constraints"_"$floatn".lemma_const_coverage
	python ../corp/const_coverage_and_placement.py news20.encs.constraints.snt  "$model"_"$constraints"_"$floatn".out ../corp/news20.cs.snt > "$model"_"$constraints"_"$floatn".surface_const_coverage
	cat "$model"_"$constraints"_"$floatn".out | python -m sacrebleu -t wmt20 -l en-cs >  "$model"_"$constraints"_"$floatn".surface_bleu
	cat "$model"_"$constraints"_"$floatn".out.lemmatized | python -m sacrebleu news20.cs.snt.lemmatized >   "$model"_"$constraints"_"$floatn".lemma_bleu
	echo -n "$floatn", "$constraints", >> find_n_results.csv
	cat "$model"_"$constraints"_"$floatn".surface_bleu  | cut -f 3 -d ' ' | cut -f 1 -d ',' |  tr '\n' ' ' >> find_n_results.csv
	echo -n , >> find_n_results.csv
	tail -n 1 "$model"_"$constraints"_"$floatn".surface_const_coverage | tr '\n' ' ' >> find_n_results.csv
        echo -n , >> find_n_results.csv
	cat "$model"_"$constraints"_"$floatn".lemma_bleu  | cut -f 3 -d ' ' | cut -f 1 -d ',' |  tr '\n' ' ' >> find_n_results.csv
	echo -n , >> find_n_results.csv
	tail -n 1 "$model"_"$constraints"_"$floatn".lemma_const_coverage  >> find_n_results.csv
	        echo -n , >> find_n_results.csv
        tail -n 2 "$model"_"$constraints"_"$floatn".surface_const_coverage |head -n 1 | tr '\n' ' ' >> find_n_results.csv

	echo >> find_n_results.csv



	done
#done

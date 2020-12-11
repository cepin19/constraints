out="model_transformer_base_concat_random_constraint_suffix_shift.npz.best-translation.npz --shift-token-id 4_news20.en.sp.constraint_suffix.out"
python ../corp/const_coverage_and_placement.py news20.encs.constraints.snt  "$out" news20.cs.snt > placement_correct
python permute_constraints.py news20.encs.constraints.snt "$out" > "$out".permuted_constraints
python ../corp/const_coverage_and_placement.py news20.encs.constraints.snt  "$out".permuted_constraints  news20.cs.snt  > placement_permuted

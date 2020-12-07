dev="0 1 2 3"
for e in {2..25..5}
do
echo "Starting epoch $e for para1"
let i=e+1
let j=e+2
let k=e+3
let l=e+4


marian-dev/build/marian \
    --model model/model_transformer_base_concat.npz --type transformer  --task transformer-base \
    --train-sets   corp/czeng20-train.head25M.en.sp corp/czeng20-train.head25M.cs.sp\
    --max-length 100 \
    --vocabs corp/encs.yml corp/encs.yml \
    --dim-vocabs 32000 32000 \
    --mini-batch-fit -w 14800 --mini-batch 1000 --maxi-batch 1000 \
    --valid-freq 5000 --save-freq 5000 --disp-freq 500 \
    --valid-metrics ce-mean-words perplexity translation\
    --valid-sets corp/news19.en.sp corp/news19.cs.sp \
    --valid-script-path ./val.sh \
    --valid-translation-output data/valid.concat.output --quiet-translation \
    --beam-size 6 --normalize=0.6 \
    --valid-mini-batch 16 \
     --keep-best \
    --early-stopping 95 --cost-type=ce-mean-words \
    --log model/train_base_bt.log --valid-log data/valid.log \
    --enc-depth 6 --dec-depth 6 \
    --learn-rate 0.0003  --lr-decay-inv-sqrt 8000 --lr-report  --data-weighting corp/czeng20-train.head25M.adq_score  \
    --optimizer-params 0.9 0.98 1e-09 --clip-norm 5 \
    --devices $dev  --sync-sgd --seed 12345 --optimizer-delay 1\
	--exponential-smoothing --sqlite -T . -e $e --no-restore-corpus 

echo "Starting epoch $i for mono1"
marian-dev/build/marian \
    --model model/model_transformer_base_concat.npz --type transformer  --task transformer-base \
    --train-sets  corp/czeng20-csmono.head25M.en.sp corp/czeng20-csmono.head25M.cs.sp \
    --max-length 100 \
    --vocabs corp/encs.yml corp/encs.yml \
    --dim-vocabs 32000 32000 \
    --mini-batch-fit -w 14800 --mini-batch 1000 --maxi-batch 1000 \
    --valid-freq 5000 --save-freq 5000 --disp-freq 500 \
    --valid-metrics ce-mean-words perplexity translation\
    --valid-sets corp/news19.en.sp corp/news19.cs.sp \
    --valid-script-path ./val.sh \
    --valid-translation-output data/valid.concat.output --quiet-translation \
    --beam-size 6 --normalize=0.6 \
    --valid-mini-batch 16 \
     --keep-best \
    --early-stopping 95 --cost-type=ce-mean-words \
    --log model/train_base_bt.log --valid-log data/valid.log \
    --enc-depth 6 --dec-depth 6 \
    --learn-rate 0.0003 --lr-decay-inv-sqrt 8000 --lr-report  --data-weighting corp/czeng20-csmono.head25M.adq_score \
    --optimizer-params 0.9 0.98 1e-09 --clip-norm 5 \
    --devices $dev --sync-sgd --seed 12345 --optimizer-delay 1 \
        --exponential-smoothing --sqlite -T . -e $i --no-restore-corpus 


echo "Starting epoch $j for para2"

marian-dev/build/marian \
    --model model/model_transformer_base_concat.npz --type transformer  --task transformer-base \
    --train-sets  corp/czeng20-train.tail+25M.en.sp corp/czeng20-train.tail+25M.cs.sp \
    --max-length 100 \
    --vocabs corp/encs.yml corp/encs.yml \
    --dim-vocabs 32000 32000 \
    --mini-batch-fit -w 14800 --mini-batch 1000 --maxi-batch 1000 \
    --valid-freq 5000 --save-freq 5000 --disp-freq 500 \
    --valid-metrics ce-mean-words perplexity translation\
    --valid-sets corp/news19.en.sp corp/news19.cs.sp \
    --valid-script-path ./val.sh \
    --valid-translation-output data/valid.concat.output --quiet-translation \
    --beam-size 6 --normalize=0.6 \
    --valid-mini-batch 16 \
     --keep-best \
    --early-stopping 95 --cost-type=ce-mean-words \
    --log model/train_base_bt.log --valid-log data/valid.log \
    --enc-depth 6 --dec-depth 6 \
    --learn-rate 0.0003  --lr-decay-inv-sqrt 8000 --lr-report  --data-weighting corp/czeng20-train.tail+25Madq_score \
    --optimizer-params 0.9 0.98 1e-09 --clip-norm 5 \
    --devices $dev  --sync-sgd --seed 12345 --optimizer-delay 1\
        --exponential-smoothing --sqlite -T . -e $j --no-restore-corpus 

echo "Starting epoch $k for mono2"
marian-dev/build/marian \
    --model model/model_transformer_base_concat.npz --type transformer  --task transformer-base \
    --train-sets  corp/czeng20-csmono.tail+25M.en.sp corp/czeng20-csmono.tail+25M.cs.sp \
    --max-length 100 \
    --vocabs corp/encs.yml corp/encs.yml \
    --dim-vocabs 32000 32000 \
    --mini-batch-fit -w 14800 --mini-batch 1000 --maxi-batch 1000 \
    --valid-freq 5000 --save-freq 5000 --disp-freq 500 \
    --valid-metrics ce-mean-words perplexity translation\
    --valid-sets corp/news19.en.sp corp/news19.cs.sp \
    --valid-script-path ./val.sh \
    --valid-translation-output data/valid.concat.output --quiet-translation \
    --beam-size 6 --normalize=0.6 \
    --valid-mini-batch 16 \
     --keep-best \
    --early-stopping 95 --cost-type=ce-mean-words \
    --log model/train_base_bt.log --valid-log data/valid.log \
    --enc-depth 6 --dec-depth 6 \
    --learn-rate 0.0003  --lr-decay-inv-sqrt 8000 --lr-report  --data-weighting corp/czeng20-csmono.tail+25M.adq_score \
    --optimizer-params 0.9 0.98 1e-09 --clip-norm 5  \
    --devices $dev  --sync-sgd --seed 12345 --optimizer-delay 1\
        --exponential-smoothing --sqlite -T . -e $k --no-restore-corpus 


done 

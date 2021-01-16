model="/home/large/data/models/marian/constrained_beam/udpipe/czech-pdt-ud-2.5-191206.udpipe"
udpipe=/home/large/data/models/marian/constrained_beam/udpipe/udpipe-1.2.0-bin/bin-linux64
#/../udpipe/udpipe-1.2f.0-bin/bin-linux64/udpipe --output horizontal --input horizontal --tokenize  $model $2
cat $1 | "$udpipe"/udpipe  --input horizontal --output=horizontal --tokenizer=presegmented --immediate   $model    > $1.tokenized



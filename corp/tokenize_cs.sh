model="/home/large/data/models/marian/constrained_beam/udpipe/czech-pdt-ud-2.5-191206.udpipe"
udpipe=/home/large/data/models/marian/constrained_beam/udpipe/udpipe-1.2.0-bin/bin-linux64
#/../udpipe/udpipe-1.2f.0-bin/bin-linux64/udpipe --output horizontal --input horizontal --tokenize  $model $2
cat $1 | sed 's/^\s*$/#empty/g'  |"$udpipe"/udpipe --tagger=templates=lemmatizer --tag --input horizontal --tokenizer=presegmented --immediate   $model  | cut -f2 | grep -v ^\# | tr '\n' ' ' | sed 's/  /\n/g' | sed 's/^empt$//g' |sed 's/< c >/<c>/g' |sed 's/< ce >/<c>/g'   > $1.tokenized



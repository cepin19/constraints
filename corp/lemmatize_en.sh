model="/home/large/data/models/marian/constrained_beam/udpipe/english-ewt-ud-2.5-191206.udpipe"
udpipe="/home/large/data/models/marian/constrained_beam/udpipe/udpipe-1.2.0-bin/bin-linux64"

cat $1 | $udpipe/udpipe --tagger=templates=lemmatizer --tag --input horizontal --tokenizer=presegmented --immediate   $model  | cut -f3 | grep -v ^\# | tr '\n' ' ' | sed 's/  /\n/g'  > $1.lemmatized

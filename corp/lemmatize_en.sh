model="../../udpipe/english-ewt-ud-2.5-191206.udpipe"

cat $1 | ../../udpipe/udpipe-1.2.0-bin/bin-linux64/udpipe --tagger=templates=lemmatizer --tag --input horizontal --tokenizer=presegmented --immediate   $model  | cut -f3 | grep -v ^\# | tr '\n' ' ' | sed 's/  /\n/g'  > $1.lemmatized

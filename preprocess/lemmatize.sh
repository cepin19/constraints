#!/bin/bash

#. /home/aires/personal_work_troja/python_envs/fairseq-env/bin/activate

# Models to use.
lang=czech #english
model=/net/projects/udpipe/models/udpipe-ud-2.0-170801/$lang-ud-2.0-170801.udpipe

data=/home/aires/personal_work_troja/constrained_decoding/datasets/many-czech-references/constraint_split/*constraints.txt #1028_constraints.txt #en.txt

for f in $data;
do
	echo "Processing $f";
	/home/varis/bin/udpipe-1.2.0 \
	       	--input=horizontal --tokenize --tag \
		$model $f \
		| cut -f3 | grep -v ^\# | tr "\n" " " \
		| sed 's/  /\n/g' > $f.lemmatized;
done

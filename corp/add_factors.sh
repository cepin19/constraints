cd parts
for f in czeng.part{00..16}
do
	echo $f 
	python add_factors.py  ../../lexD1reknc.cs-en.tabs.sp ../../lexD1reknc.cs-en.lemmatized.tabs.sp  $f $f.lemmatized $f 0.3
done

"""Print n first occurences of each constraint in term db"""
import sys
i=0
count=int(sys.argv[2])
used={}
with open(sys.argv[1]) as f:
    for line in f:
        #these words are either noise, or too frequent and trivial
        if len(line.split('\t')[1])>4 and line.split('\t')[1] not in ["zasedání","region","usnesení","rozhodnutí", "doporučení", "zpravodaj", "fond", "Evropská unie", "Komise"]:
            if line.split('\t')[1] not in used:
                used[line.split('\t')[1]]=1
            else:
                used[line.split('\t')[1]]+=1
            if used[line.split('\t')[1]]<=count:
                print (line,end='')

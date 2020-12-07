import  sys,string,yaml
for i,line in enumerate(sys.stdin):
    word=line.split("\t")[0]
#    punct=True
#    word=word.replace("?","?").replace("'","\'")
#    for c in word:
#        if c in string.punctuation or c in string.whitespace:
#            punct=True
#        else:
#            #print(c)
#            punct=False
    if word in ["?",",","!",":","-","]","[","#"]:
        word='"'+word+'"'
    print(word+" : "+i)

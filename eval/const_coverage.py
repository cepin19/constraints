import sys
constraints_total=0
constraints_correct=0
with open(sys.argv[1]) as constraints, (open(sys.argv[2])) as translations:
    for line_constraints,line_tgt in zip(constraints,translations):
        const_list=line_constraints.split('▁<c>')#TODO: change to <c> with new constraints
        for constraint in const_list:
            if constraint.isspace():continue
            constraints_total+=1
            if constraint.strip().lower() in line_tgt.lower().strip():
#                print("found: "+constraint)
                constraints_correct+=1
print(constraints_correct)
print(constraints_total)
print(constraints_correct/float(constraints_total))


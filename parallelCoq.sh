#!/bin/bash

export NB_PROC=$(nproc)
TARGET_FILE=$1
RW_FOLDER=/tmp

# Copy hol-light and hol2dk to a RW folder
cp -r $HOL2DK_DIR $RW_FOLDER/hol2dk
cp -r $HOLLIGHT_DIR $RW_FOLDER/hol-light
export HOL2DK_DIR=$RW_FOLDER/hol2dk
export HOLLIGHT_DIR=$RW_FOLDER/hol-light

cd $HOLLIGHT_DIR
hol2dk dump-simp-before-hol $TARGET_FILE
mkdir -p $RW_FOLDER/output
cd $RW_FOLDER/output
hol2dk link $TARGET_FILE HOLLight_Real.HOLLight_Real --root-path $HOL2DK_DIR/HOLLight.v Rdefinitions Rbasic_fun Raxioms
time make split # 2>&1 | tee log_split_$TARGET_FILE.txt
time make -j250 lp # 2>&1 | tee log_lp_$TARGET_FILE.txt
time make -j250 v # 2>&1 | tee log_v_$TARGET_FILE.txt

#####################################################@@

cd $RW_FOLDER/output

LIST_OF_NODES=("marg001" "marg002")
echo ${LIST_OF_NODES[@]} > LIST_OF_NODES

SPEC_ABBREVS_FILES=$(find $PWD/output -type f \( -name '*_spec.v' -o -name '*_term_abbrevs*.v' \))
string=${SPEC_ABBREVS_FILES[@]}
string=$(echo "$string" | tr ' ' '\n' | sort | tr '\n' ' ')
IFS=' ' read -ra SPEC_ABBREVS_FILES <<< $string
NBRE_OF_NODES=${#LIST_OF_NODES[@]}
NBRE_OF_SPEC_ABBREVS_FILES=${#SPEC_ABBREVS_FILES[@]}

n=$NBRE_OF_SPEC_ABBREVS_FILES
m=$(expr $n / $NBRE_OF_NODES)

echo number of elements in SPEC_ABBREVS_FILES is $n
Echo the elementz in the list are :
for elem in "${SPEC_ABBREVS_FILES[@]}"; do
    echo "$elem"
done
echo number of nodes is $NBRE_OF_NODES
echo number of elements in sublists is $m
first=0
last=$(expr $m - 1)
for i in $(seq 1 $NBRE_OF_NODES)
do
    if [ $first -ge $n ]; then
        echo WARNING! no file left to assign to node N° $i
        break
    fi
    echo
    echo iteration $i
    # echo before progressing, first indice is $first and Last indice is $last
    string=${SPEC_ABBREVS_FILES[$last]}
    IFS="_" read -r firstPartLast part2 <<< "$string"
    # IFS="_abbrevs" read -r firstPartLast part2 <<< "$firstPartLast"
    string=${SPEC_ABBREVS_FILES[$(expr $last + 1)]}
    IFS="_" read -r firstPartLastPlus1 part2 <<< "$string"
    # IFS="_abbrevs" read -r firstPartLast part2 <<< "$firstPartLastPlus1"
    while  [ $last -lt $n -a "$firstPartLast" == "$firstPartLastPlus1" ]
    do
        # echo inside the while loop. Comparing $firstPartLast and $firstPartLastPlus1 . Different : proceed with next.
        last=$(expr $last + 1)

        string=${SPEC_ABBREVS_FILES[$last]}
        IFS="_" read -r firstPartLast part2 <<< "$string"
        # IFS="_abbrevs" read -r firstPartLast part2 <<< "$firstPartLast"
        string=${SPEC_ABBREVS_FILES[$(expr $last + 1)]}
        IFS="_" read -r firstPartLastPlus1 part2 <<< "$string"

    done
    # echo after progressing, first indice is $first and Last indice is $last
    # echo  $firstPartLast is different from $firstPartLastPlus1 or last element of the list reached : n=$n

    echo Elements between $first and $last are :
    echo "${SPEC_ABBREVS_FILES[@]:first:$(expr $last - $first + 1)}" | tee SPEC_ABBREVS_FILES.${LIST_OF_NODES[$(expr $i - 1)]}.done
    
    first=$(expr $last + 1)
    # If last node, assign all left files to it
    if [ $i -eq $(expr $NBRE_OF_NODES - 1) ]; then
        last=$n
    else
        last=$(expr $first + $m)
    fi
done
make spec_abbrevs.v


# list=("img_1.jpg" "img_2.jpg")
# echo $(IFS=' testMakeParal/' ; echo "${list[*]}")
# cp $(IFS=' testMakeParal/' ; echo "${list[*]}") ..
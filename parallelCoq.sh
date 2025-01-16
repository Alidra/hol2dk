#!/bin/bash

export NB_PROC=$(nproc)
export TARGET_FILE=$1 #hol_upto_arith.ml

# Copy hol-light and hol2dk to a RW folder
cp -rf $HOL2DK_DIR $RW_FOLDER/hol2dk
cp -rf $HOLLIGHT_DIR $RW_FOLDER/hol-light
export HOL2DK_DIR=$RW_FOLDER/hol2dk
export HOLLIGHT_DIR=$RW_FOLDER/hol-light

cp $HOL2DK_DIR/hol_lib_upto_arith.ml $HOL2DK_DIR/hol_upto_arith.ml $HOLLIGHT_DIR

cd $HOLLIGHT_DIR
hol2dk dump-simp-before-hol $TARGET_FILE
mkdir -p $RW_FOLDER/$OUTPUT_FOLDER_NAME
cd $RW_FOLDER/$OUTPUT_FOLDER_NAME
hol2dk link $TARGET_FILE HOLLight_Real.HOLLight_Real --root-path $HOL2DK_DIR/HOLLight.v Rdefinitions Rbasic_fun Raxioms
# hol2dk config $TARGET_FILE HOLLight Rdefinitions Rbasic_fun Raxioms HOLLight_Real.HOLLight_Real $HOL2DK_DIR/HOLLight.v
time make split # 2>&1 | tee log_split_$TARGET_FILE.txt
time make -j$NB_PROC lp # 2>&1 | tee log_lp_$TARGET_FILE.txt
time make -j$NB_PROC v # 2>&1 | tee log_v_$TARGET_FILE.txt

#####################################################@@ 

cd $RW_FOLDER/$OUTPUT_FOLDER_NAME

LIST_OF_NODES=("002" "004")
echo ${LIST_OF_NODES[@]} > LIST_OF_NODES

echo list of nodes is : ${LIST_OF_NODES[@]}

SPEC_ABBREVS_FILES=$(find $RW_FOLDER/$OUTPUT_FOLDER_NAME -type f \( -name '*_spec.v' -o -name '*_term_abbrevs*.v' \))
string=${SPEC_ABBREVS_FILES[@]}
string=$(echo "$string" | tr ' ' '\n' | sort | tr '\n' ' ')
IFS=' ' read -ra SPEC_ABBREVS_FILES <<< $string
NBRE_OF_NODES=${#LIST_OF_NODES[@]}
NBRE_OF_SPEC_ABBREVS_FILES=${#SPEC_ABBREVS_FILES[@]}

n=$NBRE_OF_SPEC_ABBREVS_FILES
m=$(expr $n / $NBRE_OF_NODES)

echo number of elements in SPEC_ABBREVS_FILES is $n

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

    # echo Elements between $first and $last are :
    listOfFiles="${SPEC_ABBREVS_FILES[@]:first:$(expr $last - $first + 1)}"
    string=$(echo "$listOfFiles" | tr ' ' '\n')
    l=$(echo string | wc -c)
    listFilesName=SPEC_ABBREVS_FILES.marg${LIST_OF_NODES[$(expr $i - 1)]}
    echo $listOfFiles > $listFilesName
    echo node $i will process  $l    files
    
    first=$(expr $last + 1)
    # If last node, assign all left files to it
    if [ $i -eq $(expr $NBRE_OF_NODES - 1) ]; then
        last=$n
    else
        last=$(expr $first + $m)
    fi
done
cp $HOL2DK_DIR/distributed.mk distributed.mk

make -j$NBRE_OF_NODES -f distributed.mk spec_abbrevs.v

# echo ******************* spec and abbrevs done
echo **************************Now doing other v files
echo *******************************Uncomment this : 6

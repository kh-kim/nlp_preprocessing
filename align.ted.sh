FN=$1
DICT_FN=./data/enko.dict

SRC_LANG=en
TGT_LANG=ko

if [ -f $FN-$SRC_LANG.txt ]
then
    if [ -f $FN-$TGT_LANG.txt ]
    then
        cat $FN-$SRC_LANG.txt | python ./combine_line.py | python refine.py regex.txt > ./tmp/tmp.src.txt
        python ./tokenizer.py < ./tmp/tmp.src.txt > ./tmp/tmp.src.tok.txt

        cat $FN-$TGT_LANG.txt | python ./combine_line.py | python refine.py regex.txt > ./tmp/tmp.tgt.txt
        mecab --input-buffer-size=30000 -O wakati < ./tmp/tmp.tgt.txt > ./tmp/tmp.tgt.tok.txt

        python align.py --src ./tmp/tmp.src.txt --tgt ./tmp/tmp.tgt.txt --dict $DICT_FN --src_ref ./tmp/tmp.src.tok.txt --tgt_ref ./tmp/tmp.tgt.tok.txt

        rm ./tmp/tmp.src.txt ./tmp/tmp.tgt.txt ./tmp/tmp.src.tok.txt ./tmp/tmp.tgt.tok.txt
    fi
fi

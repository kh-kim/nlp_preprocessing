cd ./data/

# extract each language
cat joongang_daily.txt | awk -F'\t' '{ print $2 }' > joongang_daily.en.txt
cat joongang_daily.txt | awk -F'\t' '{ print $3 }' > joongang_daily.ko.txt

# remove noise
python ../refine.py ../regex.txt < joongang_daily.en.txt > joongang_daily.en.refined.txt
python ../refine.py ../regex.txt < joongang_daily.ko.txt > joongang_daily.ko.refined.txt

# sentence tokenization
python ../line_separator.py < joongang_daily.en.refined.txt > joongang_daily.en.refined.sep.txt
python ../line_separator.py < joongang_daily.ko.refined.txt > joongang_daily.ko.refined.sep.txt

# remove noise
python ../refine.py ../regex.txt < ted.en.txt > ted.en.refined.txt
python ../refine.py ../regex.txt < ted.ko.txt > ted.ko.refined.txt

# sentence tokenization
python ../combine_line.py < ted.en.refined.txt > ted.en.refined.sep.txt
python ../combine_line.py < ted.ko.refined.txt > ted.ko.refined.sep.txt

# tokenization
python ../tokenizer.py < joongang_daily.en.refined.sep.txt > joongang_daily.en.refined.sep.tok.txt
mecab -O wakati < joongang_daily.ko.refined.sep.txt > joongang_daily.ko.refined.sep.tok.txt

python ../tokenizer.py < ted.en.refined.sep.txt > ted.en.refined.sep.tok.txt
mecab -O wakati --input-buffer-size=30000 < ted.ko.refined.sep.txt > ted.ko.refined.sep.tok.txt

# combine corpus of each language
cat ./joongang_daily.en.refined.sep.tok.txt ted.en.refined.sep.tok.txt > en.tok.txt
cat ./joongang_daily.ko.refined.sep.tok.txt ted.ko.refined.sep.tok.txt > ko.tok.txt

# get word embedding vectors based on corpus for each language
~/Workspace/nlp/fastText/fasttext skipgram -input ko.tok.txt -output ko.tok -dim 256 -epoch 100 -minCount 5
~/Workspace/nlp/fastText/fasttext skipgram -input en.tok.txt -output en.tok -dim 256 -epoch 100 -minCount 5

# get word translation model(dictionary) with word embeding vectors
rm -rf ~/Workspace/nlp/MUSE/dumped/debug/*
time python ~/Workspace/nlp/MUSE/supervised.py --src_lang en --tgt_lang ko --src_emb ./en.tok.vec --tgt_emb ./ko.tok.vec --n_refinement 5 --cuda False --emb_dim 256 --dico_train default
cp -f ~/Workspace/nlp/MUSE/dumped/debug/*/vectors-*.txt ./

# run champollion using dictionary
python ../word_mt.py -src vectors-en.txt -tgt vectors-ko.txt -dict enko.dict -k 3 -thres .4
wc -l ./enko.dict

cd ../

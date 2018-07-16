cd ./data/

# extract each language
cat news.txt | awk -F'\t' '{ print $2 }' > news.en.txt
cat news.txt | awk -F'\t' '{ print $3 }' > news.ko.txt

cat ./ted/*-en.txt > ted.en.txt
cat ./ted/*-ko.txt > ted.ko.txt

# remove noise
python ../refine.py ../regex.txt < news.en.txt > news.en.refined.txt
python ../refine.py ../regex.txt < news.ko.txt > news.ko.refined.txt

python ../refine.py ../regex.txt < ted.en.txt > ted.en.refined.txt
python ../refine.py ../regex.txt < ted.ko.txt > ted.ko.refined.txt

# sentence tokenization
python ../line_separator.py < news.en.refined.txt > news.en.refined.sep.txt
python ../line_separator.py < news.ko.refined.txt > news.ko.refined.sep.txt

python ../combine_line.py < ted.en.refined.txt > ted.en.refined.sep.txt
python ../combine_line.py < ted.ko.refined.txt > ted.ko.refined.sep.txt

# tokenization
python ../tokenizer.py < news.en.refined.sep.txt > news.en.refined.sep.tok.txt
mecab -O wakati < news.ko.refined.sep.txt > news.ko.refined.sep.tok.txt

python ../tokenizer.py < ted.en.refined.sep.txt > ted.en.refined.sep.tok.txt
mecab -O wakati --input-buffer-size=30000 < ted.ko.refined.sep.txt > ted.ko.refined.sep.tok.txt

# combine corpus of each language
cat ./news.en.refined.sep.tok.txt ted.en.refined.sep.tok.txt > en.tok.txt
cat ./news.ko.refined.sep.tok.txt ted.ko.refined.sep.tok.txt > ko.tok.txt

# get word embedding vectors based on corpus for each language
~/Workspace/nlp/fastText/fasttext skipgram -input ko.tok.txt -output ko.tok -dim 256 -epoch 100 -minCount 5
~/Workspace/nlp/fastText/fasttext skipgram -input en.tok.txt -output en.tok -dim 256 -epoch 100 -minCount 5

# get modified word vectors for each language
rm -rf ~/Workspace/nlp/MUSE/dumped/debug/*
time python ~/Workspace/nlp/MUSE/supervised.py --src_lang en --tgt_lang ko --src_emb ./en.tok.vec --tgt_emb ./ko.tok.vec --n_refinement 5 --cuda False --emb_dim 256 --dico_train default
cp -f ~/Workspace/nlp/MUSE/dumped/debug/*/vectors-*.txt ./

# build word translation dictionary based on modified word vectors using cosine similarity
python ../word_mt.py -src vectors-en.txt -tgt vectors-ko.txt -dict enko.auto.dict -k 3 -thres .4
wc -l ./enko.auto.dict

cat enko.prev.dict enko.auto.dict | sort | uniq > enko.dict
wc -l ./enko.dict

cd ../

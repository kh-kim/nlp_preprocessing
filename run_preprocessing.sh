cd ./data/

# extract each language
cat joongang_daily.aligned.txt | awk -F'\t' '{ print $1 }' > joongang_daily.aligned.en.txt
cat joongang_daily.aligned.txt | awk -F'\t' '{ print $2 }' > joongang_daily.aligned.ko.txt

cat ted.aligned.txt | awk -F'\t' '{ print $1 }' > ted.aligned.en.txt
cat ted.aligned.txt | awk -F'\t' '{ print $2 }' > ted.aligned.ko.txt

# remove noise
python ../refine.py ../regex.txt < joongang_daily.aligned.en.txt > joongang_daily.aligned.en.refined.txt
python ../refine.py ../regex.txt < joongang_daily.aligned.ko.txt > joongang_daily.aligned.ko.refined.txt

python ../refine.py ../regex.txt < ted.aligned.en.txt > ted.aligned.en.refined.txt
python ../refine.py ../regex.txt < ted.aligned.ko.txt > ted.aligned.ko.refined.txt

# we can skip the sentence tokenization process, because it is already done in sentence aligning process.
# tokenization
python ../tokenizer.py < joongang_daily.aligned.en.refined.txt | python ../post_tokenize.py joongang_daily.aligned.en.refined.txt > joongang_daily.aligned.en.refined.tok.txt
mecab -O wakati --input-buffer-size=30000 < joongang_daily.aligned.ko.refined.txt | python ../post_tokenize.py joongang_daily.aligned.ko.refined.txt > joongang_daily.aligned.ko.refined.tok.txt

python ../tokenizer.py < ted.aligned.en.refined.txt | python ../post_tokenize.py ted.aligned.en.refined.txt > ted.aligned.en.refined.tok.txt
mecab -O wakati --input-buffer-size=30000 < ted.aligned.ko.refined.txt | python ../post_tokenize.py ted.aligned.ko.refined.txt > ted.aligned.ko.refined.tok.txt

# combine result for each language
#cat joongang_daily.aligned.en.refined.tok.txt ted.aligned.en.refined.tok.txt > aligned.en.refined.tok.txt
#cat joongang_daily.aligned.ko.refined.tok.txt ted.aligned.ko.refined.tok.txt > aligned.ko.refined.tok.txt

# learn subword model
cat joongang_daily.aligned.en.refined.tok.txt joongang_daily.aligned.ko.refined.tok.txt ted.aligned.en.refined.tok.txt ted.aligned.ko.refined.tok.txt | python ~/Workspace/nlp/subword-nmt/learn_bpe.py -s 32000 > ./bpe.model

# apply subword segmentation
python ~/Workspace/nlp/subword-nmt/apply_bpe.py -c ./bpe.model < joongang_daily.aligned.en.refined.tok.txt > joongang_daily.aligned.en.refined.tok.bpe.txt
python ~/Workspace/nlp/subword-nmt/apply_bpe.py -c ./bpe.model < joongang_daily.aligned.ko.refined.tok.txt > joongang_daily.aligned.ko.refined.tok.bpe.txt

python ~/Workspace/nlp/subword-nmt/apply_bpe.py -c ./bpe.model < ted.aligned.en.refined.tok.txt > ted.aligned.en.refined.tok.bpe.txt
python ~/Workspace/nlp/subword-nmt/apply_bpe.py -c ./bpe.model < ted.aligned.ko.refined.tok.txt > ted.aligned.ko.refined.tok.bpe.txt

# detoknization
python ../detokenizer.py < joongang_daily.aligned.en.refined.tok.bpe.txt > joongang_daily.aligned.en.refined.tok.bpe.detok.txt
python ../detokenizer.py < joongang_daily.aligned.ko.refined.tok.bpe.txt > joongang_daily.aligned.ko.refined.tok.bpe.detok.txt

python ../detokenizer.py < ted.aligned.en.refined.tok.bpe.txt > ted.aligned.en.refined.tok.bpe.detok.txt
python ../detokenizer.py < ted.aligned.ko.refined.tok.bpe.txt > ted.aligned.ko.refined.tok.bpe.detok.txt

# combine result
cat ./joongang_daily.aligned.en.refined.tok.bpe.txt ted.aligned.en.refined.tok.bpe.txt > aligned.en.refined.tok.bpe.txt
cat ./joongang_daily.aligned.ko.refined.tok.bpe.txt ted.aligned.ko.refined.tok.bpe.txt > aligned.ko.refined.tok.bpe.txt

cd ../

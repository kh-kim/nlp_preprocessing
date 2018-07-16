cd ./data/

# extract each language
cat news.aligned.txt | awk -F'\t' '{ print $1 }' > news.aligned.en.txt
cat news.aligned.txt | awk -F'\t' '{ print $2 }' > news.aligned.ko.txt

cat ted.aligned.txt | awk -F'\t' '{ print $1 }' > ted.aligned.en.txt
cat ted.aligned.txt | awk -F'\t' '{ print $2 }' > ted.aligned.ko.txt

# remove noise
python ../refine.py ../regex.txt < news.aligned.en.txt > news.aligned.en.refined.txt
python ../refine.py ../regex.txt < news.aligned.ko.txt > news.aligned.ko.refined.txt

python ../refine.py ../regex.txt < ted.aligned.en.txt > ted.aligned.en.refined.txt
python ../refine.py ../regex.txt < ted.aligned.ko.txt > ted.aligned.ko.refined.txt

# we can skip the sentence tokenization process, because it is already done in sentence aligning process.
# tokenization
python ../tokenizer.py < news.aligned.en.refined.txt | python ../post_tokenize.py news.aligned.en.refined.txt > news.aligned.en.refined.tok.txt
mecab -O wakati --input-buffer-size=30000 < news.aligned.ko.refined.txt | python ../post_tokenize.py news.aligned.ko.refined.txt > news.aligned.ko.refined.tok.txt

python ../tokenizer.py < ted.aligned.en.refined.txt | python ../post_tokenize.py ted.aligned.en.refined.txt > ted.aligned.en.refined.tok.txt
mecab -O wakati --input-buffer-size=30000 < ted.aligned.ko.refined.txt | python ../post_tokenize.py ted.aligned.ko.refined.txt > ted.aligned.ko.refined.tok.txt

# combine result for each language
#cat news.aligned.en.refined.tok.txt ted.aligned.en.refined.tok.txt > aligned.en.refined.tok.txt
#cat news.aligned.ko.refined.tok.txt ted.aligned.ko.refined.tok.txt > aligned.ko.refined.tok.txt

# learn subword model
cat news.aligned.en.refined.tok.txt news.aligned.ko.refined.tok.txt ted.aligned.en.refined.tok.txt ted.aligned.ko.refined.tok.txt | python ~/Workspace/nlp/subword-nmt/learn_bpe.py -s 32000 > ./bpe.model

# apply subword segmentation
python ~/Workspace/nlp/subword-nmt/apply_bpe.py -c ./bpe.model < news.aligned.en.refined.tok.txt > news.aligned.en.refined.tok.bpe.txt
python ~/Workspace/nlp/subword-nmt/apply_bpe.py -c ./bpe.model < news.aligned.ko.refined.tok.txt > news.aligned.ko.refined.tok.bpe.txt

python ~/Workspace/nlp/subword-nmt/apply_bpe.py -c ./bpe.model < ted.aligned.en.refined.tok.txt > ted.aligned.en.refined.tok.bpe.txt
python ~/Workspace/nlp/subword-nmt/apply_bpe.py -c ./bpe.model < ted.aligned.ko.refined.tok.txt > ted.aligned.ko.refined.tok.bpe.txt

# detoknization
python ../detokenizer.py < news.aligned.en.refined.tok.bpe.txt > news.aligned.en.refined.tok.bpe.detok.txt
python ../detokenizer.py < news.aligned.ko.refined.tok.bpe.txt > news.aligned.ko.refined.tok.bpe.detok.txt

python ../detokenizer.py < ted.aligned.en.refined.tok.bpe.txt > ted.aligned.en.refined.tok.bpe.detok.txt
python ../detokenizer.py < ted.aligned.ko.refined.tok.bpe.txt > ted.aligned.ko.refined.tok.bpe.detok.txt

# combine result
cat ./news.aligned.en.refined.tok.bpe.txt ted.aligned.en.refined.tok.bpe.txt > aligned.en.refined.tok.bpe.txt
cat ./news.aligned.ko.refined.tok.bpe.txt ted.aligned.ko.refined.tok.bpe.txt > aligned.ko.refined.tok.bpe.txt

cd ../

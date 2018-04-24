cd ./data/

# concat all corpora from clien
cat ./clien/cm_*.txt > ./clien.txt

# extract title column and category column
cat clien.txt | awk -F'\t' '{ print $4 }' > clien.title.txt
cat clien.txt | awk -F'\t' '{ print $1 }' > clien.cat.txt

# remove noise
python ../refine.py ../regex.txt < ./clien.title.txt > clien.title.refined.txt 

# Since title consists 1 sentence, we can skip sentence tokenization
# word tokenization
cat ./clien.title.refined.txt | mecab -O wakati --input-buffer-size=100000 | python ../post_tokenize.py ./clien.title.refined.txt > clien.title.refined.tok.txt 

# learn bpe model based on title corpus
# note that you need to learn bpe model everytime when you use different corpus, because bpe algorithm works based on counting in corpus
cat ./clien.title.refined.tok.txt | python ~/Workspace/nlp/subword-nmt/learn_bpe.py -s 32000 > ./bpe.model 

# apply trained bpe
python ~/Workspace/nlp/subword-nmt/apply_bpe.py -c ./bpe.model < ./clien.title.refined.tok.txt > ./clien.title.refined.tok.bpe.txt 

# paste category column and preproessed title column
paste ./clien.cat.txt ./clien.title.refined.tok.bpe.txt > clien.cat_title.txt

cd ../

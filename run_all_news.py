import sys, os, fileinput

DIR_PATH = './tmp/'
TMP_SRC_FN = DIR_PATH + 'news-en'
TMP_TGT_FN = DIR_PATH + 'news-ko'
DICT_FN = './data/enko.dict'
OUTPUT_FN = './data/news.aligned.txt'

if __name__ == "__main__":
    if not os.path.exists(DIR_PATH):
        os.mkdir(DIR_PATH)

    for line in fileinput.input():
        parts = line.strip().split('\t')

        if len(parts) < 3:
            continue

        parts[1] = parts[1].split('JoongAng Ilbo')[0]
        if parts[2].endswith("기자") or parts[2].endswith("위원"):
            parts[2] = (parts[2].split('.')[0]) if '.' in parts[2] else ''

        f = open(TMP_SRC_FN + ".txt", 'w')
        f.write(parts[1].strip())
        f.close()

        f = open(TMP_TGT_FN + ".txt", 'w')
        f.write(parts[2].strip())
        f.close()

        os.system("cat %s.txt | python ./line_separator.py > %s.sep.txt" % (TMP_SRC_FN, TMP_SRC_FN))
        os.system("cat %s.txt | python ./line_separator.py > %s.sep.txt" % (TMP_TGT_FN, TMP_TGT_FN))

        os.system("python ./tokenizer.py < %s.sep.txt > %s.sep.tok.txt" % (TMP_SRC_FN, TMP_SRC_FN))
        os.system("mecab --input-buffer-size=30000 -O wakati < %s.sep.txt > %s.sep.tok.txt" % (TMP_TGT_FN, TMP_TGT_FN))

        os.system("python align.py --src %s.sep.txt --tgt %s.sep.txt --src_ref %s.sep.tok.txt --tgt_ref %s.sep.tok.txt --dict %s >> %s" % (TMP_SRC_FN, TMP_TGT_FN, TMP_SRC_FN, TMP_TGT_FN, DICT_FN, OUTPUT_FN))

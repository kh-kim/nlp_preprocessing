import sys, argparse
import numpy as np
import torch

from sklearn.metrics.pairwise import cosine_similarity

DICT_DELIMITER = ' <> '
EXCEPTS = []

def read_vectors(fn):
    labels = []
    vectors = []

    f = open(fn, 'r')

    line_cnt = 0
    vec_dim = -1
    for line in f:
        if line_cnt >= 1:
            tokens = line.strip().split(' ')

            if vec_dim > 0 and len(tokens) - 1 != vec_dim:
                continue
            
            labels += [tokens[0]]
            vectors += [list(map(float, tokens[1:]))]

            vec_dim = len(tokens) - 1

        line_cnt += 1

    f.close()

    return labels, vectors

def get_word_translation(src_labels, src_vectors, tgt_labels, tgt_vectors, k = 1, thres = .6, max_length = 20000):
    s2t = {}

    for iteration in range(int(len(src_vectors) / max_length)):
        tmp_src_vectors = src_vectors[iteration * max_length:(iteration + 1) * max_length]
        sim = cosine_similarity(tmp_src_vectors, tgt_vectors)
    
        for i in range(len(tmp_src_vectors)):
            for j in range(k):
                max_idx = np.argmax(sim[i])
    
                if sim[i][max_idx] >= thres:
                    s2t[src_labels[(iteration * max_length) + i]] = ([] if s2t.get(src_labels[(iteration * max_length) + i]) is None else s2t[src_labels[(iteration * max_length) + i]]) + [tgt_labels[max_idx]]
    
                sim[i][max_idx] = -np.inf

    return s2t

def parse_argument():
    p = argparse.ArgumentParser()
    
    p.add_argument('-src', required = True)
    p.add_argument('-tgt', required = True)
    p.add_argument('-input', default = None)
    p.add_argument('-output', default = None)
    p.add_argument('-dict', default = None)
    p.add_argument('-k', type = int, default = 1)
    p.add_argument('-thres', type = float, default = .55)

    config = p.parse_args()

    return config

if __name__ == "__main__":
    config = parse_argument()

    src_labels, src_vectors = read_vectors(config.src)
    tgt_labels, tgt_vectors = read_vectors(config.tgt)

    src_to_tgt = get_word_translation(src_labels, src_vectors, tgt_labels, tgt_vectors, k = config.k, thres = config.thres)

    if config.input is not None and config.output is not None:
        f = open(config.input, 'r')
        f_out = open(config.output, 'w')

        for line in f:
            if line.strip() != "":
                tokens = line.strip().split(' ')

                new_line = []
                for t in tokens:
                    if src_to_tgt.get(t) is not None and t not in EXCEPTS:
                        new_line += [src_to_tgt[t]]
                    else:
                        new_line += [t]

                f_out.write(" ".join(new_line) + "\n")

        f_out.close()
        f.close()
    elif config.dict is not None:
        f = open(config.dict, 'w')

        for src_label in src_labels:
            if src_to_tgt.get(src_label) is not None:
                for candidate in src_to_tgt[src_label]:
                    if not src_label.isdigit() or not candidate.isdigit() or (src_label.isdigit() and candidate.isdigit() and src_label == candidate):
                        f.write("%s%s%s\n" % (src_label, DICT_DELIMITER, candidate))

        f.close()

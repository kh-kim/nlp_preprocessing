#!/bin/bash

# Install and register conda.
cd /tmp
curl -o miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x ./miniconda.sh
./miniconda.sh -b -p ~/.conda
echo 'export PATH="$HOME/.conda/bin:$PATH"' >> $HOME/.bashrc
source ~/.bashrc

# Create a new virtual environment for pytorch and konlpy.
conda create -y --name konlpy python=3.6 numpy pyyaml scipy ipython mkl
source activate konlpy
sudo apt install -y openjdk-8-jdk g++ build-essential autoconf automake
pip install torch jpype1 konlpy

# Install Mecab.
curl -LO https://bitbucket.org/eunjeon/mecab-ko/downloads/mecab-0.996-ko-0.9.1.tar.gz
tar -zxf mecab-0.996-ko-0.9.1.tar.gz
cd mecab-0.996-ko-0.9.1
./configure
make
make check
sudo make install
sudo ldconfig

# Install mecab-ko-dic.
cd /tmp
curl -LO https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-2.0.1-20150920.tar.gz
tar -zxf mecab-ko-dic-2.0.1-20150920.tar.gz
cd mecab-ko-dic-2.0.1-20150920
./autogen.sh
./configure
make
sudo sh -c 'echo "dicdir=/usr/local/lib/mecab/dic/mecab-ko-dic" > /usr/local/etc/mecabrc'
sudo make install
sudo ldconfig

# Install mecab-python.
cd /tmp
git clone https://bitbucket.org/eunjeon/mecab-python-0.996.git
cd mecab-python-0.996
python setup.py build
python setup.py install

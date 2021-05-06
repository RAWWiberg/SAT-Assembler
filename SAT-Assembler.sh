#!/bin/bash
# Copyright (c) 2013 Yuan Zhang, Yanni Sun.
# You may redistribute this software under the terms of GNU GENERAL PUBLIC LICENSE.
# pipeline of MetaDomain. 

set -euo pipefail


# input: 
# -m: hmm file;
# -f: fasta file;
# -t: alignment overlap threshold, default: 20;
# -d: relative overlap difference threshold: 0.15;

# output:
# -o: output_contig_file

# get the installation path.
usage() {
  echo "SAT-Assembler.sh -m <HMM file> -f <fasta file> -o <output folder> [options] 
  Options:
    -h:  show this message
    -t:  alignment overlap threshold, default: 20;
    -d:  relative overlap difference threshold: 0.15;
    -o:  output directory"
}

hmm=
fasta=
t=20
d=0.15
out=
# installation dir.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while getopts "hm:f:t:d:o:" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    m)
      hmm=$OPTARG
      ;;
    f)
      fasta=$OPTARG
      ;;
    t)
      t=$OPTARG
      ;;
    d)
      d=$OPTARG
      ;;
    o)
      out=$OPTARG     
      ;;
    esac
done

if [ "$hmm" == "" ];then
  echo "Please specify the hmm file."
  usage
  exit
fi

if [ "$fasta" == "" ];then
  echo "Please specify the input fasta file."
  usage
  exit
fi

if [ "$out" == "" ];then
  echo "Please specify the output folder."
  usage
  exit
fi


if ! which hmmsearch 2> /dev/null; then
  echo "hmmsearch is not found.";
  usage
  exit 1
fi

if ! python $DIR/check_python_packages.py; then
  echo "Biopython or NetworkX is not found."
  usage
  exit 1
fi

# create the output folder.
if [ ! -d $out/ ];then
  mkdir -p $out/
fi
tmp="$(cd $out && pwd)"
base_fasta="$(basename $fasta)"

if [[ ! -f $tmp/${base_fasta}.frame1 ]]; then
    echo "Translating reads into all six reading frames..."
    $DIR/DNA2Protein 1-6 $fasta $tmp/${base_fasta}
    echo "Done translating."
fi

# generate a list of domains in the input hmm file.
if [[ ! -d $tmp/HMMs ]]; then
    echo "Parsing HMM library"
    python $DIR/parse_hmm_files.py $hmm $tmp/HMMs
    echo "Done parsing HMM library"
fi

for hmmfile in $tmp/HMMs/*; do
    hmm_acc=$(basename $hmmfile .hmm)
    # clear hmmer output if it exists
    if [[ -f $tmp/${base_fasta}_${hmm_acc}.hmmer ]]; then
        rm $tmp/${base_fasta}_${hmm_acc}.hmmer
    fi
    echo "Fishing for reads with ${hmm_acc}"
    for i in {1..6}
    do
        bash $DIR/hmmer3_pipeline_strand.sh $hmmfile $tmp/${base_fasta}.frame${i} $i >> $tmp/${base_fasta}_${hmm_acc}.hmmer
    done
    echo "Assembling ${hmm_acc}"
    python $DIR/assembler.py $tmp/${base_fasta}_${hmm_acc}.hmmer $fasta ${hmm_acc} $t $d $out 
done
#rm -r $tmp/HMMs
#rm $tmp/${base_fasta}.frame?

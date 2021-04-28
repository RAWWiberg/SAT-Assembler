#!/bin/bash
# Copyright (c) 2013 Yuan Zhang, Yanni Sun.
# You may redistribute this software under the terms of GNU GENERAL PUBLIC LICENSE.
# pipeline of MetaDomain. 

set -e

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
    -w:  working directory (should contain the fasta file, output directory will become a sub-directory)
    -o:  output directory"
}

hmm=
fasta=
t=20
d=0.15
out=
working_dir=

# Get the installation directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#echo "${DIR}"

# Get the current directory
#working_dir=$(pwd)
#echo "${working_dir}"

while getopts "hm:f:t:d:w:o:" OPTION
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
    w)
      working_dir=$OPTARG
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

if [ "$working_dir" == "" ];then
  echo "Please give the working directory."
  usage
  exit
fi

if [ "$out" == "" ];then
  echo "Please specify the output folder."
  usage
  exit
fi

if [ `which hmmsearch 2> /dev/null | wc -l` -eq 0 ]; then
  echo "hmmsearch is not found.";
  usage
  exit
fi

if [ `$DIR/check_python_packages.py` -eq 1 ];then
  echo "Biopython or NetworkX is not found."
  usage
  exit
fi 

# Generate the output directory.
if [ ! -d ${out}/ ];then
  mkdir ${out}/
else
  echo 'Output folder exists. Please specify another output folder.'
  exit
fi

# Print the path to the working directory
working_dir=$(cd ${working_dir} && pwd)
echo "Working directory is: ${working_dir}"

# Get the full path to the output folder
out_dir="$(cd ${out} && pwd)"
# Print the path fot the output directory
echo "Output directory is: ${out_dir}"

# Get the basename for the fasta file
base_fasta="$(basename ${fasta})"

# Move to the output directory to run DNA2Protein
cd ${out_dir}
echo "fasta file: ${fasta}"
echo "fasta file basename: ${base_fasta}"
${DIR}/DNA2Protein 1-6 ${working_dir}/${fasta} ${base_fasta}

# Move back to the working directory
cd ${working_dir}

# generate a list of domains in the input hmm file.
python ${DIR}/parse_hmm_files.py ${hmm} ${out_dir}/HMMs
ls ${out_dir}/HMMs | while read line
do
  hmm_acc=$(basename ${line} .hmm)
  cat /dev/null >${out_dir}/${base_fasta}_${hmm_acc}.hmmer
  for i in {1..6}
  do
   bash ${DIR}/hmmer3_pipeline_strand.sh ${out_dir}/HMMs/$line ${out_dir}/${base_fasta}.frame${i} ${i} >> ${out_dir}/${base_fasta}_${hmm_acc}.hmmer
  done
  python ${DIR}/assembler.py ${out_dir}/${base_fasta}_${hmm_acc}.hmmer ${fasta} ${hmm_acc} ${t} ${d} ${out} 
done
#rm -r ${out_dir}/HMMs
#rm ${out_dir}/${base_fasta}.frame?

#!/bin/bash
# this file is a pipeline to run selected pfam domains against the compressed reads to see which family is transcribed
if [ $# -ne 3 ];then
  echo "Arguments: <hmm file> <fasta file> <frame:1-6>"
  exit
fi
hmmsearch -E 1000 $1 $2 | grep -E '^Query:|^Accession:|^>>|^\ *[1-9]+ !|^\ *[1-9]+ \?' | awk -v frame="$3" '
BEGIN {
  detail = ""
  if (frame <= 3) {
    symbol = "+"
  } else {
    symbol = "-"
  }
}
{
  if ($1 == ">>") {
    seq=$2
  } else if ($1 == "Accession:") {
    acc = substr($2, 1, 7)
  } else if ($1 == "Query:") {
    name = $2
  } else {
    evalue = $5
    score = $3
    model_begin = $7
    model_end = $8
    align_begin = $13
    align_end = $14
    if (acc) {
      hmm_name = acc
    } else if (name) {
      hmm_name = name
    } else {
      print "No  Query (NAME) or Accession (ACC) in hmmsearch output..\nPlease add NAME and/or ACC in hmm files.." > "/dev/stderr"
      exit 1
    }
    print seq, hmm_name, score, evalue, 
          model_begin, model_end, align_begin, align_end, symbol 
  }
}'

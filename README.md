I wanted to try [SAT-Assemlber](https://github.com/zhangy72/SAT-Assembler.git) for a project. 
Another github member [jiarong](https://github.com/jiarong/SAT-Assembler) found a few issues and fixed them. 
I found a few more that I have fixed and I hope this makes it more generalisable:

This README file contains the original text from jiarong's fixes as well as some additions by me.

1) The original tool was tailor to Pfam hmms, which require "ACC" (Accession #) line in hmm. Changed to use "NAME" instead if "ACC" is not present in hmm.
2) The current "networkx" module is no long compatible with the assembler.py script here. Changed to be compatible with "networkx" version 2.2
3) There are a few bugs in `SAT-Assembler.sh` and `assembler.py`
4) The `DNA2Protein` software included in the package does not like long path names for the output file. There is now a workaround in the `SAT-Assembler.sh` script.

### Install dependencies:
1) First intall conda following instructions [here](https://conda.io/docs/user-guide/install/linux.html)

2) Then create a new environment with python2.7 and networx from conda-forge channel:
```bash
conda create -c conda-forge -n SAT python=2.7 networkx=2.2 
conda activate SAT
```

3) Install Biopython and HMMER3 from bioconda channel:
```bash
conda install -c bioconda biopython=1.68 hmmer=3.1b2
```

### How to run:

1. Clone the repository:   

```bash
git clone https://github.com/RAWWiberg/SAT-Assembler.git
```

Make sure that the location of the *.sh and *.py files as well as DNA2Protein are in your PATH.


2. To run SAT-Assembler, use the following command:  

```
SAT-Assembler.sh -m <HMM file> -f <fasta file> [options]  
  options:
    -h:  show this message
    -t:  alignment overlap threshold, default: 20;
    -d:  relative overlap difference threshold: 0.15;
    -o:  output directory
```

An example with test data:

```bash
cd SAT-Assembler/test
gzip -d -c P_syringae-se-200K.fa.gz > P_syringae-se-200K.fa
../SAT-Assembler.sh -m rplB.hmm -f P_syringae-se-200K.fa -o test.out
```
You will see the `rplB_contigs.fa` and `rplB_scaffolds.txt` in `test.out`

## Very important:
1. The hmm file can contain multiple hmm models and should be in **HMMER3.0**'s hmm file format. All the hmm files of Pfam database can be downloaded from Pfam (http://pfam.xfam.org/).  
2. The nucleotide sequence file should be in fasta format. All the reads should be in a single fasta file.  
3. The format of paired-end reads is should be in **".1" and ".2" or "/1" and "/2"** notation. An example of a paired-end read will be gnl|SRA|SRR360147.1.1 and gnl|SRA|SRR360147.1.2.  
4. Sequences DO NOT have to be all paired. As long as all sequence name follow the name format required above, orphan reads are allowed. 

------------


More info are in original repo: https://github.com/zhangy72/SAT-Assembler.git
Additional info are in jiarong's repo: https://github.com/jiarong/SAT-Assembler

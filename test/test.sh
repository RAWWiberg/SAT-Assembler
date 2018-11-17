gzip -d -c P_syringae-se-200K.fa.gz > P_syringae-se-200K.fa
../SAT-Assembler.sh -m rplB.hmm -f P_syringae-se-200K.fa -o test.out && echo "*** test success.." || echo "*** test failed.."
rm -rf test.out P_syringae-se-200K.fa

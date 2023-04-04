#!/usr/bin/bash
#SBATCH --nodes 1 --ntasks 8 --mem 128G -J ITS --time 18:00:00
CPU=$SLURM_CPUS_ON_NODE

if [ ! $CPU ]; then
 CPU=2
fi

hostname

#AMPtk needs to be loaded in miniconda2 for UCR HPCC
#We'll need to unload miniconda3 and load miniconda2 before load AMPtk
module unload miniconda3
#module load miniconda2

module load amptk/1.5
module load usearch/10

#conda activate amptk1.6

BASE=DroughtITS

INPUT=illumina

if [ ! -f $BASE.demux.fq.gz ]; then
 amptk illumina -i $INPUT --merge_method vsearch -f ITS1-F -r ITS2 --require_primer off -o $BASE --usearch usearch9 --cpus $CPU --rescue_forward on --primer_mismatch 2 -l 230 
fi

if [ ! -f $BASE.otu_table.txt ];  then
 amptk unoise3 -i $BASE.demux.fq.gz -o $BASE --uchime_ref ITS -u usearch10 -e 0.9
fi

if [ ! -f $BASE.filtered.otus.fa ]; then
 amptk filter -i $BASE.otu_table.txt -f $BASE.ASVs.fa -p 0.005
fi

if [ ! -f $BASE.otu_table.taxonomy.txt ]; then
 amptk taxonomy -f $BASE.filtered.otus.fa -i $BASE.final.txt -d ITS
fi

if [ ! -f $BASE.guilds.txt ]; then
 amptk funguild -i $BASE.otu_table.taxonomy.txt --db fungi -o $BASE
fi

if [ ! -f $BASE.taxonomy.fix.txt ]; then
 perl rdp_taxonmy2mat.pl<$BASE.taxonomy.txt>$BASE.taxonomy.fix.txt
fi

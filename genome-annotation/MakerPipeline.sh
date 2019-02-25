#!/bin/bash

#PBS -d .
#PBS -e error/maker.${S}.pipeline.err
#PBS -o output/maker.${S}.pipeline.out
#PBS -l mem=30gb,nodes=1:ppn=20,walltime=8:00:00:00

# You don't need 100gb memory - change to decide which queue to go into

. ~/.bashrc
module load repeatmasker mpich bedtools hmmer blast

######################### VARIABLES TO SET ####################################

## path to where your programs are located (mine was set in .bashrc)
#progs=/path/to/folder/containing/programs/

## You need the TrainGeneMarkES.sh and TrainSnap.sh scripts in the cwd. If you
## are running your own Augustus training you'll also need the
## TrainAugustusTheHardWay.sh script in your cwd.

## path to search db for annotations. Assumes the raw fasta is ${uniprot}.fasta
## and that you have constructed a blast db using makeblastdb. Your blastdb
## is then ${uniprot}.p*
uniprot=/gpfs/data/kronforst-lab/nvankuren/searchdbs/uniprot/uniprot_sprot 

## prefix for gene model renaming
rename=Hpac 

#################### SPECIES-SPECIFIC REPEAT LIBRARIES #########################

## Construct a species-specific repeat library using RepeatModeler.
BuildDatabase -name $S -engine ncbi ${S}.fa
RepeatModeler -pa 20 -engine ncbi -database $S 2>&1 | tee ${S}.repeatmodeler.log

## This outputs two files: ${S}-families.fa and ${S}-families.stk. Use the fasta
## create a custom library for masking with RepeatMasker. Note that you may have
## to change this to point directly to the script and the library database. I
## have progs defined in .bashrc as /gpfs/data/kronforst-lab/nvankuren/programs.
## You may also have a more appropriate taxon than arthropoda.

perl $progs/RepeatMasker/util/queryRepeatDatabase.pl -species arthropoda | \
    cat - ${S}-families.fa > ${S}_plus_arthropoda.lib

## Clean up
mkdir ${S}_repeatmodeler
mv ${S}-families.fa ${S}-families.stk ${S}.repeatmodeler.log ${S}.n* \
   ${S}.translation RM_* ${S}_repeatmodeler/

############################## REPEAT MASKING ##################################

## Mask with new repeat library from RepeatModeler. The lib option requires a
## fasta file with the new known repeats and those high-quality repeats from
## an appropriate taxon. I had to load the module so that particular
## dependencies were also present, but point directly to the locally installed
## RM
$progs/RepeatMasker/RepeatMasker -pa 20 -engine ncbi -xsmall \
				 -lib ${S}_plus_arthropoda.lib ${S}.fa | \
    tee ${S}.repeatmasker.log

## Clean up results, prepare for MAKER
mkdir ${S}_repeatmasker
mv ${S}.fa.masked ${S}.fa.out ${S}.fa.tbl ${S}.fa.cat.gz RM_* ${S}_repeatmasker/
rm trfResult*

## Add an ID field to the RM output GFF to conform with MAKER's requirements
perl $progs/RepeatMasker/util/rmOutToGFF3.pl ${S}_repeatmasker/${S}.fa.out | \
    awk 'BEGIN{s=0}{if($0~/^#/){print $0;}else{print $0 ";ID=" s; s=s+1;}}' > \
	${S}_repeatmasker/${S}.rm_for_maker.gff

## Prepare reference fasta for MAKER
mkdir raw_fasta
mv ${S}.fa raw_fasta
cp ${S}_repeatmasker/${S}.fa.masked ${S}.fa
samtools faidx ${S}.fa
     
############################ INITIAL MAKER RUN ################################

## Run Maker using species-specific mRNAs and proteins for modeling. This
## assumes you have already set up your initial_maker_opts.ctl file to correctly
## point to the mRNA, protein, and repeat gff files that you want to use.

if [ ! -f ${S}_repeatmasker/${S}.rm_for_maker.gff ]; then
    echo "REPEAT MASKING MUST HAVE FAILED - NO GFF";
    exit
fi

## Run maker
mpiexec -n 20 maker \
	initial_maker_opts.ctl \
	maker_bopts.ctl \
	maker_exe.ctl 2>&1 | \
   tee initial_maker.log

## Merge output gffs into one
cd ${S}.maker.output
gff3_merge -n -s -d ${S}_master_datastore_index.log > ${S}.maker.noseq.gff

## Get evidence for re-use in subsequent maker runs
awk '$2 == "est2genome"' ${S}.maker.noseq.gff > ../initial_est2genome.gff
awk '$2 == "protein2genome"' ${S}.maker.noseq.gff > \
    ../initial_protein2genome.gff
awk '$2 ~/repeat/' ${S}.maker.noseq.gff > ../initial_repeats.gff
grep trnascan ${S}.maker.noseq.gff > ../initial_tRNAs.gff

fasta_merge -d ${S}_master_datastore_index.log

## back to wd
cd ..

######################## SNAP TRAINING ROUND 1 ########################

## SNAP TRAINING ROUND 1a: Train SNAP using initial maker output
bash TrainSnap.sh round1 ${S} 

## SNAP TRAINING ROUND 1b: Re-run maker using ROUND 1b trained HMMs for SNAP and AUGUSTUS
cp initial_maker_opts.ctl snap_training1_maker_opts.ctl
mv ${S}.maker.output initial_${S}.maker.output

## Prepare ctl file so that it uses previous maker annos and
## the new training files. ############ FIX ME ################
sed -i 's/est=.* #/est= #/' snap_training1_maker_opts.ctl
sed -i 's/est_gff=/est_gff=initial_est2genome.gff/' snap_training1_maker_opts.ctl
sed -i 's/altest_gff=initial_est2genome.gff/altest_gff=/' snap_training1_maker_opts.ctl
sed -i 's/protein=[a-zA-Z].* #/protein= #/' snap_training1_maker_opts.ctl
sed -i 's/protein_gff=/protein_gff=initial_protein2genome.gff/' snap_training1_maker_opts.ctl
sed -i 's/repeat_protein=.* #/repeat_protein= #/' snap_training1_maker_opts.ctl
sed -i "s/rm_gff=${S}_repeatmasker\/${S}.rm_for_maker.gff/rm_gff=initial_repeats.gff/" snap_training1_maker_opts.ctl
sed -i 's/snaphmm=/snaphmm=snap\/round1\/round1.hmm/' snap_training1_maker_opts.ctl
sed -i 's/est2genome=1/est2genome=0/' snap_training1_maker_opts.ctl
sed -i 's/protein2genome=1/protein2genome=0/' snap_training1_maker_opts.ctl
sed -i 's/trna=1/trna=0/' snap_training1_maker_opts.ctl

## run maker
mpiexec -n 20 maker \
	snap_training1_maker_opts.ctl \
	maker_bopts.ctl \
	maker_exe.ctl 2>&1 | \
   tee snap_training1_maker.log

## merge output gffs into one
cd ${S}.maker.output
gff3_merge -n -s -d ${S}_master_datastore_index.log > ${S}.maker.noseq.gff
fasta_merge -d ${S}_master_datastore_index.log
cd ..

########################## SNAP TRAINING ROUND 2 ########################

## SNAP TRAINING ROUND 2a: Improve SNAP HMM using annotations based on SNAP
## TRAINING ROUND 1 
bash TrainSnap.sh round2 ${S} 

## SNAP TRAINING ROUND 2b: Re-run maker using ROUND 1b training files

## cleanup from previous round
cp snap_training1_maker_opts.ctl snap_training2_maker_opts.ctl
mv ${S}.maker.output snap_training1_${S}.maker.output

## Prepare ctl files
sed -i 's/snaphmm=snap\/round1\/round1/snaphmm=snap\/round2\/round2/' snap_training2_maker_opts.ctl

## run maker to generate the next iteration of 
mpiexec -n 20 maker \
	snap_training2_maker_opts.ctl \
	maker_bopts.ctl \
	maker_exe.ctl 2>&1 | \
    tee snap_training2_maker.log

## merge output gffs into one
cd ${S}.maker.output
gff3_merge -n -s -d ${S}_master_datastore_index.log > ${S}.maker.noseq.gff
fasta_merge -d ${S}_master_datastore_index.log
cd ..

## Generate the final SNAP HMM for Augustus training
bash TrainSnap.sh round3 ${S}

mv ${S}.maker.output snap_training2_${S}.maker.output

######################## AUGUSTUS TRAINING ###########################
# echo "Starting to train Augustus"
## AUGUSTUS TRAINING: Train AUGUSTUS using SNAP TRAINING ROUND 2 HMM
#bash TrainAugustusTheHardWay.sh $S round3

####################### GENEMARK TRAINING ############################
echo "Starting to train GeneMark-ES"

bash TrainGeneMarkES.sh $S | tee genemark_training.log
mkdir genemark_training
mv output/data output/gmhmm* gmes.log info data run* \
   genemark_training.log genemark.gtf genemark_training/

####################### FINAL MAKER ##################################
echo "Starting the final MAKER run"

## cleanup from previous round
cp snap_training2_maker_opts.ctl final_maker_opts.ctl

## Prepare ctl files
sed -i 's/snaphmm=snap\/round2\/round2.hmm/snaphmm=snap\/round3\/round3.hmm/' final_maker_opts.ctl
sed -i 's/gmhmm=/gmhmm=genemark_training\/gmhmm.mod/' final_maker_opts.ctl

## CHANGE THIS IF YOU MAKE YOUR OWN AUGUSTUS PROFILE
sed -i "s/augustus_species=/augustus_species=heliconius_melpomene1/" final_maker_opts.ctl
sed -i 's/other_gff=/other_gff=initial_tRNAs.gff/' final_maker_opts.ctl

## run maker
mpiexec -n 20 maker \
	final_maker_opts.ctl \
	maker_bopts.ctl \
	maker_exe.ctl 2>&1 | \
    tee final_maker.log

## merge output gffs into one
cd ${S}.maker.output
gff3_merge -n -s -d ${S}_master_datastore_index.log > ${S}.maker.noseq.gff
fasta_merge -d ${S}_master_datastore_index.log
cd ..

## Reorganize files.
## The following files exist in ${S}.maker.output/:

## ${S}.all.maker.augustus_masked.proteins.fasta
## ${S}.all.maker.augustus_masked.transcripts.fasta
## ${S}.all.maker.genemark.proteins.fasta
## ${S}.all.maker.genemark.transcripts.fasta
## ${S}.all.maker.non_overlapping_ab_initio.proteins.fasta
## ${S}.all.maker.non_overlapping_ab_initio.transcripts.fasta
## ${S}.all.maker.proteins.fasta
## ${S}.all.maker.snap_masked.proteins.fasta
## ${S}.all.maker.snap_masked.transcripts.fasta
## ${S}.all.maker.transcripts.fasta

mkdir ${S}_annotations/

cd ${S}_annotations

mkdir blasting ab_initio_only_predictions additional_tracks original_maker_files renamed_annotated_files

cp ../${S}.maker.output/${S}.maker.noseq.gff original_maker_files/
cp ../${S}.maker.output/${S}.all.maker.[agns]* ab_initio_only_predictions/
cp ../${S}.maker.output/${S}.all.maker.[pt]* original_maker_files/

## Contains the raw GFF file, with all annos, and the maker proteins and
## transcripts. Separate out the important pieces.

cd original_maker_files
awk '$2 ~ "maker"' ${S}.maker.noseq.gff > ${S}.maker_only.gff
awk '$2 ~ "est2genome"' ${S}.maker.noseq.gff > ../additional_tracks/${S}.est2genome.gff
awk '$2 ~ "protein2genome"' ${S}.maker.noseq.gff > ../additional_tracks/${S}.protein2genome.gff
awk '$2 ~ "repeat"' ${S}.maker.noseq.gff > ../additional_tracks/${S}.repeats.gff

## BLAST and annotate the final protein sequences
blastp -db $uniprot \
       -query ${S}.all.maker.proteins.fasta \
       -out ../blasting/${S}.proteins_to_uniprot.blast \
       -evalue 1e-5 \
       -outfmt 6 \
       -lcase_masking \
       -max_hsps 1 \
       -seg yes \
       -soft_masking true \
       -num_alignments 1 \
       -num_threads 20
       

## Annotate gff, proteins, and transcripts
maker_functional_gff ${uniprot}.fasta ../blasting/${S}.proteins_to_uniprot.blast \
		     ${S}.maker_only.gff > \
		     ../renamed_annotated_files/${S}.maker.gff

maker_functional_fasta ${uniprot}.fasta ../blasting/${S}.proteins_to_uniprot.blast \
		       ${S}.all.maker.proteins.fasta > \
		       ../renamed_annotated_files/${S}.proteins.fa

maker_functional_fasta ${uniprot}.fasta ../blasting/${S}.proteins_to_uniprot.blast \
		       ${S}.all.maker.transcripts.fasta > \
		       ../renamed_annotated_files/${S}.transcripts.fa


## Rename to final format
cd ../renamed_annotated_files
maker_map_ids --prefix $rename --justify 6 ${S}.maker.gff > ${S}.maker.names
map_gff_ids ${S}.maker.names ${S}.maker.gff
map_fasta_ids ${S}.maker.names ${S}.proteins.fa
map_fasta_ids ${S}.maker.names ${S}.transcripts.fa


################################### FINISHED #######################################

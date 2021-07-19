module purge
module load arch/arch/haswell
module load arch/haswell
module load modulefiles/arch/haswell

module load vcftools/0.1.12a-GCC-5.3.0-binutils-2.25

vcf-subset -c samplestokeep <original>.vcf > <subsetted>.vcf

ml plink/1.90beta-4.4-21-May

plink \
  --bfile <in_prefix> \
  --allow-no-sex \
  --reference-allele ./Ref_alleles_forPlink \
  --recode vcf \
  --out <out_prefix>

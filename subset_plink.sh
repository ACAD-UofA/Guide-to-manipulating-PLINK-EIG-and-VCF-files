module load plink/1.90beta-4.4-21-May

plink --bfile <input_fileset_prefix> \
	--keep-allele-order \
	--allow-no-sex \
	--keep keep_list.txt \
	--make-bed \
	--out <output_fileset_prefix>

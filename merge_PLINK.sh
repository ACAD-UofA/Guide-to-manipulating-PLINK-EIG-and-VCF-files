ml plink/1.90beta-4.4-21-May

plink --bfile <FIRST_input_fileset_prefix> \
	--keep-allele-order \
	--allow-no-sex \
	--merge-list mergelist.txt \
	--make-bed \
	--out <output_fileset_prefix>

# Guide-to-manipulating-PLINK-EIG-and-VCF-files

## EIGENSTRAT format
Both EIGENSTRAT amd PLINK (see below) contain genoytpe information in filesets of three different types of files that must be carried together and always contain the same file prefix to be able to be called by scripts. \
The EIGENSTRAT format is made up of `.ind`, `.snp` and `.geno` files: 

`.ind`: tab-delimited sample file with one line per individual and the following 3 columns:
* sample ID
* sex (M or F). U for Unknown
* Case or Control status, or population group label. If this entry is set to "Ignore", then that individual and all genotype data from that individual will be removed from the data set in all CONVERTF output. \
Typically look like this:
```
Ind1  M Pop1
Ind2  F Pop1
Ind3  F pop2
Ind4  M Pop2
```
`.snp`: tab-delimited SNP file with one line per SNP and the following 6 columns (last 2 optional):
* SNP name
* Chromosome (X is encoded as 23, Y as 24, mtDNA as 90, and XY as 91)
* Genetic position (in Morgans). 0 if unknown
* Physical position (in bases)
* Optional 5th and 6th columns are reference and variant alleles. For monomorphic SNPs, the variant allele can be encoded as X (unknown) \
Typically look like this:
```
           rs3094315     1        0.020130          752566 G A
          rs12124819     1        0.020242          776546 A G
          rs28765502     1        0.022137          832918 T C
           rs7419119     1        0.022518          842013 T G
            rs950122     1        0.022720          846864 G C
```
`.geno`: matrix genotype file with one line per SNP and and genotypes in non-separated columns, with the following genotype coding:
* 0: no copies of reference allele
* 1: one copy of reference allele
* 2: two copies of reference allele
* 9: missing data \
Typically look like this, one individual per column and one site per row:
```
012000010010999099
000010000000999990
000110000000999099
000100000000999099
010000000100999990
201100000100999099
```
## PLINK (PACKEDPED) format 
The PLINK (PACKEDPED) format is the most common file format of plink. \
The format is a fileset of three different files that must accompany each other and have the same file prefix: `.bed`, `.bim` and `.fam` 

`.fam` files contains sample information, has no header line, and one line per sample with the following six fields:
* Family ID ('FID') 
* Within-family ID ('IID'; cannot be '0') 
* Within-family ID of father ('0' if father isn't in dataset) 
* Within-family ID of mother ('0' if mother isn't in dataset) 
* Sex code ('1' = male, '2' = female, '0' = unknown) 
* Phenotype value ('1' = control, '2' = case, '-9'/'0'/non-numeric = missing data if case/control) \
Typically look like this:
```
Pop1  Ind1  0 0 1 -9
Pop1  Ind2  0 0 2 -9
Pop2  Ind3  0 0 2 -9
Pop2  Ind4  0 0 1 -9
```
`.bim`: Contains variant information, has no header line, and one line per variant with the following six fields: 
* Chromosome code (either an integer, or 'X'/'Y'/'XY'/'MT'; '0' indicates unknown) or name 
* Variant identifier 
* Position in morgans or centimorgans 
* Base-pair coordinate (1-based) 
* Allele 1 (usually minor) 
* Allele 2 (usually major) \
Typically look like this:
```
1     rs3094315     0.020130       752566 G A
1     rs7419119     0.022518       842013 G T
1    rs13302957     0.024116       891021 G A
1     rs6696609     0.024457       903426 T C
1        rs8997     0.025727       949654 A G
1     rs9442372     0.026288      1018704 A G
```
`.bed`: binary file that contains genotype information. The genotype information links between the individuals recorded in the `.fam` file and the SNPs recorded in the `.bim` file. Do not re-order or add/remove the lines in either of these files manually or this will not work. \
*NB: If you've come across the UCSC Genome Browser's BED file format, these are NOT THE SAME thing. 

## Using PLINK
* Keep the PLINK 1.9 manual handy: https://www.cog-genomics.org/plink/1.9/ \
* DO NOT use the conda versions of PLINK, there are many bugs and issues with scrambling data. \
* PLINK is in general very annoying, reccommend to manipulate data in VCF or in EIGENSTRAT formats where possible. \
* There are many functions PLINK will do to your data by default, so find the flags necessary to turn off these functions. \
* PLINK will by default re-calculate what it thinks are the major and minor alleles in your data based on the dataset you give it, and then change the alleles around in your data accodingly. 

Some useful ones I use: \
`--keep-allele-order`	Use this EVERY SINGLE TIME you call a plink command, otherwise the order of Allele1 and Allele2 may (or probably will) be flipped in your data. \
`--allow-no-sex` 	PLINK will default to removing individuals that have unassigned sex, use this to force it to keep them. \
`--snps-only` 		Removes indels from your variant data and keeps only snps \
`--biallelic-only` Removes sites with 2+ alleles \
`--indiv-sort 0` PLINK default re-orders your data by individual name, this keeps them the same order as the `*.fam` file \
`--geno 0.9999`	Removes sites with greater that 0.9999 missing data, useful to easily remove loci with no data \
`--extract`/`--exclude` Extracts or exlcludes variants based on a .txt file list of all variant IDs


## VCF format
VCF format, or Variant Calling Format is the main type of file format for storing genotypic data. \
A VCF file can contain many individuals, sample and genotype information. \
The file will contain header rows that record important informnation about the file, including the reference used for mapping and the contigs present. \
The files do tend to be much heavier than the PLINK or EIGENSTRAT formats that have stripped out a lot of the extra information, and make use of the matrix format to avoid repeating information unnecessarily, which allows the files to be much smaller. \
Meta-information lines start with ## and contain various metadata. \
The header line starts with # and is tab separated. It contains 9 columns of information about the variant calls, and then one column per sample name:

* `CHROM` 	The name of the sequence (typically a chromosome) on which the variation is being called. This sequence is usually known as 'the reference sequence', i.e. the sequence against which the given sample varies. 
* `POS` 	The 1-based position of the variation on the given sequence. 
* `ID` 	The identifier of the variation, e.g. a dbSNP rs identifier, or if unknown a ".". Multiple identifiers should be separated by semi-colons without white-space. 
* `REF` 	The reference base (or bases in the case of an indel) at the given position on the given reference sequence. 
* `ALT` 	The list of alternative alleles at this position. 
* `QUAL` 	A quality score associated with the inference of the given alleles. 
* `FILTER` 	A flag indicating which of a given set of filters the variation has passed. 
* `INFO` 	An extensible list of key-value pairs (fields) describing the variation. See below for some common fields. Multiple fields are separated by semicolons with optional values in the format: =[,data]. 
* `FORMAT` 	An (optional) extensible list of fields for describing the samples. See below for some common fields. 
* `SAMPLE` 	For each (optional) sample described in the file, values are given for the fields listed in FORMAT

Here's an example:

![image](https://user-images.githubusercontent.com/78726635/126028105-be396333-9955-42b2-b5c1-f4a7dec63aa5.png)


# Converting between formats
There are different ways to convert between these three formats. \
To convert between EIGENSTRAT and PLINK (PACKEDPED), use CONVERTF. \
To convert between VCF and PLINK (PACKEDPED), use plink commands. \
To convert between EIGENSTRAT and VCF, there are two python scripts available, although there are some issues with these. \
All of these conversion methods are explained in detail below.
<img width="800" alt="image" src="https://user-images.githubusercontent.com/78726635/126023876-4e4d964e-403f-484b-a67b-3023fe255954.png">

## Convertf
Use EIGENSOFT's CONVERTF for converting formats. \
CONVERTF manual: https://github.com/argriffing/eigensoft/blob/master/CONVERTF/README \
The syntax to use convertf is `convertf -p parfile` \

PLINK (PACKEDPED) --> Eigenstrat format

Where the parfile should be named `par.PACKEDPED.EIGENSTRAT.<name>` \
With the following format:
```
genotypename:    <in>.bed
snpname:         <in>.bim
indivname:       <in>.fam
outputformat:    EIGENSTRAT
genotypeoutname: <out>.geno
snpoutname:      <out>.snp
indivoutname:    <out>.ind
```
Eigenstrat --> PLINK (PACKEDPED) format \
The parfile should now be named `par.EIGENSTRAT.PACKEDPED.<name>` \
With the following format:
```
genotypename:    <in>.geno
snpname:         <in>.snp
indivname:       <in>.ind
outputformat:    EIGENSTRAT
genotypeoutname: <out>.bed
snpoutname:      <out>.bim
indivoutname:    <out>.fam
```
When converting to PACKEDPED format, need SNPS in ascending chromosome & position order, and the reference allele set as the major allele. \
Whenever you use convertf, it is good to manually check the outputted `.ind` or `.fam` file afterwards, because depending on which version you use, this software is known for doing weird things such as scrambling the sample order, or appending the sample name and population name together into one column, and other irritating things.

## Plink conversions
VCF --> PLINK (PACKEDPED) format

Run the following inside a script if you are manipulating a large amount of data: 
```
ml plink/1.90beta-4.4-21-May

plink \
  --vcf <in>.vcf.gz \
  --allow-no-sex \
  --keep-allele-order \ 
  --make-bed \
  --out <out_prefix>
```
or simply onto the command line if it's small enough to run quickly:
```
plink --vcf <in>.vcf.gz --allow-no-sex --keep-allele-order --make-bed --out <out_prefix>
```
The flag `--make-bed` tells PLINK to output the `*.bed`, `*.bim`, `*.fam` fileset, called the PACKEDPED format. \
There are other PLINK formats but this is the best for downstream use. \
Also note that the files correspond to each other so you cannot manually filter one of them without filtering the fileset. \
e.g. You could rename the variant IDs as long as the same number of variants are in the `*.bim` file, but not reorder, remove or add variants.

PLINK (PACKEDPED) --> VCF format

Similarly, run the following inside a script if you are manipulating a large amount of data: 
```
ml plink/1.90beta-4.4-21-May

plink \
  --bfile <in_prefix> \
  --recode vcf \
  --out <out>

```

# Subsetting or Merging samples
<img width="756" alt="image" src="https://user-images.githubusercontent.com/78726635/126028934-333c7083-3ac2-48a1-bf52-b354cfaaf1a0.png">
## Subset by individuals in PLINK
Subset bed files to required individuals:
```
module load plink/1.90beta-4.4-21-May

plink --bfile <input_fileset_prefix> \
	--keep-allele-order \
	--allow-no-sex \
	--keep keep_list.txt \
	--make-bed \
	--out <output_fileset_prefix>
```
Where keeplist.txt has one individual per row, the first and second column from the `*.fam` file

## Subset by individuals in EIGENSTRAT
Use poplistname option in convertf \
Then use convertf to convert EIGENSTRAT to EIGENSTRAT format and the output will contain your subsetted individuals. \
The parfile will have the name `par.EIGENSTRAT.EIGENSTRAT.<name>` 
Example:
```
genotypename:    <in>.geno
snpname:         <in>.snp
indivname:       <in>.ind
outputformat:    EIGENSTRAT
genotypeoutname: <out>.geno
snpoutname:      <out>.snp
indivoutname:	 <out>.ind
poplistname:	 poplist_keep.txt
```
Where the file you give to poplistname has been written to include populations (1 per line) from the `.ind` file that you want to extract.

## Subsetting VCFs

# Merging samples

## Merge datasets in PLINK

```
plink --bfile <FIRST_input_fileset_prefix> \
	--keep-allele-order \
	--allow-no-sex \
	--merge-list mergelist.txt \
	--make-bed \
	--out <output_fileset_prefix>
```
Where mergelist.txt has the format:
```
SECOND_input.bed SECOND_input.bim SECOND_input.fam
THIRD_input.bed THIRD_input.bim THIRD_input.fam
```
## Merge datasets in EIGENSTRAT
Use mergeit, syntax is `mergeit -p parfile`. \
mergeit documentation: https://github.com/argriffing/eigensoft/blob/master/CONVERTF/README \
One issue is you can only merge two datasets at once. \
`*.parfile` format:
```
geno1: <input1>.geno
snp1:  <input1>.snp
ind1:  <input1>.ind
geno2: <input2>.geno
snp2:  <input2>.snp
ind2:  <input2>.ind
genooutfilename: <output>.geno
snpoutfilename:	<output>.snp
indoutfilename:	<output>.ind
outputformat:	EIGENSTRAT
docheck:	YES
hashcheck:	YES
```
NB** in the official mergeit documentation, this parfile is incorrect. \
The documentation reads `genotypeoutname` `snpoutname` `indivoutname`, instead of what is in the above example. \

## Merge VCFs

# Miscellaneous Useful commands

Renaming SNP ID from the rsID to "CHR_SITE" \
In `*.bim` files:
```
awk '{print $1, "\t", $1"_"$4, "\t", $3, "\t", $4, $5, "\t", $6}' <old>.bim > <new>.bim
```
In `*.snp` files:
```
awk '{print $2"_"$4, "\t", $2, "\t", $3, "\t", $4, $5, $6}' <old>.snp > <new>.snp
```

Removing rows in a text file by duplicates in a specified colums.\
e.g. to remove rows with duplicats in column 2:
```
awk '!seen[$2]++' in.txt > out.txt
```
Editing `.ind` file to set population name to 'ignore' for individuals other than ones you want to keep. \
(Only really practical if subsetting for a small number of individuals)
```
awk '{if ($1=="Sample1"||$1=="Sample2"||$1=="Sample3") print $0; else print $1, $2, "ignore"}' <in>.ind > <out>.subset.ind

```
Find and replace strings in text file. `\b` denotes word boundary
```
gsed -i 's/\b<OLD_STRING>\b/<NEW_STRING>/g' <file>.txt
```

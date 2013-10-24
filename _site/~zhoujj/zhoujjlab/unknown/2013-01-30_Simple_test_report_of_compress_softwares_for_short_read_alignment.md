# Simple test report of compress software for short-read alignment result

## software

+ [SAITRandomAccess](https://bitbucket.org/ajitsb/saitrandomaccess/downloads);
+ [CRAM](http://www.ebi.ac.uk/ena/about/cram_toolkit) developed by EBI;

## Some weak/good piont

+ SAITRandomAccess
    + Don't support paired end reads alignment result. Paired-end sequencing is wildly use now. If you use paired end reads result, you will get error: " \*\*\* glibc detected *** ./RandomAccessEnc: corrupted double-linked list: 0x083fad08 \*\*\* ";
    + Only support sam file. Many aligner output the bam to save storage. It unreasonable to limit the file format;
    + The software package should include test data set and explain the specify requirements of input/output files such as only single mapping result;
    + When user use bam file as input file, the program give any error messages.
    + When the chromosome name of sam file are not corresponding to the reference fa file, it also don't give a error message and just running until you stop the process;
    + when the sam file only contain reads mapped to one chromosome, I use the whole genome fasta file as reference, ./RandomAccessEnc just running, without any result and error messages. I only success run RandomAccessEnc based one chromosome fasta file;
    + when RandomAccessEnc compress the sam file, it almost copy reference fasta file to another file and create another \*.aux file. it's not efficiency to do that.
    + use decode program to retrieve the information from \*.enc file, the output file format without explanation. 

+ cram
    + it's written in java and error messages can guide me to complete the compress and decompress steps;
    + Regarding to the retrieve result, I check it with samtool and find that the reads information lost the quality information and the original ID has changed to be a number;

## Comparison of efficiency

Test data(741M): [ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data/NA12878/alignment/NA12878.chrom11.ILLUMINA.bwa.CEU.low_coverage.20120522.bam](ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data/NA12878/alignment/NA12878.chrom11.ILLUMINA.bwa.CEU.low_coverage.20120522.bam)

||||
software|compress time|decompress time|
SAITRandomAccess|3m7.985s|4m26.988s|
CRAM|5m3.405s|1m3.945s|
[Compress/decompress time]



||||
software|before compress|after compress|
SAITRandomAccess|3.3G(\*.sam)|1.5G(\*.aux)+341M(\*.enc)|
CRAM|741M(\*.bam)|39M|
[Storage usage]

## Conclusion

+ CRAM is better than SAITRandomAccess;
+ SAITRandomAccess is not well designed and without light-point;
+ All of these tow method will lost some information of origin bam/sam file.

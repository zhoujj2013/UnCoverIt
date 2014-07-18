---
layout: post
title: "Learn:利用shell和perl构建转录组(RNA-seq)分析流程"
description: "Mix together to build a RNA-seq pipeline."
category: "bioinformatics"
tags: ["bioinformatics", "RnaSeq", "NGS", "learn"]
---
{% include JB/setup %}

随着NGS的高速发展，越来越多有价值的物种被测序，随之而来的，基因表达及表观遗传数据会急剧增加。

公共数据库有大量已经公开的数据，这些数据大多数是基于二代测序技术产生的。

fly/C.elegan:

[http://www.modencode.org/](http://www.modencode.org/)

Mouse and Human:

[http://genome.ucsc.edu/ENCODE/](http://genome.ucsc.edu/ENCODE/)

GEO/ENA

[http://www.ncbi.nlm.nih.gov/geo/](http://www.ncbi.nlm.nih.gov/geo/)

[http://www.ebi.ac.uk/ena/](http://www.ebi.ac.uk/ena/)

#### zebra fish转录分析方案设计

**生物学问题**: 比较同一时期，male body 和 male head样品的基因表达的差异。

**数据来源**: 参考文章，[http://genome.cshlp.org/content/22/10/2067.long](http://genome.cshlp.org/content/22/10/2067.long)

male_body(ERR004012): 

ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR004/ERR004012/ERR004012_1.fastq.gz

ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR004/ERR004012/ERR004012_2.fastq.gz

male_head(ERR004022): 

ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR004/ERR004022/ERR004022_1.fastq.gz

ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR004/ERR004022/ERR004022_2.fastq.gz

**方案设计**:

![rna-seq_diagram](https://dl.dropboxusercontent.com/u/87531643/web/rna-seq.png "数据分析流程图")

#### 测序数据质量控制

下载测序数据：

{% highlight bash %}
mkdir ZabraRnaSeq
cd ZabraRnaSeq
mkdir data
cd data
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR004/ERR004012/ERR004012_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR004/ERR004012/ERR004012_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR004/ERR004022/ERR004022_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR004/ERR004022/ERR004022_2.fastq.gz
{% endhighlight %}

用fastqc对数据质量进行查看：

{% highlight bash %}
# $fastqc = path_to_fastqc_dir
ls *.gz | xargs gunzip
$fastqc/fastqc stdin -o ./ ./ERR004012_1.fastq
$fastqc/fastqc stdin -o ./ ./ERR004012_2.fastq
$fastqc/fastqc stdin -o ./ ./ERR004022_1.fastq
$fastqc/fastqc stdin -o ./ ./ERR004022_2.fastq
{% endhighlight %}

通过fastqc结果判断数据是否合格，具体判断标准,请参考下面链接的Example Reports部分：

[http://www.bioinformatics.babraham.ac.uk/projects/fastqc/](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/)

如果你发现有些数据不合格，或者还有adapter，应该用相应的程序把低质量数据去除。

如果你对fastq文件数据质量体系没有概念，请先阅读[fastq文件格式](http://en.wikipedia.org/wiki/FASTQ_format)和[Phred_quality_score](http://en.wikipedia.org/wiki/Phred_quality_score):

用fastx去除低质量数据：

{% highlight bash %}
# $fastx = path_to_fastx_dir
# GA2 phred 33, read length=75
$fastx/bin/fastq_quality_trimmer -t 36 -l 35 -i ./ERR004012_1.fastq -o ./ERR004012_1.trimed.fq
$fastx/bin/fastq_quality_trimmer -t 36 -l 35 -i ./ERR004012_1.fastq -o ./ERR004012_2.trimed.fq
$fastx/bin/fastq_quality_trimmer -t 36 -l 35 -i ./ERR004012_1.fastq -o ./ERR004022_1.trimed.fq
$fastx/bin/fastq_quality_trimmer -t 36 -l 35 -i ./ERR004012_1.fastq -o ./ERR004022_2.trimed.fq
cd .. # 返回原来的目录
{% endhighlight %}

此处没有出现高频adapter序列,所以就不用跑$fastx/bin/fastx_clipper。

#### 短reads比对及结果分析

准备参考序列及参考序列index:

{% highlight bash %}
mkdir Zebra && cd Zebra
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 MT; do wget ftp://ftp.ensembl.org/pub/release-75/fasta/danio_rerio/dna/Danio_rerio.Zv9.75.dna.chromosome.$i.fa.gz;done;
zcat *.fa.gz | sed 's/^/chr/g' > Danio_rerio.Zv9.75.Chr.fa
rm *.fa.gz
bowtie2-build ./Danio_rerio.Zv9.75.Chr.fa ./Danio_rerio.Zv9.75.Chr

# download geneset
wget ftp://ftp.ensembl.org/pub/release-75/gtf/danio_rerio/Danio_rerio.Zv9.75.gtf.gz
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 MT; do zcat Danio_rerio.Zv9.75.gtf.gz | awk '$1 == $i' | sed 's/^/chr/g' >> Danio_rerio.Zv9.75.gtf;done;
rm Danio_rerio.Zv9.75.gtf.gz
cd .. # 返回原来的目录
{% endhighlight %}

用tophat比对到zebra fish参考基因组：

{% highlight bash %}
# $tophat = path_to_tophat_dir
# 注意查看内存，两个taphat很容易把内存消耗掉的
nohup $tophat/tophat2 -G ./Zebra/Danio_rerio.Zv9.75.gtf -o male_body_tophat -p 8 ./Zebra/Danio_rerio.Zv9.75.Chr ./data/ERR004012_1.trimed.fq ./ERR004012_2.trimed.fq >MB.tophat.std 2>MB.tophat.err&
nohup $tophat/tophat2 -G ./Zebra/Danio_rerio.Zv9.75.gtf -o male_head_tophat -p 8 ./Zebra/Danio_rerio.Zv9.75.Chr ./data/ERR004022_1.trimed.fq ./ERR004022_2.trimed.fq >MH.tophat.std 2>MH.tophat.err&
# 跑完后请从MB.tophat.err，MH.tophat.err查看基本比对结果统计。
# 具体结果文件，请查看taphat的文档
# 主要结果文件是，accepted_hits.bam文件
{% endhighlight %}

#### 表达量计算及差异表达分析

用cufflinks组装新的转录集合及计算每一个转录本的表达量：

{% highlight bash %}
# $cufflinks = path_to_cufflinks_dir
$cufflinks/cufflinks -g ./Zebra/Danio_rerio.Zv9.75.gtf -o ./male_body_cufflinks ./male_body_tophat/accepted_hits.bam >MB.cufflinks.std 2>MB.cufflnks.err&
$cufflinks/cufflinks -g ./Zebra/Danio_rerio.Zv9.75.gtf -o ./male_head_cufflinks ./male_head_tophat/accepted_hits.bam >MH.cufflinks.std 2>MH.cufflnks.err&
{% endhighlight %}

合并两个样品的转录本：

{% highlight bash %}
vim transcript.lst
# 加入transcript的路径
./male_body_cufflinks/transcripts.gtf
./male_head_cufflinks/transcripts.gtf

mkdir ./merged_asm
$cufflinks/cuffmerge -o ./merged_asm -g ./Zebra/Danio_rerio.Zv9.75.gtf -s ./Zebra/Danio_rerio.Zv9.75.Chr.fa -p 8 ./transcript.lst > cuffmerge.std 2> cuffmerge.err &
{% endhighlight %}

用cuffdiff比较两个样品的差异表达基因：

{% highlight bash %}
$cufflinks/cuffdiff -o MBvsMH_cuffdiff -L MB,MH -p 8 ./merged_asm/transcripts.gtf ./male_body_tophat/accepted_hits.bam ./male_head_tophat/accepted_hits.bam >MBvsMH_cuffdiff.std 2>MBvsMH_cuffdiff.err &
{% endhighlight %}


#### 生物信息分析报告

可以根据不同的需要组织数据分析报告，主要以下几点：

1. 测序数据基本统计及质量评估；

2. 短序列比对结果统计；

3. 转录本数目、表达量统计；

4. 样品间基因表达差异分析结果；

5. 进行必要的基因功能注释分析。


上面把RNA-seq数据分析实现了一次，有人可能会问，你这也可以算是流程吗？

分析流程本来就是这样的，你只需要用shell或者perl把上面的每一步串联起来，就是一个自动化的流程了。

转载请标明出处：

[http://zhoujj2013.github.io/UnCoverIt/bioinformatics/2014/07/19/bioinfo-mix-together/](http://zhoujj2013.github.io/UnCoverIt/bioinformatics/2014/07/19/bioinfo-mix-together/)

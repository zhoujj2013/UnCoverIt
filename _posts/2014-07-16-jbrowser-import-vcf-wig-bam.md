---
layout: post
title: "JBrowser:导入vcf wig和bam数据"
description: "Import vcf, wig and bam to jbrowser."
category: "bioinformatics"
tags: ["bioinformatics", "visualization", "web"]
---
{% include JB/setup %}

#### vcf, wig和bam文件的介绍

vcf文件主要是用来记录基因组variants位置及variants功能注释。

详细格式请查看：

http://samtools.github.io/hts-specs/

wig是用来表示连续和非连续数据信号的文件格式。

详细格式请查看：

http://www.genome.ucsc.edu/goldenPath/help/wiggle.html

bam是短片断序列alignment结果sam文件，通过samtools排序压缩后生成的文件，用于存储比对文件。
bam文件需要通过samtools进行查看。

详细格式请查看：

http://samtools.github.io/hts-specs/SAMv1.pdf

http://genome.sph.umich.edu/wiki/SAM

http://picard.sourceforge.net/explain-flags.html

http://wiki.bits.vib.be/index.php/.sam

{% highlight bash %}
samtool view <bam_file>
{% endhighlight %}

#### 导入vcf文件

我个人觉得tracks.conf配置文件的配置内容更加易读，所以接下来的配置信息，我都写到tracks.conf文件。

vcf文件有两种显示方式：CanvasVariants和HTMLVariants。我暂没有发现两者的区别。

在导入vcf文件前要对vcf文件进行压缩，并建立index，这个过程要求安装samtools/tabix。

{% highlight bash %}
# tabix: https://github.com/samtools/tabix
# 下载并安装tabix
git clone https://github.com/samtools/tabix.git
cd tabix
make

# 对vcf进行压缩,以s410.vcf为例
$tabix/bgzip s410.vcf

# 建立index
$tabix/tabix -p s410.vcf.gz

# 生成s410.vcf.gz.tbi
{% endhighlight %}

**CanvasVariants**

{% highlight bash %}
[ tracks . s410 ]
storeClass = JBrowse/Store/SeqFeature/VCFTabix
urlTemplate = ../../vcf/s410.vcf.gz
category = VCF
type = JBrowse/View/Track/CanvasVariants
key = s410 VCF1
{% endhighlight %}

**HTMLVariants**

{% highlight bash %}
[ tracks . s410-2 ]
hooks.modify = function( track, feature, div ) { div.style.backgroundColor = track.config.variantIsHeterozygous(feature) ? 'red' : 'blue'; }
key = s410 VCF2
# 区分杂合和纯合位点
variantIsHeterozygous = function( feature ) { var genotypes = feature.get('genotypes');  for( var sampleName in genotypes ) { try { var gtString = genotypes[sampleName].GT.values[0]; if( ! /^1([\|\/]1)*$/.test( gtString) && ! /^0([\|\/]0)*$/.test( gtString ) ) return true; } catch(e) {} } return false; }
storeClass = JBrowse/Store/SeqFeature/VCFTabix
urlTemplate = ../../vcf/s410.vcf.gz
type = JBrowse/View/Track/HTMLVariants
metadata.category = VCF
metadata.Description = Variants called from XX.bam using samtools and bcftools.  Heterozygous variants are shown in red, homozygous variants in blue.
{% endhighlight %}

#### 导入bam文件

bam文件导入后，有两种显示方式

+ 直接显示每一个reads的比对情况(type = JBrowse/View/Track/Alignments2)

+ 只显示比对的coverage情况(type = JBrowse/View/Track/SNPCoverage)

两种方式均要临时读进某个region的alignment数据，所显示的速度较为慢的。

**alignment2方式**

{% highlight html %}
[ tracks . s410_bam ]                     #　以s410.bam为例，要求已经排序并建立index, **.bam.bai文件
style.height = 7
key = BAM - s410 alignment2
storeClass = JBrowse/Store/SeqFeature/BAM
urlTemplate = ../../data/s410.sorted.rmdup.bam
maxFeatureScreenDensity = 4
metadata.category = BAM
metadata.Description = small test pattern of BAM-format paired alignments of simulated resequencing reads on the s410 sample.
type = JBrowse/View/Track/Alignments2
chunkSizeLimit = 50000000                  # 这个是限制在某一个region允许读取的数据量，如果读进的数据量太大会造成浏览器“罢工”。
{% endhighlight %}


**coverage方式**

{% highlight html %}
[ tracks . volvox-sorted_bam_coverage ]
storeClass = JBrowse/Store/SeqFeature/BAM
urlTemplate = ../../data/s410.sorted.rmdup.bam
metadata.category = BAM
metadata.Description = SNP/Coverage view of s410.bam, simulated resequencing alignments.
type = JBrowse/View/Track/SNPCoverage       #注意这个设置的区别
key = BAM - s410 SNPs/Coverage
chunkSizeLimit = 50000000
{% endhighlight %}

#### 导入wig文件

JBrowser并不直接支持wig文件，它要求wig文件压缩成bigwig格式，这个可以大大节约存储空间。

目前还没有现成的程序支持bam文件转换为wig文件，wig文件主要是用来看sequencing的coverage和density分布情况，所以先解决bam和wig文件转换问题。

**from bam file to wig file**

{% highlight bash %}
# 先用samtools把bam转化为sam数据流，再通过管道把数据导入到sam2wig.pl脚本，生成wig文件
samtools view ../data/s410.sorted.rmdup.bam | perl sam2wig.pl --bin 30 --minMQ 30 - > s410.wig

# 下载ucsc tools
wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/fetchChromSizes
wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/wigToBigWig

# 把wig转化为bigwig格式
./fetchChromSizes hg19 > hg19.chrom.sizes
./wigToBigWig ./s410.wig hg19.chrom.sizes s410.bw
{% endhighlight %}

sam2wig.pl代码如下：

<script src="https://gist.github.com/zhoujj2013/2f44ba0c0437f0241cc4.js"></script>

**配置bigwig文件**

bigwig有两种显示的方式，一种是density，另外一种是XY-plot。

+ density plot方式

{% highlight html %}
[ tracks . s410_bw_density ]
style.neg_color = function(feature) { return feature.get('score') < 150 ? 'green' : 'red'; } # 如果位点的sequencing depth > 150X显示为红色，否则绿色
bicolor_pivot = mean
key = s410 BigWig Density
storeClass = JBrowse/Store/BigWig
urlTemplate = ../../sam2wig/s410
type = JBrowse/View/Track/Wiggle/Density
metadata.category = Quantitative / Density # 这里是表示两层的分类目录，用/分开。
metadata.Description = Wiggle/Density view of s410.bw.  Also demonstrates use of a user-configurable callback to set the value of neg_color to green when the score is below 150.
{% endhighlight %}

+ XY-plot方式

{% highlight html %}
[ tracks . s410_bw_xyplot ]
style.pos_color = function(feature) { return feature.get('score') > 30 ? 'red' : 'blue'; }
variance_band = true
key = s410 BigWig XY
storeClass = JBrowse/Store/BigWig
urlTemplate = ../../sam2wig/s410.bw
type = JBrowse/View/Track/Wiggle/XYPlot
metadata.category = Quantitative / XY Plot
metadata.description = Wiggle/XYPlot view of volvox_microarray.bw.  Demonstrates use of a user-configured callback to set the bar color to red when the score is above 30.
{% endhighlight %}

完成vcf、wig、bam文件导入后，不需要建立索引，直接就可以查看信号。

参考：
http://gmod.org/wiki/JBrowse_Configuration_Guide

转载请标明出处：
http://zhoujj2013.github.io/UnCoverIt/bioinformatics/2014/07/16/jbrowser-import-vcf-wig-bam/



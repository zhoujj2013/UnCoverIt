---
layout: post
title: "JBrowser:导入bed和gff3文件"
description: "JBrowser: Import bed and gff3 tracks into jbrowser."
category: "bioinformatics"
tags: ["bioinformatics", "visualization", "web"]
---
{% include JB/setup %}

Bed和gff3文件是存储基因功能元件位置信息的文件。想把数据导入JBrowser，首先要理解文件格式及其存储内容。

Bed的每一个位置坐标代表一个位置，详细格式见：http://genome.ucsc.edu/FAQ/FAQformat.html#format1

gff3可以表现一个基因或者转录本的结构及位置信息，详细格式见：http://genome.ucsc.edu/FAQ/FAQformat.html#format3

想了解更多与gff3格式相关的信息，请参考：

http://www.sequenceontology.org/gff3.shtml

http://gmod.org/wiki/GFF3#GFF3_Annotation_Section

在线的gff3格式认证识别：

http://modencode.oicr.on.ca/cgi-bin/validate_gff3_online

gff3格式当时发布的时候是想用这种格式表示基因组的所有信息，也就是说，bed文件也可以转化为gff3格式导入。

#### 直接向JBrowser中导入bed文件

+ 利用$JB/bin/flatfile-to-json.pl导入bed文件；

{% highlight bash %}
# --className 是把基因组元件显示的css样品，详细请查看：$JB/docs/featureglyphs.html
# --arrowheadClass 表示是否在元件两边加上方向，此处不需要加箭头方向
perl $JB/bin/flatfile-to-json.pl --bed TargetGeneRegionExtend2bp.bed --key 'XXTargetReg' --className feature2 --trackLabel RandomTarget --arrowheadClass none --metadata '{"category" : "TargetReSequencing"}' --out ./json/hg19/
{% endhighlight %}

+ 利用$JB/bin/flatfile-to-json.pl对bed文件的gene元件建立名字索引；

{% highlight bash %}
# --sortMem 是指定建立名字索引时所用的内存，单位是b
perl $JB/bin/generate-names.pl --dir ./json/hg19/ -tracks RandomTarget -v --sortMem 2048000000
{% endhighlight %}

可以从tracksselector里面选择我们刚才建立的track。

完成名字索引建立后，我们可以在查询框查询相应名字，ajax是会有自动提示的。

#### 向JBrower导入gff3/gtf/gff2文件

JBrowser的html feature暂时只支持gff3格式文件，gtf和gff2文件都要根据http://gmod.org/wiki/GFF3#GFF3_Annotation_Section中的说明进行格式转换，由于gff3有一些field名字是可以自定义的，所以还得根据JBrowser进行调整。

JBrowser还有另外一种CanvasFeatures，它是支持gtf和gff3格式的，但是它是临时读取文件的，显示速度有点过慢。

关于HTMLfeatures和CanvasFeatures，我日后详细写个文章来研究。

**HTMLfeatures导入**

+ 把Ensembl gtf文件转换为gff3格式；

先准备chromosome名字的转换文件chr.lst

{% highlight html %}
MT	chrM
X	chrX
Y	chrY
1	chr1
2	chr2
3	chr3
4	chr4
5	chr5
6	chr6
7	chr7
8	chr8
9	chr9
10	chr10
11	chr11
12	chr12
13	chr13
14	chr14
15	chr15
16	chr16
17	chr17
18	chr18
19	chr19
20	chr20
21	chr21
22	chr22
{% endhighlight %}

转换gtf文件格式为gff3:

{% highlight bash %}
perl ./gtf2gff3.pl Homo_sapiens.GRCh37.75.gtf chr.lst > Homo_sapiens.GRCh37.75.gff3
{% endhighlight %}

gtf2gff3.pl代码如下：

<script src="https://gist.github.com/zhoujj2013/024ef0789c1f5538d568.js"></script>


+ 分染色体导入gff3文件（如果单个gff3文件太大会导致程序运行的内存峰值达到5G）;

单个文件导入：

{% highlight bash %}
# --trackLabel 是指文件存储时，track的id
# --className 显示的基因的样式
# --subfeatureClasses 基因结构里的元件样式，如CDS,exon,UTR等
# --key 是显示在jbrowser中的tracks名字，与trackLabel可以是相同的，但是名字的用途是有区别的
# --autocomplete 是让基因的名字可以查询
perl $JB/bin/flatfile-to-json.pl --out ./json/hg19/ --gff Homo_sapiens.GRCh37.75.gff3  --type mRNA   --autocomplete all --trackLabel EnsemblTrans --key 'EnsemblTrans' --getSubfeatures --className transcript  --subfeatureClasses '{"CDS": "transcript-CDS"}'  --arrowheadClass arrowhead  --urltemplate "http://asia.ensembl.org/Homo_sapiens/Transcript/Summary?t={id}&db=core" --maxLookback 2000 
{% endhighlight %}

分染色体导入：

写了个perl脚本，把染色体分开导入gff3文件，代码如下：

<script src="https://gist.github.com/zhoujj2013/5e2c1f861fbe904e7de5.js"></script>

运行以下命令导入：

{% highlight bash %}
perl ./import_gff3_by_chr.pl Homo_sapiens.GRCh37.75.gff3 ./json/hg19/
{% endhighlight %}

+ 为新的tracks建立索引

{% highlight bash %}
perl /var/www/jbrowser/bin/generate-names.pl --dir ./json/hg19/ -tracks EnsemblTrans -v --sortMem 2048000000
{% endhighlight %}

**CanvasFeatures导入**

CanvasFeatures导入会相对容易一些，唯一要做的工作是格式转换，要把你手上的gff／gtf文件变为JBrowser所要求的。CanvasFeatures是支持gff3和gtf文件直接导入的，但是文件格式有一些要求。

把你的文件转换成http://gmod.org/wiki/GFF3#GFF3_Annotation_Section所要求的格式就不会错的。在此我就不写转换脚本程序了。


+ 导入gff3文件

在./json/hg19/tracks.conf文件中加入以下配置：

{% highlight html %}
[ tracks . hg19EnsemblTrans ]                         # 注意这里的格式
storeClass = JBrowse/Store/SeqFeature/GFF3
urlTemplate = ../../Homo_sapiens.GRCh37.75.gff3  # 相对于./json/hg19/的文件路径，注意文件格式
type = CanvasFeatures
metadata.description = This is just all the features in the Homo_sapiens.GRCh37.75.gff3 file, displayed directly from a web-accessible GFF3 file
category = Gene                                  # 这个tracks的类别
key = GFF3 - Homo_sapiens.GRCh37.75.gff3　　　　 # jbrowser要显示的名字
{% endhighlight %}

+ 导入gtf文件

在./json/hg19/tracks.conf文件中加入以下配置：

{% highlight html %}
[ tracks . hg19EnsemblTrans ]
storeClass = JBrowse/Store/SeqFeature/GTF
urlTemplate = ../../Homo_sapiens.GRCh37.75.gtf    # 注意ensembl中的chromosome id一定要与reference genome是一致的
type = CanvasFeatures
metadata.description = This is just all the features in the Homo_sapiens.GRCh37.75.gtf file, which like the Homo_sapiens.GRCh37.75.gff3 file, is displayed directly from a web-accessible GTF file
category = Gene
key = GTF - Homo_sapiens.GRCh37.75.gtf in-memory adaptor
style.label = transcript_id,gene_id  # 指定你所要显示转录本及基因类型
{% endhighlight %}

如果你用CanvasFeatures来显示tracks的话，这些tracks的名字是无法建立索引的。

此处我们可以总结出：

+ 生物信息分析经常要对格式进行转换，对生物信息常用数据格式一定熟悉；

+ 掌握一门编程语言，可以完成基本程序书写非常重要；

+ 要学习看生物信息软件的使用说明，并通过google查询解决方案。


参考：
http://gmod.org/wiki/JBrowse_Configuration_Guide

声明：

转载请注明出处：http://zhoujj2013.github.io/UnCoverIt/bioinformatics/2014/07/15/jbrowser-import-bed-and-gff3/




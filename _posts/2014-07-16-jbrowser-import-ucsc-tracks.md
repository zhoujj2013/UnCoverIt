---
layout: post
title: "JBrowser:导入UCSC数据库基因信息数据"
description: "Import ucsc tracks to JBrowser."
category: "bioinformatics"
tags: ["bioinformatics", "visualization", "web"]
---
{% include JB/setup %}

UCSC基因组数据库中有很多有用的基因组数据，再加上这两年新加入的encode project数据，组合这些数据可以对模式物种进行深入研究。但是它不包含的刚测序的物种信息，一般来说，hg19、hg18、mouse、zera fish、fly、c.elegan和yeast的数据较为全面。

JBrowser提供perl脚本可以方便地把ucsc数据导入浏览器。

#### 下载必要的数据库文件

ucsc是一个大型的数据库，可以先解的其ftp目录结构：

hg19 ftp数据库的目录结构
http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/

{% highlight bash %}
# 建立文件夹
mkdir ucsc && cd ucsc

# 下载该物种数据库sql文件
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/trackDb.sql
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/trackDb.txt.gz

# 下载refgene基因集文件，这个是ucsc特有的格式
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/refGene.sql
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/refGene.txt.gz

# 每一个数据集包含两个文件
cd ..
{% endhighlight %}

#### 把refGene导入JBrowser

{% highlight bash %}
# --in 这里是指输入文件夹
# --track 这个的名字要与所下载文件的tracks一致
perl $JB/bin/ucsc-to-json.pl --in ./ucsc/ --track 'refGene' -out ./json/hg19/ --cssclass transcript --subfeatureClasses '{"CDS":"transcript-CDS", "UTR": "transcript-UTR"}' --arrowheadClass transcript-arrowhead
{% endhighlight %}

#### 建立索引（可以选择不建立索引）

{% highlight bash %}
perl /var/www/jbrowser/bin/generate-names.pl --dir ./json/hg19/ -tracks refGene -v --sortMem 2048000000
{% endhighlight %}

其它的ucsc数据库里的tracks导入方法类似。

参考：
http://gmod.org/wiki/JBrowse_Configuration_Guide

转载请注明出处：
http://zhoujj2013.github.io/UnCoverIt/bioinformatics/2014/07/16/jbrowser-import-ucsc-tracks/


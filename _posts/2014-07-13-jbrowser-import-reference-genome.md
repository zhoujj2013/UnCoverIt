---
layout: post
title: "JBrowser导入参考基因组序列"
description: "Import reference genome to JBrowser"
category: "bioinformatics"
tags: ["bioinformatics", "visualization", "web"]
---
{% include JB/setup %}

向JBrowser导入数据，首先要弄清楚输入文件的格式，再根据要求导入JBrowser。

从事生物信息工作，８０％的程序都是利用一些已有的生物信息分析工具完成的，所以搞清楚程序输入和输出特别重要。

常用生物信息数据格式，请参考（大部分生物研究材料都是英文的，如看不懂，也要慢慢看）：

http://genome.ucsc.edu/FAQ/FAQformat.html

向JBrowser导入参考序列，有三种方法：

1. 利用./bin/prepare-refseqs.pl导入fasta文件；

2. 利用./bin/prepare-refseqs.pl导入gff3文件；

3. 利用./bin/prepare-refseqs.pl，根据biodb-to-json.pl配置文件，从CHADO数据库中导入数据；

我推荐使用方法１，因为包含参考基因组和基因位置信息的gff3文件太大，导入时需要的很大的内存；另外数据要导入CHADO数据库也是一件挺复杂的事情，熟悉CHADO数据库的朋友可以使用方法３。

我详细描述一下方法１：

+ 

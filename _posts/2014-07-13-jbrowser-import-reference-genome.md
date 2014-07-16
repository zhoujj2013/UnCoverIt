---
layout: post
title: "JBrowser:导入参考基因组序列"
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

+ 利用./bin/prepare-refseqs.pl导入fasta文件；

{% highlight bash %}
# $JB = path_to_jbrowser # 这里$JB=/var/www/jbrowser
# 建立文件夹存在个人的JBrowser文件
mkdir zhoujj_jb

# 在JBrowser安装文件夹建立软连接
ln -s /home/zhoujj/zhoujj_jb /var/www/jbrowser

# 建立文件夹存放以hg19为参考基因组的tracks
mkdir -p ./json/hg19

# --fasta 输入文件
# --out json文件输出文件夹
perl $JB/bin/prepare-refseqs.pl --fasta ./hg19.fa --out ./json/hg19
{% endhighlight %}

+ 利用./bin/add-json.pl添加dataset_id，这个id会显示在参考基因组选择菜单;

{% highlight bash %}
perl $JB/bin/add-json.pl '{ "dataset_id": "hg19" }' ./json/hg19/trackList.json
{% endhighlight %}

+ 为基因组序列建立索引；

{% highlight bash %}
perl $JB/bin/generate-names.pl --dir ./json/hg19/ -v --sortMem 2048000000
{% endhighlight %}

+ 修改JBrowser配置文件；

{% highlight bash %}
sudo vim $JB/jbrowse.conf
# 添加以下命令
[datasets.hg19]
url  = ?data=zhoujj_jb/json/hg19
name = hg19
# 保存并退出
{% endhighlight %}

现在可以打开浏览器测试：
http://host/jbrowser/index.html?data=zhoujj_jb/json/hg19

在JBrower中，导入参考序列fasta文件、bed文件、gff3文件后，要建立基因名或者序列名字的索引，才能在浏览器中正常查看。


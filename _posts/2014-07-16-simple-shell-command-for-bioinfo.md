---
layout: post
title: "Learn:用shell命令完成简单生物信息分析查询及统计"
description: "Learn simple shell command for bioinformatics analysis."
category: "bioinformatics"
tags: ["bioinformatics", "learn", "shell"]
---
{% include JB/setup %}

在开始这篇文之前，先具有一些linux知识和一些生物知识。

如果没有使用过linux，请阅读：(不需要全部阅读，了解一下就好)

http://en.wikipedia.org/wiki/Linux

http://www.92csz.com/study/linux/

如果不是生物学背景的读者，请有时间的时候，阅读：

http://www.nature.com/scitable

如果你在MS window下工作，还应该去安装putty大型机登录软件和winscp运程文件浏览器:

http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html

http://winscp.net/eng/docs/lang:chs

如果你没有linux系统，请先安装Oracle VM VirtualBox，并在虚拟机中安装linux（建议安装debian linux）:

https://www.virtualbox.org/wiki/Downloads

https://www.debian.org/

如果你对生物数据格式一无所知，请查看fa,gtf格式:

[http://genome.ucsc.edu/FAQ/FAQformat.html](http://genome.ucsc.edu/FAQ/FAQformat.html)

[http://genetics.bwh.harvard.edu/pph/FASTA.html](http://genetics.bwh.harvard.edu/pph/FASTA.html)


下面以zera fish为例子，讲解一下如何在linux terminal下做一些简单的生物学分析：

**从ensembl收集zebra fish数据**

{% highlight bash %}
# 获取自己当前所在路径并查看当前文件夹有什么文件及文件夹
pwd

# 建立存放zebra fish数据的文件夹并进入此文件夹
mkdir zebra_fish
cd zebra_fish

# 至于我是如何知道这些下载路径，请慢慢熟悉ensembl数据库。
# 下载zebra fish参考序列
wget ftp://ftp.ensembl.org/pub/release-75/fasta/danio_rerio/dna/Danio_rerio.Zv9.75.dna.toplevel.fa.gz

# 下载zebra fish蛋白序列
wget ftp://ftp.ensembl.org/pub/release-75/fasta/danio_rerio/pep/Danio_rerio.Zv9.75.pep.all.fa.gz

# 下载zebra fish基因集gtf文件
wget ftp://ftp.ensembl.org/pub/release-75/gtf/danio_rerio/Danio_rerio.Zv9.75.gtf.gz

# 如果标准错误输出中看到任务完成，就表示下载成功，一般来说会有进度条的。
# 查看文件夹文件长名列表
ls -l

# 查看文件夹文件短名列表，请注意对比
ls
{% endhighlight %}

**查看数据文件**

{% highlight bash %}
# 用gunzip解压文件，一般来说，以*.gz, *.bz, *.tar.gz结尾的文件为压缩文件
# 用gzip可以压缩文件，如果没有安装gzip，可以sudo apt-get install gzip
gunzip Danio_rerio.Zv9.75.dna.toplevel.fa.gz

# 如果你觉得一个个解压太烦了，可以这样
ls *.gz | xargs gunzip
# 或者，这是一个while循环语句
ls *.gz | while read line; do gunzip $line;done;

# less查看文件
less Danio_rerio.Zv9.75.gtf

# 你会发现有的行太长了，要换行才能显示，显得格式很乱，加上-S参数可以不换行显示
# 用less打开后，可以通过上下左右键移动，也可以用pagedown和pageup上下翻页
# 按"/"可以进行字符串查找，就像word里的查找框一样
less -S Danio_rerio.Zv9.75.gtf

# 查看所有的染色体名字，grep是筛选的意思，筛选条件就是"^>",以>开头
# 就是查看所有以>开头的行
grep "^>" Danio_rerio.Zv9.75.dna.toplevel.fa

# 你会发现输出会有">"号，如何去除呢？
# 可以用sed命令去除，sed教程：http://www.cnblogs.com/cbscan/articles/2277351.html　和　http://www.kuqin.com/docs/sed.html
# 用null来替换">"
grep "^>" Danio_rerio.Zv9.75.dna.toplevel.fa | sed 's/^>//g'

# 查看特定转录本的gtf信息
grep "ENSDART00000126123" Danio_rerio.Zv9.75.gtf 

# 或者
grep "ENSDART00000126123" Danio_rerio.Zv9.75.gtf | less -S

# 或者可以生成另外一个文件并保存
grep "ENSDART00000126123" Danio_rerio.Zv9.75.gtf > new.gtf

# 如果有多个转录本需要收集，可以用">>"把数据追加到文件
grep "ENSDART00000126752" Danio_rerio.Zv9.75.gtf >> new.gtf
{% endhighlight %}

**简单统计分析**

awk命令的使用，请参考：

[http://www.cnblogs.com/ggjucheng/archive/2013/01/13/2858470.html](http://www.cnblogs.com/ggjucheng/archive/2013/01/13/2858470.html)

{% highlight bash %}
# 统计文件内容行数，你会得到一个很大的数字，因为基因组挺大的
wc -l Danio_rerio.Zv9.75.dna.toplevel.fa

# 统计基因组序列条数，因为担心有重复的基因组序列，所以先排序sort，然后把相同的序列id去除uniq
grep "^>" Danio_rerio.Zv9.75.dna.toplevel.fa | sort | uniq | wc -l

# 统计zebra fish基因组中有多少个蛋白序列
grep "^>" Danio_rerio.Zv9.75.pep.all.fa | wc -l

# 统计zebra fish基因组中有多少个exon
# -v "^#" 表示除去以#开头的行
# awk -F"\t" '$3 ~ /exon/' 表示以"\t"分割每列，并且第３列包含字符串"exon"
grep -v "^#" Danio_rerio.Zv9.75.gtf | awk -F"\t" '$3 ~ /exon/' | wc -l

# 统计zebra fish基因组中有多少个rRNA基因
grep -v "^#" Danio_rerio.Zv9.75.gtf　| awk -F"\t" '$2 ~ /rRNA/ && $3 ~ /gene/' | wc -l

# 统计zebra fish基因组中每一个染色体上有多少个蛋白编码基因
grep -v "^#" Danio_rerio.Zv9.75.gtf | awk -F"\t" '$2 ~ /protein_coding/ && $3 ~ /gene/' | cut -f 1 | sort | uniq -c > chr_gene_count.lst
{% endhighlight %}

这些只是基本的操作，可以让你尽快熟悉linux命令行环境，建议多点尝试。

仅仅看教程，是无法学会技能的，但是我们确信：实践是可以让你成为高手。

转载请标明出处：

http://zhoujj2013.github.io/UnCoverIt/bioinformatics/2014/07/15/simple-shell-command-for-bioinfo/


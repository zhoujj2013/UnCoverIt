---
layout: post
title: "Learn:用Perl处理生物信息数据"
description: "Using perl in bioinformatics."
category: "bioinformatics"
tags: ["bioinformatics", "perl", "learn"]
---
{% include JB/setup %}

我在计算机方面不在行，所以就不讨论为什么选择perl语言。因为生物研究者更加关心什么工具可以让他们能快速处理大量的生物信息数据，perl脚本可以满足您的需求。

100M的2*75bp reads大概有10G左右，比对结果文件*.sam大概30G。这个数据太大了，在普通桌面电脑中是无法进行分析的，因此在大型计算机下，很有必要掌握一门能快速处理文本的语言。

大多数优秀的生物信息数据分析软件是要求在linux/unix环境下运行了，所以进行生物信息分析的最基本要求是：你能在linux命令行环境下随心所欲地处理数据。

#### perl语言学习材料

perl语言博大精深，此处我引用[Perl Maven](http://perlmaven.com/)。这个教程的好处是有英文版，也有中文版，当然重要的是free。

Perl Maven中文版

[http://cn.perlmaven.com/perl-tutorial](http://cn.perlmaven.com/perl-tutorial)

Perl Maven英文版

[http://perlmaven.com/perl-tutorial](http://perlmaven.com/perl-tutorial)

建议先阅读中文版本，再阅读英文版本，理解作者的真正用意。

[perl单行命令](https://dl.dropboxusercontent.com/u/87531643/web/perl1linerCH.txt)

#### bash shell学习材料

在[Learn:用shell命令完成简单生物信息分析查询及统计](http://zhoujj2013.github.io/UnCoverIt/bioinformatics/2014/07/16/simple-shell-command-for-bioinfo/)中，我们用到sed和awk命令，其实是两种古老的文本处理工具。

sed命令教程

[教程](http://www.kuqin.com/docs/sed.html)

[sed单行命令](https://dl.dropboxusercontent.com/u/87531643/web/sed1linerCH.txt)

awk命令教程

[教程](http://www.kuqin.com/docs/awk.html)

[awk单行命令](https://dl.dropboxusercontent.com/u/87531643/web/awk1linerEN.txt)

详细解释：[part1](http://www.catonmat.net/blog/awk-one-liners-explained-part-one/) [part2](http://www.catonmat.net/blog/awk-one-liners-explained-part-two/) [part3](http://www.catonmat.net/blog/awk-one-liners-explained-part-three/) [part4](http://www.catonmat.net/blog/update-on-famous-awk-one-liners-explained/)

#### 在命令行中使用perl

前面的文章提到用shell命令对zebra fish基因组文件进行一些简单统计分析，但是面对一些复杂的情况，只依赖命令行会显得苍白无力了。

例如：计算zebra fish基因组的长度、计算zebra fish每一个蛋白序列的长度、计算zebra fish外显子的平均长度等。

下面先看一下perl怎么在命令行下使用单行命令：

{% highlight sh %}
# 用perl进行计算
# -e 表示直接执行
perl -e 'print 10*10,"\n";'

# 用perl读取fasta文件的序列id
# 按照顺序一行一行读取文件
# chomp; 把换行符去除
perl -ne 'chomp; my $id = $1 if(/>(\S+)/); print "$id\n" if($id);' Danio_rerio.Zv9.75.dna.toplevel.fa

# 用单行perl计算基因组的长度
# BEGIN{my $sum = 0;} 程序开始读文件前执行，定义了一个全局变量
# END{print "Total: $sum\n";} 程序完成文件读取后执行
perl -ne 'BEGIN{my $sum = 0;} chomp; next if(/^>/); $sum += length($_); END{print "Total: $sum\n";}' Danio_rerio.Zv9.75.dna.toplevel.fa

# 用同样的方法可以完成所有基因的蛋白序列平均长度统计
perl -ne 'BEGIN{my $sum = 0; my $count = 0;} chomp; $count++ if(/^>/); next if(/^>/); $sum += length($_); END{my $avg = $sum/$count; print "PEP average length: $avg\n";}' Danio_rerio.Zv9.75.pep.all.fa
{% endhighlight %}

这时候，想一下我们在做生物学研究时，还需要那些统计分析，可以尝试用perl完成。

#### perl脚本

当然还有一些更加复杂的分析，用perl脚本去实现更加方便。

以下是如何计算zebra fish的染色体长度？

{% highlight bash %}
# 新建一个文件名
vim seq_len.pl
{% endhighlight %}

vim是linux系统下的文本编程器，当然你可以用gedit。

具体请参考：

[Interactive Vim tutorial](http://www.openvim.com/tutorial.html)


以下是seq_len.pl的代码：

{% highlight perl %}
#!/usr/bin/perl -w

use strict; #用严格的语法格式，这样不容易出错

my ($fa_f) = @ARGV; # 读入所要处理的fasta文件名

open IN,"$fa_f" || die $!; # 打开fasta文件，如果打开失败的话，输出标准错误信息
$/ = ">"; <IN>; $/ = "\n"; # $/ 变量是perl是存储文件句柄的分隔符
while(<IN>){
	my $id = $1 if(/\S+/); # 获取序列的id
	$/ = ">";              # 分隔符$/ 变量变成">"，可以每次读进属于id的序列
	my $seq = <IN>;
	chomp($seq);           # 去除分隔符">"
	$seq =~ s/\n//g;       # 把换行符"\n"去除
	$/ = "\n";
	print "$id\t".length($seq)."\n";  # 输出结果
}
close IN;
{% endhighlight %}

运行perl程序:

{% highlight bash %}
perl ./seq_len.pl Danio_rerio.Zv9.75.dna.toplevel.fa
{% endhighlight %}

#### Mix togethter

尝试把perl和shell结合在一起，我们要对每一个基因组都进行DNA和蛋白质序列长度进行统计。

建立并打开basic_stat.sh
{% highlight bash %}
vim basic_stat.sh
{% endhighlight %}

basic_stat.sh代码如下：

{% highlight bash %}
#!/bin/bash

# $1 表示输入的第一个参数，$2代表第二个参数
perl ./seq_len.pl $1.dna.toplevel.fa > $1.ChrLen.lst
perl ./seq_len.pl $1.pep.all.fa > $1.ProteinLen.lst
{% endhighlight %}

运行shell脚本：

{% highlight bash %}
# sh ./basic_stat.sh <genome_name_prefix>
sh ./basic_stat.sh Danio_rerio.Zv9.75
{% endhighlight %}

转载请标明出处：

[http://zhoujj2013.github.io/UnCoverIt/bioinformatics/2014/07/17/perl-for-bioinformatics/](http://zhoujj2013.github.io/UnCoverIt/bioinformatics/2014/07/17/perl-for-bioinformatics/)


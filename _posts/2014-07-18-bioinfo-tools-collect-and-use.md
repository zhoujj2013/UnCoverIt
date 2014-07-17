---
layout: post
title: "Learn:常用生物信息分析软件<i>陈列馆</i>"
description: "Bioinformatics tools collection and usage."
category: "bioinformatics"
tags: ["bioinformatics", "learn"]
---
{% include JB/setup %}

近几年来，二代测序技术(NGS)得到广泛地应用，NGS产生海量生物信息数据，然后这些数据就是通过各种生物信息处理软件，转化为生物学意义的有用信息。生物信息分析软件各类繁多，但是主要是基于NGS的短片段序列分析为主。近两年，研究者对生物功能的研究不断深入，还出现了很多基因功能分析软件以及各种生物信息数据分析流程。

现阶段生物信息分析几乎都是基于序列比对结果展开的。

下面以TopHat为例子，说明如何利用生物信息分析软件进行生物学研究。

#### Tophat的安装及使用

TopHat要求先安装bowtie2, 因为[bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml)是TopHat的比对工具：

{% highlight bash %}
# 在个人目录下建立存放程序的目录
mkdir ~/software

# 下载bowtie2和tophat，此处我下载预编译版本，也就说，下载完毕就可以使用。
wget http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.3/bowtie2-2.2.3-linux-x86_64.zip/download -O bowtie2-2.2.3-linux-x86_64.zip
wget http://ccb.jhu.edu/software/tophat/downloads/tophat-2.0.12.Linux_x86_64.tar.gz

# 解压bowtie2-2.2.3-linux-x86_64.zip
unzip bowtie2-2.2.3-linux-x86_64.zip

# 把bowtie2加入到系统环境变量，用vim打开~/.bashrc，添加行
export PATH=~/software/bowtie2-2.2.3/:$PATH
source ~/.bashrc
which bowtie2

# 同时，你也可以把bowtie1安装上，如果你是用ubuntu的话
sudo apt-get install bowtie
{% endhighlight %}

测试bowtie2是否正常运行:

{% highlight bash %}
# 进入example文件夹
cd ~/software/bowtie2-2.2.3/example/

# 建立参考基因组index
bowtie2-build reference/lambda_virus.fa reference/lambda_virus

# 测序bowtie2比对
bowtie2 -x ./reference/lambda_virus -1 ./reads/reads_1.fq -2 ./reads/reads_2.fq -S align.sam 2> bowtie.log

# 查看比对情况和比对结果
cat bowtie.log
less -S align.sam
{% endhighlight %}

安装tophat:

{% highlight bash %}
# 解压tophat数据包
tar xzvf tophat-2.0.12.Linux_x86_64.tar.gz
cd ./tophat-2.0.12.Linux_x86_64
./tophat -h
{% endhighlight %}

我们用tophat官方网站的数据对tophat进行测试：

{% highlight bash %}
mkdir test
cd test
# 下载hg19的参考基因组
wget ftp://ftp.ccb.jhu.edu/pub/data/bowtie2_indexes/hg19.zip
unzip hg19.zip

# 下载tophat的reads数据
wget http://ccb.jhu.edu/software/tophat/downloads/tophat2_simulation_data/junction_test/sim_1.fq.tar.gz
wget http://ccb.jhu.edu/software/tophat/downloads/tophat2_simulation_data/junction_test/sim_2.fq.tar.gz
tar xzvf sim_1.fq.tar.gz
tar xzvf sim_2.fq.tar.gz

# 使用tophat处理RNAseq数据，此处用的是一个模拟数据，ref: http://genomebiology.com/2013/14/4/R36
# 这个数据量比较大，请放到后台运行。当然你也可以投放到大型节点运行。
nohup ../tophat ./hg19/hg19 ./sim_1.fq ./sim_2.fq >tophat.std 2>tophat.err&

# 用top -u <username>查看情况
top -u username

# 查看tophat_out结果
ls -l ./tophat_out
{% endhighlight %}

从这个简单的例子可以看到，生物信息分析是需要读大量材料，去不断尝试新的软件，不断学习和积累的。因为你不可能把所有的分析软件用一次，所以你要具备学习的能力。

当你遇到一个生物学问题的时候，你能想起用什么软件相互组合，才能够解决你的问题。

最后剩下的就是不断学习，不断尝试，也许这就是科研。

由此看来，生物信息分析不是一门容易的技术活。

#### 获取帮助(seek for help)

当我们在安装使用过程中遇到困难的时候:

1. 应该先查看程序的使用说明文档；

2. 用google search看一下有没有人遇到类似的情况，寻找合适的解决方案；

3. 如果实在不行，可以在生物信息社区寻求解答的方法，如[seqanswer](http://seqanswers.com/)和[biostar](https://www.biostars.org/)；

4. 最后实在解决不了，请找expert。

#### 生物信息分析软件常规安装方法

**c语言程序包：**

{% highlight bash %}
./configure prefix=<install_dir> #有的程序没有这一部分
make
make test
make install
{% endhighlight %}

**Perl语言程序包**

{% highlight bash %}
perl Makefile.PL PREFIX=<install_dir> #有的程序没有这一部分
make
make install
{% endhighlight %}

**Python语言包**

{% highlight bash %}
python setup.py build --build-base=<install_dir_path>
python setup.py install
{% endhighlight %}

**预编译版本**

一般来说，这种已经编译的程序是不需要再进行其它操作了。

直接把目标文件变成可执行，就可以用了。

例如，fastqc

{% highlight bash %}
chmod 755 fastqc
./fastqc --help
{% endhighlight %}

#### 常用生物信息分析软件

下面列出一些常用的生物信息分析软件:

（链接时刻在变，我只提供keywork，如有需要请自行google）

**局部比对**

NCBI blast

blat

fasta

**全局比对**

muscle

clustal

t-coffee

**全基因组比对**

blastz/lastz

MUMmer

**短序列比对**

SOAP2

Bowtie1/Bowtie2

BWA

**短序列测序质量控制**

fastQC

cutadaptor

**RNAseq比对、表达量估计和差异表达分析**

TopHat/cufflinks

DEseq

**序列信号估计**

MACS

**短序列拼接**

Trinity

SOAPdenovo

**NGS数据操作工具集合**

samtools

BEDtools

BEDops

**分子进化相关的信息分析工具**

PAML

Treebest

转载请标明出处：

[http://zhoujj2013.github.io/UnCoverIt/bioinformatics/2014/07/17/bioinfo-tools-collect-and-use/](http://zhoujj2013.github.io/UnCoverIt/bioinformatics/2014/07/17/bioinfo-tools-collect-and-use/)


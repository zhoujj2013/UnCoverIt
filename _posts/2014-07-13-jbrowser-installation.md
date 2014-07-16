---
layout: post
title: "JBrowser:安装及配置"
description: "JBrowser installation and configuration"
category: "bioinformatics"
tags: ["bioinformatics", "visualization", "web"]
---
{% include JB/setup %}

这周有点空余时间，所以尝试着去把JBrowser配置好。从事生物信息分析已经４年了，在人们看来生物信息是个“高大上”的行当（虽然我不认为是这样），无论你的算法多么的ＮＢ，都无法离开肉眼的观察与判断。因为生物信息不是０／１的简单组合，也不是ＡＴＣＧ的简单排列，而是一首ＡＴＣＧ简单字符组成的长曲。

_希望JBrowser就像一个播放机一样，让你听到生命的赞歌，也希望您对生命的感悟超越前人。_

**选择[JBrowser](http://jbrowse.org/)的原因：**

+ 相对UCSC Genome Browser的配置，JBrowser配置更加简单，对硬件需求低，对数据库没有要求；

+ JBrowser是基于Javascript和HTML5构建的，对浏览器兼容性好；

+ UCSC Genome Browser只对一些重要的物种提供数据，而对新测序物种没有相应支持，JBrowser提倡自主定制数据；

+ JBrowser是[GMOD](http://gmod.org/wiki/Main_Page)的成员,其中GalaxybioMark等都是很成功的生物信息软件。

**JBrowser也有其致命的弱点：**

+ 基于Javascript和HTML5构建，信赖于浏览器处理和存储数据，很容易引起浏览器崩溃；

+ 所支持数据格式和格式转换支持不如UCSC；


**下面简述配置步骤：**

+ 下载及安装JBrowser，请参考（http://jbrowse.org/code/JBrowse-1.11.4/docs/tutorial/）；

{% highlight bash linenos=table %}
# make a directory that this user can write to	
sudo mkdir /var/www/jbrowse 
sudo chown `whoami` /var/www/jbrowse

# cd into it
cd /var/www/jbrowse;

# fetch a JBrowse release zip file
curl -O http://jbrowse.org/releases/JBrowse-x.x.x.zip

# unzip it and cd into it
unzip JBrowse-x.x.x.zip
cd JBrowse-x.x.x

#一定要确保你用的是bash shell
./setup.sh 
{% endhighlight %}

安装成功后，你可以通过浏览器查看默认配置的基因组。

{% highlight html %}
http://your.jbrowse.root/index.html?data=sample_data/json/volvox
{% endhighlight %}

+ JBrowser是如何工作的；

JBrowser读取json文件夹下的数据，然后根据track的信息来显示数据的。

json文件夹如下：

{% highlight html %}
path_to_json/json
	---hg19
	------trackList.conf  # 用来配置tracks
	------tracks.conf     # 用来配置tracks
	------names # 所有的名字
	------seq  # 参考基因组存放的地方
	------tracks # 所有要格式后的tracks数据存放的地方
	---hg18
	...
	---c.elegan
	...
{% endhighlight %}

hg19/hg18/c.elegan分别代表三个不同的基因组。

JBrowser先从主页面配置文件中读取主页的信息，再通过javascript调用，根据trackList.conf和tracks.conf中的配置信息读取tracks的数据，然后再返回到页面，这个过程没有通过数据库，所以如果读取大文件的话会花费一些时间。


+ JBrowser主页面配置；

下面列出一些主页面的主要配置文件：
{% highlight html %}
index.html        # 这个是主页html文件，里面都是javascript的调用
*.css             # 是对genome browser元件的样式进行设置的
jbrowse.conf      # 这两个是主页设置文件，一个是txt format，另外一个文件是json format，设置效果是一样的
jbrowse_conf.json # 这两个是主页设置文件，一个是txt format，另外一个文件是json format，设置效果是一样的
{% endhighlight %}

对about页面的设置：

{% highlight html %}
[aboutThisBrowser]
title = <i>Oryza sativa</i>        # 可以用markdown来设置
description = Browser for O. sativa transcripts and RNA-seq data, produced by the Smith laboratory at Example State University.
{% endhighlight %}

对于tracks面板的设置：

{% highlight html %}
[trackSelector] # 用#注释，表示不设置
type = Faceted
{% endhighlight %}

对于数据集的设置（对hg19数据进行开放）：

{% highlight html %}
[datasets.hg19]                    # datasets.<数据集的id>
url = ?data=/zhoujj_jb/json/hg19   #?data=<相对于jbrowser根目录的相对路径，json目录下>/hg19
name = hg19                        # 数据集的id
{% endhighlight %}

这些是主页面的基本设置，但是更重要的是，如何把自己的数据上传到JBrowser？这一部分的内存太多了。我先列一下，日后再补充。

这一部分主要包括:

+ 导入参考序列(reference genome)；

+ 导入UCSC tracks

+ 导入gff2/gtf/gff3

+ 导入bed文件

+ 导入bam/bigwig文件

+ 其它文件格式转化为jbrowser支持的格式


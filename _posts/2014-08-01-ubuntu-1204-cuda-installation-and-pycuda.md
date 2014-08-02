---
layout: post
title: "Ubuntu 12.04 LTS安装CUDA6.0及pycuda配置"
description: "ubuntu 12.04 cuda installation and pycuda"
category: "computing"
tags: ["ubuntu", "CUDA", "python"]
---
{% include JB/setup %}

操作系统：Ubuntu12.04 64位(本人只测试64位)
硬件环境：Intel Celeron D 2.8G + abit LG-95C + DDR2 2G 667 (见笑了，老机器)
显卡型号：Nvidia GeForce 210 512M

#### 删除ubuntu自带的nvida显卡driver

{% highlight sh %}
sudo apt-get -purge remove nvidia-common
{% endhighlight %}

将Ubuntu集成的Nvidia驱动加入黑名单防止冲突，如果之前没有安装过ubuntu的附加驱动，是可以的，否则的话必须将Ubuntu集成的驱动加入黑名单，具体的做法是修改/etc/modprobe.d/blacklist.conf文件：

{% highlight sh %}
sudo apt-get install vim
sudo vim /etc/modprobe.d/blacklist.conf
{% endhighlight %}

禁止其它显卡驱动运行，加入如下两行：

{% highlight html %}
blacklist nouveau
options nouveau modeset=0
{% endhighlight %}

#### 安装nvida驱动及CUDA tools kit

先要把安装依赖包安装：

{% highlight sh %}
sudo apt-get install freeglut3

#因为cuda安装程序只会去找libglut.so
sudo ln -s /usr/lib/x86_64-linux-gnu/libglut.so.3 /usr/lib/libglut.so
{% endhighlight %}

按Ctrl + Alt + F1进入tty命令行终端，登录之后首先将Ubuntu的X Server关闭，并重新启动：

{% highlight sh %}
sudo service lightdm stop
sudo reboot 
{% endhighlight %}

重启后，安装cuda 6.0:

{% highlight sh %}
sudo service lightdm stop

chmod 755 cuda_6.0.37_linux_64.run

sudo ./cuda_6.0.37_linux_64.run
{% endhighlight %}

接下来，同意安装提示，建议全部按yes或者enter，直到系统提示设置环境变量。

测试cuda 6.0是否安装成功：

{% highlight sh %}
sudo service lightdm start
nvidia-settings
{% endhighlight %}

如果能弹出setting的界面，说明已经安装成功。

#### 设置环境变量及动态链接库

在~/.bashrc中加入：

{% highlight html %}
export LD_LIBRARY_PATH=/usr/local/cuda-6.0/lib64:$LD_LIBRARY_PATH
export PATH=/usr/local/cuda-6.0/bin:PATH
{% endhighlight %}

更新环境变量：

{% highlight sh %}
source ~/.bashrc
{% endhighlight %}

在/etc/ld.so.conf.d/中，新建一个文件。因为ld.so.conf文件里include所有/etc/ld.so.conf.d/下的配置文件：

{% highlight sh %}
sudo vim /etc/ld.so.conf.d/cuda.conf
{% endhighlight %}

并加入：

{% highlight html %}
/usr/local/cuda-6.0/lib64
{% endhighlight %}

接着更新库：

{% highlight sh %}
sudo ldconfig

ldconfig -v|grep cuda
{% endhighlight %}

输出如下：

{% highlight html %}
/usr/local/cuda-6.0/lib64:
    libcudart.so.6.0 -> libcudart.so.6.0.35
    libicudata.so.48 -> libicudata.so.48.1.1
    libcuda.so.1 -> libcuda.so.304.54
{% endhighlight %}

说明已经更新成功。

#### 编译cuda6.0 samples

cuda6.0 samples有很多的文件，所以还要求有好几个库。

{% highlight sh %}
# 安装库包
sudo apt-get install g++ openmpi-bin openmpi-doc libopenmpi-dev freeglut3-dev libxi-dev libxmu-dev
# 编译文件,可以设置多线程编译, j4表示用4个cpu core
cd ~/NVIDIA_CUDA-6.0_Samples/
make j1 
{% endhighlight %}

测试：

{% highlight sh %}
cd NVIDIA_CUDA-6.0_Samples/bin/linux/release/
./deviceQuery
{% endhighlight %}

#### PyCUDA安装及配置



Reference:

[https://developer.nvidia.com/cuda-downloads](https://developer.nvidia.com/cuda-downloads)

[https://developer.nvidia.com/language-solutions](https://developer.nvidia.com/language-solutions)

[http://blog.163.com/thinki_cao/blog/static/83944875201303125444265/](http://blog.163.com/thinki_cao/blog/static/83944875201303125444265/)

[https://developer.nvidia.com/pycuda](https://developer.nvidia.com/pycuda)

[http://mathema.tician.de/software/pycuda/](http://mathema.tician.de/software/pycuda/)

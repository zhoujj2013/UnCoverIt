---
layout: post
title: "vim设置python关键字自动补全"
description: "Configure vim for python auto complete"
category: "python"
tags: ["python", "vim"]
---
{% include JB/setup %}

因为自己比较喜欢在linux工作，但是又不想放弃eclipse中python强大的python自动补全功能，所以在百度上查了一下如何设置。但是这些专家们写得很难懂，让我这种非科班出身的分析员来说，实在无法理解。在此，我解释一下如何配置。

首先，我们要实现的目标：

+ 简单python关键词补全；

+ python 函数补全带括号；

+ python 模块补全；

+ python 模块内函数，变量补全；

+ from module import sub-module 补全；

下面简述配置步骤：

+ 下载最新的pydiction（http://www.vim.org/scripts/script.php?script_id=850）

> mkdir ~/.vim/after/ftplugin/
>
> cd ~/.vim/after/ftplugin/
>
> git clone https://github.com/rkulla/pydiction.git
>
> cp pydiction/after/ftplugin/python_pydiction.vim .
>

vim自动会从~/.vim/after/ftplugin/读取配置文件，进行自动补全配置。

+ 配置~/.vimrc文件，开启自动补全

> vim ~/.vimrc

添加如下两句：

> filetype plugin on 
> 
> let g:pydiction_location = '/path/to/complete-dict'  #　告诉vim从这个文件查找python的关键字哈希表
>
> let g:pydiction_menu_height = 3 

已经成功实现功能。

+ 增加新模块关键字

某一些模块的关键字没有包含到默认的complete_dict中，当有新的模块时，要手动把新的模块关键字加到complete-dict文件。

pydiction文件夹下有一个程序pydiction.py可以实现模块字添加，以添加scipy包为例：

> cd ~/.vim/after/ftplugin/pydiction/
>
> python ./pydiction.py scipy # 会自动保存旧的complete-dict
> 

PS: vim最好的编辑器了，它没有脱离根本。它能使用户自己知道自己在做什么事情，而MS office不能。


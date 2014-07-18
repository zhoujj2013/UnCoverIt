---
layout: post
title: "Learn:利用shell和perl构建转录组(RNA-seq)分析流程"
description: "Mix together to build a RNA-seq pipeline."
category: "bioinformatics"
tags: ["bioinformatics", "RnaSeq", "NGS", "learn"]
---
{% include JB/setup %}

随着NGS的高速发展，越来越多有价值的物种被测序，随之而来的，基因表达及表观遗传数据会急剧增加。

公共数据库有大量已经公开的数据，这些数据大多数是基于二代测序技术产生的。

fly/C.elegan:

[http://www.modencode.org/](http://www.modencode.org/)

Mouse and Human:

[http://genome.ucsc.edu/ENCODE/](http://genome.ucsc.edu/ENCODE/)

GEO/ENA

[http://www.ncbi.nlm.nih.gov/geo/](http://www.ncbi.nlm.nih.gov/geo/)

[http://www.ebi.ac.uk/ena/](http://www.ebi.ac.uk/ena/)

#### zebra fish转录分析方案设计

**生物学问题**: 比较同一时期，male body 和 male head样品的基因表达的差异。

**数据来源**: 参考文章，[http://genome.cshlp.org/content/22/10/2067.long](http://genome.cshlp.org/content/22/10/2067.long)

male_body(ERR004012): 

ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR004/ERR004012/ERR004012_1.fastq.gz

ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR004/ERR004012/ERR004012_2.fastq.gz

male_head(ERR004022): 

ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR004/ERR004022/ERR004022_1.fastq.gz

ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR004/ERR004022/ERR004022_2.fastq.gz

**方案设计**:

![rna-seq_diagram](https://dl.dropboxusercontent.com/u/87531643/web/rna-seq.png "数据分析流程图")

#### 测序数据质量控制



#### 短reads比对及结果分析


#### 表达量计算及差异表达分析


#### 生物信息分析报告



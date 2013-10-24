#!/usr/bin/perl -w
use strict;
use File::Basename qw(basename dirname); 
use YAML;
use YAML qw(Dump Bless);
use HTML::Template;
#use Text::Markdown qw(markdown);
use Text::MultiMarkdown 'markdown';
use Data::Dumper;


# read in config file
open my $conf_fh,"<","./config.yml" || die $!;
my $config_raw = do { local $/; <$conf_fh> };
my $config = Load($config_raw);
close $conf_fh;

# print Dumper($config);
# read templat file and store in hash by HTML-Template modules
my %template;
my @tem_f = glob("$config->{'template'}/*");

foreach(@tem_f){
	my $b_name = basename($_);
	$template{$b_name} = HTML::Template->new(filename => $_);
}
# print Dumper(\%template);

# check the markdown file status and convert the xx.md file to html file
my $log;
if(-e "$config->{'log'}/md2html.log"){
	system("mv $config->{'log'}/md2html.log $config->{'log'}/md2html.log.bk") == 0 || die $!;
	# load log yml file from log dir
	open my $log_fh,"<","$config->{'log'}/md2html.log.bk" || die $!;
	my $log_raw = do{local $/; <$log_fh>};
	$log = Load($log_raw);
	close $log_fh;
}

# print Dumper($log);
# core part of the program
my $update_index = 0;
my %content;
my $i = 0;
foreach my $issue (@{$config->{'content'}}){
	my @md = glob("$issue->[1]/*.md");
	foreach(@md){
		# $name = 2012.12.03-Systems_biology_Flux_balance_analysis.md
		my $html_path = $1.".html" if(/(\S+).md$/);
		my $name = $1 if(/\S+-([^\.]+).md$/);
		$name =~ s/_/ /g;
		
		# $dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime, $blksize, $blockes
		my @stat = stat($_);
		my $time_num = $stat[9];
		my $modify_time = get_time($stat[9]);
		my $size = $stat[7];

		# check whether the file need to update
		if(exists $log->{$issue->[1]}{$_} && $log->{$issue->[1]}{$_}[2] == $time_num){
			# if time stamp is the same, skip the update step.
			my $action_type = "unchange";
			$content{$issue->[1]}{$_} = [$name,$size,$time_num,$modify_time,$html_path,$action_type];
		}else{
			# read in the xx.md file
			open IN,"$_" || die $!;
			my @mark_f = <IN>;
			close IN;
			my $title = $1 if($mark_f[0] =~ /^#\s+(.*)$/);
			my $md_text = join "",@mark_f;
			my $content_html = markdown($md_text);
			my $lastupdate = $modify_time;
			
			# create xx.html file based on template html
			if(defined $config->{'content'}[$i][2]){
				# convert markdown to html and add the markdown content to template file
				my $temp = $config->{'content'}[2];
				$template{$temp}->param(TITLE => $title);
				$template{$temp}->param(CONTENT => $content_html);
				$template{$temp}->param(LASTUPDATE => $lastupdate);
				write2html($html_path,$template{$temp});
			}else{
				# convert markdown to html and add the markdown content to template file
				$template{"default.html"}->param(TITLE => $title);
				$template{'default.html'}->param(CONTENT => $content_html);
				$template{'default.html'}->param(LASTUPDATE => $lastupdate);
				write2html($html_path,$template{'default.html'});
			}
			
			# check action type
			my $action_type;
			$action_type = "update" if(exists $log->{$issue->[1]}{$_});
			($action_type, $update_index) = ("add",1) if(!exists $log->{$issue->[1]}{$_});
			print STDERR "$action_type: $_ to html file\n";
			$content{$issue->[1]}{$_} = [$name,$size,$time_num,$modify_time,$html_path,$action_type];
		}
	}
	# to count which element are deal
	$i++;
}

# store the content record to yml log file
open OUT,">","$config->{'log'}/md2html.log" || die $!;
print OUT "# log file for pblog, you can load the file by YAML load function\n";
print OUT "# Data structure:\n";
print OUT "# \$hash{issue_name}{md_file_name}->(array)\n";
print OUT Dump(\%content);
close OUT;

# create the index file
my $index_text = "## Supervised classification (^_^)\n\n";
my $top_part;
my $low_part;
foreach my $issue (@{$config->{'content'}}){
	####
	my $tag = basename($issue->[1]);
	$top_part .= "+ [$issue->[0]]"."(#$tag)\n";

	####
	$low_part .= "<h3><a name=$tag>$issue->[0]</a></h3>\n\n";
	foreach my $f (keys %{$content{$issue->[1]}}){
		$low_part .= "+ [$content{$issue->[1]}{$f}[0]]($content{$issue->[1]}{$f}[4])\n";
	}
	$low_part .= "\n";
	$low_part .= "[Go to top](./index.html)\n";
}

$top_part .= "\n------------------------\n";
$index_text .= $top_part;
$index_text .= $low_part;

my $index_title = $config->{'index_title'};
my $index_content_html = markdown($index_text);
my $now = gmtime;

if(exists $config->{'index'}){
	$template{$config->{'index'}}->param(TITLE => $index_title);
	$template{$config->{'index'}}->param(CONTENT => $index_content_html);
	$template{$config->{'index'}}->param(LASTUPDATE => $now);
	write2html("./index.html",$template{$config->{'index'}});
}else{
	$template{'index_template.html'}->param(TITLE => $index_title);
	$template{'index_template.html'}->param(CONTENT => $index_content_html);
	$template{'index_template.html'}->param(LASTUPDATE => $now);
	write2html("./index.html",$template{'index_template.html'});
}

##########################################3
sub write2html{
	my ($html_f, $template_ref) = @_;
	open OUT,">","$html_f" || die $!;
	if($template_ref->output){
		print OUT $template_ref->output;
	}else{
		die "some wrong in writting html file: $html_f\n";
	}
	close OUT;
}

# input the stat() function time tag, and return common time format
sub get_time{
	my $str = shift @_;
	my ($sec, $min, $hour, $day, $mon, $year, $weekday, $yearday, $isdst) = localtime($str);
	$sec  = ($sec < 10)?"0$sec":$sec;
	$min  = ($min < 10)? "0$min":$min;
	$hour = ($hour < 10)? "0$hour":$hour;
	$day  = ($day < 10)? "0$day":$day;
	$mon  = ($mon < 9)? "0".($mon+1):($mon+1);
	$year += 1900;
	my $time = "$year-$mon-$day $hour:$min:$sec";
	return $time;
}

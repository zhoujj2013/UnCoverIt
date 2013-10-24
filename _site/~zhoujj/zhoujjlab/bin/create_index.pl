#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use File::Basename qw(dirname basename); 

my @file = glob("./*.html");

my %h;
foreach my $f (@file){
	my $y_m = $1 if($f =~ /\.\/(\d+\.\d+).*/g);
	if($f =~ /index\.html/){
		$h{'index'} = $f;
		next;
	}
	push @{$h{$y_m}},$f;
}

print "# MSc study in CUHK\n\n";
print "Ceate by [zhoujj][zjj]\n[zjj]: http://zhoujj2013.github.com/~zhoujj/\n\n";
foreach my $k (sort keys %h){
	next if($k =~ /index/);

	print "### $k\n\n";
	foreach my $l (@{$h{$k}}){
		my $str = $l;
		$str =~ s/_/ /g;
		#print $str,"\n";
		my $name = $1 if($str =~ /-(.*)\.html/);
		print "+ [$name]($l)\n";
	}
	print "\n";
}
print "[Go to top](./index.html)\n"
#print Dumper(\%h);
#print join "\n",@file;

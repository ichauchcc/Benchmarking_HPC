#!/usr/bin/perl

use strict; use warnings;
use Getopt::Long;
use Parallel::ForkManager;

# set a command line option variable (-sample); is required and is name of sample
my $sample ='';
my $bamdir ='';

GetOptions 	("sample=s" => \$sample,
			"bamdir=s" => \$bamdir
			);

# make array of genome intervals
my @intervals = glob("/project/CGSP/Targets_38/wgs_calling_regions.hg38_*.interval_list");

my $eightfork_manager = Parallel::ForkManager->new(8);

for (my $i = 0; $i < @intervals; $i++) {

    $eightfork_manager->start and next;
    my @param = ($i, $sample, $bamdir);
    HaplotypeCaller(join(" ", @param));
    $eightfork_manager->finish;
}

$eightfork_manager-> wait_all_children;

sub HaplotypeCaller {

	my $passed_param = shift(@_);
	my @sub_param = split(" ", $passed_param);
	my $p = $sub_param[0];
	my $name = $sub_param[1];
	my $bamdir = $sub_param[2];
	mkdir "/scratch/WGSHCM/hc.$name/$name$p";
	my $return_value = system("gatk", "--java-options", "-Xmx24g", "HaplotypeCaller", "--reference", "/project/CGSP/Refs/Homo_sapiens_assembly38.fasta", "--input", "/scratch/$bamdir/tempBAMs/".$name.".bam", "--tmp-dir", "/scratch/WGSHCM/hc.$name/$name$p", "--intervals", "$intervals[$p]", "--output", "/scratch/WGSHCM/tempVCFs/$name.$p.g.vcf.gz", "-ERC", "GVCF");

}

#!/usr/bin/perl -w
use strict;
use JSON qw( decode_json );

my $outdir = "fna";                                                                                                                                                                                                                         
unless(-e $outdir or mkdir($outdir)){                                                                                                                                                                                                       
    die "Cannot make $outdir\n";                                                                                                                                                                                                            
}

my @gto = glob("$ARGV[0]/*.gto");

foreach my $file ( @gto ){
    open GTO, $file;
    read(GTO, my $gto, (stat(GTO))[7]);
    close GTO;
    print "$file start processing...\n";
    my $decoded = decode_json($gto);
    my $seedid = $decoded->{'source_id'};
    print "$seedid start processing...\n";
    
    my %contigs = (); #collect contigs DNA
    
    for( my $i = 0; $i < scalar(@{$decoded->{'contigs'}}); $i++ ){
        $contigs{$decoded->{'contigs'}[$i]{'id'}} = $decoded->{'contigs'}[$i]{'dna'};
    }
    
    open FNA, ">./$outdir/$seedid.fna";
        
    foreach my $contig ( keys %contigs ){
        print FNA ">$contig\n$contigs{$contig}\n\n";
    }
    
    close FNA;
    print "$seedid finished processing...\n";
}
#!/usr/bin/perl -w
use strict;
use JSON qw( decode_json );

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
    
    open GFF, ">./gff/$seedid.gff";
    print GFF "##gff-version 3\n";
    print GFF "#Genome: $seedid\|$decoded->{'scientific_name'}\n\n";
    
    my %f_by_c = (); #store feature numbers by contig numbers
    
    for( my $i = 0; $i < scalar(@{$decoded->{'features'}}); $i++ ){ #attribute features to contigs
        push @{$f_by_c{$decoded->{'features'}[$i]{'location'}[0][0]}}, $i;
    }
    
    foreach my $cont ( keys %contigs ){
        if( not exists $f_by_c{$cont} ){
            print GFF "##sequence-region	$cont\t1\t" . length($contigs{$cont}) . "\n";
            next;
        }
        print GFF "##sequence-region	$cont\t1\t" . length($contigs{$cont}) . "\n";
        
        for( my $j = 0; $j < scalar @{$f_by_c{$cont}}; $j++){
            if($decoded->{'features'}[$f_by_c{$cont}[$j]]{'type'} eq 'peg' ){               #collect only CDS
                print GFF "$cont\t";
                print GFF "mcSEED\t";
                print GFF "CDS\t";
                if( $decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][2] eq "+" ){  #if the gene is on the forward strand write start first
                    print GFF $decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][1] . "\t" . ($decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][1] + $decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][3] - 1) . "\t";
                }else{                                                      #if the gene is on the reverse strand write end first
                    print GFF ($decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][1] - $decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][3] + 1) . "\t" . $decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][1] . "\t";
                }
                
                print GFF "\.\t" . $decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][2] . "\t0\t";
                print GFF "ID=" . $decoded->{'features'}[$f_by_c{$cont}[$j]]{'id'} . ";";
                if( exists $decoded->{'features'}[$f_by_c{$cont}[$j]]{'function'} ) {
                    print GFF "product=" . $decoded->{'features'}[$f_by_c{$cont}[$j]]{'function'};
                }else{
                    print GFF "product=Hypothetical protein";
                }
                print GFF "\n";
            }#else{
             #   print $decoded->{'features'}[$f_by_c{$cont}[$j]]{'type'}. "\n";
            #}
            
        }
    }
    
    print GFF "##FASTA \n";
    
    foreach my $contig ( keys %contigs ){
        print GFF ">$contig\n$contigs{$contig}\n\n";
    }
    
    close GFF;
    print "$seedid finished processing...\n";
}
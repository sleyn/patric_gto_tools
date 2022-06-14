#!/usr/bin/perl -w
use strict;
use JSON qw( decode_json );

my $outdir = "gff";                                                                                                                                                                                                                         
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
    
    open GFF, ">./$outdir/$seedid.gff";
    print GFF "##gff-version 3\n";
    print GFF "#Genome: $seedid\|$decoded->{'scientific_name'}\n\n";
    
    my %f_by_c = (); #store feature numbers by contig numbers
    
    for( my $i = 0; $i < scalar(@{$decoded->{'features'}}); $i++ ){ #attribute features to contigs
        push @{$f_by_c{$decoded->{'features'}[$i]{'location'}[0][0]}}, $i;
    }
    
    foreach my $cont ( keys %contigs ){     # process each contig
        if( not exists $f_by_c{$cont} ){
            print GFF "##sequence-region	$cont\t1\t" . length($contigs{$cont}) . "\n";
            next;
        }
        print GFF "##sequence-region	$cont\t1\t" . length($contigs{$cont}) . "\n";
        
        my %features = ();          # features hash for sorting purposes
        for( my $j = 0; $j < scalar @{$f_by_c{$cont}}; $j++){
            # if($decoded->{'features'}[$f_by_c{$cont}[$j]]{'type'} eq 'peg' ){               #collect only CDS
                my $pos = 0;        # fosition of feature
                if( $decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][2] eq "+" ){  #if the gene is on the forward strand write start first
                    $pos = $decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][1];
                }else{                                                      #if the gene is on the reverse strand write end first
                    $pos = ($decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][1] - $decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][3] + 1);
                }
                
                $features{$pos} = "$cont\t";
                $features{$pos} .= "mcSEED\t";
                $features{$pos} .= "CDS\t";
                if( $decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][2] eq "+" ){  #if the gene is on the forward strand write start first
                    $features{$pos} .= $decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][1] . "\t" . ($decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][1] + $decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][3] - 1) . "\t";
                }else{                                                      #if the gene is on the reverse strand write end first
                    $features{$pos} .= ($decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][1] - $decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][3] + 1) . "\t" . $decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][1] . "\t";
                }
                
                $features{$pos} .= "\.\t" . $decoded->{'features'}[$f_by_c{$cont}[$j]]{'location'}[0][2] . "\t0\t";
                $features{$pos} .= "ID=" . $decoded->{'features'}[$f_by_c{$cont}[$j]]{'id'} . ";";
                if( exists $decoded->{'features'}[$f_by_c{$cont}[$j]]{'function'} ) {
                	my $product = $decoded->{'features'}[$f_by_c{$cont}[$j]]{'function'};
                	$product =~ s/;/ \/ /g;			# remove ';' sign
                	$product =~ s/ => /, /g;		# remove '=>' sign
                    $features{$pos} .= "product=" . $product;
                }else{
                    $features{$pos} .= "product=Hypothetical protein";
                }
                $features{$pos} .= "\n";
            # }   
        }
        
        foreach my $pos ( sort {$a <=> $b} keys %features){         #sort features by positions
            print GFF $features{$pos};
        }
    }
    
    print GFF "##FASTA \n";     # add Fasta section
    
    foreach my $contig ( keys %contigs ){
        print GFF ">$contig\n$contigs{$contig}\n\n";
    }
    
    close GFF;
    print "$seedid finished processing...\n";
}
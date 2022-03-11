#!/usr/bin/perl -w
use strict;
use JSON qw( decode_json );

my $outdir = "faa";                                                                                                                                                                                                                         
unless(-e $outdir or mkdir($outdir)){                                                                                                                                                                                                       
    die "Cannot make $outdir\n";                                                                                                                                                                                                            
}

my @gto = glob("$ARGV[0]/*.gto");

foreach my $file ( @gto ){
    open GTO, $file;
    read(GTO, my $gto, (stat(GTO))[7]);
    close GTO;
    
    print "$file\n";
    my $decoded = decode_json($gto);
    my $seedid = $decoded->{'source_id'};
    print "$seedid start processing...\n";
    
    open FASTA, ">./$outdir/$seedid.fasta";
    
    for( my $i = 0; $i < scalar(@{$decoded->{'features'}}); $i++ ){
        if( $decoded->{'features'}[$i]{'id'} =~ m/\.peg\./ ){
            if( exists($decoded->{'features'}[$i]{'function'}) ){
                print FASTA ">$decoded->{'features'}[$i]{'id'} $decoded->{'features'}[$i]{'function'}\n";
            }else{
                print FASTA ">$decoded->{'features'}[$i]{'id'} Hypothetical protein\n";
            }
            print FASTA "$decoded->{'features'}[$i]{'protein_translation'}\n\n"
        }
    }
    
     print "$seedid finish processing...\n";
}
  
close FASTA;
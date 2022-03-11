# Tools for PATRIC GTO format

Scripts to convert PATRIC GTO format to other formats.

PATRIC database (the Pathosystems Resource Integration Center) [https://www.patricbrc.org/](https://www.patricbrc.org/) stores genomes in the GTO format. The GTO format is contains nucleotide and amino-acid sequences and various annotation information.

The repository provides lightweight scripts for converting GTO format to:

- FNA (nucleotide contigs in fasta format)
- FNN (genes nucleotide sequences in fasta format)
- FAA (translated genes amino acid sequences in fasta format)
- GFF (gene annotations and nucleotide contigs in GFF3 format)

## Scripts

Scripts are written on Perl and Python.

The Perl scrips require **JSON** library. It could be installed with CPAN (The Comprehensive Perl Archive Network): [https://metacpan.org/pod/JSON](https://metacpan.org/pod/JSON).

With **cpanm**:
```
cpanm JSON
```
With **CPAN shell**:
```
perl -MCPAN -e shell
install JSON
```

### GTO to FNA

Converts GTO files to files with nucleotide contigs in fasta format.

**Input:** Directory with GTO files. Files should have **".gto"** extension.

**Output:** Creates directory **"fna"** with ".fna" files.  One FNA file per one GTO file. Names preserved the same as in GTO files.

```
usage: perl fna_from_gto.pl [directory with GTO files]
```

### GTO to FNN

Converts GTO files to files with gene nucleotide sequences in fasta format.

**Input:** Directory with GTO files. Files should have **".gto"** extension.

**Output:** Make ".fnn" files in the directory defined by "-o" flag.  One FNN file per one GTO file. Names preserved the same as in GTO files.

```
usage: python3 fnn_from_gto.py [-h] [-g GTO] [-o OUTPUT]

Converts GTO files to FNN with nucleotide sequences for each gene

optional arguments:
  -h, --help            show this help message and exit
  -g GTO, --gto GTO     Directory with GTO files
  -o OUTPUT, --output OUTPUT
                        Output directory for FNN files
                        Default: "fnn" directory
```

### GTO to FAA

Converts GTO files to files with amino acid sequences in fasta format.

**Input:** Directory with GTO files. Files should have **".gto"** extension.

**Output:** Creates directory **"faa"** with ".faa" files.  One FAA file per one GTO file. Names preserved the same as in GTO files.

```
usage: perl faa_from_gto.pl [directory with GTO files]
```

### GTO to GFF3

Converts GTO files to files with annotations in GFF format. Script adds `##FASTA` section at the end of file that contains nucleotide contigs.

**Input:** Directory with GTO files. Files should have **".gto"** extension.

**Output:** Creates directory **"faa"** with ".faa" files.  One GFF file per one GTO file. **Names are generated from genome ids recorded in GTO file.**

Annotation records are often unsorted or sorted by position in reverse order. Two version of script:
- Script that sorts annotations in ascending order **(Preferred)**:

```
usage: perl gff_from_gto_sorted.pl [directory with GTO files]
```

- Script that outputs annotations in the order how they are written in GTO file:

```
usage perl gff_from_gto_no_sotring.pl [directory with GTO files]
```

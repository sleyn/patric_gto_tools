import json
import argparse
from glob import glob
from os import path
from os import mkdir

def feature_to_dict(feature_in, contigs_dict):
    feature_id = feature_in['id']
    function = feature_in.get('function', '')
    contig = feature_in['location'][0][0]
    start = int(feature_in['location'][0][1])
    strand = feature_in['location'][0][2]
    if strand == '+':
        start -= 1
        end = start + feature_in['location'][0][3] + 1
    else:
        end = start + 1
        start = start - feature_in['location'][0][3]
    header = ''.join(
        ['>', feature_id, ' ', contig, strand, ':', str(start + 1), '-', str(end - 1), ' ', function, '\n']
    )
    return header + contigs_dict[contig][start: end - 1]


parser = argparse.ArgumentParser(description='Converts GTO files to FNN with nucleotide sequences for each gene')
parser.add_argument('-g', '--gto', help='Directory with GTO files')
parser.add_argument('-o', '--output', default='fnn', help='Output directory for FNN files')
args = parser.parse_args()

# create output directory
if not path.exists(args.output):
    mkdir(args.output)

gto_files = glob(path.join(args.gto, '*.gto'))

for gto_f in gto_files:
    out_name = path.basename(gto_f).replace('.gto', '')
    gto = ''
    
    with open(gto_f, 'r') as gto_file:
        gto = json.loads(gto_file.read())
    
    print(f'GTO Loaded: {gto_f}')
    
    contigs = {contig['id']: contig['dna'] for contig in gto['contigs']}
    
    print(f'Contigs dictionary created: {len(contigs)} contigs')
    
    fnn = [feature_to_dict(feature, contigs) for feature in gto['features']]
    
    with open(path.join(args.output, out_name + '.fnn'), 'w') as output:
        output.write('\n'.join(fnn))
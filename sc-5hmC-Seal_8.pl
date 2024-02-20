#!/usr/bin/env  perl5
use  strict;
use  warnings;
use  v5.22;
## Perl5 version >= 5.22
## You can create a symbolic link for perl5 by using "sudo  ln  /usr/bin/perl   /usr/bin/perl5" in Ubuntu.
## Suffixes of all self-defined global variables must be "_g".
###################################################################################################################################################################################################





###################################################################################################################################################################################################
my $genome_g = '';  ## such as "mm39", "ce11", "hg38".
my $input_g  = '';  ## such as "6_finalBAM"
my $output_g = '';  ## such as "8_Number_Clusters"

{
## Help Infromation
my $HELP = '
        ------------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------------
        Caculate number of reads of each cluster, and determine which clusters (single cells) should be kept for further analysis.

        Usage:
               perl  sc-5hmC-Seal_8.pl    [-version]    [-help]   [-genome RefGenome]    [-in inputDir]    [-out outDir]
        For instance:
               nohup time  perl  sc-5hmC-Seal_8.pl   -genome hg38   -in 6_finalBAM   -out 8_Number_Clusters    > sc-5hmC-Seal_8.runLog.2_Bowtie2.txt   2>&1    &
        ----------------------------------------------------------------------------------------------------------
        Optional arguments:
        -version        Show version number of this program and exit.
        -help           Show this help message and exit.
        Required arguments:
        -genome RefGenome   "RefGenome" is the short name of your reference genome, such as "mm39", "ce11", "hg38".    (no default)
        -in inputDir        "inputDir" is the name of input path that contains your BAM files.  (no default)
        -out outDir         "outDir" is the name of output path that contains your running results of this step.  (no default)
        -----------------------------------------------------------------------------------------------------------
        For more details about this pipeline and other NGS data analysis piplines, please visit https://github.com/CTLife/2ndGS_Pipelines
        ------------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------------
';

## Version Infromation
my $version = "     The 8th Step, version 1.2,  2024-02-15.";

## Keys and Values
if ($#ARGV   == -1)   { say  "\n$HELP\n";  exit 0;  }       ## when there are no any command argumants.
if ($#ARGV%2 ==  0)   { @ARGV = (@ARGV, "-help") ;  }       ## when the number of command argumants is odd.
my %args = @ARGV;

## Initialize  Variables
$genome_g = 'hg38';          ## This is only an initialization value or suggesting value, not default value.
$input_g  = '6_finalBAM';    ## This is only an initialization value or suggesting value, not default value.
$output_g = '8_Number_Clusters';    ## This is only an initialization value or suggesting value, not default value.

## Available Arguments
my $available = "   -version    -help   -genome   -in   -out  ";
my $boole = 0;
while( my ($key, $value) = each %args ) {
    if ( ($key =~ m/^\-/) and ($available !~ m/\s$key\s/) ) {say    "\n\tCann't recognize $key";  $boole = 1; }
}
if($boole == 1) {
    say  "\tThe Command Line Arguments are wrong!";
    say  "\tPlease see help message by using 'perl  sc-5hmC-Seal_8.pl  -help' \n";
    exit 0;
}

## Get Arguments
if ( exists $args{'-version' }   )     { say  "\n$version\n";    exit 0; }
if ( exists $args{'-help'    }   )     { say  "\n$HELP\n";       exit 0; }
if ( exists $args{'-genome'  }   )     { $genome_g = $args{'-genome'  }; }else{say   "\n -genome is required.\n";   say  "\n$HELP\n";    exit 0; }
if ( exists $args{'-in'      }   )     { $input_g  = $args{'-in'      }; }else{say   "\n -in     is required.\n";   say  "\n$HELP\n";    exit 0; }
if ( exists $args{'-out'     }   )     { $output_g = $args{'-out'     }; }else{say   "\n -out    is required.\n";   say  "\n$HELP\n";    exit 0; }

## Conditions
$genome_g =~ m/^\S+$/    ||  die   "\n\n$HELP\n\n";
$input_g  =~ m/^\S+$/    ||  die   "\n\n$HELP\n\n";
$output_g =~ m/^\S+$/    ||  die   "\n\n$HELP\n\n";

## Print Command Arguments to Standard Output
say  "\n
        ################ Arguments ###############################
                Reference Genome:  $genome_g
                Input       Path:  $input_g
                Output      Path:  $output_g
        ###############################################################
\n";
}
###################################################################################################################################################################################################





###################################################################################################################################################################################################
say    "\n\n\n\n\n\n##################################################################################################";
say    "Running......";

sub myMakeDir  {
    my $path = $_[0];
    if ( !( -e $path) )  { system("mkdir  -p  $path"); }
    if ( !( -e $path) )  { mkdir $path  ||  die; }
}
my $output2_g = "$output_g/QC_Results";   
&myMakeDir($output_g);
&myMakeDir($output2_g);

opendir(my $DH_input_g, $input_g)  ||  die;
my @inputFiles_g = readdir($DH_input_g);
my $numCores_g   = 16;
###################################################################################################################################################################################################




###################################################################################################################################################################################################
say   "\n\n\n\n\n\n##################################################################################################";
say   "Detecting BAM files in input folder ......";
my @BAMfiles_g = ();
{
open(seqFiles_FH, ">", "$output2_g/BAM-Files.txt")  or  die; 
for ( my $i=0; $i<=$#inputFiles_g; $i++ ) {     
    next unless $inputFiles_g[$i] =~ m/\.bam$/;
    next unless $inputFiles_g[$i] !~ m/^[.]/;
    next unless $inputFiles_g[$i] !~ m/[~]$/;
    next unless $inputFiles_g[$i] !~ m/^unpaired/;
    say    "\t......$inputFiles_g[$i]"; 
    $BAMfiles_g[$#BAMfiles_g+1] =  $inputFiles_g[$i];
    say        "\t\t\t\tBAM file:  $inputFiles_g[$i]\n";
    say   seqFiles_FH  "BAM file:  $inputFiles_g[$i]\n";
}

say   seqFiles_FH  "\n\n\n\n\n";  
say   seqFiles_FH  "All BAM files:@BAMfiles_g\n\n\n";
say        "\t\t\t\tAll BAM files:@BAMfiles_g\n\n";
my $num1 = $#BAMfiles_g + 1;
say seqFiles_FH   "\nThere are $num1 BAM files.\n";
say         "\t\t\t\tThere are $num1 BAM files.\n";
}

###################################################################################################################################################################################################





###################################################################################################################################################################################################
say   "\n\n\n\n\n\n##################################################################################################";
say   "Start ......";

{

for ( my $i=0; $i<=$#BAMfiles_g; $i++ ) { 
    my $temp = $BAMfiles_g[$i];
    $temp =~ s/\.bam$//  or  die;
    
    system( "samtools  view  $input_g/$temp.bam  | cut -f 1  | awk  -F '::'   '{print \$2}'  > $output_g/$temp.1.allRows.txt "  );
    system( "sleep 3s " );
    system( "sort  $output_g/$temp.1.allRows.txt  | uniq -c  >   $output_g/$temp.2.uniq.txt" );
    system( "sleep 3s " );
    system( "sed  -i -e  's/^\s\+//g'   $output_g/$temp.2.uniq.txt" );
    system( "sleep 3s " );
    system( "sed  -i -e  's/\s\+/\t/g'  $output_g/$temp.2.uniq.txt" );
    system( "sleep 3s " );
    system( "awk  '\$1 > 10'    $output_g/$temp.2.uniq.txt  >  $output_g/$temp.3A.more-than-10.txt " );
    system( "awk  '\$1 > 1000'  $output_g/$temp.2.uniq.txt  >  $output_g/$temp.3B.more-than-1000.txt " );
    system( "awk  '\$1 > 3000'  $output_g/$temp.2.uniq.txt  >  $output_g/$temp.3C.more-than-3000.txt " );
    system( "awk  '\$1 > 5000'  $output_g/$temp.2.uniq.txt  >  $output_g/$temp.3D.more-than-5000.txt " );
 }

}
###################################################################################################################################################################################################




 

###################################################################################################################################################################################################
say   "\n\n\n\n\n\n##################################################################################################";
say   "\tJob Done! Cheers! \n\n\n\n\n";


 

  
## END

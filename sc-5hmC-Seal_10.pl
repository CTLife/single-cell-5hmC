#!/usr/bin/env  perl5
use  strict;
use  warnings;
use  v5.22;
###################################################################################################################################################################################################





###################################################################################################################################################################################################
my $input_g  = '';  ## such as "6_finalBAM"
my $output_g = '';  ## such as "10_singleCells"

{
## Help Infromation
my $HELP = '
        ------------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------------
        Get reads for each single cell.

        Usage:
               perl  sc-5hmC-Seal_10.pl    [-version]    [-help]      [-in inputDir]    [-out outDir]
        For instance:
               nohup time  perl  sc-5hmC-Seal_10.pl      -in 6_finalBAM   -out 10_singleCells    > sc-5hmC-Seal_10.runLog.txt   2>&1    &
        ----------------------------------------------------------------------------------------------------------
        Optional arguments:
        -version        Show version number of this program and exit.
        -help           Show this help message and exit.
        Required arguments:
        -in inputDir        "inputDir" is the name of input path that contains your BAM files.  (no default)
        -out outDir         "outDir" is the name of output path that contains your running results of this step.  (no default)
        -----------------------------------------------------------------------------------------------------------
        For more details about this pipeline and other NGS data analysis piplines, please visit https://github.com/CTLife/2ndGS_Pipelines
        ------------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------------
';

## Version Infromation
my $version = "     The 10th Step, version 1.2,  2024-02-15.";

## Keys and Values
if ($#ARGV   == -1)   { say  "\n$HELP\n";  exit 0;  }       ## when there are no any command argumants.
if ($#ARGV%2 ==  0)   { @ARGV = (@ARGV, "-help") ;  }       ## when the number of command argumants is odd.
my %args = @ARGV;

## Initialize  Variables
$input_g  = '6_finalBAM';        ## This is only an initialization value or suggesting value, not default value.
$output_g = '10_singleCells';    ## This is only an initialization value or suggesting value, not default value.

## Available Arguments
my $available = "   -version    -help      -in   -out  ";
my $boole = 0;
while( my ($key, $value) = each %args ) {
    if ( ($key =~ m/^\-/) and ($available !~ m/\s$key\s/) ) {say    "\n\tCann't recognize $key";  $boole = 1; }
}
if($boole == 1) {
    say  "\tThe Command Line Arguments are wrong!";
    say  "\tPlease see help message by using 'perl  sc-5hmC-Seal_10.pl  -help' \n";
    exit 0;
}

## Get Arguments
if ( exists $args{'-version' }   )     { say  "\n$version\n";    exit 0; }
if ( exists $args{'-help'    }   )     { say  "\n$HELP\n";       exit 0; }
if ( exists $args{'-in'      }   )     { $input_g  = $args{'-in'      }; }else{say   "\n -in     is required.\n";   say  "\n$HELP\n";    exit 0; }
if ( exists $args{'-out'     }   )     { $output_g = $args{'-out'     }; }else{say   "\n -out    is required.\n";   say  "\n$HELP\n";    exit 0; }

## Conditions
$input_g  =~ m/^\S+$/    ||  die   "\n\n$HELP\n\n";
$output_g =~ m/^\S+$/    ||  die   "\n\n$HELP\n\n";

## Print Command Arguments to Standard Output
say  "\n
        ################ Arguments ###############################
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
&myMakeDir($output_g);

opendir(my $DH_input_g, $input_g)  ||  die;
my @inputFiles_g = readdir($DH_input_g);
my $numCores_g   = 16;
###################################################################################################################################################################################################




###################################################################################################################################################################################################
say   "\n\n\n\n\n\n##################################################################################################";
say   "Detecting BAM files in input folder ......";
my @BAMfiles_g = ();
{
for ( my $i=0; $i<=$#inputFiles_g; $i++ ) {     
    next unless $inputFiles_g[$i] =~ m/\.bam$/;
    next unless $inputFiles_g[$i] !~ m/^[.]/;
    next unless $inputFiles_g[$i] !~ m/[~]$/;
    next unless $inputFiles_g[$i] !~ m/^unpaired/;
    say    "\t......$inputFiles_g[$i]"; 
    $BAMfiles_g[$#BAMfiles_g+1] =  $inputFiles_g[$i];
    say        "\t\t\t\tBAM file:  $inputFiles_g[$i]\n";
}

say        "\t\t\t\tAll BAM files:@BAMfiles_g\n\n";
my $num1 = $#BAMfiles_g + 1;
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
    open(FH1, "<", "8_Number_Clusters/$temp.3B.more-than-1000.txt")  or  die; 
    my @lines1 = <FH1>;
    &myMakeDir("$output_g/$temp");

    for(my $j=0; $j<=$#lines1; $j++){
        $lines1[$j] =~ m/^(\d+)\t(\S+)\n$/ or die;
        my $name = $2;
        say("###########################");
        my $name2= $name;
        $name =~ s/\[/\\[/g or die;
        $name =~ s/\]/\\]/g or die;
        say($name);
        my $cmd1 = "samtools  view -hb --threads 4  -e  aaaa qname =~ bbbb$name.bbbb aaaa  -o $output_g/$temp/$name2.bam  $input_g/$temp.bam "; 
        $cmd1 =~ s/aaaa/\'/g or die;
        $cmd1 =~ s/bbbb/\"/ or die;
        $cmd1 =~ s/\.bbbb/\"/ or die;
        say($cmd1);
        system(  " nohup $cmd1 >> $output_g/$temp.runLog.txt 2>&1  &"); 
        if($j =~ m/\d+0$/){  system("sleep 2m"); }
        
    }
    
 }

}
###################################################################################################################################################################################################

 

###################################################################################################################################################################################################
say   "\n\n\n\n\n\n##################################################################################################";
say   "\tJob Done! Cheers! \n\n\n\n\n";


 

  
## END

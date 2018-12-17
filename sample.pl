#!/usr/bin/perl -w

use strict;


## Input file of basic data. Has filtered data. 
my $input_filename = "dtc_filtered.tsv";
my $output_filename = "kd_values.txt";

## Hash to carry the drug->Protein mappings. 
my %hoa_drug_protein_hash;
my %lookup_drug_protein;

## Need to create a separate protein->drug mappings


## Other variables
my $size;
my @sections;
my @words;
my $drug_inchikey;
my $target;
my $KD_value;

## File handles
my $fh1;
my $fh2;

## Opening file handles. 
open( $fh1, $input_filename ) || die "Cannot open file $input_filename : $! \n";

open( $fh2, '>', $output_filename ) || die "Cannot open file $output_filename : $! \n";


## Splurp the file into an array for parsing
my @file_lines = <$fh1>;

## Biggest loop as we go line by line of parsing
foreach my $line ( @file_lines ) {

    my @target_words;
    my @protein;
    
    ## Split the line to figure out if KD exists
    @words = split( /\s+/, $line );

    ## Only handle the KD measurements - drop the rest
    if ( $words[2] eq "KD" ) {

	## Split line to get all the basic data per line
	## Values : drug name, Inchikeys, standard type, 
	## standard relation, standard value, assay_format, 
	## assay_subtype, target_id
	#@sections = split( / KD /, $line );
	#print "section 1 = $sections[0] \n";
	#print "section 2 = $sections[1] \n";

	#@words = split( /\s+/, $sections[0] ); 
	$drug_inchikey = $words[1];
	#$hoa_drug_protein_hash{$drug_inchikey} = 1;
	#print "drug_inchikey = $drug_inchikey \n";

	#@words = split( /\s+/, $sections[1] );
	$KD_value = $words[4];
	#print "KD value : $KD_value \n";

	$target = $words[7];
	#print "target : $target \n";
	if ( scalar(@words) > 7 ) {
	    for ( my $k = 7; $k < scalar(@words); $k++ ) {
		if ( $words[$k] =~ /,/ ) {
		    @protein = split( /,/, $words[$k] );
		    $target = $protein[0];
		    #print "after chomp : Adding to target : $target \n";
		} else {
		    $target = $words[$k];
		}
		#print "Adding to target : $target \n";
		push( @target_words, $target );
	    }
	} else {
	    push( @target_words, $target );
	    #print "Adding to only target : $target \n";
	}

	## if the inchikeys is not missing
	if ( $drug_inchikey ne "NA" ) {

	    my @pair_arr;
	    my @protein_pair_arr;

	    print "Found KD : $line \n";
	    #print $fh2 "$line"; 

	    ## Find the target_id and find out if there are multiple targets available
	    ## if there are multiple targets, each target should create a new entry in the array. 
	    foreach my $item ( @target_words ) {
		my %pair_hash;
		my $pair_hash_ref = {};

		my $drug_and_protein = $drug_inchikey.$item;
		if ( !defined( $lookup_drug_protein{$drug_and_protein} ) ) {

		    $lookup_drug_protein{$drug_and_protein} = 1;
		    #print "item = $item \n";
		    $pair_hash_ref->{'target'} = $item;
		    $pair_hash_ref->{'KD'}     = $KD_value;
		    #print "Pushing : target = $pair_hash_ref->{'target'} + KD = $pair_hash_ref->{'KD'} \n";
		    push( @protein_pair_arr, $pair_hash_ref );
		    
		    if ( defined( $hoa_drug_protein_hash{$drug_inchikey} ) ) {
			print "Found a MATCHING drug already seen. \n";		
			push( @{$hoa_drug_protein_hash{$drug_inchikey}}, $pair_hash_ref );
		    } else {
			$hoa_drug_protein_hash{$drug_inchikey} = [ $pair_hash_ref ];		    
		    }

		} else {
		    print "ERROR : Lookup of $drug_inchikey and $item already done. \n";
		    next;
		}

		#print "Available in hash : drug $drug_inchikey :";
		#print $fh2 "drug $drug_inchikey :";
		#foreach my $item1 ( @protein_pair_arr ) {
		#    print ": $item1->{'target'} : $item1->{'KD'}";
		#    print $fh2 ": $item1->{'target'} : $item1->{'KD'}";
		#}
		#print "\n";
		#print $fh2 "\n";

		#print "Also Available in hash : drug $drug_inchikey :";
		#print $fh2 "Also drug $drug_inchikey :";
		#foreach my $item2 ( @{$hoa_drug_protein_hash{$drug_inchikey}} ) {
		#    print ": $item2->{'target'} : $item2->{'KD'}";
		#    print $fh2 ": $item2->{'target'} : $item2->{'KD'}";
		#}
		#print "\n";
		#print $fh2 "\n";

		## Make sure to empty the arrays used.
		@protein_pair_arr = ();
		@pair_arr = ();

	    }

	} ## end if inchikeys is  not NA

	@target_words = ();
 

    }  ## end if type is KD

}

$size = keys %hoa_drug_protein_hash;
print "number of unique drugs = $size \n";

close($fh1);
close($fh2);

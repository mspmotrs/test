#!/usr/bin/perl -w

use strict;
use warnings;


my $filename_DEBUG = 'MS_DEBUG_FILE_test_EAI_endpoint.log';
open(FILEDEBUG, ">> $filename_DEBUG ");

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $mon++;
    $year += 1900;

	print FILEDEBUG "---------- [$year-$mon-$mday $hour:$min:$sec] ----------  \n";
	print FILEDEBUG "ENV{'REQUEST_METHOD'} = $ENV{'REQUEST_METHOD'} \n";
	print FILEDEBUG "ENV{'CONTENT_LENGTH'} = $ENV{'CONTENT_LENGTH'} \n";
	print FILEDEBUG "ENV{'QUERY_STRING'} = $ENV{'QUERY_STRING'} \n";





# ----------------- l'XML arriva via POST  (inizio) -----------------
    my ($MS_buffer, @MS_coppie, $MS_coppia, $MS_name, $MS_value, %MS_FORM);
    # Read in text
    $ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
    if ($ENV{'REQUEST_METHOD'} eq "POST")
    {
        read(STDIN, $MS_buffer, $ENV{'CONTENT_LENGTH'});
    }
    else # GET, HEAD
    {
    	exit(2); #solo POST viene supportato
		#$MS_buffer = $ENV{'QUERY_STRING'};
    }
    
    print FILEDEBUG "MS_buffer = $MS_buffer \n";
    
    # Split information into name/value pairs
    @MS_coppie = split(/&/, $MS_buffer);
    foreach $MS_coppia (@MS_coppie)  #TODO: permettere una sola coppia
    {
		($MS_name, $MS_value) = split(/=/, $MS_coppia);    # split string on '&' characters
		$MS_value =~ tr/+/ /;                        # replace "+" with a space
		$MS_value =~ s/%(..)/pack("C", hex($1))/eg;  # WARNING: replace any two characters
                                                  # preceeded by a percent sign with
                                                  # their own packed hex value. See the
                                                  # perl "pack()" function for details
		
		$MS_FORM{$MS_name} = $MS_value;
    }
    
    
    
    my $XMLrequest = "";
    if(exists($MS_FORM{XMLrequest})) #se sto usando il FORM di test
    {
    	$XMLrequest = $MS_FORM{XMLrequest}; #ATTENZIONE: suppongo che il nome della variabile che contiene l'xml sia "XMLrequest"
    }
    else #altrimenti prendo TUTTO quello che mi viene passato via POST
    {
    	$XMLrequest = $MS_buffer;
    }
    
# ----------------- l'XML arriva via POST  (fine) -----------------






#print "Content-type: text/html\n\n";
print "Content-type: text/xml\n\n";
print '<?xml version="1.0" encoding="UTF-8"?>';  
print "\n";

print "<OTRS_API>\n";
print "<TicketResponse>\n";
print "<Header>\n";
print "<TimeStamp></TimeStamp>\n";
print "<DestinationChannel>WIND</DestinationChannel>\n";
print "<SourceChannel>OTRS</SourceChannel>\n";
print "<BusinessId>unknow</BusinessId>\n";
print "<TransactionId>201312231890</TransactionId>\n";
print "</Header>\n";
print "<ResultStatus>\n";
print "<StatusCode>0</StatusCode>\n";


 print "<idTT>wind-1111</idTT>\n";
 
#if ($XMLrequest =~ m/\<action\>CREATE\<\/action\>/mi)
#{
#   print "<TicketID>wind-1111</TicketID>\n";
#}
#elsif ($XMLrequest =~ m/\<action\>UPDATE\<\/action\>/mi)
#{
#   print "<Status>APERTO</Status>\n";
#}


#print "<ERROR_CODE>$MS_error_code</ERROR_CODE>\n" if($MS_status_code == 1);
#print "<ERROR_DESCRIPTION>$MS_error_descr</ERROR_DESCRIPTION>\n" if($MS_status_code == 1);
print "</ResultStatus>\n";	
print "</TicketResponse>\n";
print "</OTRS_API>\n";




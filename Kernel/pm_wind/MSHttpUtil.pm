package MSHttpUtil;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

# Exporting the saluta routine
our @EXPORT = qw(MS_ReadHttpPost);
# Exporting the saluta2 routine on demand basis.
#our @EXPORT_OK = qw(saluta2);




# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/../cpan-lib";




# ----------------- Moduli custom necessari ------------------
use MSErrorUtil;







############################################################################
# Legge quello che arriva via POST (HTTP)
# e fatti alcuni controlli
#
# input:
#     ptr alla var da popolare con quanto letto dal POST
#		ptr al $LogObject_ptr di OTRS (per il logging) - opzionale
#		logging_level (impostato nella config specifica PMWind) - opzionale
#		error_ptr (puntatore alla struttura degli errori) - opzionale
#
# output:
#     contenuto arrivato via POST
#
# Nota: suppone che arrivi una singola var (con nome - utile per i test - o senza nome)
#
# Nota 2: uso un ptr in ingresso perche', grazie agli allegati, mi aspetto variabili "corpose"
sub MS_ReadHttpPost
{
	
	my $content_ptr = shift;
	my $LogObject_ptr = shift;
	my $logLevel = shift;
	my $errors_ptr = shift;
	
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
		
		if(defined($LogObject_ptr) and (ref $LogObject_ptr eq 'HASH') )
		{
			$LogObject_ptr->Log( Priority => 'error', Message => "_MSFull_ [MS_ReadHttpPost]: Arrivato qualcosa via HTTP ma non via POST. Interrompo l'esecuzione. Dettagli:\n $MS_buffer");
		}

      
		if (exists($errors_ptr->{InternalCode}))
		{
			#setto l'errore che verra' controllato nella subroutine a monte...
			MS_AssignInternalErrorCode( MS_WhoAmI(), 10, \$errors_ptr->{InternalCode}, \$errors_ptr->{InternalDescr});
			$errors_ptr->{StopEsecution} = 1; # "prenoto" una exit
		}
		
      #Non forzo la exit qui... lo faro' solo nella gestione dell'errore (modulo MSErrorUtil)
    	#exit(2); #solo POST viene supportato
		
		#$MS_buffer = $ENV{'QUERY_STRING'};
    }
    
    #print FILEDEBUG "MS_buffer = $MS_buffer \n" if($MS_DEBUG);
    

    # Split information into name/value pairs
	 # ATTENZIONE: vincolo al solo debug via form HTML
	 if ($MS_buffer =~ m/^MSXMLtest=/)
	 {
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
	 }
	 

    
    
	 
	 
	#logging...
	if (defined($logLevel) )
	{
		#al livello massimo di log (livello 3)... loggo anche la POST raw
		if ($logLevel > 2)
		{
			if(defined($LogObject_ptr) and (ref $LogObject_ptr eq 'HASH') )
			{
				$LogObject_ptr->Log( Priority => 'notice', Message => "_MSFull_ [MS_ReadHttpPost] - raw POST:\n $MS_buffer");
			}
		}
		
		#loggo la POST  dal livello 2 (utile solo per il debug con form HTML)
		if (exists($MS_FORM{MSXMLtest}) and $logLevel >= 2)
		{
			if(defined($LogObject_ptr) and (ref $LogObject_ptr eq 'HASH') )
			{
				$LogObject_ptr->Log( Priority => 'notice', Message => "_MSFull_ [MS_ReadHttpPost] - MSXMLtest via POST:\n $MS_FORM{MSXMLtest}");
			}
		}
		
	}
	
	
    
	#Valorizzazione var per il ritorno....
    if(exists($MS_FORM{MSXMLtest})) #se sto usando il FORM di test
    {
    	$$content_ptr = $MS_FORM{MSXMLtest}; #ATTENZIONE: suppongo che il nome della variabile che contiene l'xml sia "MSXMLtest"
    }
    else #altrimenti prendo TUTTO quello che mi viene passato via POST
    {
    	$$content_ptr = $MS_buffer;
    }
    
	# ----------------- l'XML arriva via POST  (fine) -----------------


}





1;

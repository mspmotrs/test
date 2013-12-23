package MSResponseToWindUtil;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

# Exporting the saluta routine
our @EXPORT = qw(MS_ResponseBuild MS_ResponseBuildAndSend MS_Response_OK_BuildAndSend MS_Response_GenericInternalError_BuildAndSend);
# Exporting the saluta2 routine on demand basis.
#our @EXPORT_OK = qw(saluta2);




# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/../cpan-lib";




# ----------------- Moduli custom necessari ------------------
#use MSXMLUtil;
#use MSTicketUtil;
# ----------------- Moduli custom necessari (fine) ------------------


# Struttura XML che verra' costruita:
#
#<?xml version="1.0" encoding="UTF-8"?>                       	  
#<OTRS_API>
#<TicketResponse>
#
#<Header>
#	<SourceChannel>xxxx</SourceChannel>
#	<DestinationChannel>xxxx</DestinationChannel>
#	<TimeStamp>xxxx</TimeStamp>
#	<TransactionId>xxxx</TransactionId>
#	<BusinessId>xxxx</BusinessId>
#</Header>
#
#<ResultStatus>
#	<StatusCode>xxxx</StatusCode>
#	<ErrorMessage>xxxx</ErrorMessage>
#	<ErrorDescription>xxxx</ErrorDescription>
#</ResultStatus>
#
#</TicketResponse>
#</OTRS_API>



#my $MS_HTTP_header = "Content-type: text/html\n\n"; #HTML
my $MS_HTTP_header = "Content-Type: text/xml\n\n"; #XML
 

my $MS_Response_container_start = '<?xml version="1.0" encoding="UTF-8"?>'."\n\n";
$MS_Response_container_start .= "<OTRS_API>\n<TicketResponse>\n";
my $MS_Response_container_end = "\n</TicketResponse>\n</OTRS_API>\n";

my $MS_Response_header_container_tag = 'Header';
my $MS_Response_body_container_tag = 'ResultStatus';

my %MS_Response_header = (
	SourceChannel => 'OTRS',
	DestinationChannel => 'WIND',
	TimeStamp => '',
	#Username => '',
	#Password => '',
	#MessageType => '',
	#MessageCode => '',
	TransactionId => '',
	#MessageId => '',
	BusinessId => '', #come devo popolarlo?
);

my %MS_Response_body = (
	StatusCode => 1,  # 0 = success, 1 = error
	ErrorMessage => '', #Codice di errore
	ErrorDescription => '', #Descrizione estesa dell'errore
	#TicketID => '', #TicketID dell'Alarm appena creato (se si tratta di una Response ad una Create da parte di Wind)
);





# input:
#
# Puntatore ad un hash che contiene le seguenti info:
#	StatusCode => (0 = success, 1 = error) codice da inviare a Wind
#	ErrorMessage => Codice di errore
#	ErrorDescription => Descrizione estesa dell'errore
#  TicketID => TicketID dell'Alarm appena creato (se si tratta di una Response ad una Create da parte di Wind)
#  TransactionId => nella response devo mantenere quello della request
#
# output:
#
# stringa che rappresenta l'XML della Response da inviare
#
sub MS_ResponseBuild
{
	my $MS_Response_info_ptr = shift;
	
	$MS_Response_body{StatusCode} = $MS_Response_info_ptr->{StatusCode} if(exists($MS_Response_info_ptr->{StatusCode}));
	$MS_Response_body{ErrorMessage} = $MS_Response_info_ptr->{ErrorMessage} if(exists($MS_Response_info_ptr->{ErrorMessage}));
	$MS_Response_body{ErrorDescription} = $MS_Response_info_ptr->{ErrorDescription} if(exists($MS_Response_info_ptr->{ErrorDescription}));
	$MS_Response_body{TransactionId} = $MS_Response_info_ptr->{TransactionId} if(exists($MS_Response_info_ptr->{TransactionId}));
	$MS_Response_body{BusinessId} = $MS_Response_info_ptr->{BusinessId} if(exists($MS_Response_info_ptr->{BusinessId}));
	
	$MS_Response_body{TicketID} = $MS_Response_info_ptr->{TicketID} if(exists($MS_Response_info_ptr->{TicketID}));

	my $header = MS_ResponseBuild_header(\%MS_Response_header);
	my $body = MS_ResponseBuild_body(\%MS_Response_body);

	my $response = $MS_Response_container_start;
	$response .= $header;
	$response .= $body;
	$response .= $MS_Response_container_end;
	
	return $response;
}





#Come la MS_ResponseBuild, con aggiunto l'invio (la print)
sub MS_ResponseBuildAndSend
{
	my $MS_Response_info_ptr = shift;
	
	#serve l'header prima di ogni cosa...
	print $MS_HTTP_header;
	
	my $response = MS_ResponseBuild($MS_Response_info_ptr);
	print $response;

	
	return $response;
}





# input:
#
# Puntatore ad un hash che contiene le seguenti info:
#	SourceChannel => 'OTRS',
#	DestinationChannel => 'WIND',
#	TimeStamp => '',
#	TransactionId => '', #come devo popolarlo?
#	BusinessId => '', #come devo popolarlo?
#
# output:
# XML del solo header
sub MS_ResponseBuild_header
{	
	my $MS_Response_header_ptr = shift;

	#Timestamp
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	$mon += 1;
	$year += 1900;
	
	#uso questo formato YYYY-MM-DDTHH:MM:SS
	$MS_Response_header_ptr->{TimeStamp} = "$year-$mon-$mday".'T'."$hour:$min:$sec";
	
	#Transaction ID; identifica l'ID univoco della transazione, per i servizi sincroni questa informazione deve rimanere la stessa sia per la request che per la response
	#$MS_Response_header_ptr->{TransactionId} = "$year$mon$mday$hour$min$sec";
	
	my $XML_tags = '';
	foreach my $key (keys %{$MS_Response_header_ptr})
	{
		#Nota: proteggo tutti i contenuti dal parsing con <![CDATA[XXXXXX]]>
		$XML_tags .= '<'.$key.'><![CDATA['.$MS_Response_header_ptr->{$key}.']]></'.$key.">\n";
	}
	
	my $XML_header = '<'.$MS_Response_header_container_tag.">\n";
	$XML_header .= $XML_tags;
	$XML_header .= '</'.$MS_Response_header_container_tag.">\n";
	
	return $XML_header;
}


# input:
#
# Puntatore ad un hash che contiene le seguenti info:
#	StatusCode => (0 = success, 1 = error) codice da inviare a Wind
#	ErrorMessage => Codice di errore
#	ErrorDescription => Descrizione estesa dell'errore 
#
# output:
#
# stringa che rappresenta l'XML del solo body
#
sub MS_ResponseBuild_body
{	
   my $MS_Response_body_ptr  = shift;

	#Ricevo le info gia' popolate e quindi devo solo costruire l'XML...
	

	my $XML_tags = '';
	foreach my $key (keys %{$MS_Response_body_ptr})
	{
		#Nota: proteggo tutti i contenuti dal parsing con <![CDATA[XXXXXX]]>
		$XML_tags .= '<'.$key.'><![CDATA['.$MS_Response_body_ptr->{$key}.']]></'.$key.">\n";
	}
	
	my $XML_body = '<'.$MS_Response_body_container_tag.">\n";
	$XML_body .= $XML_tags;
	$XML_body .= '</'.$MS_Response_body_container_tag.">\n";
	
	return $XML_body;
}







#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------





################################################
# Invia una response di OK
################################################
# input:
#  - TransactionId: da conservare nella response (uguale alla request) - opzionale
#  - TicketID: TicketID dell'Alarm appena creato (se si tratta di una Response ad una Create da parte di Wind) - opzionale
#
# output:
#	<nulla>
#
sub MS_Response_OK_BuildAndSend
{
	my $TransactionId = shift;
	my $TicketID = shift;

	my $infoHashForResponse = {
			StatusCode => 0,
			TransactionId => $TransactionId,
	};

	$infoHashForResponse->{TicketID} = $TicketID if(defined($TicketID) and $TicketID !~ m/^\s*$/i);
	
	my $response = MS_ResponseBuild($infoHashForResponse);

	print $response;
}





################################################
# Invia una generica response di errore interno
################################################
# input:
# transactionId da conservare nella response (uguale alla request) - opzionale
#
# output:
#	<nulla>
#
sub MS_Response_GenericInternalError_BuildAndSend
{
	my $TransactionId = shift;
	
	my $infoHashForResponse = {
		StatusCode => 1,
		ErrorMessage => 400,
		ErrorDescription => 'Errore interno',
		TransactionId => $TransactionId,
	};

	
	my $response = MS_ResponseBuild($infoHashForResponse);
	
	
	print $response;
}







1;

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
 

my $MS_Response_container_start = '<?xml version="1.0" encoding="UTF-8"?>'."\n";
$MS_Response_container_start .= "<OTRS_API ".'xmlns="http://www.tibco.com/schemas/OTTM/EnterpriseServices/InfrastrutureObject/Schemas/CommonSchemas/OTTM/TroubleTicket_OTRS.xsd"'.">\n<TicketResponse>\n";
my $MS_Response_container_end = "</TicketResponse>\n</OTRS_API>\n";

my $MS_Response_header_container_tag = 'Header';
#my $MS_Response_body_container_tag = 'ResultStatus';
my $MS_Response_body_container_tag = 'Response';

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
	StatusCode => 1,  # 0 = success, 1 = error  --> legacy
	ErrorMessage => '', #Codice di errore
	ErrorDescription => '', #Descrizione estesa dell'errore
	#TicketID => '', #TicketID dell'Alarm appena creato (se si tratta di una Response ad una Create da parte di Wind)
	#idTT => '', #TicketID dell'Alarm appena creato (se si tratta di una Response ad una Create da parte di Wind)
);










sub _MS_CalcTimestamp_ResponseToWind
{
	my $type = shift; # Timestamp -> ritorna il formato previsto per "Timestamp" (campo dell'header)
							# TimestampTT -> ritorna il formato previsto per "TimestampTT" (campo del body)
							
	my $rit = '';
	
	if (!defined($type))
	{
		return $rit;
	}
	


	my  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = my @t = localtime(time);
	$year += 1900;
	$mon += 1;
	
	$sec =~ s/^(\d)$/0$1/; #aggiungo una cifra se necessario
	$min =~ s/^(\d)$/0$1/; #aggiungo una cifra se necessario
	$hour =~ s/^(\d)$/0$1/; #aggiungo una cifra se necessario
	$mday =~ s/^(\d)$/0$1/; #aggiungo una cifra se necessario
	$mon =~ s/^(\d)$/0$1/; #aggiungo una cifra se necessario

	
	if ($type eq 'Timestamp')
	{
		$rit = $year.'-'.$mon.'-'.$mday.'T'.$hour.':'.$min.':'.$sec;
	}
	elsif ($type eq 'TimestampTT')
	{
		$rit = $year.'-'.$mon.'-'.$mday.' '.$hour.':'.$min.':'.$sec;
	}
	elsif ($type eq 'TransactionId')
	{
		$rit = $year.$mon.$mday.$hour.$min.$sec;
	}
	elsif ($type eq 'TimestampEAI' or $type eq 'EAITimestamp')
	{
		my $gmt_offset_in_seconds =  timelocal(@t) - timegm(@t);
		my $offset = '+01:00';
		$offset = '+02:00' if ($gmt_offset_in_seconds > 3600);
		
		$rit = $year.'-'.$mon.'-'.$mday.'T'.$hour.':'.$min.':'.$sec.$offset;
	}
	
	
	return $rit;
}







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


	my $EAI_namespace = 'xmlns="http://www.tibco.com/schemas/OTTM/EnterpriseServices/InfrastrutureObject/Schemas/CommonSchemas/OTTM/TroubleTicket_OTRS.xsd"';
	my $EAI_empty_namespace = 'xmlns=""';

	my $response_type_start = '';
	my $response_type_end = '';
	if(exists($MS_Response_info_ptr->{MS_InputRequestType}))
	{
		if ($MS_Response_info_ptr->{MS_InputRequestType} eq 'CREATE')
		{
			$response_type_start = "<CreateTTOutput>\n";
			$response_type_end = "</CreateTTOutput>\n";
		}
		elsif ($MS_Response_info_ptr->{MS_InputRequestType} eq 'UPDATE')
		{
			$response_type_start = "<UpdateTTOutput>\n";
			$response_type_end = "</UpdateTTOutput>\n";
		}
		elsif ($MS_Response_info_ptr->{MS_InputRequestType} eq 'NOTIFY')
		{
			$response_type_start = "<NotifyTTOutput>\n";
			$response_type_end = "</NotifyTTOutput>\n";
		}
	}
	
	
	
	$MS_Response_header{TransactionId} = $MS_Response_info_ptr->{TransactionId} if(exists($MS_Response_info_ptr->{TransactionId}));
	$MS_Response_header{BusinessId} = $MS_Response_info_ptr->{BusinessId} if(exists($MS_Response_info_ptr->{BusinessId}));
	$MS_Response_header{Username} = $MS_Response_info_ptr->{Username} if(exists($MS_Response_info_ptr->{Username}));
	$MS_Response_header{Password} = $MS_Response_info_ptr->{Password} if(exists($MS_Response_info_ptr->{Password}));
	$MS_Response_header{MessageType} = $MS_Response_info_ptr->{MessageType} if(exists($MS_Response_info_ptr->{MessageType}));
	$MS_Response_header{MessageCode} = $MS_Response_info_ptr->{MessageCode} if(exists($MS_Response_info_ptr->{MessageCode}));
	$MS_Response_header{MessageId} = $MS_Response_info_ptr->{MessageId} if(exists($MS_Response_info_ptr->{MessageId}));
	
	
	$MS_Response_body{StatusCode} = $MS_Response_info_ptr->{StatusCode} if(exists($MS_Response_info_ptr->{StatusCode}));
	$MS_Response_body{ReturnCode} = $MS_Response_body{StatusCode};
	$MS_Response_body{ErrorMessage} = $MS_Response_info_ptr->{ErrorMessage} if(exists($MS_Response_info_ptr->{ErrorMessage}));
	$MS_Response_body{ErrorDescription} = $MS_Response_info_ptr->{ErrorDescription} if(exists($MS_Response_info_ptr->{ErrorDescription}));
	$MS_Response_body{TicketID} = $MS_Response_info_ptr->{TicketID} if(exists($MS_Response_info_ptr->{TicketID}));
	$MS_Response_body{idTT} = $MS_Response_info_ptr->{TicketID} if(exists($MS_Response_info_ptr->{TicketID}));
	
	$MS_Response_body{status} = $MS_Response_info_ptr->{Status} if(exists($MS_Response_info_ptr->{Status}));
	#richiesto SOLO quando creano un Alarm (quindi sulla CREATE) e la creazione va a buon fine
	if($MS_Response_info_ptr->{MS_InputRequestType} eq 'CREATE' and exists($MS_Response_info_ptr->{StatusCode}) and $MS_Response_info_ptr->{StatusCode} eq '0')
	{
		$MS_Response_body{status} = 'APERTO'; 
	}
	
	my $header = MS_ResponseBuild_header(\%MS_Response_header, $EAI_namespace, $EAI_empty_namespace);
	my $body = MS_ResponseBuild_body(\%MS_Response_body, $EAI_namespace, $EAI_empty_namespace);
	
	my $response = $MS_Response_container_start;
	$response .= $response_type_start;
	$response .= $header;
	$response .= $body;
	$response .= $response_type_end;
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
	my $EAI_namespace = shift;
	my $EAI_empty_namespace = shift;
	
	##Timestamp
	#my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	#$mon += 1;
	#$year += 1900;
	
	#uso questo formato YYYY-MM-DDTHH:MM:SS
	$MS_Response_header_ptr->{TimeStamp} = _MS_CalcTimestamp_ResponseToWind('Timestamp'); #"$year-$mon-$mday".'T'."$hour:$min:$sec";
	
	#Transaction ID; identifica l'ID univoco della transazione, per i servizi sincroni questa informazione deve rimanere la stessa sia per la request che per la response
	#$MS_Response_header_ptr->{TransactionId} = "$year$mon$mday$hour$min$sec";

		#Ordine "fortemente" voluto da EAI anche se non necessario!!
		my @HeaderFieldsOrder = ("SourceChannel",
									 "DestinationChannel",
									 "TimeStamp",
									 "Username",
									 "Password",
									 "MessageType",
									 "MessageCode",
									 "TransactionId",
									 "MessageId",
									 "BusinessId");


	
	my $XML_tags = '';
	for(my $hh=0; $hh<scalar(@HeaderFieldsOrder); $hh++)
	{
		if (exists($MS_Response_header_ptr->{$HeaderFieldsOrder[$hh]}) ) #and $MS_Response_header_ptr->{$HeaderFieldsOrder[$hh]} !~ m/^\s*$/)
		{
			#Nota: proteggo tutti i contenuti dal parsing con <![CDATA[XXXXXX]]>
			$XML_tags .= "<$HeaderFieldsOrder[$hh] ".$EAI_empty_namespace."><![CDATA[".$MS_Response_header_ptr->{$HeaderFieldsOrder[$hh]}."]]></$HeaderFieldsOrder[$hh]>\n" ;
		}
	}
	#foreach my $key (keys %{$MS_Response_header_ptr})
	#{
	#	#Nota: proteggo tutti i contenuti dal parsing con <![CDATA[XXXXXX]]>
	#	$XML_tags .= '<'.$key.'><![CDATA['.$MS_Response_header_ptr->{$key}.']]></'.$key.">\n";
	#}
	
	#my $XML_header = '<'.$MS_Response_header_container_tag.">\n";
	my $XML_header = '<'.$MS_Response_header_container_tag." ".$EAI_namespace.">\n";
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
	my $EAI_namespace = shift;
	my $EAI_empty_namespace = shift;
	
	#Ricevo le info gia' popolate e quindi devo solo costruire l'XML...


		#Ordine "fortemente" voluto da EAI anche se non necessario!!
		my @BodyFieldsOrder = ("idTT",
									 "status",
									 "ReturnCode",
									 "ErrorDescription",
									 "ErrorMessage");
	
	

	my $XML_tags = '';
	for(my $bb=0; $bb<scalar(@BodyFieldsOrder); $bb++)
	{
		if(exists($MS_Response_body_ptr->{$BodyFieldsOrder[$bb]}) and $MS_Response_body_ptr->{$BodyFieldsOrder[$bb]} !~ m/^\s*$/)
		{
			#Nota: proteggo tutti i contenuti dal parsing con <![CDATA[XXXXXX]]>
			$XML_tags .= "<$BodyFieldsOrder[$bb]><![CDATA[".$MS_Response_body_ptr->{$BodyFieldsOrder[$bb]}."]]></$BodyFieldsOrder[$bb]>\n" ;	
		}		
	}
	#foreach my $key (keys %{$MS_Response_body_ptr})
	#{
	#	#Nota: proteggo tutti i contenuti dal parsing con <![CDATA[XXXXXX]]>
	#	$XML_tags .= '<'.$key.'><![CDATA['.$MS_Response_body_ptr->{$key}.']]></'.$key.">\n";
	#}
	
	my $XML_body = '<'.$MS_Response_body_container_tag." ".$EAI_empty_namespace.">\n";
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

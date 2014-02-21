package MSRequestToWindUtil;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

# Exporting the saluta routine
our @EXPORT = qw(MS_RequestBuildAndSend);
# Exporting the saluta2 routine on demand basis.
#our @EXPORT_OK = qw(saluta2);




# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/../cpan-lib";



# ----------------- Attiva/disattiva debug per sviluppo ------------------
my $MS_DEBUG = 0; # 0 -> disattivato, 1 -> attivato


# ----------------- Moduli necessari ------------------
#require LWP::UserAgent;
use LWP::UserAgent;
use MIME::Base64;
use URI::Escape;
use Time::Local;  #solo per il timestamp per EAI !!
#use Encode qw( encode_utf8 ); #per mandare l'xml col charset utf-8 ad EAI
use Data::Dumper;


# ----------------- Moduli custom necessari ------------------
use MSResponseFromWindUtil;
use MSTicketUtil;
use MSXMLUtil;





sub _MS_CalcTimestamp
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










#input: $Hash_ptr
#output: crea $Hash_ptr->{RequestContent}
sub MS_RequestHashToXMLString
{
	my $Hash_ptr = shift;

	my $rit = undef;
	
	if (defined($Hash_ptr) and exists($Hash_ptr->{HEADER}) and exists($Hash_ptr->{BODY})  )
	{
		$Hash_ptr->{RequestContent} = '';
		my $XML_tmp = \$Hash_ptr->{RequestContent};
		
		my $EAI_namespace = 'xmlns="http://www.tibco.com/schemas/OTTM/EnterpriseServices/InfrastrutureObject/Schemas/CommonSchemas/OTTM/TroubleTicket_OTRS.xsd"';
		my $EAI_empty_namespace = 'xmlns=""';
		
		$$XML_tmp = '<?xml version="1.0" encoding="UTF-8"?>';
		$$XML_tmp .= "\n";
		#$$XML_tmp = "";
		$$XML_tmp .= '<OTRS_API '.$EAI_namespace.'>';
		$$XML_tmp .= "\n";
		$$XML_tmp .= "<TicketRequest>\n";
	
		if(exists($Hash_ptr->{RequestType}) )
		{
			if ($Hash_ptr->{RequestType} == 1) #Create
			{
				$$XML_tmp .= "<CreateTTInput>\n";
			}
			elsif ($Hash_ptr->{RequestType} == 2) #Update
			{
				$$XML_tmp .= "<InputUpdate>\n";
			}
			elsif ($Hash_ptr->{RequestType} == 3) #Notify
			{
				$$XML_tmp .= "<NotifyUpdate>\n";
			}
		}

		
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

		my @BodyFieldsOrder = ("TicketID",
									 "TicketIDWind",
									 "Causale",
									 "Action",
									 "Status",
									 "Type",
									 "priority",
									 "CategoryTT",
									 "AmbitoTT",
									 "Oggetto",
									 "Descrizione",
									 "TimestampTT",
									 "startDateMalfunction",
									 "endDateMalfunction",
									 "segmentCustomer",
									 "msisdn",
									 "imsi",
									 "iccid",
									 "idLinea",
									 "tipoLinea",
									 "mnpType",
									 "imei",
									 "referente",
									 "address",
									 "prov",
									 "city",
									 "cap");
  

		
		
		
		
		
		
		
		
		
		$$XML_tmp .= "<Header>\n"; #TODO: verificare la correttezza di questo tag contenitore
		for(my $hh=0; $hh<scalar(@HeaderFieldsOrder); $hh++)
		{
			if (exists($Hash_ptr->{HEADER}->{$HeaderFieldsOrder[$hh]}) and $Hash_ptr->{HEADER}->{$HeaderFieldsOrder[$hh]} !~ m/^\s*$/)
			{
				#Nota: proteggo tutti i contenuti dal parsing con <![CDATA[XXXXXX]]>
				$$XML_tmp .= "<$HeaderFieldsOrder[$hh] ".$EAI_empty_namespace."><![CDATA[".$Hash_ptr->{HEADER}->{$HeaderFieldsOrder[$hh]}."]]></$HeaderFieldsOrder[$hh]>\n" ;
			}
		}
		#foreach my $key (keys(%{$Hash_ptr->{HEADER}}) )
		#{
		#	#Nota: proteggo tutti i contenuti dal parsing con <![CDATA[XXXXXX]]>
		#	$$XML_tmp .= "<$key><![CDATA[".$Hash_ptr->{HEADER}->{$key}."]]></$key>\n";
		#}
		$$XML_tmp .= "</Header>\n";

		$$XML_tmp .= "<Body ".$EAI_empty_namespace.">\n"; #TODO: verificare la correttezza di questo tag contenitore
		for(my $bb=0; $bb<scalar(@BodyFieldsOrder); $bb++)
		{
			if(exists($Hash_ptr->{BODY}->{$BodyFieldsOrder[$bb]}) and $Hash_ptr->{BODY}->{$BodyFieldsOrder[$bb]} !~ m/^\s*$/)
			{
				#The complete regex for removal of invalid xml-1.0
				# #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
				#$str =~ s/[^\x09\x0A\x0D\x20-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]//go;
					
				my $tmpString_body  = '';
				$tmpString_body = $Hash_ptr->{BODY}->{$BodyFieldsOrder[$bb]};
				$tmpString_body =~ s/[^\x09\x0A\x0D\x20-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]//g;
				$tmpString_body =~ s/\x{a0}/ /g; #aggiunta per EAI a cui il carattere \x{a0} non piace (va in errore di parsing)				
				#à è é ì ò ù  ----> \x{e0} \x{e8} \x{e9} \x{ec} \x{f2} \x{f9}
				#$tmpString_body =~ s/\x{e0}/à/g;
				#$tmpString_body =~ s/\x{e8}/è/g;
				#$tmpString_body =~ s/\x{e9}/é/g;
				#$tmpString_body =~ s/\x{ec}/ì/g;
				#$tmpString_body =~ s/\x{f2}/ò/g;
				#$tmpString_body =~ s/\x{f9}/ù/g;
				
				#Nota: proteggo tutti i contenuti dal parsing con <![CDATA[XXXXXX]]>
				$$XML_tmp .= "<$BodyFieldsOrder[$bb]><![CDATA[".$tmpString_body."]]></$BodyFieldsOrder[$bb]>\n" ;	
			}		
		}
		#debug
		#print "\n".Dumper($Hash_ptr->{BODY})."\n" if($MS_DEBUG);
		#foreach my $key (keys(%{$Hash_ptr->{BODY}}) )
		#{
		#	#debug
		#	#print "\nKey = $key   --- contenuto = $Hash_ptr->{BODY}->{$key} \n" if($MS_DEBUG);
		#	
		#	#Nota: proteggo tutti i contenuti dal parsing con <![CDATA[XXXXXX]]>
		#	$$XML_tmp .= "<$key><![CDATA[".$Hash_ptr->{BODY}->{$key}."]]></$key>\n" if(exists($Hash_ptr->{BODY}->{$key}) and defined($Hash_ptr->{BODY}->{$key}) );
		#}
		
		
		
		#Note (in verita' ci sara' sempre al massimo una nota)
		if (exists($Hash_ptr->{ListOfNotes}))
		{
			my $notesCount = scalar@{$Hash_ptr->{ListOfNotes}};
			if ($notesCount > 0)
			{
				$$XML_tmp .= "<ListOfNotes>\n";
				for(my $i = 0; $i<$notesCount; $i++)
				{
					#The complete regex for removal of invalid xml-1.0
					# #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
					#$str =~ s/[^\x09\x0A\x0D\x20-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]//go;
					my $tmpString = '';
					
					$$XML_tmp .= "<Note>\n";
					
					#Nota: proteggo tutti i contenuti dal parsing con <![CDATA[XXXXXX]]>
					if(exists($Hash_ptr->{ListOfNotes}->[$i]->{Team}))
					{
						$tmpString = $Hash_ptr->{ListOfNotes}->[$i]->{Team};
						$tmpString =~ s/[^\x09\x0A\x0D\x20-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]//g;
						$tmpString =~ s/\x{a0}/ /g; #aggiunta per EAI a cui il carattere \x{a0} non piace (va in errore di parsing)
						#à è é ì ò ù  ----> \x{e0} \x{e8} \x{e9} \x{ec} \x{f2} \x{f9}
						#$tmpString =~ s/\x{e0}/à/g;
						#$tmpString =~ s/\x{e8}/è/g;
						#$tmpString =~ s/\x{e9}/é/g;
						#$tmpString =~ s/\x{ec}/ì/g;
						#$tmpString =~ s/\x{f2}/ò/g;
						#$tmpString =~ s/\x{f9}/ù/g;
						
						$$XML_tmp .= "<Team><![CDATA[".$tmpString."]]></Team>\n" ;
					}
					
					$$XML_tmp .= "<CreationDate><![CDATA[".$Hash_ptr->{ListOfNotes}->[$i]->{CreationDate}."]]></CreationDate>\n" if(exists($Hash_ptr->{ListOfNotes}->[$i]->{CreationDate}));
					
					if (exists($Hash_ptr->{ListOfNotes}->[$i]->{Description}))
					{
						$tmpString = $Hash_ptr->{ListOfNotes}->[$i]->{Description};
						$tmpString =~ s/[^\x09\x0A\x0D\x20-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]//g;
						$tmpString =~ s/\x{a0}/ /g; #aggiunta per EAI a cui il carattere \x{a0} non piace (va in errore di parsing)
						#à è é ì ò ù  ----> \x{e0} \x{e8} \x{e9} \x{ec} \x{f2} \x{f9}
						#$tmpString =~ s/\x{e0}/à/g;
						#$tmpString =~ s/\x{e8}/è/g;
						#$tmpString =~ s/\x{e9}/é/g;
						#$tmpString =~ s/\x{ec}/ì/g;
						#$tmpString =~ s/\x{f2}/ò/g;
						#$tmpString =~ s/\x{f9}/ù/g;
						
						$$XML_tmp .= "<Description><![CDATA[".$tmpString."]]></Description>\n";
					}
					
					$$XML_tmp .= "</Note>\n";
				}
				$$XML_tmp .= "</ListOfNotes>\n";
			}
		}
		
		#allegati
		if (exists($Hash_ptr->{AttachedFiles}))
		{
			my $filesCount = scalar@{$Hash_ptr->{AttachedFiles}};
			if ($filesCount > 0)
			{
				$$XML_tmp .= "<ListOfAttachment>\n";
				for(my $i = 0; $i<$filesCount; $i++)
				{
					$$XML_tmp .= "<Attachment>\n";
					
					#Nota: proteggo tutti i contenuti dal parsing con <![CDATA[XXXXXX]]>
					$$XML_tmp .= "<FullFileName><![CDATA[".$Hash_ptr->{AttachedFiles}->[$i]->{Filename}."]]></FullFileName>\n";
					
					#NOTA: da EAI mi chiedono l'estensione del file invece del MIME-TYPE (ContentType)
					#$$XML_tmp .= "<TypeFile><![CDATA[".$Hash_ptr->{AttachedFiles}->[$i]->{ContentType}."]]></TypeFile>\n";
					$$XML_tmp .= "<TypeFile><![CDATA[".$Hash_ptr->{AttachedFiles}->[$i]->{FileExtension}."]]></TypeFile>\n";
					
					# -- codifica Base64 del contenuto del file... -- INIZIO --
					my $myContent = $Hash_ptr->{AttachedFiles}->[$i]->{Content};
					my $myLength = length($myContent);
					my $checkVar = 0;
					my $encodedContent = '';
					my $lungSpezzone = 57; #caratteri/bytes -> vedi doc su MIME::Base64 e grossi file
					while ($checkVar < $myLength)
					{
						my $partial = substr($myContent,$checkVar,$lungSpezzone);
						$checkVar += $lungSpezzone;
						$encodedContent .= encode_base64($partial, '');
					}
					$$XML_tmp .= "<FileBody><![CDATA[".$encodedContent."]]></FileBody>\n";
					#$$XML_tmp .= "<FileBody>".$encodedContent."</FileBody>\n";
					# -- codifica Base64 del contenuto del file... -- FINE --
						# -- vecchia gestione --$$XML_tmp .= "<FileBody><![CDATA[".encode_base64($Hash_ptr->{AttachedFiles}->[$i]->{Content})."]]></FileBody>\n";
					#$$XML_tmp .= "<FileBody><![CDATA[".$Hash_ptr->{AttachedFiles}->[$i]->{Content}."]]></FileBody>\n";
					#$$XML_tmp .= "<FileBody><![CDATA[".unpack('H*', $Hash_ptr->{AttachedFiles}->[$i]->{Content})."]]></FileBody>\n";
					
					#$XML_tmp .= "<dataCreazione>".$Hash_ptr->{AttachedFiles}->[$i]->{---DATO MANCANTE ---}."</dataCreazione>";
					
					$$XML_tmp .= "</Attachment>\n";
				}
				$$XML_tmp .= "</ListOfAttachment>\n";
			}
		}
		

		
		$$XML_tmp .= "</Body>\n";		

		
		
		if(exists($Hash_ptr->{RequestType}) )
		{
			if ($Hash_ptr->{RequestType} == 1) #Create
			{
				$$XML_tmp .= "</CreateTTInput>\n";
			}
			elsif ($Hash_ptr->{RequestType} == 2) #Update
			{
				$$XML_tmp .= "</InputUpdate>\n";
			}
			elsif ($Hash_ptr->{RequestType} == 3) #Notify
			{
				$$XML_tmp .= "</NotifyUpdate>\n";
			}
		}		
		
		
		$$XML_tmp .= "</TicketRequest>\n";		
		$$XML_tmp .= "</OTRS_API>\n";
		
		$rit = 1;
	}
	
	
	
	return $rit;
}









sub MS_ArticleToListOfNotesStructure
{
	my $TicketHash_ptr = shift;
	
	
	#ATTENZIONE - TODO - disabilitazione temporanea delle note
	#return;
	
	if (exists( $TicketHash_ptr->{_ARTICLE}))
	{
		$TicketHash_ptr->{ListOfNotes} = [];
		$TicketHash_ptr->{ListOfNotes}->[0] = {};
		
		my $dateFormatted = $TicketHash_ptr->{_ARTICLE}->{CREATE_TIME};
		$dateFormatted =~ s/ /T/;
		
		$TicketHash_ptr->{ListOfNotes}->[0]->{Team} = $TicketHash_ptr->{_ARTICLE}->{A_SUBJECT};
		$TicketHash_ptr->{ListOfNotes}->[0]->{CreationDate} = $dateFormatted;
		$TicketHash_ptr->{ListOfNotes}->[0]->{Description} = $TicketHash_ptr->{_ARTICLE}->{A_BODY};
		
	}
}










sub _MS_RequestBuild_HANDLER___checkIfFieldExists
{
	my $input = shift;
	my $rit = undef;
	
	$rit = 1 if(defined($input) and $input !~ m/^\s*$/);
	
	return $rit;
}


#Info:
#
# input:
#     xxxxxx
#
# output:
#
# Nota:xxxxxxxxxxx
#
sub _MS_RequestBuild_HANDLER
{
	my $ticket_id_or_tn = shift;
	my $TicketID_is_a_TN = shift; #ad 1 se mi viene passato un TN al posto di un ID
   my $MS_TicketObject_ptr = shift;
	my $actionType = shift;
	my $WindTicketType = shift;
	
	my $TicketHash_ptr = shift; # opzionale
	
	
	my $rit = undef;
	
	if( !defined($ticket_id_or_tn) or !defined($TicketID_is_a_TN) or !defined($MS_TicketObject_ptr) or !defined($actionType) or !defined($WindTicketType) )
	{
		return $rit; 
	}
	
	#debug
	print "\nOK1\n" if($MS_DEBUG);
	print "\nticket_id_or_tn=$ticket_id_or_tn, TicketID_is_a_TN=$TicketID_is_a_TN\n" if($MS_DEBUG);
	
	my $MS_DBObject_ptr = $MS_TicketObject_ptr->{DBObject};
	my $MS_ConfigObject_ptr = $MS_DBObject_ptr->{ConfigObject};
	my $MS_LogObject_ptr = $MS_DBObject_ptr->{LogObject};
	
	$TicketHash_ptr = {} if(!defined($TicketHash_ptr));	
	
	
	#Anche se il controllo e' "for Create" va bene in generale
	my $isOkToHandle = 0;
	if($WindTicketType eq 'INCIDENT')
	{
		$isOkToHandle = MS_CheckIfIncidentOrSrIsOkForCreate($ticket_id_or_tn, $TicketID_is_a_TN, $MS_DBObject_ptr, $TicketHash_ptr);
	}
	elsif($WindTicketType eq 'ALARM')
	{
		$isOkToHandle = MS_CheckIfAlarmIsOkForCreate($ticket_id_or_tn, $TicketID_is_a_TN, $MS_DBObject_ptr, $TicketHash_ptr);
	}
	else
	{
		return $rit;
	}
	

	#debug
	print "\nOK2\n" if($MS_DEBUG);
	
	
	
	#potrebbe essere fallito il controllo sualle categorie o sui tipi di ticket, ecc.
	if( !$isOkToHandle )
	{
		return $rit;
	}



	#hashes da popolare....
	$TicketHash_ptr->{RequestHash} = {};
	my $ReqHash_ptr = $TicketHash_ptr->{RequestHash};
	$ReqHash_ptr->{HEADER} = {};
	my $ReqHeader_ptr = $ReqHash_ptr->{HEADER};
	$ReqHash_ptr->{BODY} = {};
	my $ReqBody_ptr = $ReqHash_ptr->{BODY};





	
	#debug
	print "\nOK3\n" if($MS_DEBUG);
	
	
	
	if($actionType eq 'CREATE')
	{
		$ReqHash_ptr->{RequestType} = 1; #Create
		#$ReqHash_ptr->{RequestType} = 2; #Update
		#$ReqHash_ptr->{RequestType} = 3; #Notify
		#$ReqHash_ptr->{RequestType} = ?  #unknow


		### --- Request header ---
		#SourceChannel
		#DestinationChannel
		#TimeStamp
		#TransactionId 
		#BusinessId
		#
		### --- Request body ---
		#TickedIDWind					
		#Type	
		#Action					
		#Status					
		#priority
		#CategoryTT 				
		#AmbitoTT				
		#Oggetto				
		#Descrizione				
		#TimestampTT
		#startDateMalfunction
		#endDateMalfunction
		#segmentCustomer
		#msisdn		
		#imsi
		#iccid
		#idLinea
		#tipoLinea
		#mnpType
		#imei
		#referente	
		#Nota	
		#address 	
		#prov
		#city	
		#cap


		# ---------------------- Nota -------------------------
		my $validArticleIdForWind = $TicketHash_ptr->{WIND_VALID_ARTICLE_ID};
		$TicketHash_ptr->{_ARTICLE} = {};
		
		
		my $oggetto = ''; #Oggetto della nota per Wind
		my $descrizione = ''; #Corpo della nota per Wind
		
		
		# 0 -> KO (article non esiste, oppure errore generico)
		# 1 -> OK (article trovato)
		my $article_rit = MS_ArticleGetInfo($validArticleIdForWind, $MS_DBObject_ptr, $TicketHash_ptr->{_ARTICLE});
		if (!$article_rit and $WindTicketType ne 'ALARM')
		{
			return $rit;
		}
		else
		{
			$oggetto = $TicketHash_ptr->{_ARTICLE}->{A_SUBJECT}; #Oggetto della nota per Wind
			$descrizione = $TicketHash_ptr->{_ARTICLE}->{A_BODY}; #Corpo della nota per Wind
		}
		
		
		
		if (exists($TicketHash_ptr->{CREATION_ARTICLE_ID}))
		{
			$TicketHash_ptr->{_CREATION_ARTICLE} = {};
			my $article_rit_2 = MS_ArticleGetInfo($TicketHash_ptr->{CREATION_ARTICLE_ID}, $MS_DBObject_ptr, $TicketHash_ptr->{_CREATION_ARTICLE});
			if (!$article_rit_2)
			{
				return $rit;
			}
			
			$oggetto = $TicketHash_ptr->{_CREATION_ARTICLE}->{A_SUBJECT}; #Oggetto della nota di creazione
			$descrizione = $TicketHash_ptr->{_CREATION_ARTICLE}->{A_BODY}; #Corpo della nota di creazione
			
			#abilito la generazione della struttura delle note
			$ReqHash_ptr->{_ARTICLE} = $TicketHash_ptr->{_ARTICLE} if($article_rit);
		}
		
		
		

		
		$ReqHeader_ptr->{SourceChannel} = 'OTRS' ;
		$ReqHeader_ptr->{DestinationChannel} = 'WIND' ;
		$ReqHeader_ptr->{TimeStamp} = _MS_CalcTimestamp('Timestamp') ;
		$ReqHeader_ptr->{TransactionId} = _MS_CalcTimestamp('TransactionId') ;
		$ReqHeader_ptr->{BusinessId} = 'unknow' ; #TODO: valorizzare con i valori attesi da EAI 
		
		$ReqHeader_ptr->{Username} = 'OTRS' ; #TODO: valorizzare con i valori attesi da EAI
		$ReqHeader_ptr->{Password} = '' ; #TODO: valorizzare con i valori attesi da EAI
		$ReqHeader_ptr->{MessageType} = 'CreateToWind' ; #TODO: valorizzare con i valori attesi da EAI
		$ReqHeader_ptr->{MessageCode} = '1' ; #TODO: valorizzare con i valori attesi da EAI
		$ReqHeader_ptr->{MessageId} = $ReqHeader_ptr->{TransactionId} ; #TODO: valorizzare con i valori attesi da EAI 

  
  
		$ReqBody_ptr->{TicketID} = $TicketHash_ptr->{TN} ; #ATTENZIONE: mandiamo fuori in TN e non l'ID !!!
		#$ReqBody_ptr->{TickedIDWind} = '' ; 
		$ReqBody_ptr->{Type} = 'INCIDENT' ;
		
		$ReqBody_ptr->{Action} = 'CREATE' ; 
		#$ReqBody_ptr->{Status} = '' ; 
		$ReqBody_ptr->{priority} = MS_OtrsTicketPriorityToWindSeverity($TicketHash_ptr->{TICKET_PRIORITY_ID}) ;
		$ReqBody_ptr->{CategoryTT} = $TicketHash_ptr->{FREETEXT15} ;
		$ReqBody_ptr->{AmbitoTT} = $TicketHash_ptr->{WIND_AMBITOTT} ;
		$ReqBody_ptr->{Oggetto} = $oggetto;
		$ReqBody_ptr->{Descrizione} = $descrizione;
		$ReqBody_ptr->{TimestampTT} = _MS_CalcTimestamp('TimestampTT') ;
		
		#$ReqBody_ptr->{startDateMalfunction} = '' ; 
		#$ReqBody_ptr->{endDateMalfunction} = '' ;
		$ReqBody_ptr->{segmentCustomer} = $TicketHash_ptr->{FREETEXT1}  if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{FREETEXT1}));
		$ReqBody_ptr->{msisdn} = $TicketHash_ptr->{WIND_MSISDN} if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{WIND_MSISDN}));
		$ReqBody_ptr->{imsi} = $TicketHash_ptr->{WIND_IMSI} if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{WIND_IMSI}));
		$ReqBody_ptr->{iccid} = $TicketHash_ptr->{WIND_ICCID} if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{WIND_ICCID}));
		$ReqBody_ptr->{idLinea} = $TicketHash_ptr->{WIND_ID_LINEA} if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{WIND_ID_LINEA}));
		$ReqBody_ptr->{tipoLinea} = $TicketHash_ptr->{WIND_TIPO_LINEA} if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{WIND_TIPO_LINEA}));
		$ReqBody_ptr->{mnpType} = $TicketHash_ptr->{WIND_MNP_TYPE} if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{WIND_MNP_TYPE}));
		$ReqBody_ptr->{imei} = $TicketHash_ptr->{WIND_IMEI} if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{WIND_IMEI}));
		$ReqBody_ptr->{referente} = $TicketHash_ptr->{FREETEXT16} if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{FREETEXT16}));
		#$ReqBody_ptr->{Nota} = '' ; # Nella CREATE non utilizzo la Nota
		$ReqBody_ptr->{address } = $TicketHash_ptr->{WIND_Indirizzo} if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{WIND_Indirizzo}));
		$ReqBody_ptr->{prov} = $TicketHash_ptr->{WIND_Provincia} if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{WIND_Provincia}));
		$ReqBody_ptr->{city} = $TicketHash_ptr->{WIND_Comune} if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{WIND_Comune}));
		$ReqBody_ptr->{cap} = $TicketHash_ptr->{WIND_CAP} if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{WIND_CAP}));
		

		




	#debug
	print "\nOK4\n" if($MS_DEBUG);
		
		if (exists($ReqHash_ptr->{_ARTICLE} ))
		{
			#MS_ArticleToListOfNotesStructure($TicketHash_ptr);
			MS_ArticleToListOfNotesStructure($ReqHash_ptr);
		}
		

	
		#Allegati NON previsti per gli alarm 
		if($WindTicketType ne 'ALARM')
		{	
			# ---------------------- Allegati -------------------------
			# 0 -> KO (non esistono allegato per questo article, oppure errore generico)
			# num > 0 -> OK (numero degli allegati trovati)
			#
			my $attachments_rit = MS_GetArticleAttachments($validArticleIdForWind, $MS_TicketObject_ptr, $TicketHash_ptr->{RequestHash});
			#qui ho $TicketHash_ptr->{RequestHash}->{AttachedFiles}  che viene creato e popolato dalla sub precedente	
			
			my $tmp_attach_ptr = {};
			$tmp_attach_ptr->{RequestHash} = {};
			my $attachments2_rit = MS_GetArticleAttachments($TicketHash_ptr->{CREATION_ARTICLE_ID}, $MS_TicketObject_ptr, $tmp_attach_ptr->{RequestHash});
			if ($attachments_rit > 0 or $attachments2_rit > 0 ) #unisco gli allegati della nota di creazione a quelli della nota per Wind
			{
				my @tmp_array_attach_ptr = @{$tmp_attach_ptr->{RequestHash}->{AttachedFiles}};
				for(my $kkk=0; $kkk<scalar(@tmp_array_attach_ptr) ; $kkk++)
				{
					push(@{$TicketHash_ptr->{RequestHash}->{AttachedFiles}}, $tmp_array_attach_ptr[$kkk]);
				}
			}
		}
		
		
		
		if($WindTicketType eq 'ALARM')
		{
			$ReqBody_ptr->{Type} = 'ALARM' ;
			
			$ReqBody_ptr->{startDateMalfunction} = $TicketHash_ptr->{FREETIME1} if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{FREETIME1}));
			$ReqBody_ptr->{endDateMalfunction} = $TicketHash_ptr->{FREETIME2} if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{FREETIME2}));
		}

		$rit = 1;			
	}
	elsif(($actionType eq 'REOPEN' and $WindTicketType eq 'INCIDENT') or (($actionType eq 'UPDATE' or $actionType eq 'UPDATE_NO_NEW_ARTICLE') and $WindTicketType eq 'ALARM') ) #Reopen permessa solo per gli Incident e Update permessa solo per gli Alarm e Update (senza invio della nota e degli allegati) permessa solo per gli Alarm
	{
		#$ReqHash_ptr->{RequestType} = 1; #Create
		$ReqHash_ptr->{RequestType} = 2; #Update
		#$ReqHash_ptr->{RequestType} = 3; #Notify
		#$ReqHash_ptr->{RequestType} = ?  #unknow
		
		
		$ReqHeader_ptr->{SourceChannel} = 'OTRS' ;
		$ReqHeader_ptr->{DestinationChannel} = 'WIND' ;
		$ReqHeader_ptr->{TimeStamp} = _MS_CalcTimestamp('Timestamp') ;
		$ReqHeader_ptr->{TransactionId} = _MS_CalcTimestamp('TransactionId') ;
		$ReqHeader_ptr->{BusinessId} = 'unknow' ; #TODO: valorizzare con i valori attesi da EAI
		
		$ReqHeader_ptr->{Username} = 'OTRS' ; #TODO: valorizzare con i valori attesi da EAI
		$ReqHeader_ptr->{Password} = '' ; #TODO: valorizzare con i valori attesi da EAI
		$ReqHeader_ptr->{MessageType} = 'UpdateToWind' ; #TODO: valorizzare con i valori attesi da EAI
		$ReqHeader_ptr->{MessageCode} = '2' ; #TODO: valorizzare con i valori attesi da EAI
		$ReqHeader_ptr->{MessageId} = $ReqHeader_ptr->{TransactionId} ; #TODO: valorizzare con i valori attesi da EAI 
		
		
		$ReqBody_ptr->{TicketID} = $TicketHash_ptr->{TN} ; #ATTENZIONE: mandiamo fuori in TN e non l'ID !!!
		$ReqBody_ptr->{TicketIDWind} = $TicketHash_ptr->{FREETEXT9} ;
		#MS 20140207: Type non si manda piu' su una update....
		#$ReqBody_ptr->{Type} = 'INCIDENT' ;
		
		$ReqBody_ptr->{Action} = 'REOPEN' ;
		#MS 20140207: Status non si manda piu' su una update....
		#$ReqBody_ptr->{Status} = MS_OtrsTicketStateIDToWindStatus($TicketHash_ptr->{PM_Wind_settings}, $TicketHash_ptr->{TICKET_STATE_ID}) ;
		$ReqBody_ptr->{priority} = MS_OtrsTicketPriorityToWindSeverity($TicketHash_ptr->{TICKET_PRIORITY_ID}) ;
		$ReqBody_ptr->{CategoryTT} = $TicketHash_ptr->{FREETEXT15} ;
		$ReqBody_ptr->{AmbitoTT} = $TicketHash_ptr->{WIND_AMBITOTT} ;
		$ReqBody_ptr->{TimestampTT} = _MS_CalcTimestamp('TimestampTT') ;

		
		if ($actionType ne 'UPDATE_NO_NEW_ARTICLE')
		{
			# ---------------------- Nota -------------------------
			$TicketHash_ptr->{_ARTICLE} = {};
			
			if ( exists($TicketHash_ptr->{WIND_VALID_ARTICLE_ID}) and $TicketHash_ptr->{WIND_VALID_ARTICLE_ID} > 0 ) #se esiste una nota valida per Wind fatta dall'operatore mi prendo nota ed allegati
			{
				my $validArticleIdForWind = $TicketHash_ptr->{WIND_VALID_ARTICLE_ID};
				
				# 0 -> KO (article non esiste, oppure errore generico)
				# 1 -> OK (article trovato)
				my $article_rit = MS_ArticleGetInfo($validArticleIdForWind, $MS_DBObject_ptr, $TicketHash_ptr->{_ARTICLE});
				if (!$article_rit)
				{
					return $rit;
				}
				

			
				# ---------------------- Allegati -------------------------
				# 0 -> KO (non esistono allegato per questo article, oppure errore generico)
				# num > 0 -> OK (numero degli allegati trovati)
				#
				# ATTENZIONE: gli allegati per gli alarm non sono previsti!
				if ($WindTicketType ne 'ALARM')
				{
					my $attachments_rit = MS_GetArticleAttachments($validArticleIdForWind, $MS_TicketObject_ptr, $TicketHash_ptr->{RequestHash});
					#qui ho $TicketHash_ptr->{RequestHash}->{AttachedFiles}  che viene creato e popolato dalla sub precedente
				}

				
				
				#abilito la generazione della struttura delle note
				$ReqHash_ptr->{_ARTICLE} = $TicketHash_ptr->{_ARTICLE};
				
				#aggiungo la struttura per generare l'XML per la nota in uscita
				MS_ArticleToListOfNotesStructure($ReqHash_ptr);
			}
			#else # non esiste una nota valida per Wind... ma la nota in uscita verso Wind e' obbligatoria --> 20140218: non piu' vero!
			#{
			#	$TicketHash_ptr->{_ARTICLE}->{CREATE_TIME} = _MS_CalcTimestamp('Timestamp');
			#	$TicketHash_ptr->{_ARTICLE}->{A_SUBJECT} = 'Aggiornamento Alarm - nota automatica';
			#	$TicketHash_ptr->{_ARTICLE}->{A_BODY} = 'Alarm aggiornato.';				
			#}
			
			#abilito la generazione della struttura delle note --> MS: diventata opzionale
			#$ReqHash_ptr->{_ARTICLE} = $TicketHash_ptr->{_ARTICLE};
			
			#aggiungo la struttura per generare l'XML per la nota in uscita
			#MS_ArticleToListOfNotesStructure($ReqHash_ptr);
		}

		

		
		if($WindTicketType eq 'ALARM')
		{
			#MS 20140207: Type non si manda piu' su una update....
			#$ReqBody_ptr->{Type} = 'ALARM' ;
			
			$ReqBody_ptr->{Action} = 'UPDATE' ;
			
			$ReqBody_ptr->{startDateMalfunction} = $TicketHash_ptr->{FREETIME1} if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{FREETIME1}));
			$ReqBody_ptr->{endDateMalfunction} = $TicketHash_ptr->{FREETIME2} if(_MS_RequestBuild_HANDLER___checkIfFieldExists($TicketHash_ptr->{FREETIME2}));
		}

	
		$rit = 1;			
	}
	elsif( ($actionType eq 'NOTIFY' or $actionType eq 'NOTIFY_NO_NEW_ARTICLE' or $actionType eq 'CLOSE') and $WindTicketType eq 'ALARM') #Notify permessa solo per gli Alarm e Notify (senza invio della nota e degli allegati) permessa solo per gli Alarm
	{
		#$ReqHash_ptr->{RequestType} = 1; #Create
		#$ReqHash_ptr->{RequestType} = 2; #Update
		$ReqHash_ptr->{RequestType} = 3; #Notify
		#$ReqHash_ptr->{RequestType} = ?  #unknow
		
		
		$ReqHeader_ptr->{SourceChannel} = 'OTRS' ;
		$ReqHeader_ptr->{DestinationChannel} = 'WIND' ;
		$ReqHeader_ptr->{TimeStamp} = _MS_CalcTimestamp('Timestamp') ;
		$ReqHeader_ptr->{TransactionId} = _MS_CalcTimestamp('TransactionId') ;
		$ReqHeader_ptr->{BusinessId} = 'unknow' ; #TODO: valorizzare con i valori attesi da EAI
		
		$ReqHeader_ptr->{Username} = 'OTRS' ; #TODO: valorizzare con i valori attesi da EAI
		$ReqHeader_ptr->{Password} = '' ; #TODO: valorizzare con i valori attesi da EAI
		$ReqHeader_ptr->{MessageType} = 'NotifyToWind' ; #TODO: valorizzare con i valori attesi da EAI
		$ReqHeader_ptr->{MessageCode} = '3' ; #TODO: valorizzare con i valori attesi da EAI
		$ReqHeader_ptr->{MessageId} = $ReqHeader_ptr->{TransactionId} ; #TODO: valorizzare con i valori attesi da EAI
		
		
		
		$ReqBody_ptr->{TicketID} = $TicketHash_ptr->{TN} ; #ATTENZIONE: mandiamo fuori in TN e non l'ID !!!
		$ReqBody_ptr->{TicketIDWind} = $TicketHash_ptr->{FREETEXT9} ;
		#MS 20140207: Type non si manda piu' su una update....
		#$ReqBody_ptr->{Type} = 'ALARM' ;
		
		$ReqBody_ptr->{Action} = 'CLOSE' ; #possibile che sia l'unica possibile per le Notify sugli ALARM??
		#$ReqBody_ptr->{Status} = 'RISOLTO'; #MS_OtrsTicketStateIDToWindStatus($TicketHash_ptr->{PM_Wind_settings}, $TicketHash_ptr->{TICKET_STATE_ID}) ;
		$ReqBody_ptr->{Status} = 'EXPIRED'; 
		#$ReqBody_ptr->{Causale} = 'RESTITUITO'; #per quanto riguarda gli ALARM mi sembra priva di significato...
		
		# Disabilito i seguenti campi perche' in chiusura non mi pare il caso di apportare cambiamenti
		# MS 20140207: invece sembra che siano comunque obbligatori
		$ReqBody_ptr->{priority} = MS_OtrsTicketPriorityToWindSeverity($TicketHash_ptr->{TICKET_PRIORITY_ID}) ;
		$ReqBody_ptr->{CategoryTT} = $TicketHash_ptr->{FREETEXT15} ;
		$ReqBody_ptr->{AmbitoTT} = $TicketHash_ptr->{WIND_AMBITOTT} ;
		$ReqBody_ptr->{TimestampTT} = _MS_CalcTimestamp('TimestampTT') ;
		
		if ($actionType ne 'NOTIFY_NO_NEW_ARTICLE')
		{
			# ---------------------- Nota -------------------------
			$TicketHash_ptr->{_ARTICLE} = {};
			
			if ( exists($TicketHash_ptr->{WIND_VALID_ARTICLE_ID}) and $TicketHash_ptr->{WIND_VALID_ARTICLE_ID} > 0 ) #se esiste una nota valida per Wind fatta dall'operatore mi prendo nota ed allegati
			{
				my $validArticleIdForWind = $TicketHash_ptr->{WIND_VALID_ARTICLE_ID};
				
				# 0 -> KO (article non esiste, oppure errore generico)
				# 1 -> OK (article trovato)
				my $article_rit = MS_ArticleGetInfo($validArticleIdForWind, $MS_DBObject_ptr, $TicketHash_ptr->{_ARTICLE});
				if (!$article_rit)
				{
					return $rit;
				}
				

			
				# ---------------------- Allegati -------------------------
				# 0 -> KO (non esistono allegato per questo article, oppure errore generico)
				# num > 0 -> OK (numero degli allegati trovati)
				#
				# ATTENZIONE: gli allegati per gli alarm non sono previsti!
				#my $attachments_rit = MS_GetArticleAttachments($validArticleIdForWind, $MS_TicketObject_ptr, $TicketHash_ptr->{RequestHash});
				#qui ho $TicketHash_ptr->{RequestHash}->{AttachedFiles}  che viene creato e popolato dalla sub precedente
				

				#abilito la generazione della struttura delle note
				$ReqHash_ptr->{_ARTICLE} = $TicketHash_ptr->{_ARTICLE};			
				
				#aggiungo la struttura per generare l'XML per la nota in uscita
				MS_ArticleToListOfNotesStructure($ReqHash_ptr);
			}
			#else # non esiste una nota valida per Wind... ma la nota in uscita verso Wind e' obbligatoria --> 20140218: non piu' vero!
			#{
			#	$TicketHash_ptr->{_ARTICLE}->{CREATE_TIME} = _MS_CalcTimestamp('Timestamp');
			#	$TicketHash_ptr->{_ARTICLE}->{A_SUBJECT} = 'Chiusura Alarm - nota automatica';
			#	$TicketHash_ptr->{_ARTICLE}->{A_BODY} = 'Alarm chiuso con successo.';				
			#}

			
			#abilito la generazione della struttura delle note
			#$ReqHash_ptr->{_ARTICLE} = $TicketHash_ptr->{_ARTICLE};			
			
			#aggiungo la struttura per generare l'XML per la nota in uscita --> per la CREATE non valorizzo mai la nota ma 'Oggetto' e 'Descrizione'
			#MS_ArticleToListOfNotesStructure($ReqHash_ptr);
		}

	
		$rit = 1;			
	}

	
	#debug
	print "\nRit di _MS_RequestBuild_HANDLER = $rit\n" if($MS_DEBUG);
	
	return $rit;
}




















#Info:
#
# input:
#     xxxxxx
#
# output:
#     <nulla>
#
# Nota:xxxxxxxxxxx
#
sub MS_RequestSend
{
	my $TicketHash_ptr = shift;
	my $MS_LogObject_ptr = shift;
	my $log_level = shift;
	
	my $rit = 0;
	
	if(defined($TicketHash_ptr) and exists($TicketHash_ptr->{PM_Wind_settings}->{EAI_endpoint}) and exists($TicketHash_ptr->{RequestHash}->{RequestContent}) )
	{
		my $ua = LWP::UserAgent->new;
		$ua->agent('MS_OTRS/0.1');
		$ua->timeout(180); #180 secs
		$ua->env_proxy; #usa poxy di sistema se presente
		#$ua->default_header('Content-Type' => "text/xml");
		$ua->default_header('Content-Type' => "text/xml;charset=utf-8");
		
		my $req = HTTP::Request->new(POST => $TicketHash_ptr->{PM_Wind_settings}->{EAI_endpoint});
		#$req->header( $field => $value );
		#$req->header( $field => $value );
		#$req->header( $field => $value );
		my $tmp_utf8_content = $TicketHash_ptr->{RequestHash}->{RequestContent};
		utf8::encode($tmp_utf8_content);
		#utf8::decode($tmp_utf8_content);
		$req->content($tmp_utf8_content);
		#$req->content($TicketHash_ptr->{RequestHash}->{RequestContent});
		#$req->content(encode_utf8($TicketHash_ptr->{RequestHash}->{RequestContent}));
		
		
		eval 
		{  
			#my $response = $ua->post( $TicketHash_ptr->{PM_Wind_settings}->{EAI_endpoint}, Content => $TicketHash_ptr->{RequestHash}->{RequestContent} );
			#my $response = $ua->get('http://search.cpan.org/');
			my $response = $ua->request($req);
			
			$TicketHash_ptr->{ResponseHash} = {};
			
			if ($response->is_success)
			{
				$TicketHash_ptr->{ResponseHash}->{ResponseContent} = $response->decoded_content;
				$TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} = 0; 
				$TicketHash_ptr->{ResponseHash}->{ResponseErrorMessage} = '';
				$rit = 1;
				
				$MS_LogObject_ptr->Log( Priority => 'notice', Message => "_MS_Full_ *** OK invio HTTP::Request - ".$response->status_line) if(defined($MS_LogObject_ptr));
				if (defined($log_level) and $log_level > 1 and defined($MS_LogObject_ptr))
				{
					$MS_LogObject_ptr->Log( Priority => 'notice', Message => "_MS_Full_ *** OK invio HTTP::Request - Risposta del server: ".$response->decoded_content) ;
					
					$MS_LogObject_ptr->Log( Priority => 'notice', Message => "_MS_Full_ *** OK invio HTTP::Request - Request da OTRS ad EAI in UTF8: ".$tmp_utf8_content) ;
				}
				
			}
			else
			{
				$TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} = 1; 
				$TicketHash_ptr->{ResponseHash}->{ResponseErrorMessage} = $response->status_line;
				
				if (defined($MS_LogObject_ptr))
				{
					$MS_LogObject_ptr->Log( Priority => 'error', Message => "_MS_Full_ *** ERRORE invio HTTP::Request - ".$response->status_line);
					$MS_LogObject_ptr->Log( Priority => 'error', Message => "_MS_Full_ *** ERRORE invio HTTP::Request - Risposta del server: ".$response->decoded_content);
					$MS_LogObject_ptr->Log( Priority => 'notice', Message => "_MS_Full_ *** OK invio HTTP::Request - Request da OTRS ad EAI in UTF8: ".$tmp_utf8_content);
				}
				

			}
		};
		if($@)
		{
			#gestione errore
			$MS_LogObject_ptr->Log( Priority => 'error', Message => "_MS_Full_ *** Errore durante invio HTTP::Request - eccezione sulla eval") if(defined($MS_LogObject_ptr));
			$rit = 0;
		}		
	}

	

	return $rit;
}





# 0 => errore   .... 1 => ok
sub _MS_RequestBuildAndSend_HANDLER
{
	my $MSinput = shift;
	
	#my $ticketID = $MSinput->{ticketID};
	my $MS_TicketObject_ptr = $MSinput->{MS_TicketObject_ptr};
	my $RequestType = $MSinput->{RequestType}; #CREATE, UPDATE, NOTIFY
	#my $WindTicketType = $MSinput->{WindTicketType};#INCIDENT, ALARM
	my $TicketHash_ptr = $MSinput->{TicketHash_ptr};
	my $OTRS_XMLObject_ptr = $MSinput->{OTRS_XMLObject_ptr}; #opzionale
	
	
	my $outputMessages_ptr = $MSinput->{OutputMessage_ptr};
	my $export_messages = 0;
	$export_messages = 1 if(exists($MSinput->{OutputMessage_ptr}) and (ref $outputMessages_ptr eq 'HASH'));
	
	
	my $rit = 0;
	
	my $MS_LogObject_ptr = $MS_TicketObject_ptr->{LogObject};
	my $result = MS_RequestHashToXMLString($TicketHash_ptr->{RequestHash});
	
	if ($result)
	{
				#debug
				print "\nZZZ1_A\n" if($MS_DEBUG);		
		
		$result = MS_RequestSend($TicketHash_ptr, $MS_LogObject_ptr, $TicketHash_ptr->{PM_Wind_settings}->{log_level});
		if ($result)
		{
				#debug
				print "\nZZZ1_B\n" if($MS_DEBUG);			
			
			if(exists($TicketHash_ptr->{ResponseHash}->{ResponseContent}))
			{
				#debug
				print "\nZZZ1_C\n" if($MS_DEBUG);				
				
				$TicketHash_ptr->{Errors} = {};
				$TicketHash_ptr->{Errors}->{StopEsecution} = 0;
				$TicketHash_ptr->{Errors}->{InternalCode} = 0;
				$TicketHash_ptr->{Errors}->{InternalDescr} = '';
				
				if (defined($OTRS_XMLObject_ptr) and (ref $OTRS_XMLObject_ptr eq 'HASH'))
				{
					$TicketHash_ptr->{OTRS_XMLObject} = $OTRS_XMLObject_ptr;
				}
				else
				{
					eval 
					{
						#use Kernel::Config;
						#use Kernel::System::Encode;
						#use Kernel::System::Log;
						#use Kernel::System::Main;
						#use Kernel::System::DB;
						use Kernel::System::XML;
						
						#if(!exists($MS_TicketObject_ptr->{ConfigObject}) or !defined($MS_TicketObject_ptr->{ConfigObject}) or ref($MS_TicketObject_ptr->{ConfigObject}) ne 'HASH')
						#{
						#	
						#}
						
						$TicketHash_ptr->{OTRS_XMLObject} = Kernel::System::XML->new(
																					ConfigObject => $MS_TicketObject_ptr->{ConfigObject},
																					LogObject    => $MS_TicketObject_ptr->{LogObject},
																					DBObject     => $MS_TicketObject_ptr->{DBObject},
																					MainObject   => $MS_TicketObject_ptr->{MainObject},
																					EncodeObject => $MS_TicketObject_ptr->{EncodeObject},
																			  );
					};
					if($@)
					{
						#gestione errore
						$outputMessages_ptr->{message_more} = "_MSFull_ [ERRORE] Errore interno durante la creazione di un oggetto di tipo Kernel::System::XML (OTRS_XMLObject) \n" if($export_messages);
						$MS_LogObject_ptr->Log( Priority => 'notice', Message => "_MSFull_ [ERRORE] Errore interno durante la creazione di un oggetto di tipo Kernel::System::XML (OTRS_XMLObject) \n");	
						$rit = 0;
					}

				}
				
				
				$TicketHash_ptr->{OTRS_LogObject} = $MS_TicketObject_ptr->{LogObject};


				#debug
				print "\nZZZ1\n" if($MS_DEBUG);

				#proviamo a fare il parsing
				my $XMLHash_ptr = MS_XMLCheckParsing($TicketHash_ptr, $TicketHash_ptr->{ResponseHash}->{ResponseContent});
				
				#se le cose tornano...
				if ( defined($XMLHash_ptr) and (ref $XMLHash_ptr eq 'ARRAY')  )
				{
					MS_ResponseToResponseHash($TicketHash_ptr, $XMLHash_ptr) ;
					
					#debug
					print "\nZZZ2\n" if($MS_DEBUG);
					
					# 0 => KO.... 1 => OK
					my $response_result = MS_CheckResponseFromWind($TicketHash_ptr, $RequestType);
					if ($response_result) #risposta FORMALMENTE corretta
					{
						
						#debug
						print "\nZZZ3\n" if($MS_DEBUG);
					
						if (!exists($TicketHash_ptr->{ResponseHash}->{ResponseErrorCode}) or (exists($TicketHash_ptr->{ResponseHash}->{ResponseErrorCode}) and $TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} == 0) )
						{
							#non ci sono errori da segnalare
							$rit = 1;
						}
						else
						{
							#Wind mi ha inviato un errore..
							$outputMessages_ptr->{message_more} = "_MSFull_ [ERRORE] La Response arrivata da Wind/EAI mi segnala errore: ResponseErrorCode = $TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} - ResponseErrorMessage = $TicketHash_ptr->{ResponseHash}->{ResponseErrorMessage} \n" if($export_messages);
							$MS_LogObject_ptr->Log( Priority => 'notice', Message => "_MSFull_ [ERRORE] La Response arrivata da Wind/EAI mi segnala errore: ResponseErrorCode = $TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} - ResponseErrorMessage = $TicketHash_ptr->{ResponseHash}->{ResponseErrorMessage} \n");	
							$rit = 0;
						}
						
					}
					else
					{
						#gestione errore
						$outputMessages_ptr->{message_more} = "_MSFull_ [ERRORE] La Response arrivata da Wind/EAI risulta in formato non atteso: ResponseErrorCode = $TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} - ResponseErrorMessage = $TicketHash_ptr->{ResponseHash}->{ResponseErrorMessage} \n" if($export_messages);
						$MS_LogObject_ptr->Log( Priority => 'notice', Message => "_MSFull_ [ERRORE] La Response arrivata da Wind/EAI risulta in formato non atteso: ResponseErrorCode = $TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} - ResponseErrorMessage = $TicketHash_ptr->{ResponseHash}->{ResponseErrorMessage} \n");	
						$rit = 0;
					}
					
				}
				else
				{
					$TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} = 1;
					$TicketHash_ptr->{ResponseHash}->{ResponseErrorMessage} = 'Response malformata';
					
					#gestione errore
					$outputMessages_ptr->{message_more} = "_MSFull_ [ERRORE] La Response arrivata da Wind/EAI sembra malformata: ResponseErrorCode = $TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} - ResponseErrorMessage = $TicketHash_ptr->{ResponseHash}->{ResponseErrorMessage} \n" if($export_messages);
					$MS_LogObject_ptr->Log( Priority => 'notice', Message => "_MSFull_ [ERRORE] La Response arrivata da Wind/EAI sembra malformata: ResponseErrorCode = $TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} - ResponseErrorMessage = $TicketHash_ptr->{ResponseHash}->{ResponseErrorMessage} \n");	
					$rit = 0;
				}
			}						
		}
	}
	
	return $rit;				
}






# 0 => errore .... 1 => OK
sub MS_RequestBuildAndSend
{
	my $ticketID = shift;
	my $MS_TicketObject_ptr = shift;
	my $RequestType = shift; #CREATE, UPDATE, NOTIFY
	my $WindTicketType = shift; #INCIDENT, ALARM
	
	my $OTRS_XMLObject_ptr = shift; #opzionale
	my $outputHash = shift; # opzionale: utile per messaggi di ritorno ed altre info per la GUI (da verificare)
	
	if (!defined($outputHash) or (ref $outputHash ne 'HASH'))
	{
		$outputHash = {};
	}
	
	
	my $rit = 0;
	
	
	
	if (!defined($ticketID) or $ticketID <= 0 or !defined($MS_TicketObject_ptr)  or !defined($RequestType) or
		 $RequestType !~ m/^(?:CREATE|UPDATE|NOTIFY|REOPEN|UPDATE_NO_NEW_ARTICLE|NOTIFY_NO_NEW_ARTICLE)$/i or !defined($WindTicketType) or
		 $WindTicketType !~ m/^(?:INCIDENT|ALARM)$/i
		 )
	{
		#$MS_TicketObject_ptr->{LogObject}->Log( Priority => 'notice', Message => "MS_RequestBuildAndSend *********** ticketID=$ticketID, RequestType=$RequestType, WindTicketType=$WindTicketType");
		return $rit;
	}
	

	my $result = 0;
	
	my $MS_LogObject_ptr = $MS_TicketObject_ptr->{LogObject};
	my $TicketHash_ptr = {};
	
	
	if($WindTicketType =~ m/^INCIDENT$/i)
	{
		if ($RequestType =~ m/^CREATE$/i) # possibile per gli Incident/SR
		{
			$result = _MS_RequestBuild_HANDLER($ticketID, 0, $MS_TicketObject_ptr, 'CREATE', 'INCIDENT', $TicketHash_ptr);
		}
		elsif ($RequestType =~ m/^REOPEN$/i) # possibile per gli Incident/SR
		{
			$result = _MS_RequestBuild_HANDLER($ticketID, 0, $MS_TicketObject_ptr, 'REOPEN', 'INCIDENT', $TicketHash_ptr);
		}
		else
		{
			$outputHash->{message} = 'Errore interno (Su un Incident viene richiesto qualcosa di diverso da una CREATE e da una REOPEN)';
			return $rit;
		}
		
	}
	elsif($WindTicketType =~ m/^ALARM$/i)
	{
		if ($RequestType =~ m/^CREATE$/i) #unico possibile per gli Incident/SR
		{
			$result = _MS_RequestBuild_HANDLER($ticketID, 0, $MS_TicketObject_ptr, 'CREATE', 'ALARM', $TicketHash_ptr);
		}
		elsif ($RequestType =~ m/^UPDATE$/i) 
		{
			$result = _MS_RequestBuild_HANDLER($ticketID, 0, $MS_TicketObject_ptr, 'UPDATE', 'ALARM', $TicketHash_ptr);
		}
		elsif ($RequestType =~ m/^CLOSE/i) 
		{
			$result = _MS_RequestBuild_HANDLER($ticketID, 0, $MS_TicketObject_ptr, 'CLOSE', 'ALARM', $TicketHash_ptr);
		}
		elsif ($RequestType =~ m/^UPDATE_NO_NEW_ARTICLE$/i) 
		{
			$result = _MS_RequestBuild_HANDLER($ticketID, 0, $MS_TicketObject_ptr, 'UPDATE_NO_NEW_ARTICLE', 'ALARM', $TicketHash_ptr);
		}
		elsif ($RequestType =~ m/^NOTIFY$/i) 
		{
			$result = _MS_RequestBuild_HANDLER($ticketID, 0, $MS_TicketObject_ptr, 'NOTIFY', 'ALARM', $TicketHash_ptr);
		}
		elsif ($RequestType =~ m/^NOTIFY_NO_NEW_ARTICLE$/i) 
		{
			$result = _MS_RequestBuild_HANDLER($ticketID, 0, $MS_TicketObject_ptr, 'NOTIFY_NO_NEW_ARTICLE', 'ALARM', $TicketHash_ptr);
		}
		else
		{
			$outputHash->{message} = 'Errore interno (Su un Alarm viene richiesta una azione non prevista)';
			return $rit;
		}
	}
	


	if ($result)
	{
		$result = _MS_RequestBuildAndSend_HANDLER( {
						MS_TicketObject_ptr => $MS_TicketObject_ptr,
						RequestType => $RequestType,
						TicketHash_ptr => $TicketHash_ptr,
						OTRS_XMLObject_ptr => $OTRS_XMLObject_ptr,
						OutputMessage_ptr => $outputHash,
						});

		#debug
		print "\result in MS_RequestBuildAndSend = $result\n" if($MS_DEBUG);
		
		if ($result)
		{
			#tutto ok
			if ($RequestType eq 'CREATE') #ho mandato una Request di CREATE
			{
				#controllo l'id del ticket creato su Wind e lo salvo nel db e passo il ticket nello stato 'APERTO'
				if (exists($TicketHash_ptr->{ResponseHash}->{Response}->{TicketID}) )
				{
					my $idTT_Wind = $TicketHash_ptr->{ResponseHash}->{Response}->{TicketID};
					eval 
					{  
						$MS_TicketObject_ptr->{DBObject}->Do(
										SQL => "UPDATE ticket SET freetext9 = ? WHERE id = ?",
										Bind => [ \$idTT_Wind, \$ticketID ],
						);
						
						$MS_TicketObject_ptr->StateSet(
							 StateID  => $TicketHash_ptr->{PM_Wind_settings}->{ticketStateID_Open}, #Open = 4
							 TicketID => $ticketID,
							 UserID   => $TicketHash_ptr->{PM_Wind_settings}->{system_user_id},
							 SendNoNotification => 1,
									);
						
						$rit = 1; #ora siamo ok
					};
					if($@)
					{
						$MS_LogObject_ptr->Log( Priority => 'notice', Message => "_MSFull_ [ERRORE] Errore dopo la ricezione della Response da EAI/Wind - non riesco ad inserire nel db l'ID del ticket Wind - ( ticketID=$ticketID, RequestType=$RequestType, WindTicketType=$WindTicketType )");
					}

				}
				else #ho mandato una Request di UPDATE o di NOTIFY
				{
					$MS_LogObject_ptr->Log( Priority => 'notice', Message => "_MSFull_ [ERRORE] Errore dopo la ricezione della Response da EAI/Wind - non trovo ID del ticket Wind - ( ticketID=$ticketID, RequestType=$RequestType, WindTicketType=$WindTicketType )");
				}
				
			}
			else
			{
				$rit = 1;
			}
		}
		else
		{
			#lod dell'errore gia' gestito nella _MS_RequestBuildAndSend_HANDLER
			$outputHash->{message} = "_MSFull_ [ERRORE] Errore durante il processo di invio Request e validazione Response: ticketID=$ticketID, RequestType=$RequestType, WindTicketType=$WindTicketType";
			$MS_LogObject_ptr->Log( Priority => 'notice', Message => "_MSFull_ [ERRORE] Errore durante il processo di invio Request e validazione Response: ticketID=$ticketID, RequestType=$RequestType, WindTicketType=$WindTicketType");	
		}
		
	}
	else
	{
		$outputHash->{message} = "_MSFull_ [ERRORE] Errore durante la creazione di una Request: ticketID=$ticketID, RequestType=$RequestType, WindTicketType=$WindTicketType";
		$MS_LogObject_ptr->Log( Priority => 'notice', Message => "_MSFull_ [ERRORE] Errore durante la creazione di una Request: ticketID=$ticketID, RequestType=$RequestType, WindTicketType=$WindTicketType");	
	}



	if (exists($TicketHash_ptr->{PM_Wind_settings}->{log_level}) and $TicketHash_ptr->{PM_Wind_settings}->{log_level} > 2)
	{
		$MS_LogObject_ptr->Log( Priority => 'notice', Message => "_MSFull_ [INFO] TicketHash_ptr =\n".Dumper($TicketHash_ptr)."\n");	
	}
	elsif (exists($TicketHash_ptr->{PM_Wind_settings}->{log_level}) and $TicketHash_ptr->{PM_Wind_settings}->{log_level} > 1)
	{
		$MS_LogObject_ptr->Log( Priority => 'notice', Message => "_MSFull_ [INFO] Request=\n".Dumper($TicketHash_ptr->{RequestHash}->{RequestContent})."\n") if(exists($TicketHash_ptr->{RequestHash}->{RequestContent}));
		
		$MS_LogObject_ptr->Log( Priority => 'notice', Message => "_MSFull_ [INFO] Response=\n".Dumper($TicketHash_ptr->{ResponseHash}->{ResponseContent})."\n") if(exists($TicketHash_ptr->{ResponseHash}->{ResponseContent}));	
	}
	
	
	return $rit;
}



1;

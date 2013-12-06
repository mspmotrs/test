package MSRequestToWindUtil;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

# Exporting the saluta routine
our @EXPORT = qw(XXXXXXXXXXXXX);
# Exporting the saluta2 routine on demand basis.
#our @EXPORT_OK = qw(saluta2);




# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/../cpan-lib";




# ----------------- Moduli necessari ------------------
#require LWP::UserAgent;
use LWP::UserAgent;


# ----------------- Moduli custom necessari ------------------
use MSTicketUtil;






sub _MS_CalcTimestamp
{
	my $type = shift; # Timestamp -> ritorna il formato previsto per "Timestamp" (campo dell'header)
							# TimestampTT -> ritorna il formato previsto per "TimestampTT" (campo del body)
							
	my $rit = '';
	
	if (!defined($type))
	{
		return $rit;
	}
	


	my  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$year += 1900;
	$mon += 1;
	
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
		
		$$XML_tmp = '<?xml version="1.0" encoding="UTF-8"?>';
		$$XML_tmp .= "\n";
		$$XML_tmp .= "<OTRS_API>\n";
		$$XML_tmp .= "<TicketRequest>\n";
	
	
		$$XML_tmp .= "<Header>\n"; #TODO: verificare la correttezza di questo tag contenitore 
		foreach my $key (keys(%{$Hash_ptr->{HEADER}}) )
		{
			$$XML_tmp .= "<$key>".$Hash_ptr->{HEADER}->{$key}."</$key>\n";
		}
		$$XML_tmp .= "</Header>\n";

		$$XML_tmp .= "<Body>\n"; #TODO: verificare la correttezza di questo tag contenitore 
		foreach my $key (keys(%{$Hash_ptr->{BODY}}) )
		{
			$$XML_tmp .= "<$key>".$Hash_ptr->{BODY}->{$key}."</$key>";
		}
		
		
		
		#Note (in verita' ci sara' sempre al massimo una nota)
		if (exists($Hash_ptr->{ListOfNotes}))
		{
			my $notesCount = scalar@{$Hash_ptr->{ListOfNotes}};
			if ($notesCount > 0)
			{
				$$XML_tmp .= "<ListOfNotes>\n";
				for(my $i = 0; $i<$notesCount; $i++)
				{
					$$XML_tmp .= "<Note>\n";
					
					$$XML_tmp .= "<Team>".$Hash_ptr->{ListOfNotes}->[$i]->{Team}."</Team>" if(exists($Hash_ptr->{ListOfNotes}->[$i]->{Team}));
					$$XML_tmp .= "<CreationDate>".$Hash_ptr->{ListOfNotes}->[$i]->{CreationDate}."</CreationDate>" if(exists($Hash_ptr->{ListOfNotes}->[$i]->{CreationDate}));
					$$XML_tmp .= "<Description>".$Hash_ptr->{ListOfNotes}->[$i]->{Description}."</Description>";
					
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
					
					$$XML_tmp .= "<FullFileName>".$Hash_ptr->{AttachedFiles}->[$i]->{Filename}."</FullFileName>";
					$$XML_tmp .= "<TypeFile>".$Hash_ptr->{AttachedFiles}->[$i]->{ContentType}."</TypeFile>";
					$$XML_tmp .= "<FileBody>".$Hash_ptr->{AttachedFiles}->[$i]->{Content}."</FileBody>";
					#$XML_tmp .= "<dataCreazione>".$Hash_ptr->{AttachedFiles}->[$i]->{---DATO MANCANTE ---}."</dataCreazione>";
					
					$$XML_tmp .= "</Attachment>\n";
				}
				$$XML_tmp .= "</ListOfAttachment>\n";
			}
		}
		

		
		$$XML_tmp .= "</Body>\n";		
		
		$$XML_tmp .= "</TicketRequest>\n";		
		$$XML_tmp .= "</OTRS_API>\n";
		
		$rit = 1;
	}
	
	
	
	return $rit;
}









sub MS_ArticleToListOfNotesStructure
{
	my $TicketHash_ptr = shift;
	
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







#Info:
#
# input:
#     xxxxxx
#
# output:
#     undef - se la richiesta non puo' essere preparata
#		stringa - che rappresenta la richiesta in formato XML se tutto e' OK
#
# Nota:xxxxxxxxxxx
#
sub MS_RequestBuild_Create_Incident
{
	my $ticket_id_or_tn = shift;
	my $TicketID_is_a_TN = shift; #ad 1 se mi viene passato un TN al posto di un ID
   my $MS_TicketObject_ptr = shift;
	my $TicketHash_ptr = shift; # opzionale
	
	
	my $rit = undef;
	
	if( !defined($ticket_id_or_tn) or !defined($TicketID_is_a_TN) or !defined($MS_TicketObject_ptr) )
	{
		return $rit; 
	}
	

	my $MS_DBObject_ptr = $MS_TicketObject_ptr->{DBObject};
	my $MS_ConfigObject_ptr = $MS_DBObject_ptr->{ConfigObject};
	my $MS_LogObject_ptr = $MS_DBObject_ptr->{LogObject};
	
	$TicketHash_ptr = {} if(!defined($TicketHash_ptr));	
	

	# 0 -> NON sono presenti tutte le info necessarie
	# 1 -> se ok
	if( MS_CheckIfIncidentOrSrIsOkForCreate($ticket_id_or_tn, $TicketID_is_a_TN, $MS_DBObject_ptr, $TicketHash_ptr) )
	{
		#gestione note
		my $validArticleIdForWind = $TicketHash_ptr->{WIND_VALID_ARTICLE_ID};
		$TicketHash_ptr->{_ARTICLE} = {};
		
		# 0 -> KO (article non esiste, oppure errore generico)
		# 1 -> OK (article trovato)
		my $article_rit = MS_ArticleGetInfo($validArticleIdForWind, $MS_DBObject_ptr, $TicketHash_ptr->{_ARTICLE});
		if (!$article_rit)
		{
			return $rit;
		}
		
		#aggiungo la struttura per generare l'XML per la nota in uscita --> per la CREATE non valorizzo mai la nota ma 'Oggetto' e 'Descrizione'
		#MS_ArticleToListOfNotesStructure($TicketHash_ptr);
		
		$TicketHash_ptr->{RequestHash} = {};
		
		
		
		# 0 -> KO (non esistono allegato per questo article, oppure errore generico)
		# num > 0 -> OK (numero degli allegati trovati)
		#
		my $attachments_rit = MS_GetArticleAttachments($validArticleIdForWind, $MS_TicketObject_ptr, $TicketHash_ptr->{RequestHash});
		#qui ho $TicketHash_ptr->{RequestHash}->{AttachedFiles}  che viene creato e popolato dalla sub precedente
		
		
		
		
		
		
		my $ReqHash_ptr = $TicketHash_ptr->{RequestHash};
		
		$ReqHash_ptr->{RequestType} = 1; #Create
		#$ReqHash_ptr->{RequestType} = 2; #Update
		#$ReqHash_ptr->{RequestType} = 3; #Notify
		#$ReqHash_ptr->{RequestType} = ?  #unknow
		
		$ReqHash_ptr->{HEADER} = {};
		my $ReqHeader_ptr = $ReqHash_ptr->{HEADER};
		$ReqHash_ptr->{BODY} = {};
		my $ReqBody_ptr = $ReqHash_ptr->{BODY};
		

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
		#Referente	
		#Nota	
		#address 	
		#prov
		#city	
		#cap
		
		$ReqHeader_ptr->{SourceChannel} = 'OTRS' ;
		$ReqHeader_ptr->{DestinationChannel} = 'WIND' ;
		$ReqHeader_ptr->{TimeStamp} = _MS_CalcTimestamp('TimeStamp') ;
		$ReqHeader_ptr->{TransactionId} = _MS_CalcTimestamp('TransactionId') ;
		$ReqHeader_ptr->{BusinessId} = 'unknow' ; #TODO: valorizzare con i valori attesi da EAI 
		
		
		#$ReqBody_ptr->{TickedIDWind} = '' ; 
		$ReqBody_ptr->{Type} = 'INCIDENT' ; 
		$ReqBody_ptr->{Action} = 'CREATE' ; 
		#$ReqBody_ptr->{Status} = '' ; 
		$ReqBody_ptr->{priority} = $TicketHash_ptr->{TICKET_PRIORITY_ID} ;
		$ReqBody_ptr->{CategoryTT} = $TicketHash_ptr->{FREETEXT15} ;
		$ReqBody_ptr->{AmbitoTT} = $TicketHash_ptr->{WIND_AMBITOTT} ;
		$ReqBody_ptr->{Oggetto} = $TicketHash_ptr->{_ARTICLE}->{A_SUBJECT}; #Oggetto della nota per Wind
		$ReqBody_ptr->{Descrizione} = $TicketHash_ptr->{_ARTICLE}->{A_BODY}; #Corpo della nota per Wind
		$ReqBody_ptr->{TimestampTT} = _MS_CalcTimestamp('TimestampTT') ;
		
		#$ReqBody_ptr->{startDateMalfunction} = '' ; 
		#$ReqBody_ptr->{endDateMalfunction} = '' ;
		$ReqBody_ptr->{segmentCustomer} = $TicketHash_ptr->{FREETEXT15} ;
		$ReqBody_ptr->{msisdn} = $TicketHash_ptr->{WIND_MSISDN} ;
		$ReqBody_ptr->{imsi} = $TicketHash_ptr->{WIND_IMSI} ;
		$ReqBody_ptr->{iccid} = $TicketHash_ptr->{WIND_ICCID} ;
		$ReqBody_ptr->{idLinea} = $TicketHash_ptr->{WIND_ID_LINEA} ;
		$ReqBody_ptr->{tipoLinea} = $TicketHash_ptr->{WIND_TIPO_LINEA} ;
		$ReqBody_ptr->{mnpType} = $TicketHash_ptr->{WIND_MNP_TYPE} ;
		$ReqBody_ptr->{imei} = $TicketHash_ptr->{WIND_IMEI} ;
		$ReqBody_ptr->{Referente} = $TicketHash_ptr->{FREETEXT16} ;
		#$ReqBody_ptr->{Nota} = '' ; # Nella CREATE non utilizzo la Nota
		$ReqBody_ptr->{address } = $TicketHash_ptr->{WIND_Indirizzo} ;
		$ReqBody_ptr->{prov} = $TicketHash_ptr->{WIND_Provincia} ;
		$ReqBody_ptr->{city} = $TicketHash_ptr->{WIND_Comune} ;
		$ReqBody_ptr->{cap} = $TicketHash_ptr->{WIND_CAP} ;
	
		$rit = 1;
	}
	
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
sub MS_RequestBuild_Create_Alarm
{
	

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
sub MS_RequestBuild_Update_Alarm
{
	

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
sub MS_RequestBuild_Notify_Alarm
{
	

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
	
	my $rit = 0;
	
	if(defined($TicketHash_ptr) and exists($TicketHash_ptr->{PM_Wind_settings}->{EAI_endpoint}) and exists($TicketHash_ptr->{RequestHash}->{RequestContent}) )
	{
		my $ua = LWP::UserAgent->new;
		$ua->agent('MS_OTRS/0.1');
		$ua->timeout(180); #180 secs
		$ua->env_proxy; #usa poxy di sistema se presente
		$ua->default_header('Content-Type' => "text/xml");
	 
		
		eval 
		{  
			my $response = $ua->post( $TicketHash_ptr->{PM_Wind_settings}->{EAI_endpoint}, Content => $TicketHash_ptr->{RequestHash}->{RequestContent} );
			#my $response = $ua->get('http://search.cpan.org/');
			
			$TicketHash_ptr->{ResponseHash} = {};
			
			if ($response->is_success)
			{
				$TicketHash_ptr->{ResponseHash}->{ResponseContent} = $response->decoded_content;
				$TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} = 0; 
				$TicketHash_ptr->{ResponseHash}->{ResponseErrorMessage} = '';
				$rit = 1;
			}
			else
			{
				$TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} = 1; 
				$TicketHash_ptr->{ResponseHash}->{ResponseErrorMessage} = $response->status_line;
			}
		};
		if($@)
		{
			#gestione errore
			$rit = 0;
		}		
	}

	

	
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
	
	my $rit = 0;
	
	my $MS_LogObject_ptr = $MS_TicketObject_ptr->{LogObject};
	my $result = MS_RequestHashToXMLString($TicketHash_ptr->{RequestHash});
	
	if ($result)
	{
		$result = MS_RequestSend($TicketHash_ptr);
		if ($result)
		{
			if(exists($TicketHash_ptr->{ResponseHash}->{ResponseContent}))
			{
				$TicketHash_ptr->{Errors} = {};
				$TicketHash_ptr->{Errors}->{StopEsecution} = 0;
				$TicketHash_ptr->{Errors}->{InternalCode} = 0;
				$TicketHash_ptr->{Errors}->{InternalDescr} = '';
				
				if (defined($OTRS_XMLObject_ptr))
				{
					$TicketHash_ptr->{OTRS_XMLObject} = $OTRS_XMLObject_ptr;
				}
				else
				{
					eval 
					{  
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
						#gestione errore
						$MS_LogObject_ptr->Log( Priority => 'error', Message => "_MSFull_ [ERRORE] Errore interno durante la creazione di un oggetto di tipo Kernel::System::XML (OTRS_XMLObject) \n");	
						$rit = 0;
					}

				}
				
				
				$TicketHash_ptr->{OTRS_LogObject} = $MS_TicketObject_ptr->{LogObject};


				#proviamo a fare il parsing
				my $XMLHash_ptr = MS_XMLCheckParsing($TicketHash_ptr, $TicketHash_ptr->{ResponseHash}->{ResponseContent});
				
				#se le cose tornano...
				if ( defined($XMLHash_ptr) and (ref $XMLHash_ptr eq 'ARRAY')  )
				{
					MS_ResponseToResponseHash($TicketHash_ptr, $XMLHash_ptr) ;
					
					# 0 => KO.... 1 => OK
					my $response_result = MS_CheckResponseFromWind($TicketHash_ptr, $RequestType);
					if ($response_result) #risposta FORMALMENTE corretta
					{
						if (!exists($TicketHash_ptr->{ResponseHash}->{ResponseErrorCode}) or (exists($TicketHash_ptr->{ResponseHash}->{ResponseErrorCode}) and $TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} == 0) )
						{
							#non ci sono errori da segnalare
							$rit = 1;
						}
						else
						{
							#Wind mi ha inviato un errore..
						$MS_LogObject_ptr->Log( Priority => 'error', Message => "_MSFull_ [ERRORE] La Response arrivata da Wind/EAI mi segnala errore: ResponseErrorCode = $TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} - ResponseErrorMessage = $TicketHash_ptr->{ResponseHash}->{ResponseErrorMessage} \n");	
							$rit = 0;
						}
						
					}
					else
					{
						#gestione errore
						$MS_LogObject_ptr->Log( Priority => 'error', Message => "_MSFull_ [ERRORE] La Response arrivata da Wind/EAI ha qualche problema: ResponseErrorCode = $TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} - ResponseErrorMessage = $TicketHash_ptr->{ResponseHash}->{ResponseErrorMessage} \n");	
						$rit = 0;
					}
					
				}
				else
				{
					$TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} = 1;
					$TicketHash_ptr->{ResponseHash}->{ResponseErrorMessage} = 'Response malformata';
					
					#gestione errore
					$MS_LogObject_ptr->Log( Priority => 'error', Message => "_MSFull_ [ERRORE] La Response arrivata da Wind/EAI sembra malformata: ResponseErrorCode = $TicketHash_ptr->{ResponseHash}->{ResponseErrorCode} - ResponseErrorMessage = $TicketHash_ptr->{ResponseHash}->{ResponseErrorMessage} \n");	
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
	
	my $rit = 0;
	
	
	
	if (!defined($ticketID) or $ticketID <= 0 or !defined($MS_TicketObject_ptr)  or !defined($RequestType) or
		 $RequestType !~ m/^(?:CREATE|UPDATE|NOTIFY)$/i or !defined($WindTicketType) or
		 $WindTicketType !~ m/^(?:INCIDENT|ALARM)$/i
		 )
	{
		return $rit;
	}
	
	
	my $result = 0;
	
	my $MS_LogObject_ptr = $MS_TicketObject_ptr->{LogObject};
	my $TicketHash_ptr = {};
	
	if($WindTicketType =~ m/^INCIDENT$/i)
	{
		if ($RequestType =~ m/^CREATE$/i) #unico possibile per gli Incident/SR
		{
			$result = MS_RequestBuild_Create_Incident($ticketID, 0, $MS_TicketObject_ptr, $TicketHash_ptr);
		}
		else
		{
			return $rit;
		}
		
	}
	elsif($WindTicketType =~ m/^ALARM$/i)
	{
		if ($RequestType =~ m/^CREATE$/i) #unico possibile per gli Incident/SR
		{
			$result = MS_RequestBuild_Create_Alarm($ticketID, 0, $MS_TicketObject_ptr, $TicketHash_ptr);
		}
		elsif ($RequestType =~ m/^UPDATE$/i) #unico possibile per gli Incident/SR
		{
			$result = MS_RequestBuild_Update_Alarm($ticketID, 0, $MS_TicketObject_ptr, $TicketHash_ptr);
		}
		elsif ($RequestType =~ m/^NOTIFY$/i) #unico possibile per gli Incident/SR
		{
			$result = MS_RequestBuild_Notify_Alarm($ticketID, 0, $MS_TicketObject_ptr, $TicketHash_ptr);
		}
		else
		{
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
						});
		
		if ($result)
		{
			#tutto ok
			$rit = 1;
		}
		else
		{
			#lod dell'errore gia' gestito nella _MS_RequestBuildAndSend_HANDLER
			$MS_LogObject_ptr->Log( Priority => 'error', Message => "_MSFull_ [ERRORE] Errore durante il processo di invio Request e validazione Reasponse: ticketID=$ticketID, RequestType=$RequestType, WindTicketType=$WindTicketType");	
		}
		
	}
	else
	{
		$MS_LogObject_ptr->Log( Priority => 'error', Message => "_MSFull_ [ERRORE] Errore durante la creazione di una Request: ticketID=$ticketID, RequestType=$RequestType, WindTicketType=$WindTicketType");	
	}



	if (exists($TicketHash_ptr->{PM_Wind_settings}->{log_level}) and $TicketHash_ptr->{PM_Wind_settings}->{log_level} > 2)
	{
		$MS_LogObject_ptr->Log( Priority => 'error', Message => "_MSFull_ [INFO] TicketHash_ptr =\n".Data::Dumper($TicketHash_ptr)."\n");	
	}
	elsif (exists($TicketHash_ptr->{PM_Wind_settings}->{log_level}) and $TicketHash_ptr->{PM_Wind_settings}->{log_level} > 1)
	{
		$MS_LogObject_ptr->Log( Priority => 'warning', Message => "_MSFull_ [INFO] Request=\n".Data::Dumper($TicketHash_ptr->{RequestHash}->{RequestContent})."\n") if(exists($TicketHash_ptr->{RequestHash}->{RequestContent}));
		
		$MS_LogObject_ptr->Log( Priority => 'warning', Message => "_MSFull_ [INFO] Response=\n".Data::Dumper($TicketHash_ptr->{ResponseHash}->{ResponseContent})."\n") if(exists($TicketHash_ptr->{ResponseHash}->{ResponseContent}));	
	}
	
	
	return $rit;
}



1;

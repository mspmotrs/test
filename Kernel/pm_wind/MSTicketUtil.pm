package MSTicketUtil;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

# Exporting the saluta routine
our @EXPORT = qw(MS_TicketGetInfoShort MS_TicketGetWindType MS_TicketGetWindPermission MS_Check_Category MS_CreateAlarm MS_AddArticleToTicket MS_AddAttachmentToArticle MS_CheckIfExistsFreshArticleForWind MS_CheckIfAlarmIsOkForCreate MS_CheckIfIncidentOrSrIsOkForCreate MS_CheckIfExistsAlarmArticleForWind MS_ArticleGetInfo MS_GetArticleAttachments);
# Exporting the saluta2 routine on demand basis.
#our @EXPORT_OK = qw(saluta2);




# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/../cpan-lib";

# ----------------- Attiva/disattiva debug per sviluppo ------------------
my $MS_DEBUG = 1; # 0 -> disattivato, 1 -> attivato



# ----------------- Moduli custom necessari ------------------
use MSErrorUtil;
use MSConfigUtil;








##############################################################################
#Dato un ticket_id ritorna tutte le info del ticket corrispondente (tranne le note -> articles)
#
#input:
# - id o tn del tichet di cui estrarre le info
# - flag che mi dice se mi viene passato un id o un tn
# - ptr a "DBObject" di OTRS
# - ptr a struttura di tipo HASH da popolare con le info
#
#output:
# 0 -> KO (il ticket non esiste, oppure errore generico)
# 1 -> OK (ticket trovato)
#
sub MS_TicketGetInfo
{
	my $ticket_id_or_tn = shift;
	my $TicketID_is_a_TN = shift; #ad 1 se mi viene passato un TN al posto di un ID
   my $MS_DBObject_ptr = shift;
	my $TicketHash_ptr = shift;
	
	my $rit = 0; 
	
	my $query = 'SELECT id, tn, title, queue_id, ticket_lock_id, ticket_answered, type_id, service_id, sla_id, user_id, responsible_user_id, group_id, ticket_priority_id, ticket_state_id, group_read, group_write, other_read, other_write, customer_id, customer_user_id, timeout, until_time, escalation_time, escalation_update_time, escalation_response_time, escalation_solution_time, freekey1, freetext1, freekey2, freetext2, freekey3, freetext3, freekey4, freetext4, freekey5, freetext5, freekey6, freetext6, freekey7, freetext7, freekey8, freetext8, freekey9, freetext9, freekey10, freetext10, freekey11, freetext11, freekey12, freetext12, freekey13, freetext13, freekey14, freetext14, freekey15, freetext15, freekey16, freetext16, freetime1, freetime2, freetime3, freetime4, freetime5, freetime6, valid_id, create_time_unix, create_time, create_by, change_time, change_by, sr_master_id, sr_assigned_to, vf_acknowledge_date, vf_closing_code, vf_closing_date, vf_error_message, channel, sub_status, product, cq_state, cq_date, msisdn, conto_gioco, codice_fiscale, transaction_id ';
	$query .= ' FROM ticket WHERE ';
	if(defined($TicketID_is_a_TN) and $TicketID_is_a_TN == 1)
	{
		$query .= "tn = $ticket_id_or_tn";
	}
	else
	{
		$query .= "id = $ticket_id_or_tn";
	}
	

	#verifica esistenza ticket
	if(defined($ticket_id_or_tn) and ((!$TicketID_is_a_TN and $ticket_id_or_tn>0) or ($TicketID_is_a_TN and $ticket_id_or_tn !~ m/^\s*$/)) )
	{
		eval 
		{  
			$MS_DBObject_ptr->Prepare(
				  SQL   => $query,
				  Limit => 1
			 );
			 my @Row = $MS_DBObject_ptr->FetchrowArray();
			 
			 if (scalar(@Row))
			 {			
				$TicketHash_ptr->{ID} = $Row[0];
				$TicketHash_ptr->{TN} = $Row[1];
				
				$TicketHash_ptr->{StateID} = $Row[13]; #info duplicata con nome diverso (legacy)
				$TicketHash_ptr->{QueueID} = $Row[3]; #info duplicata con nome diverso (legacy)
				$TicketHash_ptr->{TypeID} = $Row[6]; #info duplicata con nome diverso (legacy)
				
				$TicketHash_ptr->{TITLE} = $Row[2];
				$TicketHash_ptr->{QUEUE_ID} = $Row[3];
				$TicketHash_ptr->{TICKET_LOCK_ID} = $Row[4];
				$TicketHash_ptr->{TICKET_ANSWERED} = $Row[5];
				$TicketHash_ptr->{TYPE_ID} = $Row[6];
				$TicketHash_ptr->{SERVICE_ID} = $Row[7];
				$TicketHash_ptr->{SLA_ID} = $Row[8];
				$TicketHash_ptr->{USER_ID} = $Row[9];
				$TicketHash_ptr->{RESPONSIBLE_USER_ID} = $Row[10];
				$TicketHash_ptr->{GROUP_ID} = $Row[11];
				$TicketHash_ptr->{TICKET_PRIORITY_ID} = $Row[12];
				$TicketHash_ptr->{TICKET_STATE_ID} = $Row[13];
				$TicketHash_ptr->{GROUP_READ} = $Row[14];
				$TicketHash_ptr->{GROUP_WRITE} = $Row[15];
				$TicketHash_ptr->{OTHER_READ} = $Row[16];
				$TicketHash_ptr->{OTHER_WRITE} = $Row[17];
				$TicketHash_ptr->{CUSTOMER_ID} = $Row[18];
				$TicketHash_ptr->{CUSTOMER_USER_ID} = $Row[19];
				$TicketHash_ptr->{TIMEOUT} = $Row[20];
				$TicketHash_ptr->{UNTIL_TIME} = $Row[21];
				$TicketHash_ptr->{ESCALATION_TIME} = $Row[22];
				$TicketHash_ptr->{ESCALATION_UPDATE_TIME} = $Row[23];
				$TicketHash_ptr->{ESCALATION_RESPONSE_TIME} = $Row[24];
				$TicketHash_ptr->{ESCALATION_SOLUTION_TIME} = $Row[25];
				$TicketHash_ptr->{FREEKEY1} = $Row[26];
				$TicketHash_ptr->{FREETEXT1} = $Row[27];
				$TicketHash_ptr->{FREEKEY2} = $Row[28];
				$TicketHash_ptr->{FREETEXT2} = $Row[29];
				$TicketHash_ptr->{FREEKEY3} = $Row[30];
				$TicketHash_ptr->{FREETEXT3} = $Row[31];
				$TicketHash_ptr->{FREEKEY4} = $Row[32];
				$TicketHash_ptr->{FREETEXT4} = $Row[33];
				$TicketHash_ptr->{FREEKEY5} = $Row[34];
				$TicketHash_ptr->{FREETEXT5} = $Row[35];
				$TicketHash_ptr->{FREEKEY6} = $Row[36];
				$TicketHash_ptr->{FREETEXT6} = $Row[37];
				$TicketHash_ptr->{FREEKEY7} = $Row[38];
				$TicketHash_ptr->{FREETEXT7} = $Row[39];
				$TicketHash_ptr->{FREEKEY8} = $Row[40];
				$TicketHash_ptr->{FREETEXT8} = $Row[41];
				$TicketHash_ptr->{FREEKEY9} = $Row[42];
				$TicketHash_ptr->{FREETEXT9} = $Row[43];
				$TicketHash_ptr->{FREEKEY10} = $Row[44];
				$TicketHash_ptr->{FREETEXT10} = $Row[45];
				$TicketHash_ptr->{FREEKEY11} = $Row[46];
				$TicketHash_ptr->{FREETEXT11} = $Row[47];
				$TicketHash_ptr->{FREEKEY12} = $Row[48];
				$TicketHash_ptr->{FREETEXT12} = $Row[49];
				$TicketHash_ptr->{FREEKEY13} = $Row[50];
				$TicketHash_ptr->{FREETEXT13} = $Row[51];
				$TicketHash_ptr->{FREEKEY14} = $Row[52];
				$TicketHash_ptr->{FREETEXT14} = $Row[53];
				$TicketHash_ptr->{FREEKEY15} = $Row[54];
				$TicketHash_ptr->{FREETEXT15} = $Row[55];
				$TicketHash_ptr->{FREEKEY16} = $Row[56];
				$TicketHash_ptr->{FREETEXT16} = $Row[57];
				$TicketHash_ptr->{FREETIME1} = $Row[58];
				$TicketHash_ptr->{FREETIME2} = $Row[59];
				$TicketHash_ptr->{FREETIME3} = $Row[60];
				$TicketHash_ptr->{FREETIME4} = $Row[61];
				$TicketHash_ptr->{FREETIME5} = $Row[62];
				$TicketHash_ptr->{FREETIME6} = $Row[63];
				$TicketHash_ptr->{VALID_ID} = $Row[64];
				$TicketHash_ptr->{CREATE_TIME_UNIX} = $Row[65];
				$TicketHash_ptr->{CREATE_TIME} = $Row[66];
				$TicketHash_ptr->{CREATE_BY} = $Row[67];
				$TicketHash_ptr->{CHANGE_TIME} = $Row[68];
				$TicketHash_ptr->{CHANGE_BY} = $Row[69];
				$TicketHash_ptr->{SR_MASTER_ID} = $Row[70];
				$TicketHash_ptr->{SR_ASSIGNED_TO} = $Row[71];
				$TicketHash_ptr->{VF_ACKNOWLEDGE_DATE} = $Row[72];
				$TicketHash_ptr->{VF_CLOSING_CODE} = $Row[73];
				$TicketHash_ptr->{VF_CLOSING_DATE} = $Row[74];
				$TicketHash_ptr->{VF_ERROR_MESSAGE} = $Row[75];
				$TicketHash_ptr->{CHANNEL} = $Row[76];
				$TicketHash_ptr->{SUB_STATUS} = $Row[77];
				$TicketHash_ptr->{PRODUCT} = $Row[78];
				$TicketHash_ptr->{CQ_STATE} = $Row[79];
				$TicketHash_ptr->{CQ_DATE} = $Row[80];
				$TicketHash_ptr->{MSISDN} = $Row[81];
				$TicketHash_ptr->{CONTO_GIOCO} = $Row[82];
				$TicketHash_ptr->{CODICE_FISCALE} = $Row[83];
				$TicketHash_ptr->{TRANSACTION_ID} = $Row[84];
				
				$rit = 1; #trovato
			 }
		};
		if($@)
		{
			#gestione errore
			$rit = 0;
		}
		

	}
	

	return $rit;
}








##############################################################################
# Ho deciso di prendere sempre tutte le info (vedi sopra "MS_TicketGetInfo") , questo metodo rimane solo per non riscrivere le chiamate ad esso
sub MS_TicketGetInfoShort
{
	my $ticket_id_or_tn = shift;
	my $TicketID_is_a_TN = shift; #ad 1 se mi viene passato un TN al posto di un ID
   my $MS_DBObject_ptr = shift;
	my $TicketHash_ptr = shift; 
	
	return MS_TicketGetInfo($ticket_id_or_tn, $TicketID_is_a_TN, $MS_DBObject_ptr, $TicketHash_ptr);
}














##############################################################################
# Data la struttuta restituita dalla MS_TicketGetInfoShort, la arricchisce con una coppia chiave/valore
# contenente la tipologia di oggetto reletivamente all'ambito Full, cioe': INCIDENT, ALARM
# Nota: la tipologia viene desunta dalla CONFINGURAZIONE
# Nota 2: non fa chiamate al DB
#
#input:
# - ptr a struttura di tipo HASH che contiene le info sul ticket e da popolare con le info aggiuntive
# - ptr all'hash PM_Wind_settings (configurazione)
#
#output:
# 0 -> KO (il ticket non esiste, oppure errore generico)
# 1 -> OK (permessi per Wind popolati)
#
sub MS_TicketGetWindType
{
	my $TicketHash_ptr = shift;
   my $PM_Wind_settingst_ptr = shift;
	
	$TicketHash_ptr->{WindTypeINCIDENT} = 'INCIDENT';
	$TicketHash_ptr->{WindTypeALARM} = 'ALARM';
	$TicketHash_ptr->{WindTypeUNKNOW} = 'unknow';
	
	my $rit = 0; 
	
	if (exists($TicketHash_ptr->{TypeID}) and $TicketHash_ptr->{TypeID} > 0)
	{
		#se il ticket si trova su una coda in cui Wind ha i permessi di scrittura
		if( $TicketHash_ptr->{TypeID} == $PM_Wind_settingst_ptr->{ticketTypeID_IncidentForWind})
		{
			$TicketHash_ptr->{WindType} = $TicketHash_ptr->{WindTypeINCIDENT};
		}
		elsif( ($TicketHash_ptr->{TypeID} == $PM_Wind_settingst_ptr->{ticketTypeID_AlarmForWind})
				or
			 ($TicketHash_ptr->{TypeID} == $PM_Wind_settingst_ptr->{ticketTypeID_AlarmFromWind})
			)
		{
			$TicketHash_ptr->{WindType} = $TicketHash_ptr->{WindTypeALARM};
		}
		else
		{
			$TicketHash_ptr->{WindType} = $TicketHash_ptr->{WindTypeUNKNOW};
		}

		$rit = 1;
	}
	else
	{
		$TicketHash_ptr->{WindType} = $TicketHash_ptr->{WindTypeUNKNOW};
	}
	
	return $rit;
}






##############################################################################
# Data la struttuta restituita dalla MS_TicketGetInfoShort, la arricchisce con un hash delle permission che Wind ha su quel ticket
# Nota: le permission sono calcolate in base alla coda, allo stato e alla CONFINGURAZIONE
# Nota 2: non fa chiamate al DB
#
#input:
# - ptr a struttura di tipo HASH che contiene le info sul ticket e da popolare con le info aggiuntive
# - ptr all'hash PM_Wind_settings (configurazione)
#
#output:
# 0 -> KO (il ticket non esiste, oppure errore generico)
# 1 -> OK (permessi per Wind popolati)
#
sub MS_TicketGetWindPermission
{
	my $TicketHash_ptr = shift;
   my $PM_Wind_settingst_ptr = shift;
	
	my $rit = 0; 
	
	if (exists($TicketHash_ptr->{QueueID}) and $TicketHash_ptr->{QueueID} > 0)
	{
		#se il ticket si trova su una coda in cui Wind ha i permessi di scrittura
		if( ($TicketHash_ptr->{QueueID} == $PM_Wind_settingst_ptr->{queue_id_incident_for_wind})
				or
			 ($TicketHash_ptr->{QueueID} == $PM_Wind_settingst_ptr->{queue_id_alarm_from_wind})
			)
		{
			$TicketHash_ptr->{Permissions}->{Wind_edit} = 1;
			$TicketHash_ptr->{Permissions}->{Wind_read} = 1;
		}
		elsif( $TicketHash_ptr->{QueueID} == $PM_Wind_settingst_ptr->{queue_id_alarm_to_wind} )
		{
			$TicketHash_ptr->{Permissions}->{Wind_edit} = 0;
			$TicketHash_ptr->{Permissions}->{Wind_read} = 1;
		}
		else
		{
			$TicketHash_ptr->{Permissions}->{Wind_edit} = 0;
			$TicketHash_ptr->{Permissions}->{Wind_read} = 0;
		}

		$rit = 1;
	}
	
	

	return $rit;
}













##############################################################################
# Controlla che una determinata category sia presente nella lista di configurazione
# Nota: non fa chiamate al DB
#
#input:
# - category da controllare
# - ptr all'hash  contenente le categoty interessate (configurazione): Category_Incident_PM_Wind, Category_Alarm_PM_Wind, Category_Alarm_Wind_PM 
#
#output:
# 0 -> KO (la categery passata come parametro NON rientra nella lista conosciuta)
# 1 -> OK (la category e' in lista)
#
#sub MS_Check_Category
#{
#	my $category = shift;
#   my $CategoryHash_ptr = shift;
#	
#	my $rit = 0; 
#
#	foreach my $key (keys( %{$CategoryHash_ptr}))
#	{
#		if($category =~ m/^$key$/i )
#		{
#			$rit = 1;
#		}
#	}	
#	
#
#	return $rit;
#}














##############################################################################
# Crea un Alarm da Wind (un Alarm e' un normale ticket, con type specifico)
#
#input:
# - ptr a "%MS_ConfigHash" instanziato in TTActionReceiver_PMWind.pl
#
#output:
# -1 -> KO (errore durante la creazione dell'Alarm)
# -2 -> KO (errore durante l'aggiornamento di qualche freetext/freetime)
# -3 -> KO (errore durante la creazione della nota)
# -4 -> KO (errore durante la creazione di un allegato)
# id alarm creato -> OK (sicuramente > 0)
#
sub MS_CreateAlarm
{
	my $MS_ConfigHash_ptr = shift;
	
	my $rit = -1; 

	#NOTA: ignoro molti dei campi previsti per l'interfaccia di Create -> sono per gli Incident
	#
	#$MS_ConfigHash_ptr->{RequestHash}->{TickedIDWind}
	#$MS_ConfigHash_ptr->{RequestHash}->{Status}    #APERTO
	#$MS_ConfigHash_ptr->{RequestHash}->{priority}
	#$MS_ConfigHash_ptr->{RequestHash}->{CategoryTT}
	#$MS_ConfigHash_ptr->{RequestHash}->{AmbitoTT}
	#$MS_ConfigHash_ptr->{RequestHash}->{TimestampTT}
	#$MS_ConfigHash_ptr->{RequestHash}->{startDateMalfunction}
	#$MS_ConfigHash_ptr->{RequestHash}->{endDateMalfunction}
	#
	# Per le note:
	#$MS_ConfigHash_ptr->{RequestHash}->{Oggetto}
	#$MS_ConfigHash_ptr->{RequestHash}->{Descrizione}


	my $TicketObj_ptr = $MS_ConfigHash_ptr->{OTRS_TicketObject};
	my $DBObj_ptr = $MS_ConfigHash_ptr->{OTRS_DBObject};
	my $RequestHash_ptr = $MS_ConfigHash_ptr->{RequestHash};
	my $PM_Wind_settings_ptr = $MS_ConfigHash_ptr->{PM_Wind_settings};
	
	
	my $alarmID = -1;
	eval 
	{  
		my $alarmID = $TicketObj_ptr->TicketCreate(
			Title        => $RequestHash_ptr->{Oggetto},
			#TN            => $TicketObject->TicketCreateNumber(), # optional
			TN            => 'AW-'.$RequestHash_ptr->{TickedIDWind},
			#Queue        => 'Raw',            
			QueueID => $PM_Wind_settings_ptr->{queue_id_alarm_from_wind},
			Lock         => 'unlock',
			#Priority     => '3 normal',       
			PriorityID => $RequestHash_ptr->{priority},
			#State        => 'open',            
			StateID => $PM_Wind_settings_ptr->{ticketStateID_Open},  #4,  # open
			
			TypeID => $PM_Wind_settings_ptr->{ticketTypeID_AlarmFromWind},  # Tipo "Alarm FROM Wind"
			
			#CustomerID   => $CustomerID,
			CustomerUser => '',
			
			OwnerID      => $PM_Wind_settings_ptr->{system_user_id}, # utenza di sistema OTRS in ambito Full
			UserID       => $PM_Wind_settings_ptr->{system_user_id}, # utenza di sistema OTRS in ambito Full
		);
	};
	if($@)
	{
		#gestione errore
		$rit = -1;
	}

	
	


	if(defined($alarmID) and $alarmID > 0)
	{

		$rit = $alarmID; #imposto valore di ritorno


		eval 
		{  
			# TickedIDWind (freetext9)
			$DBObj_ptr->Do(
						  SQL => "UPDATE ticket SET freekey9 = ?, freetext9 = ? WHERE id = ?",
						  Bind => [ \$PM_Wind_settings_ptr->{ticketFreekey9}, \$RequestHash_ptr->{TickedIDWind}, \$alarmID ],
			);
		
	
			# CategoryTT (freetext15)
			$DBObj_ptr->Do(
						  SQL => "UPDATE ticket SET freekey15 = ?, freetext15 = ? WHERE id = ?",
						  Bind => [ \$PM_Wind_settings_ptr->{ticketFreekey15}, \$RequestHash_ptr->{CategoryTT}, \$alarmID ],
			);
			
	
			# AmbitoTT (freetext10 - concatenato con AMBITO TT | TIPO LINEA | MNP TYPE )
			my $freetext10 = $RequestHash_ptr->{AmbitoTT}.'||'; #senza TIPO LINEA e MNP TYPE 
			$DBObj_ptr->Do(
						  SQL => "UPDATE ticket SET freekey10 = ?, freetext10 = ? WHERE id = ?",
						  Bind => [ \$PM_Wind_settings_ptr->{ticketFreekey10}, \$freetext10, \$alarmID ],
			);
	
			
			
	
			
		
			# TimestampTT (freetime5)
			$DBObj_ptr->Do(
						  SQL => "UPDATE ticket SET freetime5 = ? WHERE id = ?",
						  Bind => [ \$RequestHash_ptr->{TimestampTT}, \$alarmID ],
			);
			
		
			# startDateMalfunction (freetime1)
			$DBObj_ptr->Do(
						  SQL => "UPDATE ticket SET freetime1 = ? WHERE id = ?",
						  Bind => [ \$RequestHash_ptr->{startDateMalfunction}, \$alarmID ],
			);
	
			
			# endDateMalfunction (freetime2)
			$DBObj_ptr->Do(
						  SQL => "UPDATE ticket SET freetime2 = ? WHERE id = ?",
						  Bind => [ \$RequestHash_ptr->{endDateMalfunction}, \$alarmID ],
			);
	
	
	
	
			# SourceChannel
			$DBObj_ptr->Do( SQL => "UPDATE ticket SET channel='WIND' WHERE id=$alarmID" );
			
		
			## TicketCreationDate
			#if(exists($FieldsHash_ptr->{TicketCreationDate}))
			#{
			#	my $TicketCreationDate = $FieldsHash_ptr->{TicketCreationDate};
			#	$DBObject->Do( SQL => "UPDATE ticket SET create_time='$TicketCreationDate' WHERE id=$TicketID" );
			#}
		};
		if($@)
		{
			#gestione errore
			$rit = -2;
		}
	







		# ****** andiamo a creare LA NOTA *******
		my $ArticleHashInfo_ptr = {
				TicketObject => $TicketObj_ptr,
				TicketID => $alarmID,
				ArticleSubject => $MS_ConfigHash_ptr->{RequestHash}->{Oggetto},
				ArticleBody => $MS_ConfigHash_ptr->{RequestHash}->{Descrizione},
				ArticleType => $PM_Wind_settings_ptr->{article_type_FromWind},
				ArticleTypeID => $PM_Wind_settings_ptr->{article_typeID_FromWind},
				SenderType => $PM_Wind_settings_ptr->{article_senderType},
				SenderTypeID => $PM_Wind_settings_ptr->{article_senderTypeID},
				HistoryType => $PM_Wind_settings_ptr->{article_historyType_add},
				HistoryComment => $PM_Wind_settings_ptr->{article_historyComment_addFromWind},
				UserID => $PM_Wind_settings_ptr->{system_user_id},
		};

		my $articleID = MS_AddArticleToTicket($ArticleHashInfo_ptr);
		

		if ($articleID > 0)
		{
			#Aggiungiamo gli allegati alla nota - se presenti
			
			my $filesCount = scalar(@{$MS_ConfigHash_ptr->{RequestHash}->{AttachedFiles}});
			
			for(my $ii=0; $ii<$filesCount; $ii++)
			{
				my $attachResult = MS_AddAttachmentToArticle(
						TicketObject => $TicketObj_ptr,
						ArticleID => $articleID,
						UserID => $PM_Wind_settings_ptr->{system_user_id},
						
						Attachment => $MS_ConfigHash_ptr->{RequestHash}->{AttachedFiles}->[$ii],
						
					);
				
				if ($attachResult < 0)
				{
					#gestione errore creazione allegato (errore in almeno un allegato)
					$rit = -4;
				}
				
			}
		}
		else
		{
			#gestione errore creazione nota
			$rit = -3;
		}
		


	}#fine if

	

	return $rit;
}









##############################################################################
# Crea una nota (Article) senza allegati
#
#input:
# - puntatore ad hash che contiene le seguenti info
#		TicketObject (ptr)
#		TicketID
#		ArticleSubject (oggetto)
#		ArticleBody (corpo)
#			ArticleType
#			ArticleTypeID
#			SenderType
#			SenderTypeID
#			HistoryType
#			HistoryComment
#			UserID
#
#output:
# -1 -> KO (errore durante la creazione dell'Alarm)
# id alarm creato -> OK (sicuramente > 0)
#
#
# interfaccia (infoHash_ptr)
sub MS_AddArticleToTicket
{
	my $MS_ArticleInfo_ptr = shift;
	my $article_ContentType = 'text/plain; charset=utf-8';      # or optional Charset & MimeType	
	
	my $rit = -1;

	my $ArticleID = -1;
	eval 
	{  
		$ArticleID = $MS_ArticleInfo_ptr->{TicketObject}->ArticleCreate(
			TicketID         => $MS_ArticleInfo_ptr->{TicketID},
			ArticleType      => $MS_ArticleInfo_ptr->{ArticleType},                        # email-external|email-internal|phone|fax|...   
			ArticleTypeID      => $MS_ArticleInfo_ptr->{ArticleTypeID}, 
			SenderType       => $MS_ArticleInfo_ptr->{SenderType}, #'system',                                # agent|system|customer
			SenderTypeID      => $MS_ArticleInfo_ptr->{SenderTypeID},
			#From             => 'Some Agent <email@example.com>',       # not required but useful
			#To               => 'Some Customer A <customer-a@example.com>', # not required but useful
			#Cc               => 'Some Customer B <customer-b@example.com>', # not required but useful
			#ReplyTo          => 'Some Customer B <customer-b@example.com>', # not required
			Subject          => $MS_ArticleInfo_ptr->{ArticleSubject},               # required
			Body             => $MS_ArticleInfo_ptr->{ArticleBody},                     # required
			#MessageID        => '<asdasdasd.123@example.com>',          # not required but useful
			#InReplyTo        => '<asdasdasd.12@example.com>',           # not required but useful
			#References       => '<asdasdasd.1@example.com> <asdasdasd.12@example.com>', # not required but useful
			ContentType      => $article_ContentType, #'text/plain; charset=utf-8',      # or optional Charset & MimeType
			HistoryType      => $MS_ArticleInfo_ptr->{HistoryType}, #'AddNote',                          # EmailCustomer|Move|AddNote|PriorityUpdate|WebRequestCustomer|...
			HistoryComment   => $MS_ArticleInfo_ptr->{HistoryComment}, #'Add Note from EAI Adapter',
			UserID           => $MS_ArticleInfo_ptr->{UserID},   # $TicketData_ptr->{UserID},
			NoAgentNotify    => 1,                                      # 1 if you don't want to send agent notifications
			#AutoResponseType => 'auto reply'                            # auto reject|auto follow up|auto follow up|auto remove
	
			#ForceNotificationToUserID   => [ 1, 43, 56 ],               # if you want to force somebody
			#ExcludeNotificationToUserID => [ 43,56 ],                   # if you want full exclude somebody from notfications,
																		# will also be removed in To: line of article,
																		# higher prio as ForceNotificationToUserID
			#ExcludeMuteNotificationToUserID => [ 43,56 ],               # the same as ExcludeNotificationToUserID but only the
																		# sending gets muted, agent will still shown in To:
																		# line of article
		);
	};
	if($@)
	{
		#gestione errore
		$ArticleID = -1;
	}
	

        

		  
		  
	$rit = $ArticleID if($ArticleID > 0);

	

	#if($MS_ArticleCreateDate ne '' and $MS_ArticleCreateDate !~ m/^\s*$/i)
	#{
	#	$DBObject->Do( SQL => "UPDATE article SET create_time='$MS_ArticleCreateDate' WHERE id=$ArticleID" );
	#}
	
	
	
	
# ----- metodo alternativo per creare "article" ----
#    return if !$Self->{DBObject}->Do(
#        SQL => 'INSERT INTO article '
#            . '(ticket_id, article_type_id, article_sender_type_id, a_from, a_reply_to, a_to, '
#            . 'a_cc, a_subject, a_message_id, a_in_reply_to, a_references, a_body, a_content_type, '
#            . 'content_path, valid_id, incoming_time, create_time, create_by, change_time, change_by) '
#            . 'VALUES '
#            . '(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, current_timestamp, ?, current_timestamp, ?)',
#        Bind => [
#            \$Param{TicketID},  \$Param{ArticleTypeID}, \$Param{SenderTypeID},
#            \$Param{From},      \$Param{ReplyTo},       \$Param{To},
#            \$Param{Cc},        \$Param{Subject},       \$Param{MessageID},
#            \$Param{InReplyTo}, \$Param{References},    \$Param{Body},
#            \$Param{ContentType}, \$Self->{ArticleContentPath}, \$ValidID,
#            \$IncomingTime, \$Param{UserID}, \$Param{UserID},
#        ],
#    );
#
#
#    # get article id
#    my $ArticleID = $Self->_ArticleGetId(
#        TicketID     => $Param{TicketID},
#        MessageID    => $Param{MessageID},
#        From         => $Param{From},
#        Subject      => $Param{Subject},
#        IncomingTime => $IncomingTime
#    );
#
#    # return if there is not article created
#    if ( !$ArticleID ) {
#        $Self->{LogObject}->Log(
#            Priority => 'error',
#            Message  => 'Can\'t get ArticleID from INSERT!',
#        );
#        return;
#    }
#	
	
	return $rit;
}







##############################################################################
# Aggiunge un allegato (Attachment) ad una nota (Article)
#
#input:
# - puntatore ad hash che contiene le seguenti info
#		TicketObject (ptr),
#		ArticleID,
#		UserID,
#		Attachment => 	{
#								FullFileName => '',
#								TypeFile => '',
#								dataCreazione => '',
#								FileBody => '',
#							},
#
#output:
# il valore di ritorno della ArticleWriteAttachment (che mi risulta essere 1 se ok)
#
# interfaccia (infoHash_ptr)
sub MS_AddAttachmentToArticle
{
	my $MS_Attachment_info_ptr = shift;

	my $rit = -1;
	
	my $attachResult = -1;
	eval 
	{  
		$attachResult = $MS_Attachment_info_ptr->{TicketObject}->ArticleWriteAttachment(
					Content            => $MS_Attachment_info_ptr->{Attachment}->{FileBody},
					ContentType        => $MS_Attachment_info_ptr->{Attachment}->{TypeFile},
					Filename           => $MS_Attachment_info_ptr->{Attachment}->{FullFileName},
					#ContentID          => 'cid-1234', # optional
					#ContentAlternative => 0,          # optional, alternative content to shown as body
					ArticleID          => $MS_Attachment_info_ptr->{ArticleID},
					UserID             => $MS_Attachment_info_ptr->{UserID},
		);
	};
	if($@)
	{
		#gestione errore
		$attachResult = -1;
	}

	$rit = $attachResult if($attachResult > 0);

	return $rit;
}








##############################################################################
# Richiamata per testare se un certo ALARM possiede almeno una nota per Wind.
# Al momento, nel caso degli ALARM, "valida per Wind" vuol dire semplicmente esistente.
# Se trova piu' di una nota valida per quel ticket considera SOLO la piu' recente
#
# Output:
#   -1  -> l'ALARM non possiede note valide per Wind - oppure - errore generico
#   numero > 0  -> e' l' articleID che indica la nota valida per Wind
#
sub MS_GetValidArticleIdForAlarm
{
	my $alarmID = shift;
   my $MS_DBObject_ptr = shift;

	my $rit = -1;
	
	if (defined($alarmID) and ($alarmID !~ m/^\s*$/) and ($alarmID > 0) and defined($MS_DBObject_ptr) )
	{
		my $query = 'SELECT MAX(id) as id ';
		$query .= ' FROM article ';
		$query .= " WHERE ticket_id=$alarmID ";
		
		eval 
		{  
			$MS_DBObject_ptr->Prepare(
				  SQL   => $query,
				  Limit => 1
			 );
			 my @Row = $MS_DBObject_ptr->FetchrowArray();
			 
			 if (scalar(@Row) and $Row[0] > 0)
			 {			
				$rit = $Row[0];
			 }
		};
		if($@)
		{
			#gestione errore
			$rit = -1;
		}
	}
	
	return $rit;
}





##############################################################################
#Dato un article_id ritorna tutte le info dell'article corrispondente (tranne gli allegati)
#
#input:
# - id di cui estrarre le info
# - ptr a "DBObject" di OTRS
# - ptr a struttura di tipo HASH da popolare con le info
#
#output:
# 0 -> KO (article non esiste, oppure errore generico)
# 1 -> OK (article trovato)
#
sub MS_ArticleGetInfo
{
	my $articleID = shift;
   my $MS_DBObject_ptr = shift;
	my $ArticleHash_ptr = shift;

	my $rit = 0;
	
	if (defined($articleID) and ($articleID !~ m/^\s*$/) and ($articleID > 0) and defined($MS_DBObject_ptr) and defined($ArticleHash_ptr) )
	{
		my $query = 'SELECT id, ticket_id, article_type_id, article_sender_type_id, a_from, a_reply_to, a_to, a_cc, a_subject, a_message_id, a_in_reply_to, a_references, a_content_type, a_body, incoming_time, content_path, a_freekey1, a_freetext1, a_freekey2, a_freetext2, a_freekey3, a_freetext3, valid_id, create_time, create_by, change_time, change_by, note_row_id ';
		$query .= ' FROM article ';
		$query .= " WHERE id=$articleID ";

		eval 
		{  
			$MS_DBObject_ptr->Prepare(
				  SQL   => $query,
				  Limit => 1
			);
			my @Row = $MS_DBObject_ptr->FetchrowArray();
			 
			if (scalar(@Row))
			{			
				$ArticleHash_ptr->{ID} = $Row[0];
				$ArticleHash_ptr->{TICKET_ID} = $Row[1];
				$ArticleHash_ptr->{ARTICLE_TYPE_ID} = $Row[2];
				$ArticleHash_ptr->{ARTICLE_SENDER_TYPE_ID} = $Row[3];
				$ArticleHash_ptr->{A_FROM} = $Row[4];
				$ArticleHash_ptr->{A_REPLY_TO} = $Row[5];
				$ArticleHash_ptr->{A_TO} = $Row[6];
				$ArticleHash_ptr->{A_CC} = $Row[7];
				$ArticleHash_ptr->{A_SUBJECT} = $Row[8];
				$ArticleHash_ptr->{A_MESSAGE_ID} = $Row[9];
				$ArticleHash_ptr->{A_IN_REPLY_TO} = $Row[10];
				$ArticleHash_ptr->{A_REFERENCES} = $Row[11];
				$ArticleHash_ptr->{A_CONTENT_TYPE} = $Row[12];
				$ArticleHash_ptr->{A_BODY} = $Row[13];
				$ArticleHash_ptr->{INCOMING_TIME} = $Row[14];
				$ArticleHash_ptr->{CONTENT_PATH} = $Row[15];
				$ArticleHash_ptr->{A_FREEKEY1} = $Row[16];
				$ArticleHash_ptr->{A_FREETEXT1} = $Row[17];
				$ArticleHash_ptr->{A_FREEKEY2} = $Row[18];
				$ArticleHash_ptr->{A_FREETEXT2} = $Row[19];
				$ArticleHash_ptr->{A_FREEKEY3} = $Row[20];
				$ArticleHash_ptr->{A_FREETEXT3} = $Row[21];
				$ArticleHash_ptr->{VALID_ID} = $Row[22];
				$ArticleHash_ptr->{CREATE_TIME} = $Row[23];
				$ArticleHash_ptr->{CREATE_BY} = $Row[24];
				$ArticleHash_ptr->{CHANGE_TIME} = $Row[25];
				$ArticleHash_ptr->{CHANGE_BY} = $Row[26];
				$ArticleHash_ptr->{NOTE_ROW_ID} = $Row[27];

				$rit = 1; #trovato
			}
		};
		if($@)
		{
			#gestione errore
			$rit = 0;
		}
		

	}
	
	return $rit;
}







##############################################################################
#Dato un article_id ritorna una struttura che contiene gli allegati 
#
#input:
# - id dell'article da cui estrarre gli allegati
# - ptr a "TicketObject" di OTRS
# - ptr a struttura di tipo HASH da popolare con le info
#
#output:
# 0 -> KO (non esistono allegato per questo article, oppure errore generico)
# num > 0 -> OK (numero degli allegati trovati)
#
sub MS_GetArticleAttachments
{
	my $articleID = shift;
   my $MS_TicketObject_ptr = shift;
	my $AttachmentsHashContainer_ptr = shift;

	my $rit = 0;
	
	if (defined($articleID) and ($articleID !~ m/^\s*$/) and ($articleID > 0) and defined($MS_TicketObject_ptr) and defined($AttachmentsHashContainer_ptr) )
	{


		eval 
		{  
			#get article attachment index as hash (ID => hashref (Filename, Filesize, ContentID (if exists), ContentAlternative(if exists) )) 
			my %IndexOfAttachments = $MS_TicketObject_ptr->ArticleAttachmentIndex(
				 ArticleID => $articleID,
				 #UserID    => 123,
			);

			
			## --- Allegati ---
			#AttachedFiles => [
			#							{                           A T T E N Z I O N E
			#								FullFileName => '',   ----> qui ---> Filename
			#								TypeFile => '',       ----> qui ---> ContentType
			#								dataCreazione => '',  ----> qui ---> <mancante>
			#								FileBody => '',       ----> qui ---> Content
			#							},
			#
			#							{
			#								FullFileName => '',
			#								TypeFile => '',
			#								dataCreazione => '',
			#								FileBody => '',
			#							},
			#						],
			#
			
			
			$AttachmentsHashContainer_ptr->{AttachedFiles} = [];
			
			my $count = 0;
			foreach my $key (keys(%IndexOfAttachments))
			{
				#salto l'allegato di default sempre presente
				next if ($key eq '1');
				
				
				#get article attachment (Content, ContentType, Filename and optional ContentID, ContentAlternative) 
				%{$AttachmentsHashContainer_ptr->{AttachedFiles}->[$count]} = $MS_TicketObject_ptr->ArticleAttachment(
					 ArticleID => $articleID,
					 FileID    => $key,
					 #UserID    => 123,
				);
				
				#lo aggiungo ma non dovrebbe servire...
				$AttachmentsHashContainer_ptr->{AttachedFiles}->[$count]->{Filesize} = $IndexOfAttachments{$key}->{Filesize};
				
				$count++;
			}
			
			$rit = $count;
		};
		if($@)
		{
			#gestione errore
			$rit = 0;
		}
		

	}
	
	return $rit;
}





#---------------------------------------------------------------------------------




##############################################################################
# Spacchetta i campi del ticket che sul DB vengono concatenati, mentre ad interfaccia
# sono mostrati singolarmente (spacchettati)
#
#input:
# - HashTicket_ptr  (puntatore all'hash costruito con la "MS_TicketGetInfo" e che rappresenta il ticket)
#       a questo hash verranno aggiunti i campi anche in forma spacchettata: keys con prefisso "WIND_"
# 
#output:
# 0 -> se errore o nell'hash non sono presenti tutte le info che andrebbero spacchettate
# 1 -> se ok
#
#interfaccia:   MS_SplitMergedFields(\%HashTicket)
#
sub MS_SplitMergedFields
{
	my $TicketHash_ptr = shift;
	
	my $normalSeparator = '\|'; #Attenzione all'escape per il pipe
	my $specialSeparator = '_#_'; #TODO........ 19/12/2013

	my $rit = 0;
	
	if(exists($TicketHash_ptr->{FREETEXT2}) and exists($TicketHash_ptr->{FREETEXT3}) and exists($TicketHash_ptr->{FREETEXT10}) and exists($TicketHash_ptr->{FREETEXT11}))
	{
		# FREETEXT2 -> MSISDN | ID LINEA
		# Nota: nella vecchia GUI esisteva solo MSISDN
		my @MS_campi2 ;
		@MS_campi2 = split($normalSeparator, $TicketHash_ptr->{FREETEXT2}) if(defined($TicketHash_ptr->{FREETEXT2}));

		if (scalar(@MS_campi2) == 1) #solo MSISDN
		{
			$TicketHash_ptr->{WIND_FREETEXT2_SPLITTED} = 1; 
			
			$TicketHash_ptr->{WIND_MSISDN} = $MS_campi2[0];
			$TicketHash_ptr->{WIND_ID_LINEA} = '';
		}
		elsif(scalar(@MS_campi2) == 2) # MSISDN e ID LINEA
		{
			$TicketHash_ptr->{WIND_FREETEXT2_SPLITTED} = 1;
			
			$TicketHash_ptr->{WIND_MSISDN} = $MS_campi2[0];
			$TicketHash_ptr->{WIND_ID_LINEA} = $MS_campi2[1];
		}
		else  # 0 valori oppure > 2 campi (errore operatore)
		{
			$TicketHash_ptr->{WIND_FREETEXT2_SPLITTED} = 0; #non c'era niente da dover dividere
			
			$TicketHash_ptr->{WIND_MSISDN} = '';
			$TicketHash_ptr->{WIND_ID_LINEA} = '';
		}		
		 
		
		
		
		
		# FREETEXT3 -> IMSI | ICCID _#_ IMEI
		# Nota: nella vecchia GUI esisteva IMSI | ICCID
		my @MS_campi3;
		@MS_campi3 = split($specialSeparator, $TicketHash_ptr->{FREETEXT3}) if(defined($TicketHash_ptr->{FREETEXT3}));

		if (scalar(@MS_campi3) == 2 or scalar(@MS_campi3) == 1) #IMSI | ICCID _#_ IMEI   oppure  #IMSI | ICCID  ma niente IMEI
		{
			$TicketHash_ptr->{WIND_FREETEXT3_SPLITTED} = 1; 
			$TicketHash_ptr->{WIND_IMEI} = '';
			
			my @MS_campi3_BIS = split($normalSeparator, $MS_campi3[0]);
			
			if (scalar(@MS_campi3_BIS) == 1) #ho solo IMSI 
			{	
				$TicketHash_ptr->{WIND_IMSI} = $MS_campi3_BIS[0];
				$TicketHash_ptr->{WIND_ICCID} = '';
			}			
			elsif (scalar(@MS_campi3_BIS) == 2) #ho IMSI e ICCID
			{	
				$TicketHash_ptr->{WIND_IMSI} = $MS_campi3_BIS[0];
				$TicketHash_ptr->{WIND_ICCID} = $MS_campi3_BIS[1];
			}
			else
			{
				$TicketHash_ptr->{WIND_IMSI} = '';
				$TicketHash_ptr->{WIND_ICCID} = '';				
			}
			

			$TicketHash_ptr->{WIND_IMEI} = $MS_campi3[1] if (scalar(@MS_campi3) == 2);
		}
		else
		{
			$TicketHash_ptr->{WIND_FREETEXT3_SPLITTED} = 0; 
			$TicketHash_ptr->{WIND_IMSI} = '';
			$TicketHash_ptr->{WIND_ICCID} = '';				
			$TicketHash_ptr->{WIND_IMEI} = '';			
		}
		
		
		
		
		
		
		
		# FREETEXT10 -> AMBITO TT | TIPO LINEA _#_ MNP TYPE
		# Nota: nella vecchia gui esisteva il campo VF_servizio | VF_descrizione... quisndi completamente disgiunto dai 3 valori ambito full
		#       Vuol dire che in ambito full trovero' sempre i 3 valori cosi' oppure nulla
		my @MS_campi10;
		@MS_campi10 = split($specialSeparator, $TicketHash_ptr->{FREETEXT10}) if(defined($TicketHash_ptr->{FREETEXT10}));

		if (scalar(@MS_campi10) == 2 ) # AMBITO TT | TIPO LINEA _#_ MNP TYPE 
		{
			$TicketHash_ptr->{WIND_FREETEXT10_SPLITTED} = 1; 
			
			my @MS_campi10_BIS = split($normalSeparator, $MS_campi10[0]);
			
			if (scalar(@MS_campi10_BIS) == 1) #ho solo AMBITO TT 
			{	
				$TicketHash_ptr->{WIND_AMBITOTT} = $MS_campi10_BIS[0];
				$TicketHash_ptr->{WIND_TIPO_LINEA} = '';
			}			
			elsif (scalar(@MS_campi10_BIS) == 2) #ho AMBITO TT e TIPO LINEA
			{	
				$TicketHash_ptr->{WIND_AMBITOTT} = $MS_campi10_BIS[0];
				$TicketHash_ptr->{WIND_TIPO_LINEA} = $MS_campi10_BIS[0];
			}
			else
			{
				$TicketHash_ptr->{WIND_AMBITOTT} = '';
				$TicketHash_ptr->{WIND_TIPO_LINEA} = '';				
			}
			

			$TicketHash_ptr->{WIND_MNP_TYPE} = $MS_campi10[1] ;
		}
		else
		{
			$TicketHash_ptr->{WIND_FREETEXT10_SPLITTED} = 0; 
			$TicketHash_ptr->{WIND_AMBITOTT} = '';
			$TicketHash_ptr->{WIND_TIPO_LINEA} = '';				
			$TicketHash_ptr->{WIND_MNP_TYPE} = '';			
		}		
		
		

		
		
		
		# FREETEXT11 ->  Comune | Provincia | Indirizzo _#_ CAP
		# Nota: nella vecchia GUI esisteva il campo VF_citta' | VF_Provincia | VF_Via
		my @MS_campi11;		
		@MS_campi11 = split($specialSeparator, $TicketHash_ptr->{FREETEXT11}) if(defined($TicketHash_ptr->{FREETEXT11}));

		if (scalar(@MS_campi11) == 2 or scalar(@MS_campi11) == 1) 
		{
			$TicketHash_ptr->{WIND_FREETEXT11_SPLITTED} = 1;
			$TicketHash_ptr->{WIND_CAP} = '';
			
			my @MS_campi11_BIS = split($normalSeparator, $MS_campi11[0]);
			
			if (scalar(@MS_campi11_BIS) == 1)  # Comune 
			{
				$TicketHash_ptr->{WIND_Comune} = $MS_campi11_BIS[0];
				$TicketHash_ptr->{WIND_Provincia} = '';
				$TicketHash_ptr->{WIND_Indirizzo} = '';
			}			
			elsif (scalar(@MS_campi11_BIS) == 2) # Comune | Provincia
			{	
				$TicketHash_ptr->{WIND_Comune} = $MS_campi11_BIS[0];
				$TicketHash_ptr->{WIND_Provincia} = $MS_campi11_BIS[1];
				$TicketHash_ptr->{WIND_Indirizzo} = '';
			}
			elsif (scalar(@MS_campi11_BIS) == 3) # Comune | Provincia | Indirizzo
			{	
				$TicketHash_ptr->{WIND_Comune} = $MS_campi11_BIS[0];
				$TicketHash_ptr->{WIND_Provincia} = $MS_campi11_BIS[1];
				$TicketHash_ptr->{WIND_Indirizzo} = $MS_campi11_BIS[2];
			}
			else
			{
				$TicketHash_ptr->{WIND_Comune} = '';			
				$TicketHash_ptr->{WIND_Provincia} = '';
				$TicketHash_ptr->{WIND_Indirizzo} = '';				
			}
			

			$TicketHash_ptr->{WIND_CAP} = $MS_campi11[1] if(scalar(@MS_campi11) == 2);
		}
		else
		{
			$TicketHash_ptr->{WIND_Comune} = '';			
			$TicketHash_ptr->{WIND_Provincia} = '';
			$TicketHash_ptr->{WIND_Indirizzo} = '';
			$TicketHash_ptr->{WIND_CAP} = '';		
		}		
		
		
		$rit = 1;
	}

	return $rit;
}






















##############################################################################
# Richiamata per testare se un certo ticket di tipo Alert (viene fatto un controllo su questo aspetto) possiede almeno una nota.
# Se trova piu' di una nota valida per quel ticket considera SOLO la piu' recente
#
# Output:
#   -1  -> l'Alert non posside note - oppure - errore generico
#   numero > 0  -> e' l' articleID che indica la nota valida per Wind
#
#
sub MS_CheckIfExistsAlarmArticleForWind
{
	my $TicketID = shift;
   my $MS_DBObject_ptr = shift;
	my $TicketHash_ptr = shift; # opzionale
		
	my $rit = -1;
	
	my $MS_ConfigObject_ptr = $MS_DBObject_ptr->{ConfigObject};
	my $MS_LogObject_ptr = $MS_DBObject_ptr->{LogObject};
	
	$TicketHash_ptr = {} if(!defined($TicketHash_ptr));

	#Controllo la configurazione specifica...
	#if(!exists($TicketHash_ptr->{PM_Wind_settings}->{article_typeID_ToWind}))
	if(!exists($TicketHash_ptr->{PM_Wind_settings}->{ticketTypeID_AlarmToWind}))
	{
		MS_LoadAndCheckConfigForWind($TicketHash_ptr, $MS_ConfigObject_ptr);
	}
	
	#Tipo di nota
	#my $article_typeID_ToWind = $TicketHash_ptr->{PM_Wind_settings}->{article_typeID_ToWind};
	
	#Tipo di ticket (Alarm per Wind)
	my $ticket_typeID_AlarmToWind = $TicketHash_ptr->{PM_Wind_settings}->{ticketTypeID_AlarmToWind};

	
	my $query = 'SELECT id ';
	$query .= ' FROM ticket ';
	$query .= " WHERE ticket_id=$TicketID and type_id=$ticket_typeID_AlarmToWind ";
	
	eval 
	{  
		$MS_DBObject_ptr->Prepare(
			  SQL   => $query,
			  Limit => 1
		 );
		 my @Row = $MS_DBObject_ptr->FetchrowArray();
		 
		 unless(scalar(@Row) and $TicketID == $Row[0])
		 {			
			$MS_LogObject_ptr->Log( Priority => 'warning', Message => "_MSFull_ [WARNING] Il ticket $TicketID non  di tipo ALARM per WIND (type_id = $ticket_typeID_AlarmToWind). Non posso richiedere la nota da mandare a Wind");	
		 }
	};
	if($@)
	{
		#gestione errore
		$rit = -1;
	}
	
	
	$query = 'SELECT MAX(id) as id ';
	$query .= ' FROM article ';
	$query .= " WHERE ticket_id=$TicketID ";
	
	eval 
	{  
		$MS_DBObject_ptr->Prepare(
			  SQL   => $query,
			  Limit => 1
		 );
		 my @Row = $MS_DBObject_ptr->FetchrowArray();
		 
		 if (scalar(@Row))
		 {			
			$rit = $Row[0];
		 }
		 else
		 {
			$MS_LogObject_ptr->Log( Priority => 'warning', Message => "_MSFull_ [WARNING] Per il ticket $TicketID (Alarm per Wind) non trovo una nota valida (oppure errore durante la ricerca della nota stessa)");					
		 }
	};
	if($@)
	{
		#gestione errore
		$rit = -1;
	}
	
	
		
	return $rit;
}











##############################################################################
# Richiamata per testare se un certo ticket possiede almeno una nota per Wind creata
# all'interno dell'intervallo di validita' (vedi configurazioni e docs).
# Se trova piu' di una nota valida per quel ticket considera SOLO la piu' recente
#
# Output:
#   -1  -> il ticket non posside note valide per Wind - oppure - errore generico
#   numero > 0  -> e' l' articleID che indica la nota valida per Wind
#
#interfaccia:   MS_CheckIfExistsFreshArticleForWind
#
sub MS_CheckIfExistsFreshArticleForWind
{
	my $TicketID = shift;
   my $MS_DBObject_ptr = shift;
	my $TicketHash_ptr = shift; # opzionale
		
	my $rit = -1;
	
	my $MS_ConfigObject_ptr = $MS_DBObject_ptr->{ConfigObject};
	my $MS_LogObject_ptr = $MS_DBObject_ptr->{LogObject};	
	
	$TicketHash_ptr = {} if(!defined($TicketHash_ptr));

	#Controllo la configurazione specifica...
	if(!exists($TicketHash_ptr->{PM_Wind_settings}->{article_typeID_ToWind}))
	{
		MS_LoadAndCheckConfigForWind($TicketHash_ptr, $MS_ConfigObject_ptr);
	}
	
	#Tipo di nota
	my $article_typeID_ToWind = $TicketHash_ptr->{PM_Wind_settings}->{article_typeID_ToWind};
	
	#Vincolo temporale (intervallo di validita' della nota per Wind)
	my $article_validityTime_ToWind = $TicketHash_ptr->{PM_Wind_settings}->{article_validityTime_ToWind};
	my $firstValidTime = time() - $article_validityTime_ToWind; #la validita' inizia da questo tempo e finisce all'istante attuale
	
	
	#my $query = 'SELECT id, ticket_id, article_type_id, article_sender_type_id, a_from, a_reply_to, a_to, a_cc, a_subject, a_message_id, a_in_reply_to, a_references, a_content_type, a_body, incoming_time, content_path, a_freekey1, a_freetext1, a_freekey2, a_freetext2, a_freekey3, a_freetext3, valid_id, create_time, create_by, change_time, change_by, note_row_id ';
	my $query = 'SELECT MAX(id) as id ';
	$query .= ' FROM article ';
	$query .= " WHERE ticket_id=$TicketID and article_type_id=$article_typeID_ToWind and incoming_time >= $firstValidTime ";

	eval 
	{  
		$MS_DBObject_ptr->Prepare(
			  SQL   => $query,
			  Limit => 1
		 );
		 my @Row = $MS_DBObject_ptr->FetchrowArray();
		 
		 if (@Row and defined($Row[0]))
		 {
			$rit = $Row[0];
		 }
		 else
		 {
			if (exists($TicketHash_ptr->{PM_Wind_settings}->{log_level}) and $TicketHash_ptr->{PM_Wind_settings}->{log_level} > 1)
			{
				$MS_LogObject_ptr->Log( Priority => 'error', Message => "_MSFull_ [WARNING] Per il ticket $TicketID non esistono note per Wind all'interno dell'intervallo di validita' (now - $article_validityTime_ToWind secs)");	
			}
		 }
	};
	if($@)
	{
		#gestione errore
		$rit = -1;
	}
	
	
	return $rit;
}









##############################################################################
# Richiamata per testare se quando si cerca di aprire un Alarm/Incident/SR verso Wind esso e'
# corredato di tutte le info necessarie.
#
#input:
# - tipo -> ALARM oppure INCIDENT/SR (identifica la tipologia di ticket che si vuole aprire verso Wind) - impostato dalla funzione chiamante
# - id o tn del tichet di cui testare la correttezza
# - flag che mi dice se mi viene passato un id o un tn
# - ptr a "DBObject" di OTRS
# - ptr a struttura di tipo HASH da popolare con le info  (OPZIONALE)
# 
#output:
# 0 -> NON sono presenti tutte le info necessarie
# 1 -> se ok
#
#interfaccia:   _MS_CheckIfOkForCreate(.....)
#
sub _MS_CheckIfOkForCreate
{
	my $TIPO = shift;
	my $ticket_id_or_tn = shift;
	my $TicketID_is_a_TN = shift; #ad 1 se mi viene passato un TN al posto di un ID
   my $MS_DBObject_ptr = shift;
	my $TicketHash_ptr = shift; # opzionale
		
	my $rit = 0;
	
	#debug
	if($MS_DEBUG)
	{
		#use Data::Dumper;
		print "\nMSTicketUtil::_MS_CheckIfOkForCreate \n";
		print "\nTIPO=$TIPO";
		print "\nticket_id_or_tn=$ticket_id_or_tn";
		print "\nTicketID_is_a_TN=$TicketID_is_a_TN";
		#print "\n".Dumper($MS_DBObject_ptr)."\n";
		#print "\n".Dumper($TicketHash_ptr)."\n";
	}
	
	
	if( (!defined($TIPO) or ($TIPO ne 'ALARM' and $TIPO ne 'INCIDENT/SR') ) or !defined($ticket_id_or_tn) or !defined($TicketID_is_a_TN) or !defined($MS_DBObject_ptr) )
	{
		return $rit; 
	}
	
	#debug
	print "\nMSTicketUtil::_MS_CheckIfOkForCreate: i dati in input sembrano OK.\n" if($MS_DEBUG);
	
	my $isAlarm = 0; #a = indica che si tratta di un INCIDENT/SR, ad 1 che si tratta di un ALARM
	$isAlarm = 1 if($TIPO eq 'ALARM');
	
	
	my $MS_ConfigObject_ptr = $MS_DBObject_ptr->{ConfigObject};
	my $MS_LogObject_ptr = $MS_DBObject_ptr->{LogObject};
	
	$TicketHash_ptr = {} if(!defined($TicketHash_ptr));
	my $result = MS_TicketGetInfo($ticket_id_or_tn, $TicketID_is_a_TN, $MS_DBObject_ptr, $TicketHash_ptr);
	
	if ($result) #1 -> OK (ticket trovato)
	{
		$result = MS_SplitMergedFields($TicketHash_ptr);

		#debug
		print "\nMSTicketUtil::_MS_CheckIfOkForCreate: ho trovato i dati del ticket.\n" if($MS_DEBUG);
		
		if ($result)
		{
			#debug
			print "\nMSTicketUtil::_MS_CheckIfOkForCreate: ho fatto lo split dei campi condivisi sul DB.\n" if($MS_DEBUG);
			
			#Controllo la configurazione specifica...
			if(!exists($TicketHash_ptr->{PM_Wind_settings}))
			{
				MS_LoadAndCheckConfigForWind($TicketHash_ptr, $MS_ConfigObject_ptr);
			}
			
			#Controllo eventuali errori e mi comporto di conseguenza
			if ($TicketHash_ptr->{Errors}->{InternalCode} == 0)
			{
				if( ($isAlarm and exists($TicketHash_ptr->{Category_Alarm_PM_Wind}->{$TicketHash_ptr->{FREETEXT15}}))
						or
						(!$isAlarm and exists($TicketHash_ptr->{Category_Incident_PM_Wind}->{$TicketHash_ptr->{FREETEXT15}}))
					)
				{
					if (!$isAlarm or ($isAlarm and $TicketHash_ptr->{TYPE_ID} == $TicketHash_ptr->{PM_Wind_settings}->{ticketTypeID_AlarmToWind}) )
					{
						if ($TicketHash_ptr->{WIND_FREETEXT10_SPLITTED}	and exists($TicketHash_ptr->{AmbitoTT_PM_Wind}->{$TicketHash_ptr->{WIND_AMBITOTT}}))
						{
							if (!$isAlarm)
							{
								#solo per INCIDENT/SR controllo la presenza di una nota valida per Wind
								
								#   -1  -> il ticket non posside note valide per Wind - oppure - errore generico
								#   numero > 0  -> e' l' articleID che indica la nota valida per Wind
								my $checkNotaPerWind = MS_CheckIfExistsFreshArticleForWind($TicketHash_ptr->{ID}, $MS_DBObject_ptr, $TicketHash_ptr);
								$TicketHash_ptr->{WIND_VALID_ARTICLE_ID} = $checkNotaPerWind; #utile per operazioni a monte, nella sub chiamante
								if ($checkNotaPerWind > 0)
								{
									$rit = 1; #per gli ALARM ho finito i controlli (tutto ok)
									#$TicketHash_ptr->{WIND_VALID_ARTICLE_ID} = $checkNotaPerWind;
								}
								
								#in caso di errori il log viene gia' fatto dalla MS_CheckIfExistsFreshArticleForWind..
							}
							else
							{
								my $articleId = MS_GetValidArticleIdForAlarm($TicketHash_ptr->{ID}, $MS_DBObject_ptr);
								$TicketHash_ptr->{WIND_VALID_ARTICLE_ID} = $articleId; #utile per operazioni a monte, nella sub chiamante
								
								$rit = 1; #per gli ALARM ho finito i controlli (tutto ok)
							}
						}
						else
						{
							$MS_LogObject_ptr->Log( Priority => 'error', Message => "_MSFull_ [ERRORE] L' ambito '$TicketHash_ptr->{WIND_AMBITOTT}' non rientra tra quelli previsti in ambito full PM -> Wind (vedi Ticket.xml).");					
						}
					}
					else
					{
						$MS_LogObject_ptr->Log( Priority => 'error', Message => "_MSFull_ [ERRORE] Il type_ID ($TicketHash_ptr->{TYPE_ID}) del ticket non  del tipo Alarm per Wind ($TicketHash_ptr->{PM_Wind_settings}->{ticketTypeID_AlarmToWind}).");					
					}			
				}
				else
				{
					if ($isAlarm)
					{
						$MS_LogObject_ptr->Log( Priority => 'error', Message => "_MSFull_ [ERRORE] La category '$TicketHash_ptr->{FREETEXT15}' non rientra tra quelle previste per gli Alarm PM -> Wind (vedi Ticket.xml).");	
					}
					else
					{
						$MS_LogObject_ptr->Log( Priority => 'error', Message => "_MSFull_ [ERRORE] La category '$TicketHash_ptr->{FREETEXT15}' non rientra tra quelle previste per gli Incident/SR PM -> Wind (vedi Ticket.xml).");	
					}
					
				
				}
			}
			else
			{
				$MS_LogObject_ptr->Log( Priority => 'error', Message => "_MSFull_ [ERRORE] La configurazione per il Full nel Ticket.xml non sembra corretta.");				
			}		
		}
		
	}
	
	

	return $rit;
}








##############################################################################
# Richiamata per testare se quando si cerca di aprire un Alarm verso Wind esso e'
# corredato di tutte le info necessarie.
#
#input:
# - id o tn del tichet di cui testare la correttezza
# - flag che mi dice se mi viene passato un id o un tn
# - ptr a "DBObject" di OTRS
# - ptr a struttura di tipo HASH da popolare con le info  (OPZIONALE)
# 
#output:
# 0 -> NON sono presenti tutte le info necessarie
# 1 -> se ok
#
#interfaccia:   MS_CheckIfAlarmIsOkForCreate(....)
#
sub MS_CheckIfAlarmIsOkForCreate
{
	my $ticket_id_or_tn = shift;
	my $TicketID_is_a_TN = shift; #ad 1 se mi viene passato un TN al posto di un ID
   my $MS_DBObject_ptr = shift;
	my $TicketHash_ptr = shift; # opzionale
	
	return _MS_CheckIfOkForCreate('ALARM', $ticket_id_or_tn, $TicketID_is_a_TN, $MS_DBObject_ptr, $TicketHash_ptr);
}







##############################################################################
# Richiamata per testare se quando si cerca di aprire un Incident verso Wind esso e'
# corredato di tutte le info necessarie.
#
#input:
# - id o tn del tichet di cui testare la correttezza
# - flag che mi dice se mi viene passato un id o un tn
# - ptr a "DBObject" di OTRS
# - ptr a struttura di tipo HASH da popolare con le info  (OPZIONALE)
# 
#output:
# 0 -> NON sono presenti tutte le info necessarie
# 1 -> se ok
#
#interfaccia:   MS_CheckIfIncidentOrSrIsOkForCreate(...)
#
sub MS_CheckIfIncidentOrSrIsOkForCreate
{
	my $ticket_id_or_tn = shift;
	my $TicketID_is_a_TN = shift; #ad 1 se mi viene passato un TN al posto di un ID
   my $MS_DBObject_ptr = shift;
	my $TicketHash_ptr = shift; # opzionale
	
	return _MS_CheckIfOkForCreate('INCIDENT/SR', $ticket_id_or_tn, $TicketID_is_a_TN, $MS_DBObject_ptr, $TicketHash_ptr);
}















sub MS_OtrsTicketStateIDToWindStatus
{
	my $PM_Wind_settings_ptr = shift;
	my $otrs_status = shift;
	my $causale_ptr = shift; #se serve viene modificata la var puntata
	
	my $rit = undef;
	
	if ($otrs_status and exists($PM_Wind_settings_ptr->{ticketStateID_InProgress})) #ne controllo uno solo per l'esistenza
	{
		if ($otrs_status == $PM_Wind_settings_ptr->{ticketStateID_Open})
		{
			$rit = 'APERTO';
		}
		elsif ($otrs_status == $PM_Wind_settings_ptr->{ticketStateID_Risolto} and defined($causale_ptr) )
		{
			$rit = 'RESTITUITO';
			$$causale_ptr = 'RISOLTO';
		}
		elsif ($otrs_status == $PM_Wind_settings_ptr->{ticketStateID_InProgress})
		{
			$rit = 'IN LAVORAZIONE';
		}
		
		#per gli alarm dovrebbero bastare i 3 stati sopra, mentre per INCIDENT dovrebbe bastare lo stato 'APERTO'
		# NOTA 2: attenzione, la mappatura e' quindi incompleta!!!
	}



	return $rit;
}





sub MS_WindStatusToOtrsTicketStateID
{
	my $PM_Wind_settings_ptr = shift;
	my $wind_status = shift;
	my $causale = shift; #serve solo per lo stato "RESTITUITO"
	
	
	my $rit = undef;
	
	if ($wind_status and exists($PM_Wind_settings_ptr->{ticketStateID_Sospeso})) #ne controllo uno solo per l'esistenza
	{
		if ($wind_status =~ m/^\s*APERTO\s*$/i)
		{
			$rit = $PM_Wind_settings_ptr->{ticketStateID_Open};
		}
		elsif ($wind_status =~ m/^\s*IN\s+LAVORAZIONE\s*$/i)
		{
			$rit = $PM_Wind_settings_ptr->{ticketStateID_InProgress};
		}
		elsif ($wind_status =~ m/^\s*SOSPESO\s*$/i)
		{
			$rit = $PM_Wind_settings_ptr->{ticketStateID_Sospeso};
		}
		elsif ($wind_status =~ m/^\s*RESTITUITO\s*$/i and $causale) #se la CAUSALE non e' definita non posso fare il mapping
		{
			if ($causale =~ m/^\s*IN\s*ATTESA\s*INFORMAZIONI\s*$/i)
			{
				$rit = $PM_Wind_settings_ptr->{ticketStateID_InAttesaInfo};
			}
			elsif ($causale =~ m/^\s*NON\s*DI\s*COMPETENZA\s*$/i)
			{
				$rit = $PM_Wind_settings_ptr->{ticketStateID_NonDiCompetenza};
			}
			elsif ($causale =~ m/^\s*RISOLTO\s*$/i)
			{
				$rit = $PM_Wind_settings_ptr->{ticketStateID_Risolto};
			}
			elsif ($causale =~ m/^\s*NON\s*RISCONTRATO\s*$/i)
			{
				$rit = $PM_Wind_settings_ptr->{ticketStateID_RisoltoNRI};
			}
			elsif ($causale =~ m/^\s*RISOLTO\s*NO\s*ACTION\s*$/i)
			{
				$rit = $PM_Wind_settings_ptr->{ticketStateID_RisoltoNoACT};
			}
		}
		# -- EXPIRED non lo gestisco....
		#elsif ($wind_status =~ m/^\s*EXPIRED\s*$/i)
		#{
		#	$rit = -1;
		#}
		
	}
	
	return $rit;
}






1;

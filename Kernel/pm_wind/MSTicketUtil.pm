package MSTicketUtil;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

# Exporting the saluta routine
our @EXPORT = qw(MS_TicketGetInfoShort MS_TicketGetWindType MS_TicketGetWindPermission MS_Check_Category MS_CreateAlarm MS_AddArticleToTicket MS_AddAttachmentToArticle);
# Exporting the saluta2 routine on demand basis.
#our @EXPORT_OK = qw(saluta2);




# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/../cpan-lib";




# ----------------- Moduli custom necessari ------------------
#use MSErrorUtil;






##############################################################################
#Dato un ticket_id ritorna il queue_id e lo ticket_state_id del ticket corrispondente
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
sub MS_TicketGetInfoShort
{
	my $ticket_id_or_tn = shift;
	my $TicketID_is_a_TN = shift; #ad 1 se mi viene passato un TN al posto di un ID
   my $MS_DBObject_ptr = shift;
	my $TicketHash_ptr = shift;
	
	my $rit = 0; 
	
	my $query = 'SELECT id, tn, ticket_state_id, queue_id, type_id FROM ticket WHERE ';
	if($TicketID_is_a_TN)
	{
		$query .= "tn = $ticket_id_or_tn";
	}
	else
	{
		$query .= "id = $ticket_id_or_tn";
	}
	

	#verifica esistenza ticket
	if($ticket_id_or_tn)
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
				$TicketHash_ptr->{StateID} = $Row[2];
				$TicketHash_ptr->{QueueID} = $Row[3];
				$TicketHash_ptr->{TypeID} = $Row[4];
				
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
sub MS_Check_Category
{
	my $category = shift;
   my $CategoryHash_ptr = shift;
	
	my $rit = 0; 

	foreach my $key (keys( %{$CategoryHash_ptr}))
	{
		if($category =~ m/^$key$/i )
		{
			$rit = 1;
		}
	}	
	

	return $rit;
}








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








1;

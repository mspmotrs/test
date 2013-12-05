# OTRS config file (automaticaly generated!)
# VERSION:1.1
package Kernel::Config::Files::ZZZAAuto;
use utf8;
sub Load {
    my ($File, $Self) = @_;
$Self->{'TicketFreeTimeEvent'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '1',
  '5' => '0',
  '6' => '0'
};
$Self->{'MasterTicketFreeTimeField'} =  '6';
$Self->{'TicketFreeText12::DefaultSelection'} =  'Master';
$Self->{'TicketFreeText12'} =  {
  'Master' => 'Master',
  'Slave' => 'Slave'
};
$Self->{'TicketFreeTextEvent'} =  {
  '1' => '0',
  '10' => '0',
  '11' => '0',
  '12' => '0',
  '13' => '0',
  '14' => '0',
  '15' => '0',
  '16' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0',
  '7' => '1',
  '8' => '0',
  '9' => '0'
};
$Self->{'Ticket::EventModulePost'}->{'MasterSlave'} =  {
  'Event' => '(ArticleCreate|ArticleSend|TicketStateUpdate|TicketPriorityUpdate|TicketPendingTimeUpdate|TicketLockUpdate|TicketOwnerUpdate|TicketResponsibleUpdate|TicketFreeTextUpdate|TicketFreeTimeUpdate|TicketQueueUpdate)',
  'Module' => 'Kernel::System::Ticket::Event::MasterSlave'
};
$Self->{'TicketFreeKey12'} =  {
  'MasterTicket' => 'MasterTicket'
};
$Self->{'PreApplicationModule'}->{'AgentMasterSlaveTicketPrepare'} =  'Kernel::Modules::AgentMasterSlavePrepareTicket';
$Self->{'MasterTicketFreeTextField'} =  '12';
$Self->{'PM_Wind_settings'} =  {
  'prova1' => 'si tratta di una prova'
};
$Self->{'NotPossibleForCorner'} =  {
  'NoTypeAgent' => 'Alarm per PI;Bonifica;Case;Case collaudo;Creazione utenze;Evoluzioni/Change request;Fault;Gestione SCRATCH;Incident per PI;Migrazione SIM vs altra società gruppo;Monitoring;PR Master;Report;Richiesta Portabilità del numero'
};
$Self->{'NotPossibleTypeCorner'} =  {
  'NoTypeAgent' => 'Corner'
};
$Self->{'Ticket::Acl::Module'}->{'9-Ticket::Acl::Module'} =  {
  'Module' => 'Kernel::System::Ticket::Acl::NotShowPendingCorner'
};
$Self->{'TypeToAdapter'} =  {
  '43' => 'TTSynchronizeUpdate',
  '46' => 'TTSynchronizeUpdate',
  '47' => 'TTSynchronizeUpdate'
};
$Self->{'NotPossibleTypeAgent'} =  {
  'NoTypeAgent' => 'Alarm da PI;Incident da PI;SR da PI;SR-Alarm/Reclamo;SR-Escalation;SR-Sollecito'
};
$Self->{'Ticket::Type::TicketTypeGroup'} =  {
  'Clienti' => [
    'Altro',
    'Attivazione SIM',
    'Disattivazione SIM',
    'Migrazione SIM vs Consumer',
    'Migrazione SIM vs altra società gruppo',
    'Riattivazione SIM',
    'Sospensione SIM',
    'Sostituzione SIM guasta',
    'Ampliamento Contratto',
    'Assistenza Altro',
    'Assistenza Invio/Ricezione Chiamate Aziendali',
    'Assistenza Invio/Ricezione Chiamate Personali',
    'Assistenza Invio/Ricezione Chiamate e Dati',
    'Attivazione Borsellino Personale',
    'Attivazione opzioni tariffarie (voce/dati)',
    'Cambio profilo RPV temporaneo',
    'Cambio profilo RPV',
    'Disattivazione Borsellino Personale',
    'Disattivazione opzioni  (voce/dati)',
    'Downgrade Terminali',
    'Errata Tariffazione chiamate Aziendali',
    'Errata Tariffazione chiamate Personali',
    'Errata tariffazione (voce/dati)',
    'Modifica liste RPV',
    'Reintegro scorta terminali',
    'Reintegro scorta',
    'Richiesta Portabilità del numero',
    'Richieste Altro',
    'Sostituzione furto/smarrimento',
    'Sostituzione terminale guasto',
    'Upgrade Terminali'
  ],
  'PM-PI' => [
    'Alarm da PI',
    'Alarm per PI',
    'Incident da PI',
    'Incident per PI',
    'SR da PI'
  ],
  'Service Request' => [
    'SR-Alarm/Reclamo',
    'SR-Escalation',
    'SR-Sollecito'
  ]
};
$Self->{'Ticket::Acl::CustomerMoveDestinationQueue'} =  {
  '100055853000' => {
    '54' => 'CC-PI-AssistenzaTecnica',
    '55' => 'CC-PI-Gestionali'
  },
  '100060452100' => {
    '51' => 'CC-PT'
  }
};
$Self->{'Ticket::Acl::PossibleQueueBySourceQueueAndType'} =  {
  'PosteItaliane' => {
    'Ampliamento Contratto' => 'CC-PI-Gestionali',
    'Assistenza Altro' => 'CC-PI-AssistenzaTecnica',
    'Assistenza Invio/Ricezione Chiamate Aziendali' => 'CC-PI-AssistenzaTecnica',
    'Assistenza Invio/Ricezione Chiamate Personali' => 'CC-PI-AssistenzaTecnica',
    'Attivazione Borsellino Personale' => '>CC-PI-Gestionali',
    'Attivazione opzioni tariffarie (voce/dati)' => 'CC-PI-Gestionali',
    'Cambio profilo RPV' => 'CC-PI-Gestionali',
    'Cambio profilo RPV temporaneo' => 'CC-PI-Gestionali',
    'Disattivazione Borsellino Personale' => '>CC-PI-Gestionali',
    'Disattivazione SIM' => 'CC-PI-Gestionali',
    'Disattivazione opzioni  (voce/dati)' => 'CC-PI-Gestionali',
    'Downgrade Terminali' => 'CC-PI-Gestionali',
    'Errata Tariffazione chiamate Aziendali' => 'CC-PI-AssistenzaTecnica',
    'Errata Tariffazione chiamate Personali' => 'CC-PI-AssistenzaTecnica',
    'Migrazione SIM vs Consumer' => 'CC-PI-Gestionali',
    'Migrazione SIM vs altra società gruppo' => 'CC-PI-Gestionali',
    'Modifica liste RPV' => 'CC-PI-Gestionali',
    'Reintegro scorta' => 'CC-PI-Gestionali',
    'Riattivazione SIM' => 'CC-PI-Gestionali',
    'Richiesta Portabilità del numero' => 'CC-PI-Gestionali',
    'Richieste Altro' => 'CC-PI-Gestionali',
    'Sospensione SIM' => 'CC-PI-Gestionali',
    'Sostituzione SIM guasta' => 'CC-PI-Gestionali',
    'Sostituzione furto/smarrimento' => 'CC-PI-Gestionali',
    'Sostituzione terminale guasto' => 'CC-PI-Gestionali',
    'Upgrade Terminali' => 'CC-PI-Gestionali'
  },
  'PostinoTelematico' => {
    'Altro' => 'CC-PT',
    'Ampliamento Contratto' => 'CC-PT',
    'Assistenza Invio/Ricezione Chiamate e Dati' => 'CC-PT',
    'Attivazione SIM' => 'CC-PT',
    'Disattivazione SIM' => 'CC-PT',
    'Errata tariffazione (voce/dati)' => 'CC-PT',
    'Reintegro scorta terminali' => 'CC-PT',
    'Riattivazione SIM' => 'CC-PT',
    'Sospensione SIM' => 'CC-PT',
    'Sostituzione SIM guasta' => 'CC-PT',
    'Sostituzione furto/smarrimento' => 'CC-PT',
    'Sostituzione terminale guasto' => 'CC-PT'
  }
};
$Self->{'Ticket::Acl::PossibleTypeByCustomerCompany'} =  {
  '100055853000' => [
    'Ampliamento Contratto',
    'Sostituzione terminale guasto',
    'Sostituzione SIM guasta',
    'Sostituzione furto/smarrimento',
    'Cambio profilo RPV',
    'Cambio profilo RPV temporaneo',
    'Migrazione SIM vs Consumer',
    'Modifica liste RPV',
    'Sospensione SIM',
    'Riattivazione SIM',
    'Disattivazione SIM',
    'Upgrade Terminali',
    'Downgrade Terminali',
    'Attivazione opzioni tariffarie (voce/dati)',
    'Disattivazione opzioni  (voce/dati)',
    'Reintegro scorta',
    'Richieste Altro',
    'Errata Tariffazione chiamate Aziendali',
    'Errata Tariffazione chiamate Personali',
    'Assistenza Invio/Ricezione Chiamate Aziendali',
    'Assistenza Invio/Ricezione Chiamate Personali',
    'Assistenza Altro',
    'Attivazione Borsellino Personale',
    'Disattivazione Borsellino Personale',
    'Migrazione SIM vs altra società gruppo',
    'Richiesta Portabilità del numero',
    'SMS Bulk'
  ],
  '100060452100' => [
    'Attivazione SIM',
    'Ampliamento Contratto',
    'Sostituzione terminale guasto',
    'Sostituzione SIM guasta',
    'Sostituzione furto/smarrimento',
    'Sospensione SIM',
    'Riattivazione SIM',
    'Disattivazione SIM',
    'Reintegro scorta terminali',
    'Altro',
    'Errata tariffazione (voce/dati)',
    'Assistenza Invio/Ricezione Chiamate e Dati'
  ]
};
$Self->{'cateneFamily'} =  {
  'FRODI' => 'MVNE-BE-BSS-Frodi;PM-Frodi',
  'INTRALOT' => 'Intralot-FE-SIEBEL;Intralot-FE-GUI;Siebel-IN-Intralot;GameAccount-BE;PM-Technology-Intralot;Lottomatica-BE;CasinoGames-BE',
  'MVNE' => 'MVNE-BE-BSS-Billing;MVNE-BE-BSS-DWH;MVNE-BE-BSS-EAI;MVNE-BE-BSS-FMS;MVNE-BE-BSS-Portali;MVNE-BE-BSS-RAS;MVNE-BE-BSS-SIEBEL;MVNE-BE-Network;MVNE-BE-OTRS;DS-BE-PostinoTelematico;MVNE-BE-REPLY-CMT;MVNE-BE-REPLY-PW;MVNE-BE-SAPRMCA;MVNE-BE-Search Console;MVNE-BE-Security;MVNE-BE-VAS;MVNE-DEV-BSS;MVNE-DEV-Network;MVNE-DEV-OTRS;MVNE-DEV-RAS-FMS;MVNE-DEV-SAPRMCA;MVNE-DEV-Security;MVNE-DEV-VAS;MVNE-FE-GUI;MVNE-FE-SIEBEL;MVNE-FE-SIEBEL-Business;MVNE-FE-SIEBEL-Consumer;MVNE-FE-SIEBEL-FromBE;PM-COPS;PM-RAFM;PM-Technology;PosteItaliane-OUT;REPLY-DEV-CMT;REPLY-DEV-PW;Siebel-IN;Vodafone-OUT;MVNE-BE-BSS-DMining;DEV-DataMining;Atlantic-BackEnd-CCOD;Atlantic-DEV-CCOD;PM-MKT;MVNE-FE-PI;MVNE-FE-PI-Alarm;PosteItaliane-OUT-Alarm;MVNE-BE-MERCHANT;HART-BE',
  'PUREBROS' => 'PB-FE-SIEBEL;SIEBEL-IN-PB'
};
$Self->{'Ticket::Acl::Module'}->{'7-Ticket::Acl::Module'} =  {
  'Module' => 'Kernel::System::Ticket::Acl::NotShowPending'
};
$Self->{'stateToAction'} =  {
  '6' => 'NeedInfo',
  '7' => 'Resolved',
  '8' => 'Rejected'
};
$Self->{'workingQueue'} =  {
  'Atlantic-BackEnd-CCOD' => 'Atlantic',
  'Atlantic-DEV-CCOD' => 'Atlantic-Sviluppo',
  'CasinoGames-BE' => 'CasinoGames',
  'DEV-DataMining' => 'Everis - Sviluppo - DM',
  'DS-BE-PostinoTelematico' => 'DS-BackEnd',
  'Everis-DEV-KM' => 'Everis-Sviluppo-KM',
  'GameAccount-BE' => 'GameAccount',
  'HART-BE' => 'HART',
  'Intralot-FE-SIEBEL' => 'Intralot',
  'Lottomatica-BE' => 'Lottomatica',
  'MVNE-BE-BSS-Billing' => 'MVNE',
  'MVNE-BE-BSS-DMining' => 'MVNE - Sviluppo',
  'MVNE-BE-BSS-DWH' => 'MVNE',
  'MVNE-BE-BSS-EAI' => 'MVNE',
  'MVNE-BE-BSS-FMS' => 'MVNE',
  'MVNE-BE-BSS-Frodi' => 'MVNE',
  'MVNE-BE-BSS-Portali' => 'MVNE',
  'MVNE-BE-BSS-RAS' => 'MVNE',
  'MVNE-BE-BSS-SIEBEL' => 'MVNE',
  'MVNE-BE-EVERIS-KM' => 'MVNE',
  'MVNE-BE-MERCHANT' => 'MVNE',
  'MVNE-BE-Network' => 'MVNE',
  'MVNE-BE-OTRS' => 'MVNE',
  'MVNE-BE-REPLY-CMT' => 'MVNE',
  'MVNE-BE-REPLY-PW' => 'MVNE',
  'MVNE-BE-SAPRMCA' => 'MVNE',
  'MVNE-BE-Search Console' => 'MVNE',
  'MVNE-BE-Security' => 'MVNE',
  'MVNE-BE-VAS' => 'MVNE',
  'MVNE-DEV-BSS' => 'MVNE - Sviluppo',
  'MVNE-DEV-Network' => 'MVNE - Sviluppo',
  'MVNE-DEV-OTRS' => 'MVNE - Sviluppo',
  'MVNE-DEV-RAS-FMS' => 'MVNE - Sviluppo',
  'MVNE-DEV-SAPRMCA' => 'MVNE - Sviluppo',
  'MVNE-DEV-Security' => 'MVNE - Sviluppo',
  'MVNE-DEV-VAS' => 'MVNE - Sviluppo',
  'MVNE-FE-PI' => 'MVNE',
  'MVNE-FE-PI-Alarm' => 'MVNE',
  'MVNE-FE-SIEBEL' => 'MVNE',
  'MVNE-FE-SIEBEL-Business' => 'MVNE',
  'MVNE-FE-SIEBEL-Consumer' => 'MVNE',
  'MVNE-FE-SIEBEL-FromBE' => 'MVNE',
  'PB-FE-SIEBEL' => 'Pure Bros - Front End',
  'PosteItaliane-OUT' => 'PosteItaliane',
  'PosteItaliane-OUT-Alarm' => 'PosteItaliane',
  'REPLY-DEV-CMT' => 'REPLY - Sviluppo - CMT',
  'REPLY-DEV-PW' => 'REPLY - Sviluppo - PW',
  'Vodafone-OUT' => 'Vodafone'
};
$Self->{'Ticket::Acl::Module'}->{'8-Ticket::Acl::Module'} =  {
  'Module' => 'Kernel::System::Ticket::Acl::CustomerTicketACL'
};
$Self->{'Ticket::Acl::Module'}->{'6-Ticket::Acl::Module'} =  {
  'Module' => 'Kernel::System::Ticket::Acl::FlowStates'
};
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'Subject'} =  '';
$Self->{'TicketFreeTimeOptional4'} =  '1';
$Self->{'TicketFreeTimeKey4'} =  'Data Prevista Risoluzione';
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'TicketFreeTime'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '1',
  '5' => '0',
  '6' => '0'
};
$Self->{'TicketFreeText8'} =  {
  '' => '-',
  '2010 X11' => '2010 X11',
  '2010 X7' => '2010 X7',
  '2010 X9' => '2010 X9',
  '2011 X2' => '2011 X2'
};
$Self->{'Stats::DynamicObjectRegistration'}->{'TicketSolutionResponseTime'} =  {
  'Module' => 'Kernel::System::Stats::Dynamic::TicketSolutionResponseTime'
};
$Self->{'Stats::DynamicObjectRegistration'}->{'TicketAccountedTime'} =  {
  'Module' => 'Kernel::System::Stats::Dynamic::TicketAccountedTime'
};
$Self->{'Stats::DynamicObjectRegistration'}->{'TicketList'} =  {
  'Module' => 'Kernel::System::Stats::Dynamic::TicketList'
};
$Self->{'Stats::DynamicObjectRegistration'}->{'Ticket'} =  {
  'Module' => 'Kernel::System::Stats::Dynamic::Ticket'
};
$Self->{'LinkObject::PossibleLink'}->{'0201'} =  {
  'Object1' => 'Ticket',
  'Object2' => 'Ticket',
  'Type' => 'ParentChild'
};
$Self->{'LinkObject::PossibleLink'}->{'0200'} =  {
  'Object1' => 'Ticket',
  'Object2' => 'Ticket',
  'Type' => 'Normal'
};
$Self->{'SendNoAutoResponseRegExp'} =  '(MAILER-DAEMON|postmaster|abuse)@.+?\\..+?';
$Self->{'PostMaster::PostFilterModule'}->{'000-FollowUpArticleTypeCheck'} =  {
  'Module' => 'Kernel::System::PostMaster::Filter::FollowUpArticleTypeCheck'
};
$Self->{'PostMaster::PreFilterModule'}->{'000-MatchDBSource'} =  {
  'Module' => 'Kernel::System::PostMaster::Filter::MatchDBSource'
};
$Self->{'PostMaster::PreFilterModule::NewTicketReject::Body'} =  '
Dear Customer,

unfortunately you have no valid ticket number
in your subject, so this email can\'t processed.

Please create a new ticket via the customer panel.

Thanks for your help!

 Your Helpdesk Team
';
$Self->{'PostMaster::PreFilterModule::NewTicketReject::Subject'} =  'Email Rejected';
$Self->{'PostmasterX-Header'} =  [
  'From',
  'To',
  'Cc',
  'Reply-To',
  'ReplyTo',
  'Subject',
  'Message-ID',
  'Message-Id',
  'Resent-To',
  'Resent-From',
  'Precedence',
  'Mailing-List',
  'List-Id',
  'List-Archive',
  'Errors-To',
  'References',
  'In-Reply-To',
  'X-Loop',
  'X-Spam-Flag',
  'X-Spam-Status',
  'X-Spam-Level',
  'X-No-Loop',
  'X-Priority',
  'Importance',
  'X-Mailer',
  'User-Agent',
  'Organization',
  'X-Original-To',
  'Delivered-To',
  'Return-Path',
  'X-OTRS-Loop',
  'X-OTRS-Info',
  'X-OTRS-Priority',
  'X-OTRS-Queue',
  'X-OTRS-Lock',
  'X-OTRS-Ignore',
  'X-OTRS-State',
  'X-OTRS-State-PendingTime',
  'X-OTRS-Type',
  'X-OTRS-Service',
  'X-OTRS-SLA',
  'X-OTRS-CustomerNo',
  'X-OTRS-CustomerUser',
  'X-OTRS-ArticleKey1',
  'X-OTRS-ArticleKey2',
  'X-OTRS-ArticleKey3',
  'X-OTRS-ArticleValue1',
  'X-OTRS-ArticleValue2',
  'X-OTRS-ArticleValue3',
  'X-OTRS-SenderType',
  'X-OTRS-ArticleType',
  'X-OTRS-TicketKey1',
  'X-OTRS-TicketKey2',
  'X-OTRS-TicketKey3',
  'X-OTRS-TicketKey4',
  'X-OTRS-TicketKey5',
  'X-OTRS-TicketKey6',
  'X-OTRS-TicketKey7',
  'X-OTRS-TicketKey8',
  'X-OTRS-TicketKey9',
  'X-OTRS-TicketKey10',
  'X-OTRS-TicketKey11',
  'X-OTRS-TicketKey12',
  'X-OTRS-TicketKey13',
  'X-OTRS-TicketKey14',
  'X-OTRS-TicketKey15',
  'X-OTRS-TicketKey16',
  'X-OTRS-TicketValue1',
  'X-OTRS-TicketValue2',
  'X-OTRS-TicketValue3',
  'X-OTRS-TicketValue4',
  'X-OTRS-TicketValue5',
  'X-OTRS-TicketValue6',
  'X-OTRS-TicketValue7',
  'X-OTRS-TicketValue8',
  'X-OTRS-TicketValue9',
  'X-OTRS-TicketValue10',
  'X-OTRS-TicketValue11',
  'X-OTRS-TicketValue12',
  'X-OTRS-TicketValue13',
  'X-OTRS-TicketValue14',
  'X-OTRS-TicketValue15',
  'X-OTRS-TicketValue16',
  'X-OTRS-TicketTime1',
  'X-OTRS-TicketTime2',
  'X-OTRS-TicketTime3',
  'X-OTRS-TicketTime4',
  'X-OTRS-TicketTime5',
  'X-OTRS-TicketTime6',
  'X-OTRS-FollowUp-Priority',
  'X-OTRS-FollowUp-Queue',
  'X-OTRS-FollowUp-Lock',
  'X-OTRS-FollowUp-State',
  'X-OTRS-FollowUp-State-PendingTime',
  'X-OTRS-FollowUp-Type',
  'X-OTRS-FollowUp-Service',
  'X-OTRS-FollowUp-SLA',
  'X-OTRS-FollowUp-ArticleKey1',
  'X-OTRS-FollowUp-ArticleKey2',
  'X-OTRS-FollowUp-ArticleKey3',
  'X-OTRS-FollowUp-ArticleValue1',
  'X-OTRS-FollowUp-ArticleValue2',
  'X-OTRS-FollowUp-ArticleValue3',
  'X-OTRS-FollowUp-SenderType',
  'X-OTRS-FollowUp-ArticleType',
  'X-OTRS-FollowUp-TicketKey1',
  'X-OTRS-FollowUp-TicketKey2',
  'X-OTRS-FollowUp-TicketKey3',
  'X-OTRS-FollowUp-TicketKey4',
  'X-OTRS-FollowUp-TicketKey5',
  'X-OTRS-FollowUp-TicketKey6',
  'X-OTRS-FollowUp-TicketKey7',
  'X-OTRS-FollowUp-TicketKey8',
  'X-OTRS-FollowUp-TicketKey9',
  'X-OTRS-FollowUp-TicketKey10',
  'X-OTRS-FollowUp-TicketKey11',
  'X-OTRS-FollowUp-TicketKey12',
  'X-OTRS-FollowUp-TicketKey13',
  'X-OTRS-FollowUp-TicketKey14',
  'X-OTRS-FollowUp-TicketKey15',
  'X-OTRS-FollowUp-TicketKey16',
  'X-OTRS-FollowUp-TicketValue1',
  'X-OTRS-FollowUp-TicketValue2',
  'X-OTRS-FollowUp-TicketValue3',
  'X-OTRS-FollowUp-TicketValue4',
  'X-OTRS-FollowUp-TicketValue5',
  'X-OTRS-FollowUp-TicketValue6',
  'X-OTRS-FollowUp-TicketValue7',
  'X-OTRS-FollowUp-TicketValue8',
  'X-OTRS-FollowUp-TicketValue9',
  'X-OTRS-FollowUp-TicketValue10',
  'X-OTRS-FollowUp-TicketValue11',
  'X-OTRS-FollowUp-TicketValue12',
  'X-OTRS-FollowUp-TicketValue13',
  'X-OTRS-FollowUp-TicketValue14',
  'X-OTRS-FollowUp-TicketValue15',
  'X-OTRS-FollowUp-TicketValue16',
  'X-OTRS-FollowUp-TicketTime1',
  'X-OTRS-FollowUp-TicketTime2',
  'X-OTRS-FollowUp-TicketTime3',
  'X-OTRS-FollowUp-TicketTime4',
  'X-OTRS-FollowUp-TicketTime5',
  'X-OTRS-FollowUp-TicketTime6'
];
$Self->{'PostmasterFollowUpOnUnlockAgentNotifyOnlyToOwner'} =  '0';
$Self->{'PostmasterFollowUpState'} =  'open';
$Self->{'PostmasterDefaultState'} =  'new';
$Self->{'PostmasterDefaultPriority'} =  '3 high';
$Self->{'PostmasterDefaultQueue'} =  'Raw';
$Self->{'PostmasterUserID'} =  '1';
$Self->{'PostmasterFollowUpSearchInRaw'} =  '0';
$Self->{'PostmasterFollowUpSearchInAttachment'} =  '0';
$Self->{'PostmasterFollowUpSearchInBody'} =  '0';
$Self->{'PostmasterFollowUpSearchInReferences'} =  '0';
$Self->{'PostmasterAutoHTML2Text'} =  '1';
$Self->{'LoopProtectionLog'} =  '<OTRS_CONFIG_Home>/var/log/LoopProtection';
$Self->{'LoopProtectionModule'} =  'Kernel::System::PostMaster::LoopProtection::DB';
$Self->{'PostMasterReconnectMessage'} =  '20';
$Self->{'PostMasterMaxEmailSize'} =  '16384';
$Self->{'PostmasterMaxEmails'} =  '40';
$Self->{'TicketACL::Default::Action'} =  {};
$Self->{'CustomerFrontend::Module'}->{'CustomerTicketSearch'} =  {
  'Description' => 'Customer ticket search',
  'NavBar' => [
    {
      'AccessKey' => 's',
      'Block' => '',
      'Description' => 'Search',
      'Image' => 'search.png',
      'Link' => 'Action=CustomerTicketSearch',
      'Name' => 'Search',
      'NavBar' => '',
      'Prio' => '300',
      'Type' => ''
    }
  ],
  'NavBarName' => 'Ticket',
  'Title' => 'Search'
};
$Self->{'CustomerFrontend::Module'}->{'CustomerTicketAttachment'} =  {
  'Description' => 'To download attachments',
  'NavBarName' => '',
  'Title' => ''
};
$Self->{'CustomerFrontend::Module'}->{'CustomerZoom'} =  {
  'Description' => 'compat mod',
  'NavBarName' => '',
  'Title' => ''
};
$Self->{'CustomerFrontend::Module'}->{'CustomerTicketPrint'} =  {
  'Description' => 'Customer Ticket Print Module',
  'NavBarName' => '',
  'Title' => 'Print'
};
$Self->{'CustomerFrontend::Module'}->{'CustomerTicketZoom'} =  {
  'Description' => 'Ticket zoom view',
  'NavBarName' => 'Ticket',
  'Title' => 'Zoom'
};
$Self->{'CustomerFrontend::Module'}->{'CustomerTicketMessage'} =  {
  'Description' => 'Create tickets',
  'NavBar' => [
    {
      'AccessKey' => 'n',
      'Block' => '',
      'Description' => 'Create new Ticket',
      'Image' => 'new.png',
      'Link' => 'Action=CustomerTicketMessage',
      'Name' => 'New Ticket',
      'NavBar' => '',
      'Prio' => '100',
      'Type' => ''
    }
  ],
  'NavBarName' => 'Ticket',
  'Title' => 'New Ticket'
};
$Self->{'CustomerFrontend::Module'}->{'CustomerTicketOverView'} =  {
  'Description' => 'Overview of customer tickets',
  'NavBar' => [
    {
      'AccessKey' => 'm',
      'Block' => '',
      'Description' => 'MyTickets',
      'Image' => 'ticket.png',
      'Link' => 'Action=CustomerTicketOverView&Type=MyTickets',
      'Name' => 'MyTickets',
      'NavBar' => '',
      'Prio' => '110',
      'Type' => ''
    },
    {
      'AccessKey' => 'c',
      'Block' => '',
      'Description' => 'CompanyTickets',
      'Image' => 'tickets.png',
      'Link' => 'Action=CustomerTicketOverView&Type=CompanyTickets',
      'Name' => 'CompanyTickets',
      'NavBar' => '',
      'Prio' => '120',
      'Type' => ''
    }
  ],
  'NavBarName' => 'Ticket',
  'Title' => 'Overview'
};
$Self->{'Frontend::Module'}->{'AdminGenericAgent'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block4',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'GenericAgent',
    'Prio' => '300'
  },
  'NavBarName' => 'Admin',
  'Title' => 'GenericAgent'
};
$Self->{'Frontend::Module'}->{'AdminPriority'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block3',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Priority',
    'Prio' => '850'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Priority'
};
$Self->{'Frontend::Module'}->{'AdminState'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block3',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Status',
    'Prio' => '800'
  },
  'NavBarName' => 'Admin',
  'Title' => 'State'
};
$Self->{'Frontend::Module'}->{'AdminType'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block3',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Type',
    'Prio' => '700'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Type'
};
$Self->{'Frontend::Module'}->{'AdminSLA'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block3',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'SLA',
    'Prio' => '1000'
  },
  'NavBarName' => 'Admin',
  'Title' => 'SLA'
};
$Self->{'Frontend::Module'}->{'AdminService'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block3',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Service',
    'Prio' => '900'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Service'
};
$Self->{'Frontend::Module'}->{'AdminNotificationEvent'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block3',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Notification (Event)',
    'Prio' => '400'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Notification'
};
$Self->{'Frontend::Module'}->{'AdminNotification'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block3',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Notification',
    'Prio' => '400'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Notification'
};
$Self->{'Frontend::Module'}->{'AdminSystemAddress'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block3',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Email Addresses',
    'Prio' => '300'
  },
  'NavBarName' => 'Admin',
  'Title' => 'System address'
};
$Self->{'Frontend::Module'}->{'AdminSignature'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block3',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Signature',
    'Prio' => '200'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Signature'
};
$Self->{'Frontend::Module'}->{'AdminSalutation'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block3',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Salutation',
    'Prio' => '100'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Salutation'
};
$Self->{'Frontend::Module'}->{'AdminResponseAttachment'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block2',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Attachments <-> Responses',
    'Prio' => '700'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Attachments <-> Responses'
};
$Self->{'Frontend::Module'}->{'AdminAttachment'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block2',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Attachments',
    'Prio' => '600'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Attachment'
};
$Self->{'Frontend::Module'}->{'AdminQueueAutoResponse'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block2',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Auto Responses <-> Queue',
    'Prio' => '500'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Auto Responses <-> Queue'
};
$Self->{'Frontend::Module'}->{'AdminAutoResponse'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block2',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Auto Responses',
    'Prio' => '400'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Auto Responses'
};
$Self->{'Frontend::Module'}->{'AdminQueueResponses'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block2',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Responses <-> Queue',
    'Prio' => '300'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Responses <-> Queue'
};
$Self->{'Frontend::Module'}->{'AdminResponse'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block2',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Responses',
    'Prio' => '200'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Response'
};
$Self->{'Frontend::Module'}->{'AdminQueue'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block2',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Queue',
    'Prio' => '100'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Queue'
};
$Self->{'Frontend::Module'}->{'AgentTicketBulk'} =  {
  'Description' => 'Ticket bulk module',
  'NavBarName' => 'Ticket',
  'Title' => 'Bulk-Action'
};
$Self->{'Frontend::Module'}->{'AgentTicketPrint'} =  {
  'Description' => 'Ticket Print',
  'NavBarName' => 'Ticket',
  'Title' => 'Print'
};
$Self->{'Frontend::Module'}->{'AgentTicketFreeText'} =  {
  'Description' => 'Ticket FreeText',
  'NavBarName' => 'Ticket',
  'Title' => 'Free Fields'
};
$Self->{'Frontend::Module'}->{'AgentTicketClose'} =  {
  'Description' => 'Ticket Close',
  'NavBarName' => 'Ticket',
  'Title' => 'Close'
};
$Self->{'Frontend::Module'}->{'AgentTicketCustomer'} =  {
  'Description' => 'Ticket Customer',
  'NavBarName' => 'Ticket',
  'Title' => 'Customer'
};
$Self->{'Frontend::Module'}->{'AgentTicketForward'} =  {
  'Description' => 'Ticket Forward Email',
  'NavBarName' => 'Ticket',
  'Title' => 'Forward'
};
$Self->{'Frontend::Module'}->{'AgentTicketBounce'} =  {
  'Description' => 'Ticket Compose Bounce Email',
  'NavBarName' => 'Ticket',
  'Title' => 'Bounce'
};
$Self->{'Frontend::Module'}->{'AgentTicketCompose'} =  {
  'Description' => 'Ticket Compose email Answer',
  'NavBarName' => 'Ticket',
  'Title' => 'Compose'
};
$Self->{'Frontend::Module'}->{'AgentTicketResponsible'} =  {
  'Description' => 'Ticket Responsible',
  'NavBarName' => 'Ticket',
  'Title' => 'Responsible'
};
$Self->{'Frontend::Module'}->{'AgentTicketOwner'} =  {
  'Description' => 'Ticket Owner',
  'NavBarName' => 'Ticket',
  'Title' => 'Owner'
};
$Self->{'Frontend::Module'}->{'AgentTicketHistory'} =  {
  'Description' => 'Ticket History',
  'NavBarName' => 'Ticket',
  'Title' => 'History'
};
$Self->{'Frontend::Module'}->{'AgentTicketMove'} =  {
  'Description' => 'Ticket Move',
  'NavBarName' => 'Ticket',
  'Title' => 'Move'
};
$Self->{'Frontend::Module'}->{'AgentTicketLock'} =  {
  'Description' => 'Ticket Lock',
  'NavBarName' => 'Ticket',
  'Title' => 'Lock'
};
$Self->{'Frontend::Module'}->{'AgentTicketPriority'} =  {
  'Description' => 'Ticket Priority',
  'NavBarName' => 'Ticket',
  'Title' => 'Priority'
};
$Self->{'Frontend::Module'}->{'AgentTicketWatcher'} =  {
  'Description' => 'A TicketWatcher Module',
  'NavBarName' => 'Ticket-Watcher',
  'Title' => 'Ticket-Watcher'
};
$Self->{'Frontend::Module'}->{'AgentTicketPending'} =  {
  'Description' => 'Ticket Pending',
  'NavBarName' => 'Ticket',
  'Title' => 'Pending'
};
$Self->{'Frontend::Module'}->{'AgentTicketMerge'} =  {
  'Description' => 'Ticket Merge',
  'NavBarName' => 'Ticket',
  'Title' => 'Merge'
};
$Self->{'Frontend::Module'}->{'AgentTicketNote'} =  {
  'Description' => 'Ticket Note',
  'NavBarName' => 'Ticket',
  'Title' => 'Note'
};
$Self->{'Frontend::Module'}->{'AgentTicketPlain'} =  {
  'Description' => 'Ticket plain view of an email',
  'NavBarName' => 'Ticket',
  'Title' => 'Plain'
};
$Self->{'Frontend::Module'}->{'AgentTicketAttachment'} =  {
  'Description' => 'To download attachments',
  'NavBarName' => 'Ticket',
  'Title' => ''
};
$Self->{'Frontend::Module'}->{'AgentTicketZoom'} =  {
  'Description' => 'Ticket Zoom',
  'NavBarName' => 'Ticket',
  'Title' => 'Zoom'
};
$Self->{'Frontend::Module'}->{'AgentZoom'} =  {
  'Description' => 'compat module for AgentZoom to AgentTicketZoom',
  'NavBarName' => 'Ticket',
  'Title' => ''
};
$Self->{'Frontend::Module'}->{'AgentCustomerSearch'} =  {
  'Description' => 'AgentCustomerSearch',
  'NavBarName' => 'Ticket',
  'Title' => 'AgentCustomerSearch'
};
$Self->{'Frontend::Module'}->{'AgentTicketWatchView'} =  {
  'Description' => 'Watched Tickets',
  'NavBarName' => 'Ticket',
  'Title' => 'Watched Tickets'
};
$Self->{'Frontend::Module'}->{'AgentTicketResponsibleView'} =  {
  'Description' => 'Responsible Tickets',
  'NavBarName' => 'Ticket',
  'Title' => 'Responsible Tickets'
};
$Self->{'Frontend::Module'}->{'AgentTicketLockedView'} =  {
  'Description' => 'Locked Tickets',
  'NavBarName' => 'Ticket',
  'Title' => 'Locked Tickets'
};
$Self->{'Frontend::Module'}->{'AgentTicketMailbox'} =  {
  'Description' => 'compat module for AgentTicketMailbox to AgentTicketLockedView',
  'NavBarName' => 'Ticket',
  'Title' => ''
};
$Self->{'Frontend::Module'}->{'AgentTicketSearch'} =  {
  'Description' => 'Search Tickets',
  'NavBar' => [
    {
      'AccessKey' => 's',
      'Block' => '',
      'Description' => 'Search Tickets',
      'Image' => 'search.png',
      'Link' => 'Action=AgentTicketSearch',
      'Name' => 'Search',
      'NavBar' => 'Ticket',
      'Prio' => '300',
      'Type' => ''
    }
  ],
  'NavBarName' => 'Ticket',
  'Title' => 'Search'
};
$Self->{'Frontend::Module'}->{'AgentTicketPhoneOutbound'} =  {
  'Description' => 'Phone Call',
  'NavBarName' => 'Ticket',
  'Title' => 'Phone-Ticket'
};
$Self->{'Frontend::Module'}->{'AgentTicketPhone'} =  {
  'Description' => 'Create new Phone Ticket',
  'NavBar' => [
    {
      'AccessKey' => 'n',
      'Block' => '',
      'Description' => 'Create new Phone Ticket (Inbound)',
      'Image' => 'phone-new.png',
      'Link' => 'Action=AgentTicketPhone',
      'Name' => 'Phone-Ticket',
      'NavBar' => 'Ticket',
      'Prio' => '200',
      'Type' => ''
    }
  ],
  'NavBarName' => 'Ticket',
  'Title' => 'Phone-Ticket'
};
$Self->{'Frontend::Module'}->{'AgentTicketQueue'} =  {
  'Description' => 'Overview of all open Tickets',
  'NavBar' => [
    {
      'AccessKey' => 'o',
      'Block' => '',
      'Description' => 'Overview of all open Tickets',
      'Image' => 'overview.png',
      'Link' => 'Action=AgentTicketQueue',
      'Name' => 'QueueView',
      'NavBar' => 'Ticket',
      'Prio' => '100',
      'Type' => ''
    },
    {
      'AccessKey' => 't',
      'Block' => 'ItemArea',
      'Description' => 'Ticket-Area',
      'Image' => 'desktop.png',
      'Link' => 'Action=AgentTicketQueue',
      'Name' => 'Ticket',
      'NavBar' => 'Ticket',
      'Prio' => '200',
      'Type' => 'Menu'
    }
  ],
  'NavBarName' => 'Ticket',
  'Title' => 'QueueView'
};
$Self->{'CustomerFrontend::HeaderMetaModule'}->{'2-TicketSearch'} =  {
  'Action' => 'CustomerTicketSearch',
  'Module' => 'Kernel::Output::HTML::HeaderMetaTicketSearch'
};
$Self->{'CustomerFrontend::CommonParam'}->{'TicketID'} =  '';
$Self->{'CustomerFrontend::CommonParam'}->{'Action'} =  'CustomerTicketOverView';
$Self->{'CustomerFrontend::CommonObject'}->{'TicketObject'} =  'Kernel::System::Ticket';
$Self->{'CustomerFrontend::CommonObject'}->{'QueueObject'} =  'Kernel::System::Queue';
$Self->{'Frontend::CommonParam'}->{'TicketID'} =  '';
$Self->{'Frontend::CommonParam'}->{'QueueID'} =  '0';
$Self->{'Frontend::CommonParam'}->{'Action'} =  'AgentDashboard';
$Self->{'Frontend::CommonObject'}->{'TicketObject'} =  'Kernel::System::Ticket';
$Self->{'Frontend::CommonObject'}->{'QueueObject'} =  'Kernel::System::Queue';
$Self->{'CustomerPreferencesGroups'}->{'RefreshTime'} =  {
  'Activ' => '1',
  'Colum' => 'Frontend',
  'Data' => {
    '' => 'off',
    '10' => '10 minutes',
    '15' => '15 minutes',
    '2' => ' 2 minutes',
    '5' => ' 5 minutes',
    '7' => ' 7 minutes'
  },
  'DataSelected' => '',
  'Desc' => 'Select your QueueView refresh time.',
  'Label' => 'QueueView refresh time',
  'Module' => 'Kernel::Output::HTML::PreferencesGeneric',
  'PrefKey' => 'UserRefreshTime',
  'Prio' => '4000'
};
$Self->{'CustomerPreferencesGroups'}->{'ShownTickets'} =  {
  'Activ' => '1',
  'Colum' => 'Frontend',
  'Data' => {
    '15' => '15',
    '20' => '20',
    '25' => '25',
    '30' => '30'
  },
  'DataSelected' => '25',
  'Desc' => 'Max. shown Tickets a page in Overview.',
  'Label' => 'Shown Tickets',
  'Module' => 'Kernel::Output::HTML::PreferencesGeneric',
  'PrefKey' => 'UserShowTickets',
  'Prio' => '4000'
};
$Self->{'CustomerPreferencesGroups'}->{'ClosedTickets'} =  {
  'Activ' => '1',
  'Colum' => 'Other Options',
  'Data' => {
    '0' => 'No',
    '1' => 'Yes'
  },
  'DataSelected' => '1',
  'Desc' => 'Show closed tickets.',
  'Label' => 'Closed Tickets',
  'Module' => 'Kernel::Output::HTML::PreferencesGeneric',
  'PrefKey' => 'UserShowClosedTickets',
  'Prio' => '2000'
};
$Self->{'Ticket::Frontend::CustomerTicketSearch'}->{'TicketFreeTime'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0'
};
$Self->{'Ticket::Frontend::CustomerTicketSearch'}->{'TicketFreeText'} =  {
  '1' => '0',
  '10' => '0',
  '11' => '0',
  '12' => '0',
  '13' => '0',
  '14' => '0',
  '15' => '0',
  '16' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0',
  '7' => '0',
  '8' => '0',
  '9' => '0'
};
$Self->{'Ticket::Frontend::CustomerTicketSearch'}->{'ExtendedSearchCondition'} =  '1';
$Self->{'Ticket::CustomerTicketSearch::Order::Default'} =  'Down';
$Self->{'Ticket::CustomerTicketSearch::SortBy::Default'} =  'Age';
$Self->{'Ticket::CustomerTicketSearch::SearchPageShown'} =  '40';
$Self->{'Ticket::CustomerTicketSearch::SearchLimit'} =  '5000';
$Self->{'Ticket::Frontend::CustomerTicketSearch'}->{'SearchCSVData'} =  [
  'TicketNumber',
  'Type',
  'Queue',
  'Age',
  'Created',
  'State',
  'Priority',
  'CustomerID',
  'CustomerName',
  'From',
  'Subject',
  'TicketFreeTime4'
];
$Self->{'Ticket::Frontend::CustomerTicketZoom'}->{'StateType'} =  [
  'open',
  'closed'
];
$Self->{'Ticket::Frontend::CustomerTicketZoom'}->{'StateDefault'} =  'open';
$Self->{'Ticket::Frontend::CustomerTicketZoom'}->{'State'} =  '1';
$Self->{'Ticket::Frontend::CustomerTicketZoom'}->{'PriorityDefault'} =  '3 high';
$Self->{'Ticket::Frontend::CustomerTicketZoom'}->{'Priority'} =  '1';
$Self->{'Ticket::Frontend::CustomerTicketZoom'}->{'HistoryComment'} =  '';
$Self->{'Ticket::Frontend::CustomerTicketZoom'}->{'HistoryType'} =  'FollowUp';
$Self->{'Ticket::Frontend::CustomerTicketZoom'}->{'SenderType'} =  'customer';
$Self->{'Ticket::Frontend::CustomerTicketZoom'}->{'ArticleType'} =  'webrequest';
$Self->{'Ticket::Frontend::CustomerTicketZoom'}->{'NextScreenAfterFollowUp'} =  'CustomerTicketOverView';
$Self->{'Ticket::Frontend::CustomerTicketMessage'}->{'TicketFreeTime'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0'
};
$Self->{'Ticket::Frontend::CustomerTicketMessage'}->{'TicketFreeText'} =  {
  '1' => '0',
  '10' => '0',
  '11' => '0',
  '12' => '0',
  '13' => '0',
  '14' => '0',
  '15' => '0',
  '16' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0',
  '7' => '0',
  '8' => '0',
  '9' => '0'
};
$Self->{'CustomerPanel::NewTicketQueueSelectionModule'} =  'Kernel::Output::HTML::CustomerNewTicketQueueSelectionGeneric';
$Self->{'CustomerPanelSelectionString'} =  '<Queue>';
$Self->{'CustomerPanelSelectionType'} =  'Queue';
$Self->{'Ticket::Frontend::CustomerTicketMessage'}->{'HistoryComment'} =  '';
$Self->{'Ticket::Frontend::CustomerTicketMessage'}->{'HistoryType'} =  'WebRequestCustomer';
$Self->{'Ticket::Frontend::CustomerTicketMessage'}->{'SenderType'} =  'customer';
$Self->{'Ticket::Frontend::CustomerTicketMessage'}->{'ArticleType'} =  'webrequest';
$Self->{'Ticket::Frontend::CustomerTicketMessage'}->{'StateDefault'} =  'new';
$Self->{'Ticket::Frontend::CustomerTicketMessage'}->{'PriorityDefault'} =  '3 high';
$Self->{'Ticket::Frontend::CustomerTicketMessage'}->{'Priority'} =  '1';
$Self->{'Ticket::Frontend::CustomerTicketMove'}->{'State'} =  '1';
$Self->{'Ticket::Frontend::CustomerTicketMessage'}->{'NextScreenAfterNewTicket'} =  'CustomerTicketOverView';
$Self->{'CustomerNotifyJustToRealCustomer'} =  '0';
$Self->{'PreferencesGroups'}->{'CreateNextMask'} =  {
  'Activ' => '1',
  'Colum' => 'Frontend',
  'Data' => {
    '' => 'CreateTicket',
    'AgentTicketZoom' => 'TicketZoom'
  },
  'DataSelected' => '',
  'Desc' => 'Select your screen after creating a new ticket.',
  'Label' => 'Screen after new ticket',
  'Module' => 'Kernel::Output::HTML::PreferencesGeneric',
  'PrefKey' => 'UserCreateNextMask',
  'Prio' => '5000'
};
$Self->{'PreferencesGroups'}->{'RefreshTime'} =  {
  'Activ' => '1',
  'Colum' => 'Frontend',
  'Data' => {
    '0' => 'off',
    '10' => '10 minutes',
    '15' => '15 minutes',
    '2' => ' 2 minutes',
    '5' => ' 5 minutes',
    '7' => ' 7 minutes'
  },
  'DataSelected' => '0',
  'Desc' => 'Select your QueueView refresh time.',
  'Label' => 'QueueView refresh time',
  'Module' => 'Kernel::Output::HTML::PreferencesGeneric',
  'PrefKey' => 'UserRefreshTime',
  'Prio' => '3000'
};
$Self->{'PreferencesGroups'}->{'CustomQueue'} =  {
  'Activ' => '1',
  'Colum' => 'Other Options',
  'Desc' => 'Your queue selection of your favourite queues. You also get notified about those queues via email if enabled.',
  'Label' => 'My Queues',
  'Module' => 'Kernel::Output::HTML::PreferencesCustomQueue',
  'Permission' => 'ro',
  'Prio' => '2000'
};
$Self->{'PreferencesGroups'}->{'WatcherNotify'} =  {
  'Activ' => '1',
  'Colum' => 'Mail Management',
  'Data' => {
    '0' => 'No',
    '1' => 'Yes'
  },
  'DataSelected' => '0',
  'Desc' => 'Send me a notification of an watched ticket like an owner of an ticket.',
  'Label' => 'Watch notification',
  'Module' => 'Kernel::Output::HTML::PreferencesTicketWatcher',
  'PrefKey' => 'UserSendWatcherNotification',
  'Prio' => '5000'
};
$Self->{'PreferencesGroups'}->{'MoveNotify'} =  {
  'Activ' => '1',
  'Colum' => 'Mail Management',
  'Data' => {
    '0' => 'No',
    '1' => 'Yes'
  },
  'DataSelected' => '0',
  'Desc' => 'Send me a notification if a ticket is moved into one of "My Queues".',
  'Label' => 'Move notification',
  'Module' => 'Kernel::Output::HTML::PreferencesGeneric',
  'PrefKey' => 'UserSendMoveNotification',
  'Prio' => '4000'
};
$Self->{'PreferencesGroups'}->{'LockTimeoutNotify'} =  {
  'Activ' => '1',
  'Colum' => 'Mail Management',
  'Data' => {
    '0' => 'No',
    '1' => 'Yes'
  },
  'DataSelected' => '0',
  'Desc' => 'Send me a notification if a ticket is unlocked by the system.',
  'Label' => 'Ticket lock timeout notification',
  'Module' => 'Kernel::Output::HTML::PreferencesGeneric',
  'PrefKey' => 'UserSendLockTimeoutNotification',
  'Prio' => '3000'
};
$Self->{'PreferencesGroups'}->{'FollowUpNotify'} =  {
  'Activ' => '1',
  'Colum' => 'Mail Management',
  'Data' => {
    '0' => 'No',
    '1' => 'Yes'
  },
  'DataSelected' => '0',
  'Desc' => 'Send me a notification if a customer sends a follow up and I\'m the owner of the ticket or the ticket is unlocked and is in one of my subscribed queues.',
  'Label' => 'Follow up notification',
  'Module' => 'Kernel::Output::HTML::PreferencesGeneric',
  'PrefKey' => 'UserSendFollowUpNotification',
  'Prio' => '2000'
};
$Self->{'PreferencesGroups'}->{'NewTicketNotify'} =  {
  'Activ' => '1',
  'Colum' => 'Mail Management',
  'Data' => {
    '0' => 'No',
    '1' => 'Yes'
  },
  'DataSelected' => '0',
  'Desc' => 'Send me a notification if there is a new ticket in "My Queues".',
  'Label' => 'New ticket notification',
  'Module' => 'Kernel::Output::HTML::PreferencesGeneric',
  'PrefKey' => 'UserSendNewTicketNotification',
  'Prio' => '1000'
};
$Self->{'DashboardBackend'}->{'0260-TicketCalendar'} =  {
  'Block' => 'ContentSmall',
  'CacheTTL' => '2',
  'Default' => '1',
  'Group' => '',
  'Limit' => '6',
  'Module' => 'Kernel::Output::HTML::DashboardCalendar',
  'Permission' => 'rw',
  'Title' => 'Upcoming Events'
};
$Self->{'DashboardBackend'}->{'0250-TicketStats'} =  {
  'Block' => 'ContentSmall',
  'CacheTTL' => '45',
  'Closed' => '1',
  'Created' => '1',
  'Default' => '1',
  'Group' => '',
  'Module' => 'Kernel::Output::HTML::DashboardTicketStatsGeneric',
  'Permission' => 'rw',
  'Title' => '7 Day Stats'
};
$Self->{'DashboardBackend'}->{'0130-TicketOpen'} =  {
  'Attributes' => 'StateType=open;',
  'Block' => 'ContentLarge',
  'CacheTTLLocal' => '0.5',
  'Default' => '1',
  'Description' => 'Tickets which need to be answered!',
  'Filter' => 'All',
  'Group' => '',
  'Limit' => '10',
  'Module' => 'Kernel::Output::HTML::DashboardTicketGeneric',
  'Permission' => 'rw',
  'Time' => 'Age',
  'Title' => 'Open Tickets / Need to be answered'
};
$Self->{'DashboardBackend'}->{'0120-TicketNew'} =  {
  'Attributes' => 'StateType=new;',
  'Block' => 'ContentLarge',
  'CacheTTLLocal' => '0.5',
  'Default' => '1',
  'Description' => 'All new tickets!',
  'Filter' => 'All',
  'Group' => '',
  'Limit' => '10',
  'Module' => 'Kernel::Output::HTML::DashboardTicketGeneric',
  'Permission' => 'rw',
  'Time' => 'Age',
  'Title' => 'New Tickets'
};
$Self->{'DashboardBackend'}->{'0110-TicketEscalation'} =  {
  'Attributes' => 'TicketEscalationTimeOlderMinutes=1;SortBy=EscalationTime;OrderBy=Down;',
  'Block' => 'ContentLarge',
  'CacheTTLLocal' => '0.5',
  'Default' => '1',
  'Description' => 'All tickets which are escalated!',
  'Filter' => 'All',
  'Group' => '',
  'Limit' => '10',
  'Module' => 'Kernel::Output::HTML::DashboardTicketGeneric',
  'Permission' => 'rw',
  'Time' => 'EscalationTime',
  'Title' => 'Escalated Tickets'
};
$Self->{'CustomerTicket::Permission'}->{'4-CustomerTicketLocked'} =  {
  'Granted' => '1',
  'Module' => 'Kernel::System::Ticket::CustomerPermission::CustomerTicketLocked',
  'Required' => '0'
};
$Self->{'CustomerTicket::Permission'}->{'1-GroupCheck'} =  {
  'Granted' => '0',
  'Module' => 'Kernel::System::Ticket::CustomerPermission::GroupCheck',
  'Required' => '1'
};
$Self->{'Ticket::Permission'}->{'4-WatcherCheck'} =  {
  'Granted' => '1',
  'Module' => 'Kernel::System::Ticket::Permission::WatcherCheck',
  'Required' => '0'
};
$Self->{'Ticket::Permission'}->{'3-GroupCheck'} =  {
  'Granted' => '1',
  'Module' => 'Kernel::System::Ticket::Permission::GroupCheck',
  'Required' => '0'
};
$Self->{'Ticket::Permission'}->{'2-ResponsibleCheck'} =  {
  'Granted' => '1',
  'Module' => 'Kernel::System::Ticket::Permission::ResponsibleCheck',
  'Required' => '0'
};
$Self->{'Ticket::Permission'}->{'1-OwnerCheck'} =  {
  'Granted' => '1',
  'Module' => 'Kernel::System::Ticket::Permission::OwnerCheck',
  'Required' => '0'
};
$Self->{'System::Permission'} =  [
  'ro',
  'move_into',
  'create',
  'note',
  'owner',
  'priority',
  'rw'
];
$Self->{'Ticket::Frontend::PreMenuModule'}->{'440-Close'} =  {
  'Action' => 'AgentTicketClose',
  'Description' => 'Close this ticket!',
  'Link' => 'Action=AgentTicketClose&TicketID=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'Close'
};
$Self->{'Ticket::Frontend::PreMenuModule'}->{'420-Note'} =  {
  'Action' => 'AgentTicketNote',
  'Description' => 'Add a note to this ticket!',
  'Link' => 'Action=AgentTicketNote&TicketID=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'Note'
};
$Self->{'Ticket::Frontend::PreMenuModule'}->{'300-Priority'} =  {
  'Action' => 'AgentTicketPriority',
  'Description' => 'Change the ticket priority!',
  'Link' => 'Action=AgentTicketPriority&TicketID=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'Priority'
};
$Self->{'Ticket::Frontend::PreMenuModule'}->{'210-History'} =  {
  'Action' => 'AgentTicketHistory',
  'Description' => 'Shows the ticket history!',
  'Link' => 'Action=AgentTicketHistory&TicketID=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'History'
};
$Self->{'Ticket::Frontend::PreMenuModule'}->{'200-Zoom'} =  {
  'Action' => 'AgentTicketZoom',
  'Description' => 'Look into a ticket!',
  'Link' => 'Action=AgentTicketZoom&TicketID=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'Zoom'
};
$Self->{'Ticket::Frontend::PreMenuModule'}->{'100-Lock'} =  {
  'Action' => 'AgentTicketLock',
  'Module' => 'Kernel::Output::HTML::TicketMenuLock',
  'Name' => 'Lock'
};
$Self->{'Ticket::Frontend::MenuModule'}->{'450-Close'} =  {
  'Action' => 'AgentTicketClose',
  'Description' => 'Close this ticket!',
  'Link' => 'Action=AgentTicketClose&TicketID=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'Close'
};
$Self->{'Ticket::Frontend::MenuModule'}->{'448-Watch'} =  {
  'Action' => 'AgentTicketWatcher',
  'Module' => 'Kernel::Output::HTML::TicketMenuTicketWatcher',
  'Name' => 'Watch'
};
$Self->{'Ticket::Frontend::MenuModule'}->{'440-Pending'} =  {
  'Action' => 'AgentTicketPending',
  'Description' => 'Set this ticket to pending!',
  'Link' => 'Action=AgentTicketPending&TicketID=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'Pending'
};
$Self->{'Ticket::Frontend::MenuModule'}->{'430-Merge'} =  {
  'Action' => 'AgentTicketMerge',
  'Description' => 'Merge this ticket!',
  'Link' => 'Action=AgentTicketMerge&TicketID=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'Merge'
};
$Self->{'Ticket::Frontend::MenuModule'}->{'420-Note'} =  {
  'Action' => 'AgentTicketNote',
  'Description' => 'Add a note to this ticket!',
  'Link' => 'Action=AgentTicketNote&TicketID=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'Note'
};
$Self->{'Ticket::Frontend::MenuModule'}->{'420-Customer'} =  {
  'Action' => 'AgentTicketCustomer',
  'Description' => 'Change the ticket customer!',
  'Link' => 'Action=AgentTicketCustomer&TicketID=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'Customer'
};
$Self->{'Ticket::Frontend::MenuModule'}->{'410-Responsible'} =  {
  'Action' => 'AgentTicketResponsible',
  'Description' => 'Change the ticket responsible!',
  'Link' => 'Action=AgentTicketResponsible&TicketID=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuResponsible',
  'Name' => 'Responsible'
};
$Self->{'Ticket::Frontend::MenuModule'}->{'400-Owner'} =  {
  'Action' => 'AgentTicketOwner',
  'Description' => 'Change the ticket owner!',
  'Link' => 'Action=AgentTicketOwner&TicketID=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'Owner'
};
$Self->{'Ticket::Frontend::MenuModule'}->{'320-Link'} =  {
  'Action' => 'AgentLinkObject',
  'Description' => 'Link this ticket to an other objects!',
  'Link' => 'Action=AgentLinkObject&SourceObject=Ticket&SourceKey=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'Link'
};
$Self->{'Ticket::Frontend::MenuModule'}->{'310-FreeText'} =  {
  'Action' => 'AgentTicketFreeText',
  'Description' => 'Change the ticket free fields!',
  'Link' => 'Action=AgentTicketFreeText&TicketID=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'Free Fields'
};
$Self->{'Ticket::Frontend::MenuModule'}->{'300-Priority'} =  {
  'Action' => 'AgentTicketPriority',
  'Description' => 'Change the ticket priority!',
  'Link' => 'Action=AgentTicketPriority&TicketID=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'Priority'
};
$Self->{'Ticket::Frontend::MenuModule'}->{'210-Print'} =  {
  'Action' => 'AgentTicketPrint',
  'Description' => 'Print this ticket!',
  'Link' => 'Action=AgentTicketPrint&TicketID=$QData{"TicketID"}',
  'LinkParam' => 'target="print"',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'Print'
};
$Self->{'Ticket::Frontend::MenuModule'}->{'200-History'} =  {
  'Action' => 'AgentTicketHistory',
  'Description' => 'Shows the ticket history!',
  'Link' => 'Action=AgentTicketHistory&TicketID=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'History'
};
$Self->{'Ticket::Frontend::MenuModule'}->{'100-Lock'} =  {
  'Action' => 'AgentTicketLock',
  'Module' => 'Kernel::Output::HTML::TicketMenuLock',
  'Name' => 'Lock'
};
$Self->{'Ticket::Frontend::MenuModule'}->{'000-Back'} =  {
  'Action' => '',
  'Description' => 'Back',
  'Link' => '$Env{"LastScreenOverview"}&TicketID=$QData{"TicketID"}',
  'Module' => 'Kernel::Output::HTML::TicketMenuGeneric',
  'Name' => 'Back'
};
$Self->{'Ticket::Frontend::ArticleAttachmentModule'}->{'2-HTML-Viewer'} =  {
  'Module' => 'Kernel::Output::HTML::ArticleAttachmentHTMLViewer'
};
$Self->{'Ticket::Frontend::ArticleAttachmentModule'}->{'1-Download'} =  {
  'Module' => 'Kernel::Output::HTML::ArticleAttachmentDownload'
};
$Self->{'Ticket::Frontend::ArticleComposeModule'}->{'2-CryptEmail'} =  {
  'Module' => 'Kernel::Output::HTML::ArticleComposeCrypt'
};
$Self->{'Ticket::Frontend::ArticleComposeModule'}->{'1-SignEmail'} =  {
  'Module' => 'Kernel::Output::HTML::ArticleComposeSign'
};
$Self->{'Ticket::Frontend::ArticlePreViewModule'}->{'1-SMIME'} =  {
  'Module' => 'Kernel::Output::HTML::ArticleCheckSMIME'
};
$Self->{'Ticket::Frontend::ArticlePreViewModule'}->{'1-PGP'} =  {
  'Module' => 'Kernel::Output::HTML::ArticleCheckPGP'
};
$Self->{'Ticket::Frontend::ArticleViewModule'}->{'1-SMIME'} =  {
  'Module' => 'Kernel::Output::HTML::ArticleCheckSMIME'
};
$Self->{'Ticket::Frontend::ArticleViewModule'}->{'1-PGP'} =  {
  'Module' => 'Kernel::Output::HTML::ArticleCheckPGP'
};
$Self->{'Frontend::CustomerUser::Item'}->{'9-OpenTickets'} =  {
  'Action' => 'AgentTicketSearch',
  'Attributes' => 'StateType=Open;',
  'ImageNoOpenTicket' => 'greenled-small.png',
  'ImageOpenTicket' => 'redled-small.png',
  'Module' => 'Kernel::Output::HTML::CustomerUserGenericTicket',
  'Subaction' => 'Search',
  'Target' => '_blank',
  'Text' => 'Open Tickets'
};
$Self->{'Frontend::NotifyModule'}->{'3-Ticket::AgentTicketSeen'} =  {
  'Module' => 'Kernel::Output::HTML::NotificationAgentTicketSeen'
};
$Self->{'Frontend::HeaderMetaModule'}->{'2-TicketSearch'} =  {
  'Action' => 'AgentTicketSearch',
  'Module' => 'Kernel::Output::HTML::HeaderMetaTicketSearch'
};
$Self->{'Frontend::NavBarModule'}->{'1-Ticket::LockedTickets'} =  {
  'Module' => 'Kernel::Output::HTML::NavBarLockedTickets'
};
$Self->{'Frontend::NavBarModule'}->{'1-Ticket::TicketWatcher'} =  {
  'Module' => 'Kernel::Output::HTML::NavBarTicketWatcher'
};
$Self->{'CustomerDBLinkTarget'} =  '';
$Self->{'CustomerDBLink'} =  '$Env{"CGIHandle"}?Action=AgentTicketCustomer&TicketID=$Data{"TicketID"}';
$Self->{'Ticket::HTTPNotificationLinkToAdapter'} =  'http://10.157.222.50:8084/OTRS_Adapter/TTSynchronizeUpdate';
$Self->{'Ticket::HTTPNotificationLink'} =  'http://10.157.222.50:8084/OTRS_Interface/OtrsUpdateTicket';
$Self->{'Ticket::StateAfterPending'} =  {
  'pending auto close+' => 'closed successful',
  'pending auto close-' => 'closed unsuccessful'
};
$Self->{'Ticket::PendingAutoStateType'} =  [
  'pending auto'
];
$Self->{'Ticket::PendingReminderStateType'} =  [
  'pending reminder'
];
$Self->{'Ticket::PendingNotificationNotToResponsible'} =  '0';
$Self->{'Ticket::PendingNotificationOnlyToOwner'} =  '0';
$Self->{'Ticket::UnlockStateType'} =  [
  'new',
  'open'
];
$Self->{'Ticket::ViewableStateType'} =  [
  'new',
  'open',
  'pending reminder',
  'pending auto'
];
$Self->{'Ticket::ViewableLocks'} =  [
  '\'unlock\'',
  '\'tmp_lock\''
];
$Self->{'Ticket::ViewableSenderTypes'} =  [
  '\'customer\''
];
$Self->{'Ticket::Frontend::AutomaticMergeText'} =  'Merged Ticket <OTRS_TICKET> to <OTRS_MERGE_TO_TICKET>.';
$Self->{'Ticket::Frontend::MergeText'} =  'Your email with ticket number "<OTRS_TICKET>" is merged to "<OTRS_MERGE_TO_TICKET>".';
$Self->{'Ticket::Frontend::AgentTicketCustomer'}->{'RequiredLock'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketCustomer'}->{'Permission'} =  'customer';
$Self->{'Ticket::Frontend::AgentTicketMerge'}->{'RequiredLock'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketMerge'}->{'Permission'} =  'rw';
$Self->{'Ticket::Frontend::AgentTicketForward'}->{'TicketFreeTime'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketForward'}->{'TicketFreeText'} =  {
  '1' => '0',
  '10' => '0',
  '11' => '0',
  '12' => '0',
  '13' => '0',
  '14' => '0',
  '15' => '0',
  '16' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0',
  '7' => '0',
  '8' => '0',
  '9' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketForward'}->{'ArticleTypes'} =  [
  'email-external',
  'email-internal'
];
$Self->{'Ticket::Frontend::AgentTicketForward'}->{'ArticleTypeDefault'} =  'email-external';
$Self->{'Ticket::Frontend::AgentTicketForward'}->{'StateType'} =  [
  'open',
  'closed'
];
$Self->{'Ticket::Frontend::AgentTicketForward'}->{'StateDefault'} =  'closed successful';
$Self->{'Ticket::Frontend::AgentTicketForward'}->{'RequiredLock'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketForward'}->{'Permission'} =  'forward';
$Self->{'Ticket::Frontend::AgentTicketCompose'}->{'ArticleFreeText'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketCompose'}->{'TicketFreeTime'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketCompose'}->{'TicketFreeText'} =  {
  '1' => '0',
  '10' => '0',
  '11' => '0',
  '12' => '0',
  '13' => '0',
  '14' => '0',
  '15' => '0',
  '16' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0',
  '7' => '0',
  '8' => '0',
  '9' => '0'
};
$Self->{'Ticket::Frontend::ComposeExcludeCcRecipients'} =  '0';
$Self->{'Ticket::Frontend::ComposeReplaceSenderAddress'} =  '0';
$Self->{'Ticket::Frontend::ComposeAddCustomerAddress'} =  '1';
$Self->{'Ticket::Frontend::Quote'} =  '>';
$Self->{'Ticket::Frontend::ResponseFormat'} =  '$QData{"Salutation"}
$TimeShort{"$QData{"Created"}"} - $QData{"OrigFromName"} $Text{"wrote"}:
$QData{"Body"}

$QData{"StdResponse"}

$QData{"Signature"}
';
$Self->{'Ticket::Frontend::AgentTicketCompose'}->{'StateType'} =  [
  'open',
  'closed',
  'pending auto',
  'pending reminder'
];
$Self->{'Ticket::Frontend::AgentTicketCompose'}->{'StateDefault'} =  'open';
$Self->{'Ticket::Frontend::AgentTicketCompose'}->{'RequiredLock'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketCompose'}->{'Permission'} =  'compose';
$Self->{'Ticket::Frontend::BounceText'} =  'Your email with ticket number "<OTRS_TICKET>" is bounced to "<OTRS_BOUNCE_TO>". Contact this address for further information.';
$Self->{'Ticket::Frontend::AgentTicketBounce'}->{'StateType'} =  [
  'open',
  'closed'
];
$Self->{'Ticket::Frontend::AgentTicketBounce'}->{'StateDefault'} =  'closed successful';
$Self->{'Ticket::Frontend::AgentTicketBounce'}->{'RequiredLock'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketBounce'}->{'Permission'} =  'bounce';
$Self->{'Ticket::Frontend::AgentTicketMove'}->{'TicketFreeTime'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketMove'}->{'TicketFreeText'} =  {
  '1' => '0',
  '10' => '0',
  '11' => '0',
  '12' => '0',
  '13' => '0',
  '14' => '0',
  '15' => '0',
  '16' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0',
  '7' => '0',
  '8' => '0',
  '9' => '0'
};
$Self->{'Ticket::DefaultNextMoveStateType'} =  [
  'open',
  'closed'
];
$Self->{'Ticket::Frontend::AgentTicketMove'}->{'State'} =  '1';
$Self->{'Ticket::Frontend::MoveType'} =  'form';
$Self->{'Ticket::Frontend::AgentTicketBulk'}->{'ArticleTypes'} =  {
  'note-external' => '1',
  'note-external-FromPI' => '0',
  'note-external-Siebel' => '0',
  'note-external-ToPI' => '0',
  'note-external-pending' => '1',
  'note-internal' => '1',
  'note-report' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketBulk'}->{'ArticleTypeDefault'} =  'note-internal';
$Self->{'Ticket::Frontend::AgentTicketBulk'}->{'Priority'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketBulk'}->{'StateType'} =  [
  'open',
  'closed',
  'pending reminder',
  'pending auto'
];
$Self->{'Ticket::Frontend::AgentTicketBulk'}->{'State'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketBulk'}->{'Responsible'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketBulk'}->{'Owner'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'HistoryComment'} =  '%%Responsible';
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'HistoryType'} =  'AddNote';
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'ArticleFreeText'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'TicketFreeTime'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'TicketFreeText'} =  {
  '1' => '0',
  '10' => '0',
  '11' => '0',
  '12' => '0',
  '13' => '0',
  '14' => '0',
  '15' => '0',
  '16' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0',
  '7' => '0',
  '8' => '0',
  '9' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'Title'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'ArticleTypes'} =  {
  'note-external' => '0',
  'note-external-FromPI' => '0',
  'note-external-Siebel' => '0',
  'note-external-ToPI' => '0',
  'note-external-pending' => '0',
  'note-internal' => '1',
  'note-report' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'ArticleTypeDefault'} =  'note-internal';
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'Body'} =  '';
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'Subject'} =  '$Text{"Responsible Update"}!';
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'Note'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'StateDefault'} =  'open';
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'StateType'} =  [
  'open',
  'pending reminder',
  'pending auto'
];
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'State'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'Responsible'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'Owner'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'Service'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'TicketType'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'RequiredLock'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketResponsible'}->{'Permission'} =  'responsible';
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'HistoryComment'} =  '%%Priority';
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'HistoryType'} =  'AddNote';
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'ArticleFreeText'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'TicketFreeTime'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'TicketFreeText'} =  {
  '1' => '0',
  '10' => '0',
  '11' => '0',
  '12' => '0',
  '13' => '0',
  '14' => '0',
  '15' => '0',
  '16' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0',
  '7' => '0',
  '8' => '0',
  '9' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'Title'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'Priority'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'ArticleTypes'} =  {
  'note-external' => '0',
  'note-external-FromPI' => '0',
  'note-external-Siebel' => '0',
  'note-external-ToPI' => '0',
  'note-external-pending' => '0',
  'note-internal' => '1',
  'note-report' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'ArticleTypeDefault'} =  'note-internal';
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'Body'} =  '';
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'Subject'} =  '$Text{"Priority Update"}!';
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'Note'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'StateDefault'} =  'open';
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'StateType'} =  [
  'open',
  'pending reminder',
  'pending auto'
];
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'State'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'Responsible'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'Owner'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'Service'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'TicketType'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'RequiredLock'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketPriority'}->{'Permission'} =  'priority';
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'HistoryComment'} =  '%%Pending';
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'HistoryType'} =  'AddNote';
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'ArticleFreeText'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'TicketFreeTime'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'TicketFreeText'} =  {
  '1' => '0',
  '10' => '0',
  '11' => '0',
  '12' => '0',
  '13' => '0',
  '14' => '0',
  '15' => '0',
  '16' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0',
  '7' => '0',
  '8' => '0',
  '9' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'Title'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'ArticleTypes'} =  {
  'note-external' => '0',
  'note-external-FromPI' => '0',
  'note-external-Siebel' => '0',
  'note-external-ToPI' => '0',
  'note-external-pending' => '1',
  'note-internal' => '0',
  'note-report' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'ArticleTypeDefault'} =  'note-external-pending';
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'Body'} =  '';
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'Note'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'StateDefault'} =  'pending reminder';
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'StateType'} =  [
  'pending reminder',
  'pending auto'
];
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'State'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'Responsible'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'Owner'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'Service'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'TicketType'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'RequiredLock'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketPending'}->{'Permission'} =  'pending';
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'HistoryComment'} =  '%%Owner';
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'HistoryType'} =  'AddNote';
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'ArticleFreeText'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'TicketFreeTime'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'TicketFreeText'} =  {
  '1' => '0',
  '10' => '0',
  '11' => '0',
  '12' => '0',
  '13' => '0',
  '14' => '0',
  '15' => '0',
  '16' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0',
  '7' => '0',
  '8' => '0',
  '9' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'Title'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'ArticleTypes'} =  {
  'note-external' => '0',
  'note-external-FromPI' => '0',
  'note-external-Siebel' => '0',
  'note-external-ToPI' => '0',
  'note-external-pending' => '0',
  'note-internal' => '1',
  'note-report' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'ArticleTypeDefault'} =  'note-internal';
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'Body'} =  '';
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'Subject'} =  '$Text{"Owner Update"}!';
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'Note'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'StateDefault'} =  'open';
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'StateType'} =  [
  'open',
  'pending reminder',
  'pending auto'
];
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'State'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'Responsible'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'Owner'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'Service'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'TicketType'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'RequiredLock'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketOwner'}->{'Permission'} =  'owner';
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'HistoryComment'} =  '%%Note';
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'HistoryType'} =  'AddNote';
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'ArticleFreeText'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'TicketFreeTime'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'TicketFreeText'} =  {
  '1' => '0',
  '10' => '0',
  '11' => '0',
  '12' => '0',
  '13' => '0',
  '14' => '0',
  '15' => '0',
  '16' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0',
  '7' => '0',
  '8' => '0',
  '9' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'Title'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'ArticleTypes'} =  {
  'note-external' => '1',
  'note-external-FromPI' => '0',
  'note-external-Siebel' => '0',
  'note-external-ToPI' => '1',
  'note-external-pending' => '0',
  'note-internal' => '1',
  'note-report' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'ArticleTypeDefault'} =  'note-internal';
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'Body'} =  '';
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'Subject'} =  '$Text{"Note"}';
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'Note'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'StateType'} =  [
  'open',
  'closed',
  'pending reminder',
  'pending auto'
];
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'State'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'Responsible'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'Owner'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'Service'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'TicketType'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'RequiredLock'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketNote'}->{'Permission'} =  'note';
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'HistoryComment'} =  '%%Close';
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'HistoryType'} =  'AddNote';
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'ArticleFreeText'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'TicketFreeTime'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'TicketFreeText'} =  {
  '1' => '0',
  '10' => '0',
  '11' => '0',
  '12' => '0',
  '13' => '0',
  '14' => '0',
  '15' => '0',
  '16' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0',
  '7' => '0',
  '8' => '0',
  '9' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'Title'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'ArticleTypes'} =  {
  'note-external' => '0',
  'note-external-FromPI' => '0',
  'note-external-Siebel' => '0',
  'note-external-ToPI' => '0',
  'note-external-pending' => '0',
  'note-internal' => '1',
  'note-report' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'ArticleTypeDefault'} =  'note-internal';
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'Body'} =  '';
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'Subject'} =  '$Text{"Close"}';
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'Note'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'StateDefault'} =  'closed successful';
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'StateType'} =  [
  'closed'
];
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'State'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'Responsible'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'Owner'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'Service'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'TicketType'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'RequiredLock'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketClose'}->{'Permission'} =  'close';
$Self->{'Ticket::Frontend::AgentTicketEmail'}->{'HistoryComment'} =  '';
$Self->{'Ticket::Frontend::AgentTicketEmail'}->{'HistoryType'} =  'EmailAgent';
$Self->{'Ticket::Frontend::AgentTicketEmail'}->{'ArticleFreeText'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketEmail'}->{'TicketFreeTime'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketEmail'}->{'TicketFreeText'} =  {
  '1' => '0',
  '10' => '0',
  '11' => '0',
  '12' => '0',
  '13' => '0',
  '14' => '0',
  '15' => '0',
  '16' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0',
  '7' => '0',
  '8' => '0',
  '9' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketEmail'}->{'StateType'} =  [
  'open',
  'pending auto',
  'pending reminder',
  'closed'
];
$Self->{'Ticket::Frontend::AgentTicketEmail'}->{'StateDefault'} =  'open';
$Self->{'Ticket::Frontend::AgentTicketEmail'}->{'Body'} =  '';
$Self->{'Ticket::Frontend::AgentTicketEmail'}->{'Subject'} =  '';
$Self->{'Ticket::Frontend::AgentTicketEmail'}->{'SenderType'} =  'agent';
$Self->{'Ticket::Frontend::AgentTicketEmail'}->{'ArticleType'} =  'email-external';
$Self->{'Ticket::Frontend::AgentTicketEmail'}->{'Priority'} =  '3 high';
$Self->{'Ticket::Frontend::AgentTicketPhone'}->{'SplitLinkType'} =  {
  'Direction' => 'Target',
  'LinkType' => 'ParentChild'
};
$Self->{'Ticket::Frontend::AgentTicketPhone'}->{'HistoryComment'} =  '';
$Self->{'Ticket::Frontend::AgentTicketPhone'}->{'HistoryType'} =  'PhoneCallCustomer';
$Self->{'Ticket::Frontend::AgentTicketPhone'}->{'ArticleFreeText'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketPhone'}->{'TicketFreeTime'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketPhone'}->{'TicketFreeText'} =  {
  '1' => '1',
  '10' => '0',
  '11' => '0',
  '12' => '1',
  '13' => '1',
  '14' => '1',
  '15' => '1',
  '16' => '1',
  '2' => '1',
  '3' => '1',
  '4' => '1',
  '5' => '1',
  '6' => '1',
  '7' => '1',
  '8' => '1',
  '9' => '1'
};
$Self->{'Ticket::Frontend::AgentTicketPhone'}->{'StateType'} =  [
  'open',
  'pending auto',
  'pending reminder',
  'closed'
];
$Self->{'Ticket::Frontend::AgentTicketPhone'}->{'StateDefault'} =  'open';
$Self->{'Ticket::Frontend::AgentTicketPhone'}->{'Body'} =  '';
$Self->{'Ticket::Frontend::AgentTicketPhone'}->{'Subject'} =  '';
$Self->{'Ticket::Frontend::AgentTicketPhone'}->{'SenderType'} =  'customer';
$Self->{'Ticket::Frontend::AgentTicketPhone'}->{'ArticleType'} =  'phone';
$Self->{'Ticket::Frontend::AgentTicketPhone'}->{'Priority'} =  '3 high';
$Self->{'Ticket::Frontend::ShowCustomerTickets'} =  '1';
$Self->{'Ticket::Frontend::NewQueueSelectionString'} =  '<Queue>';
$Self->{'Ticket::Frontend::NewQueueSelectionType'} =  'Queue';
$Self->{'Ticket::Frontend::NewResponsibleSelection'} =  '1';
$Self->{'Ticket::Frontend::NewOwnerSelection'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketPhoneOutbound'}->{'HistoryComment'} =  '';
$Self->{'Ticket::Frontend::AgentTicketPhoneOutbound'}->{'HistoryType'} =  'PhoneCallAgent';
$Self->{'Ticket::Frontend::AgentTicketPhoneOutbound'}->{'ArticleFreeText'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketPhoneOutbound'}->{'TicketFreeTime'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketPhoneOutbound'}->{'TicketFreeText'} =  {
  '1' => '0',
  '10' => '0',
  '11' => '0',
  '12' => '0',
  '13' => '0',
  '14' => '0',
  '15' => '0',
  '16' => '0',
  '2' => '0',
  '3' => '0',
  '4' => '0',
  '5' => '0',
  '6' => '0',
  '7' => '0',
  '8' => '0',
  '9' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketPhoneOutbound'}->{'StateType'} =  [
  'open',
  'pending auto',
  'pending reminder',
  'closed'
];
$Self->{'Ticket::Frontend::AgentTicketPhoneOutbound'}->{'State'} =  'closed successful';
$Self->{'Ticket::Frontend::AgentTicketPhoneOutbound'}->{'Body'} =  '';
$Self->{'Ticket::Frontend::AgentTicketPhoneOutbound'}->{'Subject'} =  '$Text{"Phone call"}!';
$Self->{'Ticket::Frontend::AgentTicketPhoneOutbound'}->{'SenderType'} =  'agent';
$Self->{'Ticket::Frontend::AgentTicketPhoneOutbound'}->{'ArticleType'} =  'phone';
$Self->{'Ticket::Frontend::AgentTicketPhoneOutbound'}->{'RequiredLock'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketPhoneOutbound'}->{'Permission'} =  'phone';
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'HistoryComment'} =  '%%FreeText';
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'HistoryType'} =  'AddNote';
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'ArticleFreeText'} =  {
  '1' => '0',
  '2' => '0',
  '3' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'TicketFreeText'} =  {
  '1' => '1',
  '10' => '0',
  '11' => '0',
  '12' => '1',
  '13' => '0',
  '14' => '1',
  '15' => '1',
  '16' => '0',
  '2' => '1',
  '3' => '1',
  '4' => '1',
  '5' => '1',
  '6' => '1',
  '7' => '1',
  '8' => '1',
  '9' => '1'
};
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'Title'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'ArticleTypes'} =  {
  'note-external' => '1',
  'note-external-FromPI' => '0',
  'note-external-Siebel' => '0',
  'note-external-ToPI' => '0',
  'note-external-pending' => '0',
  'note-internal' => '1',
  'note-report' => '0'
};
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'ArticleTypeDefault'} =  'note-internal';
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'Body'} =  '';
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'Subject'} =  '$Text{"Note"}';
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'Note'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'StateType'} =  [
  'open',
  'closed',
  'pending reminder',
  'pending auto'
];
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'State'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'Responsible'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'Owner'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'Service'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'TicketType'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'RequiredLock'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketFreeText'}->{'Permission'} =  'rw';
$Self->{'Ticket::Frontend::AgentTicketWatchView'}->{'Order::Default'} =  'Up';
$Self->{'Ticket::Frontend::AgentTicketWatchView'}->{'SortBy::Default'} =  'Age';
$Self->{'Ticket::Frontend::AgentTicketResponsibleView'}->{'Order::Default'} =  'Up';
$Self->{'Ticket::Frontend::AgentTicketResponsibleView'}->{'SortBy::Default'} =  'Age';
$Self->{'Ticket::Frontend::AgentTicketLockedView'}->{'Order::Default'} =  'Up';
$Self->{'Ticket::Frontend::AgentTicketLockedView'}->{'SortBy::Default'} =  'Age';
$Self->{'Ticket::Frontend::AgentTicketSearch'}->{'ArticleCreateTime'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketSearch'}->{'SearchCSVData'} =  [
  'TicketNumber',
  'Age',
  'Created',
  'Closed',
  'FirstLock',
  'FirstResponse',
  'State',
  'Priority',
  'Queue',
  'Lock',
  'Owner',
  'UserFirstname',
  'UserLastname',
  'CustomerID',
  'CustomerName',
  'From',
  'Subject',
  'AccountedTime',
  'TicketFreeKey1',
  'TicketFreeText1',
  'TicketFreeKey2',
  'TicketFreeText2',
  'TicketFreeKey3',
  'TicketFreeText3',
  'TicketFreeKey4',
  'TicketFreeText4',
  'TicketFreeKey5',
  'TicketFreeText5',
  'TicketFreeKey6',
  'TicketFreeText6',
  'TicketFreeKey7',
  'TicketFreeText7',
  'TicketFreeKey8',
  'TicketFreeText8',
  'TicketFreeTime1',
  'TicketFreeTime2',
  'TicketFreeTime3',
  'TicketFreeTime4',
  'TicketFreeTime5',
  'TicketFreeTime6',
  'ArticleTree',
  'SolutionInMin',
  'SolutionDiffInMin',
  'FirstResponseInMin',
  'FirstResponseDiffInMin'
];
$Self->{'Ticket::Frontend::AgentTicketSearch'}->{'SearchArticleCSVTree'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketSearch'}->{'Order::Default'} =  'Down';
$Self->{'Ticket::Frontend::AgentTicketSearch'}->{'SortBy::Default'} =  'Age';
$Self->{'Ticket::Frontend::AgentTicketSearch'}->{'TicketFreeText'} =  {
  '1' => '1',
  '10' => '0',
  '11' => '0',
  '12' => '1',
  '13' => '0',
  '14' => '1',
  '15' => '1',
  '16' => '1',
  '2' => '1',
  '3' => '1',
  '4' => '1',
  '5' => '1',
  '6' => '1',
  '7' => '1',
  '8' => '1',
  '9' => '1'
};
$Self->{'Ticket::Frontend::AgentTicketSearch'}->{'SearchViewableTicketLines'} =  '10';
$Self->{'Ticket::Frontend::AgentTicketSearch'}->{'SearchPageShown'} =  '40';
$Self->{'Ticket::Frontend::AgentTicketSearch'}->{'SearchLimit'} =  '2000';
$Self->{'Ticket::Frontend::AgentTicketSearch'}->{'ExtendedSearchCondition'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketEscalationView'}->{'Order::Default'} =  'Up';
$Self->{'Ticket::Frontend::AgentTicketEscalationView'}->{'SortBy::Default'} =  'EscalationTime';
$Self->{'Ticket::Frontend::AgentTicketEscalationView'}->{'ViewableTicketsPage'} =  '50';
$Self->{'Ticket::Frontend::AgentTicketStatusView'}->{'Order::Default'} =  'Down';
$Self->{'Ticket::Frontend::AgentTicketStatusView'}->{'SortBy::Default'} =  'Age';
$Self->{'Ticket::Frontend::AgentTicketStatusView'}->{'ViewableTicketsPage'} =  '50';
$Self->{'Ticket::Frontend::NeedSpellCheck'} =  '0';
$Self->{'Ticket::Frontend::NeedAccountedTime'} =  '0';
$Self->{'Ticket::Frontend::TimeUnits'} =  ' (work units)';
$Self->{'Ticket::Frontend::AccountTime'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketQueue'}->{'Order::Default'} =  'Up';
$Self->{'Ticket::Frontend::AgentTicketQueue'}->{'SortBy::Default'} =  'Age';
$Self->{'Ticket::Frontend::AgentTicketQueue'}->{'Blink'} =  '1';
$Self->{'Ticket::Frontend::AgentTicketQueue'}->{'HighlightColor2'} =  'red';
$Self->{'Ticket::Frontend::AgentTicketQueue'}->{'HighlightAge2'} =  '2880';
$Self->{'Ticket::Frontend::AgentTicketQueue'}->{'HighlightColor1'} =  'orange';
$Self->{'Ticket::Frontend::AgentTicketQueue'}->{'HighlightAge1'} =  '1440';
$Self->{'Ticket::Frontend::AgentTicketQueue'}->{'ViewAllPossibleTickets'} =  '0';
$Self->{'Ticket::Frontend::AgentTicketQueue'}->{'StripEmptyLines'} =  '0';
$Self->{'Ticket::Frontend::CustomerInfoQueueMaxSize'} =  '18';
$Self->{'Ticket::Frontend::CustomerInfoQueue'} =  '0';
$Self->{'Ticket::Frontend::CustomerInfoZoomMaxSize'} =  '22';
$Self->{'Ticket::Frontend::CustomerInfoComposeMaxSize'} =  '22';
$Self->{'Ticket::Frontend::CustomerInfoCompose'} =  '1';
$Self->{'Ticket::Frontend::TextAreaNote'} =  '78';
$Self->{'Ticket::Frontend::TextAreaEmail'} =  '82';
$Self->{'Ticket::Frontend::HistoryOrder'} =  'normal';
$Self->{'Ticket::Frontend::HTMLArticleHeightMax'} =  '2500';
$Self->{'Ticket::Frontend::HTMLArticleHeightDefault'} =  '100';
$Self->{'Ticket::Frontend::ZoomRichTextForce'} =  '0';
$Self->{'Ticket::Frontend::TicketArticleFilter'} =  '0';
$Self->{'Ticket::ZoomAttachmentDisplayCount'} =  '3';
$Self->{'Ticket::ZoomAttachmentDisplay'} =  '1';
$Self->{'Ticket::Frontend::ZoomExpandSort'} =  'normal';
$Self->{'Ticket::Frontend::ZoomExpand'} =  '0';
$Self->{'Ticket::Frontend::PlainView'} =  '0';
$Self->{'Ticket::Frontend::BulkFeature'} =  '1';
$Self->{'Ticket::Watcher'} =  '0';
$Self->{'Ticket::Frontend::StdResponsesMode'} =  'Link';
$Self->{'Ticket::Frontend::ListType'} =  'tree';
$Self->{'Ticket::Frontend::PendingDiffTime'} =  '86400';
$Self->{'Ticket::Frontend::CustomerSearchAutoComplete::DynamicWidth'} =  '1';
$Self->{'Ticket::Frontend::CustomerSearchAutoComplete'}->{'MaxResultsDisplayed'} =  '20';
$Self->{'Ticket::Frontend::CustomerSearchAutoComplete'}->{'TypeAhead'} =  'false';
$Self->{'Ticket::Frontend::CustomerSearchAutoComplete'}->{'QueryDelay'} =  '0.1';
$Self->{'Ticket::Frontend::CustomerSearchAutoComplete'}->{'MinQueryLength'} =  '2';
$Self->{'Ticket::Frontend::CustomerSearchAutoComplete'}->{'Active'} =  '1';
$Self->{'Ticket::Frontend::Overview'}->{'Preview'} =  {
  'CustomerInfo' => '0',
  'CustomerInfoMaxSize' => '18',
  'Image' => 'overviewpreview.png',
  'ImageSelected' => 'overviewpreview-selected.png',
  'Module' => 'Kernel::Output::HTML::TicketOverviewPreview',
  'Name' => 'Preview',
  'PageShown' => '15'
};
$Self->{'Ticket::Frontend::Overview'}->{'Medium'} =  {
  'CustomerInfo' => '0',
  'Image' => 'overviewmedium.png',
  'ImageSelected' => 'overviewmedium-selected.png',
  'Module' => 'Kernel::Output::HTML::TicketOverviewMedium',
  'Name' => 'Medium',
  'PageShown' => '20'
};
$Self->{'Ticket::Frontend::OverviewSmall'}->{'ColumnHeader'} =  'LastCustomerSubject';
$Self->{'Ticket::Frontend::Overview'}->{'Small'} =  {
  'CustomerInfo' => '1',
  'Image' => 'overviewsmall.png',
  'ImageSelected' => 'overviewsmall-selected.png',
  'Module' => 'Kernel::Output::HTML::TicketOverviewSmall',
  'Name' => 'Small',
  'PageShown' => '25'
};
$Self->{'Ticket::EventModulePost'}->{'98-ArticleSearchIndex'} =  {
  'Event' => '(ArticleCreate|ArticleUpdate)',
  'Module' => 'Kernel::System::Ticket::Event::ArticleSearchIndex'
};
$Self->{'Ticket::SearchIndex::Attribute'} =  {
  'WordCountMax' => '1000',
  'WordLengthMax' => '30',
  'WordLengthMin' => '3'
};
$Self->{'Ticket::SearchIndexModule'} =  'Kernel::System::Ticket::ArticleSearchIndex::RuntimeDB';
$Self->{'Ticket::EventModulePost'}->{'99-EscalationIndex'} =  {
  'Event' => '(TicketSLAUpdate|TicketQueueUpdate|TicketStateUpdate|TicketCreate|ArticleCreate)',
  'Module' => 'Kernel::System::Ticket::Event::TicketEscalationIndex'
};
$Self->{'Ticket::EventModulePost'}->{'99-ForceUnlockOnMove'} =  {
  'Event' => 'TicketQueueUpdate',
  'Module' => 'Kernel::System::Ticket::Event::ForceUnlock'
};
$Self->{'Ticket::EventModulePost'}->{'5-NotificationEvent'} =  {
  'Event' => 'TicketQueueUpdate',
  'Module' => 'Kernel::System::Ticket::Event::NotificationEvent',
  'Transaction' => '0'
};
$Self->{'Ticket::EventModulePost'}->{'1-ResponsibleAutoSet'} =  {
  'Event' => 'TicketOwnerUpdate',
  'Module' => 'Kernel::System::Ticket::Event::ResponsibleAutoSet'
};
$Self->{'Ticket::EventModulePost'}->{'1-ForceStateChangeOnLock'} =  {
  'Event' => 'TicketLockUpdate',
  'Module' => 'Kernel::System::Ticket::Event::ForceState',
  'new' => 'in progress'
};
$Self->{'Ticket::EventModulePost'}->{'1-AcceleratorUpdate'} =  {
  'Event' => '(TicketStateUpdate|TicketQueueUpdate|TicketLockUpdate)',
  'Module' => 'Kernel::System::Ticket::Event::TicketAcceleratorUpdate'
};
$Self->{'ArticleDir'} =  '<OTRS_CONFIG_Home>/var/article';
$Self->{'Ticket::StorageModule'} =  'Kernel::System::Ticket::ArticleStorageDB';
$Self->{'Ticket::IndexModule'} =  'Kernel::System::Ticket::IndexAccelerator::RuntimeDB';
$Self->{'Ticket::CounterLog'} =  '<OTRS_CONFIG_Home>/var/log/TicketCounter.log';
$Self->{'Ticket::NumberGenerator::CheckSystemID'} =  '1';
$Self->{'Ticket::NumberGenerator::MinCounterSize'} =  '5';
$Self->{'Ticket::NumberGenerator'} =  'Kernel::System::Ticket::Number::DateChecksum';
$Self->{'TicketFreeTimeOptional6'} =  '1';
$Self->{'TicketFreeTimeKey6'} =  'Termin6';
$Self->{'TicketFreeTimeOptional5'} =  '1';
$Self->{'TicketFreeTimeKey5'} =  'Termin5';
$Self->{'TicketFreeTimeOptional3'} =  '1';
$Self->{'TicketFreeTimeKey3'} =  'Termin3';
$Self->{'TicketFreeKey16'} =  {
  'Frazionario' => 'Frazionario'
};
$Self->{'TicketFreeText15'} =  {
  '' => '-',
  'ALARM.APPLICAZIONI.MP.DEALER PORTAL' => 'ALARM.APPLICAZIONI.MP.DEALER PORTAL',
  'ALARM.APPLICAZIONI.MP.POSTEMOBILE' => 'ALARM.APPLICAZIONI.MP.POSTEMOBILE',
  'ALARM.APPLICAZIONI.POSTEMOBILE.CAMPAGNE' => 'ALARM.APPLICAZIONI.POSTEMOBILE.CAMPAGNE',
  'ALARM.APPLICAZIONI.POSTEMOBILE.CREDITO' => 'ALARM.APPLICAZIONI.POSTEMOBILE.CREDITO',
  'ALARM.APPLICAZIONI.POSTEMOBILE.EAI' => 'ALARM.APPLICAZIONI.POSTEMOBILE.EAI',
  'ALARM.APPLICAZIONI.POSTEMOBILE.PAGAMENTI' => 'ALARM.APPLICAZIONI.POSTEMOBILE.PAGAMENTI',
  'ALARM.APPLICAZIONI.POSTEMOBILE.SERVIZI DISPOSITIVI' => 'ALARM.APPLICAZIONI.POSTEMOBILE.SERVIZI DISPOSITIVI',
  'ALARM.APPLICAZIONI.POSTEMOBILE.SERVIZI INFORMATIVI' => 'ALARM.APPLICAZIONI.POSTEMOBILE.SERVIZI INFORMATIVI',
  'ALARM.APPLICAZIONI.POSTEMOBILE.VAS' => 'ALARM.APPLICAZIONI.POSTEMOBILE.VAS',
  'CANI' => 'CANI',
  'INCIDENT.SISTEMI.POSTEMOBILE.ALTRO' => 'INCIDENT.SISTEMI.POSTEMOBILE.ALTRO',
  'INCIDENT.SISTEMI.POSTEMOBILE.CRMO' => 'INCIDENT.SISTEMI.POSTEMOBILE.CRMO',
  'INCIDENT.SISTEMI.POSTEMOBILE.EXCHANGE' => 'INCIDENT.SISTEMI.POSTEMOBILE.EXCHANGE',
  'INCIDENT.SISTEMI.POSTEMOBILE.FAXSERVER' => 'INCIDENT.SISTEMI.POSTEMOBILE.FAXSERVER',
  'INCIDENT.SISTEMI.POSTEMOBILE.FLUSSI' => 'INCIDENT.SISTEMI.POSTEMOBILE.FLUSSI',
  'INCIDENT.SISTEMI.POSTEMOBILE.IAM' => 'INCIDENT.SISTEMI.POSTEMOBILE.IAM',
  'INCIDENT.SISTEMI.POSTEMOBILE.LDAP' => 'INCIDENT.SISTEMI.POSTEMOBILE.LDAP',
  'INCIDENT.SISTEMI.POSTEMOBILE.MF' => 'INCIDENT.SISTEMI.POSTEMOBILE.MF',
  'INCIDENT.SISTEMI.POSTEMOBILE.MSIP' => 'INCIDENT.SISTEMI.POSTEMOBILE.MSIP',
  'INCIDENT.SISTEMI.POSTEMOBILE.POSTECOM_BPOL' => 'INCIDENT.SISTEMI.POSTEMOBILE.POSTECOM_BPOL',
  'INCIDENT.SISTEMI.POSTEMOBILE.SAPR3' => 'INCIDENT.SISTEMI.POSTEMOBILE.SAPR3',
  'INCIDENT.SISTEMI.POSTEMOBILE.WEBMAILGED' => 'INCIDENT.SISTEMI.POSTEMOBILE.WEBMAILGED',
  'INCIDENT.SISTEMI.POSTEMOBILE.WMS' => 'INCIDENT.SISTEMI.POSTEMOBILE.WMS',
  'PIPPO' => 'PIPPO',
  'SR.RICHIESTE.POSTEMOBILE.ALTRO' => 'SR.RICHIESTE.POSTEMOBILE.ALTRO',
  'SR.RICHIESTE.POSTEMOBILE.CAMPAGNE' => 'SR.RICHIESTE.POSTEMOBILE.CAMPAGNE',
  'SR.RICHIESTE.POSTEMOBILE.POSTVENDITA' => 'SR.RICHIESTE.POSTEMOBILE.POSTVENDITA',
  'SR.RICHIESTE.POSTEMOBILE.RICARICHE' => 'SR.RICHIESTE.POSTEMOBILE.RICARICHE',
  'SR.RICHIESTE.POSTEMOBILE.VAS' => 'SR.RICHIESTE.POSTEMOBILE.VAS',
  'SR.RICHIESTE.POSTEMOBILE.VENDITA' => 'SR.RICHIESTE.POSTEMOBILE.VENDITA',
  'SR.SISTEMI.SAP.R/3 POSTEMOBILE_PIP' => 'SR.SISTEMI.SAP.R/3 POSTEMOBILE_PIP'
};
$Self->{'TicketFreeKey15'} =  {
  'PI Categoria' => 'PI Categoria'
};
$Self->{'TicketFreeKey14'} =  {
  'PI Ticket ID' => 'PI Ticket ID'
};
$Self->{'TicketFreeText13'} =  {
  'Altro' => 'Altro',
  'Anomalia SW PM' => 'Anomalia SW PM',
  'Disservizio PI' => 'Disservizio PI',
  'Disservizio PM - Altri' => 'Disservizio PM - Altri',
  'Disservizio PM - Billing' => 'Disservizio PM - Billing',
  'Disservizio PM - CRM' => 'Disservizio PM - CRM',
  'Disservizio PM - EAI' => 'Disservizio PM - EAI',
  'Disservizio PM - VAS' => 'Disservizio PM - VAS',
  'Disservizio SE' => 'Disservizio SE',
  'Disservizio VF' => 'Disservizio VF',
  'Evoluzione CR' => 'Evoluzione CR',
  'Non Di Competenza' => 'Non Di Competenza',
  'Non Ristontrato' => 'Non Riscontrato',
  'Richieste CC' => 'Richieste CC'
};
$Self->{'TicketFreeKey13'} =  {
  'SubTipo' => 'SubTipo'
};
$Self->{'TicketFreeKey9'} =  {
  'VF Ticket ID' => 'VF Ticket ID'
};
$Self->{'TicketFreeKey8'} =  {
  'Release' => 'Release'
};
$Self->{'TicketFreeKey7'} =  {
  'DEV Ticket ID' => 'DEV Ticket ID'
};
$Self->{'TicketFreeKey6'} =  {
  'SR Sub-Area' => 'SR Sub-Area'
};
$Self->{'TicketFreeKey5'} =  {
  'SR Area' => 'SR Area'
};
$Self->{'TicketFreeKey4'} =  {
  'SR Tipo' => 'SR Tipo'
};
$Self->{'TicketFreeKey3'} =  {
  'IMSI|ICCID' => 'IMSI|ICCID'
};
$Self->{'TicketFreeKey2'} =  {
  'MSISDN o CdG' => 'MSISDN o CdG'
};
$Self->{'TicketFreeText1'} =  {
  'All' => 'All',
  'Business' => 'Business',
  'Consumer' => 'Consumer'
};
$Self->{'TicketFreeKey1'} =  {
  'Marcaggio' => 'Marcaggio'
};
$Self->{'Ticket::Service'} =  '0';
$Self->{'Ticket::Type'} =  '1';
$Self->{'Ticket::ResponsibleAutoSet'} =  '0';
$Self->{'Ticket::Responsible'} =  '0';
$Self->{'Ticket::NewMessageMode'} =  'ArticleLastSender';
$Self->{'Ticket::ChangeOwnerToEveryone'} =  '0';
$Self->{'Ticket::CustomQueue'} =  'My Queues';
$Self->{'Ticket::SubjectRe'} =  'Re';
$Self->{'Ticket::SubjectSize'} =  '100';
$Self->{'Ticket::HookDivider'} =  '';
$Self->{'Ticket::Hook'} =  'Ticket#';
$Self->{'Frontend::Module'}->{'AdminSupport'} =  {
  'Description' => 'Admin-Support Overview',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block4',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Support Assessment',
    'Prio' => '2000'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Support Info'
};
$Self->{'TimeWorkingHours::Calendar11'} =  {
  'Fri' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21'
  ],
  'Mon' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21'
  ],
  'Sat' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21'
  ],
  'Sun' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21'
  ],
  'Thu' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21'
  ],
  'Tue' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21'
  ],
  'Wed' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21'
  ]
};
$Self->{'TimeZone::Calendar11'} =  '0';
$Self->{'TimeZone::Calendar11Name'} =  'Calendario PM';
$Self->{'CustomerFrontend::Module'}->{'CustomerTicketMove'} =  {
  'Description' => '
'
};
$Self->{'TimeWorkingHours::Calendar10'} =  {
  'Fri' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18'
  ],
  'Mon' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18'
  ],
  'Sat' => [],
  'Sun' => [],
  'Thu' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18'
  ],
  'Tue' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18'
  ],
  'Wed' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18'
  ]
};
$Self->{'TimeVacationDaysOneTime::Calendar10'} =  {
  '2011' => {
    '4' => {
      '25' => 'LunedÃ¬ dell Angelo 2011'
    }
  },
  '2012' => {
    '4' => {
      '9' => 'LunedÃ¬ dell Angelo 2012'
    }
  },
  '2013' => {
    '4' => {
      '1' => 'LunedÃ¬ dell Angelo 2013'
    }
  }
};
$Self->{'TimeVacationDays::Calendar10'} =  {
  '1' => {
    '1' => 'Capodanno',
    '6' => 'Epifania'
  },
  '11' => {
    '1' => 'Festa di Ognissanti'
  },
  '12' => {
    '25' => 'First Christmas Day',
    '26' => 'Santo Stefano',
    '31' => '31 dicembre ',
    '8' => 'Festa Immacolata'
  },
  '4' => {
    '25' => 'Festa della Liberazione'
  },
  '5' => {
    '1' => 'Festa dei Lavoratori'
  },
  '6' => {
    '2' => 'Festa della Repubblica'
  },
  '8' => {
    '15' => 'Ferragosto'
  }
};
$Self->{'TimeZone::Calendar10'} =  '0';
$Self->{'TimeZone::Calendar10Name'} =  'Calendario PB';
$Self->{'NotificationSenderEmail'} =  'otrssystem_dev@operations.postemobile.it';
$Self->{'DashboardBackend'}->{'0410-RSS'} =  {
  'Block' => 'ContentSmall',
  'CacheTTL' => '360',
  'Default' => '1',
  'Description' => '',
  'Group' => '',
  'Limit' => '5',
  'Module' => 'Kernel::Output::HTML::DashboardRSS',
  'Title' => 'OTRS News',
  'URL' => 'http://otrs.org/rss/'
};
$Self->{'DashboardBackend'}->{'0400-UserOnline'} =  {
  'Block' => 'ContentSmall',
  'CacheTTLLocal' => '5',
  'Default' => '0',
  'Description' => '',
  'Filter' => 'Agent',
  'Group' => '',
  'IdleMinutes' => '60',
  'Limit' => '10',
  'Module' => 'Kernel::Output::HTML::DashboardUserOnline',
  'ShowEmail' => '1',
  'SortBy' => 'UserLastname',
  'Title' => 'Online'
};
$Self->{'DashboardBackend'}->{'0000-ProductNotify'} =  {
  'Block' => 'ContentLarge',
  'CacheTTLLocal' => '1440',
  'Default' => '1',
  'Description' => 'News about OTRS releases!',
  'Group' => 'admin',
  'Module' => 'Kernel::Output::HTML::DashboardProductNotify',
  'Title' => 'Product News',
  'URL' => 'http://otrs.org/product.xml'
};
$Self->{'Stats::CustomerIDAsMultiSelect'} =  '1';
$Self->{'Stats::TimeType'} =  'Extended';
$Self->{'Stats::Graph::legend_marker_height'} =  '8';
$Self->{'Stats::Graph::legend_marker_width'} =  '12';
$Self->{'Stats::Graph::legend_spacing'} =  '4';
$Self->{'Stats::Graph::legend_placement'} =  'BC';
$Self->{'Stats::Graph::line_width'} =  '1';
$Self->{'Stats::Graph::dclrs'} =  [
  'red',
  'green',
  'blue',
  'yellow',
  'black',
  'purple',
  'orange',
  'pink',
  'marine',
  'cyan',
  'light gray',
  'light blue',
  'light yellow',
  'light green',
  'light red',
  'light purple',
  'light orange',
  'light brown'
];
$Self->{'Stats::Graph::textclr'} =  'black';
$Self->{'Stats::Graph::legendclr'} =  'black';
$Self->{'Stats::Graph::accentclr'} =  'black';
$Self->{'Stats::Graph::boxclr'} =  'white';
$Self->{'Stats::Graph::fgclr'} =  'black';
$Self->{'Stats::Graph::transparent'} =  '0';
$Self->{'Stats::Graph::bgclr'} =  'white';
$Self->{'Stats::Graph::r_margin'} =  '20';
$Self->{'Stats::Graph::b_margin'} =  '10';
$Self->{'Stats::Graph::l_margin'} =  '10';
$Self->{'Stats::Graph::t_margin'} =  '10';
$Self->{'Stats::GraphSize'} =  {
  '1200x800' => '1200x800',
  '1600x1200' => '1600x1200',
  '800x600' => '800x600'
};
$Self->{'Stats::Format'} =  {
  'CSV' => 'CSV',
  'GD::Graph::area' => 'graph-area',
  'GD::Graph::bars' => 'graph-bars',
  'GD::Graph::hbars' => 'graph-hbars',
  'GD::Graph::lines' => 'graph-lines',
  'GD::Graph::linespoints' => 'graph-lines-points',
  'GD::Graph::pie' => 'graph-pie',
  'GD::Graph::points' => 'graph-points',
  'Print' => 'Print'
};
$Self->{'Stats::SearchLimit'} =  '500';
$Self->{'Stats::DefaultSelectedFormat'} =  [
  'Print',
  'CSV'
];
$Self->{'Stats::DefaultSelectedPermissions'} =  [
  'stats'
];
$Self->{'Stats::DefaultSelectedDynamicObject'} =  'Ticket';
$Self->{'Stats::SearchPageShown'} =  '20';
$Self->{'Stats::StatsStartNumber'} =  '10000';
$Self->{'Stats::StatsHook'} =  'Stat#';
$Self->{'Frontend::Module'}->{'AgentStats'} =  {
  'Description' => 'Stats',
  'Group' => [
    'stats'
  ],
  'GroupRo' => [
    'stats'
  ],
  'NavBar' => [
    {
      'AccessKey' => '',
      'Block' => 'ItemArea',
      'Description' => 'Stats',
      'Image' => 'stats.png',
      'Link' => 'Action=AgentStats&Subaction=Overview',
      'Name' => 'Stats',
      'NavBar' => 'Stats',
      'Prio' => '8500',
      'Type' => 'Menu'
    },
    {
      'AccessKey' => '',
      'Block' => '',
      'Description' => 'Overview',
      'GroupRo' => [
        'stats'
      ],
      'Image' => 'overview.png',
      'Link' => 'Action=AgentStats&Subaction=Overview',
      'Name' => 'Overview',
      'NavBar' => 'Stats',
      'Prio' => '100',
      'Type' => ''
    },
    {
      'AccessKey' => '',
      'Block' => '',
      'Description' => 'New',
      'Group' => [
        'stats'
      ],
      'Image' => 'new.png',
      'Link' => 'Action=AgentStats&Subaction=Add',
      'Name' => 'New',
      'NavBar' => 'Stats',
      'Prio' => '200',
      'Type' => ''
    },
    {
      'AccessKey' => '',
      'Block' => '',
      'Description' => 'Import',
      'Group' => [
        'stats'
      ],
      'Image' => 'import.png',
      'Link' => 'Action=AgentStats&Subaction=Import',
      'Name' => 'Import',
      'NavBar' => 'Stats',
      'Prio' => '300',
      'Type' => ''
    }
  ],
  'NavBarName' => 'Stats',
  'Title' => 'Stats'
};
$Self->{'PublicFrontend::Module'}->{'PublicRepository'} =  {
  'Description' => 'PublicRepository',
  'NavBarName' => '',
  'Title' => 'PublicRepository'
};
$Self->{'PublicFrontend::Module'}->{'PublicDefault'} =  {
  'Description' => 'PublicDefault',
  'NavBarName' => '',
  'Title' => 'PublicDefault'
};
$Self->{'PublicFrontend::CommonParam'}->{'Action'} =  'PublicDefault';
$Self->{'Frontend::NavBarStyle::ShowSelectedArea'} =  '1';
$Self->{'Frontend::NavBarStyle'} =  'Modern';
$Self->{'CustomerFrontend::Module'}->{'SpellingInline'} =  {
  'Description' => 'Spell checker',
  'NavBarName' => '',
  'Title' => 'Spell Checker'
};
$Self->{'CustomerFrontend::Module'}->{'PictureUpload'} =  {
  'Description' => 'Picture upload module',
  'NavBarName' => 'Ticket',
  'Title' => 'Picture-Upload'
};
$Self->{'CustomerFrontend::Module'}->{'CustomerAccept'} =  {
  'Description' => 'To accept login infos',
  'NavBarName' => '',
  'Title' => 'Info'
};
$Self->{'CustomerFrontend::Module'}->{'CustomerCalendarSmall'} =  {
  'Description' => 'Small calendar for date selection.',
  'NavBarName' => '',
  'Title' => 'Calendar'
};
$Self->{'CustomerFrontend::Module'}->{'CustomerPreferences'} =  {
  'Description' => 'Customer preferences',
  'NavBar' => [
    {
      'AccessKey' => 'p',
      'Block' => '',
      'Description' => 'Preferences',
      'Image' => 'prefer.png',
      'Link' => 'Action=CustomerPreferences',
      'Name' => 'Preferences',
      'NavBar' => '',
      'Prio' => '1000',
      'Type' => ''
    }
  ],
  'NavBarName' => '',
  'Title' => 'Preferences'
};
$Self->{'CustomerFrontend::Module'}->{'Logout'} =  {
  'Description' => 'Logout of customer panel',
  'NavBar' => [
    {
      'AccessKey' => 'l',
      'Block' => '',
      'Description' => 'Logout',
      'Image' => 'exit.png',
      'Link' => 'Action=Logout',
      'Name' => 'Logout',
      'NavBar' => '',
      'Prio' => '10',
      'Type' => ''
    }
  ],
  'NavBarName' => '',
  'Title' => ''
};
$Self->{'Frontend::Module'}->{'AdminPackageManager'} =  {
  'Description' => 'Software Package Manager',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block4',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Package Manager',
    'Prio' => '1000'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Package Manager'
};
$Self->{'Frontend::Module'}->{'AdminSelectBox'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block4',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'SQL Box',
    'Prio' => '700'
  },
  'NavBarName' => 'Admin',
  'Title' => 'SQL Box'
};
$Self->{'Frontend::Module'}->{'AdminLog'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block4',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'System Log',
    'Prio' => '600'
  },
  'NavBarName' => 'Admin',
  'Title' => 'System Log'
};
$Self->{'Frontend::Module'}->{'AdminPerformanceLog'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block4',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Performance Log',
    'Prio' => '550'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Performance Log'
};
$Self->{'Frontend::Module'}->{'AdminSession'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block4',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Session Management',
    'Prio' => '500'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Session Management'
};
$Self->{'Frontend::Module'}->{'AdminEmail'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block4',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Admin Notification',
    'Prio' => '400'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Admin-Email'
};
$Self->{'Frontend::Module'}->{'AdminPostMasterFilter'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block4',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'PostMaster Filter',
    'Prio' => '200'
  },
  'NavBarName' => 'Admin',
  'Title' => 'PostMaster Filter'
};
$Self->{'Frontend::Module'}->{'AdminMailAccount'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block4',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'PostMaster Mail Account',
    'Prio' => '100'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Mail Account'
};
$Self->{'Frontend::Module'}->{'AdminPGP'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block3',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'PGP',
    'Prio' => '1200'
  },
  'NavBarName' => 'Admin',
  'Title' => 'PGP Key Management'
};
$Self->{'Frontend::Module'}->{'AdminSMIME'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block3',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'S/MIME',
    'Prio' => '1100'
  },
  'NavBarName' => 'Admin',
  'Title' => 'S/MIME Management'
};
$Self->{'Frontend::Module'}->{'AdminRoleGroup'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block1',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Roles <-> Groups',
    'Prio' => '800'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Roles <-> Groups'
};
$Self->{'Frontend::Module'}->{'AdminRoleUser'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block1',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Roles <-> Users',
    'Prio' => '700'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Roles <-> Users'
};
$Self->{'Frontend::Module'}->{'AdminRole'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block1',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Roles',
    'Prio' => '600'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Role'
};
$Self->{'Frontend::Module'}->{'AdminCustomerUserService'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block1',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Customer Users <-> Services',
    'Prio' => '500'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Customer Users <-> Services'
};
$Self->{'Frontend::Module'}->{'AdminCustomerUserGroup'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block1',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Customer Users <-> Groups',
    'Prio' => '400'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Customer Users <-> Groups'
};
$Self->{'Frontend::NavBarModule'}->{'6-CustomerCompany'} =  {
  'Module' => 'Kernel::Output::HTML::NavBarCustomerCompany'
};
$Self->{'Frontend::Module'}->{'AdminCustomerCompany'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin',
    'users'
  ],
  'GroupRo' => [
    ''
  ],
  'NavBar' => [
    {
      'AccessKey' => 'c',
      'Block' => 'ItemArea',
      'Description' => 'Edit Customer Company',
      'Image' => 'folder_yellow.png',
      'Link' => 'Action=AdminCustomerCompany&Nav=Agent',
      'Name' => 'Company',
      'NavBar' => 'Ticket',
      'Prio' => '9100',
      'Type' => 'Menu'
    }
  ],
  'NavBarModule' => {
    'Block' => 'Block1',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Customer Company',
    'Prio' => '310'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Customer Company'
};
$Self->{'Frontend::Module'}->{'AdminCustomerUser'} =  {
  'Description' => 'Edit Customer Users',
  'Group' => [
    'admin',
    'users'
  ],
  'GroupRo' => [
    ''
  ],
  'NavBar' => [
    {
      'AccessKey' => 'c',
      'Block' => 'ItemArea',
      'Description' => 'Edit Customer Users',
      'Image' => 'folder_yellow.png',
      'Link' => 'Action=AdminCustomerUser&Nav=Agent',
      'Name' => 'Customer',
      'NavBar' => 'Customer',
      'Prio' => '9000',
      'Type' => 'Menu'
    }
  ],
  'NavBarModule' => {
    'Block' => 'Block1',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Customer Users',
    'Prio' => '300'
  },
  'NavBarName' => 'Customer',
  'Title' => 'Customer User'
};
$Self->{'Frontend::Module'}->{'AdminUserGroup'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block1',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Users <-> Groups',
    'Prio' => '200'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Users <-> Groups'
};
$Self->{'Frontend::Module'}->{'AdminGroup'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block1',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Groups',
    'Prio' => '150'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Group'
};
$Self->{'Frontend::Module'}->{'AdminUser'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarModule' => {
    'Block' => 'Block1',
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin',
    'Name' => 'Users',
    'Prio' => '100'
  },
  'NavBarName' => 'Admin',
  'Title' => 'User'
};
$Self->{'Frontend::Module'}->{'AdminInit'} =  {
  'Description' => 'Admin',
  'Group' => [
    'admin'
  ],
  'NavBarName' => '',
  'Title' => 'Init'
};
$Self->{'Frontend::Module'}->{'Admin'} =  {
  'Description' => 'Admin-Area',
  'Group' => [
    'admin'
  ],
  'NavBar' => [
    {
      'AccessKey' => 'a',
      'Block' => 'ItemArea',
      'Description' => 'Admin-Area',
      'Image' => 'admin.png',
      'Link' => 'Action=Admin',
      'Name' => 'Admin',
      'NavBar' => 'Admin',
      'Prio' => '10000',
      'Type' => 'Menu'
    }
  ],
  'NavBarModule' => {
    'Module' => 'Kernel::Output::HTML::NavBarModuleAdmin'
  },
  'NavBarName' => 'Admin',
  'Title' => 'Admin'
};
$Self->{'Frontend::Module'}->{'AgentCalendarSmall'} =  {
  'Description' => 'Small calendar for date selection.',
  'NavBarName' => '',
  'Title' => 'Calendar'
};
$Self->{'Frontend::Module'}->{'AgentInfo'} =  {
  'Description' => 'Generic Info module',
  'NavBarName' => '',
  'Title' => 'Info'
};
$Self->{'Frontend::Module'}->{'AgentLinkObject'} =  {
  'Description' => 'Link Object',
  'NavBarName' => '',
  'Title' => 'Link Object'
};
$Self->{'Frontend::Module'}->{'AgentLookup'} =  {
  'Description' => 'Data table lookup module.',
  'NavBarName' => '',
  'Title' => 'Lookup'
};
$Self->{'Frontend::Module'}->{'AgentBook'} =  {
  'Description' => 'Address book of CustomerUser sources',
  'NavBarName' => '',
  'Title' => 'Address Book'
};
$Self->{'Frontend::Module'}->{'SpellingInline'} =  {
  'Description' => 'Spell checker',
  'NavBarName' => '',
  'Title' => 'Spell Checker'
};
$Self->{'Frontend::Module'}->{'AgentSpelling'} =  {
  'Description' => 'Spell checker',
  'NavBarName' => '',
  'Title' => 'Spell Checker'
};
$Self->{'Frontend::Module'}->{'PictureUpload'} =  {
  'Description' => 'Picture upload module',
  'NavBarName' => 'Ticket',
  'Title' => 'Picture-Upload'
};
$Self->{'Frontend::Module'}->{'AgentPreferences'} =  {
  'Description' => 'Agent Preferences',
  'NavBar' => [
    {
      'AccessKey' => 'p',
      'Block' => 'ItemArea',
      'Description' => 'Agent Preferences',
      'Image' => 'prefer.png',
      'Link' => 'Action=AgentPreferences',
      'Name' => 'Preferences',
      'NavBar' => 'Preferences',
      'Prio' => '9900',
      'Type' => 'Menu'
    }
  ],
  'NavBarName' => 'Preferences',
  'Title' => ''
};
$Self->{'Frontend::Module'}->{'AgentDashboard'} =  {
  'Description' => 'Agent Dashboard',
  'NavBar' => [
    {
      'AccessKey' => 'd',
      'Block' => 'ItemArea',
      'Description' => 'Agent Dashboard',
      'Image' => 'dashboard.png',
      'Link' => 'Action=AgentDashboard',
      'Name' => 'Dashboard',
      'NavBar' => 'Dashboard',
      'Prio' => '50',
      'Type' => 'Menu'
    }
  ],
  'NavBarName' => 'Dashboard',
  'Title' => ''
};
$Self->{'Frontend::Module'}->{'Logout'} =  {
  'Description' => 'Logout',
  'NavBar' => [
    {
      'AccessKey' => 'l',
      'Block' => 'ItemPre',
      'Description' => 'Logout',
      'Image' => 'exit.png',
      'Link' => 'Action=Logout',
      'Name' => 'Logout',
      'NavBar' => '',
      'Prio' => '100',
      'Type' => ''
    }
  ],
  'NavBarName' => '',
  'Title' => ''
};
$Self->{'CustomerPreferencesGroups'}->{'SMIME'} =  {
  'Activ' => '1',
  'Colum' => 'Other Options',
  'Desc' => 'S/MIME Certificate Upload',
  'Label' => 'S/MIME Certificate',
  'Module' => 'Kernel::Output::HTML::PreferencesSMIME',
  'PrefKey' => 'UserSMIMEKey',
  'Prio' => '11000'
};
$Self->{'CustomerPreferencesGroups'}->{'PGP'} =  {
  'Activ' => '1',
  'Colum' => 'Other Options',
  'Desc' => 'PGP Key Upload',
  'Label' => 'PGP Key',
  'Module' => 'Kernel::Output::HTML::PreferencesPGP',
  'PrefKey' => 'UserPGPKey',
  'Prio' => '10000'
};
$Self->{'CustomerPreferencesGroups'}->{'Theme'} =  {
  'Activ' => '0',
  'Colum' => 'Frontend',
  'Desc' => 'Select your frontend Theme.',
  'Label' => 'Theme',
  'Module' => 'Kernel::Output::HTML::PreferencesTheme',
  'PrefKey' => 'UserTheme',
  'Prio' => '1000'
};
$Self->{'CustomerPreferencesGroups'}->{'Language'} =  {
  'Activ' => '1',
  'Colum' => 'Frontend',
  'Desc' => 'Select your frontend language.',
  'Label' => 'Language',
  'Module' => 'Kernel::Output::HTML::PreferencesLanguage',
  'PrefKey' => 'UserLanguage',
  'Prio' => '2000'
};
$Self->{'CustomerPreferencesGroups'}->{'Password'} =  {
  'Activ' => '1',
  'Area' => 'Customer',
  'Colum' => 'Other Options',
  'Label' => 'Change Password',
  'Module' => 'Kernel::Output::HTML::PreferencesPassword',
  'PasswordMin2Characters' => '0',
  'PasswordMin2Lower2UpperCharacters' => '0',
  'PasswordMinSize' => '0',
  'PasswordNeedDigit' => '0',
  'PasswordRegExp' => '',
  'Prio' => '1000'
};
$Self->{'CustomerPreferencesView'} =  [
  'Frontend',
  'Other Options'
];
$Self->{'CustomerPreferences'} =  {
  'Module' => 'Kernel::System::CustomerUser::Preferences::DB',
  'Params' => {
    'Table' => 'customer_preferences',
    'TableKey' => 'preferences_key',
    'TableUserID' => 'user_id',
    'TableValue' => 'preferences_value'
  }
};
$Self->{'Customer::AuthModule::Radius::Die'} =  '1';
$Self->{'Customer::AuthModule::LDAP::Die'} =  '1';
$Self->{'Customer::AuthModule::DB::CustomerPassword'} =  'pw';
$Self->{'Customer::AuthModule::DB::CustomerKey'} =  'login';
$Self->{'Customer::AuthModule::DB::Table'} =  'customer_user';
$Self->{'Customer::AuthModule::DB::CryptType'} =  'md5';
$Self->{'Customer::AuthModule'} =  'Kernel::System::CustomerAuth::DB';
$Self->{'CustomerPanelBodyNewAccount'} =  'Hi <OTRS_USERFIRSTNAME>,

you or someone impersonating you has created a new OTRS account for
you (<OTRS_USERFIRSTNAME> <OTRS_USERLASTNAME>).

Login: <OTRS_USERLOGIN>
Password: <OTRS_USERPASSWORD>

<OTRS_CONFIG_HttpType>://<OTRS_CONFIG_FQDN>/<OTRS_CONFIG_ScriptAlias>customer.pl

Your OTRS Notification Master
            ';
$Self->{'CustomerPanelSubjectNewAccount'} =  'New OTRS Account!';
$Self->{'CustomerPanelBodyLostPassword'} =  'Hi <OTRS_USERFIRSTNAME>,

you or someone impersonating you has requested to change your OTRS
password.

New Password: <OTRS_NEWPW>

<OTRS_CONFIG_HttpType>://<OTRS_CONFIG_FQDN>/<OTRS_CONFIG_ScriptAlias>customer.pl

Your OTRS Notification Master
            ';
$Self->{'CustomerPanelSubjectLostPassword'} =  'New OTRS Password!';
$Self->{'CustomerPanelBodyLostPasswordToken'} =  'Hi <OTRS_USERFIRSTNAME>,

you or someone impersonating you has requested to change your OTRS
password.

If you want to do this, click on this link to get a new password.

<OTRS_CONFIG_HttpType>://<OTRS_CONFIG_FQDN>/<OTRS_CONFIG_ScriptAlias>customer.pl?Action=CustomerLostPassword&Token=<OTRS_TOKEN>

Your OTRS Notification Master
            ';
$Self->{'CustomerPanelSubjectLostPasswordToken'} =  'New OTRS Password request!';
$Self->{'CustomerPanelCreateAccount'} =  '1';
$Self->{'CustomerPanelLostPassword'} =  '1';
$Self->{'Frontend::CustomerUser::Item'}->{'1-GoogleMaps'} =  {
  'Attributes' => 'UserStreet;UserCity;UserCountry;',
  'Image' => 'maps.png',
  'Module' => 'Kernel::Output::HTML::CustomerUserGeneric',
  'Required' => 'UserStreet;UserCity;',
  'Target' => '_blank',
  'Text' => 'Location',
  'URL' => 'http://maps.google.com/maps?z=7&q='
};
$Self->{'CustomerFrontend::HeaderMetaModule'}->{'1-Refresh'} =  {
  'Module' => 'Kernel::Output::HTML::HeaderMetaRefresh'
};
$Self->{'CustomerGroupAlwaysGroups'} =  [
  'users',
  'info'
];
$Self->{'CustomerGroupSupport'} =  '0';
$Self->{'CustomerPanelUserID'} =  '1';
$Self->{'CustomerPanelSessionName'} =  'CSID';
$Self->{'PreferencesGroups'}->{'OutOfOffice'} =  {
  'Activ' => '1',
  'Block' => 'OutOfOffice',
  'Colum' => 'Other Options',
  'Desc' => 'Select your out of office time.',
  'Label' => 'Out Of Office',
  'Module' => 'Kernel::Output::HTML::PreferencesOutOfOffice',
  'PrefKey' => 'UserOutOfOffice',
  'Prio' => '4000'
};
$Self->{'PreferencesGroups'}->{'TimeZone'} =  {
  'Activ' => '1',
  'Colum' => 'Frontend',
  'Desc' => 'Select your Time-Zone.',
  'Label' => 'Time-Zone',
  'Module' => 'Kernel::Output::HTML::PreferencesTimeZone',
  'PrefKey' => 'UserTimeZone',
  'Prio' => '3000'
};
$Self->{'PreferencesGroups'}->{'Theme'} =  {
  'Activ' => '1',
  'Colum' => 'Frontend',
  'Desc' => 'Select your frontend Theme.',
  'Label' => 'Theme',
  'Module' => 'Kernel::Output::HTML::PreferencesTheme',
  'PrefKey' => 'UserTheme',
  'Prio' => '2000'
};
$Self->{'PreferencesGroups'}->{'Language'} =  {
  'Activ' => '1',
  'Colum' => 'Frontend',
  'Desc' => 'Select your frontend language.',
  'Label' => 'Language',
  'Module' => 'Kernel::Output::HTML::PreferencesLanguage',
  'PrefKey' => 'UserLanguage',
  'Prio' => '1000'
};
$Self->{'PreferencesGroups'}->{'Comment'} =  {
  'Activ' => '0',
  'Block' => 'Input',
  'Colum' => 'Other Options',
  'Data' => '$Env{"UserComment"}',
  'Desc' => 'Comment',
  'Label' => 'Comment',
  'Module' => 'Kernel::Output::HTML::PreferencesGeneric',
  'PrefKey' => 'UserComment',
  'Prio' => '6000'
};
$Self->{'PreferencesGroups'}->{'SpellDict'} =  {
  'Activ' => '1',
  'Colum' => 'Other Options',
  'Data' => {
    'deutsch' => 'Deutsch',
    'english' => 'English'
  },
  'DataSelected' => 'english',
  'Desc' => 'Select your default spelling dictionary.',
  'Label' => 'Spelling Dictionary',
  'Module' => 'Kernel::Output::HTML::PreferencesGeneric',
  'PrefKey' => 'UserSpellDict',
  'Prio' => '5000'
};
$Self->{'PreferencesGroups'}->{'Password'} =  {
  'Activ' => '1',
  'Area' => 'Agent',
  'Colum' => 'Other Options',
  'Label' => 'Change Password',
  'Module' => 'Kernel::Output::HTML::PreferencesPassword',
  'PasswordMaxLoginFailed' => '0',
  'PasswordMin2Characters' => '0',
  'PasswordMin2Lower2UpperCharacters' => '0',
  'PasswordMinSize' => '0',
  'PasswordNeedDigit' => '0',
  'PasswordRegExp' => '',
  'Prio' => '1000'
};
$Self->{'PreferencesView'} =  [
  'Frontend',
  'Mail Management',
  'Other Options'
];
$Self->{'PreferencesTableUserID'} =  'user_id';
$Self->{'PreferencesTableValue'} =  'preferences_value';
$Self->{'PreferencesTableKey'} =  'preferences_key';
$Self->{'PreferencesTable'} =  'user_preferences';
$Self->{'PerformanceLog::FileMax'} =  '25';
$Self->{'PerformanceLog::File'} =  '<OTRS_CONFIG_Home>/var/log/Performance.log';
$Self->{'PerformanceLog'} =  '0';
$Self->{'System::Customer::Permission'} =  [
  'ro',
  'rw'
];
$Self->{'NotificationBodyLostPassword'} =  'Hi <OTRS_USERFIRSTNAME>,

you or someone impersonating you has requested to change your OTRS
password.

New Password: <OTRS_NEWPW>

<OTRS_CONFIG_HttpType>://<OTRS_CONFIG_FQDN>/<OTRS_CONFIG_ScriptAlias>index.pl

Your OTRS Notification Master
            ';
$Self->{'NotificationSubjectLostPassword'} =  'New OTRS Password!';
$Self->{'NotificationBodyLostPasswordToken'} =  'Hi <OTRS_USERFIRSTNAME>,

you or someone impersonating you has requested to change your OTRS
password.

If you want to do this, click on this link to get a new password.

<OTRS_CONFIG_HttpType>://<OTRS_CONFIG_FQDN>/<OTRS_CONFIG_ScriptAlias>index.pl?Action=LostPassword&Token=<OTRS_TOKEN>

Your OTRS Notification Master
            ';
$Self->{'NotificationSubjectLostPasswordToken'} =  'New OTRS Password request!';
$Self->{'NotificationSenderName'} =  'OTRS Notification Master';
$Self->{'SMIME::PrivatePath'} =  '/etc/ssl/private';
$Self->{'SMIME::CertPath'} =  '/etc/ssl/certs';
$Self->{'SMIME::Bin'} =  '/usr/bin/openssl';
$Self->{'SMIME'} =  '0';
$Self->{'PGP::Key::Password'} =  {
  '488A0B8F' => 'SomePassword',
  'D2DF79FA' => 'SomePassword'
};
$Self->{'PGP::Options'} =  '--homedir /opt/otrs/.gnupg/ --batch --no-tty --yes';
$Self->{'PGP::Bin'} =  '/usr/bin/gpg';
$Self->{'PGP'} =  '0';
$Self->{'PDF::TTFontFile'}->{'Monospaced'} =  'DejaVuSansMono.ttf';
$Self->{'PDF::TTFontFile'}->{'ProportionalBoldItalic'} =  'DejaVuSans-BoldOblique.ttf';
$Self->{'PDF::TTFontFile'}->{'ProportionalBold'} =  'DejaVuSans-Bold.ttf';
$Self->{'PDF::TTFontFile'}->{'Proportional'} =  'DejaVuSans.ttf';
$Self->{'PDF::MaxPages'} =  '100';
$Self->{'PDF::PageSize'} =  'a4';
$Self->{'PDF::LogoFile'} =  '<OTRS_CONFIG_Home>/var/logo-otrs.png';
$Self->{'PDF'} =  '1';
$Self->{'Package::Timeout'} =  '15';
$Self->{'Package::RepositoryRoot'} =  [
  'http://ftp.otrs.org/pub/otrs/misc/packages/repository.xml',
  'http://otrs.org/repository.xml'
];
$Self->{'Package::FileUpload'} =  '1';
$Self->{'WebUserAgent::Timeout'} =  '15';
$Self->{'SpellCheckerIgnore'} =  [
  'www',
  'webmail',
  'https',
  'http',
  'html',
  'rfc'
];
$Self->{'SpellCheckerDictDefault'} =  'english';
$Self->{'SpellCheckerBin'} =  '/usr/bin/ispell';
$Self->{'SpellChecker'} =  '1';
$Self->{'SwitchToUser'} =  '0';
$Self->{'DemoSystem'} =  '0';
$Self->{'ShowMotd'} =  '0';
$Self->{'LostPassword'} =  '1';
$Self->{'Frontend::Output::FilterText'}->{'AAAURL'} =  {
  'Module' => 'Kernel::Output::HTML::OutputFilterTextURL'
};
$Self->{'CGILogPrefix'} =  'OTRS-CGI';
$Self->{'WebUploadCacheModule'} =  'Kernel::System::Web::UploadCache::DB';
$Self->{'WebMaxFileUpload'} =  '16777216';
$Self->{'TimeWorkingHours::Calendar9'} =  {
  'Fri' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Mon' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Sat' => [],
  'Sun' => [],
  'Thu' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Tue' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Wed' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ]
};
$Self->{'TimeVacationDaysOneTime::Calendar9'} =  {
  '2004' => {
    '1' => {
      '1' => 'test'
    }
  }
};
$Self->{'TimeVacationDays::Calendar9'} =  {
  '1' => {
    '1' => 'New Year\'s Day'
  },
  '12' => {
    '24' => 'Christmas Eve',
    '25' => 'First Christmas Day',
    '26' => 'Second Christmas Day',
    '31' => 'New Year\'s Eve'
  },
  '5' => {
    '1' => 'International Workers\' Day'
  }
};
$Self->{'TimeZone::Calendar9'} =  '0';
$Self->{'TimeZone::Calendar9Name'} =  'Calendar Name 9';
$Self->{'TimeWorkingHours::Calendar8'} =  {
  'Fri' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Mon' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Sat' => [],
  'Sun' => [],
  'Thu' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Tue' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Wed' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ]
};
$Self->{'TimeVacationDaysOneTime::Calendar8'} =  {
  '2004' => {
    '1' => {
      '1' => 'test'
    }
  }
};
$Self->{'TimeVacationDays::Calendar8'} =  {
  '1' => {
    '1' => 'New Year\'s Day'
  },
  '12' => {
    '24' => 'Christmas Eve',
    '25' => 'First Christmas Day',
    '26' => 'Second Christmas Day',
    '31' => 'New Year\'s Eve'
  },
  '5' => {
    '1' => 'International Workers\' Day'
  }
};
$Self->{'TimeZone::Calendar8'} =  '0';
$Self->{'TimeZone::Calendar8Name'} =  'Calendar Name 8';
$Self->{'TimeWorkingHours::Calendar7'} =  {
  'Fri' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Mon' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Sat' => [],
  'Sun' => [],
  'Thu' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Tue' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Wed' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ]
};
$Self->{'TimeVacationDaysOneTime::Calendar7'} =  {
  '2004' => {
    '1' => {
      '1' => 'test'
    }
  }
};
$Self->{'TimeVacationDays::Calendar7'} =  {
  '1' => {
    '1' => 'New Year\'s Day'
  },
  '12' => {
    '24' => 'Christmas Eve',
    '25' => 'First Christmas Day',
    '26' => 'Second Christmas Day',
    '31' => 'New Year\'s Eve'
  },
  '5' => {
    '1' => 'International Workers\' Day'
  }
};
$Self->{'TimeZone::Calendar7'} =  '0';
$Self->{'TimeZone::Calendar7Name'} =  'Calendar Name 7';
$Self->{'TimeWorkingHours::Calendar6'} =  {
  'Fri' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Mon' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Sat' => [],
  'Sun' => [],
  'Thu' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Tue' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Wed' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ]
};
$Self->{'TimeVacationDaysOneTime::Calendar6'} =  {
  '2004' => {
    '1' => {
      '1' => 'test'
    }
  }
};
$Self->{'TimeVacationDays::Calendar6'} =  {
  '1' => {
    '1' => 'New Year\'s Day'
  },
  '12' => {
    '24' => 'Christmas Eve',
    '25' => 'First Christmas Day',
    '26' => 'Second Christmas Day',
    '31' => 'New Year\'s Eve'
  },
  '5' => {
    '1' => 'International Workers\' Day'
  }
};
$Self->{'TimeZone::Calendar6'} =  '0';
$Self->{'TimeZone::Calendar6Name'} =  'Calendar Name 6';
$Self->{'TimeWorkingHours::Calendar5'} =  {
  'Fri' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Mon' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Sat' => [],
  'Sun' => [],
  'Thu' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Tue' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Wed' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ]
};
$Self->{'TimeVacationDaysOneTime::Calendar5'} =  {
  '2004' => {
    '1' => {
      '1' => 'test'
    }
  }
};
$Self->{'TimeVacationDays::Calendar5'} =  {
  '1' => {
    '1' => 'New Year\'s Day'
  },
  '12' => {
    '24' => 'Christmas Eve',
    '25' => 'First Christmas Day',
    '26' => 'Second Christmas Day',
    '31' => 'New Year\'s Eve'
  },
  '5' => {
    '1' => 'International Workers\' Day'
  }
};
$Self->{'TimeZone::Calendar5'} =  '0';
$Self->{'TimeZone::Calendar5Name'} =  'Calendar Name 5';
$Self->{'TimeWorkingHours::Calendar4'} =  {
  'Fri' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Mon' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Sat' => [],
  'Sun' => [],
  'Thu' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Tue' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Wed' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ]
};
$Self->{'TimeVacationDaysOneTime::Calendar4'} =  {
  '2004' => {
    '1' => {
      '1' => 'test'
    }
  }
};
$Self->{'TimeVacationDays::Calendar4'} =  {
  '1' => {
    '1' => 'New Year\'s Day'
  },
  '12' => {
    '24' => 'Christmas Eve',
    '25' => 'First Christmas Day',
    '26' => 'Second Christmas Day',
    '31' => 'New Year\'s Eve'
  },
  '5' => {
    '1' => 'International Workers\' Day'
  }
};
$Self->{'TimeZone::Calendar4'} =  '0';
$Self->{'TimeZone::Calendar4Name'} =  'Calendar Name 4';
$Self->{'TimeWorkingHours::Calendar3'} =  {
  'Fri' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Mon' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Sat' => [],
  'Sun' => [],
  'Thu' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Tue' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Wed' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ]
};
$Self->{'TimeVacationDaysOneTime::Calendar3'} =  {
  '2004' => {
    '1' => {
      '1' => 'test'
    }
  }
};
$Self->{'TimeVacationDays::Calendar3'} =  {
  '1' => {
    '1' => 'New Year\'s Day'
  },
  '12' => {
    '24' => 'Christmas Eve',
    '25' => 'First Christmas Day',
    '26' => 'Second Christmas Day',
    '31' => 'New Year\'s Eve'
  },
  '5' => {
    '1' => 'International Workers\' Day'
  }
};
$Self->{'TimeZone::Calendar3'} =  '0';
$Self->{'TimeZone::Calendar3Name'} =  'Calendar Name 3';
$Self->{'TimeWorkingHours::Calendar2'} =  {
  'Fri' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Mon' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Sat' => [],
  'Sun' => [],
  'Thu' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Tue' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Wed' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ]
};
$Self->{'TimeVacationDaysOneTime::Calendar2'} =  {
  '2004' => {
    '1' => {
      '1' => 'test'
    }
  }
};
$Self->{'TimeVacationDays::Calendar2'} =  {
  '1' => {
    '1' => 'New Year\'s Day'
  },
  '12' => {
    '24' => 'Christmas Eve',
    '25' => 'First Christmas Day',
    '26' => 'Second Christmas Day',
    '31' => 'New Year\'s Eve'
  },
  '5' => {
    '1' => 'International Workers\' Day'
  }
};
$Self->{'TimeZone::Calendar2'} =  '0';
$Self->{'TimeZone::Calendar2Name'} =  'Calendar Name 2';
$Self->{'TimeWorkingHours::Calendar1'} =  {
  'Fri' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Mon' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Sat' => [],
  'Sun' => [],
  'Thu' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Tue' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Wed' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ]
};
$Self->{'TimeVacationDaysOneTime::Calendar1'} =  {
  '2004' => {
    '1' => {
      '1' => 'test'
    }
  }
};
$Self->{'TimeVacationDays::Calendar1'} =  {
  '1' => {
    '1' => 'New Year\'s Day'
  },
  '12' => {
    '24' => 'Christmas Eve',
    '25' => 'First Christmas Day',
    '26' => 'Second Christmas Day',
    '31' => 'New Year\'s Eve'
  },
  '5' => {
    '1' => 'International Workers\' Day'
  }
};
$Self->{'TimeZone::Calendar1'} =  '0';
$Self->{'TimeZone::Calendar1Name'} =  'Calendar Name 1';
$Self->{'TimeWorkingHours'} =  {
  'Fri' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Mon' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Sat' => [],
  'Sun' => [],
  'Thu' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Tue' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ],
  'Wed' => [
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20'
  ]
};
$Self->{'TimeVacationDaysOneTime'} =  {
  '2004' => {
    '1' => {
      '1' => 'test'
    }
  }
};
$Self->{'TimeVacationDays'} =  {
  '1' => {
    '1' => 'New Year\'s Day'
  },
  '12' => {
    '24' => 'Christmas Eve',
    '25' => 'First Christmas Day',
    '26' => 'Second Christmas Day',
    '31' => 'New Year\'s Eve'
  },
  '5' => {
    '1' => 'International Workers\' Day'
  }
};
$Self->{'TimeZoneUserBrowserAutoOffset'} =  '1';
$Self->{'TimeZoneUser'} =  '0';
$Self->{'SessionTableValue'} =  'session_value';
$Self->{'SessionTableID'} =  'session_id';
$Self->{'SessionTable'} =  'sessions';
$Self->{'SessionDir'} =  '<OTRS_CONFIG_Home>/var/sessions';
$Self->{'SessionCSRFProtection'} =  '1';
$Self->{'SessionUseCookieAfterBrowserClose'} =  '0';
$Self->{'SessionUseCookie'} =  '1';
$Self->{'SessionDeleteIfTimeToOld'} =  '1';
$Self->{'SessionMaxIdleTime'} =  '300';
$Self->{'SessionMaxTime'} =  '57600';
$Self->{'SessionDeleteIfNotRemoteID'} =  '1';
$Self->{'SessionCheckRemoteIP'} =  '1';
$Self->{'SessionName'} =  'Session';
$Self->{'SessionModule'} =  'Kernel::System::AuthSession::DB';
$Self->{'Frontend::NotifyModule'}->{'2-UID-Check'} =  {
  'Module' => 'Kernel::Output::HTML::NotificationUIDCheck'
};
$Self->{'Frontend::NotifyModule'}->{'1-CharsetCheck'} =  {
  'Module' => 'Kernel::Output::HTML::NotificationCharsetCheck'
};
$Self->{'Frontend::HeaderMetaModule'}->{'1-Refresh'} =  {
  'Module' => 'Kernel::Output::HTML::HeaderMetaRefresh'
};
$Self->{'SendmailBcc'} =  '';
$Self->{'SendmailModule::Host'} =  'mail.example.com';
$Self->{'SendmailModule::CMD'} =  '/usr/sbin/sendmail -i -f';
$Self->{'SendmailModule'} =  'Kernel::System::Email::Sendmail';
$Self->{'LogModule::AuditLogFile'} =  '/opt/otrs/var/log/audit';
$Self->{'LogModule::LogFile::Date'} =  '0';
$Self->{'LogModule::LogFile'} =  '/opt/otrs/var/log/otrs.log';
$Self->{'LogModule::SysLog::Charset'} =  'iso-8859-1';
$Self->{'LogModule::SysLog::LogSock'} =  'unix';
$Self->{'LogModule::SysLog::Facility'} =  'user';
$Self->{'LogModule'} =  'Kernel::System::Log::SysLog';
$Self->{'AuditLogModule'} =  'Kernel::System::Log::PMLogFile';
$Self->{'LinkObject::TypeGroup'}->{'0001'} =  [
  'Normal',
  'ParentChild'
];
$Self->{'LinkObject::Type'}->{'ParentChild'} =  {
  'SourceName' => 'Parent',
  'TargetName' => 'Child'
};
$Self->{'LinkObject::Type'}->{'Normal'} =  {
  'SourceName' => 'Normal',
  'TargetName' => 'Normal'
};
$Self->{'LinkObject::ViewMode'} =  'Simple';
delete $Self->{'CheckEmailInvalidAddress'};
delete $Self->{'CheckEmailValidAddress'};
delete $Self->{'CheckEmailAddresses'};
$Self->{'CheckMXRecord'} =  '0';
$Self->{'AttachmentDownloadType'} =  'attachment';
$Self->{'TimeShowAlwaysLong'} =  '0';
$Self->{'TimeCalendarLookup'} =  '1';
$Self->{'TimeInputFormat'} =  'Option';
$Self->{'DefaultViewLines'} =  '6000';
$Self->{'DefaultPreViewLines'} =  '18';
$Self->{'DefaultViewNewLine'} =  '90';
$Self->{'Frontend::RichText::DefaultCSS'} =  'font-family:Geneva,Helvetica,Arial,sans-serif; font-size: 12px;';
$Self->{'Frontend::RichTextHeight'} =  '320';
$Self->{'Frontend::RichTextWidth'} =  '620';
$Self->{'Frontend::RichText'} =  '1';
$Self->{'Frontend::YUIPath'} =  '<OTRS_CONFIG_Frontend::WebPath>yui/2.7.0/';
$Self->{'Frontend::JavaScriptPath'} =  '<OTRS_CONFIG_Frontend::WebPath>js/';
$Self->{'Frontend::CSSPath'} =  '<OTRS_CONFIG_Frontend::WebPath>css/';
$Self->{'Frontend::ImagePath'} =  '<OTRS_CONFIG_Frontend::WebPath>images/Standard/';
$Self->{'Frontend::WebPath'} =  '/otrs-web/';
$Self->{'DefaultTheme'} =  'Customized';
$Self->{'DefaultUsedLanguages'} =  {
  'ar_SA' => 'Arabic (Saudi Arabia)',
  'bg' => 'Bulgarian (&#x0411;&#x044a;&#x043b;&#x0433;&#x0430;&#x0440;&#x0441;&#x043a;&#x0438;)',
  'ct' => 'Catal&agrave;',
  'cz' => 'Czech (&#x010c;esky)',
  'da' => 'Dansk',
  'de' => 'Deutsch',
  'el' => 'Greek (&#x0395;&#x03bb;&#x03bb;&#x03b7;&#x03bd;&#x03b9;&#x03ba;&#x03ac;)',
  'en' => 'English (United States)',
  'en_CA' => 'English (Canada)',
  'en_GB' => 'English (United Kingdom)',
  'es' => 'Espa&ntilde;ol',
  'et' => 'Eesti',
  'fa' => 'Persian (&#x0641;&#x0627;&#x0631;&#x0633;&#x0649;)',
  'fi' => 'Suomi',
  'fr' => 'Fran&ccedil;ais',
  'hu' => 'Magyar',
  'it' => 'Italiano',
  'lv' => 'Latvijas',
  'nb_NO' => 'Norsk bokm&aring;l',
  'nl' => 'Nederlands',
  'pl' => 'Polski',
  'pt' => 'Portugu&ecirc;s',
  'pt_BR' => 'Portugu&ecirc;s Brasileiro',
  'ru' => 'Russian (&#x0420;&#x0443;&#x0441;&#x0441;&#x043a;&#x0438;&#x0439;)',
  'sk_SK' => 'Slovak (Sloven&#x010d;ina)',
  'sv' => 'Svenska',
  'tr' => 'T&uuml;rk&ccedil;e',
  'uk' => 'Ukrainian (&#x0423;&#x043a;&#x0440;&#x0430;&#x0457;&#x043d;&#x0441;&#x044c;&#x043a;&#x0430;)',
  'vi_VN' => 'Vietnam (Vi&#x0246;t Nam)',
  'zh_CN' => 'Chinese (Sim.) (&#x7b80;&#x4f53;&#x4e2d;&#x6587;)',
  'zh_TW' => 'Chinese (Tradi.) (&#x6b63;&#x9ad4;&#x4e2d;&#x6587;)'
};
$Self->{'DefaultLanguage'} =  'en';
$Self->{'DefaultCharset'} =  'iso-8859-1';
$Self->{'Organization'} =  'Example Company';
$Self->{'AdminEmail'} =  'admin@example.com';
$Self->{'ScriptAlias'} =  'otrs_dev/';
$Self->{'HttpType'} =  'http';
$Self->{'FQDN'} =  'yourhost.example.com';
$Self->{'SystemID'} =  '10';
$Self->{'ProductName'} =  'OTRS';
$Self->{'SecureMode'} =  '0';
}
1;

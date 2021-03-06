package MSRequestFromWindUtil;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

# Exporting the saluta routine
our @EXPORT = qw(MS_RequestParsing MS_CheckRequestSemantic);
# Exporting the saluta2 routine on demand basis.
#our @EXPORT_OK = qw(saluta2);


use MIME::Base64;


# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/../cpan-lib";



# ----------------- Moduli custom necessari ------------------
use MSXMLUtil;
use MSTicketUtil;



use Data::Dumper;
my $MS_DEBUG = 0;



# ---------------- Impostazioni del parsing (inizio) -------------------

# -------- struttura completa -----
#	TagName =>	{	
#								
#								is_mandatory => 1, # 1 = obbligatorio, 0 = opzionale, se non previsto allora deve sparire dalle keys delle Rules
#								
#								possibleValues => [], #array con i valori possibili... per gli oggetti nell'header i valori sono sempre uguali sia in Create che in Update e Notify. Nota: se vuoto non esiste una lista di valori specifica
#								
#								canBeEmpty => 0,  #1=si, 0=no
#								canBeSpacesOnly => 0,  #1=si, 0=no
#								
#								is_string => 1,
#								is_decimalNumber => 0,
#								is_datetime => 0,
#								
#								specialCheck =>  sub { return 0; }, #sub che deve ritornare 1 in caso di controlli (oltre il vuoto, ecc. -> controlli specifici del campo) di valorizzazione falliti, 0 se tutto OK
#								specialCheckMessage => '', #messaggio di errore in caso la specialCheck ritorni 1
#							},




#in questo contesto vale solo per gli Alarm
my %RequestBody_Rules_onCreate = ( 
	#TickedIDWind =>	{	#in Create da Wind (quindi alarm) questo id e' obbligatorio...
	#					is_mandatory => 1, 
	#					#is_string => 1,
	#				},
	
	TicketID =>	{	#in Create da Wind (quindi alarm) questo id e' obbligatorio...
						is_mandatory => 1, 
						#is_string => 1,
					},
							
	Type =>	{	
						is_mandatory => 1, 
						possibleValues => ['ALARM'],

				},
							

	Action =>	{
						is_mandatory => 1, 
						possibleValues => ['CREATE'],  

				},
							
	#Status =>	{
	#					is_mandatory => 1, 
	#					possibleValues => ['APERTO'], 
	#
	#			},
							
	priority =>	{
						is_mandatory => 1, 
						possibleValues => ['0', '1', '2', '3'], 

				},
		
	#CategoryTT   (CREATE=M - UPDATE=O - NOTIFY=NO)
	#verificare se e' il caso di controllare la lista dei valori presa dal Ticket.xml magari usando "specialCheck"
	CategoryTT =>	{
						is_mandatory => 1,
								
						specialCheck =>  sub { return 0; }, 
						specialCheckMessage => '', 
					},
							
	AmbitoTT =>	{
						is_mandatory => 1, 
						possibleValues => ['MOBILE NW', 'MOBILE IT', 'ALTRO', 'INTERCONNESSIONE WHOLELINE', 'CARRIER SELECTION'], 
				},
							
	Oggetto =>	{
						is_mandatory => 1, 
						#is_string => 1,
				},
							
	Descrizione =>	{
						is_mandatory => 1, 
						#is_string => 1,
					},
							
	TimestampTT =>	{
						#is_mandatory => 1,
						canBeEmpty => 1,
						is_datetime => 1,

					},
							
							
	startDateMalfunction =>	{
								canBeEmpty => 1,
								is_datetime => 1,
							},
							

	endDateMalfunction =>	{
								canBeEmpty => 1,
								is_datetime => 1,
							},
							

	segmentCustomer =>	{ canBeEmpty => 1, },
							

	msisdn =>	{
						canBeEmpty => 1,
						is_decimalNumber => 1,
				},
							

	imsi =>	{
						canBeEmpty => 1,
						is_decimalNumber => 1,
			},
							

	iccid =>	{
						canBeEmpty => 1,
						is_string => 1,
				},
							

	idLinea =>	{ canBeEmpty => 1, },	
	

	tipoLinea =>	{
							canBeEmpty => 1,
						possibleValues => ['GNR', 'PSTN', 'ISDN'], 
					},	
	

	mnpType =>	{
						canBeEmpty => 1,
						possibleValues => ['DONATING', 'RECIPIENT'], 
				},	
	

	imei =>	{
						canBeEmpty => 1,
						is_decimalNumber => 1,
			},	
	
	
	referente => { canBeEmpty => 1, },	
	
	#Nota =>	{ },
	#ListOfNotes => {},
	
	address => { canBeEmpty => 1, },	
	
	prov =>	{ canBeEmpty => 1, },	
	
	city =>	{ canBeEmpty => 1, },	
	
	cap =>	{
				canBeEmpty => 1,
				is_decimalNumber => 1,
			},
							
);





my %RequestBody_Rules_onUpdate = ( 
	TicketID =>	{
						is_mandatory => 1, 
						#is_string => 1,
				},

	TicketIDWind =>	{
						is_mandatory => 1, 
						#is_string => 1,
					},			

	Action =>	{
						is_mandatory => 1, 
						possibleValues => ['UPDATE'],  #REOPEN | UPDATE  --> UPDATE vale solo per ALARM. Dubbio: ma la REOPEN vale per gli Alarm??
				},
							
	#Status =>	{
	#					is_mandatory => 1, 
	#					possibleValues => ['APERTO', 'IN LAVORAZIONE'],
	#			},
							
							
	priority =>	{
						is_mandatory => 1,
						possibleValues => ['0', '1', '2', '3'],
					},
		
		
	#CategoryTT   (CREATE=M - UPDATE=O - NOTIFY=NO)
	#verificare se e' il caso di controllare la lista dei valori presa dal Ticket.xml magari usando "specialCheck"
	CategoryTT =>	{
						is_mandatory => 1,
						specialCheck =>  sub { return 0; }, 
						specialCheckMessage => '', 
					},
	
					
	AmbitoTT =>	{
						is_mandatory => 1, 
						possibleValues => ['MOBILE NW', 'MOBILE IT', 'ALTRO', 'INTERCONNESSIONE WHOLELINE', 'CARRIER SELECTION'], 
				},
	
	
												
	TimestampTT =>	{
						#is_mandatory => 1,
						canBeEmpty => 1,
						is_datetime => 1,
					},
							
	#Nota =>	{ is_mandatory => 1, },
	#ListOfNotes => { #is_mandatory => 1,
	#					 },
	
							
	startDateMalfunction =>	{
									 canBeEmpty => 1,
									 is_datetime => 1, },
							

	endDateMalfunction =>	{
									 canBeEmpty => 1,
									 is_datetime => 1, },

);





my %RequestBody_Rules_onNotify = ( 
	TicketID =>	{
						is_mandatory => 1, 
						#is_string => 1,
				},

	TicketIDWind =>	{
						is_mandatory => 1, 
						#is_string => 1,
					},			

	Action =>	{
						is_mandatory => 1, 
						possibleValues => ['DELIVERED', 'PRESA IN CARICO', 'SOSPENSIONE', 'DESOSPENSIONE', 'RESTITUZIONE', 'CLOSE'],  
				},
							
	Status =>	{
						is_mandatory => 1, 
						possibleValues => ['APERTO', 'IN LAVORAZIONE', 'SOSPESO', 'RESTITUITO', 'EXPIRED'],
				},
	
	Type =>	{	
						#is_mandatory => 1,
						canBeEmpty => 1,
						possibleValues => ['ALARM', 'INCIDENT'],

				},
					
	Causale =>	{
						canBeEmpty => 1, #MS 20140204: aggiunto, ma non sono sicuro di questa cosa
						
						possibleValues => ['IN ATTESA INFORMAZIONI', 'NON DI COMPETENZA', 'RISOLTO', 'NON RISCONTRATO', 'RISOLTO NO ACTION', #questi si applicano allo stato "RESTITUITO"
											'ACCESSO AL SITO', 'ATTIVITA CONGIUNTA', #questi si applicano allo stato "SOSPESO"
											'' #vuoto... che non ho capito quando si applica... forse per gli Alarm?
											],
				},		
							
	priority =>	{
					 #canBeEmpty => 1,
					 is_mandatory => 1, 
					 possibleValues => ['0', '1', '2', '3'],  },
		
		
	#CategoryTT   (CREATE=M - UPDATE=O - NOTIFY=NO)
	#verificare se e' il caso di controllare la lista dei valori presa dal Ticket.xml magari usando "specialCheck"
	CategoryTT =>	{
						#canBeEmpty => 1,
						is_mandatory => 1, 
						specialCheck =>  sub { return 0; }, 
						specialCheckMessage => '', 
					},
					
												
	TimestampTT =>	{
						#is_mandatory => 1,
						canBeEmpty => 1,
						is_datetime => 1,
					},
							
	#Nota =>	{ is_mandatory => 1, },
	#ListOfNotes =>	{ #is_mandatory => 1,
	#					 },
	
							
	AmbitoTT =>	{
					#canBeEmpty => 1,
					is_mandatory => 1, 
					possibleValues => ['MOBILE NW', 'MOBILE IT', 'ALTRO', 'INTERCONNESSIONE WHOLELINE', 'CARRIER SELECTION'],
				},
							

	#ExpDate =>	{ is_datetime => 1, },
	ExpirationDate =>	{ is_datetime => 1, },
);







#Le regole per gli attachment valgono SOLO quando gli allegati sono presenti (vedi codice dei controlli)
my %RequestBody_Rules_forAttachment = (
	FullFileName =>	{
						is_mandatory => 1,
						is_string => 1,
					},
	
	TypeFile =>	{ is_mandatory => 1, },
							
	dataCreazione  =>	{ is_datetime => 1, },
							
	FileBody =>	{ is_mandatory => 1, },

 );	 
 
 

my %RequestHeader_Rules = (
	## --- Request header ---
	SourceChannel =>	{
								is_mandatory => 1, 
								is_string => 1,
						},

	DestinationChannel =>	{
								is_mandatory => 1, 
								is_string => 1,
							},
	
	TimeStamp =>	{
								is_mandatory => 1, 
								is_datetime => 1,
					},	

	Username =>	{
								canBeEmpty => 1,
								canBeSpacesOnly => 1,
				},
	
	Password =>	{
								canBeEmpty => 1,
								canBeSpacesOnly => 1,
				},

	MessageType =>	{
								canBeEmpty => 1,
								canBeSpacesOnly => 1,
					},
	
	MessageCode =>	{
								canBeEmpty => 1,
								canBeSpacesOnly => 1,
					},
	
	TransactionId =>	{
								is_mandatory => 1, 
						},
	
	MessageId =>	{
								canBeEmpty => 1,
								canBeSpacesOnly => 1,
					},

	BusinessId =>	{
								is_mandatory => 1, 
								is_string => 1,
					},
	
);


# ---------------- Impostazioni del parsing (fine) -------------------








sub MS_RequestParsing
{	
   my $MS_ConfigHash_ptr = shift;

	if(exists($MS_ConfigHash_ptr->{RequestHash}))
	{
		#proviamo a fare il parsing
		my $XMLHash_ptr = MS_XMLCheckParsing($MS_ConfigHash_ptr, $MS_ConfigHash_ptr->{RequestHash}->{RequestContent});
		
		
		#Debug
		print "\n\nREQUEST from EAI parser dump:\n".Dumper($XMLHash_ptr) if($MS_DEBUG);
		
		
		#se le cose tornano...
		if ( defined($XMLHash_ptr) and (ref $XMLHash_ptr eq 'ARRAY') and defined($XMLHash_ptr->[0]) and (ref $XMLHash_ptr->[0] eq 'HASH') )
		{
			MS_RequestToRequestHash($MS_ConfigHash_ptr, $XMLHash_ptr) ;	
		}
		else
		{
			$MS_ConfigHash_ptr->{RequestHash}->{RequestErrorCode} = 290;
			$MS_ConfigHash_ptr->{RequestHash}->{RequestErrorDescr} = "Request malformata";
		}
		
			
	}


}





#Parte dall'array costruito durante il parsing e popola l'hash di configurazione
sub MS_RequestToRequestHash
{
	my $ConfigHash_ptr = shift; #l'hash puntato conterra' le configurazione nella forma CAMPO => VALORE
   my $XMLHash_ptr = shift; #robaccia parsata da OTRS...
	
	my $rit = 0;
	
	my $RequestHash_prt = $ConfigHash_ptr->{RequestHash};
	
	#es.:
	#if(exists($XMLHash_ptr->[0]->{OTRS_API}[1]->{TicketRequest}[1]->{SourceChannel}[1]->{Content}))
	my $rootTag = $XMLHash_ptr->[0]->{OTRS_API}[1]->{TicketRequest}[1];
	
	if (exists($rootTag->{CreateTTInput})) #create
	{
		$rootTag = $rootTag->{CreateTTInput}[1];
		#$ConfigHash_ptr->{InputRequestType}->{RequestType} = 'CREATE';
		$RequestHash_prt->{InputRequestType} = 'CREATE';
	}
	elsif (exists($rootTag->{InputUpdate})) #update
	{
		$rootTag = $rootTag->{InputUpdate}[1];
		$RequestHash_prt->{InputRequestType} = 'UPDATE';
	}
	elsif (exists($rootTag->{NotifyUpdate})) #notify
	{
		$rootTag = $rootTag->{NotifyUpdate}[1];
		$RequestHash_prt->{InputRequestType} = 'NOTIFY';
	}
	
	
	my $rootTagHeader = $rootTag->{Header}[1];
	my $rootTagBody = $rootTag->{Body}[1];

	print "\nAction RILEVATA: ".$rootTagBody->{Action}[1]->{Content}  if($MS_DEBUG);
	
	#per prima cosa devo stabilire se si tratta di una request di Create, Update o Notify
    my $req_type = MS_FindRequestType($rootTagBody->{Action}[1]->{Content}, $RequestHash_prt);
	 
	 
	 print "\nREQ_TYPE calcolato: ".$req_type  if($MS_DEBUG);
    
    if(!$req_type)
    {
    	#TODO: gestione errore -> non riesco a capire che tipo di Request sia..
    	$RequestHash_prt->{RequestErrorCode} = 210;
		$RequestHash_prt->{RequestErrorDescr} = "Tipo di Request non riconosciuta (Action = $rootTagBody->{Action}[1]->{Content})";	
    }
    else
    {
    	$RequestHash_prt->{RequestType} = $req_type;
    	
		print "\nRequestType impostato a: ".$RequestHash_prt->{RequestType}  if($MS_DEBUG);
		
    	#in base al tipo di richiesta stabiliamo le regole da usare per la validazione
    	my $reqHeaderRules_ptr = \%RequestHeader_Rules; #l'header e' costante tra i vari tipi
    	my $reqBodyRules_forAttachment_ptr = \%RequestBody_Rules_forAttachment; #costante tra i vari tipi
    	
		#debug
#		print "\nRequestBody_Rules_forAttachment :\n",
#		print Dumper(\%RequestBody_Rules_forAttachment);
#		print "\n";
#		print "\nRequestHeader_Rules :\n",
#		print Dumper(\%RequestHeader_Rules);
#		print "\n";
		#debug (fine)

    	my $reqBodyRules_ptr = 0;
	    if($RequestHash_prt->{RequestType} eq $RequestHash_prt->{RequestTypeCREATE}) #req type = Create
	    {
	    	$reqBodyRules_ptr = \%RequestBody_Rules_onCreate;
	    }
	    elsif($RequestHash_prt->{RequestType} eq $RequestHash_prt->{RequestTypeUPDATE}) #req type = Update
	    {
	    	$reqBodyRules_ptr = \%RequestBody_Rules_onUpdate;
	    }
	    elsif($RequestHash_prt->{RequestType} eq $RequestHash_prt->{RequestTypeNOTIFY}) #req type = Notify
	    {
	    	$reqBodyRules_ptr = \%RequestBody_Rules_onNotify;
	    }



    	
    	#controlliamo prima l'header...
    	my $check = 0;
	 	foreach my $key (keys(%{$reqHeaderRules_ptr}))
		{

			$check = MS_CheckRules($RequestHash_prt, $rootTagHeader, $reqHeaderRules_ptr, $key);
			if($check)
			{
				$RequestHash_prt->{$key} = $rootTagHeader->{$key}[1]->{Content} if(exists($rootTagHeader->{$key}[1]->{Content}));
			}
			else
			{
				#TODO: gestione errore e ritorno
			}
		}  
		
		
    	#... poi il body (tranne gli allegati)...e ora anche tranne la nota (che non e' pi� nel tag Nota ma in ListOfNotes)
    	$check = 0;
	 	foreach my $key (keys(%{$reqBodyRules_ptr}))
		{

			$check = MS_CheckRules($RequestHash_prt, $rootTagBody, $reqBodyRules_ptr, $key);
			if($check)
			{
				$RequestHash_prt->{$key} = $rootTagBody->{$key}[1]->{Content} if(exists($rootTagBody->{$key}[1]->{Content}) and $rootTagBody->{$key}[1]->{Content} !~ m/^\s*$/i); #parte sul "vuoto" aggiunta il 20140205 per evitare problemi con i campi opzionali vuoti che precedentemente non erano permessi...
			}
			else
			{
				#TODO: gestione errore e ritorno
			}
		}  
		
		#debug
#		print "\nreqBodyRules_forAttachment_ptr :\n",
#		print Dumper($reqBodyRules_forAttachment_ptr);
#		print "\n";
		#debug (fine)


		#... la nota....
						#<ListOfNotes>
						#  <Note>
						#    <Team>str1234</Team>
						#    <CreationDate>str1234</CreationDate>
						#    <Description>str1234</Description>
						#  </Note>
						#</ListOfNotes>
	    if(exists($rootTagBody->{ListOfNotes}))
	    {
				if(exists($rootTagBody->{ListOfNotes}[1]->{Note}))
				{
					if(exists($rootTagBody->{ListOfNotes}[1]->{Note}[1]->{Description}) )
					{
						$RequestHash_prt->{ListOfNotes} = {};
						$RequestHash_prt->{ListOfNotes}->{Description} = $rootTagBody->{ListOfNotes}[1]->{Note}[1]->{Description}[1]->{Content};
						
						$RequestHash_prt->{Nota} = $RequestHash_prt->{ListOfNotes}->{Description}; #legacy
						
						$RequestHash_prt->{ListOfNotes}->{Team} = $rootTagBody->{ListOfNotes}[1]->{Note}[1]->{Team}[1]->{Content} if(exists($rootTagBody->{ListOfNotes}[1]->{Note}[1]->{Team}));
						$RequestHash_prt->{ListOfNotes}->{CreationDate} = $rootTagBody->{ListOfNotes}[1]->{Note}[1]->{CreationDate}[1]->{Content} if(exists($rootTagBody->{ListOfNotes}[1]->{Note}[1]->{CreationDate}));
					}
				}
		 }


		
		#... e infine gli allegati
	    if(exists($rootTagBody->{ListOfAttachment}))
	    {
	    	if(exists($rootTagBody->{ListOfAttachment}[1]->{Attachment}))
	    	{
	    		my $attachmentCOUNT= @{$rootTagBody->{ListOfAttachment}[1]->{Attachment}};
	
	 
	    		for(my $nn=1; $nn < $attachmentCOUNT; $nn++) #il primo e' vuoto for (my $nn=0; $nn < $attachmentCOUNT; $nn++)
	    		{
	
					#FullFileName
					#TypeFile
					#dataCreazione
					#FileBody
					
					my $tagPlaceForAttachment = $rootTagBody->{ListOfAttachment}[1]->{Attachment}[$nn];
	
					my $check_FullFileName = MS_CheckRules($RequestHash_prt, $tagPlaceForAttachment, $reqBodyRules_forAttachment_ptr, 'FullFileName'); #$key);
					my $check_TypeFile = MS_CheckRules($RequestHash_prt, $tagPlaceForAttachment, $reqBodyRules_forAttachment_ptr, 'TypeFile'); #);
					my $check_dataCreazione = MS_CheckRules($RequestHash_prt, $tagPlaceForAttachment, $reqBodyRules_forAttachment_ptr, 'dataCreazione'); #);
					my $check_FileBody = MS_CheckRules($RequestHash_prt, $tagPlaceForAttachment, $reqBodyRules_forAttachment_ptr, 'FileBody'); #);
					
					if($check_FullFileName and $check_TypeFile and $check_dataCreazione and $check_FileBody)
					{
						
						## --- Allegati ---
						#AttachedFiles => [
						#							{
						#								FullFileName => '',
						#								TypeFile => '',
						#								dataCreazione => '',
						#								FileBody => '',
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
						
						my $h_ptr = {};
						$h_ptr->{FullFileName} = $rootTagBody->{ListOfAttachment}[1]->{Attachment}[$nn]->{FullFileName}[1]->{Content} if(exists($rootTagBody->{ListOfAttachment}[1]->{Attachment}[$nn]->{FullFileName}[1]->{Content}));
						$h_ptr->{TypeFile} = $rootTagBody->{ListOfAttachment}[1]->{Attachment}[$nn]->{TypeFile}[1]->{Content} if(exists($rootTagBody->{ListOfAttachment}[1]->{Attachment}[$nn]->{TypeFile}[1]->{Content}));
						$h_ptr->{dataCreazione} = $rootTagBody->{ListOfAttachment}[1]->{Attachment}[$nn]->{dataCreazione}[1]->{Content} if(exists($rootTagBody->{ListOfAttachment}[1]->{Attachment}[$nn]->{dataCreazione}[1]->{Content}));
						$h_ptr->{FileBody} = decode_base64($rootTagBody->{ListOfAttachment}[1]->{Attachment}[$nn]->{FileBody}[1]->{Content}) if(exists($rootTagBody->{ListOfAttachment}[1]->{Attachment}[$nn]->{FileBody}[1]->{Content}));
						
						push (@{$RequestHash_prt->{AttachedFiles}}, $h_ptr );
						
#						push (@{$RequestHash_prt->{AttachedFiles}},
#	    			      		{
#	    			      			FullFileName => $rootTagBody->{ListOfAttachment}[1]->{Attachment}[$nn]->{FullFileName}[1]->{Content},
#	    			      			TypeFile => $rootTagBody->{ListOfAttachment}[1]->{Attachment}[$nn]->{TypeFile}[1]->{Content},
#	    			     		 	dataCreazione => $rootTagBody->{ListOfAttachment}[1]->{Attachment}[$nn]->{dataCreazione}[1]->{Content},
#	    			     		 	FileBody => $rootTagBody->{ListOfAttachment}[1]->{Attachment}[$nn]->{FileBody}[1]->{Content},
#	    			      		} );
	    			      
						#$RequestHash_prt->{$key} = $rootTagBody->{$key}[1]->{Content};
					}
					else
					{
						#TODO: gestione errore e ritorno
					}
	
	    		}#if
	    	}#for  		 	
	    }
    }#fine attachment


	return $rit;
}







sub MS_FindRequestType 
{
	my $action = shift;
	my $RequestHash_prt = shift;

	my $rit = '';
   

	if($action  =~ m/^\s*CREATE\s*$/i) #req type = Create
	{
	  $rit = $RequestHash_prt->{RequestTypeCREATE}; #'CREATE';	
	}
	elsif($action  =~ m/^\s*(?:REOPEN|UPDATE)\s*$/i) #req type = Update
	{
	  $rit = $RequestHash_prt->{RequestTypeUPDATE}; #'UPDATE';
	}
	elsif($action  =~ m/^\s*(?:DELIVERED|PRESA\s+IN\s+CARICO|SOSPENSIONE|DESOSPENSIONE|RESTITUZIONE|CLOSE)\s*$/i) #req type = Notify
	{
	  $rit = $RequestHash_prt->{RequestTypeNOTIFY}; #'NOTIFY';
	}


	return $rit;
}









#ritorna 1 se ok, 0 se KO
sub MS_CheckRules
{
	my $RequestHash_prt = shift;
	my $tagPlace = shift;
	my $rules_ptr = shift;
	my $key = shift; #NOTA: key = tag
	
	
	#debug
#	print "\n";
#	print Dumper($RequestHash_prt);
#	print "\n";
#	print Dumper($tagPlace);
#	print "\n";
#	print Dumper($rules_ptr);
#	print "\n";
	#debug (fine)
	
	

	#MS: la key per l'hash rules qui esiste per forza (ciclo proprio sulle key per richiamare questa sub)

	my $specificRules = $rules_ptr->{$key};

	my $rit = 0;

	#test esistenza tag
	if(exists($tagPlace->{$key}[1]->{Content})) #supposizione -> tag name = key name
	{
		#il tag esiste
		my $tagContent = $tagPlace->{$key}[1]->{Content};
		

		#test tag vuoto
		if( exists($specificRules->{canBeEmpty}) or ($tagContent ne '') )
		{
			#se sono su un tag vuoto che lo permette...
			if (exists($specificRules->{canBeEmpty}) and ($tagContent eq '' or $tagContent =~ m/^\s*$/i))
			{
				return 1;
			}
			
			
			#test tag solo caratteri white (spazi, ecc.)
			if( exists($specificRules->{canBeSpacesOnly}) or ($tagContent !~ m/^\s*$/) )
			{
				#test tag stringa
				if( !exists($specificRules->{is_string}) or ($tagContent =~ m/^[\w\s\-\.\#]*$/) )
				{
					#test tag numero decimale
					if( !exists($specificRules->{is_decimalNumber}) or ($tagContent =~ m/^\s*\d*\s*$/) )
					{ 
						#test tag datetime - formato concordato = YYYY-MM-DD HH:MM:SS
						if( !exists($specificRules->{is_datetime}) or ($tagContent =~ m/^\s*\d\d\d\d-\d\d-\d\d\s+\d\d\:\d\d\:\d\d\s*$/ or $tagContent =~ m/^\s*\d\d\d\d-\d\d-\d\dT\d\d\:\d\d\:\d\d\+\d\d\:\d\d\s*$/ or $tagContent =~ m/^\s*\d\d\d\d-\d\d-\d\dT\d\d\:\d\d\:\d\d\s*$/  or $tagContent !~ m/^\s*$/ ) )
						{
							
#							print "\n\n";
#							print "key = $key \n\n";
#							print Dumper($specificRules);
#							print "\n\n";
							
							
							#test tag - test speciale proprio di ogni tag (ritorna 0 se tutto ok)
							if( !exists($specificRules->{specialCheck}) or (! $specificRules->{specialCheck}->($tagContent)) )
							{
								#test tag - valori della lista consentita (per i tag che la prevedono)
								if(exists($specificRules->{possibleValues}) )
								{
									my @possibleValues = @{ $specificRules->{possibleValues} };
									my $possibleValuesCount = scalar(@possibleValues);
									my $isInList = 0;
									
									my $currentValue = '';
									for(my $i=0; $i<$possibleValuesCount; $i++)
									{
										$currentValue = $possibleValues[$i];
										
										if($tagContent =~ m/^$currentValue$/i )
										{
											$isInList = 1;
										}
									}
									
									if($possibleValuesCount == 0 or $isInList == 1) #non e' prevista una lista oppure il valore rientra nella lista
									{
										$rit = 1;
									}
									else
									{
										$RequestHash_prt->{RequestErrorCode} = 207;
										$RequestHash_prt->{RequestErrorDescr} = "Tag con valorizzazione non attesa - lista ($key)";			
									}										
								}
								
								#else ... ho terminato tutti i controlli positivamente 
								$rit = 1;

							}
							else
							{
								$RequestHash_prt->{RequestErrorCode} = 206;
								
								if(exists($specificRules->{specialCheckMessage}))
								{
									$RequestHash_prt->{RequestErrorDescr} = "$specificRules->{specialCheckMessage} ($key)";
								}
								else
								{
									$RequestHash_prt->{RequestErrorDescr} = "Tag con valorizzazione errata ($key)";
								}
											
							}	
						}
						else
						{
							$RequestHash_prt->{RequestErrorCode} = 205;
							$RequestHash_prt->{RequestErrorDescr} = "Tag con valorizzazione non attesa - datetime ($key)";			
						}						
					}
					else
					{
						$RequestHash_prt->{RequestErrorCode} = 204;
						$RequestHash_prt->{RequestErrorDescr} = "Tag con valorizzazione non attesa - numero intero ($key)";			
					}
				}
				else
				{
					$RequestHash_prt->{RequestErrorCode} = 203;
					$RequestHash_prt->{RequestErrorDescr} = "Tag con valorizzazione non attesa - stringa ($key)";			
				}
			}
			else
			{
				$RequestHash_prt->{RequestErrorCode} = 202;
				$RequestHash_prt->{RequestErrorDescr} = "Tag vuoto - solo spazi - non atteso ($key)";			
			}
		}
		else
		{
			$RequestHash_prt->{RequestErrorCode} = 201;
			$RequestHash_prt->{RequestErrorDescr} = "Tag vuoto non atteso ($key)";			
		}
		
		
	}
	else
	{
		#il tag e' obbligatorio in questa fase...quindi la sua mancanza e' un errore
		if(exists($specificRules->{is_mandatory})) 
		{
			$RequestHash_prt->{RequestErrorCode} = 200;
			$RequestHash_prt->{RequestErrorDescr} = "Tag obbligatorio mancante ($key)";
		}
		else #tag opzionale mancante...
		{
			$rit = 1; #tutto ok
		}
		 
	}
	
	return $rit;
}















# Ritorna 1 se OK, 0 se KO
# errori semantici iniziano per 3
sub MS_CheckRequestSemantic
{
	my $ConfigHash_ptr = shift;
	
	my $RequestHash_ptr = $ConfigHash_ptr->{RequestHash};
	
	my $rit = 0;
	
	#Faccio i controlli di consistenza per Create, Update, Notify
	
	my $category_is_ok = 0;
	
	#$ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "---------------------- MS_CheckRequestSemantic  (chiamata) ----");
	
	#se non si tratta di una create recupero le info che mi servono sul ticket
	if ( ($RequestHash_ptr->{RequestType} eq $RequestHash_ptr->{RequestTypeUPDATE}) or ($RequestHash_ptr->{RequestType} eq $RequestHash_ptr->{RequestTypeNOTIFY}) )
	{
		#salvo le info in $ConfigHash_ptr->{Ticket}
		$ConfigHash_ptr->{Ticket} = {};
		if(MS_TicketGetInfoShort( $RequestHash_ptr->{TicketID}, $RequestHash_ptr->{TicketID_is_a_TN}, $ConfigHash_ptr->{OTRS_DBObject}, $ConfigHash_ptr->{Ticket}) )
		{
			if(MS_TicketGetWindType($ConfigHash_ptr->{Ticket}, $ConfigHash_ptr->{PM_Wind_settings}) or 
				$ConfigHash_ptr->{Ticket}->{WindType} eq $ConfigHash_ptr->{Ticket}->{WindTypeUNKNOW})
			{
				if(MS_TicketGetWindPermission($ConfigHash_ptr->{Ticket}, $ConfigHash_ptr->{PM_Wind_settings}) or 
					!$ConfigHash_ptr->{Ticket}->{Permissions}->{Wind_edit})
				{
					if($RequestHash_ptr->{RequestType} eq $RequestHash_ptr->{RequestTypeUPDATE}) #req type = Update
					{
						if($ConfigHash_ptr->{Ticket}->{WindType} eq $ConfigHash_ptr->{Ticket}->{WindTypeALARM})
						{
							if(!exists($RequestHash_ptr->{AttachedFiles}) or scalar(@{$RequestHash_ptr->{AttachedFiles}}) == 0) #non devono esserci allegati per gli alarm
							{
								# #OK...update per ALARM
								if (exists($RequestHash_ptr->{startDateMalfunction}) and exists($RequestHash_ptr->{endDateMalfunction}))
								{
									my $tmp_compare = MS_StringDateCompare($RequestHash_ptr->{startDateMalfunction}, $RequestHash_ptr->{endDateMalfunction});
									if ($tmp_compare == 0 || $tmp_compare == 2) #endDateMalfunction uguale o nel futuro rispetto a startDateMalfunction
									{
										$rit = 1;
									}
									else
									{
										$RequestHash_ptr->{RequestErrorCode} = 308;
										$RequestHash_ptr->{RequestErrorDescr} = "startDateMalfunction nel futuro rispetto a endDateMalfunction";
									}
									
								}
								else
								{
									$rit = 1;
								}
							}
							else
							{
								#TODO: errore...non devono esserci allegati per gli alarm
								$RequestHash_ptr->{RequestErrorCode} = 307;
								$RequestHash_ptr->{RequestErrorDescr} = "Allegati non previsti per gli Alarm tramite Update";
							}
						}
						else
						{
							#TODO: errore... UPDATE permessa solo per gli ALARM
							$RequestHash_ptr->{RequestErrorCode} = 306;
							$RequestHash_ptr->{RequestErrorDescr} = "UPADTE non permessa per questo tipo di oggetto ($RequestHash_ptr->{TicketID})";
						}
					}
					else #req type = Notify
					{
						if($ConfigHash_ptr->{Ticket}->{WindType} eq $ConfigHash_ptr->{Ticket}->{WindTypeALARM})
						{
							if(!exists($RequestHash_ptr->{AttachedFiles}) or scalar(@{$RequestHash_ptr->{AttachedFiles}}) == 0) #non devono esserci allegati per gli alarm
							{
								#if(exists($RequestHash_ptr->{CategoryTT}) and MS_Check_Category($RequestHash_ptr->{CategoryTT}, $ConfigHash_ptr->{Category_Alarm_Wind_PM}))
								#{
									#OK... ma controlla che sia per la sola chiusura dell'ALARM
									if($RequestHash_ptr->{Action} eq 'CLOSE')
									{
										#...tutto OOOOKKK
										
										$rit = 1;
									}
									else
									{
										#TODO: errore...tipo di notify non prevista per gli alarm
										$RequestHash_ptr->{RequestErrorCode} = 305;
										$RequestHash_ptr->{RequestErrorDescr} = "Tipo di notify non prevista per gli Alarm ($RequestHash_ptr->{Action})";
									}
								#}
								#else
								#{
								#	#TODO: errore...category non prevista per gli alarm
								#}
							}
							else
							{
								#TODO: errore...non devono esserci allegati per gli alarm
								$RequestHash_ptr->{RequestErrorCode} = 304;
								$RequestHash_ptr->{RequestErrorDescr} = "Allegati non previsti per gli Alarm tramite Notify";
							}
						}
						else # ****** INCIDENT ******
						{
							if(exists($RequestHash_ptr->{CategoryTT}) and MS_Check_Category($RequestHash_ptr->{CategoryTT}, $ConfigHash_ptr->{Category_Incident_PM_Wind}))
							{
								# OK pe gli Incident
								$rit = 1;
							}
							else
							{
								#TODO: errore...category non prevista per gli incident
								$RequestHash_ptr->{RequestErrorCode} = 303;
								$RequestHash_ptr->{RequestErrorDescr} = "Category non prevista per gli Incident";
							}
						}
					}						
				}
				else
				{
					#TODO: errore... Wind non ha diritti sufficienti per editare questo oggetto
					$RequestHash_ptr->{RequestErrorCode} = 302;
					$RequestHash_ptr->{RequestErrorDescr} = "Diritti insufficienti per editare questo oggetto ($RequestHash_ptr->{TicketID})";
				}				
			}
			else
			{
				#TODO: errore... tipo di oggetto non appartenente ad ambito FULL o non riconosciuto
				$RequestHash_ptr->{RequestErrorCode} = 301;
				$RequestHash_ptr->{RequestErrorDescr} = "Tipo di oggetto non appartenente ad ambito FULL o non riconosciuto";
			}
					
		}
		else
		{
			$RequestHash_ptr->{RequestErrorCode} = 300;
			$RequestHash_ptr->{RequestErrorDescr} = "Alarm o Incident richiesto non trovato ($RequestHash_ptr->{TicketID})";
		}

		
	}
	elsif($RequestHash_ptr->{RequestType} eq $RequestHash_ptr->{RequestTypeCREATE}) #req type = Create
	{
		if($RequestHash_ptr->{Type} eq 'ALARM') #unico permesso in create
		{
			if(exists($RequestHash_ptr->{CategoryTT}) and MS_Check_Category($RequestHash_ptr->{CategoryTT}, $ConfigHash_ptr->{Category_Alarm_Wind_PM}))
			{
				if(!exists($RequestHash_ptr->{AttachedFiles}) or (ref($RequestHash_ptr->{AttachedFiles}) eq 'ARRAY' and scalar(@{$RequestHash_ptr->{AttachedFiles}}) == 0) ) #non devono esserci allegati per gli alarm
				{
					# OOOOOKKKKKK
					if (exists($RequestHash_ptr->{startDateMalfunction}) and exists($RequestHash_ptr->{endDateMalfunction}))
					{
						my $tmp_compare = MS_StringDateCompare($RequestHash_ptr->{startDateMalfunction}, $RequestHash_ptr->{endDateMalfunction});
						if ($tmp_compare == 0 || $tmp_compare == 2) #endDateMalfunction uguale o nel futuro rispetto a startDateMalfunction
						{
							$rit = 1;
						}
						else
						{
							$RequestHash_ptr->{RequestErrorCode} = 313;
							$RequestHash_ptr->{RequestErrorDescr} = "startDateMalfunction nel futuro rispetto a endDateMalfunction durante Create";
						}
						
					}
					else
					{
						$rit = 1;
					}
				}
				else
				{
					#TODO: errore...non devono esserci allegati per gli alarm
					$RequestHash_ptr->{RequestErrorCode} = 312;
					$RequestHash_ptr->{RequestErrorDescr} = "Allegati non previsti per gli Alarm tramite Create";
				}
			}
			else
			{
				#TODO: errore...category non prevista
				$RequestHash_ptr->{RequestErrorCode} = 311;
				$RequestHash_ptr->{RequestErrorDescr} = "Category non prevista per gli Alarm";
			}
		}
		else
		{
			#TODO: errore...create non prevista per oggetti diversi da ALARM
			$RequestHash_ptr->{RequestErrorCode} = 310;
			$RequestHash_ptr->{RequestErrorDescr} = "Create non permessa per oggetti diversi da Alarm";
		}		
	}
	else
	{
		#TODO: errore...tipo di richiesta non contemplata
		$RequestHash_ptr->{RequestErrorCode} = 309;
		$RequestHash_ptr->{RequestErrorDescr} = "Tipo di richiesta non contemplata";
	}


    

	
	#TODO: 
	# -  controllo CategoryTT, se presente, per Create, Update, Notify
	#      e verifico la consistenza con la lista presente nel Ticket.xml (vedi Categoria PI attuale -> stesso campo --> inventarsi qualcosa per la convivenza)
	#
	# Domanda: le category per gli Incident e quelle per gli Alarm sono separate?? Esistono 2 liste diverse? -> NO!
	
	#TODO: Create
	# - assenza degli allegati (la Create lato nostro vale solo per gli Alarm e per gli Alarm gli allegati NON vanno gestiti)
	
	
	#TODO: Update
	# - esistenza di TicketID
	# - controllo che TicketID sia effettivamente un Alarm (gli unici manipolabili da Wind tramite l'update) --> Corretto!!
	# - che TicketID sia su una coda in cui Wind puo' agire
	# - NON controllo la consistenza dello Status (eventuali salti non attesi)
	
	
	#TODO: Notify
	# - esistenza TicketID
	# - che TicketID sia su una coda in cui Wind puo' agire
	# - che ExpDate sia nel futuro
	# - NON controllo salti di stato non attesi. Mi adeguo e basta.	Anche per le sospensioni!! --> OK!
	# 
	# Si condivide che invece di gestire gli stati: CHIUSO � Risolto, CHIUSO � NdC, CHIUSO � INF, CHIUSO � NRis si utilizzer�:
	# STATO = Restituito
	# CAUSALE = Risolto | NdC (Non di Competenza) | INF (In attesa informazioni) | NRis (Non riscontrato)
	#
	# quindi la Notify serve per chiudere anche gli Alarm (e per gli alarm solo a questo)...
	# - 


	
	return $rit;
}

# --------------------






1;

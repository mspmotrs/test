package MSRequestFromWindUtil;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

# Exporting the saluta routine
our @EXPORT = qw(MS_RequestParsing);
# Exporting the saluta2 routine on demand basis.
#our @EXPORT_OK = qw(saluta2);




# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/../cpan-lib";




# ----------------- Moduli custom necessari ------------------
use MSXMLUtil;
use MSTicketUtil;







sub MS_RequestParsing
{	
   my $MS_ConfigHash_ptr = shift;

	if(exists($MS_ConfigHash_ptr->{RequestHash}))
	{
		#proviamo a fare il parsing
		my $XMLHash_ptr = MS_XMLCheckParsing($MS_ConfigHash_ptr, $MS_ConfigHash_ptr->{RequestHash}->{RequestContent});
		MS_RequestToRequestHash($MS_ConfigHash_ptr, $XMLHash_ptr) ;		
	}


}




	foreach my $key (keys(%Request_Rules))
	{
		my $tagPlace = $rootTagBody;
		if($Request_Rules{$key}->{TagPosition} =~ m/^HEADER$/i)
		{
			$tagPlace = $rootTagHeader;
		}

		
		if(exists($tagPlace->{SourceChannel}[1]->{Content}))
    	{
    		$RequestHash_prt->{$Request_Rules{$key}->{TagName}} =$tagPlace->{SourceChannel}[1]->{Content};
    	
    		if(!$Request_Rules{$key}->{canBeEmpty})
    		{
 				if($ConfigHash_ptr->{SystemUserID} =~ m/^\s*$/i )  #se vuoto
				{
					$rit = 1;	
					$ConfigHash_ptr->{ErrorCode} = 2;
					$ConfigHash_ptr->{ErrorDescription} = 'Errore di parsing della Request: tag vuoto (SourceChannel)';			
				}   			
    		}
    		
    	}		
	}
    }
	 
my %RequestBody_Rules_onCreate = ( );
my %RequestBody_Rules_onUpdate = ( );
my %RequestBody_Rules_onNotify = ( );
my %RequestHeader_Rules = (
	## --- Request header ---
	SourceChannel =>	{
								TagPosition => 'HEADER',
								TagName => 'SourceChannel',
								
								inCreate => 'M',
								inUpdate => 'M',
								inNotify => 'M',
								
								possibleValues => []; #array con i valori possibili... per gli oggetti nell'header i valori sono sempre uguali sia in Create che in Update e Notify. Nota: se vuoto non esiste una lista di valori specifica
								
								canBeEmpty => 0,  #1=si, 0=no
								canBeSpacesOnly => 0,  #1=si, 0=no
								
								is_string => 1,
								is_decimalNumber => 0,
								is_datetime => 0,
								
								specialCheck =>  sub { return 0; }, #sub che deve ritornare 1 in caso di controlli (oltre il vuoto, ecc. -> controlli specifici del campo) di valorizzazione falliti, 0 se tutto OK
								specialCheckMessage => '', #messaggio di errore in caso la specialCheck ritorni 1
							},

	DestinationChannel =>	{
								TagPosition => 'HEADER',
								TagName => 'DestinationChannel',
								
								inCreate => 'M',
								inUpdate => 'M',
								inNotify => 'M',
								
								possibleValues => []; #array con i valori possibili... per gli oggetti nell'header i valori sono sempre uguali sia in Create che in Update e Notify. Nota: se vuoto non esiste una lista di valori specifica
								
								canBeEmpty => 0,  #1=si, 0=no
								canBeSpacesOnly => 0,  #1=si, 0=no
								
								is_string => 1,
								is_decimalNumber => 0,
								is_datetime => 0,
								
								specialCheck =>  sub { return 0; }, #sub che deve ritornare 1 in caso di controlli (oltre il vuoto, ecc. -> controlli specifici del campo) di valorizzazione falliti, 0 se tutto OK
								specialCheckMessage => '', #messaggio di errore in caso la specialCheck ritorni 1
							},
	
	TimeStamp =>	{
								TagPosition => 'HEADER',
								TagName => 'TimeStamp',
								
								inCreate => 'M',
								inUpdate => 'M',
								inNotify => 'M',
								
								possibleValues => []; #array con i valori possibili... per gli oggetti nell'header i valori sono sempre uguali sia in Create che in Update e Notify. Nota: se vuoto non esiste una lista di valori specifica
								
								canBeEmpty => 0,  #1=si, 0=no
								canBeSpacesOnly => 0,  #1=si, 0=no
								
								is_string => 0,
								is_decimalNumber => 0,
								is_datetime => 1,
								
								specialCheck =>  sub { return 0; }, #sub che deve ritornare 1 in caso di controlli (oltre il vuoto, ecc. -> controlli specifici del campo) di valorizzazione falliti, 0 se tutto OK
								specialCheckMessage => '', #messaggio di errore in caso la specialCheck ritorni 1
							},	

	Username =>	{
								TagPosition => 'HEADER',
								TagName => 'Username',
								
								inCreate => 'O',
								inUpdate => 'O',
								inNotify => 'O',
								
								possibleValues => []; #array con i valori possibili... per gli oggetti nell'header i valori sono sempre uguali sia in Create che in Update e Notify. Nota: se vuoto non esiste una lista di valori specifica
								
								canBeEmpty => 1,  #1=si, 0=no
								canBeSpacesOnly => 1,  #1=si, 0=no
								
								is_string => 1,
								is_decimalNumber => 0,
								is_datetime => 0,
								
								specialCheck =>  sub { return 0; }, #sub che deve ritornare 1 in caso di controlli (oltre il vuoto, ecc. -> controlli specifici del campo) di valorizzazione falliti, 0 se tutto OK
								specialCheckMessage => '', #messaggio di errore in caso la specialCheck ritorni 1
							},
	
	Password =>	{
								TagPosition => 'HEADER',
								TagName => 'Password',
								
								inCreate => 'O',
								inUpdate => 'O',
								inNotify => 'O',
								
								possibleValues => []; #array con i valori possibili... per gli oggetti nell'header i valori sono sempre uguali sia in Create che in Update e Notify. Nota: se vuoto non esiste una lista di valori specifica
								
								canBeEmpty => 1,  #1=si, 0=no
								canBeSpacesOnly => 1,  #1=si, 0=no
								
								is_string => 1,
								is_decimalNumber => 0,
								is_datetime => 0,
								
								specialCheck =>  sub { return 0; }, #sub che deve ritornare 1 in caso di controlli (oltre il vuoto, ecc. -> controlli specifici del campo) di valorizzazione falliti, 0 se tutto OK
								specialCheckMessage => '', #messaggio di errore in caso la specialCheck ritorni 1
							},

	MessageType =>	{
								TagPosition => 'HEADER',
								TagName => 'MessageType',
								
								inCreate => 'O',
								inUpdate => 'O',
								inNotify => 'O',
								
								possibleValues => []; #array con i valori possibili... per gli oggetti nell'header i valori sono sempre uguali sia in Create che in Update e Notify. Nota: se vuoto non esiste una lista di valori specifica
								
								canBeEmpty => 1,  #1=si, 0=no
								canBeSpacesOnly => 1,  #1=si, 0=no
								
								is_string => 1,
								is_decimalNumber => 0,
								is_datetime => 0,
								
								specialCheck =>  sub { return 0; }, #sub che deve ritornare 1 in caso di controlli (oltre il vuoto, ecc. -> controlli specifici del campo) di valorizzazione falliti, 0 se tutto OK
								specialCheckMessage => '', #messaggio di errore in caso la specialCheck ritorni 1
							},
	
	MessageCode =>	{
								TagPosition => 'HEADER',
								TagName => 'MessageCode',
								
								inCreate => 'O',
								inUpdate => 'O',
								inNotify => 'O',
								
								possibleValues => []; #array con i valori possibili... per gli oggetti nell'header i valori sono sempre uguali sia in Create che in Update e Notify. Nota: se vuoto non esiste una lista di valori specifica
								
								canBeEmpty => 1,  #1=si, 0=no
								canBeSpacesOnly => 1,  #1=si, 0=no
								
								is_string => 1,
								is_decimalNumber => 0,
								is_datetime => 0,
								
								specialCheck =>  sub { return 0; }, #sub che deve ritornare 1 in caso di controlli (oltre il vuoto, ecc. -> controlli specifici del campo) di valorizzazione falliti, 0 se tutto OK
								specialCheckMessage => '', #messaggio di errore in caso la specialCheck ritorni 1
							},
	
	TransactionId =>	{
								TagPosition => 'HEADER',
								TagName => 'TransactionId',
								
								inCreate => 'M',
								inUpdate => 'M',
								inNotify => 'M',
								
								possibleValues => []; #array con i valori possibili... per gli oggetti nell'header i valori sono sempre uguali sia in Create che in Update e Notify. Nota: se vuoto non esiste una lista di valori specifica
								
								canBeEmpty => 0,  #1=si, 0=no
								canBeSpacesOnly => 0,  #1=si, 0=no
								
								is_string => 1,
								is_decimalNumber => 0,
								is_datetime => 0,
								
								specialCheck =>  sub { return 0; }, #sub che deve ritornare 1 in caso di controlli (oltre il vuoto, ecc. -> controlli specifici del campo) di valorizzazione falliti, 0 se tutto OK
								specialCheckMessage => '', #messaggio di errore in caso la specialCheck ritorni 1
							},
	
	MessageId =>	{
								TagPosition => 'HEADER',
								TagName => 'MessageId',
								
								inCreate => 'O',
								inUpdate => 'O',
								inNotify => 'O',
								
								possibleValues => []; #array con i valori possibili... per gli oggetti nell'header i valori sono sempre uguali sia in Create che in Update e Notify. Nota: se vuoto non esiste una lista di valori specifica
								
								canBeEmpty => 1,  #1=si, 0=no
								canBeSpacesOnly => 1,  #1=si, 0=no
								
								is_string => 1,
								is_decimalNumber => 0,
								is_datetime => 0,
								
								specialCheck =>  sub { return 0; }, #sub che deve ritornare 1 in caso di controlli (oltre il vuoto, ecc. -> controlli specifici del campo) di valorizzazione falliti, 0 se tutto OK
								specialCheckMessage => '', #messaggio di errore in caso la specialCheck ritorni 1
							},

	BusinessId =>	{
								TagPosition => 'HEADER',
								TagName => 'BusinessId',
								
								inCreate => 'M',
								inUpdate => 'M',
								inNotify => 'M',
								
								possibleValues => []; #array con i valori possibili... per gli oggetti nell'header i valori sono sempre uguali sia in Create che in Update e Notify. Nota: se vuoto non esiste una lista di valori specifica
								
								canBeEmpty => 0,  #1=si, 0=no
								canBeSpacesOnly => 0,  #1=si, 0=no
								
								is_string => 1,
								is_decimalNumber => 0,
								is_datetime => 0,
								
								specialCheck =>  sub { return 0; }, #sub che deve ritornare 1 in caso di controlli (oltre il vuoto, ecc. -> controlli specifici del campo) di valorizzazione falliti, 0 se tutto OK
								specialCheckMessage => '', #messaggio di errore in caso la specialCheck ritorni 1
							},
	
);


	
	#
	## --- Request body ---
	#TicketID => '',
	#TickedIDWind => '',
	#Causale => '', #valida solo in NOTIFY
	#Action => '',
	#Status => '',
	#Type => '',
	#priority => '',
	#CategoryTT => '',
	#AmbitoTT => '',
	#Oggetto => '',
	#Descrizione => '',
	#TimestampTT => '',
	#startDateMalfunction => '',
	#endDateMalfunction => '',
	#segmentCustomer => '',
	#msisdn => '',
	#imsi => '',
	#iccid => '',
	#idLinea => '',
	#tipoLinea => '',
	#mnpType => '',
	#imei => '',
	#ErrorCode => '',
	#ErrorDesc => '',
	#ExpDate => '', # ExpirationDate_TTL valida solo in NOTIFY
	#Referente => '',
	#Nota => '',
	#address => '',
	#prov => '',
	#city => '',
	#cap => '',
	#
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
)





##request
#RequestHash => {
#						#MS info (non arrivano nella request ma li valorizza internamente)
#						RequestType => '', #CREATE, UPDATE, NOTIFY
#						RequestContent => '', #il contenuto della request cosi' come arriva al server
#						#MS info -- fine
#						
#						#di seguito aggiungero' i campi specicfici della request (se assenti sono da considerarsi non presenti nella request in arrivo)
#
#						## --- Request header ---
#						#SourceChannel => '',
#						#DestinationChannel => '',
#						#TimeStamp => '',
#						#Username => '',
#						#Password => '',
#						#MessageType => '',
#						#MessageCode => '',
#						#TransactionId => '',
#						#MessageId => '',
#						#BusinessId => '',
#						#
#						## --- Request body ---
#						#TicketID => '',
#						#TickedIDWind => '',
#						#Causale => '', #valida solo in NOTIFY
#						#Action => '',
#						#Status => '',
#						#Type => '',
#						#priority => '',
#						#CategoryTT => '',
#						#AmbitoTT => '',
#						#Oggetto => '',
#						#Descrizione => '',
#						#TimestampTT => '',
#						#startDateMalfunction => '',
#						#endDateMalfunction => '',
#						#segmentCustomer => '',
#						#msisdn => '',
#						#imsi => '',
#						#iccid => '',
#						#idLinea => '',
#						#tipoLinea => '',
#						#mnpType => '',
#						#imei => '',
#						#ErrorCode => '',
#						#ErrorDesc => '',
#						#ExpDate => '', # ExpirationDate_TTL valida solo in NOTIFY
#						#Referente => '',
#						#Nota => '',
#						#address => '',
#						#prov => '',
#						#city => '',
#						#cap => '',
#						#
#						## --- Allegati ---
#						#AttachedFiles => [
#						#							{
#						#								FullFileName => '',
#						#								TypeFile => '',
#						#								dataCreazione => '',
#						#								FileBody => '',
#						#							},
#						#
#						#							{
#						#								FullFileName => '',
#						#								TypeFile => '',
#						#								dataCreazione => '',
#						#								FileBody => '',
#						#							},
#						#						],
#						#
#					}





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
	my $rootTagHeader = $rootTag;
	my $rootTagBody = $rootTag;
	
	
	
	
	## ------------------------- Request header -------------------------
	
	#TimeStamp (CREATE=M - UPDATE=M - NOTIFY=M)
	#Username (CREATE=O - UPDATE=O - NOTIFY=O)
	#Password (CREATE=O - UPDATE=O - NOTIFY=O)
	#MessageType (CREATE=O - UPDATE=O - NOTIFY=O)
	#MessageCode (CREATE=O - UPDATE=O - NOTIFY=O)
	#TransactionId (CREATE=M - UPDATE=M - NOTIFY=M)
	#MessageId (CREATE=O - UPDATE=M - NOTIFY=M)
	#BusinessId (CREATE=M - UPDATE=M - NOTIFY=M)


	
	#SourceChannel (CREATE=M - UPDATE=M - NOTIFY=M)
	if(exists($rootTagHeader->{SourceChannel}[1]->{Content}))
    {
    	$RequestHash_prt->{SourceChannel} = $rootTagHeader->{SourceChannel}[1]->{Content};
    	
		if($ConfigHash_ptr->{SystemUserID} =~ m/^\s*$/i )  #se vuoto
		{
			$rit = 1;	
			$ConfigHash_ptr->{ErrorCode} = 2;
			$ConfigHash_ptr->{ErrorDescription} = 'Errore di parsing della Request: tag vuoto (SourceChannel)';			
		}
    }
    else #il tag NON esiste
    {
    	$rit = 1;	
		$ConfigHash_ptr->{ErrorCode} = 1;
		$ConfigHash_ptr->{ErrorDescription} = 'Errore di parsing della Request: manca un tag (SourceChannel)';
    }
	 
	 
	 
	 
	#DestinationChannel (CREATE=M - UPDATE=M - NOTIFY=M)
	if(exists($rootTagHeader->{DestinationChannel}[1]->{Content}))
    {
    	$RequestHash_prt->{DestinationChannel} = $rootTagHeader->{DestinationChannel}[1]->{Content};
    	
		if($ConfigHash_ptr->{DestinationChannel} =~ m/^\s*$/i ) #se vuoto
		{
			$rit = 1;	
			$ConfigHash_ptr->{ErrorCode} = 2;
			$ConfigHash_ptr->{ErrorDescription} = 'Errore di parsing della Request: tag vuoto (DestinationChannel)';			
		}
    }
    else #il tag NON esiste
    {
    	$rit = 1;	
		$ConfigHash_ptr->{ErrorCode} = 1;
		$ConfigHash_ptr->{ErrorDescription} = 'Errore di parsing della Request: manca un tag (DestinationChannel)';
    }
    
	 
	 
	
	## ------------------------- Request body -------------------------
	#TicketID   (CREATE=M - UPDATE=M - NOTIFY=M)
	#TickedIDWind    (CREATE=M - UPDATE=M - NOTIFY=M)
	#Causale   (CREATE=NO - UPDATE=NO - NOTIFY=O)
	#Action   (CREATE=M - UPDATE=M - NOTIFY=M)
	#Status   (CREATE=M - UPDATE=M - NOTIFY=M)
	#Type   (CREATE=M - UPDATE=NO - NOTIFY=NO)
	#priority    (CREATE=M - UPDATE=O - NOTIFY=NO)
	#CategoryTT   (CREATE=M - UPDATE=NO - NOTIFY=NO)
	#AmbitoTT   (CREATE=M - UPDATE=NO - NOTIFY=NO)
	#Oggetto    (CREATE=M - UPDATE=NO - NOTIFY=NO)
	#Descrizione    (CREATE=M - UPDATE=NO - NOTIFY=NO)
	#TimestampTT   (CREATE=M - UPDATE=NO - NOTIFY=M)
	#startDateMalfunction   (CREATE=O - UPDATE=O - NOTIFY=NO)
	#endDateMalfunction   (CREATE=O - UPDATE=O - NOTIFY=NO)
	#segmentCustomer    (CREATE=O - UPDATE=NO - NOTIFY=NO)
	#msisdn    (CREATE=O - UPDATE=NO - NOTIFY=NO)
	#imsi    (CREATE=O - UPDATE=NO - NOTIFY=NO)
	#iccid    (CREATE=O - UPDATE=NO - NOTIFY=NO),
	#idLinea    (CREATE=O - UPDATE=NO - NOTIFY=NO),
	#tipoLinea    (CREATE=O - UPDATE=NO - NOTIFY=NO)
	#mnpType    (CREATE=O - UPDATE=NO - NOTIFY=NO)
	#imei    (CREATE=O - UPDATE=NO - NOTIFY=NO)
	#ErrorCode     (CREATE=NO - UPDATE=NO - NOTIFY=O)
	#ErrorDesc    (CREATE=NO - UPDATE=NO - NOTIFY=O)
	#ExpDate    (CREATE=NO - UPDATE=NO - NOTIFY=O)
	#Referente   (CREATE=O - UPDATE=NO - NOTIFY=NO)
	#Nota    (CREATE=O - UPDATE=O - NOTIFY=O)
	#address    (CREATE=O - UPDATE=NO - NOTIFY=NO),
	#prov    (CREATE=O - UPDATE=NO - NOTIFY=NO)
	#city    (CREATE=O - UPDATE=NO - NOTIFY=NO)
	#cap    (CREATE=O - UPDATE=NO - NOTIFY=NO)
	#
	## --- Allegati ---
	# TAG lista -> ListOfAttachment  (CREATE=O - UPDATE=O - NOTIFY=O)
	# TAG singolo attachment -> Attachment  (CREATE=O - UPDATE=O - NOTIFY=O)
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
	
	 


}






1;

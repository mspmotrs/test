package MSErrorUtil;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

# Exporting the saluta routine
our @EXPORT = qw(MS_CheckInternalErrorAndSendResponse MS_WhoAmI MS_AssignInternalErrorCode);
# Exporting the saluta2 routine on demand basis.
#our @EXPORT_OK = qw(saluta2);




# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/../cpan-lib";




# ----------------- Moduli custom necessari ------------------
use MSResponseToWindUtil;









#Controlla una struttura che rappresenta eventuali errori, se ne trova si comporta secondo la gravita' dell'errore trovato:
# - errore grave: invia una response e termina l'esecuzione
# - errore normale: logga l'errore e ritorna 1 (non manda response e continua l'esecuzione)
# - nessun errore: ritorna 0
#
# input:  (InfoErrorHash_ptr, LogObject_ptr)
#     InfoErrorHash_ptr = {
#			ExternalCode => 0, # 0 = tutto ok -- da esportare verso Wind
#			ExternalDescr => '',
#		
#			InternalCode => 0, # 0 = tutto ok - uso interno
#			InternalDescr => '', #uso interno
#			StopEsecution => 0, #uso interno - messo ad 1 mi fa chiamare una exit dopo un errore...		
#		}
#
# output:
#     0 = nessun errore, 1 = riscontrato un errore
#
# Nota: puo' chiamare una exit() e terminare l'esecuzione!!
#
sub MS_CheckInternalErrorAndSendResponse
{
	
	my $ErrorHash_ptr = shift;
   my $LogObject_ptr = shift;
   
	
	my $rit = 0;	

	
	if ($ErrorHash_ptr->{InternalCode} != 0)
	{
		$rit = 1;
		
		$LogObject_ptr->Log( Priority => 'error', Message => "_MSFull_ [MS_CheckInternalErrorAndSendResponse]: Rilevato errore interno - InternalCode = $ErrorHash_ptr->{InternalCode}  --  InternalDescr = $ErrorHash_ptr->{InternalDescr}");
		
		if ($ErrorHash_ptr->{StopEsecution})
		{
			$LogObject_ptr->Log( Priority => 'error', Message => "_MSFull_ [MS_CheckInternalErrorAndSendResponse]: L'errore mi costringe a terminare l'esecuzione.");
			
			MS_Response_GenericInternalError_BuildAndSend();
			
			exit(1);
		}
		
	}
	
	
	return $rit;
}






#Ritorna il nome della subroutine che chiama questa sub.
# Es. se in package::pippo si fa una chiamata MS_WhoAmI allora in questo caso
# la MS_WhoAmI restituira' "package::pippo"
sub MS_WhoAmI
{
	return ( caller(1) )[3];
}



#Input :
# - stringa restituita da MS_WhoAmI
# - <numero> che identifica l'errore all'interno della specifica subroutine
#   (Se in una sub ho 2 possibili errori che posso settare:
#     + il primo settera' <numero> = 1
#     + il secondo settera' <numero> = 2
#     + ecc
#)
# - ptr alla var che deve contenere l'internal error code
# - ptr alla var che deve contenere l'internal error descr
#
#Output:
#
#
sub MS_AssignInternalErrorCode
{
	my $subroutineFullName = shift;
	my $cardinalErrorNum = shift;
	my $errorCode_ptr = shift;
	my $errorDescr_ptr = shift;
	
	
	my @PackageAndSubroutine = split(/\:\:/, $subroutineFullName);
	
	
	# ---------------------- Lista codici errori interni -----------
	my $InternalErrorList = {
		
		MSConfigUtil => {
								_error_code_base_ => 10,
								
								MS_LoadAndCheckConfigForWind => {
									_error_code_base_ => 10,
									10 => { descr => "Non trovo la sezione 'PM_Wind_settings' nel Ticket.xml. Interrompo l'esecuzione."},
									20 => { descr => "Non trovo la sezione 'Category_Incident_PM_Wind' nel Ticket.xml. Interrompo l'esecuzione."},
									30 => { descr => "Non trovo la sezione 'Category_Alarm_PM_Wind' nel Ticket.xml. Interrompo l'esecuzione."},
									40 => { descr => "Non trovo la sezione 'Category_Alarm_Wind_PM' nel Ticket.xml. Interrompo l'esecuzione."},
								},
							
							 },
		
		
		MSXMLUtil => {
								_error_code_base_ => 11,
								
								MS_XMLCheckParsing => {
									_error_code_base_ => 10,
									10 => { descr => "Errore imprevisto durante parsing XML" },
									20 => { descr => "L'XML sembra malformato... esco."},
								},
							
							},
		
		
		MSHttpUtil => {
								_error_code_base_ => 12,
								
								MS_ReadHttpPost => {
									_error_code_base_ => 10,
									10 => { descr => "Arrivato qualcosa via HTTP ma non via POST. Interrompo l'esecuzione." },
								}
							},
		
		
		
		MSRequestFromWindActionsUtil => {
								_error_code_base_ => 13,
								
								MS_do_Create => {
									_error_code_base_ => 10,
									10 => { descr => "-1 -> KO (errore durante la creazione dell'Alarm)" },
									20 => { descr => "-2 -> KO (errore durante l'aggiornamento di qualche freetext/freetime)" },
									30 => { descr => "-3 -> KO (errore durante la creazione della nota)" },
									40 => { descr => "-4 -> KO (errore durante la creazione di un allegato)" },
								}
							},
		
	
		MSRequestFromWindUtil => {
								_error_code_base_ => 14,
								
								MS_RequestParsing => {
									_error_code_base_ => 10,
									10 => { descr => "Il parsing XML e' saltato: credo XML malformato. Esco." },
								}
							},
		
	};
	# ---------------------- Lista codici errori interni  (fine) -----------
	
	
	
	
	
	
	
	#Come costruire l'error code:
	# Si concatena _error_code_base_ del package con _error_code_base_ della sub con <numero>
	
	my $errCodeTmp = $InternalErrorList->{$PackageAndSubroutine[0]}->{_error_code_base_};
	$errCodeTmp .= $InternalErrorList->{$PackageAndSubroutine[0]}->{$PackageAndSubroutine[1]}->{_error_code_base_};
	$errCodeTmp .= $cardinalErrorNum;
	
	my $errDescrTmp = $InternalErrorList->{$PackageAndSubroutine[0]}->{$PackageAndSubroutine[1]}->{$cardinalErrorNum}->{descr};
	
	
	
	$$errorCode_ptr = $errCodeTmp;
	$$errorDescr_ptr = $errDescrTmp;
}



1;

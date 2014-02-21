package MSConfigUtil;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

# Exporting the saluta routine
our @EXPORT = qw(MS_LoadAndCheckConfigForWind);
# Exporting the saluta2 routine on demand basis.
#our @EXPORT_OK = qw(saluta2);




# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/../cpan-lib";




# ----------------- Moduli custom necessari ------------------
use MSErrorUtil;







#La configurazione viene gia' caricata dagli oggetti di OTRS, qui vengono settati alcuni puntatori "scorciatoia"
# e fatti alcuni controlli
#
# input:
#     ConfigHash_ptr (instanziato in TTActionReceiver_PMWind.pl)
#     ConfigObject = shift; #opzionale (lo uso all'interno di alcuni controlli prima di aprire un Alarm o un Incident VERSO Wind)
#
# output:
#     <nulla>
#
# Nota: puo' PRENOTARE una exit() per terminare l'esecuzione (ma e' solo una indicazione per la funzione chiamante)
# No
sub MS_LoadAndCheckConfigForWind
{
	
	my $MS_ConfigHash_ptr = shift;
   my $ConfigObject = shift; #opzionale

   $ConfigObject = $MS_ConfigHash_ptr->{OTRS_ConfigObject} if(!defined($ConfigObject) and exists($MS_ConfigHash_ptr->{OTRS_ConfigObject}) );
   $MS_ConfigHash_ptr->{Errors} = {} if(!exists($MS_ConfigHash_ptr->{Errors}));
   $MS_ConfigHash_ptr->{Errors}->{InternalCode} = 0 if(!exists($MS_ConfigHash_ptr->{Errors}->{InternalCode}));
   $MS_ConfigHash_ptr->{Errors}->{InternalDescr} = '' if(!exists($MS_ConfigHash_ptr->{Errors}->{InternalDescr}));
	$MS_ConfigHash_ptr->{Errors}->{StopEsecution} = 0 if(!exists($MS_ConfigHash_ptr->{Errors}->{StopEsecution}));
   $MS_ConfigHash_ptr->{log_prefix} = '_MSFull_' if(!exists($MS_ConfigHash_ptr->{log_prefix}));
   
   
	#Queste conf si trova ne Ticket.xml
	#my %MS_PMWindConfig = %{ $ConfigObject->Get( 'PM_Wind_settings' )};
	
	if (%{ $ConfigObject->Get( 'PM_Wind_settings' )})
	{
		##copio tutti i valori nell'hash che contiene tutte le conf
		#for my $Key ( keys %{ $ConfigObject->Get( 'PM_Wind_settings' )} )
		#{
		#	$MS_ConfigHash_ptr->{$Key} = $ConfigObject->Get( 'PM_Wind_settings' )->{$Key};
		#}
		
		#Alla fine opto per un puntatore 'scorciatoia' alla struttura dati di OTRS
		$MS_ConfigHash_ptr->{PM_Wind_settings} = $ConfigObject->Get( 'PM_Wind_settings' );
		
		#print "\nTEST: ericsson_queue_id = $MS_ConfigHash_ptr->{ericsson_queue_id} \n";
		#print "\nTEST: ericsson_queue_id = $MS_ConfigHash_ptr->{PM_Wind_settings}->{ericsson_queue_id} \n";
	}
	else
	{
		$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "$MS_ConfigHash_ptr->{log_prefix} [ERRORE] Non trovo la sezione 'PM_Wind_settings' nel Ticket.xml. Interrompo l'esecuzione.");
      
      #setto l'errore che verra' controllato nella subroutine a monte...
      MS_AssignInternalErrorCode( MS_WhoAmI(), 10, \$MS_ConfigHash_ptr->{Errors}->{InternalCode}, \$MS_ConfigHash_ptr->{Errors}->{InternalDescr});
      $MS_ConfigHash_ptr->{Errors}->{StopEsecution} = 1; # "prenoto" una exit
      
      #Non forzo la exit qui... lo faro' solo nella gestione dell'errore (modulo MSErrorUtil)
		#exit(1);
	}
	
	
	
	if (%{ $ConfigObject->Get( 'Category_Incident_PM_Wind' )})
	{	
		#Alla fine opto per un puntatore 'scorciatoia' alla struttura dati di OTRS
		$MS_ConfigHash_ptr->{Category_Incident_PM_Wind} = $ConfigObject->Get( 'Category_Incident_PM_Wind' );
	
	}
	else
	{
		$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "$MS_ConfigHash_ptr->{log_prefix} [ERRORE] Non trovo la sezione 'Category_Incident_PM_Wind' nel Ticket.xml. Interrompo l'esecuzione.");
      
      #setto l'errore che verra' controllato nella subroutine a monte...
      MS_AssignInternalErrorCode( MS_WhoAmI(), 20, \$MS_ConfigHash_ptr->{Errors}->{InternalCode}, \$MS_ConfigHash_ptr->{Errors}->{InternalDescr});
      $MS_ConfigHash_ptr->{Errors}->{StopEsecution} = 1; # "prenoto" una exit
      
      #Non forzo la exit qui... lo faro' solo nella gestione dell'errore (modulo MSErrorUtil)
		#exit(1);
	}
	
	
	
	
	if (%{ $ConfigObject->Get( 'Category_Alarm_PM_Wind' )})
	{	
		#Alla fine opto per un puntatore 'scorciatoia' alla struttura dati di OTRS
		$MS_ConfigHash_ptr->{Category_Alarm_PM_Wind} = $ConfigObject->Get( 'Category_Alarm_PM_Wind' );
	
	}
	else
	{
		$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "$MS_ConfigHash_ptr->{log_prefix} [ERRORE] Non trovo la sezione 'Category_Alarm_PM_Wind' nel Ticket.xml. Interrompo l'esecuzione.");
      
      #setto l'errore che verra' controllato nella subroutine a monte...
      MS_AssignInternalErrorCode( MS_WhoAmI(), 30, \$MS_ConfigHash_ptr->{Errors}->{InternalCode}, \$MS_ConfigHash_ptr->{Errors}->{InternalDescr});
      $MS_ConfigHash_ptr->{Errors}->{StopEsecution} = 1; # "prenoto" una exit
      
      #Non forzo la exit qui... lo faro' solo nella gestione dell'errore (modulo MSErrorUtil)
		#exit(1);
	}
	
	
	
	if (%{ $ConfigObject->Get( 'Category_Alarm_Wind_PM' )})
	{	
		#Alla fine opto per un puntatore 'scorciatoia' alla struttura dati di OTRS
		$MS_ConfigHash_ptr->{Category_Alarm_Wind_PM} = $ConfigObject->Get( 'Category_Alarm_Wind_PM' );
	
	}
	else
	{
		$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "$MS_ConfigHash_ptr->{log_prefix} [ERRORE] Non trovo la sezione 'Category_Alarm_Wind_PM' nel Ticket.xml. Interrompo l'esecuzione.");
      
      #setto l'errore che verra' controllato nella subroutine a monte...
      MS_AssignInternalErrorCode( MS_WhoAmI(), 40, \$MS_ConfigHash_ptr->{Errors}->{InternalCode}, \$MS_ConfigHash_ptr->{Errors}->{InternalDescr});
      $MS_ConfigHash_ptr->{Errors}->{StopEsecution} = 1; # "prenoto" una exit
      
      #Non forzo la exit qui... lo faro' solo nella gestione dell'errore (modulo MSErrorUtil)
		#exit(1);
	}
   
   
   
   
	if (%{ $ConfigObject->Get( 'AmbitoTT_PM_Wind' )})
	{	
		$MS_ConfigHash_ptr->{AmbitoTT_PM_Wind} = $ConfigObject->Get( 'AmbitoTT_PM_Wind' );
	
	}
	else
	{
		$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "$MS_ConfigHash_ptr->{log_prefix} [ERRORE] Non trovo la sezione 'AmbitoTT_PM_Wind' nel Ticket.xml. Interrompo l'esecuzione.");
      
      #setto l'errore che verra' controllato nella subroutine a monte...
      MS_AssignInternalErrorCode( MS_WhoAmI(), 40, \$MS_ConfigHash_ptr->{Errors}->{InternalCode}, \$MS_ConfigHash_ptr->{Errors}->{InternalDescr});
      $MS_ConfigHash_ptr->{Errors}->{StopEsecution} = 1; # "prenoto" una exit
	}

}





1;

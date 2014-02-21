package MSRequestFromWindActionsUtil;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

# Exporting the saluta routine
our @EXPORT = qw(MS_do_action);
# Exporting the saluta2 routine on demand basis.
#our @EXPORT_OK = qw(saluta2);




# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/../cpan-lib";




# ----------------- Moduli custom necessari ------------------
use MSTicketUtil;
use MSErrorUtil;
# ----------------- Moduli custom necessari (fine) ------------------






#Esamina la Request e richiama la sub corretta
#ritorna:
# 0 -> se ERRORE
# 1 -> se ok
sub MS_do_action
{
   my $MS_ConfigHash_ptr = shift;
	#$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "************ do ACTION chiamata *********");
	my $rit = 0;
	
	if(exists($MS_ConfigHash_ptr->{RequestHash}))
	{	
		if($MS_ConfigHash_ptr->{RequestHash}->{RequestType} eq $MS_ConfigHash_ptr->{RequestHash}->{RequestTypeCREATE})
		{
			$rit = MS_do_Create($MS_ConfigHash_ptr);
		}
		elsif($MS_ConfigHash_ptr->{RequestHash}->{RequestType} eq $MS_ConfigHash_ptr->{RequestHash}->{RequestTypeUPDATE})
		{
			$rit = MS_do_Update($MS_ConfigHash_ptr);
		}
		elsif($MS_ConfigHash_ptr->{RequestHash}->{RequestType} eq $MS_ConfigHash_ptr->{RequestHash}->{RequestTypeNOTIFY})
		{
			#$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "************ do ACTION chiama NOTIFY *********");
			$rit = MS_do_Notify($MS_ConfigHash_ptr);
		}
		else
		{
			if($MS_ConfigHash_ptr->{PM_Wind_settings}->{log_level} >= 1)
			{
					$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "$MS_ConfigHash_ptr->{log_prefix} [WARNING] Chiamata MS_do_action() su una Request ma il tipo della request non risulta conosciuto: $MS_ConfigHash_ptr->{RequestHash}->{RequestType}");
			}
		}
	}
	

	return $rit;
}






#gestisce l'esecuzione della Create
#ritorna:
# 0 -> se ERRORE
# 1 -> se ok
sub MS_do_Create
{	
   my $MS_ConfigHash_ptr = shift;

	my $rit = 0;
	
	if(exists($MS_ConfigHash_ptr->{RequestHash}))
	{

		my $result = MS_CreateAlarm($MS_ConfigHash_ptr);
		
		if ($result > 0) #Alarm creato interamente con successo -> Alarm_ID = $result
		{
			$MS_ConfigHash_ptr->{NewAlarmID} = $result;
			$rit = 1; # -> ok
		}
		else
		{
			my $sub_err_identity_number = 0;
			if ($result == -1) # -1 -> KO (errore durante la creazione dell'Alarm)
			{
				$sub_err_identity_number = 10;
			}
			elsif ($result == -2) # -2 -> KO (errore durante l'aggiornamento di qualche freetext/freetime)
			{
				$MS_ConfigHash_ptr->{NewAlarmID} = $result;
				$sub_err_identity_number = 20;
			}
			elsif ($result == -3) # -3 -> KO (errore durante la creazione della nota)
			{
				$MS_ConfigHash_ptr->{NewAlarmID} = $result;
				$sub_err_identity_number = 30;
			}
			elsif ($result == -4) # -4 -> KO (errore durante la creazione di un allegato)
			{
				$MS_ConfigHash_ptr->{NewAlarmID} = $result;
				$sub_err_identity_number = 40;
			}
			
			#my $LogObj_ptr = $MS_ConfigHash_ptr->{OTRS_LogObject};
			#$LogObj_ptr->Log( Priority => 'notice', Message => "---------------------- MS_do_Create  chiamata ----");
			#setto l'errore che verra' controllato nella subroutine a monte...
			MS_AssignInternalErrorCode( MS_WhoAmI(), $sub_err_identity_number, \$MS_ConfigHash_ptr->{Errors}->{InternalCode}, \$MS_ConfigHash_ptr->{Errors}->{InternalDescr});
			#$errors_ptr->{StopEsecution} = 1; # "prenoto" una exit
			#$LogObj_ptr->Log( Priority => 'notice', Message => "---------------------- MS_do_Create  fine ----");
		}

		
	}
	
	return $rit;
}




#gestisce l'esecuzione della Update
#ritorna:
# 0 -> se ERRORE
# 1 -> se ok
sub MS_do_Update
{	
   my $MS_ConfigHash_ptr = shift;
	
	my $rit = 0;

	if(exists($MS_ConfigHash_ptr->{RequestHash}))
	{
		my $result = MS_UpdateObject($MS_ConfigHash_ptr);
		
		$MS_ConfigHash_ptr->{StatusToSendOnUpdate} = 'APERTO'; #sembra che ora sia richiesto anche questo
	}

	return $rit;
}



#gestisce l'esecuzione della Notify
#ritorna:
# 0 -> se ERRORE
# 1 -> se ok
sub MS_do_Notify
{	
   my $MS_ConfigHash_ptr = shift;

	my $rit = 0;
	
	if(exists($MS_ConfigHash_ptr->{RequestHash}))
	{
		my $result = MS_NotifyObject($MS_ConfigHash_ptr);
	}

	return $rit;
}





1;

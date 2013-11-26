package MSRequestFromWindActionsUtil;
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
use MSTicketUtil;
# ----------------- Moduli custom necessari (fine) ------------------






#Esamina la Request e richiama la sub corretta
sub MS_do_action
{	
   my $MS_ConfigHash_ptr = shift;

	if(exists($MS_ConfigHash_ptr->{RequestHash}))
	{	
		if($MS_ConfigHash_ptr->{RequestHash}->{RequestType} eq $MS_ConfigHash_ptr->{RequestHash}->{RequestTypeCREATE})
		{
			MS_do_Create($MS_ConfigHash_ptr);
		}
		elsif($MS_ConfigHash_ptr->{RequestHash}->{RequestType} eq $MS_ConfigHash_ptr->{RequestHash}->{RequestTypeUPDATE})
		{
			MS_do_Update($MS_ConfigHash_ptr);
		}
		elsif($MS_ConfigHash_ptr->{RequestHash}->{RequestType} eq $MS_ConfigHash_ptr->{RequestHash}->{RequestTypeNOTIFY})
		{
			MS_do_Notify($MS_ConfigHash_ptr);
		}
		else
		{
			if($MS_ConfigHash_ptr->{PM_Wind_settings}->{log_level} >= 2)
			{
					$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'error', Message => "$MS_ConfigHash_ptr->{log_prefix} [WARNING] Chiamata MS_do_action() su una Request ma il tipo della request non risulta conosciuto: $MS_ConfigHash_ptr->{RequestHash}->{RequestType}");
			}
		}
	}
	


}






#gestisce l'esecuzione della Create
sub MS_do_Create
{	
   my $MS_ConfigHash_ptr = shift;

	if(exists($MS_ConfigHash_ptr->{RequestHash}))
	{

	}


}




#gestisce l'esecuzione della Update
sub MS_do_Update
{	
   my $MS_ConfigHash_ptr = shift;

	if(exists($MS_ConfigHash_ptr->{RequestHash}))
	{

	}


}



#gestisce l'esecuzione della Notify
sub MS_do_Notify
{	
   my $MS_ConfigHash_ptr = shift;

	if(exists($MS_ConfigHash_ptr->{RequestHash}))
	{

	}


}


1;

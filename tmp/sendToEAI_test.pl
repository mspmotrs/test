#!/usr/bin/perl -w

use strict;
use warnings;




## --- MS: questi path presuppongono che questo eseguibile si trova in <OTRS_path>bin/cgi-bin ---
# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin/../..";
use lib "$Bin/../../Kernel/pm_wind"; #MS: per i miei moduli custom
use lib "$Bin/../../Kernel/cpan-lib";

# use vars qw($VERSION @INC);
# $VERSION = qw($Revision: 1.88 $) [1];

# check @INC for mod_perl (add lib path for "require module"!)
push( @INC, "$Bin/../..", "$Bin/../../Kernel/cpan-lib" , "$Bin/../../Kernel/pm_wind" ); #MS: compresi i miei moduli custom



#----------------------------------------------------------

my $ticket_id = 1111;
my $RequestType = 'CREATE'; #CREATE, UPDATE, NOTIFY
my $WindTicketType = 'INCIDENT'; #INCIDENT, ALARM


$ticket_id = $ARGV[0] if (defined($ARGV[0]) and $ARGV[0] =~ m/^\d+$/);
$RequestType = $ARGV[1] if (defined($ARGV[1]) and $ARGV[1] =~ m/^(?:CREATE|UPDATE|NOTIFY)$/);
$WindTicketType = $ARGV[2] if (defined($ARGV[2]) and $ARGV[2] =~ m/^(?:INCIDENT|ALARM)$/);






# ----------------- Moduli custom necessari ------------------
#use MSErrorUtil;
#use MSConfigUtil;
#use MSHttpUtil;
use MSRequestToWindUtil;
use MSResponseFromWindUtil;










# ----------------- Inizializzazione oggetti OTRS ------------------

	use Kernel::Config;
	use Kernel::System::Encode;
	use Kernel::System::Log;
	use Kernel::System::Main;
	use Kernel::System::DB;

	use Kernel::System::XML;

	use Kernel::System::Time;
	use Kernel::System::Ticket;




	my $ConfigObject = Kernel::Config->new();
	my $EncodeObject = Kernel::System::Encode->new(
		ConfigObject => $ConfigObject,
	);
	my $LogObject = Kernel::System::Log->new(
		ConfigObject => $ConfigObject,
		EncodeObject => $EncodeObject,
	);
	my $MainObject = Kernel::System::Main->new(
		ConfigObject => $ConfigObject,
		EncodeObject => $EncodeObject,
		LogObject    => $LogObject,
	);
	my $DBObject = Kernel::System::DB->new(
		ConfigObject => $ConfigObject,
		EncodeObject => $EncodeObject,
		LogObject    => $LogObject,
		MainObject   => $MainObject,
	);
	
	
	
	my $TimeObject = Kernel::System::Time->new(
		ConfigObject => $ConfigObject,
		LogObject    => $LogObject,
	);
          


    my $TicketObject = Kernel::System::Ticket->new(
        ConfigObject => $ConfigObject,
        LogObject    => $LogObject,
        DBObject     => $DBObject,
        MainObject   => $MainObject,
        TimeObject   => $TimeObject,
        EncodeObject => $EncodeObject,
        #GroupObject  => $GroupObject,              # if given
        #CustomerUserObject => $CustomerUserObject, # if given
        #QueueObject        => $QueueObject,        # if given
    );








my $rit1 = MS_RequestBuildAndSend($ticket_id, $TicketObject, $RequestType, $WindTicketType);


print "\n----- Ricorda che puoi usarlo in questo modo: ./sendToEAI_test.pl ticketID requestType windObjectType -----";
if ($rit1 == 1)
{
	 print "\nRisultato => OK\n\n";
}
else
{
	 print "\nRisultato => ERRORE!\n\n";
}








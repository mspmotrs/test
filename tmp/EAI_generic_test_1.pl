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






# ----------------- Moduli custom necessari ------------------
use MSErrorUtil;
use MSConfigUtil;
use MSHttpUtil;
#use MSRequestFromWindUtil;
use MSResponseToWindUtil;
use MSRequestFromWindActionsUtil;

# ----------------- Moduli custom necessari ------------------
use MSTicketUtil;



use MIME::Base64;

my $MS_DEBUG = 0;








# ----------------- Inizializzazione oggetti OTRS ------------------

	use Kernel::Config;
	use Kernel::System::Encode;
	use Kernel::System::Log;
	use Kernel::System::Main;
	use Kernel::System::DB;

	use Kernel::System::XML;

	use Kernel::System::Time;
	use Kernel::System::Ticket;




	my $MS_ConfigObject = Kernel::Config->new();
	my $MS_EncodeObject = Kernel::System::Encode->new(
		ConfigObject => $MS_ConfigObject,
	);
	my $MS_LogObject = Kernel::System::Log->new(
		ConfigObject => $MS_ConfigObject,
		EncodeObject => $MS_EncodeObject,
	);
	my $MS_MainObject = Kernel::System::Main->new(
		ConfigObject => $MS_ConfigObject,
		EncodeObject => $MS_EncodeObject,
		LogObject    => $MS_LogObject,
	);
	my $MS_DBObject = Kernel::System::DB->new(
		ConfigObject => $MS_ConfigObject,
		EncodeObject => $MS_EncodeObject,
		LogObject    => $MS_LogObject,
		MainObject   => $MS_MainObject,
	);
	
	
	
	my $MS_TimeObject = Kernel::System::Time->new(
		ConfigObject => $MS_ConfigObject,
		LogObject    => $MS_LogObject,
	);
          


    my $MS_TicketObject = Kernel::System::Ticket->new(
        ConfigObject => $MS_ConfigObject,
        LogObject    => $MS_LogObject,
        DBObject     => $MS_DBObject,
        MainObject   => $MS_MainObject,
        TimeObject   => $MS_TimeObject,
        EncodeObject => $MS_EncodeObject,
        #GroupObject  => $GroupObject,              # if given
        #CustomerUserObject => $CustomerUserObject, # if given
        #QueueObject        => $QueueObject,        # if given
    );



						

						
		my $MS_XMLObject = Kernel::System::XML->new(
																	ConfigObject => $MS_ConfigObject,
																	LogObject    => $MS_LogObject,
																	DBObject     => $MS_DBObject,
																	MainObject   => $MS_MainObject,
																	EncodeObject => $MS_EncodeObject,
															  );



my %MS_ConfigHash = (
OTRS_XMLObject => $MS_XMLObject,
OTRS_ConfigObject => $MS_ConfigObject,
OTRS_LogObject => $MS_LogObject,
OTRS_DBObject => $MS_DBObject,
OTRS_MainObject => $MS_MainObject,
OTRS_EncodeObject => $MS_EncodeObject,
OTRS_TicketObject => $MS_TicketObject,
);


$MS_ConfigHash{RequestHash} = {
							RequestTypeCREATE => 'CREATE',
							RequestTypeUPDATE => 'UPDATE',
							RequestTypeNOTIFY => 'NOTIFY',
							RequestType => '', #CREATE, UPDATE, NOTIFY --> RequestTypeCREATE, RequestTypeUPDATE, RequestTypeNOTIFY
							RequestContent => '', #il contenuto della request cosi' come arriva al server
							RequestErrorCode => 0, # 0 = tutto ok 
							RequestErrorDescr => '',
							
							TicketID_is_a_TN => 1, #ad 1 se con Wind scambiamo il TN del ticket invece del suo ID
};



my $ConfigHash_ptr = \%MS_ConfigHash;
my $output = {};

my $test = MS_TicketGetInfoShort( '2014013110000011', 1, $ConfigHash_ptr->{OTRS_DBObject}, $output);

print "\n\n$test\n\n";

use Data::Dumper;
print Dumper($output);














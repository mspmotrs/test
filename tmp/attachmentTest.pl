#!/usr/bin/perl -w

use strict;
use warnings;

# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin/../..";
use lib "$Bin/../../Kernel/cpan-lib";

# use vars qw($VERSION @INC);
# $VERSION = qw($Revision: 1.88 $) [1];

# check @INC for mod_perl (add lib path for "require module"!)
push( @INC, "$Bin/../..", "$Bin/../../Kernel/cpan-lib" );





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
    
    
    




my $ticket_id = 7679;
$ticket_id = $ARGV[0] if (defined($ARGV[0]) and $ARGV[0] =~ m/^\d+$/);


my $articleID = 0;


	my $query = 'SELECT max(id) as id ';
	$query .= ' FROM article ';
	$query .= " WHERE ticket_id=$ticket_id ";

	eval 
	{  
		$DBObject->Prepare(
			  SQL   => $query,
			  Limit => 1
		 );
		 my @Row = $DBObject->FetchrowArray();
		 
		 if (scalar(@Row))
		 {			
			$articleID = $Row[0];
		 }
		 
		print "\narticleID = $articleID" ;
		print "\n\n";
	};





        my %Article = $TicketObject->ArticleGet(
            ArticleID => $articleID,
            #UserID    => 123,
        );
        
        
        
        use Data::Dumper;
        print "\n\n".Dumper(\%Article)."\n\n";


    #get article attachment index as hash (ID => hashref (Filename, Filesize, ContentID (if exists), ContentAlternative(if exists) )) 
        my %IndexOfAttachments = $TicketObject->ArticleAttachmentIndex(
            ArticleID => $articleID,
            #UserID    => 123,
        );

		print "\n\n\n\n".Dumper(\%IndexOfAttachments)."\n\n";





    #get article attachment (Content, ContentType, Filename and optional ContentID, ContentAlternative) 

#        my %Attachment = $TicketObject->ArticleAttachment(
#            ArticleID => $articleID,
#            FileID    => 1,
#            #UserID    => 123,
#        );
#
#
#
#	print "\n\n\n\n".Dumper(\%Attachment)."\n\n";












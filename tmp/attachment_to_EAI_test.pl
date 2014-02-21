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
#use MSErrorUtil;
#use MSConfigUtil;
#use MSHttpUtil;
#use MSXMLUtil;
#use MSRequestToWindUtil;
#use MSResponseFromWindUtil;
#use MSTicketUtil;

# ----------------- Moduli custom necessari ------------------
#use MSErrorUtil;

use MIME::Base64;









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



my $TicketHash_ptr = {};
#$TicketHash_ptr->{ResponseHash} = {};

$TicketHash_ptr->{OTRS_XMLObject} = $MS_XMLObject;
$TicketHash_ptr->{OTRS_ConfigObject} = $MS_ConfigObject;
$TicketHash_ptr->{OTRS_LogObject} = $MS_LogObject;
$TicketHash_ptr->{OTRS_DBObject} = $MS_DBObject;
$TicketHash_ptr->{OTRS_MainObject} = $MS_MainObject;
$TicketHash_ptr->{OTRS_EncodeObject} = $MS_EncodeObject;
$TicketHash_ptr->{OTRS_TicketObject} = $MS_TicketObject;






my $t = 6064;
my $typ = 27;

				$MS_DBObject->Prepare(
								SQL => "select name from ticket_history where id = (select MAX(id) from ticket_history where ticket_id = $t and history_type_id = $typ  and (name LIKE '%pending auto close-\%\%' or name LIKE '%pending auto close+\%\%' or name LIKE '%pending reminder\%\%'))",
				);	
my @RowHistory = $MS_DBObject->FetchrowArray();
print "\n\n*****|$RowHistory[0]|*****\n\n";



            #my $tmp_string_name = '%%ciao%%miao%%';
            my $tmp_string_name = '%%pending reminder%%closed unsuccessful inf%%';
            my $historyID_risoluzione = 39305;
            my $t_id = 6021;
            
            #aggiorno direttamente le righe di history che dovrei cancellare...
            if ($historyID_risoluzione > 0 )
            {
                $MS_DBObject->Do(
                            SQL => "UPDATE ticket_history SET name = ? WHERE id = ? and ticket_id = ?",
                            Bind => [ \$tmp_string_name, \$historyID_risoluzione, \$t_id ],
                );
            }











#ticket = 6090, article = 5679
$TicketHash_ptr->{RequestHash} = {};
my $attachments_rit = MS_GetArticleAttachments(5695, $MS_TicketObject, $TicketHash_ptr->{RequestHash});

print "attachments_rit=$attachments_rit\n";
#$tmp_attach_ptr->{RequestHash}->{AttachedFiles}


		#my $tmp_attach_ptr = {};
		##$tmp_attach_ptr->{RequestHash} = {};
		#my $attachments2_rit = MS_GetArticleAttachments(5679, $MS_TicketObject, $tmp_attach_ptr->{RequestHash});
		#if ($attachments_rit > 0 or $attachments2_rit > 0 ) #unisco gli allegati della nota di creazione a quelli della nota per Wind
		#{
		#	my @tmp_array_attach_ptr = @{$tmp_attach_ptr->{RequestHash}->{AttachedFiles}};
		#	for(my $kkk=0; $kkk<scalar(@tmp_array_attach_ptr) ; $kkk++)
		#	{
		#		push(@{$TicketHash_ptr->{RequestHash}->{AttachedFiles}}, $tmp_array_attach_ptr[$kkk]);
		#	}
		#}



use Data::Dumper;
#print "\n\n".Dumper($TicketHash_ptr->{RequestHash})."\n\n";

#print "\n\n".Dumper($TicketHash_ptr->{RequestHash}->{AttachedFiles}->[0])."\n\n";
print "\n\n".Dumper($TicketHash_ptr->{RequestHash}->{AttachedFiles}->[1])."\n\n";


for(my $ff=0; $ff < scalar(@{$TicketHash_ptr->{RequestHash}->{AttachedFiles}}); $ff++)
{
   if ($TicketHash_ptr->{RequestHash}->{AttachedFiles}->[$ff]->{Filename} eq '2014020310000017.docx')
   {
      my $myContent = $TicketHash_ptr->{RequestHash}->{AttachedFiles}->[$ff]->{Content};
      my $myLength = length($myContent);
      my $checkVar = 0;
      my $encodedContent = '';
      my $lungSpezzone = 57; #60*57; #vedi doc su MIME::Base64 e grossi file 
      while ($checkVar < $myLength)
      {
         my $partial = substr($myContent,$checkVar,$lungSpezzone);
         $checkVar += $lungSpezzone;
         $encodedContent .= encode_base64($partial,'');
      }
      
      
      #my $testEncoding = encode_base64();
      my $testEncoding = decode_base64($encodedContent);
      my $nome_file = 'AAA_prova_docx.docx';
      open(USCITA, "> $nome_file") or die "\nNon riesco ad aprire il file $nome_file \n";
      #print USCITA $TicketHash_ptr->{RequestHash}->{AttachedFiles}->[$ff]->{Content};
      print USCITA $testEncoding;
      close(USCITA);
   }
}



sub MS_GetArticleAttachments
{
	my $articleID = shift;
   my $MS_TicketObject_ptr = shift;
	my $AttachmentsHashContainer_ptr = shift;

	my $rit = 0;
   print "debug 1\n" if (defined($articleID) and ($articleID !~ m/^\s*$/) and ($articleID > 0) );
   print "debug 2\n" if (defined($MS_TicketObject_ptr) );
   print "debug 3\n" if (defined($AttachmentsHashContainer_ptr) );
	
	if (defined($articleID) and ($articleID !~ m/^\s*$/) and ($articleID > 0) and defined($MS_TicketObject_ptr) and defined($AttachmentsHashContainer_ptr) )
	{

      print "1\n";
		eval 
		{  
			#get article attachment index as hash (ID => hashref (Filename, Filesize, ContentID (if exists), ContentAlternative(if exists) )) 
			my %IndexOfAttachments = $MS_TicketObject_ptr->ArticleAttachmentIndex(
				 ArticleID => $articleID,
				 #UserID    => 123,
			);

         print "\n\n".Dumper(\%IndexOfAttachments)."\n\n";
			
			## --- Allegati ---
			#AttachedFiles => [
			#							{                           A T T E N Z I O N E
			#								FullFileName => '',   ----> qui ---> Filename
			#								TypeFile => '',       ----> qui ---> ContentType
			#								dataCreazione => '',  ----> qui ---> <mancante>
			#								FileBody => '',       ----> qui ---> Content
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
			
			
			$AttachmentsHashContainer_ptr->{AttachedFiles} = [];
			
			my $count = 0;
			foreach my $key (keys(%IndexOfAttachments))
			{
				#salto l'allegato di default sempre presente
				next if ($key eq '1');
				
				
				#get article attachment (Content, ContentType, Filename and optional ContentID, ContentAlternative) 
				%{$AttachmentsHashContainer_ptr->{AttachedFiles}->[$count]} = $MS_TicketObject_ptr->ArticleAttachment(
					 ArticleID => $articleID,
					 FileID    => $key,
					 #UserID    => 123,
				);
				
				#lo aggiungo ma non dovrebbe servire...
				$AttachmentsHashContainer_ptr->{AttachedFiles}->[$count]->{Filesize} = $IndexOfAttachments{$key}->{Filesize};
				
				$count++;
			}
			
			$rit = $count;
		};
		if($@)
		{
			#gestione errore
			$rit = 0;
		}
		

	}
	
	return $rit;
}















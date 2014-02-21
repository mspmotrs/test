# --
# Kernel/System/Ticket/Acl/CheckNoteForWind.pm - acl module
# - Check sulla presenza di ultima nota di tipo "Nota esterna per Wind". Se l'ultima nota non è del tipo richiesto non viene mostrata
#   la coda Wind-OUT nella Move.
# --
# $Id: CheckNoteForWind.pm,v 1.0 2013/12/11 11:11:11 MDL Exp $
# --
# --

package Kernel::System::Ticket::Acl::CheckNoteForWind;




## --- MS: questi path presuppongono che questo eseguibile si trova in <OTRS_path>bin/cgi-bin ---
# use ../../ as lib location
use FindBin qw($Bin);
#use lib "$Bin/../..";
use lib "$Bin/../../../pm_wind"; #MS: per i miei moduli custom
#use lib "$Bin/../../Kernel/cpan-lib";

# use vars qw($VERSION @INC);
# $VERSION = qw($Revision: 1.88 $) [1];

# check @INC for mod_perl (add lib path for "require module"!)
#push( @INC, "$Bin/../..", "$Bin/../../Kernel/cpan-lib" , "$Bin/../../Kernel/pm_wind" ); #MS: compresi i miei moduli custom
push( @INC, "$Bin/../../../pm_wind" ); #MS: compresi i miei moduli custom




use strict;
use warnings;

# ----------------- Moduli custom necessari ------------------
use MSTicketUtil;






use vars qw($VERSION);
$VERSION = qw($Revision: 1.0 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for (
        qw(ConfigObject DBObject TicketObject LogObject UserObject CustomerUserObject MainObject TimeObject EncodeObject)
        )
    {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;
    # check needed stuff
    for (qw(Config Acl)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # check if child tickets are not closed
    #return 1 if (!$Param{TicketID} || !$Param{UserID});CR Se si applica questa condizione non viene eseguita la ACL quando il ticket Ë in fase di creazione
    return 1 if ($Param{CustomerUserID}); # Questa ACL non si applica per i customer


    # get ticket
    my %Ticket = $Self->{TicketObject}->TicketGet(
        TicketID => $Param{TicketID},
    );
   
    my $tmpHash = {};
    my $checkResult = MSTicketUtil::MS_CheckIfExistsFreshArticleForWind($Ticket{TicketID}, $Self->{DBObject}, $tmpHash);
   
   
    $Self->{DBObject}->Prepare(
        SQL => 'SELECT a.id, a.article_type_id FROM article a, article_type at WHERE '
            . ' a.article_type_id = at.id '
            . ' AND a.ticket_id       = ? AND a.note_row_id is null ORDER BY a.id DESC',
        Bind => [ \$Param{TicketID}, ],
    );

    my @Row = $Self->{DBObject}->FetchrowArray();
 
    $Self->{LogObject}->Log( Priority => 'error', Message => "Move verso $Row[1]" ); 
  #  if ( $Row[1] ne '15' )
  #  {
  #     $Self->{LogObject}->Log( Priority => 'error', Message => "Move verso PosteItaliane-OUT NON possibile." );
  #  } 
 
    #CR1686 - Se ultima nota NON e' di tipo "Nota esterna per PI" NON e' mostrata la coda PosteItaliane-OUT.
    if ( !$Row[1] || $Row[1] ne '15' && ( $Ticket{Queue} ne 'PosteItaliane-OUT-Alarm' ) ){
      $Self->{LogObject}->Log( Priority => 'info', Message => "ACL Check Note $Row[1] Called on $Ticket{TicketNumber} with $Ticket{State} - $Ticket{StateType}." ); 
        $Param{Acl}->{CheckNotePI} = {

            # match properties
            Properties => {

                # current ticket match properties
                Ticket => {
                    TicketID => [ $Param{TicketID} ],
                },
            },

            # return possible options (black list)
            PossibleNot => {
                # possible ticket options (black list)
                Ticket => {
                    Queue => ['PosteItaliane-OUT', 'PosteItaliane-OUT-Alarm'],
                },
            },

            # return possible options (white list)
            Possible => {

                # possible action options
            },
        };
    }
    
    
    return 1;
}

1;

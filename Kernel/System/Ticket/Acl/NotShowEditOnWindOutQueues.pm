# --
# Kernel/System/Ticket/Acl/NotShowEditOnWindOutQueues.pm - acl module
# - Ambito FULL by MS -
# --
# $Id: NotShowEditOnWindOutQueues.pm,v 1.14 2014/01/10 10:00:00 cresh Exp $
# --
# --

package Kernel::System::Ticket::Acl::NotShowEditOnWindOutQueues;

use strict;
use warnings;

###use Kernel::System::LinkObject;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.00 $) [1];

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
    return 1 if !$Param{TicketID} || !$Param{UserID};

    my ( $Package1, $Filename1, $Line1, $Subroutine1 ) = caller( 0 );
    my ( $Package2, $Filename2, $Line2, $Subroutine2 ) = caller( 1 );

    #Check if the AgentTicketZoom module is a caller
    #if ( $Package1 ne 'Kernel::Modules::AgentTicketZoom' &&
    #     $Package2 ne 'Kernel::Modules::AgentTicketZoom' 
    #   ) 
    #{
    #    return 1;
    #}
       
    # get ticket
    my %Ticket = $Self->{TicketObject}->TicketGet(
        TicketID => $Param{TicketID},
    );

    #$Self->{LogObject}->Log( Priority => 'notice', Message => "*************** ACL NotShowEditOnWindOutQueues Called on $Param{TicketID} with $Ticket{StateType} -> $Param{Action}." );
    #$Self->{LogObject}->Log( Priority => 'info', Message => "Caller $Package1, $Filename1, $Line1, $Subroutine1." );
    #$Self->{LogObject}->Log( Priority => 'info', Message => "Caller $Package2, $Filename2, $Line2, $Subroutine2." );

    #my $ClosableTickets = $Ticket{StateType} eq 'pending reminder' ||
     #                     $Ticket{StateType} eq 'pending auto' || $Ticket{StateType} eq 'closed';

    # generate acl
    #if ($ClosableTickets) {
    # $Self->{LogObject}->Log( Priority => 'info', Message => "ACL Called on $Ticket{TicketNumber} with $Ticket{StateType}." ); 
	
   my $MS_PM_Wind_settings_ptr = $Self->{ConfigObject}->Get( 'PM_Wind_settings' );
   
    #MS_nota: le acl vengono orginate numericamente per nome prima di essere eseguite.
    #         Voglio che questa venga eseguita in fondo alla lista insieme alla gemella per gli Alarm da Wind  
	$Param{Acl}->{ZZZNotShowEditOnWindOutQueues} = {
		# match properties
		Properties => {
			#Frontend => {
			#	Action => ['AgentTicketZoom'],
			#},
			#User => {
			#	#Group_rw => [
			#	#'PM-Comunicazione','PM-Commerciale','PM-Logistica','PM-Technology-CRN','CRN-Manutenzione1','CRN-Manutenzione2','CRN-Manutenzione3','Fornitore1','Fornitore2','Fornitore3','CORNER'
			#	#],
			#	#Role => [
			#	#	'OTRS-System-CORNER','PM-Comunicazione','PM-Commerciale','PM-Logistica','PM-Technology-CRN','Fornitore1','Fornitore2','Fornitore3','PM-Acquisti',
			#	#],
			#},
			# current ticket match properties
			Ticket => {
				#TicketID => [ $Param{TicketID} ],
				#Queue => ['WIND-OUT','WIND-OUT[ERICSSON]'],
				#State => ['pending reminder','pending auto close+','pending auto close-','closed successful','closed unsuccessful','closed unsuccessful inf'],
            #TypeID => [ $MS_PM_Wind_settings_ptr->{ticketTypeID_AlarmFromWind} ],
            QueueID => [$MS_PM_Wind_settings_ptr->{queue_id_incident_for_wind}, $MS_PM_Wind_settings_ptr->{queue_id_ERICSSON_PM_WIND_OUT}],
			},
		},
		# return possible options (black list)
		#PossibleNot => {
		#	# possible ticket options (black list)
		#	#Ticket => {
		#	#    State => $Param{Config}->{ClosingState},
		#	#},
		#},
		# return possible options (white list)
		Possible => {
			# possible action options
			Action => {
				AgentTicketLock        => 0,
				AgentTicketZoom        => 1,
				AgentTicketClose       => 0,
				AgentTicketPending     => 0,
				AgentTicketNote        => 0,
				AgentTicketHistory     => 1,
				AgentTicketPriority    => 0,
				AgentTicketFreeText    => 0,
				AgentTicketCompose     => 0,
				AgentTicketBounce      => 0,
				AgentTicketForward     => 0,
				AgentLinkObject        => 0,
				AgentTicketPrint       => 1,
				AgentTicketPhone       => 0, # only used to hide the Split action
				AgentTicketCustomer    => 0,
				AgentTicketOwner       => 0,
				AgentTicketResponsible => 0,
            AgentTicketMerge => 0,
            AgentTicketLink => 0,
            AgentTicketMove => 0,
            AgentObjectLink => 0,
			},
         
        Ticket => {
            #Queue => ['Alert'],
            QueueID => [$MS_PM_Wind_settings_ptr->{queue_id_incident_for_wind}, $MS_PM_Wind_settings_ptr->{queue_id_ERICSSON_PM_WIND_OUT}],
        },
		},
      
		# remove options (black list)
		PossibleNot => {
			# possible action options
			Action => {
				AgentTicketLock        => 1,
				AgentTicketZoom        => 0,
				AgentTicketClose       => 1,
				AgentTicketPending     => 1,
				AgentTicketNote        => 1,
				AgentTicketHistory     => 1,
				AgentTicketPriority    => 1,
				AgentTicketFreeText    => 1,
				AgentTicketCompose     => 1,
				AgentTicketBounce      => 1,
				AgentTicketForward     => 1,
				AgentLinkObject        => 1,
				AgentTicketPrint       => 0,
				AgentTicketPhone       => 1,
				AgentTicketCustomer    => 1,
				AgentTicketOwner       => 1,
				AgentTicketResponsible => 1,
            AgentTicketMerge => 1,
            AgentTicketLink => 1,
            AgentTicketTicketLink => 1,
            AgentTicketMove => 1,
            AgentObjectLink => 1,
			},
		},
	};

    return 1;
}

1;


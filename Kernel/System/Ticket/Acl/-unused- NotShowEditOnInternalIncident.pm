# --
# Kernel/System/Ticket/Acl/NotShowEditOnInternalIncident.pm - acl module
# - Ambito FULL by MS -
# --
# $Id: NotShowEditOnInternalIncident.pm,v 1.14 2014/01/10 10:00:00 cresh Exp $
# --
# --

package Kernel::System::Ticket::Acl::NotShowEditOnInternalIncident;

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

    #$Self->{LogObject}->Log( Priority => 'notice', Message => "*************** ACL NotShowEditOnInternalIncident Called on $Param{TicketID} with $Ticket{StateType} -> $Param{Action}." );
    #$Self->{LogObject}->Log( Priority => 'info', Message => "Caller $Package1, $Filename1, $Line1, $Subroutine1." );
    #$Self->{LogObject}->Log( Priority => 'info', Message => "Caller $Package2, $Filename2, $Line2, $Subroutine2." );

    #my $ClosableTickets = $Ticket{StateType} eq 'pending reminder' ||
     #                     $Ticket{StateType} eq 'pending auto' || $Ticket{StateType} eq 'closed';

    # generate acl
    #if ($ClosableTickets) {
    # $Self->{LogObject}->Log( Priority => 'info', Message => "ACL Called on $Ticket{TicketNumber} with $Ticket{StateType}." ); 
	
   my $MS_PM_Wind_settings_ptr = $Self->{ConfigObject}->Get( 'PM_Wind_settings' );
   
    #MS_nota: Incident to Pm -> le acl ZZZNotShowEditOnInternalIncidentToPm1 e ZZZNotShowEditOnInternalIncidentToPm2 lavorano in coppia e in ordine
	$Param{Acl}->{ZZZZNotShowEditOnInternalIncidentToPm1} = {
		# match properties
		Properties => {

         User => {
            Role => [
                'ERICSSON',
            ],
         },
         
			# current ticket match properties
			Ticket => {
            TypeID => [ $MS_PM_Wind_settings_ptr->{ticketTypeID_IncidentToPM} ],
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

   
   
   
   
   
	$Param{Acl}->{ZZZZNotShowEditOnInternalIncidentToPm2} = {
		# match properties
		Properties => {
         
         User => {
            Role => [
                'ERICSSON',
            ],
         },
         
			# current ticket match properties
			Ticket => {
				#TicketID => [ $Param{TicketID} ],
				#Queue => ['WIND-OUT','WIND-OUT[ERICSSON]'],
				#State => ['pending reminder','pending auto close+','pending auto close-','closed successful','closed unsuccessful','closed unsuccessful inf'],
            TypeID => [ $MS_PM_Wind_settings_ptr->{ticketTypeID_IncidentToPM} ],
            QueueID => [$MS_PM_Wind_settings_ptr->{queue_id_ericsson}],
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
				AgentTicketLock        => 1,
				AgentTicketZoom        => 1,
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
				AgentTicketPrint       => 1,
				AgentTicketPhone       => 1, # only used to hide the Split action
				AgentTicketCustomer    => 1,
				AgentTicketOwner       => 1,
				AgentTicketResponsible => 1,
            AgentTicketMerge => 1,
            AgentTicketLink => 1,
            AgentTicketMove => 1,
            AgentObjectLink => 1,
			},

		},
      

		# remove options (black list)
		PossibleNot => {
			# possible action options
			Action => {
				AgentTicketLock        => 0,
				AgentTicketZoom        => 0,
				AgentTicketClose       => 0,
				AgentTicketPending     => 0,
				AgentTicketNote        => 0,
				AgentTicketHistory     => 0,
				AgentTicketPriority    => 0,
				AgentTicketFreeText    => 0,
				AgentTicketCompose     => 0,
				AgentTicketBounce      => 0,
				AgentTicketForward     => 0,
				AgentLinkObject        => 0,
				AgentTicketPrint       => 0,
				AgentTicketPhone       => 0,
				AgentTicketCustomer    => 0,
				AgentTicketOwner       => 0,
				AgentTicketResponsible => 0,
            AgentTicketMerge => 0,
            AgentTicketLink => 0,
            AgentTicketTicketLink => 0,
            AgentTicketMove => 0,
            AgentObjectLink => 0,
			},
		},

      
	};
   

















    #MS_nota: Incident to Pm -> le acl ZZZNotShowEditOnInternalIncidentToEricsson1 e ZZZNotShowEditOnInternalIncidentToEricsson2 lavorano in coppia e in ordine
	$Param{Acl}->{ZZZZNotShowEditOnInternalIncidentToEricsson1} = {
		# match properties
		Properties => {

			# current ticket match properties
			Ticket => {
				#TicketID => [ $Param{TicketID} ],
				#Queue => ['WIND-OUT','WIND-OUT[ERICSSON]'],
				#State => ['pending reminder','pending auto close+','pending auto close-','closed successful','closed unsuccessful','closed unsuccessful inf'],
            TypeID => [ $MS_PM_Wind_settings_ptr->{ticketTypeID_IncidentToEricsson} ],
            QueueID => [$MS_PM_Wind_settings_ptr->{queue_id_ericsson}],
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

   
   
   
   
   
	$Param{Acl}->{ZZZZNotShowEditOnInternalIncidentToEricsson2} = {
		# match properties
		Properties => {
         
         User => {
            Role => [
                'ERICSSON',
            ],
         },
         
			# current ticket match properties
			Ticket => {
				#TicketID => [ $Param{TicketID} ],
				#Queue => ['WIND-OUT','WIND-OUT[ERICSSON]'],
				#State => ['pending reminder','pending auto close+','pending auto close-','closed successful','closed unsuccessful','closed unsuccessful inf'],
            TypeID => [ $MS_PM_Wind_settings_ptr->{ticketTypeID_IncidentToEricsson} ],
            QueueID => [$MS_PM_Wind_settings_ptr->{queue_id_ericsson}],
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
				AgentTicketLock        => 1,
				AgentTicketZoom        => 1,
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
				AgentTicketPrint       => 1,
				AgentTicketPhone       => 1, # only used to hide the Split action
				AgentTicketCustomer    => 1,
				AgentTicketOwner       => 1,
				AgentTicketResponsible => 1,
            AgentTicketMerge => 1,
            AgentTicketLink => 1,
            AgentTicketMove => 1,
            AgentObjectLink => 1,
			},

		},
      

		# remove options (black list)
		PossibleNot => {
			# possible action options
			Action => {
				AgentTicketLock        => 0,
				AgentTicketZoom        => 0,
				AgentTicketClose       => 0,
				AgentTicketPending     => 0,
				AgentTicketNote        => 0,
				AgentTicketHistory     => 0,
				AgentTicketPriority    => 0,
				AgentTicketFreeText    => 0,
				AgentTicketCompose     => 0,
				AgentTicketBounce      => 0,
				AgentTicketForward     => 0,
				AgentLinkObject        => 0,
				AgentTicketPrint       => 0,
				AgentTicketPhone       => 0,
				AgentTicketCustomer    => 0,
				AgentTicketOwner       => 0,
				AgentTicketResponsible => 0,
            AgentTicketMerge => 0,
            AgentTicketLink => 0,
            AgentTicketTicketLink => 0,
            AgentTicketMove => 0,
            AgentObjectLink => 0,
			},
		},

      
	};
   












  
    return 1;
}

1;


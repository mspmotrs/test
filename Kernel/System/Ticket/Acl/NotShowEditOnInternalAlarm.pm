# --
# Kernel/System/Ticket/Acl/NotShowEditOnInternalAlarm.pm - acl module
# - Ambito FULL by MS -
# --
# $Id: NotShowEditOnInternalAlarm.pm,v 1.14 2014/01/10 10:00:00 cresh Exp $
# --
# --

package Kernel::System::Ticket::Acl::NotShowEditOnInternalAlarm;

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

    my $Ticket_channel = '';
    if (exists($Param{TicketID}) and $Param{TicketID} > 0)
    {
        my $MS_DBObject_ptr = $Self->{DBObject};
        $MS_DBObject_ptr->Prepare(
           SQL   => "SELECT channel FROM ticket WHERE id = ?",
           Bind => [ \$Param{TicketID}],
           Limit => 1
        );
       my @RowHistory = $MS_DBObject_ptr->FetchrowArray();
    
       if(scalar(@RowHistory) > 0)
       {
          $Ticket_channel = $RowHistory[0];
       }
    }
    
    
    my $isUserWithEricssonRole = 0;
    if (exists($Param{UserID}) and $Param{UserID} > 0)
    {
        my $MS_GroupObject = Kernel::System::Group->new(
            ConfigObject => $Self->{ConfigObject},
            LogObject    => $Self->{LogObject},
            DBObject     => $Self->{DBObject},
        );        
        
        my @MS_GroupData = $MS_GroupObject->GetRoleListByUser(
                                           UserID => $Param{UserID},
                                           Result => 'Name',
                               );
        
        for (@MS_GroupData)
        {
             $isUserWithEricssonRole = 1 if($_ eq 'ERICSSON');
        }
    }
    

    
    #$Self->{LogObject}->Log( Priority => 'notice', Message => "*************** ACL NotShowEditOnInternalAlarm Called ---- Ticket_channel=$Ticket_channel  ** isUserWithEricssonRole=$isUserWithEricssonRole." );
 
   my $MS_PM_Wind_settings_ptr = $Self->{ConfigObject}->Get( 'PM_Wind_settings' );
   
   
   
    my @notPossibleQueues = ();
    my @possibleQueues = ();
    my @notPossibleQueuesEricsson = ();
    my @possibleQueuesEricsson = ();
   
    if($Ticket{QueueID} == $MS_PM_Wind_settings_ptr->{queue_id_alarm_to_wind} or $Ticket{QueueID} == $MS_PM_Wind_settings_ptr->{'queue_id_ERICSSON-WIND-OUT-Alarm'} )
    {
        my $QueueObject = Kernel::System::Queue->new(
           ConfigObject => $Self->{TicketObject}->{ConfigObject},
           LogObject    => $Self->{TicketObject}->{LogObject},
           DBObject     => $Self->{TicketObject}->{DBObject},
           MainObject   => $Self->{TicketObject}->{MainObject},
       );
        
        my %Queues = $QueueObject->GetAllQueues();
        foreach my $key (%Queues)
        {
            if( $key ne $MS_PM_Wind_settings_ptr->{queue_id_alarm_to_wind} and $key ne  $MS_PM_Wind_settings_ptr->{'queue_id_ERICSSON-WIND-OUT-Alarm'} )
            {
                 push( @notPossibleQueues, $Queues{$key});
                 push( @notPossibleQueuesEricsson, $Queues{$key});
            }
            elsif( $key ne $MS_PM_Wind_settings_ptr->{queue_id_alarm_to_wind} )
            {
                push( @notPossibleQueuesEricsson, $Queues{$key});
                push( @possibleQueues, $Queues{$key});
            }
            else
            {
                push( @possibleQueuesEricsson, $Queues{$key});
                push( @possibleQueues, $Queues{$key});                
            }
        }
        #use Data::Dumper;
        #$Self->{LogObject}->Log( Priority => 'notice', Message => "*********** ACL NotShowEditAlarmFromWind Called on $Param{TicketID} with $Ticket{StateType} -> $Param{Action}.".Dumper(\@notPossibleQueues) );
        #$Self->{LogObject}->Log( Priority => 'notice', Message => "*********** ACL NotShowEditAlarmFromWind Called on $Param{TicketID} with $Ticket{StateType} -> $Param{Action}.".Dumper(\@possibleQueues) );
    }
    

   
   
   
    #Alarm da PM ad Ericsson o a Wind (o a PM per sbaglio) --> impedisco l'edit ad Ericsson
   if (($Ticket_channel eq 'PM' and $isUserWithEricssonRole) or ($Ticket_channel eq 'ERICSSON' and !$isUserWithEricssonRole) )
   {
        $Param{Acl}->{ZZZNotShowEditOnAlarmToERICSSONZZZ} = {
           # match properties
           Properties => {
             
              #User => {
              #   Role => [
              #       'ERICSSON',
              #   ],
              #},
              
              # current ticket match properties
              Ticket => {
                 TypeID => [ $MS_PM_Wind_settings_ptr->{ticketTypeID_AlarmToEricsson},  $MS_PM_Wind_settings_ptr->{ticketTypeID_AlarmToWind}, $MS_PM_Wind_settings_ptr->{ticketTypeID_AlarmToPM}],
                 
                 QueueID => [$MS_PM_Wind_settings_ptr->{'queue_id_ERICSSON-WIND-OUT-Alarm'}],
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
   }
 















	$Param{Acl}->{ZZZNotShowQueueOnAlarmsZZZ1} = {
		# match properties
		Properties => {

			# current ticket match properties
			Ticket => {
            QueueID => [$MS_PM_Wind_settings_ptr->{queue_id_alarm_to_wind}, $MS_PM_Wind_settings_ptr->{'queue_id_ERICSSON-WIND-OUT-Alarm'}],

			},
		},

    # return possible options (black list)
    PossibleNot => {
        # possible ticket options (black list)
        Ticket => {
            Queue => [@notPossibleQueues],
        },
    },
      
		# return possible options (white list)
		Possible => {
         
        Ticket => {
            Queue => [@possibleQueues],
            #QueueID => [$MS_PM_Wind_settings_ptr->{queue_id_alarm_from_wind}, $MS_PM_Wind_settings_ptr->{'queue_id_MVNE-FE-Wind-Ericsson-Alarm'}],
        },
		},
	};







	$Param{Acl}->{ZZZNotShowQueueOnAlarmsZZZ2} = {
		# match properties
		Properties => {
        
         User => {
            Role => [
                'ERICSSON',
            ],
         },
         
			# current ticket match properties
			Ticket => {
            QueueID => [$MS_PM_Wind_settings_ptr->{'queue_id_ERICSSON-WIND-OUT-Alarm'}],

			},
		},

    # return possible options (black list)
    PossibleNot => {
        # possible ticket options (black list)
        Ticket => {
            Queue => [@notPossibleQueuesEricsson],
        },
    },
      
		# return possible options (white list)
		Possible => {
         
        Ticket => {
            Queue => [@possibleQueuesEricsson],
            #QueueID => [$MS_PM_Wind_settings_ptr->{queue_id_alarm_from_wind}, $MS_PM_Wind_settings_ptr->{'queue_id_MVNE-FE-Wind-Ericsson-Alarm'}],
        },
		},
	};





  
    return 1;
}

1;


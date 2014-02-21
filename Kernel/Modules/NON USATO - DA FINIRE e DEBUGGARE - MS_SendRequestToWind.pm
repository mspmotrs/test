# --
# Kernel/Modules/MS_SendRequestToWind.pm - Accenture CR FULL integrazione con Wind
# Copyright (C) 2013 MS - Accenture
# --
# $Id: MS_SendRequestToWind.pm,v 1.0.0 2014/01/16 10:00:00 tr Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::MS_SendRequestToWind;

use strict;
use warnings;

use vars qw(@ISA $VERSION);
$VERSION = qw($Revision: 1.0 $) [1];


# MS Full ---------------
use FindBin qw($Bin);
use lib "$Bin/../../Kernel/pm_wind"; #MS: per i miei moduli custom
push( @INC, "$Bin/../../Kernel/pm_wind" ); #MS: compresi i miei moduli custom
use MSRequestToWindUtil;
use MSResponseFromWindUtil;
use MSTicketUtil;



# disable redefine warnings in this scope
{
no warnings 'redefine';

## as example redefine the TicketXXX() of Kernel::System::Ticket
#sub Kernel::System::Ticket::TicketXXX {
#    my ( $Self, %Param ) = @_;
#
#    # do some new stuff
#
#    return 1;
#}





	sub Kernel::Modules::MS_SendRequestToWind::MS_SendUpdateOrNotify
	{
		my $TicketObject_ptr = shift; 
		my $MS_RequestType = shift;  #'NOTIFY'; #l'unica azione possibile nella notify di un Alarm e' la chiusura
		my $MS_WindTicketType = shift;  #'ALARM';
		
		my $ConfigObject_ptr = $TicketObject_ptr->{ConfigObject};
		my $DBObject_ptr = $TicketObject_ptr->{DBObject};
		my $LogObject_ptr = $TicketObject_ptr->{LogObject};

		my $Ticket_ID = $TicketObject_ptr->{TypeID};
		
	
        my $MS_PM_Wind_settings_ptr = $ConfigObject_ptr->Get( 'PM_Wind_settings' );
        
        my $MS_TicketInfo_ptr = {}; 
        MS_TicketGetInfo($Ticket_ID, 0, $DBObject_ptr, $MS_TicketInfo_ptr);
        my $MS_lastQueueID = MS_FindLastQueueID($DBObject_ptr, $Ticket_ID);
        
        
        #L'invio di una Notify di chiusura a Wind vale solo per gli Alarm
        #Controllo anche che siano effettivamente stati mandati a Wind (le code)
        if (    ($MS_TicketInfo_ptr->{TypeID} == $MS_PM_Wind_settings_ptr->{ticketTypeID_AlarmToWind} )
                and
                (   $MS_TicketInfo_ptr->{QueueID} == $MS_PM_Wind_settings_ptr->{queue_id_alarm_to_wind} or 
                    $MS_TicketInfo_ptr->{QueueID} == $MS_PM_Wind_settings_ptr->{'queue_id_ERICSSON-WIND-OUT-Alarm'} or
                    $MS_TicketInfo_ptr->{QueueID} == $MS_PM_Wind_settings_ptr->{'queue_id_WIND-ERICSSON-OUT-Alarm'}
                    or
                    $MS_lastQueueID == $MS_PM_Wind_settings_ptr->{queue_id_alarm_to_wind} or 
                    $MS_lastQueueID == $MS_PM_Wind_settings_ptr->{'queue_id_ERICSSON-WIND-OUT-Alarm'} or
                    $MS_lastQueueID == $MS_PM_Wind_settings_ptr->{'queue_id_WIND-ERICSSON-OUT-Alarm'} )
            )
        {
            my $MS_moreInfo = {};
            
            eval 
            {   
                my $MS_RequestType = 'NOTIFY'; #l'unica azione possibile nella notify di un Alarm e' la chiusura
                my $MS_WindTicketType = 'ALARM';
                #$MS_moreInfo->{sub_action} = 'CLOSE_ALARM';
                my $MS_send_result = MS_RequestBuildAndSend($Ticket_ID, $TicketObject_ptr, $MS_RequestType, $MS_WindTicketType, '', $MS_moreInfo);
                
                if ($MS_send_result != 1) #not ok
                {
                    $LogObject_ptr->Log( Priority => 'error', Message => $MS_moreInfo->{message}.' '.$MS_moreInfo->{message_more});
                }
            };
            if($@)
            {
               #gestione errore
                $LogObject_ptr->Log( Priority => 'error', Message => "Errore di invio NOTIFY/UPDATE verso Wind");
            }
        }
	
		
	}








	sub Kernel::Modules::MS_SendRequestToWind::MS_SendCreate
	{
		my $TicketObject_ptr = shift; 

		my $ConfigObject_ptr = $TicketObject_ptr->{ConfigObject};
		my $DBObject_ptr = $TicketObject_ptr->{DBObject};
		my $LogObject_ptr = $TicketObject_ptr->{LogObject};

		my $Ticket_ID = $TicketObject_ptr->{TypeID};



    my $rit = 0;
	 
    my $MS_Wind_message = '';
    
    my $MS_PM_Wind_settings_ptr = $Self->{ConfigObject}->Get( 'PM_Wind_settings' );

    
    my $MS_RequestType = ''; #CREATE, UPDATE, NOTIFY
    my $MS_WindTicketType = ''; #INCIDENT, ALARM
    my $MS_send_result = -1;
    my $MS_check_OK_for_CREATE = 0; # K.O.
    
    #$Self->{LogObject}->Log( Priority => 'notice', Message => "_MS_Full_ @@@@@@@@@@@@@@@ -> ho letto la conf: $MS_PM_Wind_settings{queue_id_incident_for_wind}");
    
    
    my $MS_messages = {};
    
    if (exists($GetParam{DestQueueID}) and
            (   $GetParam{DestQueueID} eq $MS_PM_Wind_settings{queue_id_incident_for_wind} or 
                $GetParam{DestQueueID} eq $MS_PM_Wind_settings{queue_id_ERICSSON_PM_WIND_OUT} )
        )
    {
        eval 
        {  
            #$Self->{LogObject}->Log( Priority => 'notice', Message => "_MS_Full_ @@@@@@@@@@@@@@@ -> sto cercando di creare un Incident");
            $MS_check_OK_for_CREATE = MS_CheckIfIncidentOrSrIsOkForCreate($Self->{TicketID}, 0, $Self->{DBObject}); #MSTicketUtil.pm
            #$Self->{LogObject}->Log( Priority => 'notice', Message => "_MS_Full_ @@@@@@@@@@@@@@@ -> sto cercando di creare un Incident --> ESITO = $MS_check_OK_for_CREATE");
            
            if ($MS_check_OK_for_CREATE == 1) 
            {
                #$Self->{LogObject}->Log( Priority => 'notice', Message => "_MS_Full_ @@@@@@@@@@@@@@@ -> sembra che lo posso creare...");
                
                $MS_RequestType = 'CREATE';
                $MS_WindTicketType = 'INCIDENT';
                $MS_send_result = MS_RequestBuildAndSend($Self->{TicketID}, $Self->{TicketObject}, $MS_RequestType, $MS_WindTicketType, '', $MS_messages);
                
                #$Self->{LogObject}->Log( Priority => 'notice', Message => "_MS_Full_ @@@@@@@@@@@@@@@ -> l'ho mandato a Wind");
                
                if ($MS_send_result == 1) #ok
                {
                    $Move = $Self->{TicketObject}->MoveTicket(
                    QueueID            => $GetParam{DestQueueID},
                    UserID             => $Self->{UserID},
                    TicketID           => $Self->{TicketID},
                    SendNoNotification => $GetParam{NewUserID},
                    Comment            => $BodyAsText,
                    );
                }
                else
                {
                    $Self->{LogObject}->Log( Priority => 'error', Message => $MS_messages->{message}.' '.$MS_messages->{message_more});
                }
            }
        };
        if($@)
        {
           #gestione errore
            $Self->{LogObject}->Log( Priority => 'error', Message => "Errore di creazione Incident verso Wind");
        }

        
    }
    elsif (exists($GetParam{DestQueueID}) and
            (   $GetParam{DestQueueID} eq $MS_PM_Wind_settings{queue_id_alarm_to_wind} or 
                $GetParam{DestQueueID} eq $MS_PM_Wind_settings{'queue_id_ERICSSON-WIND-OUT-Alarm'} or
                $GetParam{DestQueueID} eq $MS_PM_Wind_settings{'queue_id_WIND-ERICSSON-OUT-Alarm'} )
        )
    {
        eval 
        {  
            $MS_check_OK_for_CREATE = MS_CheckIfAlarmIsOkForCreate($Self->{TicketID}, 0, $Self->{DBObject}); #MSTicketUtil.pm
            
            if ($MS_check_OK_for_CREATE == 1) 
            {
                $MS_RequestType = 'CREATE';
                $MS_WindTicketType = 'ALARM';
                $MS_send_result = MS_RequestBuildAndSend($Self->{TicketID}, $Self->{TicketObject}, $MS_RequestType, $MS_WindTicketType, '', $MS_messages);
                
                if ($MS_send_result == 1) #ok
                {
                    $Move = $Self->{TicketObject}->MoveTicket(
                    QueueID            => $GetParam{DestQueueID},
                    UserID             => $Self->{UserID},
                    TicketID           => $Self->{TicketID},
                    SendNoNotification => $GetParam{NewUserID},
                    Comment            => $BodyAsText,
                    );
                }
                else
                {
                    $Self->{LogObject}->Log( Priority => 'error', Message => $MS_messages->{message}.' '.$MS_messages->{message_more});
                }
            }
        };
        if($@)
        {
           #gestione errore
            $Self->{LogObject}->Log( Priority => 'error', Message => "Errore di creazione Alarm verso Wind");
        }
    }
    else # in tutti gli altri casi faccio comunque la move
    {
        $Move = $Self->{TicketObject}->MoveTicket(
       QueueID            => $GetParam{DestQueueID},
       UserID             => $Self->{UserID},
       TicketID           => $Self->{TicketID},
       SendNoNotification => $GetParam{NewUserID},
       Comment            => $BodyAsText,
       );       
    }

	}







# reset all warnings
}

1;

# --
# Kernel/System/Stats/TimeOnQueueITL.pm - stats module
# Copyright (C) 2001-2009 OTRS AG, http://otrs.org/
# --
# $Id: TimeOnQueueITL.pm,v 1.1 2011/12/14 08:16:26 rk Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Stats::Static::TimeOnQueueITL;

use strict;
use warnings;

use Date::Pcalc qw(Today_and_Now Days_in_Month Day_of_Week Day_of_Week_Abbreviation);
use Kernel::Config;
use Kernel::System::Encode;
use Kernel::System::Log;
use Kernel::System::Main;
use Kernel::Language;
use Kernel::System::Time;


use vars qw($VERSION);
$VERSION = '$Revision: 1.1 $ ';

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = { %Param };
    bless( $Self, $Type );

    # check all needed objects
    for (qw(DBObject ConfigObject LogObject)) {
        die "Got no $_" if ( !$Self->{$_} );
    }
    
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
#    my $LanguageObject = Kernel::Language->new(
#        MainObject   => $MainObject,
#        ConfigObject => $ConfigObject,
#        EncodeObject => $EncodeObject,
#        LogObject    => $LogObject,
#        UserLanguage => 'it',
#    );

    return $Self;
}

sub Param {
    my $Self = shift;

    my @Params = ();

    # get current time
    my ( $s, $m, $h, $D, $M, $Y, $wd, $yd, $dst ) = localtime( time() );
    $Y = $Y + 1900;
    $M++;
    
    # get one month before
    if ( $M == 1 ) {
        $M = 12;
        $Y = $Y - 1;
    }
    else {
        $M = $M - 1;
    }
    
    # create possible time selections
    my %Year = ();
    for ( $Y - 10 .. $Y + 1 ) {
        $Year{$_} = $_;
    }
    my %Month = ();
    for ( 1 .. 12 ) {
        my $Tmp = sprintf( "%02d", $_ );
        $Month{$_} = $Tmp;
    }
    my %Day = ();
    for ( 1 .. 31 ) {
        my $Tmp = sprintf( "%02d", $_ );
        $Day{$_} = $Tmp;
    }
        
    push(
        @Params,
        {   Frontend   => 'Inizio intervallo (Anno)',
            Name       => 'Year',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $Y-1,
            Data       => { %Year, },
        },
    );
    push(
        @Params,
        {   Frontend   => 'Inizio intervallo (Mese)',
            Name       => 'Month',
            Multiple   => 0,
            Size       => 0,
            SelectedID => 1,
            Data       => { %Month, },
        },
    );
    push(
        @Params,
        {   Frontend   => 'Inizio intervallo (Giorno)',
            Name       => 'Day',
            Multiple   => 0,
            Size       => 0,
            SelectedID => 1,
            Data       => { %Day, },
        },
    );
        
    push(
        @Params,
        {   Frontend   => 'Fine intervallo (Anno)',
            Name       => 'YearEnd',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $Y-1,
            Data       => { %Year, },
        },
    );
    push(
        @Params,
        {   Frontend   => 'Fine intervallo (Mese)',
            Name       => 'MonthEnd',
            Multiple   => 0,
            Size       => 0,
            SelectedID => 1,
            Data       => { %Month, },
        },
    );
    push(
        @Params,
        {   Frontend   => 'Fine intervallo (Giorno)',
            Name       => 'DayEnd',
            Multiple   => 0,
            Size       => 0,
            SelectedID => 1,
            Data       => { %Day, },
        },
    );
        
    push(
        @Params,
        {   Frontend   => 'Graph Size',
            Name       => 'GraphSize',
            Multiple   => 0,
            Size       => 0,
            SelectedID => '550x350',
            Data       => {
                '550x350'  => ' 550x350',
                '800x600'  => ' 800x600',
                '1200x800' => '1200x800',
            },
        },
    );
    return @Params;
}

sub Run {
    my ( $Self, %Param ) = @_;

    for (keys %Param) {
        $Self->{LogObject}->Log (
            Priority    => 'info',
            Message     => "$_ = $Param{$_}",
        );
    }

    my $LanguageObject = Kernel::Language->new(
        MainObject   => $Self->{MainObject},
        ConfigObject => $Self->{ConfigObject},
        EncodeObject => $Self->{EncodeObject},
        LogObject    => $Self->{LogObject},
        UserLanguage => 'it',
    );
    
    my $TimeObject = Kernel::System::Time->new(
        ConfigObject => $Self->{ConfigObject},
        LogObject    => $Self->{LogObject},
    );

    my $TicketObject = Kernel::System::Ticket->new(
        ConfigObject => $Self->{ConfigObject},
        LogObject    => $Self->{LogObject},
        DBObject     => $Self->{DBObject},
        MainObject   => $Self->{MainObject},
        TimeObject   => $TimeObject,
        EncodeObject => $Self->{EncodeObject},
    );


    #get the time period
    my $YearStart  = $Param{Year};
    my $MonthStart = $Param{Month};
    my $DayStart   = $Param{Day};
	  
    my $YearEnd    = $Param{YearEnd};
    my $MonthEnd   = $Param{MonthEnd};
    my $DayEnd     = $Param{DayEnd}+1;
 	
    $Self->{LogObject}->Log (
        Priority	=> 'info',
 	Message		=> "DATEINTERVAL = $YearStart-$MonthStart-$DayStart / $YearEnd-$MonthEnd-$DayEnd",
    );
 	
    my $Title = "TimeOnQueueITL";
	
    my @HeadData = ('ID', 'Oggetto' , 'Tipo', 'Priorita\'', 'Stato','SR Tipo', 'SR Area', 'SR Sub-Area', 'Data di Creazione su OTRS', 'Data chiusura', 'Coda', 'Tempo di Permanenza sulla coda');

	
    my ($DBObject, $Select );
    #my (@Data, $Title);
    my (@DataEnd, $Title);
    my @Data = ();
    
    $DBObject = $Self->{DBObject};

    my $SQL
         = " SELECT t_filter.tn           as TicketName "
         . "       ,t_filter.title        as TicketTitle "
         . "       ,tt.name               as TicketType "
         . "       ,tp.name               as TicketPriority "
         . "       ,ts.name               as Stato_Corrente "
         . "       ,t_filter.freetext4    as SRTipo "
         . "       ,t_filter.freetext5    as SRArea "
         . "       ,t_filter.freetext6    as SRSubArea "
         . "       ,t_filter.create_time  as Data_Creazione_Ticket "
         . "       ,FROM_UNIXTIME(t_filter.until_time - (1*60*60*24)) as Ultima_Data_Chiusura "
         . "       ,q.name                as Coda "
         . "       ,th.create_time        as DataIngresso "
         . "       ,t_filter.id           as TicketID "
         . "       ,q.id                  as QueueID "
         . "   from ticket_history th "
         . "       , "
         . "        (select FROM_UNIXTIME(t.until_time - (1*60*60*24) ) "
         . "               ,t.* "
         . "           from ticket t "
         . "          where ( FROM_UNIXTIME(t.until_time - (1*60*60*24) ) >= '$YearStart-$MonthStart-$DayStart 00:00:00' "
         . "              and FROM_UNIXTIME(t.until_time - (1*60*60*24) ) <= '$YearEnd-$MonthEnd-$DayEnd 23:59:59' "
         . "                ) "
         . "            and t.queue_id in ( 46, 47, 48, 49, 50, 56, 57 ) "
         . "            and t.ticket_state_id in ( 2, 3, 11 ) "
         . "        )t_filter "
         . "       ,ticket_type     tt "
         . "       ,ticket_state    ts "
         . "       ,ticket_priority tp "
         . "       ,queue           q "
         . "  where th.ticket_id                = t_filter.id "
         . "    and t_filter.type_id            = tt.id "
         . "    and t_filter.ticket_state_id    = ts.id "
         . "    and t_filter.ticket_priority_id = tp.id "
         . "    and th.queue_id                 = q.id "
         . "    and th.history_type_id in (1, 16) "
         . "  order by th.ticket_id desc, th.create_time asc ";



    $Self->{LogObject}->Log (
        Priority	=> 'info',
        Message		=> "SQL = " . $SQL,
    );
    
                      
    #Read SQL result and put it in @Data
    $Self->{DBObject}->Prepare( SQL => $SQL );
    
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
            my @TranslatedRow = ();
        for my $Dat ( @Row ) {
            my $TranslatedElement = $LanguageObject->Get("$Dat");  
          $Self->{LogObject}->Log (
              Priority        => 'info',
              Message         => "SQL ResultRow= @Row ---- $Dat --TRANS--> $TranslatedElement",
          );
          push(@TranslatedRow, $TranslatedElement);
        } 
#        push ( @Data , \@Row);
         push ( @Data , \@TranslatedRow); 
    }

    my $nrows = scalar @Data;   
    my $ncols = scalar @HeadData;

    $Self->{LogObject}->Log (
                 Priority        => 'info',
                 Message         => "N_ROWS: $nrows....N_COLS: $ncols",
            );  
    
    my %hashTicket; 
    my @fields = ();
    
    my @myQueues = ('46', '47', '56', '57'); 
 
    #CICLO SULL'ARRAY DERIVATO DALLA QUERY SUI TICKET CHIUSI PASSATI SULLE CODE DI INTERESSE 
    for ( my $i = 0; $i < $nrows; $i++ )
    {
    	 #Se i TN sono uguali
       if ( $Data[$i][0] eq $Data[($i+1)][0] )
       { 
       	    $Self->{LogObject}->Log (
                 Priority        => 'info',
                 Message         => "Ticket Analizzato . $Data[$i][0] su Coda . $Data[$i][13]",
            );
            
            $Self->{LogObject}->Log (
                 Priority        => 'info',
                 Message         => "MY_QUEUES: @myQueues",
            );
            
            if ( grep /^$Data[$i][13]$/, @myQueues )
            {                  
                  #calculate Delta on the queue 
                  my $create_time_before = $Data[$i][11]; 
                  my $create_time_after  = $Data[$i+1][11];
                                    
                  my $Before = $Self->{TimeObject}->TimeStamp2SystemTime(
                                    String => "$create_time_before",
                               ); 
                  
                  my $After  = $Self->{TimeObject}->TimeStamp2SystemTime(
                                    String => "$create_time_after",
                               );
                  
                  my $diffSec       = $TimeObject->WorkingTime(
                                                             StartTime => $Before,
                                                             StopTime  => $After,
                                                             Calendar  => 11,
                                                     );
                  
                  my $ticketName          = $Data[$i][0];
                  my $ticketTitle         = $Data[$i][1];
                  my $ticketType          = $Data[$i][2];
                  my $ticketPriority      = $Data[$i][3];
                  my $ticketState         = $Data[$i][4];
                  my $SRTipo              = $Data[$i][5];
                  my $SRArea              = $Data[$i][6];
                  my $SRSubArea           = $Data[$i][7];
                  my $dataCreazioneTicket = $Data[$i][8];
                  my $dataChiusuraTicket  = $Data[$i][9];
                  my $queue               = $Data[$i][10];
                  my $diffMin             = $diffSec/60; #tempo di permanenza in minuti
                  
                  my $dataIngresso        = $Data[$i][11];
                  my $ticketID            = $Data[$i][12];
                  my $queueID             = $Data[$i][13];
                  
                  my $ticketID = $ticketID;
                  my %Ticket   = $TicketObject->TicketGet(
                                                  TicketID => $ticketID,
                                                );
                  
                  my %dataChiusura = $TicketObject->_TicketGetClosed(
                                                          TicketID => $ticketID,
                                                          Ticket   => \%Ticket,  );
                  
                  $fields[0]  = $ticketName;
                  $fields[1]  = $ticketTitle;
                  $fields[2]  = $ticketType;
                  $fields[3]  = $ticketPriority;
                  $fields[4]  = $ticketState;
                  $fields[5]  = $SRTipo;
                  $fields[6]  = $SRArea;
                  $fields[7]  = $SRSubArea;
                  $fields[8]  = $dataCreazioneTicket;
                  $fields[9]  = $dataChiusura{SolutionTime};
                  $fields[10]  = $queue;
                  $fields[11] = $diffMin;

                  my @MyRow = @fields;
                  #push ( @DataEnd , \@MyRow);
                  
									
                  my $ticketKey = "$Data[$i][0]" . "-$queue";  
                  
                  #ticket Name 
                  if ( $hashTicket{$ticketKey} )
                  { 
                  	  my @myArray = $hashTicket{$ticketKey};
                  	  
                      #key presente aggiornare la riga 
                      $Self->{LogObject}->Log (
                               Priority        => 'info',
                               Message         => "PRIMA --- $ticketKey presente nell hash... Aggiungo delta di permanenza sulla coda . $hashTicket{$ticketKey}[11] . $myArray[10]",
                      );
                      
                      my $timeValue = $hashTicket{$ticketKey}[11];
                      
                      $hashTicket{$ticketKey}[11] = ($timeValue + $diffMin);
                      
                      #key presente aggiornare la riga 
                      $Self->{LogObject}->Log (
                               Priority        => 'info',
                               Message         => "DOPO --- $ticketKey presente nell hash... Aggiungo delta di permanenza sulla coda . $hashTicket{$ticketKey}[11] . $myArray[10]",
                      );
                  } 
                  else {
                  	  $Self->{LogObject}->Log (
                               Priority        => 'info',
                               Message         => "$ticketKey NON presente nell hash...\%hashTicket",
                      );
                  	  
                  	  $hashTicket{$ticketKey} = \@MyRow;
                  
                  }                  
             } 
       }
       else {
            if ( grep /^$Data[$i][13]$/, @myQueues )
            {
                  #calculate Delta on the queue 
                  my $create_time_before = $Data[$i][11]; 
                  my $create_time_after  = $Data[$i][9];
                                    
                  my $Before = $Self->{TimeObject}->TimeStamp2SystemTime(
                                    String => "$create_time_before",
                               ); 
                  
                  my $After  = $Self->{TimeObject}->TimeStamp2SystemTime(
                                    String => "$create_time_after",
                               );
                  
                  my $diffSec       = $TimeObject->WorkingTime(
                                                             StartTime => $Before,
                                                             StopTime  => $After,
                                                             Calendar  => 11,
                                                     );
                  
                  my $ticketName          = $Data[$i][0];
                  my $ticketTitle         = $Data[$i][1];
                  my $ticketType          = $Data[$i][2];
                  my $ticketPriority      = $Data[$i][3];
                  my $ticketState         = $Data[$i][4];
                  my $SRTipo              = $Data[$i][5];
                  my $SRArea              = $Data[$i][6];
                  my $SRSubArea           = $Data[$i][7];
                  my $dataCreazioneTicket = $Data[$i][8];
                  my $dataChiusuraTicket  = $Data[$i][9];
                  my $queue               = $Data[$i][10];
                  my $diffMin             = $diffSec/60; #tempo di permanenza in minuti
                  
                  my $dataIngresso        = $Data[$i][11];
                  my $ticketID            = $Data[$i][12];
                  my $queueID             = $Data[$i][13];
                  
                  my $ticketID = $ticketID;
                  my %Ticket   = $TicketObject->TicketGet(
                                                  TicketID => $ticketID,
                                                );
                  
                  my %dataChiusura = $TicketObject->_TicketGetClosed(
                                                          TicketID => $ticketID,
                                                          Ticket   => \%Ticket,  );
                  
                  $fields[0]  = $ticketName;
                  $fields[1]  = $ticketTitle;
                  $fields[2]  = $ticketType;
                  $fields[3]  = $ticketPriority;
                  $fields[4]  = $ticketState;
                  $fields[5]  = $SRTipo;
                  $fields[6]  = $SRArea;
                  $fields[7]  = $SRSubArea;
                  $fields[8]  = $dataCreazioneTicket;
                  $fields[9]  = $dataChiusura{SolutionTime};
                  $fields[10] = $queue;
                  $fields[11] = $diffMin;

                  my @MyRow = @fields;
                  #push ( @DataEnd , \@MyRow);
                  
									
                  my $ticketKey = "$Data[$i][0]" . "-$queue";  
                  
                  #ticket Name 
                  if ( $hashTicket{$ticketKey} )
                  { 
                  	  my @myArray = $hashTicket{$ticketKey};
                  	  
                      #key presente aggiornare la riga 
                      $Self->{LogObject}->Log (
                               Priority        => 'info',
                               Message         => "PRIMA --- $ticketKey presente nell hash... Aggiungo delta di permanenza sulla coda . $hashTicket{$ticketKey}[11] . $myArray[10]",
                      );
                      
                      my $timeValue = $hashTicket{$ticketKey}[11];
                      
                      $hashTicket{$ticketKey}[11] = ($timeValue + $diffMin);
                      
                      #key presente aggiornare la riga 
                      $Self->{LogObject}->Log (
                               Priority        => 'info',
                               Message         => "DOPO --- $ticketKey presente nell hash... Aggiungo delta di permanenza sulla coda . $hashTicket{$ticketKey}[11] . $myArray[10]",
                      );
                  } 
                  else {
                  	  $Self->{LogObject}->Log (
                               Priority        => 'info',
                               Message         => "$ticketKey NON presente nell hash...\%hashTicket",
                      );
                  	  
                  	  $hashTicket{$ticketKey} = \@MyRow;
                  
                  }             
            
            }
       
       }
    }
    
    for my $rowKey ( sort keys %hashTicket )
    {
 	 
       my @currentRow = @{ $hashTicket{$rowKey} };
       
       
       $Self->{LogObject}->Log (
                  Priority        => 'info',
                  Message         => "VALORI::: $rowKey . @currentRow",
              );
       
       push(@DataEnd, \@currentRow);
    }
    
    #push(@DataEnd, values %hashTicket);
    

    return ( [$Title], [@HeadData], @DataEnd );
}

1;

# --
# Kernel/System/Stats/TimeOnQueuePB.pm - stats module
# Copyright (C) 2001-2009 OTRS AG, http://otrs.org/
# --
# $Id: TimeOnQueuePB.pm,v 1.1 2011/12/14 08:16:26 rk Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Stats::Static::TimeOnQueuePB;

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

#    my @HeadData = ('ID', 'Subject' , 'Tipo', 'Priorita\'', 'Stato', 'SR Tipo', 'SR Area', 'SR Sub-Area', 'Data di Creazione su OTRS', 'Data Prima Risposta', 'Data Chiusura', 'Tempo di Prima Risposta', 'Tempo di Permanenza sulla coda Pure Bros');

    my @HeadData = ('ID', 'Subject' , 'Tipo', 'Priorita\'', 'Stato', 'SR Tipo', 'SR Area', 'SR Sub-Area', 'Data di Creazione su OTRS', 'Coda','Data Prima Risposta', 'Data Chiusura', 'Tempo di Prima Risposta', 'Tempo di Permanenza sulla coda Pure Bros'); 
    
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
 	
#    my $Title = "TimeOnQueuePB.pm TripletteSR Ticket creati dal $DayStart-$MonthStart-$YearStart al $DayEnd-$MonthEnd-$YearEnd";
    my $Title = "TimeOnQueuePB.pm ";
		
    my ($DBObject, $Select );
    my (@DataEnd, $Title);
    my @Data = ();
 

    my $DBObject  = $Self->{DBObject};
    #my $DBObject3 = $Self->{DBObject};
    #my $DBObject4 = $Self->{DBObject};

    my $SQL
        =   "SELECT ti.tn           as TicketName   "
          . "      ,ti.title        as TicketTitle  "
          . "      ,tp.name         as TicketType   "
          . "      ,tpr.name        as TicketPriority   "
          . "      ,ts.name         as Stato_Corrente "
          . "      ,ti.freetext4    as SRTipo "
          . "      ,ti.freetext5    as SRArea "
          . "      ,ti.freetext6    as SRSubArea "
          . "      ,ti.create_time  as Data_Creazione_Ticket "
          . "      ,q.name          as Coda "
          . "      ,t.create_time   as DataIngresso "
          . "      ,ti.id           as TicketID "
          . "      ,q.id            as QueueID " 
          . "  FROM ticket_history  t "
          . "      ,ticket          ti "
          . "      ,ticket_type     tp "
          . "      ,ticket_state    ts "
          . "      ,ticket_priority tpr " 
          . "      ,queue           q "
          . " where ti.id      = t.ticket_id " 
          . "   and ti.type_id = tp.id "
          . "   and tpr.id     = ti.ticket_priority_id " 
          . "   and ts.id      = ti.ticket_state_id "
          . "   and t.queue_id = q.id "
          . "   and t.history_type_id in (1,16) "
          . "   and t.ticket_id in  "
          . "	  (SELECT t.id "
          . "             FROM ticket t "
          . "            where (t.create_time >= '$YearStart-$MonthStart-$DayStart' and t.create_time <= '$YearEnd-$MonthEnd-$DayEnd') "
          . "	      and t.channel='Siebel' "
          . "              and t.sr_assigned_to like 'Pure%' "
          . "           ) "
          . "order by t.ticket_id, t.id ";                  

      $Self->{LogObject}->Log (
         Priority	=> 'info',
         Message		=> "SQL = " . $SQL,
      );
 

      my @fields = ();       

      #Read SQL result and put it in @Data
      $DBObject->Prepare( SQL => $SQL );
      #$DBObject3->Prepare( SQL => $SQL );
      #$DBObject4->Prepare( SQL => $SQL );

			
     #$DBObject4->FetchrowArray();

     $Self->{LogObject}->Log (
                     Priority        => 'info',
                     Message         => "TimeOnQueue START...",
          );

      while ( my @RowTemp = $Self->{DBObject}->FetchrowArray() ) {
          my @TranslatedRow = ();
          for my $Dat ( @RowTemp ) {
              my $TranslatedElement = $LanguageObject->Get("$Dat");  
                 push(@TranslatedRow, $TranslatedElement);
          }
          $Self->{LogObject}->Log (
                     Priority        => 'info',
                     Message         => "SQL ResultRow= @TranslatedRow",
          ); 
          push ( @Data , \@TranslatedRow); 
      }
      
      my $nrows = scalar @Data;
      my $ncols = scalar @HeadData;
      
      $Self->{LogObject}->Log (
                     Priority        => 'info',
                     Message         => "N_ROWS: $nrows....N_COLS: $ncols",
                  );
      for ( my $i = 0; $i < $nrows; $i++ ){
           #ticket Name 
           if ( $Data[$i][0] eq $Data[($i+1)][0] ) {
           	 #queue Name
           	     if ( $Data[$i][9] ne $Data[($i+1)][9] ) {
           	     	    #create_time sulla ticket_history
                          my $create_time_after  = $Data[($i+1)][10];
                          my $create_time_before = $Data[$i][10];
                          my $local = localtime $create_time_before; 
                          
                          my $After = $Self->{TimeObject}->TimeStamp2SystemTime(
                               String => "$Data[($i+1)][10]",
                          );
                          
                          my $Before = $Self->{TimeObject}->TimeStamp2SystemTime(
                               String => "$Data[$i][10]",
                          );
              
                          my $diffSec            = $TimeObject->WorkingTime(
                                                            StartTime => $Before,
                                                            StopTime  => $After,
                                                            Calendar  => 2,
                                                   );
                          my $diffMin = $diffSec/60; 
                          my $ticketID = $Data[$i][11]; 
                          my %Ticket = $TicketObject->TicketGet(
                                          TicketID => $ticketID,
                                       );            	     	 
                            
                          my %dataPrimaRisposta = $TicketObject->_TicketGetFirstResponse(
                                                             TicketID => $ticketID,
                                                             Ticket   => \%Ticket,  );
                          
                          my %dataChiusura = $TicketObject->_TicketGetClosed(
                                                          TicketID => $ticketID,
                                                          Ticket   => \%Ticket,  );

                          my $ticketName    = $Data[$i][0];
                          my $ticketTitle   = $Data[$i][1];
           	          my $dataIngresso  = $Data[$i][10];
                          my $dataUscita    = $Data[($i+1)][10];
                          my $queue         = $Data[$i][9];
                          my $queueID       = $Data[$i][12];
 
                          $fields[0]  = $ticketName;
                          $fields[1]  = $ticketTitle; 
                          $fields[2]  = $Data[$i][2]; #TicketType #$rs3[2];
                          $fields[3]  = $Data[$i][3]; #TicketPriority
                          $fields[4]  = $Data[$i][4]; #Stato
                          $fields[5]  = $Data[$i][5]; #SR-Tipo #$rs3[3];
                          $fields[6]  = $Data[$i][6]; #SR-Area
                          $fields[7]  = $Data[$i][7]; #SR-SubArea
                          $fields[8]  = $Data[$i][8]; #Data Creazione su Ticket $rs3[2];
                          $fields[9]  = $queue;
                          $fields[10] = $dataPrimaRisposta{FirstResponse}; #'XXXXDataPrimaRisposta' 
                          my $SystemTime = $Self->{TimeObject}->SystemTime(); 
                          my $Sysdate = $TimeObject->SystemTime2TimeStamp(
                                              SystemTime => $SystemTime,
                                          ); 
                          $fields[11] = $dataChiusura{SolutionTime} || $Sysdate; #'YYYChiusuraORSysdate';
                          $fields[12] = $dataPrimaRisposta{FirstResponseInMin}; #'XXXXTempoPrimaRisposta';
                          $fields[13] = $diffMin; #T permanenza Coda
 
 
                          my @MyRow = @fields;
                          $Self->{LogObject}->Log (
                                          Priority        => 'info',
                                          Message         => "RIGA1::::: @fields",
                          );
                          if( $queueID eq 40 ) {
                              #push ( @DataEnd , \@MyRow);

                              my @lastRow = pop( @DataEnd );
                              $Self->{LogObject}->Log (
                                      Priority        => 'info',
                                      Message         => "POPRIGA1:: @lastRow ...$lastRow[0][0] ",
                              );
                              if( ($lastRow[0][0] eq $MyRow[0]) && ($lastRow[0][9] eq $MyRow[9]) ){
                                   $lastRow[0][13] = $lastRow[0][13] + $MyRow[13];

                                   $Self->{LogObject}->Log (
                                           Priority        => 'info',
                                           Message         => "SUMMA POPRIGA5::$lastRow[0][0] --  $lastRow[0][13]",
                                   );
                                   push ( @DataEnd , @lastRow);
                              }
                              else{
                                   push ( @DataEnd , @lastRow);
                                   push ( @DataEnd , \@MyRow);
                              }
                          }
##### INIZIO
                          my $j = ($i + 1) +1; #rs4 index (is j)
                                       if ($j ge $nrows) {  #counterRs4 + 1 == n of rows ; counterRs4 +=1; Rs4next
					   		my $last_tn  = $Data[$j][0]; #rs4.getString(1);
                                                        my $Title    = $Data[$j][1];
                                                        my $last_TicketID = $Data[$j][11]; 
					   		my $last_ticketType = $Data[$j][2]; #rs4.getString(2);
                                                        my $last_ticketPriority = $Data[$j][3]; #TicketPriority
					   		my $last_dataCreazioneTicket = $Data[$j][8];# rs4.getString(3).substring(0,19);
					   		my $last_stato     = $Data[$j][4]; #rs4.getString(4);
                                                        my $last_SRTipo    = $Data[$j][5]; #SRTipo
					   		my $last_SRArea    = $Data[$j][6]; #SRArea
                                                        my $last_SRSubArea = $Data[$j][7]; #SRSubArea
					   		my $last_queue     = $Data[$j][9]; #rs4.getString(5);
					                my $last_queue_id  = $Data[$j][12]; 
					   		my $last_data_ingresso = $Data[$j][10]; #rs4.getTimestamp(6).getTime();
             
					   		$j = $j - 1  ; #rs4.previous();
					   		
					   		my $pre_tn = $Data[$j][0]; #rs4.getString(1);
                                                        my $pre_TicketID = $Data[$j][11];
					   		my $pre_ticketType = $Data[$j][2]; #rs4.getString(2);
					   		my $pre_ticketPriority = $Data[$j][3]; #TicketPriority
                                                        my $pre_dataCreazioneTicket = $Data[$j][8]; #rs4.getString(3).substring(0, 19);
					   		my $pre_stato = $Data[$j][4]; #rs4.getString(4);
					   		my $pre_queue = $Data[$j][9]; #rs4.getString(5);
                                                        my $pre_SRTipo    = $Data[$j][5]; #SRTipo
					   		my $pre_SRArea    = $Data[$j][6]; #SRArea
                                                        my $pre_SRSubArea = $Data[$j][7]; #SRSubArea
                                                        my $pre_queue_id  = $Data[$j][12]; 
					   		my $pre_data_ingresso = $Data[$j][10]; #rs4.getTimestamp(6).getTime();
					   		
					   		$j = $j+1; #rs4.next();

					   		if ($last_tn eq $pre_tn) {
					   		       	
					   			if ($last_queue ne $pre_queue) {
                                                                    my $After = $Self->{TimeObject}->TimeStamp2SystemTime(
                                                                             String => "$last_data_ingresso",
                                                                    );
                          
                                                                    my $Before = $Self->{TimeObject}->TimeStamp2SystemTime(
                                                                             String => "$pre_data_ingresso",
                                                                    );
              
                                                                    my $diffSec            = $TimeObject->WorkingTime(
                                                                                                StartTime => $Before,
                                                                                                StopTime  => $After,
                                                                                                Calendar  => 2,
                                                                                             );
                                                                           
					   	                    my $diffMin = $diffSec/60; 
					   				
				                                    $fields[0] = $pre_tn;
                                                                    $fields[1] = $Title;
					   		            $fields[2] = $pre_ticketType;
                                                                    
                                                                    $fields[3]  = $pre_ticketPriority; #TicketPriority
                                                                    $fields[4]  = $pre_stato; #Stato
                                                                    $fields[5]  = $pre_SRTipo; #SR-Tipo
                                                                    $fields[6]  = $pre_SRArea; #SR-Area
                                                                    $fields[7]  = $pre_SRSubArea; #SR-SubArea

					   		            $fields[8] = $pre_dataCreazioneTicket;
					   		            
					   		            $fields[9] = $pre_queue;
                                                                    my $ticketID = $pre_TicketID;
                                                                    my %Ticket = $TicketObject->TicketGet(
                                                                                     TicketID => $ticketID,
                                                                                 );

                                                                    my %dataPrimaRisposta = $TicketObject->_TicketGetFirstResponse(
                                                                                               TicketID => $ticketID,
                                                                                               Ticket   => \%Ticket,  ); 
                                                                    
                                                                    $fields[10] = $dataPrimaRisposta{FirstResponse};
                                                                    my %dataChiusura = $TicketObject->_TicketGetClosed(
                                                                                                          TicketID => $ticketID,
                                                                                                          Ticket   => \%Ticket,  );

                                                                    my $SystemTime = $Self->{TimeObject}->SystemTime();             
                                                                    my $Sysdate = $TimeObject->SystemTime2TimeStamp(
                                                                                      SystemTime => $SystemTime,
                                                                                  );
                                                                    $fields[11] = $dataChiusura{SolutionTime} || $Sysdate; #'YYYChiusuraORSysdate';  
                                                                    
                                                                    $fields[12] = $dataPrimaRisposta{FirstResponseInMin};
                                                                    $fields[13] = $diffMin; #T permanenza Coda
					   		         
					   				
					   		            my @MyRow = @fields;  
                                                                    $Self->{LogObject}->Log (
                                                                           Priority        => 'info',
                                                                           Message         => "RIGA2::$last_queue -- $pre_queue::: @fields",
                                                                    );
              
                                                                    if( $pre_queue_id eq 40 ) {
                                                                        #push ( @DataEnd , \@MyRow);

                                                                        my @lastRow = pop( @DataEnd );
                                                                        $Self->{LogObject}->Log (
                                                                            Priority        => 'info',
                                                                            Message         => "POPRIGA2:: @lastRow ...$lastRow[0][0] ",
                                                                        );
                                                                        if( ($lastRow[0][0] eq $MyRow[0]) && ($lastRow[0][9] eq $MyRow[9]) ){
                                                                             $lastRow[0][13] = $lastRow[0][13] + $MyRow[13];

                                                                             $Self->{LogObject}->Log (
                                                                                 Priority        => 'info',
                                                                                 Message         => "SUMMA POPRIGA5::$lastRow[0][0] --  $lastRow[0][13]",
                                                                             );
                                                                             push ( @DataEnd , @lastRow);
                                                                        }
                                                                        else{
                                                                             push ( @DataEnd , @lastRow);
                                                                             push ( @DataEnd , \@MyRow);
                                                                        }
                                                                    }
 
                                                                }
					   			
					   			##Date dataFineInt = FORMATTER.parse(dataFine);
					   			
					   			##Date dateNow = new Date();
					   			##String nowString = FORMATTER.format(dateNow);
					   					
					   			##long diffMills = dateNow.getTime() - pre_data_ingresso;
					   			##int sec2 = (int)(diffMills/1000);
					   
					   			##dataUscita = nowString;

                                                                my $After = $Self->{TimeObject}->SystemTime();  
              
                                                                my $Before = $Self->{TimeObject}->TimeStamp2SystemTime(
                                                                     String => " $pre_data_ingresso",
                                                                );
              
                                                                my $diffSec            = $TimeObject->WorkingTime(
                                                                                               StartTime => $Before,
                                                                                               StopTime  => $After,
                                                                                               Calendar  => 2,
                                                                                         );
					   		        my $diffMin = $diffSec/60; 
					   			
                                                                $fields[0] = $last_tn;
                                                                $fields[1] = $Title;
					   	                $fields[2] = $last_ticketType;
                                                                $fields[3] = $last_ticketPriority;
                                                                $fields[4] = $last_stato;
                                                                $fields[5]  = $last_SRTipo; #SR-Tipo
                                                                $fields[6]  = $last_SRArea; #SR-Area
                                                                $fields[7]  = $last_SRSubArea; #SR-SubArea

					   			$fields[8] = $last_dataCreazioneTicket;
					   			
					   	                $fields[9] = $last_queue;
					   		        my $ticketID = $pre_TicketID;
                                                                my %Ticket = $TicketObject->TicketGet(
                                                                                     TicketID => $ticketID,
                                                                             );

                                                                my %dataPrimaRisposta = $TicketObject->_TicketGetFirstResponse(
                                                                                           TicketID => $ticketID,
                                                                                           Ticket   => \%Ticket,  ); 	
                                                                $fields[10] = $dataPrimaRisposta{FirstResponse};
                                                                my %dataChiusura = $TicketObject->_TicketGetClosed(
                                                                                                     TicketID => $ticketID,
                                                                                                     Ticket   => \%Ticket,  );

                                                                my $SystemTime = $Self->{TimeObject}->SystemTime();             
                                                                my $Sysdate    = $TimeObject->SystemTime2TimeStamp(
                                                                                    SystemTime => $SystemTime,
                                                                                 );
                                                                $fields[11] = $dataChiusura{SolutionTime} || $Sysdate; #'YYYChiusuraORSysdate'; 
                                                                $fields[12] = $dataPrimaRisposta{FirstResponseInMin};
                                                                $fields[13] = $diffMin; #T permanenza Coda
					   			
					   			my @MyRow = @fields;
                                                                    $Self->{LogObject}->Log (
                                                                        Priority        => 'info',
                                                                        Message         => "RIGA3::::: @fields ",
                                                                    );
                                                                if( $last_queue_id eq 40 ) {
                                                                    #push ( @DataEnd , \@MyRow);

                                                                    my @lastRow = pop( @DataEnd );
                                                                    $Self->{LogObject}->Log (
                                                                            Priority        => 'info',
                                                                            Message         => "POPRIGA5:: @lastRow ...$lastRow[0][0] ",
                                                                    );
                                                                    if( ($lastRow[0][0] eq $MyRow[0]) && ($lastRow[0][9] eq $MyRow[9]) ){
                                                                         $lastRow[0][13] = $lastRow[0][13] + $MyRow[13];

                                                                         $Self->{LogObject}->Log (
                                                                                 Priority        => 'info',
                                                                                 Message         => "SUMMA POPRIGA5::$lastRow[0][0] --  $lastRow[0][13]",
                                                                         );
                                                                         push ( @DataEnd , @lastRow);    
                                                                    }
                                                                    else{
                                                                         push ( @DataEnd , @lastRow);
                                                                         push ( @DataEnd , \@MyRow);
                                                                    }
                                                                }
					   		}
					   		else {
					   			##Date dataFineInt = FORMATTER.parse(dataFine);
					   			
					   			##Date dateNow = new Date();
					   			##String nowString = FORMATTER.format(dateNow);
					   			
					   			##long diffMills = dateNow.getTime() - pre_data_ingresso;
					   			##int sec2 = (int)(diffMills/1000);
					   			
					   			#dataUscita = nowString;

                                                                my $After = $Self->{TimeObject}->SystemTime();  
              
                                                                my $Before = $Self->{TimeObject}->TimeStamp2SystemTime(
                                                                     String => " $pre_data_ingresso",
                                                                );
              
                                                                my $diffSec            = $TimeObject->WorkingTime(
                                                                                               StartTime => $Before,
                                                                                               StopTime  => $After,
                                                                                               Calendar  => 2,
                                                                                         );
                                                                my $diffMin = $diffSec/60; 
					   			$fields[0] = $last_tn;
                                                                $fields[1] = $Title;
                                                                $fields[2] = $last_ticketType;
                                                                $fields[3] = $last_ticketPriority;
                                                                $fields[4] = $last_stato;
                                                                $fields[5]  = $last_SRTipo; #SR-Tipo
                                                                $fields[6]  = $last_SRArea; #SR-Area
                                                                $fields[7]  = $last_SRSubArea; #SR-SubArea

					   	                
					   			$fields[8] = $last_dataCreazioneTicket;
					   			
					   	                $fields[9] = $last_queue;
					   		        my $ticketID = $last_TicketID;
                                                                my %Ticket = $TicketObject->TicketGet(
                                                                                     TicketID => $ticketID,
                                                                             );

                                                                my %dataPrimaRisposta = $TicketObject->_TicketGetFirstResponse(
                                                                                          TicketID => $ticketID,
                                                                                          Ticket   => \%Ticket,  ); 
                                                                $fields[10] = $dataPrimaRisposta{FirstResponse}; #'XXXXDataPrimaRisposta';
                                                                my %dataChiusura = $TicketObject->_TicketGetClosed(
                                                                                                     TicketID => $ticketID,
                                                                                                     Ticket   => \%Ticket,  );
                                                                
                                                                my $SystemTime = $Self->{TimeObject}->SystemTime();             
                                                                my $Sysdate    = $TimeObject->SystemTime2TimeStamp(
                                                                                      SystemTime => $SystemTime,
                                                                                 );
                                                                $fields[11] = $dataChiusura{SolutionTime} || $Sysdate; #'YYYChiusuraORSysdate'  
                                                                $fields[12] = $dataPrimaRisposta{FirstResponseInMin};
                                                                $fields[13] = $diffMin; #T permanenza Coda
					   			
					   			my @MyRow = @fields;
                                                                    $Self->{LogObject}->Log (
                                                                        Priority        => 'info',
                                                                        Message         => "RIGA4::::: @fields ",
                                                                    );
                                                                if( $last_queue_id eq 40 ) {
                                                                    #push ( @DataEnd , \@MyRow);

                                                                    my @lastRow = pop( @DataEnd );
                                                                    $Self->{LogObject}->Log (
                                                                            Priority        => 'info',
                                                                            Message         => "POPRIGA5:: @lastRow ...$lastRow[0][0] ",
                                                                    );
                                                                    if( ($lastRow[0][0] eq $MyRow[0]) && ($lastRow[0][9] eq $MyRow[9]) ){
                                                                         $lastRow[0][13] = $lastRow[0][13] + $MyRow[13];

                                                                         $Self->{LogObject}->Log (
                                                                                 Priority        => 'info',
                                                                                 Message         => "SUMMA POPRIGA5::$lastRow[0][0] --  $lastRow[0][13]",
                                                                         );
                                                                         push ( @DataEnd , @lastRow);    
                                                                    }
                                                                    else{
                                                                         push ( @DataEnd , @lastRow);
                                                                         push ( @DataEnd , \@MyRow);
                                                                    }
                                                                 }
 
					   		}
					   	} else {
					   		$j = $j-1;#rs4.previous(); //ELIMINATA
					   	}

##### FINE
           	     
           	     }
           	
           }
           else { 
                   #Esiste un solo storico quindi T = Sysdate - CreateTime
                   #create_time sulla ticket_history
                    my $create_time_before = $Data[$i][10]; #$rs3[5];
                    #my $local = localtime $create_time_before;

                    my $After = $Self->{TimeObject}->SystemTime();  
              
                    my $Before = $Self->{TimeObject}->TimeStamp2SystemTime(
                           String => "$create_time_before",
                    );
              
                    my $diffSec       = $TimeObject->WorkingTime(
                                                             StartTime => $Before,
                                                             StopTime  => $After,
                                                             Calendar  => 2,
                                                     );
                    my $diffMin        = $diffSec/60; 
                    my $ticketName     = $Data[$i][0];
                    my $ticketID       = $Data[$i][11]; 
                    my $ticketTitle    = $Data[$i][1];
                    my $ticketType     = $Data[$i][2];
                    my $ticketPriority = $Data[$i][3]; #TicketPriority
                    my $ticketState    = $Data[$i][4]; #rs4.getString(4);
                    my $SRTipo         = $Data[$i][5]; #SRTipo
                    my $SRArea         = $Data[$i][6]; #SRArea
                    my $SRSubArea      = $Data[$i][7]; #SRSubArea
                    my $queueID        = $Data[$i][12]; 
                    my $dataCreazioneTicket = $Data[$i][8];# rs4.getString(3).substring(0,19);
                    my $queue          = $Data[$i][9]; #$rs3[9];
                    
                   # my $dataIngresso   = $Data[$i][10]; #$rs3[5];
                   # my $dataUscita     = $Data[($i+1)][10]; #$rs4[5];
              
                    $fields[0] = $ticketName;
                    $fields[1] = $ticketTitle;
                    $fields[2] = $ticketType; #$rs3[1];
                    $fields[3] = $ticketPriority;
                    $fields[4] = $ticketState;
                    $fields[5] = $SRTipo;
                    $fields[6] = $SRArea;
                    $fields[7] = $SRSubArea;
                    $fields[8] = $dataCreazioneTicket;
                    $fields[9] = $queue;

                   # $fields[8] = $Data[$i][8]; #$rs3[2];
                   # $fields[5] = $Data[$i][5]; #$rs3[3];
                    
                   # $fields[10] = $dataIngresso;
                   # $fields[6] =  $TimeObject->SystemTime2TimeStamp(
                   #                   SystemTime => $After,
                   #               );
                    my $ticketID = $ticketID;
                    my %Ticket = $TicketObject->TicketGet(
                                                  TicketID => $ticketID,
                                                );

                  #  my $dataPrimaRisposta = $Ticket{FirstResponse};
                    my %dataPrimaRisposta = $TicketObject->_TicketGetFirstResponse(
                                                             TicketID => $ticketID,
                                                             Ticket   => \%Ticket,  );  
                    
                    $fields[10] = $dataPrimaRisposta{FirstResponse}; #'XXXXDataPrimaRisposta'; ##$pre_data_ingresso;
                    
                    my %dataChiusura = $TicketObject->_TicketGetClosed(
                                                          TicketID => $ticketID,
                                                          Ticket   => \%Ticket,  );

                    my $SystemTime = $Self->{TimeObject}->SystemTime();             
                    my $Sysdate    = $TimeObject->SystemTime2TimeStamp(
                                           SystemTime => $SystemTime,
                                     );
                    $fields[11] = $dataChiusura{SolutionTime} || $Sysdate; #'YYYChiusuraORSysdate';  
                    $fields[12] = $dataPrimaRisposta{FirstResponseInMin}; #'XXXXTempoPrimaRisposta';
                    $fields[13] = $diffMin; #T permanenza Coda

              
                    my @MyRow = @fields;
                         $Self->{LogObject}->Log (
                                  Priority        => 'info',
                                  Message         => "RIGA5::::: @fields",
                         );
                    if( $queueID eq 40 ) {
                        #push ( @DataEnd , \@MyRow);
                    
                        my @lastRow = pop( @DataEnd );
                        $Self->{LogObject}->Log (
                               Priority        => 'info',
                               Message         => "POPRIGA5:: @lastRow ...$lastRow[0][0] ",
                        );
                        if( ($lastRow[0][0] eq $MyRow[0]) && ($lastRow[0][9] eq $MyRow[9]) ){
                             $lastRow[0][13] = $lastRow[0][13] + $MyRow[13]; 
                        
                             $Self->{LogObject}->Log (
                                 Priority        => 'info',
                                 Message         => "SUMMA POPRIGA5::$lastRow[0][0] --  $lastRow[0][13]",
                             );
                             push ( @DataEnd , @lastRow); 
                        }
                        else{
                             push ( @DataEnd , @lastRow);
                             push ( @DataEnd , \@MyRow);  
                        }   
                    }


	         }   

      }


    $Self->{LogObject}->Log (
              Priority        => 'info',
             Message         => "DATA_INIZIO-FINE: $YearStart-$MonthStart-$DayStart - $YearEnd-$MonthEnd-$DayEnd ",
    );
    
    return ( [$Title], [@HeadData], @DataEnd );
}

1;

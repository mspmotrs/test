# --
# Kernel/System/Stats/TimeOnQueuePICustomer.pm - stats module
# Copyright (C) 2001-2009 OTRS AG, http://otrs.org/
# --
# $Id: TimeOnQueuePICustomer.pm,v 1.1 2011/12/14 08:16:26 rk Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Stats::Static::TimeOnQueuePICustomer;

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
    
     $Self->{TypeObject}   = Kernel::System::Type->new( %{$Self} );
    
    


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
    my $SelectedYear  = $M == 1 ? $Y - 1 : $Y;
    my $SelectedMonth = $M == 1 ? 12 : $M;
    my $SelectedDay = $M == 1 ? 1 : $D;
    
    # create possible time selections
    
    my %Year = map { $_ => (( $Y - 10 ) == $_) ? "" : $_ } ( $Y - 10 .. $Y );       
    my %Month = map { $_ => ($_ == 0 ) ? "" : sprintf( "%02d", $_ ); } ( 0 .. 12 );    
    my %Day = map {   $_ => ($_ == 0 ) ? "" : sprintf( "%02d", $_ ); } ( 0 .. 31 );
   
 	my %Types  = $Self->{TypeObject}->TypeList( Valid => 1,);
                      
   	push (
   	@Params,
        {
            Frontend  => 'Type',
            Name      => 'TypeIDs',
            Multiple  => 1,
            Size      => 6,
            Data      => \%Types,
        },
   	
   	);
   	   	
   	push (
   	@Params,
        {
            Frontend  => 'Ticket ID',
            Name      => 'TicketID',
            Type	 => 'text',
            
        },
   	
   	);

    push(
        @Params,
        {   Frontend   => 'Inizio intervallo creazione (Anno)',
            Name       => 'Year',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $SelectedYear,
            Data       => { %Year, },
        },
    );
    push(
        @Params,
        {   Frontend   => 'Inizio intervallo creazione (Mese)',
            Name       => 'Month',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $SelectedMonth,
            Data       => { %Month, },
        },
    );
    push(
        @Params,
        {   Frontend   => 'Inizio intervallo creazione (Giorno)',
            Name       => 'Day',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $SelectedDay-1,
            Data       => { %Day, },
        },
    );
        
    push(
        @Params,
        {   Frontend   => 'Fine intervallo creazione (Anno)',
            Name       => 'YearEnd',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $SelectedYear,
            Data       => { %Year, },
        },
    );
    
    push(
        @Params,
        {   Frontend   => 'Fine intervallo creazione (Mese)',
            Name       => 'MonthEnd',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $SelectedMonth,
            Data       => { %Month, },
        },
    );
    
    push(
        @Params,
        {   Frontend   => 'Fine intervallo creazione (Giorno)',
            Name       => 'DayEnd',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $SelectedDay,
            Data       => { %Day, },
        },
    );
    
    push(
        @Params,
        {   Frontend   => 'Inizio intervallo chiusura (Anno)',
            Name       => 'YearClose',
            Multiple   => 0,
            Size       => 0,
            SelectedID => 0,
            Data       => { %Year, },
        },
    );
    
    push(
        @Params,
        {   Frontend   => 'Inizio intervallo chiusura (Mese)',
            Name       => 'MonthClose',
            Multiple   => 0,
            Size       => 0,
            SelectedID => 0,
            Data       => { %Month, },
        },
    );
    
    push(
        @Params,
        {   Frontend   => 'Inizio intervallo chiusura (Giorno)',
            Name       => 'DayClose',
            Multiple   => 0,
            Size       => 0,
            SelectedID => 0,
            Data       => { %Day, },
        },
    );
        
    push(
        @Params,
        {   Frontend   => 'Fine intervallo chiusura (Anno)',
            Name       => 'YearEndClose',
            Multiple   => 0,
            Size       => 0,
            SelectedID => 0,
            Data       => { %Year, },
        },
    );
    push(
        @Params,
        {   Frontend   => 'Fine intervallo chiusura (Mese)',
            Name       => 'MonthEndClose',
            Multiple   => 0,
            Size       => 0,
            SelectedID => 0,
            Data       => { %Month, },
        },
    );
    push(
        @Params,
        {   Frontend   => 'Fine intervallo chiusura (Giorno)',
            Name       => 'DayEndClose',
            Multiple   => 0,
            Size       => 0,
            SelectedID => 0,
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

sub checkDate(){
	
	my ($Self,$d,$m,$y) = @_;
	 
	my @monthDays = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31) ;
 	if ($y == int($y/400)*400) { $monthDays[1] = 29; } 
 	elsif ($y != int($y/100)*100) {
		if ($y == int($y/4)*4) {
 			$monthDays[1] = 29;
		}
 	}
 	
 	return "" if ($y !~ /^\d+$/) ;
 	return "" if (!(($m>=1) && ($m<=12)));
 	if (!(($d>=1) && ($m<=$monthDays[$m-1]))) {
 		return "$y\-".$monthDays[$m-1]."\-$d";	
 	} else {
 		return "$y\-$m\-$d";
 	}
 		
}


sub Run(){
	
    my ( $Self, %Param ) = @_;
    
    my $TypeIDs = $Param{TypeIDs};
    my @TicketID = ();
    if ($Param{TicketID} ne "") { @TicketID = split(';', $Param{TicketID} ); }
    
    my $Year = $Param{Year};
    my $Month = $Param{Month};
    my $Day = $Param{Day};
    
    my $YearEnd = $Param{YearEnd};
    my $MonthEnd = $Param{MonthEnd};
    my $DayEnd = $Param{DayEnd};
    
    my $YearClose = $Param{YearClose};
    my $MonthClose = $Param{MonthClose};
    my $DayClose = $Param{DayClose};
    
    my $YearEndClose = $Param{YearEndClose};
    my $MonthEndClose = $Param{MonthEndClose};
    my $DayEndClose = $Param{DayEndClose};

    my @HeadData = ('Ticket ID','Data Creazione', 'Data Chiusura', 'Tipo','Codice Cliente', 'Creato da', "Priorita'", 'Stato','Oggetto','Descrizione','Ticket collegati','Coda corrente','Tempo permanenza',);
	
    for (keys %Param) {
          $Self->{LogObject}->Log (
              Priority  => 'info',
              Message   => "$_ = $Param{$_}",
          );
    }
    
    my $TimeObject = Kernel::System::Time->new(
        ConfigObject => $Self->{ConfigObject},
        LogObject    => $Self->{LogObject},
    );
    

    my $Title = "Lista utenti registrati su OTRS";

    my ($DBObject, $Select );
    my (@Data, $Title);

    $DBObject = $Self->{DBObject};
    
    my @Filter = ();
    
    push @Filter, "ticket.customer_id = '100055853000'"; #Solo i ticket di poste italiane!
	#push @Filter, "ticket.queue_id IN (53,54,55)";				
	push @Filter, "queue.name IN ('CC-PI-Gestionali','CC-PI-AssistenzaTecnica','PosteItaliane')";				
	push @Filter, "ticket.valid_id = 1";
	#push @Filter, "link_relation_padre.source_key IS NULL"; Servono tutti i ticket anche i figli di primo livello!
	
	my $dateStart = $Self->checkDate($Day,$Month,$Year);
	my $dateEnd = $Self->checkDate($DayEnd,$MonthEnd,$YearEnd);
    
	my $dateStartClose = $Self->checkDate($DayClose,$MonthClose,$YearClose);
	my $dateEndClose = $Self->checkDate($DayEndClose,$MonthEndClose,$YearEndClose);
	
	if (($dateStart ne "") && ($dateEnd ne "")) {
		push @Filter , "(DATE(ticket.create_time) BETWEEN '$dateStart' AND '$dateEnd')";
	}
	
	if (@TicketID){
		push @Filter , "ticket.tn IN (".join(",",@TicketID).")";
	}
	
	if (@{$TypeIDs}){
		push @Filter , "ticket.type_id IN (".join(",",@{$TypeIDs}).")";
	}

	my $WHERE = join(' AND ',@Filter);

	my $HAVING;
	if (($dateStartClose ne "") && ($dateEndClose ne "")) {
		$HAVING = "HAVING (DATE( DataChiusura ) BETWEEN '$dateStartClose' AND '$dateEndClose')";
	}

	my $SQLCalcolaTempiDifferenza = "
	SELECT 	
		ticket.id,
		IFNULL( UNIX_TIMESTAMP(ticket_history.create_time),0 ) AS StartTime ,
		IF( ticket_history.create_time IS NULL,
				0,
				UNIX_TIMESTAMP(IFNULL(th.create_time,NOW()))
			) AS EndTime,
			
		IF ( ticket_state_type.name = 'closed', MAX(th_data_chiusura.create_time) ,NULL ) AS DataChiusura		
								
	FROM 
		ticket
	
	LEFT JOIN ticket_history ON
		ticket_history.ticket_id = ticket.id
		AND ticket_history.valid_id = 1
		AND ticket_history.history_type_id = 16				
		AND ticket_history.queue_id IN ( 
			SELECT 
				queue.id 
			FROM 
				queue 
			WHERE 
				queue.name IN ('CC-PI-Gestionali','CC-PI-AssistenzaTecnica') 
				AND queue.valid_id = 1 
		)
		
	LEFT JOIN ticket_history th ON
		th.ticket_id = ticket_history.ticket_id
		AND th.id = (	
							SELECT 
								th_sub.id
							FROM 
								ticket_history th_sub 
							INNER JOIN queue queue_sub ON
								queue_sub.id = th_sub.queue_id
								AND queue_sub.valid_id = 1
								AND queue_sub.name = 'PosteItaliane'
							WHERE
								th_sub.ticket_id = ticket_history.ticket_id
								AND th_sub.id > ticket_history.id
								AND th_sub.history_type_id = 16
								AND th_sub.queue_id = queue_sub.id
								
								LIMIT 0,1
							)
			
									
		INNER JOIN queue ON
			queue.id = ticket.queue_id
			AND queue.valid_id = 1
			
		INNER JOIN ticket_state ON
			ticket_state.id = ticket.ticket_state_id
			AND ticket_state.valid_id = 1

		INNER JOIN ticket_state_type ON	
			ticket_state_type.id = ticket_state.type_id

		LEFT JOIN ticket_history th_data_chiusura ON
			th_data_chiusura.ticket_id = ticket.id
			AND th_data_chiusura.valid_id = 1
			AND th_data_chiusura.history_type_id = 27
			AND th_data_chiusura.state_id = ticket.ticket_state_id
										
		WHERE
			$WHERE
			
		GROUP BY 
			ticket.id,StartTime,EndTime

		$HAVING 
		
		ORDER BY 
			ticket.id,ticket_history.id	
	";	
	
	my %TempoDiPermanenza;

    $Self->{DBObject}->Prepare( SQL => $SQLCalcolaTempiDifferenza );
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
    	
		my $diffSec = $TimeObject->WorkingTime(StartTime => $Row[1],StopTime  => $Row[2],Calendar  => 10,);
		
		$TempoDiPermanenza{$Row[0]} += $diffSec;
		        
    }


    my $SQL = "SELECT 	
				ticket.id,
				ticket.tn,			
				ticket.create_time,				
				IF ( ticket_state_type.name = 'closed', MAX(th_data_chiusura.create_time) ,'' ) AS DataChiusura,
				ticket_type.name AS type,				
				ticket.customer_id,
				ticket.customer_user_id,				
				ticket_priority.name AS priority,
				ticket_state.name AS state,
				
				ticket.title,
				article.a_body AS article,
				
				IFNULL(GROUP_CONCAT(DISTINCT ticket_figlio.tn SEPARATOR '|'),' ') AS ListaIDFigli,
				
				queue.name AS queue											 

			FROM 
				ticket
			
			INNER JOIN ticket_history th_webrequestcustomer ON
				th_webrequestcustomer.ticket_id = ticket.id
				AND th_webrequestcustomer.id = (
					SELECT MIN(id) 
					FROM ticket_history th 
					WHERE 
						th.ticket_id = th_webrequestcustomer.ticket_id 
						AND th.history_type_id IN (15,29)
						AND th.valid_id = 1
					)
				AND th_webrequestcustomer.valid_id = 1

			INNER JOIN article ON
				article.id = th_webrequestcustomer.article_id
				AND article.valid_id = 1


			LEFT JOIN link_relation link_relation_figli ON		
				link_relation_figli.source_key = ticket.id
				AND link_relation_figli.source_object_id = 1
				AND link_relation_figli.target_object_id = 1
				AND link_relation_figli.type_id = 2

			LEFT JOIN ticket ticket_figlio ON
				ticket_figlio.id = link_relation_figli.target_key
				AND ticket_figlio.valid_id = 1				
										

			INNER JOIN ticket_type ON 
				ticket_type.id = ticket.type_id
				AND ticket_type.valid_id = 1
				
			INNER JOIN ticket_priority ON
				ticket_priority.id = ticket.ticket_priority_id
				AND ticket_priority.valid_id = 1
				
			INNER JOIN ticket_state ON
				ticket_state.id = ticket.ticket_state_id
				AND ticket_state.valid_id = 1
			
			INNER JOIN queue ON
				queue.id = ticket.queue_id
				AND queue.valid_id = 1
				
			INNER JOIN ticket_state_type ON	
				ticket_state_type.id = ticket_state.type_id
			
			LEFT JOIN ticket_history th_data_chiusura ON
				th_data_chiusura.ticket_id = ticket.id
				AND th_data_chiusura.valid_id = 1
				AND th_data_chiusura.history_type_id = 27
				AND th_data_chiusura.state_id = ticket.ticket_state_id

				
			WHERE
				$WHERE
							
			GROUP BY				
				ticket.id							
			
			$HAVING

			ORDER BY 
				ticket.id";				
				
				
    my $LanguageObject = Kernel::Language->new(
        MainObject   => $Self->{MainObject},
        ConfigObject => $Self->{ConfigObject},
        EncodeObject => $Self->{EncodeObject},
        LogObject    => $Self->{LogObject},
        UserLanguage => 'it',
    );
    

    $Self->{LogObject}->Log (
        Priority  => 'info',
        Message   => "SQL = " . $SQL,
    );

    #Read SQL result and put it in @Data
    $Self->{DBObject}->Prepare( SQL => $SQL );

    
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
    	
		my @CurrentRow = ();
		my $TotalElements = @Row;
    	for(my $i = 1; $i < $TotalElements; $i++) {
    		  
			push @CurrentRow, $LanguageObject->Get($Row[$i]);    		
    	}
    	my $TempoPermanenzaMinuti = 0;
    	if ($TempoDiPermanenza{$Row[0]}){
			$TempoPermanenzaMinuti = ($TempoDiPermanenza{$Row[0]} / 60);     		    		
    	}
    	
    	push @CurrentRow,$TempoPermanenzaMinuti;
    	
        #push ( @Data , \@Row);
        push ( @Data , \@CurrentRow);
    }

    return ( [$Title], [@HeadData], @Data );	
}

1;

# --
# Kernel/System/Stats/TopTen.pm - stats module
# Copyright (C) 2001-2009 OTRS AG, http://otrs.org/
# --
# $Id: StateAction.pm,v 1.2 2006/03/09 08:16:26 rk Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Stats::Static::ListaTT;

use strict;
use warnings;

#use Date::Calc qw(Add_Delta_Days);
use Date::Pcalc qw(Today_and_Now Days_in_Month Day_of_Week Day_of_Week_Abbreviation Add_Delta_Days);

use vars qw($VERSION);
$VERSION = '$Revision: 1.2 $ ';

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = { %Param };
    bless( $Self, $Type );

    # check all needed objects
    for (qw(DBObject ConfigObject LogObject)) {
        die "Got no $_" if ( !$Self->{$_} );
    }

    return $Self;
}

sub Param {
    my $Self = shift;

    my @Params = ();
    my %marcaggio;
		#Trovare i valori possibili dei parametri
	  my $SQL = "select id,name from ticket_state";
    $Self->{DBObject}->Prepare( SQL => $SQL );
    while ( my @RowTmp = $Self->{DBObject}->FetchrowArray() ) {
        $marcaggio { $RowTmp[0] } = $RowTmp[1];
    }

    push(
        @Params,
        {   Frontend   => 'Stati',
            Name       => 'Stati',
            Multiple   => 1,
            Size       => 0,
           # SelectedID => 'Business',
            Data       => { %marcaggio, },
        },
    );

    my( $s,$m, $h, $D, $M, $Y, $wd, $yd, $dst ) = localtime( time() );
    $Y = $Y + 1900;
    $M = $M+1;
    
    # get one month before
    #if ( $M == 1 ) {
    #    $M = 12;
    #    $Y = $Y - 1;
    #}
    #else {
    #    $M = $M - 1;
    #}
    
    # create possible time selections
    my %Year = ();
    for ( $Y - 10 .. $Y + 1 ) {
        $Year{$_} = $_;
    }
    my %Month = ();
    for ( 1 .. 12 ) {
        my $Tmp = sprintf( "%02d", $_ );
        #$Month{$_} = $Tmp;
        $Month{$Tmp} = $Tmp;
    }
    my %Day = ();
    for ( 1 .. 31 ) {
        my $Tmp = sprintf( "%02d", $_ );
        $Day{$Tmp} = $Tmp;
    }
    


    my $yearTemp;
    my $monthTemp;
    my $dayTemp;
    ($yearTemp, $monthTemp, $dayTemp) = Add_Delta_Days($Y,$M,$D,-365);
    
    if( $monthTemp < 10){
       $monthTemp = '0'.$monthTemp;
    }
    if( $dayTemp < 10){
       $dayTemp = '0'.$dayTemp;
    }
    if( $M < 10){
       $M = '0'.$M;
    }
    if( $D < 10){
       $D = '0'.$D;
    }

    
    push(
        @Params,
        {   Frontend   => 'Inizio intervallo (Anno)',
            Name       => 'Year',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $yearTemp,
            Data       => { %Year, },
        },
    );
    push(
        @Params,
        {   Frontend   => 'Inizio intervallo (Mese)',
            Name       => 'Month',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $monthTemp,
            Data       => { %Month, },
        },
    );
    push(
        @Params,
        {   Frontend   => 'Inizio intervallo (Giorno)',
            Name       => 'Day',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $dayTemp,
            Data       => { %Day, },
        },
    );
        
    push(
        @Params,
        {   Frontend   => 'Fine intervallo (Anno)',
            Name       => 'YearEnd',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $Y,
            Data       => { %Year, },
        },
    );
    push(
        @Params,
        {   Frontend   => 'Fine intervallo (Mese)',
            Name       => 'MonthEnd',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $M,
            Data       => { %Month, },
        },
    );
    push(
        @Params,
        {   Frontend   => 'Fine intervallo (Giorno)',
            Name       => 'DayEnd',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $D,
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

		my @HeadData = ('Ticket_ID', 'Oggetto', 'DataCreazione', 'CreatoDa','ModificatoDa','ChangeTime','CodaAttuale','Stato','Prorita',
                                'Tipo','SubTipo','Marcaggio','MSISDN o CdG','IMSI_ICCID','DEVTicketID','StatoCQ','TimeStampCQ','VFTicketID','Release');

		for (keys %Param) {
			    $Self->{LogObject}->Log (
	            Priority	=> 'info',
  	          Message		=> "$_ = $Param{$_}",
    			);
		}

		
                #get the time period
                my $YearStart  = $Param{Year};
                my $MonthStart = $Param{Month};
                my $DayStart   = $Param{Day};
         
                my $YearEnd    = $Param{YearEnd};
                my $MonthEnd   = $Param{MonthEnd};
                my $DayEnd     = $Param{DayEnd};


 
    my $mark;
    my $stateSelected = '';
    my $stateIdLength = @{$Param{Stati}};


    if( $stateIdLength > 0 ){
       $stateSelected = 'and t.ticket_state_id in (';

       for $mark (@{$Param{Stati}}){ 
	   $stateSelected .=$mark.',';
       }
    
       my $length = length $stateSelected;
       my $fragment =  substr($stateSelected, 0, $length-1);

       $stateSelected = $fragment.')';
    }


#$Self->{LogObject}->Log (
#        Priority       => 'error',
#       Message         => "LLLLLLLLL " . $yearTemp.'   '.$monthTemp.'       '.$dayTemp,
#);


   
    my $Title = "Lista Trouble Ticket";

    my ($DBObject, $Select );
    my (@Data, $Title);

    $DBObject = $Self->{DBObject};


    my $SQL
	= "select concat('''', t.tn) as TicketID, t.title as oggetto, t.create_time as data_creazione,                                         "
	. "	ucr.login as creato_da,uch.login as modificato_da,t.change_time as data_ult_modifica,                                        "
	. "	q.name as coda_attuale,                                                                                                      "
	. "	case ts.name WHEN 'closed successful' THEN 'chiuso'                                                                          "
	. "	WHEN 'closed unsuccessful' THEN 'rigettato'                                                                                  "
	. "	WHEN 'in progress' THEN 'in lavorazione'                                                                                     "
	. "	WHEN 'merged' THEN 'unito'                                                                                                   "
	. "	WHEN 'new' THEN 'nuovo'                                                                                                      "
	. "	WHEN 'open' THEN 'aperto'                                                                                                    "
	. "	WHEN 'pending auto close+' THEN 'risolto'                                                                                    "
	. "	WHEN 'pending auto close-' THEN 'rigettato'                                                                                  "
	. "	WHEN 'pending reminder' THEN 'in attesa info'                                                                                "
	. "	WHEN 'removed' THEN 'eliminato'                                                                                              "
	. "	else ts.name END as stato_ticket,                                                                                            "
	. "	tp.name as priorita, tt.name as tipo, t.freetext13 as subtype, t.freetext1 as marcaggio,                                      "
	. "	t.freetext2 as MSISDN,t.freetext3 as IMSI,                                                                                   "
	. "	t.freetext7 as DEV_TICKET_ID,t.cq_state as Stato_CQ, t.cq_date as TimeStamp_CQ, t.freetext9 as 'VF_TICKET_ID',               "
	. "  t.freetext8 as 'RELEASE'                                                                                           "
	. "from ticket t,ticket_state ts, queue q, ticket_priority tp,ticket_type tt, article a,article_type at,users ucr,users uch 		 "
	. "where t.id = a.ticket_id                                                                                                      "
	. "   and t.ticket_state_id = ts.id                                                                                              "
	. "   and t.queue_id = q.id                                                                                                      "
	. "   and tp.id = t.ticket_priority_id                                                                                           "
	. "   and tt.id = t.type_id                                                                                                      "
	. "   and a.article_type_id = at.id                                                                                              "
	. "   and ucr.id = t.create_by                                                                                                   "
	. "   and uch.id = t.change_by                                                                                                   "
	. "   and tt.name not like ('SR%')                                                                                               "
	. "   and ucr.login != 'CustomerAgent'                                                                                           "
	. "   and t.tn not in ('2010082410000019','2010083010000016','2010090110000015','2010090110000024','2010090210000013',           "
	. "                    '2011051010017817','2011051010017808','2011051010017782')                                                 "
	. "   and date(t.create_time)>='$YearStart-$MonthStart-$DayStart'                                                                      "
	. "   and date(t.create_time)<='$YearEnd-$MonthEnd-$DayEnd'                                                                             "
	. "   $stateSelected                                                                                                             "
	. "group by a.ticket_id                                                                                                          "
	. "order by a.ticket_id,a.create_time                                                                                            ";



    $Self->{LogObject}->Log (
        Priority	=> 'info',
 		 		Message		=> "SQL = " . $SQL,
 		);
		                        
    #Read SQL result and put it in @Data
    $Self->{DBObject}->Prepare( SQL => $SQL );
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        push ( @Data , \@Row);
    }

    return ( [$Title], [@HeadData], @Data );
}

1;

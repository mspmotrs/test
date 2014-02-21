# --
# Kernel/System/Stats/TicketReopenITL.pm - stats module
# Copyright (C) 2001-2009 OTRS AG, http://otrs.org/
# --
# $Id: TicketReopenITL.pm,v 1.1 2011/12/14 08:16:26 rk Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Stats::Static::TicketReopenITL;

use strict;
use warnings;

use Date::Pcalc qw(Today_and_Now Days_in_Month Day_of_Week Day_of_Week_Abbreviation);
use Kernel::Config;
use Kernel::System::Encode;
use Kernel::System::Log;
use Kernel::System::Main;
use Kernel::Language;


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

    my @HeadData = ('ID', 'Oggetto' , 'Tipo', 'Priorita\'', 'Stato','SR Tipo', 'SR Area', 'SR Sub-Area', 'Numero di Riaperture', 'Data di creazione OTRS', 'Data chiusura', 'Da Coda', 'A Coda', 'Data Move');

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
 	
#    my $Title = "TicketReopenITL TripletteSR Ticket creati dal $DayStart-$MonthStart-$YearStart al $DayEnd-$MonthEnd-$YearEnd";
    my $Title = "TicketReopenITL ";
	
    my @HeadData = ('ID', 'Oggetto' , 'Tipo', 'Priorita\'', 'Stato','SR Tipo', 'SR Area', 'SR Sub-Area', 'Data di Creazione su OTRS', 'Data chiusura', 'Da Coda', 'A Coda', 'Data Move');

	
    my ($DBObject, $Select );
    my (@Data, $Title);

    $DBObject = $Self->{DBObject};

    my $SQL
         = "select t_filter.tn      as TicketName "
  . "      ,t_filter.title          as TicketTitle "
  . "      ,tt.name                 as TicketType "
  . "      ,tp.name                 as TicketPriority "
  . "      ,ts.name                 as Stato_Corrente "
  . "      ,t_filter.freetext4      as SRTipo "
  . "      ,t_filter.freetext5      as SRArea "
  . "      ,t_filter.freetext6      as SRSubArea "
  . "      ,t_filter.create_time    as Data_Creazione_Ticket "
  . "      ,FROM_UNIXTIME(t_filter.until_time - (1*60*60*24))                 as Data_Chiusura_Ticket "
  . "      ,SUBSTRING_INDEX( SUBSTRING_INDEX( th.name, '%%', -2) , '%%', 1 )  as Da_Coda "
  . "      ,SUBSTRING( SUBSTRING_INDEX( th.name, '%%', 2), 3 )                as A_Coda "
  . "      ,th.create_time          as Data_Move "
  . "  from ticket_history th "
  . "      ,( select * "
  . "           from ticket t "
  . "          where ( t.create_time >= '$YearStart-$MonthStart-$DayStart 00:00:00' "
  . "              and t.create_time <= '$YearEnd-$MonthEnd-$DayEnd 23:59:59' ) "
  . "              and t.queue_id in ( 46, 47, 48, 49, 50, 56, 57 ) "
  . "       ) t_filter "
  . "      ,ticket_type     tt "
  . "      ,ticket_state    ts "
  . "      ,ticket_priority tp "
  . "      ,queue            q "
  . " where th.ticket_id                 = t_filter.id "
  . "   and t_filter.type_id             = tt.id "
  . "   and t_filter.ticket_state_id     = ts.id "
  . "   and t_filter.ticket_priority_id  = tp.id "
  . "   and t_filter.queue_id            = q.id "
  . "   and th.history_type_id           = 16 "
  . "   and th.queue_id                  in ( 46,47,56,57 ) "
  . " order by t_filter.id desc ";


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
#          $Self->{LogObject}->Log (
#              Priority        => 'info',
#              Message         => "SQL ResultRow= @Row ---- $Dat --TRANS--> $TranslatedElement",
#          );
          push(@TranslatedRow, $TranslatedElement);
        } 
#        push ( @Data , \@Row);
         push ( @Data , \@TranslatedRow); 
    }

    return ( [$Title], [@HeadData], @Data );
}

1;

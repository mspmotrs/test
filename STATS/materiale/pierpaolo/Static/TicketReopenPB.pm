# --
# Kernel/System/Stats/TicketReopenPB.pm - stats module
# Copyright (C) 2001-2009 OTRS AG, http://otrs.org/
# --
# $Id: TicketReopenPB.pm,v 1.1 2011/12/14 08:16:26 rk Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Stats::Static::TicketReopenPB;

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

    my @HeadData = ('ID', 'Subject' , 'Tipo', 'Priorita\'', 'Stato','SR Tipo', 'SR Area', 'SR Sub-Area', 'Numero di Riaperture');

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
 	
#    my $Title = "TicketReopenPB TripletteSR Ticket creati dal $DayStart-$MonthStart-$YearStart al $DayEnd-$MonthEnd-$YearEnd";
    my $Title = "TicketReopenPB ";
		
    my ($DBObject, $Select );
    my (@Data, $Title);

    $DBObject = $Self->{DBObject};

    my $SQL
        = "select t.tn,t.title,tt.name,tp.name,ts.name,t.freetext4,t.freetext5,t.freetext6,count(t.tn) "
        . "  from ticket          t  "
        . "      ,ticket_type     tt "
        . "      ,ticket_priority tp "
        . "      ,ticket_state    ts "
        . "      ,ticket_history  th "
        . " where t.id                  = th.ticket_id "  
        . "   and t.type_id             = tt.id "
        . "   and t.ticket_priority_id  = tp.id "
        . "   and t.ticket_state_id     = ts.id " 
        . "   and t.channel             = 'Siebel' "
        . "   and t.sr_assigned_to      like 'PureBros%' "
        . "   and t.tn                  like '%PB' " 
        . "   and (  (th.history_type_id = 16 and th.queue_id = 40) OR (th.history_type_id = 1  and th.queue_id = 40) ) " 
        . "   and t.create_time >= '$YearStart-$MonthStart-$DayStart' "
        . "   and t.create_time <= '$YearEnd-$MonthEnd-$DayEnd' "
        . " group by t.tn "
        . " order by t.id ";                   

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

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

package Kernel::System::Stats::Static::TopTen;

use strict;
use warnings;

use Date::Pcalc qw(Today_and_Now Days_in_Month Day_of_Week Day_of_Week_Abbreviation);

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
	  my $SQL = "select distinct freetext1 from ticket where freetext1 !=''";
    $Self->{DBObject}->Prepare( SQL => $SQL );
    while ( my @RowTmp = $Self->{DBObject}->FetchrowArray() ) {
        $marcaggio { $RowTmp[0] } = $RowTmp[0];
    }

    push(
        @Params,
        {   Frontend   => 'Marcaggio',
            Name       => 'Marcaggio',
            Multiple   => 0,
            Size       => 0,
            SelectedID => 'Business',
            Data       => { %marcaggio, },
        },
    );

		#my %timeunit;
		#for ( 1 .. 99 ) {
    #    my $Tmp = sprintf( "%02d", $_ );
    #    $timeunit{$_} = $Tmp;
    #}
    #
    #push(
    #    @Params,
    #    {   Frontend   => 'Creato da',
    #        Name       => 'TimeUnit',
    #        Multiple   => 0,
    #        Size       => 0,
    #        SelectedID => '1',
    #        Data       => { %timeunit, },
    #    },
    #);
		#
		#my %timequantity;
		#$timequantity{'Day'} = 'Giorno';
		#$timequantity{'Week'} = 'Settimana';
		#$timequantity{'Month'} = 'Mese';
		#$timequantity{'Year'} = 'Anno';
    #
    #push(
    #    @Params,
    #    {   Frontend   => '',
    #        Name       => 'TimeQuantity',
    #        Multiple   => 0,
    #        Size       => 0,
    #        SelectedID => 'Giorno',
    #        Data       => { %timequantity, },
    #    },
    #);

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
        {   Frontend   => 'Creato da (Anno)',
            Name       => 'Year',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $Y-1,
            Data       => { %Year, },
        },
    );
    push(
        @Params,
        {   Frontend   => 'Creato da (Mese)',
            Name       => 'Month',
            Multiple   => 0,
            Size       => 0,
            SelectedID => 1,
            Data       => { %Month, },
        },
    );
    push(
        @Params,
        {   Frontend   => 'Creato da (Giorno)',
            Name       => 'Day',
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

		my @HeadData = ('SR Tipo', 'SR Area', 'SR SubArea', 'Numero');

		for (keys %Param) {
			    $Self->{LogObject}->Log (
	            Priority	=> 'info',
  	          Message		=> "$_ = $Param{$_}",
    			);
		}

		#get the time period
    my $Year  = $Param{Year};
    my $Month = $Param{Month};
    my $Day   = $Param{Day};
		
		#get the selected CustomerSegment
		my $Marcaggio = $Param{Marcaggio};
		
    my $Title = "TopTenTripletteSR Ticket $Marcaggio creati dal $Day-$Month-$Year";

		my ($DBObject, $Select );
    my (@Data, $Title);

    $DBObject = $Self->{DBObject};

    my $SQL
        = "select t.freetext4,t.freetext5,t.freetext6,count(id) "
        . "  from ticket t "
        . " where trim(t.freetext4) !='' "
        . "   and trim(t.freetext5) !='' "
        . "   and trim(t.freetext6) !='' "
        . "   and t.create_time >= '$Year-$Month-$Day' "
        . "   and t.sr_assigned_to like 'MVNE%' "  
        . "   and t.freetext1 = '$Marcaggio'"
        . " group by t.freetext4,t.freetext5,t.freetext6 "
        . " order by 4 desc";                       

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

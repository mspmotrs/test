# --
# Kernel/System/Stats/ListProfiles.pm - stats module
# --
# $Id: ListProfiles.pm,v 1.0 2010/10/07 12:02:26 cf Exp $
# --
# --

package Kernel::System::Stats::Static::ListProfiles;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = '$Revision: 1.0 $ ';

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
    return @Params;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my @HeadData = ('Denominazione', 'Descrizione', 'Permessi'
                  , 'Gruppo code', 'Descrizione gruppo','Data ultimamodifica');

    for (keys %Param) {
          $Self->{LogObject}->Log (
              Priority  => 'info',
              Message   => "$_ = $Param{$_}",
          );
    }

    my $Title = "Lista profili registrati su OTRS";

    my ($DBObject, $Select );
    my (@Data, $Title);

    $DBObject = $Self->{DBObject};

    my $SQL
        = "select r.name as denominazione
                , r.comments as descrizione
                , group_concat(gr.permission_key order by gr.create_time asc separator ', ') as permessi
                , g.name as gruppo_code
                , g.comments as descrizione_gruppo
                , r.change_time as data_ult_modifica
             from roles r join group_role gr on r.id = gr.role_id join groups g on gr.group_id = g.id
            where gr.permission_value = '1'
            group by r.name, g.name
            order by r.name,g.name ";

    $Self->{LogObject}->Log (
        Priority  => 'info',
        Message   => "SQL = " . $SQL,
    );

    #Read SQL result and put it in @Data
    $Self->{DBObject}->Prepare( SQL => $SQL );
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        push ( @Data , \@Row);
    }

    return ( [$Title], [@HeadData], @Data );
}

1;

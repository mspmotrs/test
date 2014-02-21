# --
# Kernel/System/Stats/ListUsers.pm - stats module
# --
# $Id: ListUsers.pm,v 1.0 2010/10/06 12:02:26 cf Exp $
# --
# --

package Kernel::System::Stats::Static::ListUsers;

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

    my @HeadData = ('UserID', 'Nome', 'Cognome'
                  , 'Profili', 'Valido', 'Ultimo accesso');

    for (keys %Param) {
          $Self->{LogObject}->Log (
              Priority  => 'info',
              Message   => "$_ = $Param{$_}",
          );
    }

    my $Title = "Lista utenti registrati su OTRS";

    my ($DBObject, $Select );
    my (@Data, $Title);

    $DBObject = $Self->{DBObject};

    my $SQL
        = "select u.login as user_id
                , u.first_name as nome
                , u.last_name as cognome
                , ifnull(group_concat(r.name ORDER BY r.create_time ASC SEPARATOR ', '),'nessuno') as profili
                , IF(u.valid_id = 1, 'si', 'no') as valido
                , from_unixtime(up.preferences_value) as ultimo_accesso
             from users as u left outer join user_preferences as up ON u.id = up.user_id
                  left outer join role_user as ru on up.user_id = ru.user_id
                  left outer join roles r on r.id =ru.role_id
            WHERE up.preferences_key = 'UserLastLogin'
            group by u.login ";

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

# --
# Kernel/System/Stats/ListUsers.pm - stats module
# --
# $Id: ListUsers.pm,v 1.0 2010/10/06 12:02:26 cf Exp $
# --
# --

package Kernel::System::Stats::Static::ListCustomerUsers;

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

    my @HeadData = ('Nr','UserID', 'Nome', 'Cognome','Codice Cliente','Valido', 'Ultimo accesso');

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
        = "select \@rownum:=\@rownum+1 as rank, b.*
             from ( 
             
					SELECT 
					
						customer_user.login as user_id, 
						customer_user.first_name as nome,
						customer_user.last_name as cognome,
						CONCAT(customer_company.customer_id,' ',customer_company.name) AS codice_cliente,
						IF(customer_user.valid_id = 1, 'si', 'no') as valido,
						FROM_UNIXTIME(customer_preferences.preferences_value) as ultimo_accesso
											
					FROM
						customer_user
						
					INNER JOIN customer_preferences ON
						customer_preferences.user_id = customer_user.login
						AND customer_preferences.preferences_key = 'UserLastLogin'
						
					INNER JOIN customer_company ON
						customer_company.customer_id = customer_user.customer_id
						AND customer_company.valid_id = 1
					
					
					WHERE
						customer_user.valid_id = 1
						
						
					ORDER BY 
						customer_user.id
             
              ) b
               , (SELECT \@rownum:=0) r ";

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

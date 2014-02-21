# --
# Kernel/System/Stats/ListUsers.pm - stats module
# --
# $Id: ListUsers.pm,v 1.0 2010/10/06 12:02:26 cf Exp $
# --
# --

package Kernel::System::Stats::Static::ListPermessiCustomerUsers;

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

    my @HeadData = ('Nr','UserID', 'Permessi','Gruppo Code');

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
										
						GROUP_CONCAT(group_customer_user.permission_key ORDER BY group_customer_user.group_id,group_customer_user.create_time ASC SEPARATOR ', ') AS permessi,
						GROUP_CONCAT(DISTINCT groups.name ORDER BY groups.id SEPARATOR ', ') AS gruppo_code
											
					FROM
						customer_user
						
					INNER JOIN customer_preferences ON
						customer_preferences.user_id = customer_user.login
						AND customer_preferences.preferences_key = 'UserLastLogin'
					
					INNER JOIN customer_company ON
						customer_company.customer_id = customer_user.customer_id
						AND customer_company.valid_id = 1
					
					INNER JOIN group_customer_user ON
						group_customer_user.user_id = customer_user.login
						AND group_customer_user.permission_value = '1'
					
					INNER JOIN groups ON
						groups.id = group_customer_user.group_id
						AND groups.valid_id = 1
						
					
					WHERE
						customer_user.valid_id = 1
						
					GROUP BY
						customer_user.login,
						groups.name
						
					ORDER BY 
						customer_user.id,
						groups.name,
						group_customer_user.permission_key ASC
             
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

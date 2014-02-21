# --
# Kernel/System/Ticket/Acl/FlowStates.pm - acl module
# - Diagramma degli stati  -
# --
# $Id: FlowStates.pm,v 1.14 2010/09/13 11:57:50 cresh Exp $
# --
# --

package Kernel::System::Ticket::Acl::FlowStates;

use strict;
use warnings;

###use Kernel::System::LinkObject;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.14 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for (
        qw(ConfigObject DBObject TicketObject LogObject UserObject CustomerUserObject MainObject TimeObject EncodeObject)
        )
    {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    return $Self;
}

sub Run {

	my ( $Self, %Param ) = @_;
    # check needed stuff
    for (qw(Config Acl)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

	$Self->{LogObject}->Log( Priority => 'info', Message => "FLOW_STATES Called..." );

	
    # check if child tickets are not closed
    #return 1 if (!$Param{TicketID} || !$Param{UserID});CR Se si applica questa condizione non viene eseguita la ACL quando il ticket è in fase di creazione
    return 1 if ($Param{CustomerUserID}); # Questa ACL non si applica per i customer

    my ( $Package1, $Filename1, $Line1, $Subroutine1 ) = caller( 0 );
    my ( $Package2, $Filename2, $Line2, $Subroutine2 ) = caller( 1 );

  #  #Check if the AgentTicketZoom module is a caller
  #  if ( $Package1 ne 'Kernel::Modules::AgentTicketZoom' &&
  #       $Package2 ne 'Kernel::Modules::AgentTicketZoom' 
  #     ) 
  #  {
  #      return 1;
  #  }
  
    my %Ticket; 
 
    # get ticket 
    if( $Param{TicketID} ) {
       # get ticket
        %Ticket = $Self->{TicketObject}->TicketGet(
          TicketID => $Param{TicketID},
       );
    }    

    my %AllType = ();

    # get type
    if ( $Param{QueueID} || $Param{TicketID} ) {
       %AllType = $Self->{TicketObject}->TicketTypeList(
           %Param,
           Action => $Self->{Action},
           UserID => 1, 
       );
    }
    
    #$Self->{LogObject}->Log( Priority => 'info', Message => "Caller $Package1, $Filename1, $Line1, $Subroutine1." );
    #$Self->{LogObject}->Log( Priority => 'info', Message => "Caller $Package2, $Filename2, $Line2, $Subroutine2." );

    my %catenaField = %{ $Self->{ConfigObject}->Get( 'cateneFamily' )};

    my @AllNotPossibleQueues = ();
 
    for my $Key ( keys %catenaField ) {
       if( $catenaField{$Key} !~ $Ticket{Queue}  ){ 
      #   $Self->{LogObject}->Log( Priority => 'info', Message => "CATENA SCELTA: $Key . CODA CORRENTE: $Ticket{Queue} . VALORI: $catenaField{$Key} " );
            push( @AllNotPossibleQueues, split(';',$catenaField{$Key}) ); 
       } 
    }

    #$Self->{LogObject}->Log( Priority => 'info', Message => "ALL POSSIBLE NOT QUEUES: @AllNotPossibleQueues " );
    
    #CR1490
    #Leggo i tipi di ticket definiti per i customer user

    my %PossibleTypeByCustomerCompany = %{ $Self->{ConfigObject}->Get("Ticket::Acl::PossibleTypeByCustomerCompany") };
    my %UniqueCustomerTypes;
    my @CustomerTypes;
    
    foreach my $CustomerID ( keys %PossibleTypeByCustomerCompany ) {
    	for my $i ( 0 .. $#{ $PossibleTypeByCustomerCompany{$CustomerID} } ) {
			 $UniqueCustomerTypes{$PossibleTypeByCustomerCompany{$CustomerID}[$i]} = 1;    		
    	}
    }
  
    @CustomerTypes = keys %UniqueCustomerTypes;

    #CR1686 - Restrizione sui ticket_type possibili per PI - START 
    my @AllNotPossibleTypeAgent = ();
	
	$Self->{LogObject}->Log( Priority => 'error', Message => "@@@@@@@@@@@@@@@@@@@@@@@@@@@@ TicketTypeID: $Ticket{TypeID}   =>   TicketType: $Ticket{Type}" );
	
	if ( $Ticket{TypeID} eq '1' || $Ticket{TypeID} eq '9' || $Ticket{TypeID} eq '10' || $Ticket{TypeID} eq '45' || $Ticket{TypeID} eq '46' || $Ticket{TypeID} eq '47' ) {
       #$Self->{LogObject}->Log( Priority => 'error', Message => "@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Caller CHIAMATO $Ticket{TypeID} $Ticket{Type}" );
       my $FixedType = $Ticket{TypeID};
  
       for my $TKey ( keys %AllType ) { 
          if ( $FixedType ne $TKey ) {
                push( @AllNotPossibleTypeAgent, $AllType{$TKey} );           
          } 
       }             

    }
    else { 
        #Lettura TicketType Non da non mostrare in Creazione e CampiLiberi per gli Agent
        my %notPossibleTypeAgentField = %{ $Self->{ConfigObject}->Get( 'NotPossibleTypeAgent' )};

        for my $Key ( keys %notPossibleTypeAgentField ) {
           if( $notPossibleTypeAgentField{$Key} ){
              push( @AllNotPossibleTypeAgent, split(';',$notPossibleTypeAgentField{$Key}) );
           }
        }
    }
	#CR3264
	return if !$Self->{DBObject}->Prepare(
        SQL   => 'SELECT preferences_value FROM user_preferences WHERE user_id = ? AND preferences_key = \'UserTheme\'',
        Bind  => [ \$Param{UserID} ],
        Limit => 1,
    );
    my $currentTheme;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        $currentTheme = $Row[0];
    }
	if( $currentTheme eq 'Corner' ){
		my %NotPossibleForCorner = %{ $Self->{ConfigObject}->Get( 'NotPossibleForCorner' )};
		for my $Key ( keys %NotPossibleForCorner ) {
		   if( $NotPossibleForCorner{$Key} ){
				$Self->{LogObject}->Log( Priority => 'error', Message => "@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Caller CHIAMATO $Key $NotPossibleForCorner{$Key}" );
				push( @AllNotPossibleTypeAgent, split(';',$NotPossibleForCorner{$Key}) );
		   }
		}
	}else{
		my %notPossibleTypeCornerField = %{ $Self->{ConfigObject}->Get( 'NotPossibleTypeCorner' )};
		for my $Key ( keys %notPossibleTypeCornerField ) {
		   if( $notPossibleTypeCornerField{$Key} ){
				push( @AllNotPossibleTypeAgent, split(';',$notPossibleTypeCornerField{$Key}) );
		   }
		}
	}
	
	
		
    #Aggiunta dei tipi NON possibili per gli Agent 
    push @CustomerTypes, @AllNotPossibleTypeAgent;

    #CR1686 - Restrizione sui ticket_type possibili per PI - END

    #CR1686 - Restrizione su coda PosteItaliane-OUT - START
    #Coda PosteItaliane-OUT NON visibile nella Move se ultima Nota non e' di tipo
    #"Nota esterna per PI
    $Self->{DBObject}->Prepare(
       SQL => 'SELECT a.id, a.article_type_id FROM article a, article_type at WHERE '
            . ' a.article_type_id = at.id '
            . ' AND a.ticket_id       = ? and a.note_row_id is null ORDER BY a.id DESC',
        Bind => [ \$Param{TicketID}, ],
    );

    my @Row = $Self->{DBObject}->FetchrowArray();
    
    if ( !$Row[1] || $Row[1] ne '15' && ( $Ticket{Queue} ne 'PosteItaliane-OUT-Alarm' ) )
    {
       my @NotPossibleQueuePI = ();
       push( @NotPossibleQueuePI, 'PosteItaliane-OUT' );
       push( @NotPossibleQueuePI, 'PosteItaliane-OUT-Alarm' );

       push @AllNotPossibleQueues, @NotPossibleQueuePI ; 
    }
    #CR1686 - Restrizione su coda PosteItaliane-OUT - START

		my $currentState = $Ticket{StateID};
		
		#CR1686 - Restrizione sugli stati di risoluzione per Allarmi - START
		my @NotPossibleState = ();
		#$Self->{LogObject}->Log( Priority => 'info', Message => "CURRENT_TICKET_TYPE: $Ticket{Type}" );
		
		my $ticketType = $Ticket{Type};
		my $typePrefix = substr $ticketType, 0, index($ticketType, ' ');
		
		#$Self->{LogObject}->Log( Priority => 'info', Message => "CURRENT_PREFIX_TICKET_TYPE: $typePrefix" );
		
		#CR1686 - Restrizione sugli stati di risoluzione per Allarmi - END
	
        #        $Self->{LogObject}->Log( Priority => 'info', Message => "QUEUE NOT POSSIBLE: @AllNotPossibleQueues" );	
	
		#OPEN -> X
		if ( $currentState eq 4 ){
			    
			    push( @NotPossibleState, ('closed successful', 'closed unsuccessful') );
			    if ( $typePrefix eq 'Alarm' )
          {
              push( @NotPossibleState, ('pending reminder', 'pending auto close-') );
          }
          $Param{Acl}->{FlowStates} = {

            # match properties
            Properties => {

                # current ticket match properties
                Ticket => {
                    TicketID => [ $Param{TicketID} ],
                },
            },

            # return possible options (black list)
            PossibleNot => {
                # possible ticket options (black list)
                Ticket => {
                    State => [@NotPossibleState],
                    Queue => [@AllNotPossibleQueues],
                    Type => [@CustomerTypes], 
                }  
            },

            # return possible options (white list)
            Possible => {
                Ticket => {
                    Queue => ['MVNE-DEV-SAPRMCA','MVNE-DEV-Security'],
                },
                 
                # possible action options
                Action => {
                    AgentTicketLock        => 1,
                    AgentTicketZoom        => 1,
                    AgentTicketClose       => 0,
                    AgentTicketPending     => 1,
                    AgentTicketNote        => 1,
                    AgentTicketHistory     => 1,
                    AgentTicketPriority    => 1,
                    AgentTicketFreeText    => 1,
                    AgentTicketHistory     => 1,
                    AgentTicketCompose     => 1,
                    AgentTicketBounce      => 1,
                    AgentTicketForward     => 1,
                    AgentLinkObject        => 1,
                    AgentTicketPrint       => 1,
                    AgentTicketPhone       => 1,
                    AgentTicketCustomer    => 1,
                    AgentTicketOwner       => 1,
                    AgentTicketResponsible => 1,
                },
            },
        };
    }
    
    #IN PROGRESS
    elsif ( $currentState eq 10 ){
#      $Self->{LogObject}->Log( Priority => 'info', Message => "ACL Called on $Ticket{TicketNumber} with $Ticket{State} - $Ticket{StateType}." ); 
        push( @NotPossibleState, ('closed successful', 'closed unsuccessful') );
			  if ( $typePrefix eq 'Alarm' )
			  {
           push( @NotPossibleState, ('pending reminder', 'pending auto close-') );
			  }  
        $Param{Acl}->{FlowStates} = {

            # match properties
            Properties => {

                # current ticket match properties
                Ticket => {
                    TicketID => [ $Param{TicketID} ],
                },
            },
            # return possible options (black list)
            PossibleNot => {
                # possible ticket options (black list)
                Ticket => {
                    State => [@NotPossibleState],
                    Queue => [@AllNotPossibleQueues],
                    Type => [@CustomerTypes], 
                },
            },

            # return possible options (white list)
            Possible => {

                # possible action options
                Action => {
                    AgentTicketLock        => 1,
                    AgentTicketZoom        => 1,
                    AgentTicketClose       => 0,
                    AgentTicketPending     => 1,
                    AgentTicketNote        => 1,
                    AgentTicketHistory     => 1,
                    AgentTicketPriority    => 1,
                    AgentTicketFreeText    => 1,
                    AgentTicketHistory     => 1,
                    AgentTicketCompose     => 1,
                    AgentTicketBounce      => 1,
                    AgentTicketForward     => 1,
                    AgentLinkObject        => 1,
                    AgentTicketPrint       => 1,
                    AgentTicketPhone       => 1,
                    AgentTicketCustomer    => 1,
                    AgentTicketOwner       => 1,
                    AgentTicketResponsible => 1,
                },
            },
        };
    }
    
    #pending reminder ( 6 - In attesa Informazioni)-> {closed unsuccessful inf}
    elsif ( $currentState eq 6 ){
#      $Self->{LogObject}->Log( Priority => 'info', Message => "ACL Called on $Ticket{TicketNumber} with $Ticket{State} - $Ticket{StateType}." ); 
        push( @NotPossibleState, ('closed successful', 'closed unsuccessful', 'pending auto close+', 'pending auto close-') );
			    
        $Param{Acl}->{FlowStates} = {

            # match properties
            Properties => {

                # current ticket match properties
                Ticket => {
                    TicketID => [ $Param{TicketID} ],
                },
            },

            # return possible options (black list)
            PossibleNot => {
                # possible ticket options (black list)
                Ticket => {
                    State => [@NotPossibleState],
                    Queue => [@AllNotPossibleQueues],
                    Type => [@CustomerTypes], 
                },
            },

            # return possible options (white list)
            Possible => {

                # possible action options
                Action => {
                    AgentTicketLock        => 1,
                    AgentTicketZoom        => 1,
                    AgentTicketClose       => 1,
                    AgentTicketPending     => 0,
                    AgentTicketNote        => 1,
                    AgentTicketHistory     => 1,
                    AgentTicketPriority    => 1,
                    AgentTicketFreeText    => 1,
                    AgentTicketHistory     => 1,
                    AgentTicketCompose     => 1,
                    AgentTicketBounce      => 1,
                    AgentTicketForward     => 1,
                    AgentLinkObject        => 1,
                    AgentTicketPrint       => 1,
                    AgentTicketPhone       => 1,
                    AgentTicketCustomer    => 1,
                    AgentTicketOwner       => 1,
                    AgentTicketResponsible => 1,
                },
            },
        };
    }
    
    #pending auto close- ( 8 - Non di competenza )-> {closed unsuccessful}
    elsif ( $currentState eq 8 ) {
#      $Self->{LogObject}->Log( Priority => 'info', Message => "ACL Called on $Ticket{TicketNumber} with $Ticket{State} - $Ticket{StateType}." ); 

# ****** MS changes for CR3264 - file: FlowStates.pm (inizio) *******************************
		#MS (CR 3264): if necessario per permettere la riapertura di alcuni tipi di ticket 
		if( ($Ticket{Queue} =~ m/^\s*CORNER\s*$/i)  or 
			($Ticket{Queue} =~ m/^\s*CRN-Manutenzione-Studio80\s*$/i)  or 
			($Ticket{Queue} =~ m/^\s*CRN-Manutenzione-Sinergica\s*$/i)  or 
			($Ticket{Queue} =~ m/^\s*CRN-Manutenzione-Iterby\s*$/i) 
		) # ($Ticket{Type} =~ m/^\s*Corner\s*$/i)  or 
		{
			#permetto lo stato 'open', il resto rimane uguale
		    push( @NotPossibleState, ('pending reminder', 'closed successful', 'closed unsuccessful inf', 'pending auto close+') );
		}
		else
		{
        	push( @NotPossibleState, ('open', 'pending reminder', 'closed successful', 'closed unsuccessful inf', 'pending auto close+') );		
		}
# ****** MS changes for CR3264 - file: FlowStates.pm (fine) *******************************
			  
        $Param{Acl}->{FlowStates} = {

            # match properties
            Properties => {

                # current ticket match properties
                Ticket => {
                    TicketID => [ $Param{TicketID} ],
                },
            },

            # return possible options (black list)
            PossibleNot => {
                # possible ticket options (black list)
                Ticket => {
                    State => [@NotPossibleState],
                    Queue => [@AllNotPossibleQueues],
                    Type => [@CustomerTypes], 
                },
            },

            # return possible options (white list)
            Possible => {

                # possible action options
                Action => {
                    AgentTicketLock        => 1,
                    AgentTicketZoom        => 1,
                    AgentTicketClose       => 1,
                    AgentTicketPending     => 0,
                    AgentTicketNote        => 1,
                    AgentTicketHistory     => 1,
                    AgentTicketPriority    => 1,
                    AgentTicketFreeText    => 1,
                    AgentTicketHistory     => 1,
                    AgentTicketCompose     => 1,
                    AgentTicketBounce      => 1,
                    AgentTicketForward     => 1,
                    AgentLinkObject        => 1,
                    AgentTicketPrint       => 1,
                    AgentTicketPhone       => 1,
                    AgentTicketCustomer    => 1,
                    AgentTicketOwner       => 1,
                    AgentTicketResponsible => 1,
                },
            },
        };
    }
    
    
    #pending auto close+  -> {}
    elsif ( $currentState eq 7 ) {
#      $Self->{LogObject}->Log( Priority => 'info', Message => "ACL Called on $Ticket{TicketNumber} with $Ticket{State} - $Ticket{StateType}." ); 

# ****** MS changes for CR3264 - file: FlowStates.pm (inizio) *******************************
		#MS (CR 3264): if necessario per permettere la riapertura di alcuni tipi di ticket 
		if( ($Ticket{Queue} =~ m/^\s*CORNER\s*$/i)  or 
			($Ticket{Queue} =~ m/^\s*CRN-Manutenzione-Studio80\s*$/i)  or 
			($Ticket{Queue} =~ m/^\s*CRN-Manutenzione-Sinergica\s*$/i)  or 
			($Ticket{Queue} =~ m/^\s*CRN-Manutenzione-Iterby\s*$/i) 
		) # ($Ticket{Type} =~ m/^\s*Corner\s*$/i)  or 
		{
			#permetto lo stato 'open', il resto rimane uguale
        	push( @NotPossibleState, ('pending reminder', 'closed unsuccessful', 'closed unsuccessful inf', 'pending auto close-') );
		}
		else
		{
        	push( @NotPossibleState, ('open', 'pending reminder', 'closed unsuccessful', 'closed unsuccessful inf', 'pending auto close-') );
		}
# ****** MS changes for CR3264 - file: FlowStates.pm (fine) *******************************
			  
        $Param{Acl}->{FlowStates} = {

            # match properties
            Properties => {

                # current ticket match properties
                Ticket => {
                    TicketID => [ $Param{TicketID} ],
                },
            },

            # return possible options (black list)
            PossibleNot => {
                # possible ticket options (black list)
                Ticket => {
                    State => [@NotPossibleState],
                    Queue => [@AllNotPossibleQueues],
                    Type => [@CustomerTypes], 
                },
            },

            # return possible options (white list)
            Possible => {

                # possible action options
                Action => {
                    AgentTicketLock        => 1,
                    AgentTicketZoom        => 1,
                    AgentTicketClose       => 1,
                    AgentTicketPending     => 0,
                    AgentTicketNote        => 1,
                    AgentTicketHistory     => 1,
                    AgentTicketPriority    => 1,
                    AgentTicketFreeText    => 1,
                    AgentTicketHistory     => 1,
                    AgentTicketCompose     => 1,
                    AgentTicketBounce      => 1,
                    AgentTicketForward     => 1,
                    AgentLinkObject        => 1,
                    AgentTicketPrint       => 1,
                    AgentTicketPhone       => 1,
                    AgentTicketCustomer    => 1,
                    AgentTicketOwner       => 1,
                    AgentTicketResponsible => 1,
                },
            },
        };
    }
        
    #close+  -> {}
    elsif ( $currentState eq 2 ) {
#      $Self->{LogObject}->Log( Priority => 'info', Message => "ACL Called on $Ticket{TicketNumber} with $Ticket{State} - $Ticket{StateType}." ); 
        push( @NotPossibleState, ('open', 'pending reminder', 'closed unsuccessful', 'closed unsuccessful inf', 'pending auto close-') );
			  
        $Param{Acl}->{FlowStates} = {

            # match properties
            Properties => {

                # current ticket match properties
                Ticket => {
                    TicketID => [ $Param{TicketID} ],
                },
            },

            # return possible options (black list)
            PossibleNot => {
                # possible ticket options (black list)
                Ticket => {
                    State => [@NotPossibleState],
                    Queue => [@AllNotPossibleQueues],
                    Type => [@CustomerTypes], 
                },
            },

            # return possible options (white list)
            Possible => {

                # possible action options
                Action => {
                    AgentTicketLock        => 1,
                    AgentTicketZoom        => 1,
                    AgentTicketClose       => 0,
                    AgentTicketPending     => 0,
                    AgentTicketNote        => 1,
                    AgentTicketHistory     => 1,
                    AgentTicketPriority    => 1,
                    AgentTicketFreeText    => 1,
                    AgentTicketHistory     => 1,
                    AgentTicketCompose     => 1,
                    AgentTicketBounce      => 1,
                    AgentTicketForward     => 1,
                    AgentLinkObject        => 1,
                    AgentTicketPrint       => 1,
                    AgentTicketPhone       => 1,
                    AgentTicketCustomer    => 1,
                    AgentTicketOwner       => 1,
                    AgentTicketResponsible => 1,
                },
            },
        };
    }
    
     #close-  -> {} Riapertura con link Prendi in gestione
    elsif ( $currentState eq 3 || $currentState eq 11) {
#      $Self->{LogObject}->Log( Priority => 'info', Message => "ACL Called on $Ticket{TicketNumber} with $Ticket{State} - $Ticket{StateType}." ); 
        push( @NotPossibleState, ('open', 'pending reminder', 'closed successful', 'pending auto close+') );
			  
        $Param{Acl}->{FlowStates} = {

            # match properties
            Properties => {

                # current ticket match properties
                Ticket => {
                    TicketID => [ $Param{TicketID} ],
                },
            },

            # return possible options (black list)
            PossibleNot => {
                # possible ticket options (black list)
                Ticket => {
                    State => [@NotPossibleState],
                    Queue => [@AllNotPossibleQueues],
                    Type => [@CustomerTypes], 
                },
            },

            # return possible options (white list)
            Possible => {

                # possible action options
                Action => {
                    AgentTicketLock        => 1,
                    AgentTicketZoom        => 1,
                    AgentTicketClose       => 0,
                    AgentTicketPending     => 0,
                    AgentTicketNote        => 1,
                    AgentTicketHistory     => 1,
                    AgentTicketPriority    => 1,
                    AgentTicketFreeText    => 1,
                    AgentTicketHistory     => 1,
                    AgentTicketCompose     => 1,
                    AgentTicketBounce      => 1,
                    AgentTicketForward     => 1,
                    AgentLinkObject        => 1,
                    AgentTicketPrint       => 1,
                    AgentTicketPhone       => 1,
                    AgentTicketCustomer    => 1,
                    AgentTicketOwner       => 1,
                    AgentTicketResponsible => 1,
                },
            },
        };
    } else {
        $Param{Acl}->{FlowStates} = {

            # match properties
            Properties => {
                # current ticket match properties
            },

            # return possible options (black list)
            PossibleNot => {
                # possible ticket options (black list)
                Ticket => {
                    Type => [@CustomerTypes],
                },
            },

            # return possible options (white list)
            Possible => {
                # possible action options
            },
        }; 

     }	

    
    return 1;
}

1;

package MSResponseFromWindUtil;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

# Exporting the saluta routine
our @EXPORT = qw(MS_ResponseToResponseHash MS_CheckResponseFromWind);
# Exporting the saluta2 routine on demand basis.
#our @EXPORT_OK = qw(saluta2);




# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/../cpan-lib";





# ----------------- Attiva/disattiva debug per sviluppo ------------------
my $MS_DEBUG = 1; # 0 -> disattivato, 1 -> attivato




# ----------------- Moduli custom necessari ------------------
#use MSXMLUtil;
#use MSTicketUtil;
# ----------------- Moduli custom necessari (fine) ------------------


# Struttura XML attesa:
#
#<?xml version="1.0" encoding="UTF-8"?>                       	  
#<OTRS_API>
#<TicketResponse>
#
#<Header>
#	<SourceChannel>xxxx</SourceChannel>
#	<DestinationChannel>xxxx</DestinationChannel>
#	<TimeStamp>xxxx</TimeStamp>
#	<TransactionId>xxxx</TransactionId>
#	<BusinessId>xxxx</BusinessId>
#</Header>
#
#<ResultStatus>
#	<StatusCode>xxxx</StatusCode>
#	<ErrorMessage>xxxx</ErrorMessage>
#	<ErrorDescription>xxxx</ErrorDescription>
#</ResultStatus>
#
#</TicketResponse>
#</OTRS_API>





sub MS_ResponseToResponseHash
{
	my $TicketHash_ptr = shift;
	my $XMLHash_ptr = shift;

	
	#if ($MS_DEBUG)
	#{
	#	use Data::Dumper;
	#	print "\n".Dumper($XMLHash_ptr)."\n";
	#}
	
	
	my $rootTag = $XMLHash_ptr->[0]->{OTRS_API}[1]->{TicketResponse}[1];
	my $rootTagHeader = $rootTag->{Header}[1];
	my $rootTagBody = $rootTag->{ResultStatus}[1];
	
	my $ResponseHash_prt = $TicketHash_ptr->{ResponseHash};
	$ResponseHash_prt->{Header} = {};
	$ResponseHash_prt->{ResultStatus} = {};
	my $header = $ResponseHash_prt->{Header};
	my $body = $ResponseHash_prt->{ResultStatus};
	
	
	foreach my $key (keys(%{$rootTagHeader}))
	{	
		$header->{$key} = $rootTagHeader->{$key}[1]->{Content} if(exists($rootTagHeader->{$key}) and ref($rootTagHeader->{$key}) eq 'ARRAY' and exists($rootTagHeader->{$key}[1]->{Content}));
	}
	
	foreach my $key (keys(%{$rootTagBody}))
	{	
		$body->{$key} = $rootTagBody->{$key}[1]->{Content} if(exists($rootTagBody->{$key}) and ref($rootTagBody->{$key}) eq 'ARRAY' and exists($rootTagBody->{$key}[1]->{Content}));
	}
}





sub MS_CheckResponseFromWind
{
	my $TicketHash_ptr = shift;
	my $RequestType = shift; #CREATE, UPDATE, NOTIFY
	
	my $rit = 0;
	
	my $ResponseHash_ptr = $TicketHash_ptr->{ResponseHash};
	
	if (defined($TicketHash_ptr) and exists($ResponseHash_ptr->{Header}) and exists($ResponseHash_ptr->{ResultStatus}) )
	{
		my $TransactionId = $TicketHash_ptr->{RequestHash}->{HEADER}->{TransactionId};
	
			#debug
			print "\nYYY1\n" if($MS_DEBUG);		
		
		if ($MS_DEBUG or ( exists($ResponseHash_ptr->{Header}->{TransactionId}) and ($TransactionId eq $ResponseHash_ptr->{Header}->{TransactionId})  ) ) #quando sono in debug ignoro il transactionID
		{
			
			#debug
			print "\nYYY2\n" if($MS_DEBUG);			
			
			if (exists($ResponseHash_ptr->{ResultStatus}->{StatusCode}) )
			{
				if ($ResponseHash_ptr->{ResultStatus}->{StatusCode} == 0 )
				{
					if ($RequestType =~ m/^CREATE$/i)
					{
						if(exists($ResponseHash_ptr->{ResultStatus}->{TicketID}) )
						{
							$ResponseHash_ptr->{ResponseErrorCode} = 0;
							$ResponseHash_ptr->{ResponseErrorMessage} = '';
							$rit = 1;
						}
						else
						{
							$ResponseHash_ptr->{ResponseErrorCode} = 6; 
							$ResponseHash_ptr->{ResponseErrorMessage} = 'Response ad una request di CREATE priva del campo TicketID.';
						}
						
					}
					elsif($RequestType =~ m/^UPDATE$/i)
					{
						if(exists($ResponseHash_ptr->{ResultStatus}->{Status}) )
						{
							$ResponseHash_ptr->{ResponseErrorCode} = 0;
							$ResponseHash_ptr->{ResponseErrorMessage} = '';
							$rit = 1; #tutto ok
						}
						else
						{
							$ResponseHash_ptr->{ResponseErrorCode} = 5; 
							$ResponseHash_ptr->{ResponseErrorMessage} = 'Response ad una request di UPDATE priva del campo Status.';
						}
					}
					else #notify
					{
						$ResponseHash_ptr->{ResponseErrorCode} = 0;
						$ResponseHash_ptr->{ResponseErrorMessage} = '';
						$rit = 1; #tutto ok
					}
				}
				else
				{
					if(exists($ResponseHash_ptr->{ResultStatus}->{ErrorMessage})  and exists($ResponseHash_ptr->{ResultStatus}->{ErrorDescription}) )
					{
						$ResponseHash_ptr->{ResponseErrorCode} = $ResponseHash_ptr->{ResultStatus}->{ErrorMessage}; 
						$ResponseHash_ptr->{ResponseErrorMessage} = $ResponseHash_ptr->{ResultStatus}->{ErrorDescription};
					}
					else
					{
						$ResponseHash_ptr->{ResponseErrorCode} = 4; 
						$ResponseHash_ptr->{ResponseErrorMessage} = 'Response da Wind segnala errore ma manca dettaglio (ErrorMessage e ErrorDescription)';
					}
				}
			}
			else
			{
				$ResponseHash_ptr->{ResponseErrorCode} = 3; 
				$ResponseHash_ptr->{ResponseErrorMessage} = 'StatusCode assente nella Response!';
			}
			
		}
		else
		{
			$ResponseHash_ptr->{ResponseErrorCode} = 2; 
			$ResponseHash_ptr->{ResponseErrorMessage} = 'TransactionId della Response da EAI/Wind diverso da quello della Request';
		}
		
	}
	
	return $rit;
}











1;

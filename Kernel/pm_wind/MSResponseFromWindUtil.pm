package MSResponseFromWindUtil;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

# Exporting the saluta routine
our @EXPORT = qw(XXXXXXXXXX);
# Exporting the saluta2 routine on demand basis.
#our @EXPORT_OK = qw(saluta2);




# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/../cpan-lib";




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
		$header->{$key} = $rootTagHeader->{$key}[1]->{Content} if(exists($rootTagHeader->{$key}[1]->{Content}));
	}
	
	foreach my $key (keys(%{$rootTagBody}))
	{	
		$body->{$key} = $rootTagBody->{$key}[1]->{Content} if(exists($rootTagBody->{$key}[1]->{Content}));
	}
}



sub MS_CheckResponseFromWind
{
	
}











1;

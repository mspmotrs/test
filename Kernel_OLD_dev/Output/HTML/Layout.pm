# --
# Kernel/Output/HTML/Layout.pm - provides generic HTML output
# Copyright (C) 2001-2010 OTRS AG, http://otrs.org/
# --
# $Id: Layout.pm,v 1.176.2.17 2010/02/03 09:31:53 mb Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Layout;

use lib '../../';

use strict;
use warnings;

use Kernel::Language;
use Kernel::System::HTMLUtils;

use vars qw(@ISA $VERSION);
$VERSION = qw($Revision: 1.176.2.17 $) [1];

=head1 NAME

Kernel::Output::HTML::Layout - all generic html functions

=head1 SYNOPSIS

All generic html finctions. E. g. to get options fields, template processing, ...

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create a new object

    use Kernel::Config;
    use Kernel::System::Encode;
    use Kernel::System::Log;
    use Kernel::System::Time;
    use Kernel::System::Main;
    use Kernel::System::Web::Request;
    use Kernel::Output::HTML::Layout;

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
    my $TimeObject = Kernel::System::Time->new(
        ConfigObject => $ConfigObject,
        LogObject    => $LogObject,
    );
    my $RequestObject = Kernel::System::Web::Request->new(
        ConfigObject => $ConfigObject,
        LogObject    => $LogObject,
        EncodeObject => $EncodeObject,
        MainObject   => $MainObject,
    );
    my $LayoutObject = Kernel::Output::HTML::Layout->new(
        ConfigObject  => $ConfigObject,
        LogObject     => $LogObject,
        MainObject    => $MainObject,
        TimeObject    => $TimeObject,
        RequestObject => $RequestObject,
        EncodeObject  => $EncodeObject,
        Lang          => 'de',
    );

    in addition for NavigationBar() you need
        DBObject
        SessionObject
        UserID
        TicketObject
        GroupObject

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # set debug
    $Self->{Debug} = 0;

    # check needed objects
    # Attention the SessionObject is needet for NavigationBar()
    for (qw(ConfigObject LogObject TimeObject MainObject EncodeObject ParamObject)) {
        if ( !$Self->{$_} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Got no $_!",
            );
            $Self->FatalError();
        }
    }

    $Self->{HTMLUtilsObject} = Kernel::System::HTMLUtils->new( %{$Self} );

    # reset block data
    delete $Self->{BlockData};

    # get/set some common params
    if ( !$Self->{UserTheme} ) {
        $Self->{UserTheme} = $Self->{ConfigObject}->Get('DefaultTheme');
    }
    if ( $Self->{ConfigObject}->Get('TimeZoneUser') && $Self->{UserTimeZone} ) {
        $Self->{UserTimeObject} = Kernel::System::Time->new(%Param);
    }
    else {
        $Self->{UserTimeObject} = $Self->{TimeObject};
        $Self->{UserTimeZone}   = '';
    }

    # get use language (from browser) if no language is there!
    if ( !$Self->{UserLanguage} ) {
        my $BrowserLang = $Self->{Lang} || $ENV{HTTP_ACCEPT_LANGUAGE} || '';
        my %Data = %{ $Self->{ConfigObject}->Get('DefaultUsedLanguages') };
        LANGUAGE:
        for my $Language ( reverse sort keys %Data ) {

            # check xx_XX and xx-XX type
            my $LanguageOtherType = $Language;
            $LanguageOtherType =~ s/_/-/;
            if ( $BrowserLang =~ /^($Language|$LanguageOtherType)/i ) {
                $Self->{UserLanguage} = $Language;
                last LANGUAGE;
            }
        }
        $Self->{UserLanguage} ||= $Self->{ConfigObject}->Get('DefaultLanguage') || 'en';
    }

    # create language object
    if ( !$Self->{LanguageObject} ) {
        $Self->{LanguageObject} = Kernel::Language->new(
            UserTimeZone => $Self->{UserTimeZone},
            UserLanguage => $Self->{UserLanguage},
            LogObject    => $Self->{LogObject},
            ConfigObject => $Self->{ConfigObject},
            EncodeObject => $Self->{EncodeObject},
            MainObject   => $Self->{MainObject},
            Action       => $Self->{Action},
        );
    }

    # set charset if there is no charset given
    $Self->{UserCharset} = $Self->{LanguageObject}->GetRecommendedCharset();
    $Self->{Charset}     = $Self->{UserCharset};                               # just for compat.
    $Self->{SessionID}   = $Param{SessionID} || '';
    $Self->{SessionName} = $Param{SessionName} || 'SessionID';
    $Self->{CGIHandle}   = $ENV{SCRIPT_NAME} || 'No-$ENV{"SCRIPT_NAME"}';

    # baselink
    $Self->{Baselink} = $Self->{CGIHandle} . '?';
    $Self->{Time}     = $Self->{LanguageObject}->Time(
        Action => 'GET',
        Format => 'DateFormat',
    );
    $Self->{TimeLong} = $Self->{LanguageObject}->Time(
        Action => 'GET',
        Format => 'DateFormatLong',
    );

    # set text direction
    $Self->{TextDirection} = $Self->{LanguageObject}->{TextDirection};

    # check Frontend::Output::FilterElementPre
    $Self->{FilterElementPre} = $Self->{ConfigObject}->Get('Frontend::Output::FilterElementPre');

    # check Frontend::Output::FilterElementPost
    $Self->{FilterElementPost} = $Self->{ConfigObject}->Get('Frontend::Output::FilterElementPost');

    # check Frontend::Output::FilterContent
    $Self->{FilterContent} = $Self->{ConfigObject}->Get('Frontend::Output::FilterContent');

    # check Frontend::Output::FilterText
    $Self->{FilterText} = $Self->{ConfigObject}->Get('Frontend::Output::FilterText');

    # check browser (defaut is IE because I don't have IE)
    $Self->{BrowserWrap} = 'physical';
    $Self->{Browser}     = 'Unknown';

    $Self->{BrowserJavaScriptSupport} = 1;
    $Self->{BrowserRichText}          = 1;

    my $HttpUserAgent = lc $ENV{HTTP_USER_AGENT};
    if ( !$HttpUserAgent ) {
        $Self->{Browser} = 'Unknown - no $ENV{"HTTP_USER_AGENT"}';
    }
    elsif ($HttpUserAgent) {

        # msie
        if (
            $HttpUserAgent =~ /msie\s([0-9.]+)/
            || $HttpUserAgent =~ /internet\sexplorer\/([0-9.]+)/
            )
        {
            $Self->{Browser}     = 'MSIE';
            $Self->{BrowserWrap} = 'physical';

            # For IE 5.5, we break the header in a special way that makes
            # things work. I don't really want to know.
            if ( $1 =~ /(\d)\.(\d)/ ) {
                $Self->{BrowserMajorVersion} = $1;
                $Self->{BrowserMinorVersion} = $2;
                if (
                    $1 == 5
                    && $2 == 5
                    || $1 == 6 && $2 == 0
                    || $1 == 7 && $2 == 0
                    || $1 == 8 && $2 == 0
                    )
                {
                    $Self->{BrowserBreakDispositionHeader} = 1;
                }
            }
        }

        # safari
        elsif ( $HttpUserAgent =~ /safari/ ) {
            $Self->{Browser}     = 'Safari';
            $Self->{BrowserWrap} = 'hard';

            # on iphone disable rich text editor
            if ( $HttpUserAgent =~ /iphone\sos/ ) {
                $Self->{BrowserRichText} = 0;
            }

            # on android disable rich text editor
            elsif ( $HttpUserAgent =~ /android/ ) {
                $Self->{BrowserRichText} = 0;
            }
        }

        # konqueror
        elsif ( $HttpUserAgent =~ /konqueror/ ) {
            $Self->{Browser}     = 'Konqueror';
            $Self->{BrowserWrap} = 'hard';

            # on konquerer disable rich text editor
            $Self->{BrowserRichText} = 0;
        }

        # mozilla
        elsif ( $HttpUserAgent =~ /^mozilla/ ) {
            $Self->{Browser}     = 'Mozilla';
            $Self->{BrowserWrap} = 'hard';
        }

        # opera
        elsif ( $HttpUserAgent =~ /^opera.*/ ) {
            $Self->{Browser}     = 'Opera';
            $Self->{BrowserWrap} = 'hard';
        }

        # netscape
        elsif ( $HttpUserAgent =~ /netscape/ ) {
            $Self->{Browser}     = 'Netscape';
            $Self->{BrowserWrap} = 'hard';
        }

        # w3m
        elsif ( $HttpUserAgent =~ /^w3m.*/ ) {
            $Self->{Browser}                  = 'w3m';
            $Self->{BrowserJavaScriptSupport} = 0;
        }

        # lynx
        elsif ( $HttpUserAgent =~ /^lynx.*/ ) {
            $Self->{Browser}                  = 'Lynx';
            $Self->{BrowserJavaScriptSupport} = 0;
        }

        # links
        elsif ( $HttpUserAgent =~ /^links.*/ ) {
            $Self->{Browser} = 'Links';
        }
        else {
            $Self->{Browser} = 'Unknown - ' . $HttpUserAgent;
        }
    }

    # check if rich text can be active
    if ( !$Self->{BrowserJavaScriptSupport} || !$Self->{BrowserRichText} ) {
        $Self->{ConfigObject}->Set(
            Key   => 'Frontend::RichText',
            Value => 0,
        );
    }

    # check if rich text is active
    if ( !$Self->{ConfigObject}->Get('Frontend::RichText') ) {
        $Self->{BrowserRichText} = 0;
    }

    # check if spell check should be active
    if ( $Self->{BrowserJavaScriptSupport} && $Self->{ConfigObject}->Get('SpellChecker') ) {
        if ( $Self->{ConfigObject}->Get('Frontend::RichText') ) {
            $Self->{BrowserSpellCheckerInline} = 1;
        }
        else {
            $Self->{BrowserSpellChecker} = 1;
        }
    }

    # load theme
    my $Theme = $Self->{UserTheme} || $Self->{ConfigObject}->Get('DefaultTheme') || 'Standard';

    # force a theme based on host name
    my $DefaultThemeHostBased = $Self->{ConfigObject}->Get('DefaultTheme::HostBased');
    if ( $DefaultThemeHostBased && $ENV{HTTP_HOST} ) {
        for my $RegExp ( sort keys %{$DefaultThemeHostBased} ) {

            # do not use empty regexp or theme directories
            next if !$RegExp;
            next if $RegExp eq '';
            next if !$DefaultThemeHostBased->{$RegExp};

            # check if regexp is matching
            if ( $ENV{HTTP_HOST} =~ /$RegExp/i ) {
                $Theme = $DefaultThemeHostBased->{$RegExp};
            }
        }
    }

    # locate template files
    $Self->{TemplateDir} = $Self->{ConfigObject}->Get('TemplateDir') . '/HTML/' . $Theme;
    if ( !-e $Self->{TemplateDir} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message =>
                "No existing template directory found ('$Self->{TemplateDir}')! Check your Home in Kernel/Config.pm",
        );
        $Self->FatalDie();
    }

# FRAMEWORK-2.5: define $Env{"Images"} (only for compat till 2.5, use $Config{"Frontend::ImagePath"})
    $Self->{Images} = $Self->{ConfigObject}->Get('Frontend::ImagePath');

    # load sub layout files
    my $Dir = $Self->{ConfigObject}->Get('TemplateDir') . '/HTML/';
    if ( -e $Dir ) {
        my @Files = glob("$Dir/Layout*.pm");
        for my $File (@Files) {
            if ( $File !~ /Layout.pm$/ ) {
                $File =~ s/^.*\/(.+?).pm$/$1/g;
                if ( !$Self->{MainObject}->Require("Kernel::Output::HTML::$File") ) {
                    $Self->FatalError();
                }
                push @ISA, "Kernel::Output::HTML::$File";
            }
        }
    }

    return $Self;
}

sub SetEnv {
    my ( $Self, %Param ) = @_;

    for (qw(Key Value)) {
        if ( !defined $Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            $Self->FatalError();
        }
    }
    $Self->{EnvNewRef}->{ $Param{Key} } = $Param{Value};
    return 1;
}

=item Block()

use a dtl block

    $LayoutObject->Block(
        Name => 'Row',
        Data => {
            Time     => $Row[0],
            Priority => $Row[1],
            Facility => $Row[2],
            Message  => $Row[3],
        },
    );

=cut

sub Block {
    my ( $Self, %Param ) = @_;

    if ( !$Param{Name} ) {
        $Self->{LogObject}->Log( Priority => 'error', Message => 'Need Name!' );
        return;
    }
    push @{ $Self->{BlockData} }, { Name => $Param{Name}, Data => $Param{Data} };
}

sub _BlockTemplatePreferences {
    my ( $Self, %Param ) = @_;

    my %TagsOpen       = ();
    my @Preferences    = ();
    my $LastLayerCount = 0;
    my $Layer          = 0;
    my $LastLayer      = '';
    my $CurrentLayer   = '';
    my %UsedNames      = ();
    my $TemplateFile   = $Param{TemplateFile} || '';
    if ( !defined $Param{Template} ) {
        $Self->{LogObject}->Log( Priority => 'error', Message => 'Need Template!' );
        return;
    }

    if ( $Self->{PrasedBlockTemplatePreferences}->{$TemplateFile} ) {
        return $Self->{PrasedBlockTemplatePreferences}->{$TemplateFile};
    }

    $Param{Template} =~ s{
        <!--\s{0,1}dtl:block:(.+?)\s{0,1}-->
    }
    {
        my $BlockName = $1;
        if (!$TagsOpen{$BlockName}) {
            $Layer++;
            $TagsOpen{$BlockName} = 1;
            my $CL = '';
            if ($Layer == 1) {
                $LastLayer = '';
                $CurrentLayer = $BlockName;
            }
            elsif ($LastLayerCount == $Layer) {
                $CurrentLayer = $LastLayer.'::'.$BlockName;
            }
            else {
                $LastLayer = $CurrentLayer;
                $CurrentLayer = $CurrentLayer.'::'.$BlockName;
            }
            $LastLayerCount = $Layer;
            if (!$UsedNames{$BlockName}) {
                push (@Preferences, {
                    Name => $BlockName,
                    Layer => $Layer,
                    },
                );
                $UsedNames{$BlockName} = 1;
            }
        }
        else {
            $TagsOpen{$BlockName} = 0;
            $Layer--;
        }
    }segxm;

    # check open (invalid) tags
    for ( keys %TagsOpen ) {
        if ( $TagsOpen{$_} ) {
            my $Message = "'dtl:block:$_' isn't closed!";
            if ($TemplateFile) {
                $Message .= " ($TemplateFile.dtl)";
            }
            $Self->{LogObject}->Log( Priority => 'error', Message => $Message );
            $Self->FatalError();
        }
    }

    # remember block data
    if ($TemplateFile) {
        $Self->{PrasedBlockTemplatePreferences}->{$TemplateFile} = \@Preferences;
    }

    return \@Preferences;
}

sub _BlockTemplatesReplace {
    my ( $Self, %Param ) = @_;

    my %BlockLayer     = ();
    my %BlockTemplates = ();
    my @BR             = ();
    if ( !$Param{Template} ) {
        $Self->{LogObject}->Log( Priority => 'error', Message => 'Need Template!' );
        return;
    }
    my $TemplateString = $Param{Template};

    # get availabe template block preferences
    my $BlocksRef = $Self->_BlockTemplatePreferences(
        Template => $$TemplateString,
        TemplateFile => $Param{TemplateFile} || '',
    );
    for my $Block ( reverse @{$BlocksRef} ) {
        $$TemplateString =~ s{
            <!--\s{0,1}dtl:block:$Block->{Name}\s{0,1}-->(.+?)<!--\s{0,1}dtl:block:$Block->{Name}\s{0,1}-->
        }
        {
            $BlockTemplates{$Block->{Name}} = $1;
            "<!-- dtl:place_block:$Block->{Name} -->";
        }segxm;
        $BlockLayer{ $Block->{Name} } = $Block->{Layer};
    }

    # create block template string
    if ( $Self->{BlockData} && %BlockTemplates ) {
        my @NotUsedBlockData = ();
        for my $Block ( @{ $Self->{BlockData} } ) {
            if ( $BlockTemplates{ $Block->{Name} } ) {
                push(
                    @BR,
                    {
                        Layer => $BlockLayer{ $Block->{Name} },
                        Name  => $Block->{Name},
                        Data  => $Self->_Output(
                            Template => "\n<!--start $Block->{Name}-->"
                                . $BlockTemplates{ $Block->{Name} }
                                . "<!--stop $Block->{Name} -->",
                            Data => $Block->{Data},
                        ),
                    }
                );
            }
            else {
                push @NotUsedBlockData, { %{$Block} };
            }
        }

        # remember not use block data
        $Self->{BlockData} = \@NotUsedBlockData;
    }
    return @BR;
}

=item Output()

use a dtl template and get html back

using a template file

    my $HTML = $LayoutObject->Output(
        TemplateFile => 'AdminLog',
        Data         => \%Param,
    );

using a template string

    my $HTML = $LayoutObject->Output(
        Template => '<b>$QData{"SomeKey"}</b>',
        Data     => \%Param,
    );

=cut

sub Output {
    my ( $Self, %Param ) = @_;

    # get and check param Data
    if ( $Param{Data} ) {
        if ( ref $Param{Data} ne 'HASH' ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need HashRef in Param Data! Got: '" . ref( $Param{Data} ) . "'!",
            );
            $Self->FatalError();
        }
    }
    else {
        $Param{Data} = {};
    }

    # fill init Env
    if ( !$Self->{EnvRef} ) {
        %{ $Self->{EnvRef} } = %ENV;

        # all $Self->{*}
        for ( keys %{$Self} ) {
            if ( defined $Self->{$_} && !ref $Self->{$_} ) {
                $Self->{EnvRef}->{$_} = $Self->{$_};
            }
        }
    }

    # add new env
    if ( $Self->{EnvNewRef} ) {
        for ( %{ $Self->{EnvNewRef} } ) {
            $Self->{EnvRef}->{$_} = $Self->{EnvNewRef}->{$_};
        }
        undef $Self->{EnvNewRef};
    }

    # read template from filesystem
    my $TemplateString = '';
    if ( $Param{TemplateFile} ) {
        my $File = '';
        if ( -f "$Self->{TemplateDir}/$Param{TemplateFile}.dtl" ) {
            $File = "$Self->{TemplateDir}/$Param{TemplateFile}.dtl";
        }
        else {
            $File = "$Self->{TemplateDir}/../Standard/$Param{TemplateFile}.dtl";
        }
        if ( open my $TEMPLATEIN, '<', $File ) {
            $TemplateString = do { local $/; <$TEMPLATEIN> };
            close $TEMPLATEIN;
        }
        else {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Can't read $File: $!",
            );
        }
    }

    # take templates from string/array
    elsif ( defined $Param{Template} && ref $Param{Template} eq 'ARRAY' ) {
        for ( @{ $Param{Template} } ) {
            $TemplateString .= $_;
        }
    }
    elsif ( defined $Param{Template} ) {
        $TemplateString = $Param{Template};
    }
    else {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need Template or TemplateFile Param!',
        );
        $Self->FatalError();
    }

    # custom pre filters
    if ( $Self->{FilterElementPre} ) {
        my %Filters = %{ $Self->{FilterElementPre} };
        for my $Filter ( sort keys %Filters ) {
            next if !$Self->{MainObject}->Require( $Filters{$Filter}->{Module} );
            my $Object = $Filters{$Filter}->{Module}->new(
                ConfigObject => $Self->{ConfigObject},
                LogObject    => $Self->{LogObject},
                MainObject   => $Self->{MainObject},
                ParamObject  => $Self->{ParamObject},
                LayoutObject => $Self,
                Debug        => $Self->{Debug},
            );

            # run module
            $Object->Run(
                %{ $Filters{$Filter} },
                Data => \$TemplateString,
                TemplateFile => $Param{TemplateFile} || '',
            );
        }
    }

    # filtering of comment lines
    $TemplateString =~ s/^#.*\n//gm;

    my $Output = $Self->_Output(
        Template     => $TemplateString,
        Data         => $Param{Data},
        BlockReplace => 1,
        TemplateFile => $Param{TemplateFile} || '',
    );

    # do time translation (with seconds)
    $Output =~ s{
        \$TimeLong{"(.*?)"}
    }
    {
        $Self->{LanguageObject}->FormatTimeString($1);
    }egx;

    # do time translation (without seconds)
    $Output =~ s{
        \$TimeShort{"(.*?)"}
    }
    {
        $Self->{LanguageObject}->FormatTimeString($1, undef, 'NoSeconds');
    }egx;

    # do date translation
    $Output =~ s{
        \$Date{"(.*?)"}
    }
    {
        $Self->{LanguageObject}->FormatTimeString($1, 'DateFormatShort');
    }egx;

    # do translation
    $Output =~ s{
        \$Text{"(.*?)"}
    }
    {
        $Self->Ascii2Html(
            Text => $Self->{LanguageObject}->Get($1),
        );
    }egx;

    $Output =~ s{
        \$JSText{"(.*?)"}
    }
    {
        $Self->Ascii2Html(
            Text => $Self->{LanguageObject}->Get($1),
            Type => 'JSText',
        );
    }egx;

    # do html quote
    $Output =~ s{
        \$Quote{"(.*?)"}
    }
    {
        my $Text = $1;
        if ( !defined $Text || $Text =~ /^",\s*"(.+)$/ ) {
            '';
        }
        elsif ($Text =~ /^(.+?)",\s*"(.+)$/) {
            $Self->Ascii2Html(Text => $1, Max => $2);
        }
        else {
            $Self->Ascii2Html(Text => $Text);
        }
    }egx;

    # rewrite forms, add challenge token : <form action="index.pl" method="get">
    if ( $Self->{SessionID} && $Self->{UserChallengeToken} ) {
        my $UserChallengeToken = $Self->Ascii2Html( Text => $Self->{UserChallengeToken} );
        $Output =~ s{
            (<form.+?action=".*?".*?>)
        }
        {
            my $Form = $1;
            if ( lc $Form =~ m{^http s? :}smx ) {
                $Form;
            }
            else {
                $Form . "<input type=\"hidden\" name=\"ChallengeToken\" value=\"$UserChallengeToken\"/>";
            }
        }iegx;
    }

    # Check if the browser sends the session id cookie!
    # If not, add the session id to the links and forms!
    if ( $Self->{SessionID} && !$Self->{SessionIDCookie} ) {

        # rewrite a hrefs
        $Output =~ s{
            (<a.+?href=")(.+?)(\#.+?|)(".*?>)
        }
        {
            my $AHref   = $1;
            my $Target  = $2;
            my $End     = $3;
            my $RealEnd = $4;
            if ( lc $Target =~ /^(http:|https:|#|ftp:)/ ||
                $Target !~ /\.(pl|php|cgi|fcg|fcgi|fpl)(\?|$)/ ||
                $Target =~ /(\?|&)\Q$Self->{SessionName}\E=/) {
                $AHref.$Target.$End.$RealEnd;
            }
            else {
                $AHref.$Target.'&'.$Self->{SessionName}.'='.$Self->{SessionID}.$End.$RealEnd;
            }
        }iegxs;

        # rewrite img and iframe src
        $Output =~ s{
            (<(?:img|iframe).+?src=")(.+?)(".*?>)
        }
        {
            my $AHref = $1;
            my $Target = $2;
            my $End = $3;
            if (lc $Target =~ m{^http s? :}smx || !$Self->{SessionID} ||
                $Target !~ /\.(pl|php|cgi|fcg|fcgi|fpl)(\?|$)/ ||
                $Target =~ /\Q$Self->{SessionName}\E/) {
                $AHref.$Target.$End;
            }
            else {
                $AHref.$Target.'&'.$Self->{SessionName}.'='.$Self->{SessionID}.$End;
            }
        }iegxs;

        # rewrite forms: <form action="index.pl" method="get">
        my $SessionID = $Self->Ascii2Html( Text => $Self->{SessionID} );
        $Output =~ s{
            (<form.+?action=".*?".*?>)
        }
        {
            my $Form = $1;
            if ( lc $Form =~ m{^http s? :}smx ) {
                $Form;
            }
            else {
                $Form . "<input type=\"hidden\" name=\"$Self->{SessionName}\" value=\"$SessionID\"/>";
            }
        }iegx;
    }

    # do correct direction
    if ( $Self->{TextDirection} && $Self->{TextDirection} eq 'rtl' ) {
        $Output =~ s{
            <(table.+?)>
        }
        {
            my $Table = $1;
            if ($Table !~ /dir=/) {
                "<$Table dir=\"".$Self->{TextDirection}."\">";
            }
            else {
                "<$Table>";
            }
        }iegx;
        $Output =~ s{
            align="(left|right)"
        }
        {
            if ($1 =~ /left/i) {
                "align=\"right\"";
            }
            else {
                "align=\"left\"";
            }
        }iegx;
    }

    # custom post filters
    if ( $Self->{FilterElementPost} ) {
        my %Filters = %{ $Self->{FilterElementPost} };
        for my $Filter ( sort keys %Filters ) {
            next if !$Self->{MainObject}->Require( $Filters{$Filter}->{Module} );
            my $Object = $Filters{$Filter}->{Module}->new(
                ConfigObject => $Self->{ConfigObject},
                LogObject    => $Self->{LogObject},
                MainObject   => $Self->{MainObject},
                ParamObject  => $Self->{ParamObject},
                LayoutObject => $Self,
                Debug        => $Self->{Debug},
            );

            # run module
            $Object->Run(
                %{ $Filters{$Filter} },
                Data => \$Output,
                TemplateFile => $Param{TemplateFile} || '',
            );
        }
    }

    return $Output;
}

sub _Output {
    my ( $Self, %Param ) = @_;

    # deep recursion protection
    $Self->{OutputCount}++;
    if ( $Self->{OutputCount} > 20 ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Loop detection!',
        );
        $Self->FatalDie();
    }

    # create refs
    my $GlobalRef = {
        Env    => $Self->{EnvRef},
        Data   => $Param{Data},
        Config => $Self->{ConfigObject},
    };

    my $TemplateString = $Param{Template};

    # parse/get text blocks
    my @BR = $Self->_BlockTemplatesReplace(
        Template => \$TemplateString,
        TemplateFile => $Param{TemplateFile} || '',
    );
    my $ID        = 0;
    my %LayerHash = ();
    my $OldLayer  = 1;
    for my $Block (@BR) {

        # reset layer counter if we switched on layer lower
        if ( $Block->{Layer} > $OldLayer ) {
            $LayerHash{ $Block->{Layer} } = 0;
        }

        # count current layer
        $LayerHash{ $Block->{Layer} }++;

        # create current id (1:2:3)
        undef $ID;
        for ( my $i = 1; $i <= $Block->{Layer}; $i++ ) {
            if ( defined $ID ) {
                $ID .= ':';
            }
            if ( defined $LayerHash{$i} ) {
                $ID .= $LayerHash{$i};
            }
        }

        # add block counter to template blocks
        if ( $Block->{Layer} == 1 ) {
            $TemplateString =~ s{
                ( <!--\s{0,1}dtl:place_block:$Block->{Name})(\s{0,1}-->)
            }
            {
                "$1:".$LayerHash{$Block->{Layer}}.$2;
            }segxm;
        }

        # add block counter to in block blocks
        $Block->{Data} =~ s{
            (<!--\s{0,1}dtl:place_block:.+?)(\s{0,1}-->)
        }
        {
            "$1:$ID:-$2";
        }segxm;

        # count up place_block counter
        $ID =~ s/^(.*:)(\d+)$/$1-/g;

        my $NewID = '';
        if ( $ID =~ /^(.*:)(\d+)$/ ) {
            $NewID = $1 . ( $2 + 1 );
        }
        elsif ( $ID =~ /^(\d+)$/ ) {
            $NewID = ( $1 + 1 );
        }
        elsif ( $ID =~ /^(.*:)-$/ ) {
            $NewID = $ID;
        }

        $TemplateString =~ s{
            <!--\sdtl:place_block:$Block->{Name}:$ID\s-->
        }
        {$Block->{Data}<!-- dtl:place_block:$Block->{Name}:$NewID -->}sxm;
        $OldLayer = $Block->{Layer};
    }

    # remove empty blocks and block preferences
    if ( $Param{BlockReplace} ) {
        $TemplateString =~ s{ <!--\s{0,1}dtl:place_block:.+?\s{0,1}--> }{}sgxm;
    }

    # process template
    my $Output = '';
    for my $Line ( split( /\n/, $TemplateString ) ) {

        #        # add missing new line (striped from split)
        #        $Line .= "\n";
        if ( $Line =~ /<dtl/ ) {

            # do template set (<dtl set $Data{"adasd"} = "lala">)
            # do system call (<dtl system-call $Data{"adasd"} = "uptime">)
            $Line =~ s{
                <dtl\W(system-call|set)\W\$(Data|Env|Config)\{\"(.+?)\"\}\W=\W\"(.+?)\">
            }
            {
                my $Data = '';
                if ($1 eq 'set') {
                    $Data = $4;
                }
                else {
                    open my $System, " $4 | " or print STDERR "Can't open $4: $!";
                    $Data = do { local $/; <$System> };
                    close $System;
                }

                $GlobalRef->{$2}->{$3} = $Data;
                # output replace with nothing!
                '';
            }egx;

            # do template if dynamic
            $Line =~ s{
                <dtl\Wif\W\(\$(Env|Data|Text|Config)\{\"(.*)\"\}\W(eq|ne|=~|!~)\W\"(.*)\"\)\W\{\W\$(Data|Env|Text)\{\"(.*)\"\}\W=\W\"(.*)\";\W\}>
            }
            {
                my $Type    = $1 || '';
                my $TypeKey = $2 || '';
                my $Con     = $3 || '';
                my $ConVal  = defined $4 ? $4 : '';
                my $IsType  = $5 || '';
                my $IsKey   = $6 || '';
                my $IsValue = $7 || '';
                # do ne actions
                if ($Type eq 'Text') {
                    my $Tmp = $Self->{LanguageObject}->Get($TypeKey) || '';
                    if (eval '($Tmp '.$Con.' $ConVal)') {
                        $GlobalRef->{$IsType}->{$IsKey} = $IsValue;
                        # output replace with nothing!
                        '';
                    }
                }
                elsif ($Type eq 'Env' || $Type eq 'Data') {
                    my $Tmp = $GlobalRef->{$Type}->{$TypeKey};
                    if ( !defined $Tmp ) {
                        $Tmp = '';
                    }
                    if (eval '($Tmp '.$Con.' $ConVal)') {
                        $GlobalRef->{$IsType}->{$IsKey} = $IsValue;
                        # output replace with nothing!
                        '';
                    }
                    else {
                        # output replace with nothing!
                        '';
                    }
                }
                elsif ($Type eq 'Config') {
                    my $Tmp = $Self->{ConfigObject}->Get($TypeKey);
                    if ( defined $Tmp && eval '($Tmp '.$Con.' $ConVal)') {
                        $GlobalRef->{$IsType}->{$IsKey} = $IsValue;
                        '';
                    }
                }
            }egx;
        }

        # variable & env & config replacement (three times)
        my $Regexp = 1;
        while ($Regexp) {
            $Regexp = $Line =~ s{
                \$((?:|Q|LQ|)Data|(?:|Q)Env|Config|Include){"(.+?)"}
            }
            {
                if ($1 eq 'Data' || $1 eq 'Env') {
                    if ( defined $GlobalRef->{$1}->{$2} ) {
                        $GlobalRef->{$1}->{$2};
                    }
                    else {
                        # output replace with nothing!
                        '';
                    }
                }
                elsif ($1 eq 'QEnv') {
                    my $Text = $2;
                    if ( !defined $Text || $Text =~ /^",\s*"(.+)$/ ) {
                        '';
                    }
                    elsif ($Text =~ /^(.+?)",\s*"(.+)$/) {
                        if ( defined $GlobalRef->{Env}->{$1} ) {
                            $Self->Ascii2Html(Text => $GlobalRef->{Env}->{$1}, Max => $2);
                        }
                        else {
                            # output replace with nothing!
                            '';
                        }
                    }
                    else {
                        if ( defined $GlobalRef->{Env}->{$Text} ) {
                            $Self->Ascii2Html(Text => $GlobalRef->{Env}->{$Text});
                        }
                        else {
                            # output replace with nothing!
                            '';
                        }
                    }
                }
                elsif ($1 eq 'QData') {
                    my $Text = $2;
                    if ( !defined $Text || $Text =~ /^",\s*"(.+)$/ ) {
                        '';
                    }
                    elsif ($Text =~ /^(.+?)",\s*"(.+)$/) {
                        if ( defined $GlobalRef->{Data}->{$1} ) {
                            $Self->Ascii2Html(Text => $GlobalRef->{Data}->{$1}, Max => $2);
                        }
                        else {
                            # output replace with nothing!
                            '';
                        }
                    }
                    else {
                        if ( defined $GlobalRef->{Data}->{$Text} ) {
                            $Self->Ascii2Html(Text => $GlobalRef->{Data}->{$Text});
                        }
                        else {
                            # output replace with nothing!
                            '';
                        }
                    }
                }
                # link encode
                elsif ($1 eq 'LQData') {
                    if ( defined $GlobalRef->{Data}->{$2} ) {
                        $Self->LinkEncode($GlobalRef->{Data}->{$2});
                    }
                    else {
                        # output replace with nothing!
                        '';
                    }
                }
                # replace with
                elsif ($1 eq 'Config') {
                    if ( defined $Self->{ConfigObject}->Get($2) ) {
                        $Self->{ConfigObject}->Get($2);
                    }
                    else {
                        # output replace with nothing!
                        '';
                    }
                }
                # include dtl files
                elsif ($1 eq 'Include') {
                    $Self->Output(
                        %Param,
                        TemplateFile => $2,
                    );
                }
            }egx;
        }

        # add this line to output
        $Output .= $Line . "\n";
    }
    chomp $Output;

    $Self->{OutputCount} = 0;

    # return output
    return $Output;
}

=item Redirect()

return html for browser to redirect

    my $HTML = $LayoutObject->Redirect(
        OP => "Action=AdminUserGroup&Subaction=User&ID=$UserID",
    );

    my $HTML = $LayoutObject->Redirect(
        ExtURL => "http://some.example.com/",
    );

=cut

sub Redirect {
    my ( $Self, %Param ) = @_;

    my $SessionIDCookie = '';
    my $Cookies         = '';

    # add cookies if exists
    if ( $Self->{SetCookies} && $Self->{ConfigObject}->Get('SessionUseCookie') ) {
        for ( keys %{ $Self->{SetCookies} } ) {
            $Cookies .= "Set-Cookie: $Self->{SetCookies}->{$_}\n";
        }
    }

    # create & return output
    if ( $Param{ExtURL} ) {

        # external redirect
        $Param{Redirect} = $Param{ExtURL};
        return $Cookies . $Self->Output( TemplateFile => 'Redirect', Data => \%Param );
    }

    # set baselink
    $Param{Redirect} = $Self->{Baselink};

    if ( $Param{OP} ) {

        # Filter out hazardous characters
        if ( $Param{OP} =~ s{\x00}{}smxg ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => 'Someone tries to use a null bytes (\x00) character in redirect!',
            );
        }

        if ( $Param{OP} =~ s{\r}{}smxg ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => 'Someone tries to use a carriage return character in redirect!',
            );
        }

        if ( $Param{OP} =~ s{\n}{}smxg ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => 'Someone tries to use a newline character in redirect!',
            );
        }

        # internal redirect
        $Param{OP} =~ s/^.*\?(.+?)$/$1/;
        $Param{Redirect} .= $Param{OP};
    }

    # check if IIS is used, add absolute url for IIS workaround
    # see also:
    #  o http://bugs.otrs.org/show_bug.cgi?id=2230
    #  o http://support.microsoft.com/default.aspx?scid=kb;en-us;221154
    if ( $ENV{SERVER_SOFTWARE} =~ /^microsoft\-iis/i ) {
        my $Host = $ENV{HTTP_HOST} || $Self->{ConfigObject}->Get('FQDN');
        my $HttpType = $Self->{ConfigObject}->Get('HttpType');
        $Param{Redirect} = $HttpType . '://' . $Host . '/' . $Param{Redirect};
    }
    my $Output = $Cookies . $Self->Output( TemplateFile => 'Redirect', Data => \%Param );

    # add session id to redirect if no cookie is enabled
    if ( !$Self->{SessionIDCookie} ) {

        # rewrite location header
        $Output =~ s{
            (location:\s)(.*)
        }
        {
            my $Start  = $1;
            my $Target = $2;
            my $End = '';
            if ($Target =~ /^(.+?)#(|.+?)$/) {
                $Target = $1;
                $End = "#$2";
            }
            if ($Target =~ /http/i || !$Self->{SessionID}) {
                "$Start$Target$End";
            }
            else {
                if ($Target =~ /(\?|&)$/) {
                    "$Start$Target$Self->{SessionName}=$Self->{SessionID}$End";
                }
                elsif ($Target !~ /\?/) {
                    "$Start$Target?$Self->{SessionName}=$Self->{SessionID}$End";
                }
                elsif ($Target =~ /\?/) {
                    "$Start$Target&$Self->{SessionName}=$Self->{SessionID}$End";
                }
                else {
                    "$Start$Target?&$Self->{SessionName}=$Self->{SessionID}$End";
                }
            }
        }iegx;
    }
    return $Output;
}

sub Login {
    my ( $Self, %Param ) = @_;

    my $Output = '';

    # add cookies if exists
    if ( $Self->{SetCookies} && $Self->{ConfigObject}->Get('SessionUseCookie') ) {
        for ( keys %{ $Self->{SetCookies} } ) {
            $Output .= "Set-Cookie: $Self->{SetCookies}->{$_}\n";
        }
    }

    # get message of the day
    if ( $Self->{ConfigObject}->Get('ShowMotd') ) {
        $Param{Motd} = $Self->Output( TemplateFile => 'Motd', Data => \%Param );
    }

    # get language options
    $Param{Language} = $Self->OptionStrgHashRef(
        Data       => $Self->{ConfigObject}->Get('DefaultUsedLanguages'),
        Name       => 'Lang',
        SelectedID => $Self->{UserLanguage},
        OnChange   => 'submit()',
        HTMLQuote  => 0,
    );

    # get lost password y
    if (
        $Self->{ConfigObject}->Get('LostPassword')
        && $Self->{ConfigObject}->Get('AuthModule') eq 'Kernel::System::Auth::DB'
        )
    {
        $Self->Block(
            Name => 'LostPassword',
            Data => \%Param,
        );
    }

    # create & return output
    $Output .= $Self->Output( TemplateFile => 'Login', Data => \%Param );

    # remove the version tag from the header if configured
    $Self->_DisableBannerCheck( OutputRef => \$Output );

    return $Output;
}
sub BasicLogin {
    my ( $Self, %Param ) = @_;

    my $Output = '';

    # add cookies if exists
    if ( $Self->{SetCookies} && $Self->{ConfigObject}->Get('SessionUseCookie') ) {
        for ( keys %{ $Self->{SetCookies} } ) {
            $Output .= "Set-Cookie: $Self->{SetCookies}->{$_}\n";
        }
    }

    # get message of the day
    if ( $Self->{ConfigObject}->Get('ShowMotd') ) {
        $Param{Motd} = $Self->Output( TemplateFile => 'Motd', Data => \%Param );
    }

    # get language options
    $Param{Language} = $Self->OptionStrgHashRef(
        Data       => $Self->{ConfigObject}->Get('DefaultUsedLanguages'),
        Name       => 'Lang',
        SelectedID => $Self->{UserLanguage},
        OnChange   => 'submit()',
        HTMLQuote  => 0,
    );

    # get lost password y
    if (
        $Self->{ConfigObject}->Get('LostPassword')
        && $Self->{ConfigObject}->Get('AuthModule') eq 'Kernel::System::Auth::DB'
        )
    {
        $Self->Block(
            Name => 'LostPassword',
            Data => \%Param,
        );
    }

    # create & return output
    $Output .= $Self->Output( TemplateFile => 'BasicLogin', Data => \%Param );

    # remove the version tag from the header if configured
    $Self->_DisableBannerCheck( OutputRef => \$Output );

    return $Output;
}


sub ChallengeTokenCheck {
    my ( $Self, %Param ) = @_;

    # return if feature is disabled
    return 1 if !$Self->{ConfigObject}->Get('SessionCSRFProtection');

    # get challenge token and check it
    my $ChallengeToken = $Self->{ParamObject}->GetParam( Param => 'ChallengeToken' ) || '';

    # check regular ChallengeToken
    return 1 if $ChallengeToken eq $Self->{UserChallengeToken};

    # check ChallengeToken of all own sessions
    my @Sessions = $Self->{SessionObject}->GetAllSessionIDs();
    for my $SessionID (@Sessions) {
        my %Data = $Self->{SessionObject}->GetSessionIDData( SessionID => $SessionID );
        next if !$Data{UserID};
        next if $Data{UserID} ne $Self->{UserID};
        next if !$Data{UserChallengeToken};

        # check ChallengeToken
        return 1 if $ChallengeToken eq $Data{UserChallengeToken};
    }

    # no valid token found
    $Self->FatalError(
        Message => 'Invalid Challenge Token!',
    );

    # ChallengeToken ok
    return;
}

sub FatalError {
    my ( $Self, %Param ) = @_;

    if ( $Param{Message} ) {
        $Self->{LogObject}->Log(
            Caller   => 1,
            Priority => 'error',
            Message  => $Param{Message},
        );
    }
    my $Output = $Self->Header( Area => 'Frontend', Title => 'Fatal Error' );
    $Output .= $Self->Error(%Param);
    $Output .= $Self->Footer();
    $Self->Print( Output => \$Output );
    exit;
}

sub SecureMode {
    my ( $Self, %Param ) = @_;

    my $Output = $Self->Header( Area => 'Frontend', Title => 'Secure Mode' );
    $Output .= $Self->Output( TemplateFile => 'AdminSecureMode', Data => \%Param );
    $Output .= $Self->Footer();
    $Self->Print( Output => \$Output );
    exit;
}

sub FatalDie {
    my ( $Self, %Param ) = @_;

    if ( $Param{Message} ) {
        $Self->{LogObject}->Log(
            Caller   => 1,
            Priority => 'error',
            Message  => $Param{Message},
        );
    }

    # get backend error messages
    for (qw(Message Traceback)) {
        my $Backend = 'Backend' . $_;
        $Param{$Backend} = $Self->{LogObject}->GetLogEntry(
            Type => 'Error',
            What => $_
        ) || '';
        $Param{$Backend} = $Self->Ascii2Html(
            Text           => $Param{$Backend},
            HTMLResultMode => 1,
        );
    }
    if ( !$Param{Message} ) {
        $Param{Message} = $Param{BackendMessage};
    }
    die $Param{Message};
}

sub ErrorScreen {
    my ( $Self, %Param ) = @_;

    my $Output = $Self->Header( Title => 'Error' );
    $Output .= $Self->Error(%Param);
    $Output .= $Self->Footer();
    return $Output;
}

sub Error {
    my ( $Self, %Param ) = @_;

    # get backend error messages
    for (qw(Message Traceback)) {
        my $Backend = 'Backend' . $_;
        $Param{$Backend} = $Self->{LogObject}->GetLogEntry(
            Type => 'Error',
            What => $_
        ) || '';
        $Param{$Backend} = $Self->Ascii2Html(
            Text           => $Param{$Backend},
            HTMLResultMode => 1,
        );
    }
    if ( !$Param{BackendMessage} && !$Param{BackendTraceback} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message => $Param{Message} || '?',
        );
        for (qw(Message Traceback)) {
            my $Backend = 'Backend' . $_;
            $Param{$Backend} = $Self->{LogObject}->GetLogEntry(
                Type => 'Error',
                What => $_
            ) || '';
            $Param{$Backend} = $Self->Ascii2Html(
                Text           => $Param{$Backend},
                HTMLResultMode => 1,
            );
        }
    }
    if ( !$Param{Message} ) {
        $Param{Message} = $Param{BackendMessage};
    }
    $Param{Message} =~ s/^(.{80}).*$/$1\[\.\.\]/gs;

    # create & return output
    return $Self->Output( TemplateFile => 'Error', Data => \%Param );
}

sub Warning {
    my ( $Self, %Param ) = @_;

    # get backend error messages
    $Param{BackendMessage} = $Self->{LogObject}->GetLogEntry(
        Type => 'Notice',
        What => 'Message',
        )
        || $Self->{LogObject}->GetLogEntry(
        Type => 'Error',
        What => 'Message',
        ) || '';
    $Param{BackendMessage} = $Self->Ascii2Html(
        Text           => $Param{BackendMessage},
        HTMLResultMode => 1,
    );

    if ( !$Param{Message} ) {
        $Param{Message} = $Param{BackendMessage};
    }

    # create & return output
    return $Self->Output( TemplateFile => 'Warning', Data => \%Param );
}

=item Notify()

create notify lines

    infos, the text will be translated

    my $Output = $LayoutObject->Notify(
        Priority => 'warning',
        Info => 'Some Info Message',
    );

    data with link, the text will be translated

    my $Output = $LayoutObject->Notify(
        Priority => 'warning',
        Data => '$Text{"Some DTL Stuff"}',
        Link => 'http://example.com/',
    );

    errors, the text will be translated

    my $Output = $LayoutObject->Notify(
        Priority => 'error',
        Info => 'Some Error Message',
    );

    errors from log backend, if no error extists, a '' will be returned

    my $Output = $LayoutObject->Notify(
        Priority => 'error',
    );

=cut

sub Notify {
    my ( $Self, %Param ) = @_;

    # create & return output
    if ( !$Param{Info} && !$Param{Data} ) {
        $Param{BackendMessage} = $Self->{LogObject}->GetLogEntry(
            Type => 'Notice',
            What => 'Message',
            )
            || $Self->{LogObject}->GetLogEntry(
            Type => 'Error',
            What => 'Message',
            ) || '';

        $Param{Info} = $Param{BackendMessage};

        # return if we have nothing to show
        return '' if !$Param{Info};
    }
    if ( $Param{Info} ) {
        $Param{Info} =~ s/\n//g;
    }
    if ( $Param{Priority} && $Param{Priority} eq 'Error' ) {
        $Self->Block(
            Name => 'Error',
            Data => {},
        );
    }
    else {
        $Self->Block(
            Name => 'Warning',
            Data => {},
        );
    }
    if ( $Param{Link} ) {
        $Self->Block(
            Name => 'LinkStart',
            Data => { LinkStart => $Param{Link}, },
        );
    }
    if ( $Param{Data} ) {
        $Self->Block(
            Name => 'Data',
            Data => \%Param,
        );
    }
    else {
        $Self->Block(
            Name => 'Text',
            Data => \%Param,
        );
    }
    if ( $Param{Link} ) {
        $Self->Block(
            Name => 'LinkStop',
            Data => { LinkStop => '</a>', },
        );
    }
    return $Self->Output( TemplateFile => 'Notify', Data => \%Param );
}

sub Header {
    my ( $Self, %Param ) = @_;

    my $Output = '';
    my $Type = $Param{Type} || '';

    # add cookies if exists
    if ( $Self->{SetCookies} && $Self->{ConfigObject}->Get('SessionUseCookie') ) {
        for ( keys %{ $Self->{SetCookies} } ) {
            $Output .= "Set-Cookie: $Self->{SetCookies}->{$_}\n";
        }
    }

    # fix IE bug if in filename is the word attachment
    my $File = $Param{Filename} || $Self->{Action} || 'unknown';
    if ( $Self->{BrowserBreakDispositionHeader} ) {
        $File =~ s/attachment/bttachment/gi;
    }

    # set file name for "save page as"
    $Param{ContentDisposition} = "filename=\"$File.html\"";

    # area and title
    if ( !$Param{Area} ) {
        $Param{Area}
            = $Self->{ConfigObject}->Get('Frontend::Module')->{ $Self->{Action} }->{NavBarName}
            || '';
    }
    if ( !$Param{Title} ) {
        $Param{Title} = $Self->{ConfigObject}->Get('Frontend::Module')->{ $Self->{Action} }->{Title}
            || '';
    }
    for my $Word (qw(Area Title Value)) {
        if ( $Param{$Word} ) {
            $Param{TitleArea} .= ' :: ' . $Self->{LanguageObject}->Get( $Param{$Word} );
        }
    }

    # create the user login info (usually visible right on the top of the page)
    if ( !$Self->{UserLoginIdentifier} ) {
        $Self->{UserLoginIdentifier} = $Self->{UserLogin} ? "($Self->{UserEmail})" : '';
    }

    # run header meta modules
    my $HeaderMetaModule = $Self->{ConfigObject}->Get('Frontend::HeaderMetaModule');
    if ( ref $HeaderMetaModule eq 'HASH' ) {
        my %Jobs = %{$HeaderMetaModule};
        for my $Job ( sort keys %Jobs ) {

            # load and run module
            next if !$Self->{MainObject}->Require( $Jobs{$Job}->{Module} );
            my $Object = $Jobs{$Job}->{Module}->new( %{$Self}, LayoutObject => $Self );
            next if !$Object;
            $Object->Run( %Param, Config => $Jobs{$Job} );
        }
    }

    # create & return output
    $Output .= $Self->Output( TemplateFile => "Header$Type", Data => \%Param );

    # remove the version tag from the header if configured
    $Self->_DisableBannerCheck( OutputRef => \$Output );

    return $Output;
}

sub Footer {
    my ( $Self, %Param ) = @_;

    my $Type = $Param{Type} || '';

    # unless explicitly specified, we set the footer width to use the whole space
    $Param{Width} ||= '100%';

    # create & return output
    return $Self->Output( TemplateFile => "Footer$Type", Data => \%Param );
}

sub Print {
    my ( $Self, %Param ) = @_;

    # custom post filters
    if ( $Self->{FilterContent} ) {
        my %Filters = %{ $Self->{FilterContent} };
        for my $Filter ( sort keys %Filters ) {
            next if !$Self->{MainObject}->Require( $Filters{$Filter}->{Module} );
            my $Object = $Filters{$Filter}->{Module}->new(
                ConfigObject => $Self->{ConfigObject},
                LogObject    => $Self->{LogObject},
                MainObject   => $Self->{MainObject},
                ParamObject  => $Self->{ParamObject},
                LayoutObject => $Self,
                Debug        => $Self->{Debug},
            );

            # run module
            $Object->Run(
                %{ $Filters{$Filter} },
                Data         => $Param{Output},
                TemplateFile => $Param{TemplateFile},
            );
        }
    }
    print ${ $Param{Output} };
    return 1;
}

sub PrintHeader {
    my ( $Self, %Param ) = @_;

    # unless explicitly specified, we set the header width
    $Param{Width} ||= 640;

    # fix IE bug if in filename is the word attachment
    my $File = $Param{Filename} || $Self->{Action} || 'unknown';
    if ( $Self->{BrowserBreakDispositionHeader} ) {
        $File =~ s/attachment/bttachment/gi;
    }

    # set file name for "save page as"
    $Param{ContentDisposition} = "filename=\"$File.html\"";

    # area and title
    if ( !$Param{Area} ) {
        $Param{Area}
            = $Self->{ConfigObject}->Get('Frontend::Module')->{ $Self->{Action} }->{NavBarName}
            || '';
    }
    if ( !$Param{Title} ) {
        $Param{Title} = $Self->{ConfigObject}->Get('Frontend::Module')->{ $Self->{Action} }->{Title}
            || '';
    }
    for my $Word (qw(Area Title Value)) {
        if ( $Param{$Word} ) {
            $Param{TitleArea} .= " :: " . $Self->{LanguageObject}->Get( $Param{$Word} );
        }
    }

    my $Output = $Self->Output( TemplateFile => 'PrintHeader', Data => \%Param );

    # remove the version tag from the header if configured
    $Self->_DisableBannerCheck( OutputRef => \$Output );

    # create & return output
    return $Output;
}

sub PrintFooter {
    my ( $Self, %Param ) = @_;

    $Param{Host} = $Self->Ascii2Html( Text => $ENV{SERVER_NAME} . $ENV{REQUEST_URI}, );
    $Param{Host} =~ s/&amp;/&/ig;

    # create & return output
    return $Self->Output( TemplateFile => 'PrintFooter', Data => \%Param );
}

=item Ascii2Html()

convert ascii to html string

    my $HTML = $LayoutObject->Ascii2Html(
        Text            => 'Some <> Test <font color="red">Test</font>',
        Max             => 20,       # max 20 chars folowed by [..]
        VMax            => 15,       # first 15 lines
        NewLine         => 0,        # move \r to \n
        HTMLResultMode  => 0,        # replace " " with &nbsp;
        StripEmptyLines => 0,
        Type            => 'Normal', # JSText or Normal text
        LinkFeature     => 0,        # do some URL detections
    );

also string ref is possible

    my $HTMLStringRef = $LayoutObject->Ascii2Html(
        Text            => \$Sting,
    );

=cut

sub Ascii2Html {
    my ( $Self, %Param ) = @_;

    my $Max             = $Param{Max}             || '';
    my $VMax            = $Param{VMax}            || '';
    my $NewLine         = $Param{NewLine}         || '';
    my $HTMLMode        = $Param{HTMLResultMode}  || '';
    my $StripEmptyLines = $Param{StripEmptyLines} || '';
    my $Type            = $Param{Type}            || '';

    return '' if !defined $Param{Text};

    # check ref
    my $TextScalar;
    my $Text;

    if ( !ref $Param{Text} ) {
        $TextScalar = 1;
        $Text       = \$Param{Text};
    }
    elsif ( ref $Param{Text} eq 'SCALAR' ) {
        $Text = $Param{Text};
    }
    else {
        return '';
    }

    my @Filters;
    if ( $Param{LinkFeature} && $Self->{FilterText} ) {
        my %Filters = %{ $Self->{FilterText} };
        for my $Filter ( sort keys %Filters ) {

            # load module
            my $Module = $Filters{$Filter}->{Module};
            if ( !$Self->{MainObject}->Require($Module) ) {
                $Self->FatalDie();
            }
            my $Object = $Module->new(
                %{$Self},
                LayoutObject => $Self,
            );
            next if !$Object;
            push(
                @Filters,
                {
                    Object => $Object,
                    Filter => $Filters{$Filter}
                },
            );
        }

        # pre run
        for my $Filter (@Filters) {
            $Text = $Filter->{Object}->Pre( Filter => $Filter->{Filter}, Data => $Text );
        }
    }

    # max width
    if ($Max) {
        ${$Text} =~ s/^(.{$Max}).+?$/$1\[\.\.\]/gs;
    }

    # newline
    if ( $NewLine && length($Text) < 140_000 ) {
        ${$Text} =~ s/(\n\r|\r\r\n|\r\n)/\n/g;
        ${$Text} =~ s/\r/\n/g;
        ${$Text} =~ s/(.{4,$NewLine})(?:\s|\z)/$1\n/gm;
        my $ForceNewLine = $NewLine + 10;
        ${$Text} =~ s/(.{$ForceNewLine})(.+?)/$1\n$2/g;
    }

    # remove tabs
    ${$Text} =~ s/\t/ /g;

    # strip empty lines
    if ($StripEmptyLines) {
        ${$Text} =~ s/^\s*\n//mg;
    }

    # max lines
    if ($VMax) {
        my @TextList = split( "\n", ${$Text} );
        ${$Text} = '';
        my $Counter = 1;
        for (@TextList) {
            if ( $Counter <= $VMax ) {
                ${$Text} .= $_ . "\n";
            }
            $Counter++;
        }
        if ( $Counter >= $VMax ) {
            ${$Text} .= "[...]\n";
        }
    }

    # html quoting
    ${$Text} =~ s/&/&amp;/g;
    ${$Text} =~ s/</&lt;/g;
    ${$Text} =~ s/>/&gt;/g;
    ${$Text} =~ s/"/&quot;/g;

    # text -> html format quoting
    if ( $Param{LinkFeature} ) {
        for my $Filter (@Filters) {
            $Text = $Filter->{Object}->Post( Filter => $Filter->{Filter}, Data => $Text );
        }
    }

    if ($HTMLMode) {
        ${$Text} =~ s/\n/<br\/>\n/g;
        ${$Text} =~ s/  /&nbsp;&nbsp;/g;
    }
    if ( $Type eq 'JSText' ) {
        ${$Text} =~ s/'/\\'/g;
    }

    # check ref && return result like called
    if ( defined $TextScalar ) {
        return ${$Text};
    }
    else {
        return $Text;
    }
}

=item LinkQuote()

so some URL link detections

    my $HTMLWithLinks = $LayoutObject->LinkQuote(
        Text => $HTMLWithOutLinks,
    );

also string ref is possible

    my $HTMLWithLinksRef = $LayoutObject->LinkQuote(
        Text => \$HTMLWithOutLinksRef,
    );

=cut

sub LinkQuote {
    my ( $Self, %Param ) = @_;

    my $Text   = $Param{Text}   || '';
    my $Target = $Param{Target} || 'NewPage' . int( rand(199) );

    # check ref
    my $TextScalar;
    if ( !ref $Text ) {
        $TextScalar = $Text;
        $Text       = \$TextScalar;
    }

    my @Filters;
    if ( $Self->{FilterText} ) {
        my %Filters = %{ $Self->{FilterText} };
        for my $Filter ( sort keys %Filters ) {
            if ( $Self->{MainObject}->Require( $Filters{$Filter}->{Module} ) ) {
                my $Object = $Filters{$Filter}->{Module}->new( %{$Self} );

                # run module
                if ($Object) {
                    push @Filters, { Object => $Object, Filter => $Filters{$Filter} };
                }
            }
            else {
                $Self->FatalDie();
            }
        }
    }
    for my $Filter (@Filters) {
        $Text = $Filter->{Object}->Pre( Filter => $Filter->{Filter}, Data => $Text );
    }
    for my $Filter (@Filters) {
        $Text = $Filter->{Object}->Post( Filter => $Filter->{Filter}, Data => $Text );
    }

    # do mail to quote
    ${$Text} =~ s/(mailto:.*?)(\.\s|\s|\)|\"|]|')/<a href=\"$1\">$1<\/a>$2/gi;

    # check ref && return result like called
    if ($TextScalar) {
        return ${$Text};
    }
    else {
        return $Text;
    }
}

=item HTMLLinkQuote()

so some URL link detections in HTML code

    my $HTMLWithLinks = $LayoutObject->HTMLLinkQuote(
        String => $HTMLString,
    );

also string ref is possible

    my $HTMLWithLinksRef = $LayoutObject->HTMLLinkQuote(
        String => \$HTMLString,
    );

=cut

sub HTMLLinkQuote {
    my ( $Self, %Param ) = @_;

    return $Self->{HTMLUtilsObject}->LinkQuote(
        String    => $Param{String},
        TargetAdd => 1,
        Target    => '_blank',
    );
}

=item LinkEncode()

do some url encoding - e. g. replace + with %2B in links

    my $URLEncoded = $LayoutObject->LinkEncode($URL);

=cut

sub LinkEncode {
    my ( $Self, $Link ) = @_;

    return if !defined $Link;

    $Link =~ s/&/%26/g;
    $Link =~ s/=/%3D/g;
    $Link =~ s/\!/%21/g;
    $Link =~ s/"/%22/g;
    $Link =~ s/\#/%23/g;
    $Link =~ s/\$/%24/g;
    $Link =~ s/'/%27/g;
    $Link =~ s/\+/%2B/g;
    $Link =~ s/\?/%3F/g;
    $Link =~ s/\|/%7C/g;
    $Link =~ s/�/\%A7/g;
    $Link =~ s/ /\+/g;
    return $Link;
}

sub CustomerAgeInHours {
    my ( $Self, %Param ) = @_;

    my $Age = defined( $Param{Age} ) ? $Param{Age} : return;
    my $Space = $Param{Space} || '<br/>';
    my $AgeStrg = '';
    if ( $Age =~ /^-(.*)/ ) {
        $Age     = $1;
        $AgeStrg = '-';
    }

    # get hours
    if ( $Age >= 3600 ) {
        $AgeStrg .= int( ( $Age / 3600 ) ) . ' ';
        if ( int( ( $Age / 3600 ) % 24 ) > 1 ) {
            $AgeStrg .= $Self->{LanguageObject}->Get('hours');
        }
        else {
            $AgeStrg .= $Self->{LanguageObject}->Get('hour');
        }
        $AgeStrg .= $Space;
    }

    # get minutes (just if age < 1 day)
    if ( $Age <= 3600 || int( ( $Age / 60 ) % 60 ) ) {
        $AgeStrg .= int( ( $Age / 60 ) % 60 ) . ' ';
        if ( int( ( $Age / 60 ) % 60 ) > 1 ) {
            $AgeStrg .= $Self->{LanguageObject}->Get('minutes');
        }
        else {
            $AgeStrg .= $Self->{LanguageObject}->Get('minute');
        }
    }
    return $AgeStrg;
}

sub CustomerAge {
    my ( $Self, %Param ) = @_;

    my $Age = defined( $Param{Age} ) ? $Param{Age} : return;
    my $Space = $Param{Space} || '<br/>';
    my $AgeStrg = '';
    if ( $Age =~ /^-(.*)/ ) {
        $Age     = $1;
        $AgeStrg = '-';
    }

    # get days
    if ( $Age >= 86400 ) {
        $AgeStrg .= int( ( $Age / 3600 ) / 24 ) . ' ';
        if ( int( ( $Age / 3600 ) / 24 ) > 1 ) {
            $AgeStrg .= $Self->{LanguageObject}->Get('days');
        }
        else {
            $AgeStrg .= $Self->{LanguageObject}->Get('day');
        }
        $AgeStrg .= $Space;
    }

    # get hours
    if ( $Age >= 3600 ) {
        $AgeStrg .= int( ( $Age / 3600 ) % 24 ) . ' ';
        if ( int( ( $Age / 3600 ) % 24 ) > 1 ) {
            $AgeStrg .= $Self->{LanguageObject}->Get('hours');
        }
        else {
            $AgeStrg .= $Self->{LanguageObject}->Get('hour');
        }
        $AgeStrg .= $Space;
    }

    # get minutes (just if age < 1 day)
    if ( $Self->{ConfigObject}->Get('TimeShowAlwaysLong') || $Age < 86400 ) {
        $AgeStrg .= int( ( $Age / 60 ) % 60 ) . ' ';
        if ( int( ( $Age / 60 ) % 60 ) > 1 ) {
            $AgeStrg .= $Self->{LanguageObject}->Get('minutes');
        }
        else {
            $AgeStrg .= $Self->{LanguageObject}->Get('minute');
        }
    }
    return $AgeStrg;
}

# OptionStrgHashRef()
#
# !! DONT USE THIS FUNCTION !! Use BuildSelection() instead.
#
# Due to compatibility reason this function is still in use and will be removed
# in a further release.

sub OptionStrgHashRef {
    my ( $Self, %Param ) = @_;

    my $Output     = '';
    my $Name       = $Param{Name} || '';
    my $Max        = $Param{Max} || 80;
    my $Multiple   = $Param{Multiple} ? 'multiple' : '';
    my $HTMLQuote  = defined( $Param{HTMLQuote} ) ? $Param{HTMLQuote} : 1;
    my $LT         = defined( $Param{LanguageTranslation} ) ? $Param{LanguageTranslation} : 1;
    my $Selected   = defined( $Param{Selected} ) ? $Param{Selected} : '-not-possible-to-use-';
    my $SelectedID = defined( $Param{SelectedID} ) ? $Param{SelectedID} : '-not-possible-to-use-';
    my $SelectedIDRefArray = $Param{SelectedIDRefArray} || '';
    my $PossibleNone       = $Param{PossibleNone} || '';
    my $SortBy             = $Param{SortBy} || 'Value';
    my $Size               = $Param{Size} || '';
    $Size = "size=$Size" if ($Size);

    # set OnChange if AJAX is used
    if ( $Param{Ajax} ) {
        if ( !$Param{Ajax}->{Depend} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => 'Need Depend Param Ajax option!',
            );
            $Self->FatalError();
        }
        if ( !$Param{Ajax}->{Update} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => 'Need Update Param Ajax option()!',
            );
            $Self->FatalError();
        }
        $Param{OnChange} = "AJAXUpdate('" . $Param{Ajax}->{Subaction} . "', "
            . " '$Name',"
            . "['"
            . join( "', '", @{ $Param{Ajax}->{Depend} } ) . "'], ['"
            . join( "', '", @{ $Param{Ajax}->{Update} } ) . "']);";
    }

    # check data
    if ( !$Param{Data} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Got no Data Param ref in OptionStrgHashRef()!',
        );
        $Self->FatalError();
    }
    elsif ( ref $Param{Data} ne 'HASH' ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "Need HashRef in Param Data! Got: '" . ref( $Param{Data} ) . "'!",
        );
        $Self->FatalError();
    }
    my %Data    = %{ $Param{Data} };
    my $OnStuff = '';
    if ( $Param{OnChangeSubmit} ) {
        $OnStuff .= ' onchange="submit()" ';
    }
    if ( $Param{OnChange} ) {
        $OnStuff = " onchange=\"$Param{OnChange}\" ";
    }
    if ( $Param{OnClick} ) {
        $OnStuff = " onclick=\"$Param{OnClick}\" ";
    }

    # set default value
    my $NoSelectedDataGiven = 0;
    if ( $Selected eq '-not-possible-to-use-' && $SelectedID eq '-not-possible-to-use-' ) {
        $NoSelectedDataGiven = 1;
    }
    if ( ( $Name eq 'ValidID' || $Name eq 'Valid' ) && $NoSelectedDataGiven ) {
        $Selected = $Self->{ConfigObject}->Get('DefaultValid');
    }
    elsif ( ( $Name eq 'LanguageID' || $Name eq 'Language' ) && $NoSelectedDataGiven ) {
        $Selected = $Self->{ConfigObject}->Get('DefaultLanguage');
    }
    elsif ( ( $Name eq 'ThemeID' || $Name eq 'Theme' ) && $NoSelectedDataGiven ) {
        $Selected = $Self->{ConfigObject}->Get('DefaultTheme');
    }
    elsif ( ( $Name eq 'LanguageID' || $Name eq 'Language' ) && $NoSelectedDataGiven ) {
        $Selected = $Self->{ConfigObject}->Get('DefaultLanguage');
    }

    #    elsif ($NoSelectedDataGiven) {
    #        # else set 1?
    #        $SelectedID = 1;
    #    }
    # build select string
    $Output .= "<select id=\"$Name\" name=\"$Name\" $Multiple $OnStuff $Size>\n";
    if ($PossibleNone) {
        $Output .= '<option VALUE="">-$Text{"none"}-</option>';
    }

    # hash cleanup
    for ( keys %Data ) {
        if ( !defined $Data{$_} ) {
            delete $Data{$_};
        }
    }

    my @Order = ();
    if ( $SortBy eq 'Key' ) {
        for ( sort keys %Data ) {
            push @Order, $_;
        }
    }
    else {
        for ( sort { $Data{$a} cmp $Data{$b} } keys %Data ) {
            push @Order, $_;
        }
    }
    for (@Order) {
        if ( defined $_ && defined $Data{$_} ) {

            # check if SelectedIDRefArray exists
            if ( $SelectedIDRefArray && ref $SelectedIDRefArray eq 'ARRAY' ) {
                for my $ID ( @{$SelectedIDRefArray} ) {
                    if ( $ID eq $_ ) {
                        $Param{SelectedIDRefArrayOK}->{$_} = 1;
                    }
                }
            }

            # build select string
            if ( $_ eq $SelectedID || $Data{$_} eq $Selected || $Param{SelectedIDRefArrayOK}->{$_} )
            {
                $Output .= '  <option selected value="' . $Self->Ascii2Html( Text => $_ ) . '">';
            }
            else {
                $Output .= '  <option value="' . $Self->Ascii2Html( Text => $_ ) . '">';
            }
            if ($LT) {
                $Data{$_} = $Self->{LanguageObject}->Get( $Data{$_} );
            }
            if ($HTMLQuote) {
                $Output .= $Self->Ascii2Html( Text => $Data{$_}, Max => $Max );
            }
            else {
                $Output .= $Data{$_};
            }
            $Output .= "</option>\n";
        }
    }
    $Output .= "</select><a id=\"AJAXImage$Name\"></a>\n";
    return $Output;
}

# OptionElement()
#
# !! DONT USE THIS FUNCTION !! Use BuildSelection() instead.
#
# Due to compatibility reason this function is still in use and will be removed
# in a further release.
#
#
# build a html option element based on given data
#
#    my $HTML = $LayoutObject->OptionElement(
#        Name            => 'SomeParamName',
#        Data            => {
#            ParamA => {
#                Position    => 1,
#                Value       => 'Some Nice Text A',
#            },
#            ParamB => {
#                Position    => 2,
#                Value       => 'Some Nice Text B',
#                Selected    => 1,
#            },
#        },
#        # optional
#        Max             => 80, # max size of the shown value
#        Multiple        => 0, # 1|0
#        Size            => '', # option element size
#        HTMLQuote       => 1, # 1|0
#        PossibleNone    => 0, # 1|0 add a leading empty selection
#    );

sub OptionElement {
    my ( $Self, %Param ) = @_;

    my $Output       = '';
    my $Name         = $Param{Name} || '';
    my $Max          = $Param{Max} || 80;
    my $Multiple     = $Param{Multiple} ? 'multiple' : '';
    my $HTMLQuote    = defined( $Param{HTMLQuote} ) ? $Param{HTMLQuote} : 1;
    my $Translation  = defined( $Param{Translation} ) ? $Param{Translation} : 1;
    my $PossibleNone = $Param{PossibleNone} || '';
    my $Size         = $Param{Size} || '';
    $Size = "size=\"$Size\"" if ($Size);

    # check needed stuff
    for (qw(Name Data)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Got no Data Param ref in OptionStrgHashRef()!",
            );
            $Self->FatalError();
        }
    }
    if ( !$Param{Data} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "Got no Data Param ref in OptionStrgHashRef()!",
        );
        $Self->FatalError();
    }
    elsif ( ref $Param{Data} ne 'HASH' ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "Need HashRef in Param Data! Got: '" . ref( $Param{Data} ) . "'!",
        );
        $Self->FatalError();
    }

    # detect
    # $Param{Data}{Key}{Value}
    my $Hash2 = 0;
    for my $Key ( %{ $Param{Data} } ) {
        if ( ref $Param{Data}->{$Key} eq 'HASH' ) {
            $Hash2 = 1;
            last;
        }
    }
    if ($Hash2) {

        # get sort prio
        my %DataSort = ();
        for my $Key ( keys %{ $Param{Data} } ) {
            if ( $Param{Data}->{$Key}->{Position} ) {
                $DataSort{$Key} = $Param{Data}->{$Key}->{Position};
            }
            else {
                $DataSort{$Key} = 0;
            }
        }

        # build option element
        $Output .= "<select name=\"$Name\" $Multiple $Size>\n";
        if ($PossibleNone) {
            $Output .= '<option VALUE="">-$Text{"none"}-</option>';
        }
        for my $Key ( sort { $DataSort{$a} <=> $DataSort{$b} } keys %DataSort ) {
            $Output .= '  <option value="' . $Self->Ascii2Html( Text => $Key ) . '"';
            if ( $Param{Data}->{$Key}->{Selected} ) {
                $Output .= ' selected';
            }
            $Output .= '>';
            if ($Translation) {
                $Param{Data}->{$Key}->{Value}
                    = $Self->{LanguageObject}->Get( $Param{Data}->{$Key}->{Value} );
            }
            if ($HTMLQuote) {

                my $Value = $Self->Ascii2Html(
                    Text => $Param{Data}->{$Key}->{Value},
                    Max  => $Max,
                );

                $Output .= defined $Value ? $Value : '';
            }
            else {
                my $Value = $Param{Data}->{$Key}->{Value};

                $Output .= defined $Value ? $Value : '';
            }
            $Output .= "</option>\n";
        }
        $Output .= "</select>\n";
    }
    else {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "Got corrupt Data param! Got: '" . ref( $Param{Data} ) . "'!",
        );
        $Self->FatalError();
    }
    return $Output;
}

=item BuildSelection()

build a html option element based on given data

    my $HTML = $LayoutObject->BuildSelection(
        Data => $ArrayRef,                # use $HashRef, $ArrayRef or $ArrayHashRef (see below)

        Name       => 'TheName',          # name of element
        Multiple   => 0,                  # (optional) default 0 (0|1)
        Size       => 1,                  # (optional) default 1 element size
        Class      => 'class',            # (optional) a css class
        Disabled   => 0,                  # (optional) default 0 (0|1) disable the element
        OnChange   => 'javascript',       # (optional)
        OnClick    => 'javascript',       # (optional)

        SelectedID    => 1,               # (optional) use integer or arrayref (unable to use with ArrayHashRef)
        SelectedID    => [1, 5, 3],       # (optional) use integer or arrayref (unable to use with ArrayHashRef)
        SelectedValue => 'test',          # (optional) use string or arrayref (unable to use with ArrayHashRef)
        SelectedValue => ['test', 'test1'], # (optional) use string or arrayref (unable to use with ArrayHashRef)
        Sort => 'NumericValue',           # (optional) (AlphanumericValue|NumericValue|AlphanumericKey|NumericKey|TreeView|IndividualKey|IndividualValue) unable to use with ArrayHashRef
        SortIndividual => ['sec', 'min']  # (optional) only sort is set to IndividualKey or IndividualValue
        SortReverse    => 0,              # (optional) reverse the list
        Translation    => 1,              # (optional) default 1 (0|1) translate value
        PossibleNone   => 0,              # (optional) default 0 (0|1) add a leading empty selection
        TreeView       => 0,              # (optional) default 0 (0|1)
        DisabledBranch => 'Branch',       # (optional) disable all elements of this branch (use string or arrayref)
        Max            => 100,            # (optional) default 100 max size of the shown value
        HTMLQuote      => 0,              # (optional) default 1 (0|1) disable html quote
        Title          => 'Tooltip Text', # (optional) string will be shown as Tooltip on mouseover
    );

    my $HashRef = {
        'Key1' => 'Value1',
        'Key2' => 'Value2',
        'Key3' => 'Value3',
    };

    my $ArrayRef = [
        'KeyValue1',
        'KeyValue2',
        'KeyValue3',
        'KeyValue4',
    ];

    my $ArrayHashRef = [
        {
            Key => '1',
            Value => 'Value1',
        },
        {
            Key => '2',
            Value => 'Value1::Subvalue1',
            Selected => 1,
        },
        {
            Key => '3',
            Value => 'Value1::Subvalue2',
        },
        {
            Key => '4',
            Value => 'Value2',
            Disabled => 1,
        }
    ];

=cut

sub BuildSelection {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Name Data)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # set OnChange if AJAX is used
    if ( $Param{Ajax} ) {
        if ( !$Param{Ajax}->{Depend} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => 'Need Depend Param Ajax option!',
            );
            $Self->FatalError();
        }
        if ( !$Param{Ajax}->{Update} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => 'Need Update Param Ajax option()!',
            );
            $Self->FatalError();
        }
        $Param{OnChange} = "AJAXUpdate('" . $Param{Ajax}->{Subaction} . "',"
            . " '$Param{Name}',"
            . " ['"
            . join( "', '", @{ $Param{Ajax}->{Depend} } ) . "'], ['"
            . join( "', '", @{ $Param{Ajax}->{Update} } ) . "']);";
    }

    # create OptionRef
    my $OptionRef = $Self->_BuildSelectionOptionRefCreate(%Param);

    # create AttributeRef
    my $AttributeRef = $Self->_BuildSelectionAttributeRefCreate(%Param);

    # create DataRef
    my $DataRef = $Self->_BuildSelectionDataRefCreate(
        Data         => $Param{Data},
        AttributeRef => $AttributeRef,
        OptionRef    => $OptionRef,
    );

    # generate output
    my $String = $Self->_BuildSelectionOutput(
        AttributeRef => $AttributeRef,
        DataRef      => $DataRef,
    );
    $String .= "<a id=\"AJAXImage$Param{Name}\"></a>\n";
    return $String;
}

sub BuildGroupedSelection {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Name Data)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # set OnChange if AJAX is used
    if ( $Param{Ajax} ) {
        if ( !$Param{Ajax}->{Depend} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => 'Need Depend Param Ajax option!',
            );
            $Self->FatalError();
        }
        if ( !$Param{Ajax}->{Update} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => 'Need Update Param Ajax option()!',
            );
            $Self->FatalError();
        }
        $Param{OnChange} = "AJAXUpdate('" . $Param{Ajax}->{Subaction} . "',"
            . " '$Param{Name}',"
            . " ['"
            . join( "', '", @{ $Param{Ajax}->{Depend} } ) . "'], ['"
            . join( "', '", @{ $Param{Ajax}->{Update} } ) . "']);";
    }

    # create OptionRef
    my $OptionRef = $Self->_BuildSelectionOptionRefCreate(%Param);

    # create AttributeRef
    my $AttributeRef = $Self->_BuildSelectionAttributeRefCreate(%Param);

    # create DataRef
    my $DataRef = $Self->_BuildSelectionDataRefCreate(
        Data         => $Param{Data},
        AttributeRef => $AttributeRef,
        OptionRef    => $OptionRef,
    );

    # generate output
    my $String = $Self->_BuildGroupedSelectionOutput(
        AttributeRef => $AttributeRef,
        DataRef      => $DataRef,
        GroupType      => $Param{GroupType},
    );
    $String .= "<a id=\"AJAXImage$Param{Name}\"></a>\n";
    return $String;
}


#=item _BuildSelectionOptionRefCreate()
#
#create the option hash
#
#    my $OptionRef = $LayoutObject->_BuildSelectionOptionRefCreate(
#        %Param,
#    );
#
#    my $OptionRef = {
#        Sort => 'numeric',
#        PossibleNone => 0,
#        Max => 100,
#    }
#
#=cut

sub _BuildSelectionOptionRefCreate {
    my ( $Self, %Param ) = @_;

    my $OptionRef = {};

    # set SelectedID option
    if ( defined $Param{SelectedID} ) {
        if ( ref $Param{SelectedID} eq 'ARRAY' ) {
            for my $Key ( @{ $Param{SelectedID} } ) {
                $OptionRef->{SelectedID}->{$Key} = 1;
            }
        }
        else {
            $OptionRef->{SelectedID}->{ $Param{SelectedID} } = 1;
        }
    }

    # set SelectedValue option
    if ( defined $Param{SelectedValue} ) {
        if ( ref $Param{SelectedValue} eq 'ARRAY' ) {
            for my $Value ( @{ $Param{SelectedValue} } ) {
                $OptionRef->{SelectedValue}->{$Value} = 1;
            }
        }
        else {
            $OptionRef->{SelectedValue}->{ $Param{SelectedValue} } = 1;
        }
    }

    # set Sort option
    $OptionRef->{Sort} = 0;
    if ( $Param{Sort} ) {
        $OptionRef->{Sort} = $Param{Sort};
    }

    # look if a individual sort is available
    if ( $Param{SortIndividual} && ref $Param{SortIndividual} eq 'ARRAY' ) {
        $OptionRef->{SortIndividual} = $Param{SortIndividual};
    }

    # set SortReverse option
    $OptionRef->{SortReverse} = 0;
    if ( $Param{SortReverse} ) {
        $OptionRef->{SortReverse} = 1;
    }

    # set Translation option
    $OptionRef->{Translation} = 1;
    if ( defined $Param{Translation} && $Param{Translation} eq 0 ) {
        $OptionRef->{Translation} = 0;
    }

    # correcting selected value hash if translation is on
    if (
        $OptionRef->{Translation}
        && $OptionRef->{SelectedValue}
        && ref $OptionRef->{SelectedValue} eq 'HASH'
        )
    {
        my %SelectedValueNew;
        for my $OriginalKey ( keys %{ $OptionRef->{SelectedValue} } ) {
            my $TranslatedKey = $Self->{LanguageObject}->Get($OriginalKey);
            $SelectedValueNew{$TranslatedKey} = 1;
        }
        $OptionRef->{SelectedValue} = \%SelectedValueNew;
    }

    # set PossibleNone option
    $OptionRef->{PossibleNone} = 0;
    if ( $Param{PossibleNone} ) {
        $OptionRef->{PossibleNone} = 1;
    }

    # set TreeView option
    $OptionRef->{TreeView} = 0;
    if ( $Param{TreeView} ) {
        $OptionRef->{TreeView} = 1;
        $OptionRef->{Sort}     = 'TreeView';
    }

    # set DisabledBranch option
    if ( $Param{DisabledBranch} ) {
        if ( ref $Param{DisabledBranch} eq 'ARRAY' ) {
            for my $Branch ( @{ $Param{DisabledBranch} } ) {
                $OptionRef->{DisabledBranch}->{$Branch} = 1;
            }
        }
        else {
            $OptionRef->{DisabledBranch}->{ $Param{DisabledBranch} } = 1;
        }
    }

    # set Max option
    $OptionRef->{Max} = $Param{Max} || 100;

    # set HTMLQuote option
    $OptionRef->{HTMLQuote} = 1;
    if ( defined $Param{HTMLQuote} ) {
        $OptionRef->{HTMLQuote} = $Param{HTMLQuote};
    }

    return $OptionRef;
}

#=item _BuildSelectionAttributeRefCreate()
#
#create the attribute hash
#
#    my $AttributeRef = $LayoutObject->_BuildSelectionAttributeRefCreate(
#        %Param,
#    );
#
#    my $AttributeRef = {
#        name => 'TheName',
#        multiple => undef,
#        size => 5,
#    }
#
#=cut

sub _BuildSelectionAttributeRefCreate {
    my ( $Self, %Param ) = @_;

    my $AttributeRef = {};

    # check params with key and value
    for (qw(Name ID Size Class OnChange OnClick)) {
        if ( $Param{$_} ) {
            $AttributeRef->{ lc($_) } = $Param{$_};
        }
    }

    # add id attriubut
    if ( !$AttributeRef->{id} ) {
        $AttributeRef->{id} = $AttributeRef->{name};
    }

    # check params with key and value that need to be HTML-Quoted
    for (qw(Title)) {
        if ( $Param{$_} ) {
            $AttributeRef->{ lc($_) } = $Self->Ascii2Html( Text => $Param{$_} );
        }
    }

    # check key only params
    for (qw(Multiple Disabled)) {
        if ( $Param{$_} ) {
            $AttributeRef->{ lc($_) } = undef;
        }
    }

    return $AttributeRef;
}

#=item _BuildSelectionDataRefCreate()
#
#create the data hash
#
#    my $DataRef = $LayoutObject->_BuildSelectionDataRefCreate(
#        Data => $ArrayRef,              # use $HashRef, $ArrayRef or $ArrayHashRef
#        AttributeRef => $AttributeRef,
#        OptionRef => $OptionRef,
#    );
#
#    my $DataRef  = [
#        {
#            Key => 11,
#            Value => 'Text',
#        },
#        {
#            Key => 'abc',
#            Value => '&nbsp;&nbsp;Text',
#            Selected => 1,
#        },
#    ];
#
#=cut

sub _BuildSelectionDataRefCreate {
    my ( $Self, %Param ) = @_;

    my $AttributeRef = $Param{AttributeRef};
    my $OptionRef    = $Param{OptionRef};
    my $DataRef      = [];

    my $Counter = 0;

    # if HashRef was given
    if ( ref $Param{Data} eq 'HASH' ) {

        # sort hash (before the translation)
        my @SortKeys;
        if ( $OptionRef->{Sort} eq 'IndividualValue' && $OptionRef->{SortIndividual} ) {
            my %List = reverse %{ $Param{Data} };
            for my $Key ( @{ $OptionRef->{SortIndividual} } ) {
                if ( $List{$Key} ) {
                    push @SortKeys, $List{$Key};
                    delete $List{$Key};
                }
            }
            push @SortKeys, sort { $a cmp $b } ( values %List );
        }

        # translate value
        if ( $OptionRef->{Translation} ) {
            for my $Row ( keys %{ $Param{Data} } ) {
                $Param{Data}->{$Row} = $Self->{LanguageObject}->Get( $Param{Data}->{$Row} );
            }
        }

        # sort hash (after the translation)
        if ( $OptionRef->{Sort} eq 'NumericKey' ) {
            @SortKeys = sort { $a <=> $b } ( keys %{ $Param{Data} } );
        }
        elsif ( $OptionRef->{Sort} eq 'NumericValue' ) {
            @SortKeys
                = sort { $Param{Data}->{$a} <=> $Param{Data}->{$b} } ( keys %{ $Param{Data} } );
        }
        elsif ( $OptionRef->{Sort} eq 'AlphanumericKey' ) {
            @SortKeys = sort( keys %{ $Param{Data} } );
        }
        elsif ( $OptionRef->{Sort} eq 'TreeView' ) {

            # add suffix for correct sorting
            my %SortHash;
            for ( keys %{ $Param{Data} } ) {
                $SortHash{$_} = $Param{Data}->{$_} . '::';
            }
            @SortKeys = sort { $SortHash{$a} cmp $SortHash{$b} } ( keys %SortHash );
        }
        elsif ( $OptionRef->{Sort} eq 'IndividualKey' && $OptionRef->{SortIndividual} ) {
            my %List = %{ $Param{Data} };
            for my $Key ( @{ $OptionRef->{SortIndividual} } ) {
                if ( $List{$Key} ) {
                    push @SortKeys, $Key;
                    delete $List{$Key};
                }
            }
            push @SortKeys, sort { $List{$a} cmp $List{$b} } ( keys %List );
        }
        elsif ( $OptionRef->{Sort} eq 'IndividualValue' && $OptionRef->{SortIndividual} ) {

            # already done before the translation
        }
        else {
            @SortKeys
                = sort { $Param{Data}->{$a} cmp $Param{Data}->{$b} } ( keys %{ $Param{Data} } );
            $OptionRef->{Sort} = 'AlphanumericValue';
        }

        # create DataRef
        for my $Row (@SortKeys) {
            $DataRef->[$Counter]->{Key}   = $Row;
            $DataRef->[$Counter]->{Value} = $Param{Data}->{$Row};
            $Counter++;
        }
    }

    # if ArrayHashRef was given
    elsif ( ref $Param{Data} eq 'ARRAY' && ref $Param{Data}->[0] eq 'HASH' ) {

        # create DataRef
        for my $Row ( @{ $Param{Data} } ) {
            if ( ref $Row eq 'HASH' && defined $Row->{Key} ) {
                $DataRef->[$Counter]->{Key}   = $Row->{Key};
                $DataRef->[$Counter]->{Value} = $Row->{Value};

                # translate value
                if ( $OptionRef->{Translation} ) {
                    $DataRef->[$Counter]->{Value}
                        = $Self->{LanguageObject}->Get( $DataRef->[$Counter]->{Value} );
                }

                # set Selected and Disabled options
                if ( $Row->{Selected} ) {
                    $DataRef->[$Counter]->{Selected} = 1;
                }
                elsif ( $Row->{Disabled} ) {
                    $DataRef->[$Counter]->{Disabled} = 1;
                }
                $Counter++;
            }
        }
    }

    # if ArrayRef was given
    elsif ( ref $Param{Data} eq 'ARRAY' ) {

        if (
            ( $OptionRef->{Sort} eq 'IndividualValue' || $OptionRef->{Sort} eq 'IndividualValue' )
            && $OptionRef->{SortIndividual}
            )
        {
            my %List = map { $_ => 1 } @{ $Param{Data} };
            $Param{Data} = [];
            for my $Key ( @{ $OptionRef->{SortIndividual} } ) {
                if ( $List{$Key} ) {
                    push @{ $Param{Data} }, $Key;
                    delete $List{$Key};
                }
            }
            push @{ $Param{Data} }, sort { $a cmp $b } ( keys %List );
        }

        my %ReverseHash;

        # translate value
        if ( $OptionRef->{Translation} ) {
            my @TranslateArray;
            for my $Row ( @{ $Param{Data} } ) {
                my $TranslateString = $Self->{LanguageObject}->Get($Row);
                push @TranslateArray, $TranslateString;
                $ReverseHash{$TranslateString} = $Row;
            }
            $Param{Data} = \@TranslateArray;
        }
        else {
            for my $Row ( @{ $Param{Data} } ) {
                $ReverseHash{$Row} = $Row;
            }
        }

        # sort array
        if ( $OptionRef->{Sort} eq 'AlphanumericKey' || $OptionRef->{Sort} eq 'AlphanumericValue' )
        {
            my @SortArray = sort( @{ $Param{Data} } );
            $Param{Data} = \@SortArray;
        }
        elsif ( $OptionRef->{Sort} eq 'NumericKey' || $OptionRef->{Sort} eq 'NumericValue' ) {
            my @SortArray = sort { $a <=> $b } ( @{ $Param{Data} } );
            $Param{Data} = \@SortArray;
        }
        elsif ( $OptionRef->{Sort} eq 'TreeView' ) {

            # add suffix for correct sorting
            my @SortArray;
            for my $Row ( @{ $Param{Data} } ) {
                push @SortArray, ( $Row . '::' );
            }

            # sort array
            @SortArray = sort(@SortArray);

            # remove suffix
            my @SortArray2;
            for my $Row (@SortArray) {
                $/ = '::';
                chomp($Row);
                push @SortArray2, $Row;
            }
            $Param{Data} = \@SortArray;
        }

        # create DataRef
        for my $Row ( @{ $Param{Data} } ) {
            $DataRef->[$Counter]->{Key}   = $ReverseHash{$Row};
            $DataRef->[$Counter]->{Value} = $Row;
            $Counter++;
        }
    }

    # SelectedID and SelectedValue option
    if ( $OptionRef->{SelectedID} || $OptionRef->{SelectedValue} ) {
        for my $Row ( @{$DataRef} ) {
            if (
                $OptionRef->{SelectedID}->{ $Row->{Key} }
                || $OptionRef->{SelectedValue}->{ $Row->{Value} }
                )
            {
                $Row->{Selected} = 1;
            }
        }
    }

    # DisabledBranch option
    if ( $OptionRef->{DisabledBranch} ) {
        for my $Row ( @{$DataRef} ) {
            for my $Branch ( keys %{ $OptionRef->{DisabledBranch} } ) {
                if ( $Row->{Value} =~ /^(\Q$Branch\E)$/ || $Row->{Value} =~ /^(\Q$Branch\E)::/ ) {
                    $Row->{Disabled} = 1;
                }
            }
        }
    }

    # Max option
    # REMARK: Don't merge the Max handling with Ascii2Html function call of
    # the HTMLQuote handling. In this case you lose the max handling if you
    # deactivate HTMLQuote
    if ( $OptionRef->{Max} ) {
        for my $Row ( @{$DataRef} ) {

            # REMARK: This is the same solution as in Ascii2Html
            $Row->{Value} =~ s/^(.{$OptionRef->{Max}}).+?$/$1\[\.\.\]/gs;

            #$Row->{Value} = substr( $Row->{Value}, 0, $OptionRef->{Max} );
        }
    }

    # HTMLQuote option
    if ( $OptionRef->{HTMLQuote} ) {
        for my $Row ( @{$DataRef} ) {
            $Row->{Key}   = $Self->Ascii2Html( Text => $Row->{Key} );
            $Row->{Value} = $Self->Ascii2Html( Text => $Row->{Value} );
        }
    }

    # SortReverse option
    if ( $OptionRef->{SortReverse} ) {
        @{$DataRef} = reverse( @{$DataRef} );
    }

    # PossibleNone option
    if ( $OptionRef->{PossibleNone} ) {
        my %None;
        $None{Key}   = '';
        $None{Value} = '-';

        unshift( @{$DataRef}, \%None );
    }

    # TreeView option
    if ( $OptionRef->{TreeView} ) {

        ROW:
        for my $Row ( @{$DataRef} ) {

            next ROW if !$Row->{Value};

            my @Fragment = split '::', $Row->{Value};
            $Row->{Value} = pop @Fragment;

            my $Space = '&nbsp;&nbsp;' x scalar @Fragment;
            $Space ||= '';

            $Row->{Value} = $Space . $Row->{Value};
        }
    }

    return $DataRef;
}

#=item _BuildSelectionOutput()
#
#create the html string
#
#    my $HTMLString = $LayoutObject->_BuildSelectionOutput(
#        AttributeRef => $AttributeRef,
#        DataRef => $DataRef,
#    );
#
#    my $AttributeRef = {
#        name => 'TheName',
#        multiple => undef,
#        size => 5,
#    }
#
#    my $DataRef  = [
#        {
#            Key => 11,
#            Value => 'Text',
#            Disabled => 1,
#        },
#        {
#            Key => 'abc',
#            Value => '&nbsp;&nbsp;Text',
#            Selected => 1,
#        },
#    ];
#
#=cut

sub _BuildSelectionOutput {
    my ( $Self, %Param ) = @_;

    my $String;

    # start generation, if AttributeRef and DataRef was found
    if ( $Param{AttributeRef} && $Param{DataRef} ) {

        # generate <select> row
        $String = '<select';
        for my $Key ( keys %{ $Param{AttributeRef} } ) {
            if ( $Key && defined $Param{AttributeRef}->{$Key} ) {
                $String .= " $Key=\"$Param{AttributeRef}->{$Key}\"";
            }
            elsif ($Key) {
                $String .= " $Key";
            }
        }
        $String .= ">\n";

        # generate <option> rows
        for my $Row ( @{ $Param{DataRef} } ) {
            my $Key = '';
            if ( defined $Row->{Key} ) {
                $Key = $Row->{Key};
            }
            my $Value = '';
            if ( defined $Row->{Value} ) {
                $Value = $Row->{Value};
            }
            my $SelectedDisabled = '';
            if ( $Row->{Selected} ) {
                $SelectedDisabled = ' selected';
            }
            elsif ( $Row->{Disabled} ) {
                $SelectedDisabled = ' disabled';
            }
            $String .= "  <option value=\"$Key\"$SelectedDisabled>$Value</option>\n";
        }
        $String .= '</select>';
    }
    return $String;
}

sub _BuildGroupedSelectionOutput {
    my ( $Self, %Param ) = @_;

    my $String;

    # start generation, if AttributeRef and DataRef was found
    if ( $Param{AttributeRef} && $Param{DataRef} ) {

        # generate <select> row
        $String = '<select';
        for my $Key ( keys %{ $Param{AttributeRef} } ) {
            if ( $Key && defined $Param{AttributeRef}->{$Key} ) {
                $String .= " $Key=\"$Param{AttributeRef}->{$Key}\"";
            }
            elsif ($Key) {
                $String .= " $Key";
            }
        }
        $String .= ">\n";
        
        my %Groups;
                
        foreach my $GroupName ( values %{ $Param{GroupType} } ) {
        	$Groups{$GroupName} = ();
        }
        
        my @GroupedRow;
	        
			foreach my $Row ( @{ $Param{DataRef} } ) {
				
				my $TypeName = $Row->{Value};
				
				my $k = $Param{GroupType}{$TypeName};
				#if (defined($k)){
					push @{$Groups{ $k }}, $Row;
				#} else {
					#push @{}, $Row;
				#}
	        }
	        
       
		foreach my $GroupName (keys %Groups ) {
			
			if ((defined($GroupName)) && ($GroupName ne "")){			
				$String .= '<optgroup label="'.$GroupName.'">';
			}        
			
	        # generate <option> rows
	        #for my $Row ( @{ $Param{DataRef} } ) {
	        for my $Row ( @{ $Groups{$GroupName} } ) {
	            my $Key = '';
	            if ( defined $Row->{Key} ) {
	                $Key = $Row->{Key};
	            }
	            my $Value = '';
	            if ( defined $Row->{Value} ) {
	                $Value = $Row->{Value};
	            }
	            my $SelectedDisabled = '';
	            if ( $Row->{Selected} ) {
	                $SelectedDisabled = ' selected';
	            }
	            elsif ( $Row->{Disabled} ) {
	                $SelectedDisabled = ' disabled';
	            }
	            $String .= "  <option value=\"$Key\"$SelectedDisabled>$Value</option>\n";
	        }
	        
	        if ((defined($GroupName)) && ($GroupName ne "")){
	        	$String .= '</optgroup>';
	        }
	        
		}
		
        $String .= '</select>';
    }
    return $String;
}

sub NoPermission {
    my ( $Self, %Param ) = @_;

    my $WithHeader = $Param{WithHeader} || 'yes';
    my $Output = '';
    $Param{Message} = 'No Permission!' if ( !$Param{Message} );

    # create output
    $Output = $Self->Header( Title => 'No Permission' ) if ( $WithHeader eq 'yes' );
    $Output .= $Self->Output( TemplateFile => 'NoPermission', Data => \%Param );
    $Output .= $Self->Footer() if ( $WithHeader eq 'yes' );

    # return output
    return $Output;
}

sub CheckCharset {
    my ( $Self, %Param ) = @_;

    my $Output = '';
    if ( !$Param{Action} ) {
        $Param{Action} = '$Env{"Action"}';
    }

    # with utf-8 can everything be shown
    if ( $Self->{UserCharset} !~ /^utf-8$/i ) {

        # replace ' or "
        $Param{Charset} && $Param{Charset} =~ s/'|"//gi;

        # if the content charset is different to the user charset
        if ( $Param{Charset} && $Self->{UserCharset} !~ /^$Param{Charset}$/i ) {

            # if the content charset is us-ascii it is always shown correctly
            if ( $Param{Charset} !~ /us-ascii/i ) {
                $Output = '<p><i class="small">'
                    . '$Text{"This message was written in a character set other than your own."}'
                    . '$Text{"If it is not displayed correctly,"} '
                    . '<a href="'
                    . $Self->{Baselink}
                    . "Action=$Param{Action}&TicketID=$Param{TicketID}"
                    . "&ArticleID=$Param{ArticleID}&Subaction=ShowHTMLeMail\" target=\"HTMLeMail\" "
                    . 'onmouseover="window.status=\'$Text{"open it in a new window"}\'; return true;" onmouseout="window.status=\'\';">'
                    . '$Text{"click here"}</a> $Text{"to open it in a new window."}</i></p>';
            }
        }
    }

    # return note string
    return $Output;
}

sub CheckMimeType {
    my ( $Self, %Param ) = @_;

    my $Output = '';
    if ( !$Param{Action} ) {
        $Param{Action} = '$Env{"Action"}';
    }

    # check if it is a text/plain email
    if ( $Param{MimeType} && $Param{MimeType} !~ /text\/plain/i ) {
        $Output = '<p><i class="small">$Text{"This is a"} '
            . $Param{MimeType}
            . ' $Text{"email"}, '
            . '<a href="'
            . $Self->{Baselink}
            . "Action=$Param{Action}&TicketID="
            . "$Param{TicketID}&ArticleID=$Param{ArticleID}&Subaction=ShowHTMLeMail\" "
            . 'target="HTMLeMail" '
            . 'onmouseover="window.status=\'$Text{"open it in a new window"}\'; return true;" onmouseout="window.status=\'\';">'
            . '$Text{"click here"}</a> '
            . '$Text{"to open it in a new window."}</i></p>';
    }

    # just to be compat
    elsif ( $Param{Body} =~ /^<.DOCTYPE html PUBLIC|^<HTML>/i ) {
        $Output = '<p><i class="small">$Text{"This is a"} '
            . $Param{MimeType}
            . ' $Text{"email"}, '
            . '<a href="'
            . $Self->{Baselink}
            . 'Action=$Env{"Action"}&TicketID='
            . "$Param{TicketID}&ArticleID=$Param{ArticleID}&Subaction=ShowHTMLeMail\" "
            . 'target="HTMLeMail" '
            . 'onmouseover="window.status=\'$Text{"open it in a new window"}\'; return true;" onmouseout="window.status=\'\';">'
            . '$Text{"click here"}</a> '
            . '$Text{"to open it in a new window."}</i></p>';
    }

    # return note string
    return $Output;
}

sub ReturnValue {
    my ( $Self, $What ) = @_;

    return $Self->{$What};
}

=item Attachment()

returns browser output to display/download a attachment

    $HTML = $LayoutObject->Attachment(
        Type        => 'inline', # inline|attachment
        Filename    => 'FileName.png',
        ContentType => 'image/png',
        Content     => $Content,
    );

    or

    $HTML = $LayoutObject->Attachment(
        Type        => 'inline', # inline|attachment
        Filename    => 'FileName.png',
        ContentType => 'image/png',
        Content     => $Content,
        NoCache     => 1,
    );

=cut

sub Attachment {
    my ( $Self, %Param ) = @_;

    # check needed objects
    for (qw(Content ContentType)) {
        if ( !defined $Param{$_} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Got no $_!",
            );
            $Self->FatalError();
        }
    }

    # return attachment
    my $Output = 'Content-Disposition: ';
    if ( $Param{Type} ) {
        $Output .= $Param{Type};
        $Output .= '; ';
    }
    else {
        $Output .= $Self->{ConfigObject}->Get('AttachmentDownloadType') || 'attachment';
        $Output .= '; ';
    }

    # clean filename to get no problems with some browsers
    if ( $Param{Filename} ) {

        # detect if IE workaround is used (solution for IE problem with multi byte filename)
        # to solve this kind of problems use the following in dtl for attachment downloads:
        # <a href="$Env{"CGIHandle"}/$LQData{"Filename"}?Action=...">xxx</a>
        my $FilenameInHeader = 1;

        # check if browser is broken
        if ( $Self->{BrowserBreakDispositionHeader} && $ENV{REQUEST_URI} ) {

            # check if IE workaround is used
            if ( $ENV{REQUEST_URI} =~ /\Q$Self->{CGIHandle}\E\/.+?\?Action=/ ) {
                $FilenameInHeader = 0;
            }
        }

        # only deliver filename if needed
        if ($FilenameInHeader) {
            $Output .= " filename=\"$Param{Filename}\"";
        }
    }
    $Output .= "\n";

    # get attachment size
    {
        use bytes;
        $Param{Size} = length $Param{Content};
        no bytes;
    }

    # add no cache headers
    if ( $Param{NoCache} ) {
        $Output .= "Expires: Tue, 1 Jan 1980 12:00:00 GMT\n";
        $Output .= "Cache-Control: no-cache\n";
        $Output .= "Pragma: no-cache\n";
    }
    $Output .= "Content-Length: $Param{Size}\n";

    if ( $Param{Charset} ) {
        $Output .= "Content-Type: $Param{ContentType}; charset=$Param{Charset};\n\n";
    }
    else {
        $Output .= "Content-Type: $Param{ContentType}\n\n";
    }

    # disable utf8 flag, to write binary to output
    $Self->{EncodeObject}->EncodeOutput( \$Output );
    $Self->{EncodeObject}->EncodeOutput( \$Param{Content} );

    # fix for firefox HEAD problem
    if ( !$ENV{REQUEST_METHOD} || $ENV{REQUEST_METHOD} ne 'HEAD' ) {
        $Output .= $Param{Content};
    }

    # reset binmode, don't use utf8
    binmode STDOUT;

    return $Output;
}

=item PageNavBar()

generates a page nav bar

    my %PageNavBar = $LayoutObject->PageNavBar(
        Limit       => 100,         # marks result of TotalHits red if Limit is gerater then AllHits
        WindowSize  => 15,          # max shown pages to click
        StartHit    => 1,           # start to show items
        PageShown   => 15,          # number of shown items a page
        AllHits     => 56,          # number of total hits
        Action      => 'AgentXXX',  # e. g. 'Action=' . $Self->{LayoutObject}->{Action}
        Link        => $Link,       # e. g. 'Subaction=View&'
        AJAXReplace => 'IDElement', # IDElement which should be replaced
    );

    return values of hash

        TotalHits  # total hits
        Result     # shown items e. g. 1-5 or 16-30
        SiteNavBar # html for page nav bar

=cut

sub PageNavBar {
    my ( $Self, %Param ) = @_;

    my $Limit = $Param{Limit} || 0;
    $Param{AllHits}  = 0 if ( !$Param{AllHits} );
    $Param{StartHit} = 0 if ( !$Param{AllHits} );
    my $Pages = int( ( $Param{AllHits} / $Param{PageShown} ) + 0.99999 );
    my $Page  = int( ( $Param{StartHit} / $Param{PageShown} ) + 0.99999 );
    my $WindowSize = $Param{WindowSize} || 15;

    # build Results (1-5 or 16-30)
    if ( $Param{AllHits} >= ( $Param{StartHit} + $Param{PageShown} ) ) {
        $Param{Results} = $Param{StartHit} . "-" . ( $Param{StartHit} + $Param{PageShown} - 1 );
    }
    else {
        $Param{Results} = "$Param{StartHit}-$Param{AllHits}";
    }

    # check total hits
    if ( $Limit == $Param{AllHits} ) {
        $Param{TotalHits} = "<font color=red>$Param{AllHits}</font>";
    }
    else {
        $Param{TotalHits} = $Param{AllHits};
    }

    # build page nav bar
    my $WindowStart = sprintf( "%.0f", ( $Param{StartHit} / $Param{PageShown} ) );
    $WindowStart = int( ( $WindowStart / $WindowSize ) ) + 1;
    $WindowStart = ( $WindowStart * $WindowSize ) - ($WindowSize);
    my $Action = $Param{Action} || '';
    my $Link   = $Param{Link}   || '';
    my $Baselink = "$Self->{Baselink}$Action&$Link";
    my $i        = 0;
    while ( $i <= ( $Pages - 1 ) ) {
        $i++;

        # show normal page 1,2,3,...
        if ( $i <= ( $WindowStart + $WindowSize ) && $i > $WindowStart ) {
            my $BaselinkAll
                = $Baselink
                . "StartWindow=$WindowStart&StartHit="
                . ( ( ( $i - 1 ) * $Param{PageShown} ) + 1 );
            my $AJAXReplace = '';
            if ( $Param{AJAXReplace} ) {
                $AJAXReplace
                    = "onclick=\"AJAXContentUpdate('$Param{AJAXReplace}', '$BaselinkAll'); return false;\" ";
            }
            $Param{SearchNavBar}
                .= " <a name=\"OverviewControl\" href=\"$BaselinkAll\" $AJAXReplace";
            if ( $Page == $i ) {
                $Param{SearchNavBar} .= 'style="text-decoration:none"><b>' . $i . '</b>';
            }
            else {
                $Param{SearchNavBar} .= '>' . $i;
            }
            $Param{SearchNavBar} .= '</a> ';
        }

        # over window ">>" and ">|"
        elsif ( $i > ( $WindowStart + $WindowSize ) ) {
            my $StartWindow     = $WindowStart + $WindowSize + 1;
            my $LastStartWindow = int( $Pages / $WindowSize );
            my $BaselinkAllBack = $Baselink . "StartHit=" . ( $i - 1 ) * $Param{PageShown};
            my $AJAXReplaceBack = '';
            if ( $Param{AJAXReplace} ) {
                $AJAXReplaceBack
                    = "onclick=\"AJAXContentUpdate('$Param{AJAXReplace}', '$BaselinkAllBack'); return false;\" ";
            }
            $Param{SearchNavBar}
                .= "&nbsp;<a href=\"$BaselinkAllBack\" $AJAXReplaceBack>&gt;&gt;</a>&nbsp;";
            my $BaselinkAllNext
                = $Baselink . "StartHit=" . ( ( $Param{PageShown} * ( $Pages - 1 ) ) + 1 );
            my $AJAXReplaceNext = '';
            if ( $Param{AJAXReplace} ) {
                $AJAXReplaceNext
                    = "onclick=\"AJAXContentUpdate('$Param{AJAXReplace}', '$BaselinkAllNext'); return false;\" ";
            }
            $Param{SearchNavBar} .= " <a href=\"$BaselinkAllNext\" $AJAXReplaceNext>&gt;|</a> ";
            $i = 99999999;
        }

        # over window "<<" and "|<"
        elsif ( $i < $WindowStart && ( $i - 1 ) < $Pages ) {
            my $StartWindow     = $WindowStart - $WindowSize - 1;
            my $BaselinkAllBack = $Baselink . "StartHit=1&StartWindow=1";
            my $AJAXReplaceBack = '';
            if ( $Param{AJAXReplace} ) {
                $AJAXReplaceBack
                    = "onclick=\"AJAXContentUpdate('$Param{AJAXReplace}', '$BaselinkAllBack'); return false;\" ";
            }
            $Param{SearchNavBar}
                .= " <a href=\"$BaselinkAllBack\" $AJAXReplaceBack>|&lt;</a>&nbsp;";
            my $BaselinkAllNext
                = $Baselink . "StartHit=" . ( ( $WindowStart - 1 ) * ( $Param{PageShown} ) + 1 );
            my $AJAXReplaceNext = '';
            if ( $Param{AJAXReplace} ) {
                $AJAXReplaceNext
                    = "onclick=\"AJAXContentUpdate('$Param{AJAXReplace}', '$BaselinkAllNext'); return false;\" ";
            }
            $Param{SearchNavBar}
                .= " <a href=\"$BaselinkAllNext\" $AJAXReplaceNext>&lt;&lt;</a>&nbsp;";
            $i = $WindowStart - 1;
        }
    }

    # return data
    return (
        TotalHits  => $Param{TotalHits},
        Result     => $Param{Results},
        SiteNavBar => $Param{SearchNavBar},
        Link       => $Param{Link},
    );
}

sub NavigationBar {
    my ( $Self, %Param ) = @_;

    my $Output = '';
    if ( !$Param{Type} ) {
        $Param{Type} = $Self->{ModuleReg}->{NavBarName} || 'Ticket';
    }

    # run notification modules
    my $FrontendNotifyModuleConfig = $Self->{ConfigObject}->Get('Frontend::NotifyModule');
    if ( ref $FrontendNotifyModuleConfig eq 'HASH' ) {
        my %Jobs = %{$FrontendNotifyModuleConfig};
        for my $Job ( sort keys %Jobs ) {

            # load module
            next if !$Self->{MainObject}->Require( $Jobs{$Job}->{Module} );
            my $Object = $Jobs{$Job}->{Module}->new(
                %{$Self},
                ConfigObject => $Self->{ConfigObject},
                LogObject    => $Self->{LogObject},
                DBObject     => $Self->{DBObject},
                LayoutObject => $Self,
                UserID       => $Self->{UserID},
                Debug        => $Self->{Debug},
            );

            # run module
            $Output .= $Object->Run( %Param, Config => $Jobs{$Job} );
        }
    }

    # create menu items
    my %NavBarModule         = ();
    my $FrontendModuleConfig = $Self->{ConfigObject}->Get('Frontend::Module');

    MODULE:
    for my $Module ( sort keys %{$FrontendModuleConfig} ) {
        my %Hash = %{ $FrontendModuleConfig->{$Module} };
        next MODULE if !$Hash{NavBar} || ref $Hash{NavBar} ne 'ARRAY';

        my @Items = @{ $Hash{NavBar} };
        for my $Item (@Items) {
            if (
                ( $Item->{NavBar} && $Item->{NavBar} eq $Param{Type} )
                || ( $Item->{Type} && $Item->{Type} eq 'Menu' )
                || !$Item->{NavBar}
                )
            {

                # highligt avtive area link
                if (
                    ( $Item->{Type} && $Item->{Type} eq 'Menu' )
                    && ( $Item->{NavBar} && $Item->{NavBar} eq $Param{Type} )
                    )
                {
                    next if !$Self->{ConfigObject}->Get('Frontend::NavBarStyle::ShowSelectedArea');
                    $Item->{ItemAreaCSSSuffix} = 'active';
                }

                # get permissions from module if no permissions are defined for the icon
                if ( !$Item->{GroupRo} && !$Item->{Group} ) {
                    if ( $Hash{GroupRo} ) {
                        $Item->{GroupRo} = $Hash{GroupRo};
                    }
                    if ( $Hash{Group} ) {
                        $Item->{Group} = $Hash{Group};
                    }
                }

                # check shown permission
                my $Shown = 0;
                for my $Permission (qw(GroupRo Group)) {

                    # array access restriction
                    if ( $Item->{$Permission} && ref $Item->{$Permission} eq 'ARRAY' ) {
                        for ( @{ $Item->{$Permission} } ) {
                            my $Key = 'UserIs' . $Permission . '[' . $_ . ']';
                            if ( $Self->{$Key} && $Self->{$Key} eq 'Yes' ) {
                                $Shown = 1;
                            }
                        }
                    }

                    # scalar access restriction
                    elsif ( $Item->{$Permission} ) {
                        my $Key = 'UserIs' . $Permission . '[' . $Item->{$Permission} . ']';
                        if ( $Self->{$Key} && $Self->{$Key} eq 'Yes' ) {
                            $Shown = 1;
                        }
                    }

                    # no access restriction
                    elsif ( !$Item->{GroupRo} && !$Item->{Group} ) {
                        $Shown = 1;
                    }
                }
                next if !$Shown;

                my $Key = ( $Item->{Block} || '' ) . sprintf( "%07d", $Item->{Prio} );
                for ( 1 .. 51 ) {
                    last if !$NavBarModule{$Key};

                    $Item->{Prio}++;
                    $Key = ( $Item->{Block} || '' ) . sprintf( "%07d", $Item->{Prio} );
                }
                $NavBarModule{$Key} = $Item;

            }
        }
    }

    # run menu item modules
    if ( ref $Self->{ConfigObject}->Get('Frontend::NavBarModule') eq 'HASH' ) {
        my %Jobs = %{ $Self->{ConfigObject}->Get('Frontend::NavBarModule') };
        for my $Job ( sort keys %Jobs ) {

            # load module
            next if !$Self->{MainObject}->Require( $Jobs{$Job}->{Module} );
            my $Object = $Jobs{$Job}->{Module}->new(
                %{$Self},
                ConfigObject => $Self->{ConfigObject},
                LogObject    => $Self->{LogObject},
                DBObject     => $Self->{DBObject},
                LayoutObject => $Self,
                UserID       => $Self->{UserID},
                Debug        => $Self->{Debug},
            );

            # run module
            %NavBarModule = ( %NavBarModule, $Object->Run( %Param, Config => $Jobs{$Job} ) );
        }
    }

    my $NavBarType = $Self->{ConfigObject}->Get('Frontend::NavBarStyle') || 'Classic';
    $Self->Block(
        Name => $NavBarType,
        Data => \%Param,
    );
    for ( sort keys %NavBarModule ) {
        next if !%{ $NavBarModule{$_} };
        $Self->Block(
            Name => $NavBarModule{$_}->{Block} || 'Item',
            Data => $NavBarModule{$_},
        );
    }

    # create & return output
    $Output = $Self->Output( TemplateFile => 'AgentNavigationBar', Data => \%Param ) . $Output;
    if ( $Self->{ModuleReg}->{NavBarModule} ) {

        # run navbar modules
        my %Jobs = %{ $Self->{ModuleReg}->{NavBarModule} };

        # load module
        next if !$Self->{MainObject}->Require( $Jobs{Module} );
        my $Object = $Jobs{Module}->new(
            %{$Self},
            ConfigObject => $Self->{ConfigObject},
            LogObject    => $Self->{LogObject},
            DBObject     => $Self->{DBObject},
            LayoutObject => $Self,
            UserID       => $Self->{UserID},
            Debug        => $Self->{Debug},
        );

        # run module
        $Output .= $Object->Run( %Param, Config => \%Jobs );
    }
    return $Output;
}

sub WindowTabStart {
    my ( $Self, %Param ) = @_;

    if ( !$Param{Tab} || ( $Param{Tab} && ref $Param{Tab} ne 'ARRAY' ) ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need Tab as ARRAY ref in WindowTabStart()!',
        );
        $Self->FatalError();
    }

    $Self->Block(
        Name => 'WindowTabStart',
        Data => \%Param,
    );

    my @Tabs = @{ $Param{Tab} };
    my $Size = int( 100 / ( $#Tabs + 1 ) );
    for my $Hash (@Tabs) {
        $Hash->{Size} = $Size;
        if ( $Hash->{Ready} ) {
            $Hash->{Image} = 'ready.png';
        }
        else {
            $Hash->{Image} = 'notready.png';
        }
        $Self->Block(
            Name => 'Tab',
            Data => { %{$Hash}, },
        );
    }
    return $Self->Output( TemplateFile => 'AgentWindowTab', Data => \%Param );
}

sub WindowTabStop {
    my ( $Self, %Param ) = @_;

    $Self->Block(
        Name => 'WindowTabStop',
        Data => \%Param,
    );

    if ( $Param{Layer0Footer} ) {
        for my $Hash ( @{ $Param{Layer0Footer} } ) {
            $Self->Block(
                Name => 'Layer0Footer',
                Data => { %{$Hash}, },
            );
        }
    }
    if ( $Param{Layer1Footer} ) {
        for my $Hash ( @{ $Param{Layer1Footer} } ) {
            $Self->Block(
                Name => 'Layer1Footer',
                Data => { %{$Hash}, },
            );
        }
    }
    return $Self->Output( TemplateFile => 'AgentWindowTab', Data => \%Param );
}

sub TransfromDateSelection {
    my ( $Self, %Param ) = @_;

    my $DateInputStyle = $Self->{ConfigObject}->Get('TimeInputFormat');
    my $Prefix         = $Param{'Prefix'} || '';
    my $Format         = defined( $Param{Format} ) ? $Param{Format} : 'DateInputFormatLong';

    # time zone translation
    if ( $Self->{ConfigObject}->Get('TimeZoneUser') && $Self->{UserTimeZone} ) {
        my $TimeStamp = $Self->{TimeObject}->TimeStamp2SystemTime(
            String => $Param{ $Prefix . 'Year' } . '-'
                . $Param{ $Prefix . 'Month' } . '-'
                . $Param{ $Prefix . 'Day' } . ' '
                . ( $Param{ $Prefix . 'Hour' }   || 0 ) . ':'
                . ( $Param{ $Prefix . 'Minute' } || 0 )
                . ':00',
        );
        $TimeStamp = $TimeStamp - ( $Self->{UserTimeZone} * 3600 );
        (
            $Param{ $Prefix . 'Secunde' },
            $Param{ $Prefix . 'Minute' },
            $Param{ $Prefix . 'Hour' },
            $Param{ $Prefix . 'Day' },
            $Param{ $Prefix . 'Month' },
            $Param{ $Prefix . 'Year' }
        ) = $Self->{UserTimeObject}->SystemTime2Date( SystemTime => $TimeStamp, );
    }
    return %Param;
}

sub BuildDateSelection {
    my ( $Self, %Param ) = @_;

    my $DateInputStyle = $Self->{ConfigObject}->Get('TimeInputFormat');
    my $Prefix         = $Param{Prefix} || '';
    my $DiffTime       = $Param{DiffTime} || 0;
    my $Format         = defined( $Param{Format} ) ? $Param{Format} : 'DateInputFormatLong';
    my $Area           = $Param{Area} || 'Agent';
    my $Optional       = $Param{ $Prefix . 'Optional' } || 0;
    my $Used           = $Param{ $Prefix . 'Used' } || 0;
    my ( $s, $m, $h, $D, $M, $Y ) = $Self->{UserTimeObject}->SystemTime2Date(
        SystemTime => $Self->{UserTimeObject}->SystemTime() + $DiffTime,
    );

    # time zone translation
    if (
        $Self->{ConfigObject}->Get('TimeZoneUser')
        && $Self->{UserTimeZone}
        && $Param{ $Prefix . 'Year' }
        && $Param{ $Prefix . 'Month' }
        && $Param{ $Prefix . 'Day' }
        )
    {
        my $TimeStamp = $Self->{TimeObject}->TimeStamp2SystemTime(
            String => $Param{ $Prefix . 'Year' } . '-'
                . $Param{ $Prefix . 'Month' } . '-'
                . $Param{ $Prefix . 'Day' } . ' '
                . ( $Param{ $Prefix . 'Hour' }   || 0 ) . ':'
                . ( $Param{ $Prefix . 'Minute' } || 0 )
                . ':00',
        );
        $TimeStamp = $TimeStamp + ( $Self->{UserTimeZone} * 3600 );
        (
            $Param{ $Prefix . 'Secunde' },
            $Param{ $Prefix . 'Minute' },
            $Param{ $Prefix . 'Hour' },
            $Param{ $Prefix . 'Day' },
            $Param{ $Prefix . 'Month' },
            $Param{ $Prefix . 'Year' }
        ) = $Self->{UserTimeObject}->SystemTime2Date( SystemTime => $TimeStamp, );
    }

    # year
    if ( $DateInputStyle eq 'Option' ) {
        my %Year = ();
        if ( defined $Param{YearPeriodPast} && defined $Param{YearPeriodFuture} ) {
            for ( $Y - $Param{YearPeriodPast} .. $Y + $Param{YearPeriodFuture} ) {
                $Year{$_} = $_;
            }
        }
        else {
            for ( $Y - 10 .. $Y + 1 + ( $Param{YearDiff} || 0 ) ) {
                $Year{$_} = $_;
            }
        }
        $Param{Year} = $Self->OptionStrgHashRef(
            Name                => $Prefix . 'Year',
            Data                => \%Year,
            SelectedID          => int( $Param{ $Prefix . 'Year' } || $Y ),
            LanguageTranslation => 0,
        );
    }
    else {
        $Param{Year} = "<input id=\"" . $Prefix . "Year\" " . "type=\"text\" name=\""
            . $Prefix
            . "Year\" size=\"4\" maxlength=\"4\" "
            . "value=\""
            . sprintf( "%02d", ( $Param{ $Prefix . 'Year' } || $Y ) ) . "\"/>";
    }

    # month
    if ( $DateInputStyle eq 'Option' ) {
        my %Month = ();
        for ( 1 .. 12 ) {
            my $Tmp = sprintf( "%02d", $_ );
            $Month{$_} = $Tmp;
        }
        $Param{Month} = $Self->OptionStrgHashRef(
            Name                => $Prefix . 'Month',
            Data                => \%Month,
            SelectedID          => int( $Param{ $Prefix . 'Month' } || $M ),
            LanguageTranslation => 0,
        );
    }
    else {
        $Param{Month}
            = "<input type=\"text\" name=\""
            . $Prefix
            . "Month\" id=\""
            . $Prefix
            . "Month\" size=\"2\" maxlength=\"2\" "
            . "value=\""
            . sprintf( "%02d", ( $Param{ $Prefix . 'Month' } || $M ) ) . "\"/>";
    }

    # day
    if ( $DateInputStyle eq 'Option' ) {
        my %Day = ();
        for ( 1 .. 31 ) {
            my $Tmp = sprintf( "%02d", $_ );
            $Day{$_} = $Tmp;
        }
        $Param{Day} = $Self->OptionStrgHashRef(
            Name                => $Prefix . 'Day',
            Data                => \%Day,
            SelectedID          => int( $Param{ $Prefix . 'Day' } || $D ),
            LanguageTranslation => 0,
        );
    }
    else {
        $Param{Day} = "<input type=\"text\" name=\""
            . $Prefix
            . "Day\" id=\"" . $Prefix . "Day\" size=\"2\" maxlength=\"2\" "
            . "value=\""
            . sprintf( "%02d", ( $Param{ $Prefix . 'Day' } || $D ) ) . "\"/>";
    }
    if ( $Format eq 'DateInputFormatLong' ) {

        # hour
        if ( $DateInputStyle eq 'Option' ) {
            my %Hour = ();
            for ( 0 .. 23 ) {
                my $Tmp = sprintf( "%02d", $_ );
                $Hour{$_} = $Tmp;
            }
            $Param{Hour} = $Self->OptionStrgHashRef(
                Name       => $Prefix . 'Hour',
                Data       => \%Hour,
                SelectedID => defined( $Param{ $Prefix . 'Hour' } )
                ? int( $Param{ $Prefix . 'Hour' } )
                : int($h),
                LanguageTranslation => 0,
            );
        }
        else {
            $Param{Hour} = "<input type=\"text\" name=\""
                . $Prefix
                . "Hour\" id=\"" . $Prefix . "Hour\" size=\"2\" maxlength=\"2\" "
                . "value=\""
                . sprintf(
                "%02d",
                ( defined( $Param{ $Prefix . 'Hour' } ) ? int( $Param{ $Prefix . 'Hour' } ) : $h )
                )
                . "\"/>";
        }

        # minute
        if ( $DateInputStyle eq 'Option' ) {
            my %Minute = ();
            for ( 0 .. 59 ) {
                my $Tmp = sprintf( "%02d", $_ );
                $Minute{$_} = $Tmp;
            }
            $Param{Minute} = $Self->OptionStrgHashRef(
                Name       => $Prefix . 'Minute',
                Data       => \%Minute,
                SelectedID => defined( $Param{ $Prefix . 'Minute' } )
                ? int( $Param{ $Prefix . 'Minute' } )
                : int($m),
                LanguageTranslation => 0,
            );
        }
        else {
            $Param{Minute} = "<input type=\"text\" name=\""
                . $Prefix
                . "Minute\" id=\"" . $Prefix . "Minute\" size=\"2\" maxlength=\"2\" "
                . "value=\""
                . sprintf(
                "%02d",
                (
                    defined( $Param{ $Prefix . 'Minute' } )
                    ? int( $Param{ $Prefix . 'Minute' } )
                    : $m
                    )
                ) . "\"/>";
        }
    }
    my $Output;

    # optional checkbox
    if ($Optional) {
        my $Checked = '';
        if ($Used) {
            $Checked = ' checked';
        }
        $Output .= "<input type=\"checkbox\" name=\""
            . $Prefix
            . "Used\" id=\"" . $Prefix . "Used\" value=\"1\""
            . $Checked
            . "/>&nbsp;";
    }

    # date format
    $Output .= $Self->{LanguageObject}->Time(
        Action => 'Return',
        Format => 'DateInputFormat',
        Mode   => 'NotNumeric',
        %Param,
    );

    # show calendar lookup
    if ( $Self->{BrowserJavaScriptSupport} ) {
        if ( $Area eq 'Agent' && $Self->{ConfigObject}->Get('TimeCalendarLookup') ) {

            # loas site preferences
            $Self->Output(
                TemplateFile => 'HeaderSmall',
                Data         => {},
            );
            $Output .= $Self->Output(
                TemplateFile => 'AgentCalendarSmallIcon',
                Data => { Prefix => $Prefix, }
            );
        }
        elsif ( $Area eq 'Customer' && $Self->{ConfigObject}->Get('TimeCalendarLookup') ) {

            # loas site preferences
            $Self->Output(
                TemplateFile => 'CustomerHeaderSmall',
                Data         => {},
            );
            $Output .= $Self->Output(
                TemplateFile => 'CustomerCalendarSmallIcon',
                Data => { Prefix => $Prefix, }
            );
        }
    }

    return $Output;
}

sub CustomerLogin {
    my ( $Self, %Param ) = @_;

    my $Output = '';
    $Param{TitleArea} = ' :: ' . $Self->{LanguageObject}->Get('Login');

    # add cookies if exists
    if ( $Self->{SetCookies} && $Self->{ConfigObject}->Get('SessionUseCookie') ) {
        for ( keys %{ $Self->{SetCookies} } ) {
            $Output .= "Set-Cookie: $Self->{SetCookies}->{$_}\n";
        }
    }

    # get language options
    $Param{Language} = $Self->OptionStrgHashRef(
        Data                => $Self->{ConfigObject}->Get('DefaultUsedLanguages'),
        Name                => 'Lang',
        SelectedID          => $Self->{UserLanguage},
        OnChange            => 'submit()',
        HTMLQuote           => 0,
        LanguageTranslation => 0,
    );

    # get lost password output
    if (
        $Self->{ConfigObject}->Get('CustomerPanelLostPassword')
        && $Self->{ConfigObject}->Get('Customer::AuthModule') eq
        'Kernel::System::CustomerAuth::DB'
        )
    {
        $Self->Block(
            Name => 'LostPassword',
            Data => \%Param,
        );
    }

    # get lost password output
    if (
        $Self->{ConfigObject}->Get('CustomerPanelCreateAccount')
        && $Self->{ConfigObject}->Get('Customer::AuthModule') eq
        'Kernel::System::CustomerAuth::DB'
        )
    {
        $Self->Block(
            Name => 'CreateAccount',
            Data => \%Param,
        );
    }

    # create & return output
    $Output .= $Self->Output( TemplateFile => 'CustomerLogin', Data => \%Param );

    # remove the version tag from the header if configured
    $Self->_DisableBannerCheck( OutputRef => \$Output );

    return $Output;
}

sub CustomerHeader {
    my ( $Self, %Param ) = @_;

    my $Output = '';
    my $Type = $Param{Type} || '';

    # add cookies if exists
    if ( $Self->{SetCookies} && $Self->{ConfigObject}->Get('SessionUseCookie') ) {
        for ( keys %{ $Self->{SetCookies} } ) {
            $Output .= "Set-Cookie: $Self->{SetCookies}->{$_}\n";
        }
    }

    # area and title
    if (
        !$Param{Area}
        && $Self->{ConfigObject}->Get('CustomerFrontend::Module')->{ $Self->{Action} }
        )
    {
        $Param{Area} = $Self->{ConfigObject}->Get('CustomerFrontend::Module')->{ $Self->{Action} }
            ->{NavBarName} || '';
    }
    if (
        !$Param{Title}
        && $Self->{ConfigObject}->Get('CustomerFrontend::Module')->{ $Self->{Action} }
        )
    {
        $Param{Title}
            = $Self->{ConfigObject}->Get('CustomerFrontend::Module')->{ $Self->{Action} }->{Title}
            || '';
    }
    if (
        !$Param{Area}
        && $Self->{ConfigObject}->Get('PublicFrontend::Module')->{ $Self->{Action} }
        )
    {
        $Param{Area} = $Self->{ConfigObject}->Get('PublicFrontend::Module')->{ $Self->{Action} }
            ->{NavBarName} || '';
    }
    if (
        !$Param{Title}
        && $Self->{ConfigObject}->Get('PublicFrontend::Module')->{ $Self->{Action} }
        )
    {
        $Param{Title}
            = $Self->{ConfigObject}->Get('PublicFrontend::Module')->{ $Self->{Action} }->{Title}
            || '';
    }
    for my $Word (qw(Area Title Value)) {
        if ( $Param{$Word} ) {
            $Param{TitleArea} .= ' :: ' . $Self->{LanguageObject}->Get( $Param{$Word} );
        }
    }

    # run header meta modules
    my $HeaderMetaModule = $Self->{ConfigObject}->Get('CustomerFrontend::HeaderMetaModule');
    if ( ref $HeaderMetaModule eq 'HASH' ) {
        my %Jobs = %{$HeaderMetaModule};
        for my $Job ( sort keys %Jobs ) {

            # load and run module
            next if !$Self->{MainObject}->Require( $Jobs{$Job}->{Module} );
            my $Object = $Jobs{$Job}->{Module}->new( %{$Self}, LayoutObject => $Self );
            next if !$Object;
            $Object->Run( %Param, Config => $Jobs{$Job} );
        }
    }

    # create & return output
    $Output .= $Self->Output( TemplateFile => "CustomerHeader$Type", Data => \%Param );

    # remove the version tag from the header if configured
    $Self->_DisableBannerCheck( OutputRef => \$Output );

    return $Output;
}

sub CustomerFooter {
    my ( $Self, %Param ) = @_;

    my $Type = $Param{Type} || '';

    # unless explicitly specified, we set the footer width to the defaults, which are:
    # 800 pixel for the standard footer
    # 100% for any others (small)
    if ( !$Param{Width} ) {
        if ( $Type eq '' ) {
            $Param{Width} = '800';
        }
        else {
            $Param{Width} = '100%';
        }
    }

    # create & return output
    return $Self->Output( TemplateFile => "CustomerFooter$Type", Data => \%Param );
}

sub CustomerFatalError {
    my ( $Self, %Param ) = @_;

    if ( $Param{Message} ) {
        $Self->{LogObject}->Log(
            Caller   => 1,
            Priority => 'error',
            Message  => $Param{Message},
        );
    }
    my $Output = $Self->CustomerHeader( Area => 'Frontend', Title => 'Fatal Error' );
    $Output .= $Self->Error(%Param);
    $Output .= $Self->CustomerFooter();
    $Self->Print( Output => \$Output );
    exit;
}

sub CustomerNavigationBar {
    my ( $Self, %Param ) = @_;

    # create menu items
    my %NavBarModule         = ();
    my $FrontendModuleConfig = $Self->{ConfigObject}->Get('CustomerFrontend::Module');
    for my $Module ( sort keys %{$FrontendModuleConfig} ) {
        my %Hash = %{ $FrontendModuleConfig->{$Module} };
        if ( $Hash{NavBar} && ref $Hash{NavBar} eq 'ARRAY' ) {
            my @Items = @{ $Hash{NavBar} };
            for my $Item (@Items) {
                for ( 1 .. 51 ) {
                    if ( $NavBarModule{ sprintf( "%07d", $Item->{Prio} ) } ) {
                        $Item->{Prio}++;
                    }
                    if ( !$NavBarModule{ sprintf( "%07d", $Item->{Prio} ) } ) {
                        last;
                    }
                }
                $NavBarModule{ sprintf( "%07d", $Item->{Prio} ) } = $Item;
            }
        }
    }

    # run menu item modules
    if ( ref $Self->{ConfigObject}->Get('CustomerFrontend::NavBarModule') eq 'HASH' ) {
        my %Jobs = %{ $Self->{ConfigObject}->Get('CustomerFrontend::NavBarModule') };
        for my $Job ( sort keys %Jobs ) {

            # load module
            if ( !$Self->{MainObject}->Require( $Jobs{$Job}->{Module} ) ) {
                $Self->FatalError();
            }
            my $Object = $Jobs{$Job}->{Module}->new(
                %{$Self},
                ConfigObject => $Self->{ConfigObject},
                LogObject    => $Self->{LogObject},
                DBObject     => $Self->{DBObject},
                LayoutObject => $Self,
                UserID       => $Self->{UserID},
                Debug        => $Self->{Debug},
            );

            # run module
            %NavBarModule = ( %NavBarModule, $Object->Run( %Param, Config => $Jobs{$Job} ) );
        }
    }

    for ( sort keys %NavBarModule ) {
        next if !%{ $NavBarModule{$_} };
        $Self->Block(
            Name => $NavBarModule{$_}->{Block} || 'Item',
            Data => $NavBarModule{$_},
        );
    }

    # run notification modules
    my $FrontendNotifyModuleConfig = $Self->{ConfigObject}->Get('CustomerFrontend::NotifyModule');
    if ( ref $FrontendNotifyModuleConfig eq 'HASH' ) {
        my %Jobs = %{$FrontendNotifyModuleConfig};
        for my $Job ( sort keys %Jobs ) {

            # log try of load module
            if ( $Self->{Debug} > 1 ) {
                $Self->{LogObject}->Log(
                    Priority => 'debug',
                    Message  => "Try to load module: $Jobs{$Job}->{Module}!",
                );
            }
            if ( !$Self->{MainObject}->Require( $Jobs{$Job}->{Module} ) ) {
                $Self->{LogObject}->Log(
                    Priority => 'error',
                    Message  => "Can't load module $Jobs{$Job}->{Module}!",
                );
            }
            my $Object = $Jobs{$Job}->{Module}->new(
                ConfigObject   => $Self->{ConfigObject},
                LogObject      => $Self->{LogObject},
                MainObject     => $Self->{MainObject},
                DBObject       => $Self->{DBObject},
                TimeObject     => $Self->{TimeObject},
                UserTimeObject => $Self->{UserTimeObject},
                LayoutObject   => $Self,
                EncodeObject   => $Self->{EncodeObject},
                UserID         => $Self->{UserID},
                Debug          => $Self->{Debug},
            );

            # log loaded module
            if ( $Self->{Debug} > 1 ) {
                $Self->{LogObject}->Log(
                    Priority => 'debug',
                    Message  => "Module: $Jobs{$Job}->{Module} loaded!",
                );
            }

            # run module
            $Param{Notification} .= $Object->Run( %Param, Config => $Jobs{$Job} );
        }
    }

    # create the customer user login info (usually at the right side of the navigation bar)
    if ( !$Self->{UserLoginIdentifier} ) {
        $Param{UserLoginIdentifier} = $Self->{UserEmail} ne $Self->{UserCustomerID}
            ?
            "( $Self->{UserEmail} / $Self->{UserCustomerID} )"
            : $Self->{UserEmail};
    }
    else {
        $Param{UserLoginIdentifier} = $Self->{UserLoginIdentifier};
    }

    # create & return output
    return $Self->Output( TemplateFile => 'CustomerNavigationBar', Data => \%Param );
}

sub CustomerError {
    my ( $Self, %Param ) = @_;

    # get backend error messages
    for (qw(Message Traceback)) {
        $Param{ 'Backend' . $_ } = $Self->{LogObject}->GetLogEntry(
            Type => 'Error',
            What => $_
        ) || '';
        $Param{ 'Backend' . $_ } = $Self->Ascii2Html(
            Text           => $Param{ 'Backend' . $_ },
            HTMLResultMode => 1,
        );
    }
    if ( !$Param{BackendMessage} && !$Param{BackendTraceback} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message => $Param{Message} || '?',
        );
        for (qw(Message Traceback)) {
            $Param{ 'Backend' . $_ } = $Self->{LogObject}->GetLogEntry(
                Type => 'Error',
                What => $_
            ) || '';
            $Param{ 'Backend' . $_ } = $Self->Ascii2Html(
                Text           => $Param{ 'Backend' . $_ },
                HTMLResultMode => 1,
            );
        }
    }

    if ( !$Param{Message} ) {
        $Param{Message} = $Param{BackendMessage};
    }

    # create & return output
    return $Self->Output( TemplateFile => 'CustomerError', Data => \%Param );
}

sub CustomerWarning {
    my ( $Self, %Param ) = @_;

    # get backend error messages
    $Param{BackendMessage} = $Self->{LogObject}->GetLogEntry(
        Type => 'Notice',
        What => 'Message',
        )
        || $Self->{LogObject}->GetLogEntry(
        Type => 'Error',
        What => 'Message',
        ) || '';
    $Param{BackendMessage} = $Self->Ascii2Html(
        Text           => $Param{BackendMessage},
        HTMLResultMode => 1,
    );

    if ( !$Param{Message} ) {
        $Param{Message} = $Param{BackendMessage};
    }

    # create & return output
    return $Self->Output( TemplateFile => 'CustomerWarning', Data => \%Param );
}

sub CustomerNoPermission {
    my ( $Self, %Param ) = @_;

    my $WithHeader = $Param{WithHeader} || 'yes';
    $Param{Message} ||= 'No Permission!';

    # create output
    my $Output = $Self->CustomerHeader( Title => 'No Permission' ) if ( $WithHeader eq 'yes' );
    $Output .= $Self->Output( TemplateFile => 'NoPermission', Data => \%Param );
    $Output .= $Self->CustomerFooter() if ( $WithHeader eq 'yes' );

    # return output
    return $Output;
}

sub _DisableBannerCheck {
    my ( $Self, %Param ) = @_;

    return 1 if !$Self->{ConfigObject}->Get('Secure::DisableBanner');
    return   if !$Param{OutputRef};

    # remove the version tag from the header
    ${ $Param{OutputRef} } =~ s{
                ^ X-Powered-By: .+? Open \s Ticket \s Request \s System \s \(http .+? \)$ \n
            }{}smx;

    return 1
}

=item Ascii2RichText()

converts text to rich text

    my $HTMLString = $LayoutObject->Ascii2RichText(
        String => $TextString,
    );

=cut

sub Ascii2RichText {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(String)) {
        if ( !defined $Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # ascii 2 html
    $Param{String} = $Self->{HTMLUtilsObject}->ToHTML(
        String => $Param{String},
    );

    return $Param{String};
}

=item RichText2Ascii()

converts text to rich text

    my $TextString = $LayoutObject->RichText2Ascii(
        String => $HTMLString,
    );

=cut

sub RichText2Ascii {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(String)) {
        if ( !defined $Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # ascii 2 html
    $Param{String} = $Self->{HTMLUtilsObject}->ToAscii(
        String => $Param{String},
    );

    return $Param{String};
}

=item RichTextDocumentComplete()

1) add html, body, ... tags to be a valid html document
2) replace links of inline content e. g. images

    $HTMLBody = $LayoutObject->RichTextDocumentComplete(
        String => $HTMLBody,
    );

=cut

sub RichTextDocumentComplete {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(String)) {
        if ( !defined $Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # replace image link with content id for uploaded images
    my $StringRef = $Self->_RichTextReplaceLinkOfInlineContent(
        String => \$Param{String},
    );

    # verify html document
    $Param{String} = $Self->{HTMLUtilsObject}->DocumentComplete(
        String  => ${$StringRef},
        Charset => $Self->{UserCharset},
    );

    # do correct direction
    if ( $Self->{TextDirection} ) {
        $Param{String} =~ s/<body/<body dir="$Self->{TextDirection}"/i;
    }

    return $Param{String};
}

#=item _RichTextReplaceLinkOfInlineContent()
#
#replace links of inline content e. g. images
#
#
#    $HTMLBodyStringRef = $LayoutObject->_RichTextReplaceLinkOfInlineContent(
#        String => $HTMLBodyStringRef,
#    );
#
#=cut

sub _RichTextReplaceLinkOfInlineContent {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(String)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # replace image link with content id for uploaded images
    ${ $Param{String} } =~ s{
        (<img.+?src=("|')).+?ContentID=(.+?)("|')(.*?>)
    }
    {
        $1 . 'cid:' . $3 . $4 . $5;
    }esgxi;

    return $Param{String};
}

=item RichTextDocumentCleanup()

1)  replace MS Word 12 <p|div> with class "MsoNormal" by using <br/> because
    it's not used as <p><div> (margin:0cm; margin-bottom:.0001pt;)

2)  replace <blockquote> by using
    "<div style="border:none;border-left:solid blue 1.5pt;padding:0cm 0cm 0cm 4.0pt" type="cite">"
    because of cross mail client and browser compatability

    $HTMLBody = $LayoutObject->RichTextDocumentCleanup(
        String => $HTMLBody,
    );

=cut

sub RichTextDocumentCleanup {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(String)) {
        if ( !defined $Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    $Param{String} = $Self->{HTMLUtilsObject}->DocumentStyleCleanup(
        String => $Param{String},
    );

    return $Param{String};
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (http://otrs.org/).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see http://www.gnu.org/licenses/agpl.txt.

=head1 VERSION

$Revision: 1.176.2.17 $ $Date: 2010/02/03 09:31:53 $

=cut

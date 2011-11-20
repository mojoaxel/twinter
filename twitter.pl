#!/bin/perl
# ----------------------------------------------------------------------------
# Alexander Wunschik aka. delphiN wrote this file.
# As long as you retain this notice you can do whatever you want with this
# stuff. If you think this stuff is worth it, you can flattr me here:
# https://flattr.com/thing/373125/Twinter
# ----------------------------------------------------------------------------
use strict;
use warnings;

use XML::RSS;
use XML::RSS::TimingBot;
use XML::RSS::Parser::Lite;
use LWP::Simple;
use URI::Escape;

use lib "/home/twinter/POSprinter";
use TCP2000;

my $STYLE_NONE = 0x0000;
my $STYLE_BOLD = 0x0001;
my $STYLE_UNDERLINED = 0x0002;
my $STYLE_OVERLINED = 0x0004;
my $STYLE_INVERTED = 0x0008;

my $ALIGN_LEFT = 0x30;
my $ALIGN_CENTER = 0x31;
my $ALIGN_RIGHT = 0x32;

my $tcp2k = new TCP2000();

#$ENV{'TIMINGBOTPATH'} = '.';

#my $hash = "%23CCCamp11"; 
my $hash = "%23Piraten";
#my $hash = "wunschik";

###### CHANGE url.txt  !!!!!!!!!
my $url = qq("http://search.twitter.com/search.rss?q=$hash&result_type=recent&show_user=true");
#my $url = 'http://twitter.com/statuses/user_timeline/16351337.rss';
#my $url = 'http://www.soup.io/notifications/ca309cbd4f2d4657f4b6eb0b60221c7e.rss';

#----------------------------------------------------------------
sub init_printer {
	$tcp2k->init();
	$tcp2k->set_chartable(0);
	$tcp2k->set_charset(0);
	$tcp2k->set_char_spacing(1);
	$tcp2k->set_line_spacing("4mm");
}

#----------------------------------------------------------------
sub clean_text {
        my $text = shift;
	$text =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;

        # Whitespaces am Anfang und Ende wegfressen
        $text =~ s/^\s*//g;
        $text =~ s/\s*$//g;

	$text =~ s/\n//ig;
	
        # HTML-Zeilenumbruch behandeln
        $text =~ s/&lt;br&gt;/\n/g;

        # Style: Bold
        $text =~ s/&lt;b&gt;/\x1B\x45/g;
        $text =~ s/&lt;\/b&gt;/\x1B\x46/g;

	# highlight mentions
	$text =~ s/(@.*? )/\x1B\x45$1\x1B\x46/g;
	
	# author
	$text =~ s/^(.*?): /\x1B\x45\x1B\x57\x01$1\n\x1B\x57\x00\x1B\x46/g;
	
	$text =~ s/(http:\/\/.*? )/\x1B\x2D\x01$1\x1B\x2D\x00/g;
	$text =~ s/(http:\/\/.*?)$/\x1B\x2D\x01$1\x1B\x2D\x00/g;

	$text =~ s/&lt;\/em&gt//ig;

        #HTML Links
        $text =~ s/ class=".*?"//ig;
        $text =~ s/ title=".*?"//ig;
        $text =~ s/&lt;a href="(.*?)"&gt;(.*?)&lt;\/a&gt;/$2/ig;
        #$text =~ s/&lt;a href="(.*?)" class=".*?" &gt;(.*?)&lt;\/a&gt;/$1/ig;
        #$text =~ s/&lt;a href="(.*?)" title=".*?" class=".*?" \/a&gt(.*?)&lt;/$2/ig;

        #Alle anderen HTML Tags entfernen
        $text =~ s/&lt;.*&gt;//g;

        # Sonderzeichen umwandeln
        $text =~ s/&amp;#34;/\"/g; # Anführungszeichen
        $text =~ s/&amp;#39;/\'/g; # Aprostroph
        $text =~ s/´/\'/g; # Aprostroph

        # Style: Bold
        $text =~ s/&lt;b&gt;/\x1B\x45/g;
        $text =~ s/&lt;\/b&gt;/\x1B\x46/g;

        #Alle anderen HTML Tags entfernen
        #$text =~ s/&lt;.*&gt;//g;
	$text =~ s/&lt;em&gt;//g;

        # Sonderzeichen umwandeln
        $text =~ s/&amp;#34;/\"/g; # Anführungszeichen
        $text =~ s/&amp;#39;/\'/g; # Aprostroph
        $text =~ s/´/\'/g; # Aprostroph

        # Deutsche Sonderzeichen        
        $text =~ s/&#xe4;/\xCD/g; #ä
        $text =~ s/Ä/\xA0/g;
        $text =~ s/ö/\xB9/g;
        $text =~ s/Ö/\xA1/g;
        $text =~ s/&#xfc;/\xBE/g; #ü
        $text =~ s/Ü/\xA2/g;
        $text =~ s/ß/\xA3/g;
        $text =~ s/\?/\x3F/g;

        return $text;
}

#----------------------------------------------------------------
sub  loop { 
	open FILE, "<url.txt";
	my @lines = <FILE>;
	my $oldUrl = $lines[0];
	if ( length($oldUrl) > 0 ) { $url = $oldUrl };
	close FILE;

	my $data = get( $url );
	my $rss = XML::RSS->new();

	if (!$data) { die "data could not be read" };

	#stupid XML::RSS can not handle tags with nontext charecters
	$data =~ s/twitter:refresh_url/twitter_refresh_url/ig;
	$data =~ s/openSearch:itemsPerPage/openSearch_itemsPerPage/ig;

	$rss->parse( $data );
	
	#print $data."\n\n";

	my $channel = $rss->{channel};

	my $itemcount = $channel->{openSearch_itemsPerPage};
	if (!$itemcount) {
		print "no new tweets yet :-(\n";
		goto NO_TWEETS;
	}

	$url = $channel->{twitter_refresh_url};
	$url =~ s/&amp;/&/ig;
	$url = $url."&rpp=15&result_type=recent&show_user=true";

	print("Channel: ".$channel->{title}."\n");
        print("url: ".$url."\n");
	print("pubDate: ".$channel->{pubDate}."\n");
	print("itemcount: ".$itemcount."\n");

	$tcp2k->clean_buffer();

	if (rand(10)<1) {
		$tcp2k->set_text_size(3);
		$tcp2k->set_style( $STYLE_BOLD );
		$tcp2k->print_text( $hash );	

		$tcp2k->set_text_size(0);
		$tcp2k->set_char_width(0);
		$tcp2k->set_style( $STYLE_NONE );
		$tcp2k->print_text( "hacked together in perl by" );
		$tcp2k->set_style( $STYLE_BOLD );
		$tcp2k->print_text( 'delphiN, @wunschik, delphiN.soup.io' ); 
		
		#$tcp2k->set_char_spacing(7);
		#$tcp2k->set_style( $STYLE_UNDERLINED );
		#$tcp2k->print_text( "http://twinter.wunschik.it\n" );
		#$tcp2k->print_line( );	
		
		$tcp2k->print_line( );
		#$tcp2k->print_text( "\n" );
	}	

	$tcp2k->set_text_size(0);
	$tcp2k->set_char_width(0);
	$tcp2k->set_style( $STYLE_NONE );

	$tcp2k->set_char_width(0);
	$tcp2k->set_text_size(0);
	$tcp2k->set_char_spacing(0);
        $tcp2k->set_style( $STYLE_NONE );
        $tcp2k->set_alignment($ALIGN_CENTER);


	for my $i (@{$rss->{items}}) {
		my $item = $i;		
		
		my $text = $item->{title};
		my $pubDate = $item->{pubDate};
		#$pubDate =~ s/(.*)\+.*/$1/ig;
		#$pubDate =~ s/\s?, \d? \s? (\d?):(\d?):(\d?) /$1:$2:$3/ig;
		my $author = $item->{author};	
		$author =~ s/^.*\((.*)\)/$1/ig;

		$text = clean_text($text);

		print "\n..............................................................................................\n";		
		print "PUBDATE: ".$pubDate."\n";
		print "AUTHOR: ".$author."\n";
		print "TITLE: ".$text."\n";

		$tcp2k->print_text($pubDate);		
		$tcp2k->print_text( $text );

		$tcp2k->set_char_width(0);
		$tcp2k->set_text_size(0);
		$tcp2k->set_char_spacing(0);
		$tcp2k->set_style( $STYLE_NONE );
		$tcp2k->set_alignment($ALIGN_CENTER);
		$tcp2k->print_line( );
		#$tcp2k->cut_paper();
	}
	$tcp2k->flush();

	open FILE, ">url.txt";
	print FILE $url;
	close FILE;

NO_TWEETS:
	#no new tweets
}

init_printer();
while (1) {
	loop();
	sleep(60);
}

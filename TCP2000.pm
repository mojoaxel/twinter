# ----------------------------------------------------------------------------
# Alexander Wunschik aka. delphiN wrote this file.
# As long as you retain this notice you can do whatever you want with this
# stuff. If you think this stuff is worth it, you can flattr me here:
# https://flattr.com/thing/373125/Twinter
# ----------------------------------------------------------------------------
package TCP2000;
$VERSION = '0.2';

use Printer;

my $STYLE_NONE = 0x0000;
my $STYLE_BOLD = 0x0001;
my $STYLE_UNDERLINED = 0x0002;
my $STYLE_OVERLINED = 0x0004;
my $STYLE_INVERTED = 0x0008;

my $ALIGN_LEFT = 0x30;
my $ALIGN_CENTER = 0x31;
my $ALIGN_RIGHT = 0x32;

my $LINE_LENGTH = 44;

###################################################################

sub error {
	my $msg = shift;
	print $msg;
}

sub trace {
	my $msg = shift;
	#print $msg;
}

############################################################################
my $prn;
my $sendBuffer;

$prn = new Printer( 'linux' => 'lpr' );
$prn->print_command(
	'linux' => {
		'type'    => 'pipe',
		'command' => 'lpr'
	}
);
#my %available_printers = $prn->list_printers;
#$prn->use_default;

############################################################################
sub new {
	# constructor
	my $type = shift;
	my %params = @_;
	my $self = {};
	return bless $self, $type;
}

############################################################################
sub clear_buffer {
	$sendBuffer = "";
}

############################################################################
sub print {
	my ($self, $data) = @_;
	$sendBuffer = $sendBuffer.$data;
}

############################################################################
sub print_text {
	my ($self, $data) = @_;
	my $line = "";
	
	$data =~ s/\n/\n\xE8/g;
	@words =  split(/\s/, $data);
	
	foreach (@words) {
		my $word = $_;
		$word =~ s/\xE8/\x0A/g;
		
		trace "WORD: ".$word."\n";
		trace "LENGTH: ".length($line." ".$word)."\n";
		
		# Auf Zeilenlänge von 44+LF beschneiden. Bei Ist ein LF enthalten dann neue Zeile beginnen
		if ($word eq "\n") {
			$sendBuffer = $sendBuffer.$line.chr(0x0A);
			$line = "";
		} elsif (length($line.$word." ") <= $LINE_LENGTH) {
			$line = $line.$word." ";
		} elsif (length($line.$word) == $LINE_LENGTH) {
			$line = $line.$word;
			$sendBuffer = $sendBuffer.$line;
			$line = "";
		} else {
			$sendBuffer = $sendBuffer.$line.chr(0x0A);
			$line = $word." ";
		}	
		trace "LINE: ".$line."\n------------------------------------------------\n";
	}
	$sendBuffer = $sendBuffer.$line."\n";
}

############################################################################
sub init {
	my ($self) = @_;
	#reset printer buffer
	$self->print( chr(0x1B).chr(0x40) );
}
	
############################################################################
sub set_chartable {
	my ($self, $arg) = @_;
	#TODO wertebereich abfragen 0x00-0x0A, 0x30-0x39 & 0x41
	$self->print( chr(0x1B).chr(0x1D).chr(0x74).$arg );
}

############################################################################
sub set_charset {
	my ($self, $arg) = @_;
	#TODO wertebereich abfragen 0x00-0x0C, 0x30-0x39 & 0x41-0x43
	$self->print( chr(0x1B).chr(0x52).$arg );
}

############################################################################
sub set_char_spacing {
	my ($self,$arg) = @_;
	#TODO Wertebereich abfragen 0x01-0x0F, 0x31-0x39 & 0x41-0x46 
	$self->print( chr(0x1B).chr(0x20).$arg );
}

############################################################################
sub set_line_spacing {
	my ($self, $arg) = @_;
	#TODO Wertebereich abfragen 3-4
	if ($arg eq "3mm") {
		$self->print( chr(0x1B).chr(0x30) );
	} elsif ($arg eq "4mm") {
		$self->print( chr(0x1B).chr(0x7A).chr(0x01) );
	} else {
		error("line spacing %arg is not allowed. Please choose between \"3mm\" or \"4mm\".\n");
	}
}

############################################################################
sub set_style {
	my ($self, $style) = @_;
		
	trace "Style: ";
	
	if ($style & $STYLE_BOLD) {
		trace "<BOLD> ";
		$self->print( chr(0x1B).chr(0x45) );
	} else {
		trace "BOLD ";
		$self->print( chr(0x1B).chr(0x46) );
	}
	
	if ($style & $STYLE_UNDERLINED) {
		trace "<UNDERLINED> ";
		$self->print( chr(0x1B).chr(0x2D).chr(0x01) );
	} else {
		trace "UNDERLINED ";
		$self->print( chr(0x1B).chr(0x2D).chr(0x00) );
	}
	
	if ($style & $STYLE_OVERLINED) {
		trace "<OVERLINED> ";
		$self->print( chr(0x1B).chr(0x5F).chr(0x01) );
	} else {
		trace "OVERLINED ";
		$self->print( chr(0x1B).chr(0x5F).chr(0x00) );
	}
	
	if ($style & $STYLE_INVERTED) {
		trace "<INVERTED> ";
		$self->print( chr(0x1B).chr(0x34) )
	} else {
		trace "INVERTED ";
		$self->print( chr(0x1B).chr(0x35) );
	}
	
	print "\n";
}

############################################################################
sub set_char_width {
	my ($self, $arg) = @_;
	#TODO wertebereich überprüfen 0x00-0x05, 0x30-0x35
	$self->print( chr(0x1B).chr(0x57).$arg );
}

############################################################################
sub set_char_hight {
	my ($self, $arg) = @_;
	#TODO wertebereich überprüfen 0x00-0x05, 0x30-0x35
	$self->print( chr(0x1B).chr(0x68).$arg );
}

############################################################################
sub set_text_size {
	my ($self, $size) = @_;
	$self->set_char_width($size);
	$self->set_char_hight($size); 
}

############################################################################
sub set_alignment {
	my ($self, $alignment) = @_;
	#TODO Wertebereich überprüfen
	if ($alignment == $ALIGN_LEFT) {
		trace "Alignment: LEFT\n";
		$self->print( chr(0x1B).chr(0x1D).chr(0x61).chr(0x30) );
	} elsif ($alignment == $ALIGN_CENTER) {
		trace "Alignment: CENTER\n";
		$self->print( chr(0x1B).chr(0x1D).chr(0x61).chr(0x31) );
	} elsif ($alignment == $ALIGN_RIGHT) {
		trace "Alignment: RIGHT\n";
		$self->print( chr(0x1B).chr(0x1D).chr(0x61).chr(0x32) );
	} else {
		error("invalid alignment $alignment");
	}
}

############################################################################
sub cut_paper {
	my ($self) = @_;
	$self->print( chr(0x0C) );
}

############################################################################
sub print_testpage {
	my ($self) = @_;
	$self->print( chr(0x1B).chr(0x3F).chr(0x0A).chr(0x00) );
}

############################################################################
sub print_line {
	my ($self) = @_;
	
	for (my $i = 0; $i < $LINE_LENGTH+4; $i++ ) {
		$self->print( "_" );
	}
}

############################################################################
sub reset_style {
	my ($self) = @_;
	
	$self->set_style( $STYLE_NONE );
	$self->set_alignment($ALIGN_LEFT);
	$self->set_text_size(0);
	$self->set_char_spacing(1);
	$self->set_line_spacing("4mm");
	
   	$self->print("x123456789x123456789x123456789x123456789x123\n");
   #$self->print("____________________________________________\n");
	$self->print("--------------------------------------------\n");
}

############################################################################
sub set_mirrored {
	my ($self, $arg) = @_;

	#TODO wertebereich festlegen und überprüfen
	if ($arg == 1) {
		$self->print( chr(0x0F) );
	} else {
		$self->print( chr(0x12) );
	}
}

############################################################################
sub flush {
	my ($self) = @_;
	$prn->print( $sendBuffer );
	$sendbuffer = "";
}

############################################################################
__END__

# documentation

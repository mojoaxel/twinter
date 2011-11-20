#!perl
# ----------------------------------------------------------------------------
# Alexander Wunschik aka. delphiN wrote this file.
# As long as you retain this notice you can do whatever you want with this
# stuff. If you think this stuff is worth it, you can flattr me here:
# https://flattr.com/thing/373125/Twinter
# ----------------------------------------------------------------------------
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

#------------------------------------------------------------------------------
$tcp2k->init();
$tcp2k->set_chartable(0);
$tcp2k->set_charset(2);
$tcp2k->set_char_spacing(1);
$tcp2k->set_line_spacing("4mm");

$tcp2k->reset_style();
#------------------------------------------------------------------------------

$tcp2k->set_style( $STYLE_NONE );
$tcp2k->print("Style: NONE\n");

$tcp2k->set_style( $STYLE_BOLD );
$tcp2k->print("Style: BOLD\n");

$tcp2k->set_style( $STYLE_UNDERLINED );
$tcp2k->print("Style: UNDERLINED \n");

$tcp2k->set_style( $STYLE_OVERLINED );
$tcp2k->print("Style: OVERLINED\n");

$tcp2k->set_style( $STYLE_INVERTED );
$tcp2k->print("Style: INVERTED\n");

$tcp2k->set_style( $STYLE_BOLD | $STYLE_UNDERLINED );
$tcp2k->print("Style: BOLD + UNDERLINED\n");

$tcp2k->reset_style();
#------------------------------------------------------------------------------

$tcp2k->set_alignment($ALIGN_LEFT);
$tcp2k->print("ALIGN_LEFT\n");

$tcp2k->set_alignment($ALIGN_CENTER);
$tcp2k->print("ALIGN_CENTER\n");

$tcp2k->set_alignment($ALIGN_RIGHT);
$tcp2k->print("ALIGN_RIGHT\n");

$tcp2k->reset_style();
#------------------------------------------------------------------------------

$tcp2k->set_mirrored(1);
$tcp2k->print("mirrored line 1\n");
$tcp2k->print("mirrored line 2\n");

$tcp2k->set_mirrored(0);
$tcp2k->print("normal line 3\n");
$tcp2k->print("normal line 4\n");

$tcp2k->reset_style();
#------------------------------------------------------------------------------

$tcp2k->set_line_spacing("3mm");
$tcp2k->print("1 - line spacing: 3 mm\n");
$tcp2k->print("2 - line spacing: 3 mm\n");
$tcp2k->print("3 - line spacing: 3 mm\n");
$tcp2k->print("4 - line spacing: 3 mm\n");
$tcp2k->print("5 - line spacing: 3 mm\n");

$tcp2k->reset_style();
#------------------------------------------------------------------------------

$tcp2k->set_line_spacing("4mm");
$tcp2k->print("1 - line spacing: 4 mm\n");
$tcp2k->print("2 - line spacing: 4 mm\n");
$tcp2k->print("3 - line spacing: 4 mm\n");
$tcp2k->print("4 - line spacing: 4 mm\n");
$tcp2k->print("5 - line spacing: 4 mm\n");

$tcp2k->reset_style();
#------------------------------------------------------------------------------

for (my $space = 0x00; $space <= 0x0F; $space++ ) {
	$tcp2k->set_char_spacing($space);
	$tcp2k->print("char spacing: $space\n");
}

$tcp2k->reset_style();
#-----------------------------------------------------------------------------

for (my $width = 0; $width <= 5; $width++ ) {
	$tcp2k->set_char_width($width);
	$tcp2k->print("WIDTH: $width\n");
}

$tcp2k->reset_style();
#------------------------------------------------------------------------------

for (my $hight = 0; $hight <= 5; $hight++ ) {
	$tcp2k->set_char_hight($hight);
	$tcp2k->print("HIGHT: $hight\n");
}

$tcp2k->reset_style();
#------------------------------------------------------------------------------

for (my $size = 0; $size <= 5; $size++ ) {
	$tcp2k->set_text_size($size);
	$tcp2k->print("SIZE: $size\n");
}

$tcp2k->reset_style();
#------------------------------------------------------------------------------
$tcp2k->print("cutting...");
$tcp2k->cut_paper();
$tcp2k->flush();


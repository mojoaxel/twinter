#!perl
# ----------------------------------------------------------------------------
# Alexander Wunschik aka. delphiN wrote this file.
# As long as you retain this notice you can do whatever you want with this
# stuff. If you think this stuff is worth it, you can flattr me here:
# https://flattr.com/thing/373125/Twinter
# ----------------------------------------------------------------------------
use TCP2000;

my $tcp2k = new TCP2000();

$tcp2k->init();
$tcp2k->set_line_spacing("4mm");

my $table = 0;
my $set = 2;

{
	$tcp2k->set_chartable($table);
	$tcp2k->set_charset($set);
	
	$tcp2k->print("Chartable: $table\n");
	$tcp2k->print("Charset: $set\n\n");
	
	for (my $i = 0x22; $i <= 0xFF; $i++ )
	{	
		my $hex = sprintf "0x%02X", $i; 
		$tcp2k->print( $hex.":  ".chr($i)."    ");
	}
	
	$tcp2k->cut_paper();
	$tcp2k->flush();

}

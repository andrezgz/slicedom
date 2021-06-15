#!/usr/bin/perl

print "Enter an IP Address: ";

# get the users input
$_ = <STDIN>;

# remove the newline "\n" character
chomp($_);

$converteddecimal = ip2dec($_);
$convertedip = dec2ip($converteddecimal);

print "\nInput IP address: $_\n";
print "Decimal conversion: $converteddecimal\n";
print "IP address from decimal: $convertedip\n";


# this sub converts a decimal IP to a dotted IP
sub dec2ip ($) {
    join '.', unpack 'C4', pack 'N', shift;
}

# this sub converts a dotted IP to a decimal IP
sub ip2dec ($) {
    #unpack N => pack CCCC => split /\./ => shift;
    #unpack N => pack C4 => split /\./ => shift;
    #unpack('N' , pack ('CCCC' , split(/\./ , shift)));

    my $ip = shift;
    my @octets = split /\./, $ip;

    # pack converts values to a byte sequence
    my $bytes = pack 'CCCC', @octets;
    # C  An unsigned char (octet) value.

    # unpack derives value from the contents of a string of bytes
    my ($dec) = unpack 'N', $bytes;
    # N  An unsigned long (32-bit) in "network" (big-endian) order.

    #my $dec = unpack 'B*', $bytes;
    # B  A bit string (descending bit order inside each byte).

    return $dec;
}

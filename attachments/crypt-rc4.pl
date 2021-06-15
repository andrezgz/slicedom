#!/usr/bin/perl

use strict;
use warnings;
use Crypt::RC4;

my $passphrase = 'abcde#01234';
my $plaintext = shift || 'text with #0';

print "Plain text: $plaintext\n";
my $encrypted = RC4($passphrase, $plaintext);
print "Encrypted: ", $encrypted, "\n";
my $encrypted_hex = unpack('H*', $encrypted);
print "Encrypted hex: ", $encrypted_hex, "\n\n";

my $encrypted_from_hex = pack('H*', $encrypted_hex);
print "Encrypted from hex: ", $encrypted, "\n";
my $decrypted = RC4($passphrase, $encrypted_from_hex);
print "Decrypted: $decrypted\n";

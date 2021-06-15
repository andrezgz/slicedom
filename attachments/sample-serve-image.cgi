#!/usr/bin/perl

my $data = do {
    local $/ = undef;
    open my $fh, "<:raw", "sample.jpg"
        or die "could not open $file: $!";
    <$fh>;
};

my $filename = 'imagen.jpg';

binmode(STDOUT, ':raw');

print "Content-Type: image/jpeg\n".
      "Content-Disposition: attachment; filename=".$filename."\n".
      "\n";


my $n = 4096;
my @groups = unpack "a$n" x ((length($data)/$n)-1) . "a*", $data;

print $_ for ( @groups );

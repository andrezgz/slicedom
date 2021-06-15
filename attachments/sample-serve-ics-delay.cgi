#!/usr/bin/perl

$| = 1;

my $data = do {
    local $/ = undef;
    open my $fh, "<", "sample.ics"
        or die "could not open $file: $!";
    <$fh>;
};

my $filename = 'calendario.ics';

print "Content-Type: text/html\n".
      "\n";


my $n = 150;
my @groups = unpack "a$n" x ((length($data)/$n)-1) . "a*", $data;

 for ( @groups ) {
    s/\n/<br>/g;
    print $_;
    sleep 1;
}

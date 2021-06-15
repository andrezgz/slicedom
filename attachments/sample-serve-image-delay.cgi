#!/usr/bin/perl

my $data = do {
    local $/ = undef;
    open my $fh, "<:raw", "sample.jpg"
        or die "could not open $file: $!";
    <$fh>;
};

binmode(STDOUT, ':raw');

print "Content-Type: image/jpeg\n".
      "\n";


my $n = 16384;
my @groups = unpack "a$n" x ((length($data)/$n)-1) . "a*", $data;

 for ( @groups ) {
    print $_;
    sleep 1;
}

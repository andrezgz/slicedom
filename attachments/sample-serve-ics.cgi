#!/usr/bin/perl

my $data = do {
    local $/ = undef;
    open my $fh, "<", "sample.ics"
        or die "could not open $file: $!";
    <$fh>;
};

my $filename = 'calendario.ics';

print "Content-Type: text/calendar\n".
      "Content-Disposition: attachment; filename=".$filename."\n".
      "\n";


my $n = 4096;
my @groups = unpack "a$n" x ((length($data)/$n)-1) . "a*", $data;

print $_ for ( @groups );

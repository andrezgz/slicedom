# Perl - select

`select` returns the currently selected filehandle.

## select(FILEHANDLE)

Sets the current default filehandle for output, if FILEHANDLE is supplied.

- A [write](https://perldoc.perl.org/5.8.8/functions/write.html) or a [print](https://perldoc.perl.org/5.8.8/functions/print.html) without a filehandle will default to this FILEHANDLE.
- References to variables related to output will refer to this output channel.

## select(RBITS,WBITS,EBITS,TIMEOUT)

This syntax of `select()` tries to see which file handles or sockets are active

Any of the bit masks can also be undef. The timeout, if specified, is in seconds, which may be fractional.

## Usage

### Redirect STDOUT temporarily to a scalar

```perl
# Open a filehandle on a string
my $scalar_file = '';
open my $scalar_fh, '>', \$scalar_file
		or die "Can't open scalar filehandle: $!";

# Select scalar filehandle as default, save STDOUT
my $ostdout = select( $scalar_fh );

# Unbuffered output
$| = 1;

# Now, close scalar filehandle and bring back STDOUT
close( $scalar_fh );

print "ABC\n";
print "DEF\n";
print "GHI...\n";

# Bring STDOUT back
select( $ostdout );
```

### Set unbuffered output recipe

-> [Perl - Unbuffered Output or Hot Filehandle](Perl-Unbuffered-Output-or-Hot-Filehandle.md)

```perl
my $old_fh = select(STDERR);
$| = 1; # Set ->autoflush()
select($old_fh);
```

#### Use IO::Handle to set unbuffered output 

One should not use `select($file_handle)` syntax to set the "currently selected filehandle" because this will affect all subsequent uses by such functions as `print` and is a sure-fire way to confuse the maintenance programmer. Instead, use [IO::Handle](http://metacpan.org/module/IO::Handle) and its methods.

```perl
use IO::Handle;
STDERR->autoflush(1);
```

### Perform sub-second sleeps

```perl
#You can effect a sleep of 250 milliseconds this way
select(undef, undef, undef, 0.25);
```

#### Use Time::HiRes for a simple delay

Avoid the use of `select()` for performing non-integer sleeps. It's something that generally requires the reader to read `perldoc -f select` to figure out what it should be doing.

For a simple delay, one should use [Time::HiRes](https://metacpan.org/pod/Time::HiRes)

```perl
use Time::HiRes;
sleep( 0.25 );
```

## Linked Sources

- [select](http://perldoc.perl.org/functions/select.html)
- [Things I always need to look up in Perl](https://www.kcaran.com/posts/things-i-always-need-to-look-up-in-perl.html)

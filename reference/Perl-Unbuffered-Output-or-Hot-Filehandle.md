# Perl - Unbuffered Output or Hot Filehandle

SOURCES:

- <https://www.perlmonks.org/?node_id=280025>
- <https://stackoverflow.com/questions/33812618/can-you-force-flush-output-in-perl>
- [Suffering from Buffering?](https://perl.plover.com/FAQs/Buffering.html)
- [Perl Cookbook - 7.12. Flushing Output](https://www.cs.ait.ac.th/~on/O/oreilly/perl/cookbook/ch07_13.htm)
- [Select](https://perldoc.perl.org/5.8.8/functions/select.html)
    - [Programming Perl - select (output filehandle)](https://www.cs.ait.ac.th/~on/O/oreilly/perl/prog/ch03_134.htm)
- [perlvar - Perl predefined variables](https://perldoc.perl.org/5.8.8/perlvar.html)
    - [Programming Perl - Special Variables](https://www.cs.ait.ac.th/~on/O/oreilly/perl/prog/ch02_09.htm#)

---

For efficiency, Perl does not read or write the disk or the network when you ask it to. Instead, it reads and writes large chunks of data to a 'buffer' in memory, and does I/O to the buffer; this is much faster than making a request to the operating system for every read or write.

When you write data to a file with print, the data doesn't normally go into the file right away. Instead, it goes into a buffer. When the buffer is full, Perl writes all the data in the buffer at once. This is called **flushing the buffer**. Here the performance gain is even bigger than for reading, about 60%.

Usually this is what you want, but sometimes the buffering causes problems. Typical problems include communicating with conversational network services and writing up-to-date log files. In such circumstances, you would like to disable the buffering.

## Perlvar `$|`

```perl
autoflush HANDLE EXPR
HANDLE->autoflush( EXPR )
$OUTPUT_AUTOFLUSH
$|
```

- If set to nonzero, forces a flush right away and after every write or print on the currently selected output channel.
- Default is 0 (regardless of whether the channel is really buffered by the system or not; `$|` tells you only whether you've asked Perl explicitly to flush after each write).
- STDOUT is line-buffered (flushed by LF) when connected to a terminal, and block-buffered (flushed when buffer gets full) when connected to something other than a terminal.
- `<STDIN>` flushes STDOUT when it's connected to a terminal.
- This has no effect on input buffering.
- Its value, magically, can only ever be 0 or 1

## Disabling Inappropriate Buffering

In Perl, you can't turn the buffering off, but you can get the same benefits by making the **filehandle hot**. Whenever you print to a hot filehandle, Perl flushes the buffer immediately.

Filehandles are "cold" unless they're attached to the terminal.

> Exception: the filehandle STDERR is always in line buffered mode by default

When a filehandle is attached to the terminal (as STDOUT normally is) it is in *line buffered mode* by default. A filehandle in line buffered mode:

1. It's flushed automatically whenever you print a newline character to it, and it's flushed automatically whenever you read from the terminal.
2. STDOUT is flushed automatically when we read from STDIN.

When a filehandle is attached to something else than a terminal (in `perl script.pl > FILE`, STDOUT is attached to a file), it is block-buffered (flushed when buffer gets full). If buffer is 8 Kb, the content is printed each time the buffer gets to 8192 characters.

When the program finishes, it flushes all its buffers, so all content appears in the file at the same time.

## Perl idiom `$|++` or `$|=1`

```perl
#make the filehandle hot
my $old_fh = select(FILEHANDLE); $| = 1; select($old_fh);
my $old_fh = select(STDERR); $| = 1; select($old_fh);
```

To make FILEHANDLE hot, we select it, set `$|` to a true value, and then we re-select whatever filehandle was selected before.

What's the current filehandle? It's the one last selected with the **select** operator.

```perl
#shorter, bizarre and obscure, version
select((select(FILEHANDLE), $|=1)[0]);
```

This example works by building a list consisting of the returned value from `select(FILEHANDLE)` (which selects FILEHANDLE as a side effect) and `$| = 1`(which is always 1), but sets autoflushing on the now-selected FILEHANDLE as a side effect. The first element of that list (the previously selected filehandle) is now used as an argument to the outer select.

## Using the FileHandle or IO modules

Code is much more readable but takes longer to compile because of the module inclusion.

```perl
use FileHandle; # Or IO::Handle or IO::-anything-else
...

# Make FILEHANDLE hot
FILEHANDLE->autoflush(1);
STDERR->autoflush(1);
```

```perl
use IO::Handle; #Needed in older versions of Perl.

# Execute after the print.

#Flush the currently selected handle.
select()->flush();

#Flush the STODOUT handle.
STDOUT->flush();
```

## Examples

```perl
# Execute anytime before the <STDIN>.
# Causes the currently selected handle to be flushed after every print.
$|++;
use Some::Module 'process_stuff';
print '.' while process_stuff();
```

```perl
#!/usr/bin/perl -w
# WITH buffering the dots aren't displayed until the flush is forced with a \n
print "printing dots with buffering\n";
select undef, undef, undef, 0.25 or print '.'
    for 1 .. 10;
print "\nflush forced\n";
```

```perl
# WITHOUT buffering the dots were displayed immediately as the output wasn't being held in an output buffer.
$|++;
print "printing dots without buffering\n";
select undef, undef, undef, 0.25 or print '.'
    for 1 .. 10;
print "\nflush forced\n";
```

```perl
#!/usr/bin/perl -w
# seeme - demo stdio output buffering
$| = (@ARGV > 0); # command buffered if arguments given
print "Now you don't see it...";
sleep 2;
print "now you do\n";
```

- If you call this program with no arguments, STDOUT is not command buffered. Your terminal (console, window, telnet session, whatever) doesn't receive output until the entire line is completed, so you see nothing for two seconds and then get the full line "Now you don't see it ... now you do".
- If you call the program with at least one argument, STDOUT is command buffered. That means you first see  "Now you don't see it...", and then after two seconds you finally see "now you  do".

```perl
#!/usr/bin/perl -w
# default buffer is 8k: 8192 bytes = 32 * 256
$| = ($ARGV[1] > 0) if $ARGV[1]; # command buffered if arguments given
my $limit = $ARGV[0] || 255;
# each printed content has 32 bytes
print sprintf("%04d > Now you don't see it ....",$_) for (1..$limit);
# if limit < 256, buffer not completed, nothing is shown
# if limit = 256*N, buffer flushed, content up to 256*N is printed. Buffer is empty.
# if limit > 256*N, buffer flushed, content up to 256*N is printed. Buffer contains data.
sleep 2;
print "now you do";
# if limit < 256, buffer flushed, content up to limit is printed
# if limit > 256*N, buffer flushed, content from 256*N+1 is printed
```

## Related builtins

### print()

Perl's print function does not support truly unbuffered output - a physical write for each individual character. Instead, it supports *command buffering*, in which one physical write is made after every separate output command.

It prints to the currently selected handle when no handle is provided.

### select()

Returns the currently selected filehandle.

#### select(FILEHANDLE)

Sets the current default filehandle for output, if FILEHANDLE is supplied.

- A [write](https://perldoc.perl.org/5.8.8/functions/write.html) or a [print](https://perldoc.perl.org/5.8.8/functions/print.html) without a filehandle will default to this FILEHANDLE.
- References to variables related to output will refer to this output channel.

#### select(RBITS,WBITS,EBITS,TIMEOUT)

Any of the bit masks can also be undef. The timeout, if specified, is in seconds, which may be fractional.

```perl
#You can effect a sleep of 250 milliseconds this way
select(undef, undef, undef, 0.25);
```

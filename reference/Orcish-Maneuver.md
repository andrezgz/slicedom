# Orcish Maneuver

ALIAS: OM, Orcish Manoeuvre

There is an inline cache technique called the **Orcish Maneuver**, a clever pun on [Orc](http://lotr.wikia.com/wiki/Orcs) (perhaps) and "OR Cache". Joseph Hall (author of "Effective Perl Programming") coined the term.

It is useful for caching inside the sort comparator function to increase speed. Joseph uses a hash to store the potentially expensive sort value. If that key does not yet exist, he calculates and stores it for next time.

```perl
$cache{$a} ||= function($a); # If it is not cached, $cache{$a} is false
                             # function() is called
                             # the result is stored in the cache
                             # the result is returned
```

This idiom relies on the feature that a Perl assignment returns the value assigned.

```perl
my %cache;
my @sorted = sort {
    ( $cache{$a} ||= function($a) )
    <=>
    ( $cache{$b} ||= function($b) )
} @old_array;
```

## CAVEATS

It has some minor efficiency flaws:

- An extra test is necessary after each sortkey is retrieved from the or-cache.
- If an extracted sortkey has a false value, it will be recomputed every time. This is not usually the case, because the extracted sortkeys are seldom false.

## Comparison

Except when the need to avoid reading the data twice is critical, <mark>the explicit cached sort is always slightly faster than the OM</mark>.

It is simpler than [Schwartzian Transform](Schwartzian-Transform.md) and <mark>faster, if the list contains duplicates</mark>.

## Linked Sources

- <https://perl.plover.com/yak/hw1/Hardware-notes.html#_Orcish_Maneuver_>
- <https://www.nntp.perl.org/group/perl.beginners/2001/05/msg1250.html>

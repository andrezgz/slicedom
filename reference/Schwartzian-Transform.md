# Schwartzian Transform

ALIAS: ST

The **Schwartzian transform** is a technique used to improve the efficiency of [sorting](https://en.wikipedia.org/wiki/Sorting) a list of items. This [idiom](https://en.wikipedia.org/wiki/Programming_idiom) is appropriate for [comparison-based sorting](https://en.wikipedia.org/wiki/Comparison_sort) when the ordering is actually based on the ordering of a certain property (the *key*) of the elements, where computing that property is an **intensive operation** that should be performed a minimal number of times.

The Schwartzian transform is a version of a [Lisp](https://en.wikipedia.org/wiki/Lisp_programming_language) idiom known as **decorate-sort-undecorate**, which avoids recomputing the sort keys by temporarily associating them with the input items. This approach is similar to [Memoization](Memoization.md), which avoids repeating the calculation of the key corresponding to a specific input value.

## The Perl idiom

The general form of the Schwartzian Transform is:

```perl
@sorted = map  { $_->[0] }
          sort { $a->[1] <=> $b->[1] || $a->[0] cmp $b->[0] }
          map  { [$_, foo($_)] }
          @unsorted;
```

Where `foo($_)` represents an expression that takes `$_` (each item of the list in turn) and produces the corresponding value that is to be compared in its stead.

Reading from right to left (or from the bottom to the top):

1. list of item => a list of `[item, value]`:
    - the original list `@unsorted` is fed into a `map` operation that wraps each item into a reference to an anonymous 2-element array consisting of itself and the calculated value that will determine its sort order
2. list of `[item, value]` => sorted list of `[item, value]`
    - the list of lists produced by `map` is fed into `sort`, which sorts it according to the values previously calculated
3. sorted list of `[item, value]` => sorted list of item
    - another `map` operation unwraps the values (from the anonymous array) used for the sorting, producing the items of the original list in the sorted order.

The use of anonymous arrays ensures that memory will be reclaimed by the Perl garbage collector immediately after the sorting is done.

## CAVEATS

If the function to get the sortkey is relatively simple, then the extra overhead of the Schwartzian transform may be unwarranted.

## Comparison

The Schwartzian transform is notable in that it does not use named temporary arrays.

It also assures that each input item's key is calculated exactly once, which may still result in repeating some calculations if the input data contains *duplicate* items.

Nevertheless, it is more efficient than the [Orcish Maneuver](Orcish-Maneuver.md) approach to caching sortkeys.

## Examples

### Sort strings by length

```perl
@sorted = map  { $_->[0] }
          sort { $a->[1] <=> $b->[1] || $a->[0] cmp $b->[0] } # use numeric comparison, fall back to string sort on original
          map { [$_, length($_)] } # calculate the length of the string
          @unsorted;
```

### Sort querystring by the first numeric value, then the case-insensitive querystring

Inefficiently sort by descending numeric compare using the first integer after the first = sign, or the whole querystring case-insensitively otherwise

```perl
my @new = sort {
    ($b =~ /=(\d+)/)[0] <=> ($a =~ /=(\d+)/)[0]
                        ||
                fc($a)  cmp  fc($b)
} @old;
```

Same thing, but much more efficiently; without any temps

```perl
my @new = map { $_->[0] }
          sort { $b->[1] <=> $a->[1]
                         ||
                 $a->[2] cmp $b->[2]
               }
          map { [$_, /=(\d+)/, fc($_)] }
          @old;
```

## History

The first known online appearance of the Schwartzian Transform is a December 16, 1994 [posting by Randal Schwartz](http://groups.google.com/group/comp.unix.shell/browse_frm/thread/31da970cebb30c6d?hl=en) ([Randal Schwartz](https://en.wikipedia.org/wiki/Randal_L._Schwartz)) to a thread in comp.unix.shell, crossposted to comp.lang.perl. (The current version of the [Perl Timeline](http://history.perl.org/PerlTimeline.html) is incorrect and refers to a later date in 1995.) The thread began with a question about how to sort a list of lines by their "last" word:

```text
adjn:Joshua Ng
adktk:KaLap Timothy Kwong
admg:Mahalingam Gobieramanan
admln:Martha L. Nangalama
```

Schwartz responded with:

```perl
#!/usr/bin/perl
require 5; # new features, new bugs!
print
    map { $_->[0] }
    sort { $a->[1] cmp $b->[1] }
    map { [$_, /(\S+)$/] }
    <>;
```

Schwartz noted in the post that he was "Speak\[ing\] with a lisp in Perl," a reference to the idiom's [Lisp](https://en.wikipedia.org/wiki/Lisp_%28programming_language%29) origins.

The term "Schwartzian Transform" itself was coined by [Tom Christiansen](https://en.wikipedia.org/wiki/Tom_Christiansen) in a follow-up reply. Later posts by Christiansen made it clear that he had not intended to *name* the construct, but merely to refer to it from the original post: his attempt to finally name it "The Black Transform" did not take hold ("Black" here being a pun on "schwar\[t\]z", which means black in German).

## Comparison to other languages

In *Python*:

- before 2.4, developers would use the lisp-originated Decorate-Sort-Undecorate (DSU) idiom, usually by wrapping the objects in a (sortkey, object) tuple.
- 2.4 and above, both the `sorted()` function and the in-place `list.sort()` method take a `key=` parameter that allows the user to provide a "key function".
- 3 and above, use of the key function is the only way to specify a custom sort order (the previously-supported comparator argument was removed).

In *Ruby* 1.8.6 and above, the Enumerable abstract class (which includes Arrays) contains a sort_by method which allows you to specify the "key function" (like foo in the examples above) as a code block.

In *PHP* 5.3 and above the transform can be implemented by use of array_walk, e.g. to work around the limitations of the unstable sort algorithms in PHP.

```php
function spaceballs_sort(array& $a) {
    array_walk($a, function(&$v, $k){ $v = array($v, $k); });
    asort($a);
    array_walk($a, function(&$v, $_) { $v = $v[0]; });
}
```

In *Perl 6*, one needs to supply a comparator lambda that only takes 1 argument to perform a Schwartzian transform under the hood:

```perl
@a.sort( { $^a.Str } ) # would sort on the string representation using a Schwartzian transform
@a.sort( { $^a.Str cmp $^b.Str } ) # would do the same converting the elements to compare just before each comparison.
```

## Unix shell

This is so common in Unix shell programming that it doesn't even have a name:

```shell
# Sort file names by file size
ls -l | sort -n +4 | awk '{print $NF}'

# Sort output of SOMETHING from most frequent to least
# SOMETHING | uniq -c | sort -nr | awk '{$1=""; print}'
```

## Linked Sources

- [sort](https://perldoc.perl.org/functions/sort)
- [Schwartzian transform](https://en.wikipedia.org/wiki/Schwartzian_transform)
- [The History of the Schwartzian Transform](https://www.perl.com/article/the-history-of-the-schwartzian-transform/) - brian d foy
- <https://www.slideshare.net/brian_d_foy/the-surprisingly-tense-history-of-the-schwartzian-transform>
- <https://perl.plover.com/yak/hw1/Hardware-notes.html#Schwartzian_Transform>

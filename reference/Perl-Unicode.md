# Perl - Unicode

## Normalization

It doesn't matter what form you use as long as you are consistent.

You almost always need access to the functions from the standard [Unicode::Normalize](https://metacpan.org/pod/Unicode::Normalize) module various types of decompositions. `export PERL5OPTS=-MUnicode::Normalize=NFD,NFKD,NFC,NFKD`, and then always run incoming stuff through NFD and outbound stuff from NFC.

See `nfc`, `nfd`, `nfkd`, and `nfkc`.

Process input through NFD and output through NFC.

```perl
#!/usr/bin/perl
use Unicode::Normalize;
my $norm = NFD($str);
```

[Unicode::Stringprep](https://metacpan.org/pod/Unicode::Stringprep) prepares Unicode text strings in order to increase the likelihood that string input and string comparison work in ways that make sense for typical users throughout the world. The `stringprep` protocol is useful for protocol identifier values, company and personal names, internationalized domain names, and other text strings.

> **You are going to have filesystem issues on filesystems**. Some filesystems silently enforce a conversion to NFC; others silently enforce a conversion to NFD. And others do something else still. Some even ignore the matter altogether, which leads to even greater problems. So you have to do your own NFC/NFD handling to keep sane.

## Casefolding

```perl
#!/usr/bin/perl
use Unicode::CaseFold; # or: use v5.16;
sort { fc($a) cmp fc($b) } @stuff;
```

## Comparing & Sorting

You should use the [Unicode::Collate](https://perldoc.perl.org/Unicode::Collate) module.

String comparisons in Perl using `eq`, `ne`, `lc`, `cmp`, `sort`, `&c&cc` are always wrong. So instead of `@a = sort @b`, you need `@a = Unicode::Collate->new->sort(@b)`. Might as well add that to your `export PERL5OPTS=-MUnicode::Collate`. You can cache the key for binary comparisons.

Case-insensitive comparisons need to check for whether two things are the same letters no matter their diacritics and such. The easiest way to do that is whit `Unicode::Collate->new(level => 1)->cmp($a, $b)`. There are also `eq` methods and such, and you should probably learn about the `match` and `substr` methods, too. These have distinct advantages over the Perl built-ins.

Sometimes that's still not enough, and you need the [Unicode::Collate::Locale](https://perldoc.perl.org/Unicode::Collate::Locale) module instead, as in `Unicode::Collate::Locale->new(locale => "de__phonebook", level => 1)->cmp($a, $b)` instead. Consider that `Unicode::Collate->new(level => 1)->eq("d", "ð")` is true, but `Unicode::Collate::Locale->new(locale=>"is",level => 1)->eq("d", " ð")` is false. Similarly, `ae` and `æ` are `eq` if you don't use locales, or if you use the English one, but they are different in the Icelandic locale.

```perl
#!/usr/bin/perl
use Unicode::Collate::Locale;
my $collator = Unicode::Collate::Locale->new(locale => 'DE');
my @sorted = $collator->sort(@array);
$collator->cmp($word, $another_word); # -> -1, 0 or 1
```

-> Perl alphabetic sort done right

## Unicode and internationalised domain names

In Perl, one can use [Net::IDN::Encode](https://metacpan.org/module/Net::IDN::Encode) which will also perform Punycode conversion.

## The problem of 'user characters'

In Perl at least, everything (substr, length, index, reverse...) works on the level of codepoints. This is often not what you want, because what a user considers to be a character such as `ў` is actually two codepoints (`y` + `◌̆`).

[On dual-living Unicode::GCString in v5.16](https://www.nntp.perl.org/group/perl.perl5.porters/2011/10/msg178687.html)

Even seemingly innocuous things like `printf "%-10s", $str` breaks completely for combining characters, double-width characters (e.g. Chinese/Japanese) or zero-width characters.

Fortunately Perl provides the `\X` regular expression metachar which matches exactly one Extended Grapheme Cluster, i.e. what a user would consider a character to be.

A more robust solution is to install [Unicode::GCString](https://metacpan.org/module/Unicode::GCString):

```perl
#!/usr/bin/perl
use Unicode::GCString;
use Unicode::Normalize;
use utf8;
use open qw(:std :encoding(UTF-8));

my $s = NFD("crème brûlée"); # ensure combining marks get their own codepoint
my $g = Unicode::GCString->new($s);

print $g->length, "\n"; # 12, not 15
print reverse(@$g), "\n"; # 'eélûrb emèrc', not 'éel̂urb em̀erc'
print $g->substr(0,5), "\n"; # 'crème', not 'crèm'
print $g->substr(0,3), "\n"; # 'crè', not 'cre'

print "1234512345123451234512345|\n";
printf "%s%*s|\n", $g, (25 - $g->columns), ''; # 25 columns long (ᵔᴥᵔ)

printf "%-25s|\n", $s; # 22 columns long (╯°□°）╯︵ ┻━┻
```

See `uwc` and `unifmt` from [Unicode::Tussle - Tom's Unicode Scripts So Life is Easier](https://metacpan.org/pod/Unicode::Tussle)

## Line breaks

In Perl, this has all been handled for you - just use [Unicode::LineBreak](https://metacpan.org/module/Unicode::LineBreak).

## ENV variables

All Perl source code should be in UTF-8 by default. You can get that with `use utf8` or `export PERL5OPTS=-Mutf8`.

The Perl DATA handle should be UTF-8. You will have to do this on a per-package basis, as in `binmode(DATA, ":encoding(UTF-8)")`.

Program arguments to Perl scripts should be understood to be UTF-8 by default. `export PERL_UNICODE=A`, or `perl -CA`, or `export PERL5OPTS=-CA`.

The standard input, output, and error streams should default to UTF-8. `export PERL_UNICODE=S` for all of them, or I, O, and/or E for just some of them. This is like `perl -CS`.

Any other handles opened by Perl should be considered UTF-8 unless declared otherwise; `export PERL_UNICODE=D` or with `i` and `o` for particular ones of these; `export PERL5OPTS=-CD` would work. That makes `-CSAD` for all of them.

Cover both bases plus all the streams you open with `export PERL5OPTS=-Mopen=:utf8,:std`. See `uniquote` from [Unicode::Tussle - Tom's Unicode Scripts So Life is Easier](https://metacpan.org/pod/Unicode::Tussle)

You don't want to miss UTF-8 encoding errors. Try `export PERL5OPTS=-Mwarnings=FATAL,utf8`. And make sure your input streams are always binmoded to `:encoding(UTF-8)`, not just to `:utf8`.

Code points between 128–255 should be understood by Perl to be the corresponding Unicode code points, not just unpropertied binary values. `use feature "unicode_strings"` or `export PERL5OPTS=-Mfeature=unicode_strings`. That will make `uc("\xDF") eq "SS"` and `"\xE9" =~ /\w/`. A simple export `PERL5OPTS=-Mv5.12` or better will also get that.

Named Unicode characters are not by default enabled, so add `export PERL5OPTS=-Mcharnames=:full,:short,latin,greek` or some such. See `uninames` and `tcgrep` from [Unicode::Tussle - Tom's Unicode Scripts So Life is Easier](https://metacpan.org/pod/Unicode::Tussle)

## Regular expressions

To work with integers, then you are going to have to run your `\d+` captures through the [Unicode::UCD::num](https://metacpan.org/pod/Unicode::UCD#num()) function because Perl's built-in *atoi*(3) isn't currently clever enough.

All your Perl code involving `a-z` or `A-Z` and such **MUST BE CHANGED**, including` m//`,` s///`, and `tr///`. Getting the right properties, and understanding their casefolds, is harder than you might think. See `unichars` and `uniprops` from [Unicode::Tussle - Tom's Unicode Scripts So Life is Easier](https://metacpan.org/pod/Unicode::Tussle)

Code that uses `[a-zA-Z]` can't be changed to `\pL` or `\p{Letter}`; it needs to use `\p{Alphabetic}`. Not all alphabetics are letters.

You need to use `\p{Upper}` instead of `\p{Lu}`. `\p{Lowercase}` and `\p{Lower}` are different from `\p{Ll}` and `\p{Lowercase_Letter}`.

If you are looking for Perl variables, you need to look for `/[\$\@\%]\p{IDS}\p{IDC}*/` (not `/[\$\@\%]\w+/`), and even that isn't thinking about the punctuation variables or package variables.

If you are checking for whitespace, then you should choose between `\h` and `\v`, depending. And you should never use `\s`, since it **DOES NOT MEAN** `[\h\v]`, contrary to popular belief.

You should use `\R` for a line boundary. It matches any Unicode linebreak sequence (including `\n`, `\r\n` and six others)

`\p, \P`: Match any codepoint possessing (or not possessing) a Unicode property.

Common ones are `\pL` (Letter), `\pU` (Uppercase), `\pS` (Symbol), or even `\p{script=Latin}`, `\p{East_Asian_Width=Wide}`, `\p{Numeric_Value=4}`.

See [perluniprops](http://perldoc.perl.org/perluniprops.html) for a big list.

Built-in character classes such as `\w`, `\b`, `\s` and `\d` are Unicode-aware since Perl 5.6 (though you need to make sure your string or pattern has the UTF8 flag on!) Disable this with the `/a` flag (see [perlre](http://perldoc.perl.org/perlre.html#Character-set-modifiers)).

`\X`: Match an extended grapheme cluster, which is basically a user-visible 'character'. Use it instead of `.` unless you want codepoints.

E.g. to match a vowel with optional diacritics or marks ([source](http://www.perl.com/pub/2012/05/perlunicook-match-unicode-grapheme-cluster-in-regex.html)) :

```perl
my $nfd = NFD($string);
$nfd =~ / (?=[aeiou]) \X /xi;
```

Now consider how to match the pattern CVCV (consonant, vowel, consonant, vowel) in the string `niño`. Its NFD form — which you had darned well better have remembered to put it in — becomes `nin\x{303}o`. Now what are you going to do? Even pretending that a vowel is `[aeiou]` (which is wrong, by the way), you won't be able to do something like `(?=[aeiou])\X)` either, because even in NFD a code point like `ø` **does not decompose**! However, it will test equal to an `o` using the UCA comparison I just showed you. You can't rely on NFD, you have to rely on UCA.

### Hexadecimal escapes

<https://perldoc.perl.org/perlrebackslash#Hexadecimal-escapes>

Like octal escapes, there are two forms of hexadecimal escapes, but both start with the sequence `\x`. This is followed by either

- exactly two hexadecimal digits forming a number `\x50`
- hexadecimal number of arbitrary length surrounded by curly braces `\x{2602}`

```perl
$str = "Perl";
$str =~ /\x50/;    # Match, "\x50" is "P".
$str =~ /\x50+/;   # Match, "\x50" is "P", it is repeated at least once
$str =~ /P\x2B/;   # No match, "\x2B" is "+" and taken literally.

/\x{2603}\x{2602}/ # Snowman with an umbrella.
                   # The Unicode character 2603 is a snowman,
                   # the Unicode character 2602 is an umbrella.
/\x{263B}/         # Black smiling face.
/\x{263b}/         # Same, the hex digits A - F are case insensitive.
```

[Unicode Character Search](https://www.fileformat.info/info/unicode/char/search.htm)

### Perl Regular Expression Character Classes

<https://perldoc.perl.org/perlrecharclass#Backslash-sequences>

```text
\d             Match a decimal digit character.
\D             Match a non-decimal-digit character.
\w             Match a "word" character.
\W             Match a non-"word" character.
\s             Match a whitespace character.
\S             Match a non-whitespace character.
\h             Match a horizontal whitespace character.
\H             Match a character that isn't horizontal whitespace.
\v             Match a vertical whitespace character.
\V             Match a character that isn't vertical whitespace.
\N             Match a character that isn't a newline.
\pP, \p{Prop}  Match a character that has the given Unicode property.
\PP, \P{Prop}  Match a character that doesn't have the Unicode property
```

#### Backslash sequences

##### Digits

`\d` matches a single character considered to be a decimal *digit*.

- If the `/a` regular expression modifier is in effect, it matches `[0-9]`.
- Otherwise, it matches anything that is matched by `\p{Digit}`, which includes `[0-9]`.
    - An unlikely possible exception is that under locale matching rules, the current locale might not have `[0-9]` matched by `\d`, and/or might match other characters whose code point is less than 256. The only such locale definitions that are legal would be to match `[0-9]` plus another set of 10 consecutive digit characters; anything else would be in violation of the C language standard, but Perl doesn't currently assume anything in regard to this.

What this means is that unless the `/a` modifier is in effect `\d` not only matches the digits '0' - '9', but also Arabic, Devanagari, and digits from other languages. This may cause some confusion, and some security issues.

Some digits that `\d` matches look like some of the `[0-9]` ones, but have different values.
    - Examples
        - BENGALI DIGIT FOUR (U+09EA) looks very much like an ASCII DIGIT EIGHT (U+0038)
        - LEPCHA DIGIT SIX (U+1C46) looks very much like an ASCII DIGIT FIVE (U+0035)
    - An application that is expecting only the ASCII digits might be misled, or if the match is `\d+`, the matched string might contain a mixture of digits from different writing systems that look like they signify a number different than they actually do.

What `\p{Digit}` means (and hence `\d` except under the `/a` modifier) is `\p{General_Category=Decimal_Number}`, or synonymously, `\p{General_Category=Digit}`. Starting with Unicode version 4.1, this is the same set of characters matched by `\p{Numeric_Type=Decimal}`. But Unicode also has a different property with a similar name, `\p{Numeric_Type=Digit}`, which matches a completely different set of characters. These characters are things such as `CIRCLED DIGIT ONE` or subscripts, or are from writing systems that lack all ten digits.

The design intent is for `\d` to exactly match the set of characters that can safely be used with "normal" big-endian positional decimal syntax, where, for example 123 means one 'hundred', plus two 'tens', plus three 'ones'. This positional notation does not necessarily apply to characters that match the other type of "digit", `\p{Numeric_Type=Digit}`, and so `\d` doesn't match them.

Any character not matched by `\d` is matched by `\D`.

##### Word characters

`\w` and `\W`

<https://perldoc.perl.org/perlrecharclass#Word-characters>

A `\w` matches a single alphanumeric character (an alphabetic character, or a decimal digit); or a connecting punctuation character, such as an underscore (`_`); or a "mark" character (like some sort of accent) that attaches to one of those. It does not match a whole word. To match a whole word, use `\w+`. This isn't the same thing as matching an English word, but in the ASCII range it is the same as a string of Perl-identifier characters.

- If the `/a` modifier is in effect ...
    - `\w` matches the 63 characters [a-zA-Z0-9_].
- otherwise ...
    - For code points above 255 ...
        - `\w` matches the same as `\p{Word}` matches in this range. That is, it matches Thai letters, Greek letters, etc. This includes connector punctuation (like the underscore) which connect two words together, or diacritics, such as a `COMBINING TILDE` and the modifier letters, which are generally used to add auxiliary markings to letters.
    - For code points below 256 ...
        - if locale rules are in effect ...
            - `\w` matches the platform's native underscore character plus whatever the locale considers to be alphanumeric.
        - if, instead, Unicode rules are in effect ...
            - `\w` matches exactly what `\p{Word}` matches.
        - otherwise ...
            - `\w` matches [a-zA-Z0-9_].

There are a number of security issues with the full Unicode list of word characters. See <http://unicode.org/reports/tr36>.

Any character not matched by `\w` is matched by `\W`.

##### Whitespace

`\s` and `\S`

<https://perldoc.perl.org/perlrecharclass#Whitespace>

`\s` matches any single character considered whitespace.

- If the `/a` modifier is in effect ...
    - In all Perl versions, `\s` matches the 5 characters `[\t\n\f\r ]`; that is, the horizontal tab, the newline, the form feed, the carriage return, and the space. Starting in Perl v5.18, it also matches the vertical tab, `\cK`. See note `[1]` below for a discussion of this.
- otherwise ...
    - For code points above 255 ...
        - `\s` matches exactly the code points above 255 shown with an "s" column in the table below.
    - For code points below 256 ...
        - if locale rules are in effect ...
            - `\s` matches whatever the locale considers to be whitespace.
        - if, instead, Unicode rules are in effect ...
            - `\s` matches exactly the characters shown with an "s" column in the table below.
        - otherwise ...
            - `\s` matches `[\t\n\f\r ]` and, starting in Perl v5.18, the vertical tab, `\cK`. Note that this list doesn't include the non-breaking space.

##### `\N`

`\N`, available starting in v5.12, like the dot, matches any character that is not a newline. `\N` is not influenced by the *single line* regular expression modifier.

The form `\N{...}` may mean something completely different.

- When the `{...}` is a [quantifier](https://perldoc.perl.org/perlre#Quantifiers), it means to match a non-newline character that many times.
    - For example, `\N{3}` means to match 3 non-newlines; `\N{5,}` means to match 5 or more non-newlines.
- If `{...}` is not a legal quantifier, it is <mark>presumed to be a named character</mark>.
    - Both `\N{DIGIT NINE}` and `\N{U+0039}` represent the digit 9.
    - For example, none of `\N{COLON}`, `\N{4F}`, and `\N{F4}` contain legal quantifiers, so Perl will try to find characters whose names are respectively `COLON`, `4F`, and `F4`.

###### charnames

<https://perldoc.perl.org/charnames>

- Starting in Perl v5.16, any occurrence of `\N{CHARNAME}` sequences in a double-quotish string automatically loads this module with arguments `:full` and `:short` (described below) if it hasn't already been loaded with different arguments, in order to compile the named Unicode character into position in the string.
- Prior to v5.16, an explicit `use charnames` was required to enable this usage. (However, prior to v5.16, the form `"use charnames ();"` did not enable `\N{CHARNAME}`.)

Note that `\N{U+...}`, where the `...` is a hexadecimal number, also inserts a character into a string. The character it inserts is the one whose Unicode code point (ordinal value) is equal to the number. For example, `"\N{U+263a}"` is the Unicode (white background, black foreground) smiley face equivalent to `"\N{WHITE SMILING FACE}"`.

> NOTE: `\N{...}` can mean a regex quantifier instead of a character name, when the `...` is a number (or comma separated pair of numbers)

##### Unicode Properties

<https://perldoc.perl.org/perlrecharclass#Unicode-Properties>

`\pP` and `\p{Prop}` are character classes to match characters that fit given Unicode properties.

- One letter property names can be used in the `\pP` form, with the property name following the `\p`, otherwise, braces are required.
- When using braces, there is a single form, which is just the property name enclosed in the braces, and a compound form which looks like `\p{name=value}`, which means to match if the property "name" for the character has that particular "value".

Example: a match for a number can be written as `/\pN/` or as `/\p{Number}/`, or as `/\p{Number=True}/`.

Example: lowercase letters are matched by the property *Lowercase_Letter* which has the short form *Ll*. They need the braces, so are written as `/\p{Ll}/` or `/\p{Lowercase_Letter}/`, or `/\p{General_Category=Lowercase_Letter}/` (the underscores are optional).

> IMPORTANT: `/\pLl/` is valid, but means something different. It matches a two character string: a letter (Unicode property `\pL`), followed by a lowercase `l`.

What a <mark>Unicode property matches is never subject to locale rules</mark>, and if locale rules are not otherwise in effect, <mark>the use of a Unicode property will force the regular expression into using Unicode rules</mark>, if it isn't already.

Unicode properties are defined *only* on Unicode code points. Starting in v5.20, when matching against `\p` and `\P`, Perl treats non-Unicode code points (those above the legal Unicode maximum of 0x10FFFF) as if they were typical unassigned Unicode code points.

#### Bracketed Character Classes

##### Backslash Sequences

<https://perldoc.perl.org/perlrecharclass#Backslash-Sequences>

You can put any backslash sequence character class (with the exception of `\N` and `\R`) inside a bracketed character class, and it will act just as if you had put all characters matched by the backslash sequence inside the character class. For instance, `[a-f\d]` matches any decimal digit, or any of the lowercase letters between 'a' and 'f' inclusive.

`\N` within a bracketed character class must be of the forms `\N{name}` or `\N{U+hex char}`, and NOT be the form that matches non-newlines, for the same reason that a dot `.` inside a bracketed character class loses its special meaning: it matches nearly anything, which generally isn't what you want to happen.

Examples:

```perl
/[\p{Thai}\d]/     # Matches a character that is either a Thai
                   # character, or a digit.
/[^\p{Arabic}()]/  # Matches a character that is neither an Arabic
                   # character, nor a parenthesis.
```

##### POSIX Character Classes

<https://perldoc.perl.org/perlrecharclass#POSIX-Character-Classes>

POSIX character classes have the form `[:class:]`, where *class* is the name, and the `[:` and `:]` delimiters. <mark>POSIX character classes only appear *inside* bracketed character classes</mark>, and are a convenient and descriptive way of listing a group of characters.

```perl
$string =~ /[[:alpha:]]/; # Correct!

$string =~ /[:alpha:]/;   # Incorrect (will warn), it represents a
                          # character class a colon, `a`, `l`, `p` and `h`.
```

Perl recognizes the following POSIX character classes:

```text
alpha  Any alphabetical character (e.g., [A-Za-z]).
alnum  Any alphanumeric character (e.g., [A-Za-z0-9]).
ascii  Any character in the ASCII character set.
blank  A GNU extension, equal to a space or a horizontal tab ("\t").
cntrl  Any control character.  See Note [2] below.
digit  Any decimal digit (e.g., [0-9]), equivalent to "\d".
graph  Any printable character, excluding a space.  See Note [3] below.
lower  Any lowercase character (e.g., [a-z]).
print  Any printable character, including a space.  See Note [4] below.
punct  Any graphical character excluding "word" characters.  Note [5].
space  Any whitespace character. "\s" including the vertical tab
       ("\cK").
upper  Any uppercase character (e.g., [A-Z]).
word   A Perl extension (e.g., [A-Za-z0-9_]), equivalent to "\w".
xdigit Any hexadecimal digit (e.g., [0-9a-fA-F]).  Note [7].
```

Like the [Unicode properties](https://perldoc.perl.org/perlrecharclass#Unicode-Properties), most of the POSIX properties match the same regardless of whether case-insensitive (`/i`) matching is in effect or not. The two exceptions are `[:upper:]` and `[:lower:]`. Under `/i`, they each match the union of `[:upper:]` and `[:lower:]`.

Most POSIX character classes have **two** Unicode-style `\p` property counterparts. They are not official Unicode properties, but Perl extensions derived from official Unicode properties.

- One counterpart, "ASCII-range Unicode", matches only characters in the ASCII character set.
- The other counterpart, "Full-range Unicode", matches any appropriate characters in the full Unicode character set.
    - For example, `\p{Alpha}` matches not just the ASCII alphabetic characters, but any character in the entire Unicode character set considered alphabetic.
- An entry in "backslash sequence" is a (short) equivalent.

```text
[[:...:]]      ASCII-range          Full-range  backslash  Note
                Unicode              Unicode     sequence
-----------------------------------------------------
  alpha      \p{PosixAlpha}       \p{XPosixAlpha}
  alnum      \p{PosixAlnum}       \p{XPosixAlnum}
  ascii      \p{ASCII}
  blank      \p{PosixBlank}       \p{XPosixBlank}  \h      [1]
                                  or \p{HorizSpace}        [1]
  cntrl      \p{PosixCntrl}       \p{XPosixCntrl}          [2]
  digit      \p{PosixDigit}       \p{XPosixDigit}  \d
  graph      \p{PosixGraph}       \p{XPosixGraph}          [3]
  lower      \p{PosixLower}       \p{XPosixLower}
  print      \p{PosixPrint}       \p{XPosixPrint}          [4]
  punct      \p{PosixPunct}       \p{XPosixPunct}          [5]
             \p{PerlSpace}        \p{XPerlSpace}   \s      [6]
  space      \p{PosixSpace}       \p{XPosixSpace}          [6]
  upper      \p{PosixUpper}       \p{XPosixUpper}
  word       \p{PosixWord}        \p{XPosixWord}   \w
  xdigit     \p{PosixXDigit}      \p{XPosixXDigit}         [7]
```

alpha

```text
  \p{PosixAlpha}          (52: [A-Za-z])


  \p{XPosixAlpha}         \p{Alphabetic=Y} (Short: \p{Alpha})
                            (132_875)


  \p{Alpha}               \p{XPosixAlpha} (= \p{Alphabetic=Y})
                            (132_875)
  \p{Alphabetic}          \p{XPosixAlpha} (= \p{Alphabetic=Y})
                            (132_875)
  \p{Alphabetic: Y*}      (Short: \p{Alpha=Y}, \p{Alpha}) (132_875:
                            [A-Za-z\xaa\xb5\xba\xc0-\xd6\xd8-\xf6
                            \xf8-\xff], U+0100..02C1, U+02C6..02D1,
                            U+02E0..02E4, U+02EC, U+02EE ...)
```

alnum

```text
  \p{PosixAlnum}          (62: [0-9A-Za-z])


  \p{XPosixAlnum}         Alphabetic and (decimal) Numeric (Short:
                            \p{Alnum}) (133_525: [0-9A-Za-z\xaa\xb5
                            \xba\xc0-\xd6\xd8-\xf6\xf8-\xff],
                            U+0100..02C1, U+02C6..02D1,
                            U+02E0..02E4, U+02EC, U+02EE ...)
  \p{Alnum}               \p{XPosixAlnum} (133_525)
```

blank

```text
  \p{PosixBlank}          (2: [\t\x20])


  \p{XPosixBlank}         \h, Horizontal white space (Short:
                            \p{Blank}) (18: [\t\x20\xa0], U+1680,
                            U+2000..200A, U+202F, U+205F, U+3000)
  \p{Blank}               \p{XPosixBlank} (18)
  \p{HorizSpace}          \p{XPosixBlank} (18)
```

digit

```text
  \p{PosixDigit}          (10: [0-9])


  \p{XPosixDigit}         \p{General_Category=Decimal_Number} [0-9]
                            + all other decimal digits (Short:
                            \p{Nd}) (650)
  \p{Nd}                  \p{XPosixDigit} (= \p{General_Category=
                            Decimal_Number}) (650)

  \p{General_Category: Decimal_Number} (Short: \p{Gc=Nd}, \p{Nd})
                            (650: [0-9], U+0660..0669, U+06F0..06F9,
                            U+07C0..07C9, U+0966..096F, U+09E6..09EF
                            ...)
  \p{Digit}               \p{XPosixDigit} (= \p{General_Category=
                            Decimal_Number}) (650)
  \p{Decimal_Number}      \p{XPosixDigit} (= \p{General_Category=
                            Decimal_Number}) (650)
  \p{General_Category: Nd} \p{General_Category=Decimal_Number} (650)
  \p{General_Category: Digit} \p{General_Category=Decimal_Number}
                            (650)
```

punct

```text
  \p{PosixPunct}          (32: [!\"#\$\%&\'\(\)*+,\-.\/:;<=>?\@
                            \[\\\]\^_`\{\|\}~])


  \p{XPosixPunct}         \p{Punct} + ASCII-range \p{Symbol} (807:
                            [!\"#\$\%&\'\(\)*+,\-.\/:;<=>?\@\[\\\]
                            \^_`\{\|\}~\xa1\xa7\xab\xb6-\xb7\xbb
                            \xbf], U+037E, U+0387, U+055A..055F,
                            U+0589..058A, U+05BE ...)


  \p{Punct}               \p{General_Category=Punctuation} (Short:
                            \p{P}; NOT \p{General_Punctuation}) (798)
  \p{Punctuation}         \p{Punct} (= \p{General_Category=
                            Punctuation}) (NOT
                            \p{General_Punctuation}) (798)
  \p{General_Category: P} \p{General_Category=Punctuation} (798)
  \p{General_Category: P} \p{General_Category=Punctuation} (798)
  \p{General_Category: Punct} \p{General_Category=Punctuation} (798)
  \p{General_Category: Punct} \p{General_Category=Punctuation} (798)
  \p{General_Category: Punctuation} (Short: \p{Gc=P}, \p{P}) (798:
                            [!\"#\%&\'\(\)*,\-.\/:;?\@\[\\\]_\{\}
                            \xa1\xa7\xab\xb6-\xb7\xbb\xbf], U+037E,
                            U+0387, U+055A..055F, U+0589..058A,
                            U+05BE ...)


  \p{Symbol}              \p{General_Category=Symbol} (Short: \p{S})
                            (7564)
  \p{S} \pS               \p{Symbol} (= \p{General_Category=Symbol})
                            (7564)
  \p{General_Category: S} \p{General_Category=Symbol} (7564)
  \p{General_Category: Symbol} (Short: \p{Gc=S}, \p{S}) (7564:
                            [\$+<=>\^`\|~\xa2-\xa6\xa8-\xa9\xac\xae-
                            \xb1\xb4\xb8\xd7\xf7], U+02C2..02C5,
                            U+02D2..02DF, U+02E5..02EB, U+02ED,
                            U+02EF..02FF ...)
```

space

```text
  \p{PosixSpace}          (Short: \p{PerlSpace}) (6: [\t\n\cK\f\r
                            \x20])
  \p{PerlSpace}           \p{PosixSpace} (6)


  \p{XPosixSpace}         \s including beyond ASCII and vertical tab
                            (Short: \p{SpacePerl}) (25: [\t\n\cK\f
                            \r\x20\x85\xa0], U+1680, U+2000..200A,
                            U+2028..2029, U+202F, U+205F ...)
  \p{SpacePerl}           \p{XPosixSpace} (25)
  \p{XPerlSpace}          \p{XPosixSpace} (25)
```

word

```text
  \p{PosixWord}           \w, restricted to ASCII (Short:
                            \p{PerlWord}) (63: [0-9A-Z_a-z])
  \p{PerlWord}            \p{PosixWord} (63)


  \p{XPosixWord}          \w, including beyond ASCII; = \p{Alnum} +
                            \pM + \p{Pc} + \p{Join_Control} (Short:
                            \p{Word}) (134_564: [0-9A-Z_a-z\xaa\xb5
                            \xba\xc0-\xd6\xd8-\xf6\xf8-\xff],
                            U+0100..02C1, U+02C6..02D1,
                            U+02E0..02E4, U+02EC, U+02EE ...)
  \p{Word}                \p{XPosixWord} (134_564)
```

1. `\p{Blank}` and `\p{HorizSpace}` are synonyms.
2. Control characters don't produce output as such, but instead usually control the terminal somehow
    1. newline and backspace are control characters.
    2. On ASCII platforms, in the ASCII range, characters whose code points are between 0 and 31 inclusive, plus 127 (`DEL`) are control characters; on EBCDIC platforms, their counterparts are control characters.
3. Any character that is *graphical*, that is, visible. This class consists of all alphanumeric characters and all punctuation characters.
4. All printable characters, which is the set of all graphical characters plus those whitespace characters which are not also controls.
5. `\p{PosixPunct}` and `[[:punct:]]` in the ASCII range match all non-controls, non-alphanumeric, non-space characters: ``[-!"#$%&'()*+,./:;<=>?@[\\\]^_`{|}~]`` (although if a locale is in effect, it could alter the behavior of `[[:punct:]]`).
    1. The similarly named property, `\p{Punct}`, matches a somewhat different set in the ASCII range, namely `[-!"#%&'()*,./:;?@[\\\]_{}]`. That is, it is missing the nine characters ``[$+<=>^`|~]``. This is because Unicode splits what POSIX considers to be punctuation into two categories, Punctuation and Symbols.
    2. `\p{XPosixPunct}` and (under Unicode rules) `[[:punct:]]`, match what `\p{PosixPunct}` matches in the ASCII range, plus what `\p{Punct}` matches. This is different than strictly matching according to `\p{Punct}`. Another way to say it is that if Unicode rules are in effect, `[[:punct:]]` matches all characters that Unicode considers punctuation, plus all ASCII-range characters that Unicode considers symbols.
6. `\p{XPerlSpace}` and `\p{Space}` match identically starting with Perl v5.18. In earlier versions, these differ only in that in non-locale matching, `\p{XPerlSpace}` did not match the vertical tab, `\cK`. Same for the two ASCII-only range forms.
7. Unlike `[[:digit:]]` which matches digits in many writing systems, there are currently only two sets of hexadecimal digits, and it is unlikely that more will be added. This is because you not only need the ten digits, but also the six `[A-F]` (and `[a-f]`) to correspond. That means only the Latin script is suitable for these, and Unicode has only two sets of these, the familiar ASCII set, and the fullwidth forms starting at U+FF10 (FULLWIDTH DIGIT ZERO).

<mark>Both the `\p` counterparts always assume Unicode rules are in effect</mark>. On ASCII platforms, this means they assume that the code points from 128 to 255 are Latin-1, and that means that using them under locale rules is unwise unless the locale is guaranteed to be Latin-1 or UTF-8. In contrast, the POSIX character classes are useful under locale rules. They are affected by the actual rules in effect, as follows:

- If the `/a` modifier, is in effect ...
    - Each of the POSIX classes matches exactly the same as their ASCII-range counterparts.
- otherwise ...
    - For code points above 255 ...
        - The POSIX class matches the same as its Full-range counterpart.
    - For code points below 256 ...
        - if locale rules are in effect ...
            - The POSIX class matches according to the locale, except:
                - `word`: also includes the platform's native underscore character, no matter what the locale is.
                - `ascii`: on platforms that don't have the POSIX `ascii` extension, this matches just the platform's native ASCII-range characters.
                - `blank`: on platforms that don't have the POSIX `blank` extension, this matches just the platform's native tab and space characters.
        - if, instead, Unicode rules are in effect ...
            - The POSIX class matches the same as the Full-range counterpart.
        - otherwise ...
            - The POSIX class matches the same as the ASCII range counterpart.

### Character set modifiers

<https://perldoc.perl.org/perlre#Character-set-modifiers>

`/d`, `/u`, `/a`, and `/l`, available starting in 5.14, are called the character set modifiers; they affect the character set rules used for the regular expression.

- `/d` is the old, problematic, pre-5.14 **D**efault character set behavior. Its only use is to force that old behavior.
- `/l` sets the character set to that of whatever **L**ocale is in effect at the time of the execution of the pattern match.
- `/u` sets the character set to **U**nicode.
- `/a` modifier, may be useful. <mark>It also sets the character set to Unicode, BUT adds several restrictions for **A**SCII-safe matching.</mark>

At any given time, exactly one of these modifiers is in effect. Their existence allows Perl to keep the originally compiled behavior of a regular expression, regardless of what rules are in effect when it is actually executed. And if it is interpolated into a larger regex, the original's rules continue to apply to it, and don't affect the other parts.

<mark>The `/l` and `/u` modifiers are automatically selected for regular expressions compiled within the scope of various pragmas, and we recommend that in general, you use those pragmas instead of specifying these modifiers explicitly.</mark> For one thing, the modifiers affect only pattern matching, and do not extend to even any replacement done, whereas using the pragmas gives consistent results for all appropriate operations within their scopes. For example,

```perl
s/foo/\Ubar/il
```

will match "foo" using the locale's rules for case-insensitive matching, but the `/l` does not affect how the `\U` operates. Most likely you want both of them to use locale rules. To do this, instead compile the regular expression within the scope of `use locale`. This both implicitly adds the `/l`, and applies locale rules to the `\U`. The lesson is to `use locale`, and not `/l` explicitly.

It would be better to use `use feature 'unicode_strings'` instead of,

```perl
s/foo/\Lbar/iu
```

to get Unicode rules, as the `\L` in the former (but not necessarily the latter) would also use Unicode rules.

#### /l

means to use the current locale's rules (see [perllocale](https://perldoc.perl.org/perllocale)) when pattern matching. For example, `\w` will match the "word" characters of that locale, and `/i` case-insensitive matching will match according to the locale's case folding rules. The locale used will be the one in effect at the time of execution of the pattern match. This may not be the same as the compilation-time locale, and can differ from one match to another if there is an intervening call of the [setlocale() function](https://perldoc.perl.org/perllocale#The-setlocale-function).

<mark>Prior to v5.20, Perl did not support multi-byte locales. Starting then, UTF-8 locales are supported.</mark> No other multi byte locales are ever likely to be supported. However, in all locales, one can have code points above 255 and these will always be treated as Unicode no matter what locale is in effect.

Under Unicode rules, there are a few case-insensitive matches that cross the 255/256 boundary. Except for UTF-8 locales in Perls v5.20 and later, these are disallowed under `/l`. For example, 0xFF (on ASCII platforms) does not caselessly match the character at 0x178, `LATIN CAPITAL LETTER Y WITH DIAERESIS`, because 0xFF may not be `LATIN SMALL LETTER Y WITH DIAERESIS` in the current locale, and Perl has no way of knowing if that character even exists in the locale, much less what code point it is.

In a UTF-8 locale in v5.20 and later, the only visible difference between locale and non-locale in regular expressions should be tainting (see [perlsec](https://perldoc.perl.org/perlsec)).

This modifier may be specified to be the default by `use locale`.

#### /u

means to use Unicode rules when pattern matching. On ASCII platforms, this means that the code points between 128 and 255 take on their Latin-1 (ISO-8859-1) meanings (which are the same as Unicode's). (Otherwise Perl considers their meanings to be undefined.) Thus, under this modifier, the ASCII platform effectively becomes a Unicode platform; and hence, for example, `\w` will match any of the more than 100_000 word characters in Unicode.

Unlike most locales, which are specific to a language and country pair, Unicode classifies all the characters that are letters *somewhere* in the world as `\w`. For example, your locale might not think that `LATIN SMALL LETTER ETH` is a letter (unless you happen to speak Icelandic), but Unicode does. Similarly, all the characters that are decimal digits somewhere in the world will match `\d`; this is hundreds, not 10, possible matches. And some of those digits look like some of the 10 ASCII digits, but mean a different number, so a human could easily think a number is a different quantity than it really is. For example, `BENGALI DIGIT FOUR` (U+09EA) looks very much like an `ASCII DIGIT EIGHT` (U+0038), and `LEPCHA DIGIT SIX` (U+1C46) looks very much like an `ASCII DIGIT FIVE` (U+0035). And, `\d+`, may match strings of digits that are a mixture from different writing systems, creating a security issue. A fraudulent website, for example, could display the price of something using U+1C46, and it would appear to the user that something cost 500 units, but it really costs 600. A browser that enforced script runs (["Script Runs"](https://perldoc.perl.org/perlre#Script-Runs)) would prevent that fraudulent display. ["num()" in Unicode::UCD](https://perldoc.perl.org/Unicode::UCD#num%28%29) can also be used to sort this out. Or the `/a` modifier can be used to force `\d` to match just the ASCII 0 through 9.

Also, under this modifier, case-insensitive matching works on the full set of Unicode characters. The `KELVIN SIGN`, for example matches the letters "k" and "K"; and `LATIN SMALL LIGATURE FF` matches the sequence "ff", which, if you're not prepared, might make it look like a hexadecimal constant, presenting another potential security issue. See <https://unicode.org/reports/tr36> for a detailed discussion of Unicode security issues.

This modifier may be specified to be the default by `use feature 'unicode_strings`, `use locale ':not_characters'`, or `[use 5.012](https://perldoc.perl.org/perlfunc#use-VERSION)` (or higher).

#### /d

This modifier is automatically selected by default when none of the others are. It means to use the *Default* native rules of the platform except when there is cause to use Unicode rules instead, as follows:

1. the target string is encoded in UTF-8; or
2. the pattern is encoded in UTF-8; or
3. the pattern explicitly mentions a code point that is above 255 (say by `\x{100}`); or
4. the pattern uses a Unicode name (`\N{...}`); or
5. the pattern uses a Unicode property (`\p{...}` or `\P{...}`); or
6. the pattern uses a Unicode break (`\b{...}` or `\B{...}`); or
7. the pattern uses [`(?[ ])`](https://perldoc.perl.org/perlre#%28%3F%5B-%5D%29)
8. the pattern uses [`(*script_run: ...)`](https://perldoc.perl.org/perlre#Script-Runs)

Another mnemonic for this modifier is *Depends*, as the rules actually used depend on various things, and as a result you can get unexpected results.

Unless the pattern or string are encoded in UTF-8, only ASCII characters can match positively.

Example of how that works on an **ASCII** platform:

```perl
$str =  "\xDF";      # Character LATIN SMALL LETTER SHARP S (ß)
                     # $str is not in UTF-8 format.
$str =~ /^\w/;       # No match, as $str isn't in UTF-8 format.
$str .= "\x{0e0b}";  # Added character THAI CHARACTER SO SO (ซ)
                     # Now $str is in UTF-8 format !!!
$str =~ /^\w/;       # Match! $str is now in UTF-8 format.
chop $str;
$str =~ /^\w/;       # Still a match! $str remains in UTF-8 format.
```

Same example printing ouput:

```perl
use feature 'say';

binmode STDOUT, ':encoding(UTF-8)';

# Unless the pattern or string are encoded in UTF-8,
# only ASCII characters can match positively.
# Example of how that works on an **ASCII** platform:

$str =  "\N{U+00DF}";               # Character LATIN SMALL LETTER SHARP S (ß)
                                    # Unicode named character \N{...}
say $str;                           # ß
say utf8::is_utf8($str) ? 'utf8'    # $str is in UTF-8 format.
                        : 'no utf8';
say $str =~ /^\w/ ? 'match'         # match ($str in UTF-8)
                  : 'no-match';

$str =  "\xDF";                     # Character LATIN SMALL LETTER SHARP S (ß)
                                    # Hexadecimal escaped character
say $str;                           # ß
say utf8::is_utf8($str) ? 'utf8'
                        : 'no utf8';# $str is not in UTF-8 format.
say $str =~ /^\w/ ? 'match'
                  : 'no-match';     # no-match ($str NOT in UTF-8)

$str .= "\x{0e0b}";                 # Added character THAI CHARACTER SO SO (ซ)
say $str;                           # ßซ
say utf8::is_utf8($str) ? 'utf8'    # Now $str is in UTF-8 format !!!
                        : 'no utf8';
say $str =~ /^\w/ ? 'match'         # match ($str in UTF-8)
                  : 'no-match';
chop $str;                          # Removed character THAI CHARACTER SO SO (ซ)
say $str =~ /^\w/ ? 'match'         # match ($str in UTF-8)
                  : 'no-match';
```

<mark>Because of the unexpected behaviors associated with this modifier, you probably should only explicitly use it to maintain weird backward compatibilities.</mark>

#### /a (and /aa)

This modifier stands for ASCII-restrict (or ASCII-safe). This modifier may be doubled-up to increase its effect.

When it appears singly, it causes the sequences `\d`, `\s`, `\w`, and the Posix character classes to match only in the ASCII range. They thus revert to their pre-5.6, pre-Unicode meanings. So, under `/a`:

- `\d` always means precisely the digits `0` to `9`
- `\s` means the five characters `[ \f\n\r\t]`, and starting in Perl v5.18, the vertical tab
- `\w` means the 63 characters `[A-Za-z0-9_]`
- all the Posix classes such as `[[:print:]]` match only the appropriate ASCII-range characters.

This modifier is useful for people who only incidentally use Unicode, and who do not wish to be burdened with its complexities and security concerns.

With `/a`, one can write `\d` with confidence that it will only match ASCII characters, and should the need arise to match beyond ASCII, you can instead use `\p{Digit}` (or `\p{Word}` for `\w`). There are similar `\p{...}` constructs that can match beyond ASCII both [Whitespace](#Whitespace) and [POSIX Character Classes](#POSIX-Character-Classes). Thus, this modifier doesn't mean you can't use Unicode, it means that to get Unicode matching you must explicitly use a construct (`\p{}`, `\P{}`) that signals Unicode.

As you would expect, this modifier causes, for example, `\D` to mean the same thing as `[^0-9]`; in fact, all non-ASCII characters match `\D`, `\S`, and `\W`. `\b` still means to match at the boundary between `\w` and `\W`, using the `/a` definitions of them (similarly for `\B`).

Otherwise, `/a` behaves like the `/u` modifier, in that case-insensitive matching uses Unicode rules; for example, "k" will match the Unicode `\N{KELVIN SIGN}` under `/i` matching, and code points in the Latin1 range, above ASCII will have Unicode rules when it comes to case-insensitive matching.

To forbid ASCII/non-ASCII matches (like "k" with `\N{KELVIN SIGN}`), specify the `a` twice, for example `/aai` or `/aia`. (The first occurrence of `a` restricts the `\d`, etc., and the second occurrence adds the `/i` restrictions.) But, note that code points outside the ASCII range will use Unicode rules for `/i` matching, so the modifier doesn't really restrict things to just ASCII; it just forbids the intermixing of ASCII and non-ASCII.

To summarize, this modifier provides protection for applications that don't wish to be exposed to all of Unicode. Specifying it twice gives added protection.

This modifier may be specified to be the default by `use re '/a'` or `use re '/aa'`. If you do so, you may actually have occasion to use the `/u` modifier explicitly if there are a few regular expressions where you do want full Unicode rules (but even here, it's best if everything were under feature `unicode_strings`, along with the `use re '/aa'`)

### Which character set modifier is in effect?

Which of these modifiers is in effect at any given point in a regular expression depends on a fairly complex set of interactions.

- `[use re '/foo'](https://perldoc.perl.org/re#%27%2Fflags%27-mode)` pragma can be used to set default modifiers (including these) for regular expressions compiled within its scope.
    - This pragma has precedence over the other pragmas listed below that also change the defaults.
- Otherwise
    - `use locale` sets the default modifier to `/l`
    - `use feature 'unicode_strings`, or `use 5.012` (or higher) set the default to `/u` when not in the same scope as either `use locale` or `use bytes`.
        - `use locale ':not_characters'` also sets the default to `/u`, overriding any plain `use locale`.
    - Unlike the mechanisms mentioned above, these affect operations besides regular expressions pattern matching, and so give more consistent results with other operators, including using `\U`, `\l`, *etc*. in substitution replacements.
- If none of the above apply, for backwards compatibility reasons, the `/d` modifier is the one in effect by default.
    - As this can lead to unexpected results, it is best to specify which other rule set should be used.

### Character set modifier behavior prior to Perl 5.14

Prior to 5.14, there were no explicit modifiers, but `/l` was implied for regexes compiled within the scope of `use locale`, and `/d` was implied otherwise. However, interpolating a regex into a larger regex would ignore the original compilation in favor of whatever was in effect at the time of the second compilation. There were a number of inconsistencies (bugs) with the `/d` modifier, where Unicode rules would be used when inappropriate, and vice versa. `\p{}` did not imply Unicode rules, and neither did all occurrences of `\N{}`, until 5.12.

#### The Unicode Bug

<https://perldoc.perl.org/perlunicode#The-%22Unicode-Bug%22>

Before Unicode, when a character was a byte was a character, Perl knew only about the 128 characters defined by ASCII, code points 0 through 127 (except for under `use locale`). That left the code points 128 to 255 as unassigned. The only semantics they have is their ordinal numbers, and that they are members of none of the non-negative character classes. None are considered to match `\w` for example, but all match `\W`.

The term, "Unicode bug" has been applied to an *inconsistency* with the code points in the `Latin-1 Supplement` block, that is, between 128 and 255. Without a locale specified, unlike all other characters or code points, these characters can have very different semantics depending on the rules in effect.

> Characters whose code points are above 255 force Unicode rules; whereas the rules for ASCII characters are the same under both ASCII and Unicode rules.

- <mark>Under Unicode rules, these upper-Latin1 characters are interpreted as Unicode code points, which means they have the same semantics as Latin-1 (ISO-8859-1) and C1 controls</mark>.
- Under ASCII rules, they are considered to be unassigned characters, as explained in ["ASCII Rules versus Unicode Rules"](https://perldoc.perl.org/perlunicode#ASCII-Rules-versus-Unicode-Rules).

<mark>This can lead to unexpected results</mark>. For example, a string's semantics can suddenly change if a code point above 255 is appended to it, which changes the rules from ASCII to Unicode:

```perl
no feature "unicode_strings"; # also, the default behavior

# Â is a word character
$s1 = "\xC2";
print $s1 =~ /\w/ || 0; # 0 
# BUT under ASCII rules it is NOT a "word" character

# ♠ is not a word character
$s2 = "\x{2660}"; # code point above 255 implies Unicode for the whole string
print $s2 =~ /\w/ || 0; # 0
# and under Unicode rules it is not a "word" character

# The concatenation of both Â♠ implies Unicode for the whole string
$s = $s1.$s2;
print $s =~ /\w/ || 0; # 1
# Â is NOW considered a word character because it is matched under Unicode rules
```

This anomaly stems from Perl's attempt to not disturb older programs that didn't use Unicode, along with Perl's desire to add Unicode support seamlessly. But the result turned out to not be seamless.

`use feature 'unicode_strings'` was added, starting in Perl v5.12, to address this problem. Check [What is it people have against unicode_strings?](https://youtu.be/FlGpiS39NMY?t=3024)

### Properties accessible through `\p{}` and `\P{}`

<https://perldoc.perl.org/perluniprops#Properties-accessible-through-%5Cp%7B%7D-and-%5CP%7B%7D>

**Compound forms** consist of two components, separated by an equals sign or a colon.
    - The first component is the property name
    - The second component is the particular value of the property to match against

Example: `\p{Script_Extensions: Greek}` and `\p{Script_Extensions=Greek}` both mean to match characters whose Script_Extensions property value is Greek. (`Script_Extensions` is an improved version of the `Script` property.)

**Single forms**, like `\p{Greek}`, are mostly Perl-defined shortcuts for their equivalent compound forms. There are also a few Perl-defined single forms that are not shortcuts for a compound form ( `\p{Word}` )

Example: `\p{Greek}` is a just a shortcut for `\p{Script_Extensions=Greek}`

<mark>Perl always ignores Upper/lower case differences everywhere within the {braces}</mark>. Thus `\p{Greek}` means the same thing as `\p{greek}`.

> IMPORTANT: changing the case of the `p` or `P` before the left brace completely changes the meaning of the construct, from "match" (for `\p{}`) to "doesn't match" (for `\P{}`).

White space, hyphens, and underscores are normally ignored everywhere between the {braces}, and hence can be freely added or removed even if the `/x` modifier hasn't been specified on the regular expression.

#### Tighter rules

A `T` at the beginning of an entry means that tighter (stricter) rules are used for that entry:

Single form (`\p{name}`) tighter rules:

- White space, hyphens, and underscores ARE significant except for:
    - white space adjacent to a non-word character
    - underscores separating digits in numbers
- You can freely add or remove white space adjacent to (but within) the braces without affecting the meaning.

Compound form (`\p{name=value}` or `\p{name:value}`) tighter rules:

- The tighter rules given above for the single form apply to everything to the right of the colon or equals; the looser rules still apply to everything to the left.
- You can freely add or remove white space adjacent to (but within) the braces and the colon or equal sign.

#### Varieties of obsolescence

- `S` Stabilized: the property will not be maintained nor extended for newly encoded characters.
- `D` Deprecated: its use is strongly discouraged, so much so that a warning will be issued if used, unless the regular expression is in the scope of a `no warnings 'deprecated'` statement.
    - Perl may issue such a warning, even for properties that aren't officially deprecated by Unicode, when there used to be characters or code points that were matched by them, but no longer. This is to warn you that your program may not work like it did on earlier Unicode releases.
    - A deprecated property may be made unavailable in a future Perl version, so it is best to move away from them.
    - A deprecated property may also be stabilized, but this fact is not shown.
- `O` Obsolete: properties that Unicode once used for internal purposes (but not any longer).
- `X` Discouraged: applies to certain Perl extensions that are present for backwards compatibility, but are discouraged from being used. These are not obsolete, but their meanings are not stable.
    - Future Unicode versions could force any of these extensions to be removed without warning, replaced by another property with the same name that means something different.
    - Use the equivalent shown instead.

#### Propertis beginning with `In_` or `Is_`

In particular, matches in the Block property have *single forms defined by Perl* that begin with `In_`, `Is_`, or even with no prefix at all, like all **DISCOURAGED** forms, these are not stable. For example, `\p{Block=Deseret}` can currently be written as `\p{In_Deseret}`, `\p{Is_Deseret}`, or `\p{Deseret}`. But, a new Unicode version may come along that would force Perl to change the meaning of one or more of these, and your program would no longer be correct. Currently there are no such conflicts with the form that begins `In_`, but there are many with the other two shortcuts, and Unicode continues to define new properties that begin with `In`, so it's quite possible that a conflict will occur in the future. The compound form is guaranteed to not become obsolete, and its meaning is clearer anyway. See ["Blocks" in perlunicode](https://perldoc.perl.org/perlunicode#Blocks) for more information about this.

- The left column contains the `\p{}` constructs to look up
- The right column contains information about them, like a description, or synonyms.
    - The right column will also caution you if a property means something different than what might normally be expected.
- Short vs long names
    - If the left column is a short name for a property, the right column will give its longer, more descriptive name
    - If the left column is the longest name, the right column will show any equivalent shortest name, in both single and compound forms if applicable.
- If braces are not needed to specify a property (e.g., `\pL`), the left column contains both forms, with and without braces.

**All single forms are Perl extensions**; a few compound forms are as well, and are noted as such.

`(\d+)` Numbers in (parentheses) indicate the total number of Unicode code points matched by the property. For the entries that give the longest, most descriptive version of the property, the count is followed by a list of some of the code points matched by it:
    - all the matched characters in the 0-255 range, enclosed in the familiar \[brackets\] the same as a regular expression bracketed character class
    - *the next few higher matching ranges* are also given
    - the SPACE character is represented as `\x20`.

Most properties match the same code points regardless of whether `/i` case-insensitive matching is specified or not. But a few properties are affected. These are shown with the notation `(/i= _other_property_)` in the second column. Under case-insensitive matching they match the same code pode points as the property *other_property*.

For compactness, `*` is used as a wildcard instead of showing all possible combinations.

```text
\p{Gc: *}                                  \p{General_Category: *}
```

mean that 'Gc' is a synonym for 'General_Category', and anything that is valid for the latter is also valid for the former.

```text
\p{Is_*}                                   \p{*}
```

means that if and only if, for example, `\p{Foo}` exists, then `\p{Is_Foo}` and `\p{IsFoo}` are also valid and all mean the same thing. And similarly, `\p{Foo=Bar}` means the same as `\p{Is_Foo=Bar}` and `\p{IsFoo=Bar}`. `*` here is restricted to something not beginning with an underscore.

All non-essential underscores are removed in the display of the short names below.

#### Legend summary

- `*` is a wild-card
- `(\d+)` in the info column gives the number of Unicode code points matched by this property.
- `D` means this is deprecated.
- `O` means this is obsolete.
- `S` means this is stabilized.
- `T` means tighter (stricter) name matching applies.
- `X` means use of this form is discouraged, and may not be stable.

```text
      NAME                           INFO

  \p{ASCII}               \p{Block=Basic_Latin} (128)
X \p{Basic_Latin}         \p{ASCII} (= \p{Block=Basic_Latin}) (128)
  \p{Block: ASCII}        \p{Block=Basic_Latin} (128)
  \p{Block: Basic_Latin}  (Short: \p{Blk=ASCII}) (128: [\x00-\x7f])


  \p{Block: Latin_1}      \p{Block=Latin_1_Supplement} (128)
  \p{Block: Latin_1_Sup}  \p{Block=Latin_1_Supplement} (128)
  \p{Block: Latin_1_Supplement} (Short: \p{Blk=Latin1}) (128: [\x80-\xff])
  \p{Block: Latin_Ext_A}  \p{Block=Latin_Extended_A} (128)
  \p{Block: Latin_Ext_Additional} \p{Block= Latin_Extended_Additional} (256)
  \p{Block: Latin_Ext_B}  \p{Block=Latin_Extended_B} (208)
  \p{Block: Latin_Ext_C}  \p{Block=Latin_Extended_C} (32)
  \p{Block: Latin_Ext_D}  \p{Block=Latin_Extended_D} (224)
  \p{Block: Latin_Ext_E}  \p{Block=Latin_Extended_E} (64)
  \p{Block: Latin_Extended_A} (Short: \p{Blk=LatinExtA}) (128: U+0100..017F)
  \p{Block: Latin_Extended_Additional} (Short: \p{Blk= LatinExtAdditional}) (256: U+1E00..1EFF)
  \p{Block: Latin_Extended_B} (Short: \p{Blk=LatinExtB}) (208: U+0180..024F)
  \p{Block: Latin_Extended_C} (Short: \p{Blk=LatinExtC}) (32: U+2C60..2C7F)
  \p{Block: Latin_Extended_D} (Short: \p{Blk=LatinExtD}) (224: U+A720..A7FF)
  \p{Block: Latin_Extended_E} (Short: \p{Blk=LatinExtE}) (64: U+AB30..AB6F)


  \p{Script: Latin}       (Short: \p{Sc=Latn}) (1374: [A-Za-z\xaa\xba\xc0-\xd6\xd8-\xf6\xf8-\xff],U+0100..02B8, U+02E0..02E4,U+1D00..1D25, U+1D2C..1D5C, U+1D62..1D65...)
  \p{Script: Latn}        \p{Script=Latin} (1374)

  \p{Latin}               \p{Script_Extensions=Latin} (Short: \p{Latn}) (1403)
  \p{Latn}                \p{Latin} (= \p{Script_Extensions=Latin}) (1403)
  \p{Script_Extensions: Latin} (Short: \p{Scx=Latn}, \p{Latn}) (1403: [A-Za-z\xaa\xba\xc0-\xd6\xd8-\xf6\xf8-\xff], U+0100..02B8,U+02E0..02E4, U+0363..036F,U+0485..0486, U+0951..0952 ...)
  \p{Script_Extensions: Latn} \p{Script_Extensions=Latin} (1403)


X \p{Latin_1}             \p{Latin_1_Supplement} (= \p{Block=
                            Latin_1_Supplement}) (128)
X \p{Latin_1_Sup}         \p{Latin_1_Supplement} (= \p{Block=
                            Latin_1_Supplement}) (128)
X \p{Latin_1_Supplement}  \p{Block=Latin_1_Supplement} (Short:
                            \p{InLatin1}) (128)
```

## Wrong Perl Unicode assumptions

### Code that believes you can use Perl printf widths to pad and justify Unicode data is broken and wrong

You can't, because some characters have no width (combining accents, control characters) while some have double-width (CJKV ideographs, 'full-width' letters).

Most likely printf will interpret each codepoint as a character with a width of one, so for things like Chinese it'll pad completely wrong.

For Perl the solution is [Unicode::GCString](https://metacpan.org/module/Unicode::GCString).

### Code that believes `\p{InLatin}` is the same as `\p{Latin}` is heinously broken

`\p{InLatin}` does not exist in my Perl 5.16, but `\p{InLatin1}` does: it's the same as `\p{Block=Latin1}` (filters by block).

`\p{Latin}` is equivalent to `\p{Script=Latin}` (filters by script). See [perluniprops](http://perldoc.perl.org/perluniprops.html) for gory details.

These are clearly different; the Latin-1 block contains all kinds of junk, including control characters, superscripts, fractions and currency signs. In the other direction, Latin can be found in the ASCII block, and elsewhere.

### Code that believes that `\p{InLatin}` is almost ever useful is almost certainly wrong

Again, assuming `\p{InLatin1}`, it would be useless as the block has such a diverse set of characters.

### Code that believes that given `$FIRST_LETTER` as the first letter in some alphabet and `$LAST_LETTER` as the last letter in that same alphabet, that `[${FIRST_LETTER}-${LAST_LETTER}]` has any meaning whatsoever is almost always completely broken and wrong and meaningless

Unicode places no semantic value on the codepoint number. It may or may not be related to nearby codepoints; if it is, it's usually just because that was convenient when assigning them.

Alphabets vary by locale; while `[a-z]` works OK for English (many may disagree...), the Danish/Norweigian alphabet includes æ, ø, and å at the end. `[a-å]` matches a huge chunk of ASCII and Latin-1, included most capital accented characters, Latin-1 control characters, and punctuation. Not ideal.

### Code that assumes `\w` contains only letters, digits, and underscores is wrong

`\w` is generally locale specific for any POSIX-compatible regex engine.

For Perl 5.14+, `\w` matches "anything that is a letter or digit *somewhere* in the world", but *also* includes "connector punctuation marks and Unicode marks" ([perlre](http://perldoc.perl.org/perlre.html)). This means vowel signs and combining accents.

Use the regular expression `/a` flag to get a more legacy behaviour where `\w` is just `[a-z0-9_]` and `\d` is `[0-9]`. This modifier stands for ASCII-restrict (or ASCII-safe). This modifier may be doubled-up to increase its effect (`/aa`).

In other languages, see documentation to see which definition of `\w` applies.

### Code that assumes Perl uses UTF‑8 internally is wrong. Code that assumes Perl code points are limited to 0x10_FFFF is wrong

-> Perl - UTF-8 vs utf8

- Perl uses a [very permissive variant](http://perldoc.perl.org/Encode.html#UTF-8-vs.-utf8-vs.-UTF8) of UTF-8 it calls 'utf8' which allows very high codepoints (beyond 0x10_FFFF) and illegal characters or sequences.
- Perl may use ISO-8859-1 if the string's UTF8 flag is unset.
- On EBCDIC platforms, different encodings may be used.

The idea is that Perl's internal representation is abstract; you should not rely on it; you should be blissfully unaware of it and just [decode](http://perldoc.perl.org/Encode.html) input data into Perl's representation, and then [encode](http://perldoc.perl.org/Encode.html) when outputting it.

Unfortunately that is not true of Perls before 5.14 due to a variety of bugs, including [The Unicode Bug](#The-Unicode-Bug).

### Code that assumes you can set `$/` to something that will work with any valid line separator is wrong

The set of valid Unicode linebreak sequences requires a regex, but `$/` can only be a single string. You can use `\R` in regular expressions to do The Right Thing™.

See perlrebackslash: <http://perldoc.perl.org/perlrebackslash.html#Misc>

`\R` matches a generic newline; that is, anything considered a linebreak sequence by Unicode.

### MUCH ADO ABOUT `\X`

So `\X` matches an 'extended grapheme cluster' which is basically what a user would think of as a character. It accounts for decomposed Hangul, Latin characters with combining diacritics, and so on.

#### Code that uses `\PM\pM*` to find grapheme clusters instead of using `\X` is broken and wrong

`\PM\pM*` means a non-mark char followed by zero or more mark chars. It has a couple of major differences I think:

- `\X` handles decomposed Hangul and regional indicators
- `\X` uses Unicode's Grapheme_Cluster_Break properties instead of the Mark general category.

In short, it's much better, but more complicated, so PCRE implements `\X` as `\PM\pM*` instead.

#### Code that assumes `\X` can never start with a `\p{Mark}` character is wrong

Vowel signs (again!) are in `\p{Grapheme_Base}` but also `\p{Mark}`, so `\X` may start with them. This makes sense if you think about it.

If it's at the start of the string, `\X` will match anything.

#### Code that assumes there is a limit to the number of code points in a row that just one `\X` can match is wrong

This can be seen from the grammar of `\X`:

```text
# All the tables with _X_ in their names are used in defining \X handling,
# and are based on the Unicode GCB property.  Basically, \X matches:
#   CR LF
#   | Prepend* Begin Extend*
#   | .
# Begin is:           ( Special_Begin | ! Control )
# Begin is also:      ( Regular_Begin | Special_Begin )
#   where Regular_Begin is defined as ( ! Control - Special_Begin )
# Special_Begin is:   ( Regional-Indicator+ | Hangul-syllable )
# Extend is:          ( Grapheme_Extend | Spacing_Mark )
# Control is:         [ GCB_Control | CR | LF ]
# Hangul-syllable is: ( T+ | ( L* ( L | ( LVT | ( V | LV ) V* ) T* ) ))
```

(Prepend, Extend, L/T/V etc. come from the Grapheme_Cluster_Break property).

So it'll slurp up all regional indicator characters and any number of L/V/T components in a decomposed Hangul syllable construction.

#### Code that assumes that `\X` can never hold two non-`\p{Mark}` characters is wrong

Hangul components aren't in `\p{Mark}`, for example. There are also `\p{Grapheme_Extend}` code points that lie outside `\p{Mark}`, such as U+200C and U+200D.

## Boilerplate for Unicode-Aware Code

-> Boilerplate

1. Set your the env variable `PERL_UNICODE="AS"`. This makes all Perl scripts decode `@ARGV` as UTF‑8 strings, and sets the encoding of all three of stdin, stdout, and stderr to UTF‑8. Both these are global effects, not lexical ones.
2. At the top of your source file (program, module, library, do), prominently assert you are running **perl version 5.12 or better**:
    - `use v5.12; # minimal for unicode string feature`
    - `use v5.14; # optimal for unicode string feature`
3. Enable **warnings**, since the previous declaration only enables strictures and features, not warnings.
    - Promote Unicode warnings into exceptions, so use both these lines, not just one of them. Note however that under v5.14, the utf8 warning class comprises three other subwarnings which can all be separately enabled: nonchar, surrogate, and non_unicode.
    - `use warnings;`
    - `use warnings qw( FATAL utf8 );`
4. Declare that this source unit is encoded as UTF‑8:
    - `use utf8;`
5. Declare that anything that opens a filehandle *within this lexical scope but not elsewhere* is to assume that that stream is encoded in UTF‑8 unless you tell it otherwise. That way you do not affect other module's or other program's code.
    - `use open qw( :encoding(UTF-8) :std );`
6. Enable named characters via `\N{CHARNAME}`.
    - `use charnames qw( :full :short );`
7. If you have a DATA handle, you must explicitly set its encoding. If you want this to be UTF‑8, then say:
    - `binmode(DATA, ":encoding(UTF-8)");`

```perl
use 5.014;

use utf8;
use strict;
use autodie; # not Unicode related
use warnings;
use warnings qw< FATAL utf8 >;
use open qw< :std :encoding(UTF-8) >;
use charnames qw< :full >;
use feature qw< unicode_strings >;

use File::Basename qw< basename >;
use Carp qw< carp croak confess cluck >;
use Encode qw< encode decode >;
use Unicode::Normalize qw< NFD NFC >;

END { close STDOUT }

if (grep /\P{ASCII}/ => @ARGV) {
    @ARGV = map { decode("UTF-8", $_) } @ARGV;
}

$0 = basename($0); # shorter messages
$| = 1;

binmode(DATA, ":encoding(UTF-8)");

# give a full stack dump on any untrapped exceptions

local $SIG{__DIE__} = sub {
    confess "Uncaught exception: @_" unless $^S;
};

# now promote run-time warnings into stack-dumped
# exceptions *unless* we're in an try block, in
# which case just cluck the stack dump instead

local $SIG{__WARN__} = sub {
    if ($^S) { cluck "Trapped warning: @_" }
    else { confess "Deadly warning: @_" }
};

while (<>) {
    chomp;
    $_ = NFD($_);
    ...
} continue {
    say NFC($_);
}

__END__
```

## Assume Brokenness

There are a million broken assumptions that people make about Unicode. Until they understand these things, their Perl code will be broken.

What you're going to discover that <mark>it is simply impossible to impose all these things on code that hasn't been designed right from the beginning to account for them</mark>. And even once you do, there are still critical issues that require a great deal of thought to get right. Nothing but brain, and I mean *real brain*, will suffice here. There's a heck of a lot of stuff you have to learn. You cannot wish Unicode away by willful ignorance.

If there's one thing I know about Perl, it is what its Unicode bits do and do not do, and this thing I promise you: "There is no Unicode Magic Bullet".

Unicode is fundamentally more complex than the model that you would like to impose on it, and there is complexity here that you can never sweep under the carpet. At some point, you simply have to break down and **learn what Unicode is about**.

You cannot just change some defaults and get smooth sailing. You shoud go through all the many steps outlined very, **very** carefully.

## Linked Sources

- [perlunicode - Unicode support in Perl](https://perldoc.perl.org/perlunicode)
- [perluniprops - Index of Unicode Version 13.0.0 character properties in Perl](https://perldoc.perl.org/perluniprops)
- [perlrecharclass - Perl Regular Expression Character Classes](https://perldoc.perl.org/perlrecharclass)
- [perlre - Perl regular expressions](https://perldoc.perl.org/perlre)
- [perlrebackslash - Perl Regular Expression Backslash Sequences and Escapes](https://perldoc.perl.org/perlrebackslash)
- [Unicode In Five Minutes](https://richardjharris.github.io/unicode-in-five-minutes.html) - Richard Harris
- [All sorts of things you can get wrong in Unicode, and why](https://richardjharris.github.io/all-sorts-of-things-you-can-get-wrong-in-unicode-and-why.html) - Richard Harris
- [Why does modern Perl avoid UTF-8 by default?](https://stackoverflow.com/questions/6162484/why-does-modern-perl-avoid-utf-8-by-default)
- [𝙎𝙞𝙢𝙥𝙡𝙚𝙨𝙩 ℞: 𝟕 𝘿𝙞𝙨𝙘𝙧𝙚𝙩𝙚 𝙍𝙚𝙘𝙤𝙢𝙢𝙚𝙣𝙙𝙖𝙩𝙞𝙤𝙣𝙨](https://stackoverflow.com/questions/6162484/why-does-modern-perl-avoid-utf-8-by-default/6163129#6163129) - Tom Christiansen (tchrist)
- [JSON, Unicode, and Perl ... Oh My!](https://perl.com/article/json-unicode-and-perl-oh-my-/)
- [How does perl treat unicode symbols with length?](https://www.reddit.com/r/perl/comments/pcmrt2/how_does_perl_treat_unicode_symbols_with_length/)

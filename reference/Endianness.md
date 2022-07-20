# Endianness

ALIAS: big-endian, little-endian

TAGS: #development #concepto

SOURCES:

- [Lilliput and Blefuscu](https://en.wikipedia.org/wiki/Lilliput_and_Blefuscu)
- [Big and Little Endian](https://web.archive.org/web/20170227191944/http://www.cs.umd.edu:80/class/sum2003/cmsc311/Notes/Data/endian.html)
- [Big Endian vs Little Endian](https://www.youtube.com/watch?v=JrNF0KRAlyo)
- [Big and Little Endian inside / out](https://www.youtube.com/watch?v=oBSuXP-1Tc0)

---

## Byte orders

- **Little-endian:** Intel and VAX CPUs
- **Big-endian**: Everybody else, including Motorola m68k/88k, PPC, Sparc, HP PA, Power, and Cray
    - Also known as the **network byte order** or **network order**
- Either: Alpha and MIPS. Digital/Compaq used them in little-endian mode, but SGI/Cray uses them in big-endian mode

A 4-byte integer 0x12345678 (305419896 decimal) would be ordered natively (arranged in and handled by the CPU registers) into bytes as

- 0x12 0x34 0x56 0x78 for big-endian
- 0x78 0x56 0x34 0x12 for little-endian

## Weirder byte orders

Some systems may have even weirder byte orders called mid-endian, middle-endian, mixed-endian, or just *weird*.

- 0x56 0x78 0x12 0x34
- 0x34 0x12 0x78 0x56

## Perl

### pack & unpack

-> [Perl - pack y unpack](Perl-pack-y-unpack.md)

The integer formats `s`, `S`, `i`, `I`, `l`, `L`, `j`, and `J` are inherently non-portable between processors and operating systems because they obey native byteorder and endianness.

For portably packed integers, either use the formats `n`, `N`, `v`, and `V` or else use the `>` and `<` modifiers.

### Determine your system endianness

Run this incantation

```shell
$ perl -e 'printf("%#02x ", $_) for unpack("W*", pack L=>0x12345678);'
0x78 0x56 0x34 0x12 # little-endian
```

Get the byteorder on the platform where Perl was built:

```perl
use Config;
print "$Config{byteorder}\n";
```

and from the command line:

```shell
perl -V:byteorder
```

Byteorders "1234" and "12345678" are little-endian
Byteorders "4321" and "87654321" are big-endian

Systems with multiarchitecture binaries will have "ffff" , signifying that static information doesn't work, one must use runtime probing.

## Origin

The names *big-endian* and *little-endian* are comic references to the egg-eating habits of the little-endian Lilliputians and the big-endian Blefuscudians from the classic Jonathan Swift satire, *Gulliver's Travels*.

This entered computer lingo via the paper "On Holy Wars and a Plea for Peace" by Danny Cohen, USC/ISI IEN 137, April 1, 1980.

### Lilliput and Blefuscu

**Lilliput** and **Blefuscu** are two fictional island nations that appear in the first part of the 1726 novel Gulliver's Travels by Jonathan Swift.

The novel further describes an intra-Lilliputian quarrel over **the practice of breaking eggs**. Traditionally, Lilliputians broke boiled eggs on the larger end; a few generations ago, an Emperor of Lilliput, the Present Emperor's great-grandfather, had decreed that all eggs be broken on the smaller end after his son cut himself breaking the egg on the larger end. The differences between **Big-Endians** (those who broke their eggs at the larger end) and **Little-Endians** had given rise to "six rebellions ... wherein one Emperor lost his life, and another his crown". The Lilliputian religion says an egg should be broken on the convenient end, which is now interpreted by the Lilliputians as the smaller end. The Big-Endians gained favour in Blefuscu.

### English Catholicism and Protestantism

The Big-Endian/Little-Endian controversy reflects, in a much simplified form, **British quarrels over religion**. Less than 200 years previously, England had been a Catholic (Big-Endian) country; but a series of reforms beginning in the 1530s under King Henry VIII (reigned 1509–1547), Edward VI (1547–1553), and Queen Elizabeth I (1558–1603) had converted most of the country to Protestantism (Little-Endianism), in the episcopalian form of the Church of England. At the same time, revolution and reform in Scotland (1560) had also converted that country to Presbyterian Protestantism, which led to fresh difficulties when England and Scotland were united under one ruler, James I (1603–1625).

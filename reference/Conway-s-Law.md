# Conway's Law

ALIAS: Ley de Conway

> Organizations which design systems are constrained to produce designs which are copies of the communication structures of these organizations.

Simplified version:

> Any piece of software reflects the organizational structure that produced it.

Basically:

> You will ship your org chart.

The modular decomposition of a system and the decomposition of the development organization must be done together. This isn't just at the beginning, evolution of the architecture and reorganizing the human organization must go hand-in-hand throughout the life of an enterprise.

Although we usually discuss it with respect to software, the observation applies broadly to systems in general.

Many organizations divide teams by function, which have poor communication and, in some cases, even *silos* (complete isolation).

> If a single team writes a compiler, it will be a one-pass compiler, but if the team is divided into two, then it will be a two-pass compiler. 

Changes that one of these teams wants or needs to make may fall into another's territory. The independent decisions of each group are made to seek local optimization, maximizing the objectives of the function, not who consumes the resulting product.

All this will result in a final system with gaps.

> Conway understood that software coupling is enabled and encouraged by human communication.
>
> -- Chris Ford

If I can talk easily to the author of some code, then it is easier for me to build up a rich understanding of that code. This makes it easier for my code to interact, and thus be coupled, to that code. Not just in terms of explicit function calls, but also in the implicit shared assumptions and way of thinking about the problem domain.

A dozen or two people can have deep and informal communications, so Conways Law indicates they will create a monolith.

Since the current form of the organization affects the resulting system,

> If you don't want your system to look like your organization, **change your organization**

## Do not to fight it
  
Recognize the impact of Conway's Law, and ensure your architecture doesn't clash with designers' communication patterns.

big impact location has on human communication.

Components developed in different time-zones needed to have a well-defined and limited interaction because their creators would not be able to talk easily

architect of a large new project that consisted of six teams in different cities all over the world. "I made my first architectural decision" he told me. "There are going to be six major subsystems. I have no idea what they are going to be, but there are going to be six of them."

While location makes a big contribution to in-person communication patterns, one of the features of [remote-first](https://martinfowler.com/articles/remote-or-co-located.html#remote-first) working, is that it reduces the role of distance, as everyone is communicating online. Conway's Law still applies, but it's based on the online communication patterns. Time zones still have a big effect, even online.

## Inverse Conway Maneuver

Change the communication patterns of the designers to encourage the desired software architecture.

alter the development team's organization structure to encourage the desired software architecture, an approach referred to as the **Inverse Conway Maneuver**

The term "inverse Conway maneuver" was coined by Jonny LeRoy and Matt Simons in [an article](https://web.archive.org/web/20221020175558/https://jonnyleroy.com/2011/02/03/dealing-with-creaky-legacy-platforms/) published in the December 2010 issue of the Cutter IT journal.

This approach is often talked about in the world of [microservices](https://martinfowler.com/articles/microservices.html#OrganizedAroundBusinessCapabilities), where advocates advise building small, long-lived [BusinessCapabilityCentric](https://martinfowler.com/bliki/BusinessCapabilityCentric.html) teams that contain all the skills needed to deliver customer value. By organizing autonomous teams this way, we employ Conway's Law to encourage similarly autonomous services that can be enhanced and deployed independently of each other.

If you have an existing system with a rigid architecture that you want to change, changing the development organization [isn't going to be an instant fix](https://verraes.net/2022/05/conways-law-vs-rigid-designs/). Instead it's more likely to result in a mismatch between developers and code that adds friction to further enhancement. With an existing system like this, the point of Conway's Law is that we need to take into account its presence while changing both organization and code base. And as usual, I'd recommend taking small steps while being vigilant for feedback.

## Origin

Coined by Melvin Conway, who introduced the idea in 1967. His original words were:

> Any organization that designs a system (defined broadly) will produce a design whose structure is a copy of the organization's communication structure.
>
> -- Melvin E. Conway

The source for Conway's law is [an article](https://www.melconway.com/Home/Committees_Paper.html) written by Melvin Conway in 1968. It was published by Datamation, one of the most important journals for the software industry at that time. It was later dubbed "Conway's Law" by Fred Brooks in his hugely influential book [The Mythical Man-Month](https://www.amazon.com/gp/product/0201835959/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0201835959&linkCode=as2&tag=martinfowlerc-20). I ran into it there at the beginning of my career in the 1980s, and it has been a thought-provoking companion ever since.

## Linked Sources

- <https://en.wikipedia.org/wiki/Conway%27s_law>
- [Famous laws of Software development](https://www.timsommer.be/famous-laws-of-software-development/) - Tim Sommer
- [10 Laws of Software Engineering That People Ignore](https://www.indiehackers.com/post/10-laws-of-software-engineering-that-people-ignore-e3439176dd)
- [hacker-laws > Conway's Law](https://github.com/dwmkerr/hacker-laws#conways-law)
- [Conway's Law](https://martinfowler.com/bliki/ConwaysLaw.html)
- [Conway's Law, DDD, and Microservices](https://ardalis.com/conways-law-ddd-and-microservices/)

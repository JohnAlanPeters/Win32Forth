\ $Id: Release.f,v 1.3 2014/08/06 12:30:30 georgeahubert Exp $

\ Release.f - reminders for creating a new release

\s

\ ------------------------------------
\ REMINDERS FOR BUILDING A NEW RELEASE
\ ------------------------------------

- Change version number in Version.f

- Handle evolve.f between releases :
  - Rename previous evolve.f as evolve?????.f where ????? is the previous release)
    (in this way, the history of changes is made available to the user)
  - Prepare a new, empty, file Evolve.f for the next under-development version
  - Check "reminders" in previous evolve.f as, once some words are definitively
    removed, we are allowed to make some changes in some files.




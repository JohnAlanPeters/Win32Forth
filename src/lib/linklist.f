\ $Id: linklist.f,v 1.1 2004/12/21 00:19:10 alex_mcdonald Exp $

\ ----------------------------------------------------------------------------
\ ----- A Generic Linked-List Class          29-OCT-97 Mike Kemper
\ ----------------------------------------------------------------------------
\
\ Creation:
\    Linked-List  <ListName>              ; define a link-list with 1 link
\
\ NOTE: A more useful approach is to define an object type for your data
\       record, then define a new class (of type Linked-List) which has
\       modifiers for the needed functions (AddRecord, DeleteRecord, etc)
\       which will create instances of your data object and store their
\       address in the linked list data parameter.
\
\ List Management Methods:
\     Data@:      (  -- n )         ; Get data item at current link
\     Data!:      ( n --  )         ; Set data item at current link
\     FirstLink?: (  -- f )         ; is current link the first link?
\     LastLink?:  (  -- f )         ; is current link the last link?
\     >PrevLink:  (  --  )          ; move link ptr to prev link
\     >NextLink:  (  --  )          ; move link ptr to next link
\     >LastLink:  (  --  )          ; move link ptr to last link
\     >FirstLink: (  --  )          ; move link ptr to first link
\     >Link#:     ( n --  )         ; move link ptr to specified link
\     #links:     (  -- n )         ; get total # of links
\     Link#:      (  -- n )         ; get # of current link
\     AddLink:    (  --  )          ; add link to end of list
\     InsertLink: (  --  )          ; insert link before current link
\     DeleteLink: (  --  )          ; delete current link
\     PrevLink:   (  -- n )         ; get previous link address
\     NextLink:   (  -- n )         ; get next link address
\     CurrLink@:  (  -- n )         ; get current link address
\     PurgeList:  (  --  )          ; delete all links

anew -linklist.f

internal
external

\ ----- Link object

:CLASS Link <SUPER object

   record: LinkStuff
      int PrevLink
      int NextLink
      int Data       \ pointer to data object
   ;record

   :M ClassInit: (  --  )
      ClassInit: super
      0 to PrevLink
      0 to NextLink
      0 to Data ;M

   :M SetPrev: ( n --  )  to PrevLink ;M         \ set addr of prev record
   :M GetPrev: (  -- n )  PrevLink ;M         \ get addr of prev record, 0 = first
   :M SetNext: ( n --  )  to NextLink ;M         \ set addr of next record
   :M GetNext: (  -- n )  NextLink ;M         \ get addr of next record, 0 = last
   :M SetData: ( addr --  )   to Data ;M         \ set data item/ptr
   :M GetData: (  -- addr )   Data  ;M         \ get data item/ptr
;CLASS


\ ----- List object

:CLASS Linked-List <SUPER Object

   int CurrentLink                          \ address of active link
   int FirstLink                            \ address of first link
   int TempLink                             \ temp storage for switching links
   int TempPrev                             \
   int TempNext                             \

   :M ClassInit: (  --  )
      ClassInit: super
      0 to CurrentLink
      0 to FirstLink
      0 to TempLink
      0 to TempPrev
      0 to Tempnext

      new> Link dup to CurrentLink              \ create first record
      to FirstLink ;M                           \ label this link as the first in the list


\ ----- List Management Control Methods

   :M Data@: (  -- n )                          \ get data/pointer
      GetData: CurrentLink ;M

   :M Data!: ( n --  )                          \ set data/pointer
      SetData: CurrentLink ;M

   :M FirstLink?: (  -- f )
      GetPrev: Currentlink 0= ;M                \ is current link the first in the list?

   :M LastLink?: (  -- f )
      GetNext: CurrentLink 0= ;M                \ is current link the last in the list?

   :M >PrevLink: (  --  )
      FirstLink?: self  0= if
         GetPrev: CurrentLink to CurrentLink    \ move to previous link
      then ;M

   :M >NextLink: (  --  )
      LastLink?: self  0= if
         GetNext: CurrentLink to CurrentLink    \ move to next link
      then ;M

   :M >LastLink: (  --  )
      begin
         >NextLink: self                        \ move to next link
         LastLink?: self                        \ is it the last link?
      until ;M

   :M >FirstLink: (  --  )
      FirstLink to CurrentLink ;M

   :M >Link#: ( n --  )
      1 max  1-                                 \ don't allow negative #'s
      FirstLink to CurrentLink                  \ start at first link
      ?dup if
         0 do  >NextLink: self  loop            \ move down n links
      then ;M

   :M #links: (  -- n )
      CurrentLink                               \ save current location
      FirstLink to CurrentLink                  \ start at first link
      0 begin
         1+                                     \ add 1 to link count
         LastLink?: self                        \ force terminate if last
         >NextLink: self                        \ try to move to next link
      until                                     \ continue till finished
      swap to CurrentLink ;M                    \ restore current location

   :M Link#: (  -- n )  \ --- return # of current link
      CurrentLink to TempLink                   \ save current location
      FirstLink to CurrentLink                  \ start at first link
      0 begin
         1+  CurrentLink TempLink =             \ increment and compare
         LastLink?: self or
         >NextLink: self                        \ jump to next...count + 1
      until

      TempLink to CurrentLink ;M                \ restore current location

   :M AddLink: (  --  )  \ --- Add line at end of document and makes it current
      >LastLink: self                           \ move to last link
      CurrentLink to TempPrev                   \ get pointer to current link
      new> Link to CurrentLink                  \ create new link
      CurrentLink SetNext: TempPrev             \ update prev link's next link ptr
      TempPrev    SetPrev: CurrentLink          \ point back to prev record
      0 SetNext: CurrentLink ;M                 \ mark this link as the last link

   :M InsertLink: (  --  )  \ --- Insert link just before current link
      FirstLink?: self if
         CurrentLink to TempNext                \ break chain
         new> Link to CurrentLink               \ create new record
         GetPrev: TempNext SetPrev: CurrentLink \ update links
         CurrentLink SetPrev: TempNext          \
         TempNext  SetNext: CurrentLink         \
         CurrentLink to FirstLink               \ set current record as first record
      else
         GetPrev: CurrentLink to TempPrev       \ find prev link
         CurrentLink to TempNext                \ break chain
         new> Link to CurrentLink               \ create new record
         GetNext: TempPrev SetNext: CurrentLink \ update links
         GetPrev: TempNext SetPrev: CurrentLink \
         CurrentLink  SetNext: TempPrev         \
         CurrentLink  SetPrev: TempNext         \
      then ;M

   :M PurgeList: (  --  )
      >LastLink: self
      FirstLink?: self 0= if
         begin
            CurrentLink to TempLink             \ get addr of current link
            >PrevLink: self                     \ move back one link
            TempLink dispose                    \ delete link
            FirstLink?: self                    \ continue until all links gone (but 1st)
         until
         0 SetNext: CurrentLink                 \ Set single link as first and last
      then ;M


   \ ----- These functions assume that we are currently pointing to the
   \       link that is to be removed

   : DeleteFirst (  --  )  \ --- Delete first link in the list
      CurrentLink to TempLink             \ get addr of record to remove
      >NextLink: self                     \ move to next link
      TempLink dispose                    \ destroy the link
      CurrentLink to FirstLink            \ mark link as first in the list
      0 SetPrev: CurrentLink ;            \

   : DeleteLast (  --  )   \ --- Delete last link in the list
      CurrentLink to TempLink             \ get addr of record to remove
      >PrevLink: self                     \ move to previous link
      TempLink dispose                    \ destroy the link
      0 SetNext: CurrentLink ;            \ mark link as last in the list

   : DeleteLink (  --  )   \ --- Delete current link and position on next
      GetNext: CurrentLink to TempNext    \ get links on either side
      GetPrev: CurrentLink to TempPrev    \
      TempPrev SetPrev: TempNext          \ link them together
      TempNext SetNext: TempPrev          \
      CurrentLink to TempLink             \ get addr of link to destroy
      >NextLink: self                     \ move to next link
      TempLink dispose ;                  \ destroy the record

   :M DeleteLink: (  --  )  \ --- delete current line
      FirstLink?: self
      LastLink?: self  and if             \ only link in the list?
         PurgeList: self                  \ yes...purge list
      else
         FirstLink?: self if              \ first link in the list?
            DeleteFirst                   \ yes...remove and position on next
         else
            LastLink?: self if            \ last link in the list?
               DeleteLast                 \ yes...remove and position on prev
            else
               DeleteLink                 \ no...remove and link prev to next
            then
         then
      then ;M

   :M PrevLink:   (  -- n )  GetPrev: CurrentLink ;M
   :M NextLink:   (  -- n )  GetNext: CurrentLink ;M
   :M CurrLink@: (  -- n )  CurrentLink ;M


\ ----- Object Cleanup

   :M ~: (  --  )  \ --- class destructor
      PurgeList: self                           \ deallocate document storage
      CurrentLink dispose ;M                    \ remove first (and only remaining) record

;CLASS


: DisposeList   { list \ -- }
                >FirstLink: list
                #Links: list 0
                do   Data@: list ?dup
                     if   Dispose
                          0 Data!: list
                     then DeleteLink: list
                     >NextLink: list
                loop ;

MODULE

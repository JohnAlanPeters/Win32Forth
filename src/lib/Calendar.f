\ $Id: Calendar.f,v 1.9 2013/12/09 19:42:00 georgeahubert Exp $

\ *D doc\classes\
\ *> Controls

anew -Calendar.f

Require control.f

WinLibrary COMCTL32.DLL

cr .( Loading Calendar Classes...)

\ *P The MonthCalendar and TimeDatePicker controls both use a structure, the members 
\ ** of which are;

\ *Q Year
\ ** The year (1601 - 30827).
\ **
\ ** Month
\ **
\ ** January = 1
\ ** February = 2
\ ** March = 3
\ ** April = 4
\ ** May = 5
\ ** June = 6
\ ** July = 7
\ ** August = 8
\ ** September = 9
\ ** October = 10
\ ** November = 11
\ ** December = 12
\ **
\ ** DayOfWeek
\ **
\ ** Sunday = 0
\ ** Monday = 1
\ ** Tuesday = 2
\ ** Wednesday = 3
\ ** Thursday = 4
\ ** Friday = 5
\ ** Saturday = 6
\ **
\ ** Day
\ ** The day of the month (0-31).
\ ** Hour
\ ** The hour (0-23).
\ ** Minute
\ ** The minute(s) (0-59).
\ ** Second
\ ** The second(s) (0-59).
\ ** Milliseconds
\ ** The millisecond(s) (0-999).

in-system

|Class DateTimeControl <super Control

in-previous

Record: Time
short year
short month
short DayOfWeek
short Day
short Hour
short Minute
short Second
short MilliSeconds
;RecordSize: SizeOfTime

: SendTimeMessage ( message -- )
              >r Time 0 r> SendMessage:Self ?Win-Error ;

: Date>       ( -- day month year )
              day month year ;

: >Date       ( day month year -- )
              to day to month to year ;

;Class

\ ------------------------------------------------------------------------
\ *W <a name="MonthCalendar"></a>
\ *S MonthCalendar class
\ ------------------------------------------------------------------------
:Class MonthCalendar	<Super DateTimeControl
\ *G Month Calendar control.
\ ** A month calendar control implements a calendar-like user interface. This
\ ** provides the user with a very intuitive and recognizable method of entering
\ ** or selecting a date.

:M Start:       ( Parent -- )
\ *G Create the control.
                to parent
                ICC_DATE_CLASSES 8 sp@ Call InitCommonControlsEx 3drop
                z" SysMonthCal32" Create-Control
                ;M

:M MinSize: 	( -- x y )
\ *G Return minimum size required to display a month.
                EraseRect: winRect
                winRect 0 MCM_GETMINREQRECT SendMessage:Self ?Win-Error
                Right: winRect Bottom: winRect
                ;M

:M GetDate:     ( -- day month year )
\ *G Retrieves the currently selected date.
\ *P \i day \d is the day of the month (0-31).
\ *P \i Month \d is the month (January = 1; December = 12)
\ *P \i year \d is the year (1601 - 30827).
\                 _SystemTime 0  MCM_GETCURSEL SendMessage:SelfDrop
\                 wday w@ wmonth w@ wyear w@ ;M
                MCM_GETCURSEL SendTimeMessage
                date> ;M

:M GetToday:    ( -- day month year )
\ *G Retrieves the date information for the date specified as "today".
\ *P \i day \d is the day of the month (0-31).
\ *P \i Month \d is the month (January = 1; December = 12)
\ *P \i year \d is the year (1601 - 30827).
\                 MCM_GETTODAY SendMessage:Self ?Win-Error
\                 wday w@ wmonth w@ wyear w@ ;M
                MCM_GETTODAY SendTimeMessage
                date> ;M

;Class
\ *G End of MonthCalendar class

\ ------------------------------------------------------------------------
\ *W <a name="DateTimePicker"></a>
\ *S DateTimePicker class
\ ------------------------------------------------------------------------
:Class DateTimePicker   <Super DateTimeControl
\ *G Date and Time Picker control

:M Start:       ( Parent -- )
\ *G Create the control.
                to parent
                ICC_DATE_CLASSES 8 sp@ Call InitCommonControlsEx 3drop
                z" SysDateTimePick32" Create-Control
                ;M

\ *P Date and Time Picker Control Styles \n
\ **
\ ** The window styles listed here are specific to date and time picker controls. \n
\ **
\ ** Constants \n
\ ** DTS_APPCANPARSE \n
\ ** Allows the owner to parse user input and take necessary action. It enables users
\ ** to edit within the client area of the control when they press the F2 key.
\ ** The control sends DTN_USERSTRING notification messages when users are finished. \n
\ **
\ ** DTS_LONGDATEFORMAT \n
\ ** Displays the date in long format. The default format string for this style is
\ ** defined by LOCALE_SLONGDATEFORMAT, which produces output like "Friday, April
\ ** 19, 1996". \n
\ **
\ ** DTS_RIGHTALIGN \n
\ ** The drop-down month calendar will be right-aligned with the control instead of
\ ** left-aligned, which is the default. \n
\ **
\ ** DTS_SHOWNONE \n
\ ** It is possible to have no date currently selected in the control. With this style,
\ ** the control displays a check box that users can check once they have entered or
\ ** selected a date. Until this check box is checked, the application will not be
\ ** able to retrieve the date from the control because, in essence, the control has
\ ** no date. This state can be set with the DTM_SETSYSTEMTIME message or queried
\ ** with the DTM_GETSYSTEMTIME message. \n
\ **
\ ** DTS_SHORTDATEFORMAT \n
\ ** Displays the date in short format. The default format string for this style is
\ ** defined by LOCALE_SSHORTDATE, which produces output like "4/19/96". \n
\ **
\ ** DTS_SHORTDATECENTURYFORMAT \n
\ ** Version 5.80. Similar to the DTS_SHORTDATEFORMAT style, except the year is a
\ ** four-digit field. The default format string for this style is based on
\ ** LOCALE_SSHORTDATE. The output looks like: "4/19/1996". \n
\ **
\ ** DTS_TIMEFORMAT \n
\ ** Displays the time. The default format string for this style is defined by
\ ** LOCALE_STIMEFORMAT, which produces output like "5:31:42 PM". \n
\ **
\ ** DTS_UPDOWN \n
\ ** Places an up-down control to the right of the DTP control to modify date-time
\ ** values. This style can be used in place of the drop-down month calendar, which
\ ** is the default style. \n
\ **
\ ** Remarks \n
\ **
\ ** The DTS_XXXFORMAT styles that define the display format cannot be combined.
\ ** If none of the format styles are suitable, use a DTM_SETFORMAT message to
\ ** define a custom format.

:M SetCustomFormat:   ( z"format"  -- )
\ *G set the display format for time or date
                0 DTM_SETFORMAT SendMessage:Self ?Win-Error
                ;M

\ *P Format Strings
\ ** A DTP format string consists of a series of elements that represent a particular
\ ** piece of information and define its display format. The elements will be displayed
\ ** in the order they appear in the format string. \n
\ **
\ ** Date and time format elements will be replaced by the actual date and time. They are
\ ** defined by the following groups of characters: \n
\ **
\ ** Element     Description \n
\ ** "d"     The one- or two-digit day. \n
\ ** "dd"    The two-digit day. Single-digit day values are preceded by a zero. \n
\ ** "ddd"   The three-character weekday abbreviation. \n
\ ** "dddd"  The full weekday name. \n
\ ** "h"     The one- or two-digit hour in 12-hour format. \n
\ ** "hh"    The two-digit hour in 12-hour format. Single-digit values are preceded by
\ ** a zero. \n
\ ** "H"     The one- or two-digit hour in 24-hour format. \n
\ ** "HH"    The two-digit hour in 24-hour format. Single-digit values are preceded by
\ ** a zero. \n
\ ** "m"     The one- or two-digit minute. \n
\ ** "mm"    The two-digit minute. Single-digit values are preceded by a zero. \n
\ ** "M"     The one- or two-digit month number. \n
\ ** "MM"    The two-digit month number. Single-digit values are preceded by a zero. \n
\ ** "MMM"   The three-character month abbreviation. \n
\ ** "MMMM"  The full month name. \n
\ ** "t"     The one-letter AM/PM abbreviation (that is, AM is displayed as "A"). \n
\ ** "tt"    The two-letter AM/PM abbreviation (that is, AM is displayed as "AM"). \n
\ ** "yy"    The last two digits of the year (that is, 1996 would be displayed as "96"). \n
\ ** "yyyy"  The full year (that is, 1996 would be displayed as "1996"). \n
\ **
\ ** To make the information more readable, you can add body text to the format string
\ ** by enclosing it in single quotes. Spaces and punctuation marks do not need to be
\ ** quoted. \n
\ **
\ ** \b Note \d   Nonformat characters that are not delimited by single quotes will
\ ** result in unpredictable display by the DTP control. \n
\ **
\ ** For example, to display the current date with the format
\ ** "'Today is: 04:22:31 Tuesday Mar 23, 1996", the format string is
\ ** "'Today is: 'hh':'m':'s dddd MMM dd', 'yyyy". To include a single quote in your
\ ** body text, use two consecutive single quotes. For example,
\ ** "'Don''t forget' MMM dd',' yyyy" produces output that looks like: \n
\ ** Don't forget Mar 23, 1996. \n
\ ** It is not necessary to use quotes with the comma, so
\ ** "'Don''t forget' MMM dd, yyyy" is also valid, and produces the same output.

:M GetTime:     ( -- hrs min secs )
\ *G get user selected time
\                 _SystemTime 0 DTM_GETSYSTEMTIME SendMessage:Self GDT_VALID =
\                 if      wHour w@ wMinute w@ wSecond w@
\                 else    0 0 0
\                 then    ;M
                0 DTM_GETSYSTEMTIME SendTimeMessage
                Hour Minute Second     ;M

:M SetTime:     ( hr min sec -- )
\ *G set time for user to edit
\                 wSecond w! wMinute w! wHour w!
\                 0 wMilliSeconds w!
\                 _SystemTime GDT_VALID DTM_SETSYSTEMTIME SendMessage:Self ?Win-Error
\                  ;M
                to Second to Minute to Hour
                0 to MilliSeconds
                DTM_SETSYSTEMTIME SendTimeMessage
                 ;M

:M GetDate:     ( -- day month year )
\ *G get user selected date
\                 GetTime: self 3dup or or 0<>
\                 if      3drop wDay w@ wMonth w@ wYear w@
\                 then    ;M
                GetTime: self 3dup or or 0<>
                if      3drop Date>
                then    ;M

;Class
\ *G End of DateTimePicker class

\ *Z

# callistevents #

This is a quick command line program written by Brett Hutley <brett@hutley.net> which lists all the events in the specified calendar between two dates.

For example:

    callistevents -c Pomodoros -s 2013-05-27 -e 2013-05-29

This lists all the events in the "Pomodoros" calendar between the 27th May 2013 and 29th May 2013.

It returns the events as "Event Title <TAB> Start Date Time <TAB> End Date Time". e.g.

    10 minutes Pomodoro 'Create an index page for TweetGen'	28/05/2013 11:22	28/05/2013 11:32
    10 minutes Pomodoro 'Review Book 3 Flashcards'	28/05/2013 11:42	28/05/2013 11:52
    10 minutes Pomodoro 'Put website under source control'	28/05/2013 11:57	28/05/2013 12:07


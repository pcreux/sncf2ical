# SNCF2iCal

Fetch all emails from voyages-sncf.com from your GMail inbox, parse them
and create events in Google Calendar accordingly.

## Usage

* 1. Clone this project.
* 2. Run `bundle install`
* 3. Run `ruby bin/sncf2ical.rb`. It will prompt your for your google
  username and password, fetch all travel confirmation from your Inbox
  and add them as events to your Google Calendar. 

You might see some weird output and error messages. This is due to the
GoogleCalendar gem not playing very nicely with GoogleCalendar. The
events should have been created though.

Once done, you can archive all those emails so that the events don't get
duplicated the next time you run this script.

## Notes

This is a quick hack. I don't plan to maintain this project. Feel free
to fork it & improve it!

## License

MIT

## Author

Philippe Creux

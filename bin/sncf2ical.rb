require File.expand_path('../lib/sncf2ical', File.dirname(__FILE__))

require 'highline/import'

USERNAME = ask('Username: ')
PASSWORD = ask('Password: ') { |q| q.echo = false }

include Sncf2Ical

emails = GmailMessages.new(USERNAME, PASSWORD).ticket_confirmation_emails

puts "Processing #{emails.size} emails"

emails.each_with_index do |email, index|
  begin
    html_email = email.html_part
    # This happens with emails before July 2011
    raise "No html_part in email" unless html_email
    html_email_body = html_email.decoded

    EmailParser.new(html_email_body).itineraries.each do |i|
      puts "Pushing itinerary #{i.inspect}"
      p i.push_to_google_calendar
    end
  rescue
    p $!
  end
end
puts "Now check your GoogleCalendar. It should have worked even if you see errors in the output above"

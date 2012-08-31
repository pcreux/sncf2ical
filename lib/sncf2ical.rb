class String
  def titleize
    self.split(' ').collect {|word| word.capitalize}.join(" ")
  end
end


require 'rubygems'
require 'bundler'

Bundler.require

module Sncf2Ical
  class GmailMessages
    attr_reader :ticket_confirmation_emails

    def initialize(username, password)
      Gmail.new(username, password) do |gmail|
        @ticket_confirmation_emails = fetch_emails(gmail)
      end
    end

    protected

    def fetch_emails(gmail)
      #emails = gmail.mailbox("[Gmail]/All Mail").emails(:from => 'noreply@voyages-sncf.com', :after => Date.parse("2011-09-01")).map(&:message)
      gmail.inbox.
        emails(:from => 'noreply@voyages-sncf.com').map(&:message).
        select { |email| email.subject.include? 'Confirmation pour votre voyage' }
    end
  end # class GmailMessages

  class EmailParser
    attr_reader :html_email_body

    def initialize(html_email_body)
      @html_email_body = html_email_body
    end

    def itineraries
      [fetch_travel('Aller'), fetch_travel('Retour')].compact
    end

    def fetch_travel(type)
      #Samedi 1 SeptembreAller : 16h15VALENCE   GARE TGV54041\r\n                e\r\n                Classe17h20MARSEILLE SAINT CHARLES
      #Dimanche 2 SeptembreRetour : 18h08MARSEILLE SAINT CHARLES61301\r\n                e\r\n                Classe19h08VALENCE   GARE TGV
      match_data = text.match /(Lundi|Mardi|Mercredi|Jeudi|Vendredi|Samedi|Dimanche) (\d{1,2}) (\D+)#{type} : (\d\dh\d\d)(\D+)\d+\s+e\s+Classe(\d\dh\d\d)(\D+)/

      if match_data
        Itinerary.new.tap do |i|
          i.date = match_data[1..3].join(' ')
          i.departure_time = match_data[4]
          i.from = match_data[5].gsub(/\s+/, ' ')
          i.arrival_time = match_data[6]
          i.to = match_data[7].gsub(/\s+/, ' ')
        end
      else
        nil
      end
    end

    def text
      strip_html(html_email_body)
    end

    def strip_html(string)
      re = /<[^>]*(>+|\s*\z)/m
      string.gsub(re,'')
    end
  end # class EmailParser

  class Itinerary
    attr_accessor :from, :to, :departure_time, :arrival_time, :date 

    def to_ical
      RiCal.Calendar do |cal|
        cal.event do |event|
          event.summary     = "#{from}\n#{to}".titleize # TODO Capitalize words
          event.dtstart     = NaturalTime.new("#{date} #{departure_time}").utc_time
          event.dtend       = NaturalTime.new("#{date} #{arrival_time}").utc_time
          #event.description = 
          #event.location    = "Cape Canaveral"
          #event.add_attendee  "john.glenn@nasa.gov"
          #event.url         = "http://nasa.gov"
        end
      end
    end # def to_ical

    def push_to_google_calendar
      # TODO: Use reliable API. I'm getting weird response code and intermittent failure with this gem
      g = Googlecalendar::GData.new
      g.login("#{USERNAME}@gmail.com", PASSWORD)
      event = { :title     => "#{from} - #{to}".titleize,
                #:content   => 'content',
                :author    => USERNAME,
                :email     => "#{USERNAME}gmail.com",
                #:where     => 'Toulouse,France',
                :startTime => NaturalTime.new("#{date} #{departure_time}").utc_time.strftime('%Y-%m-%dT%H:%M:%S.00Z'),
                :endTime   => NaturalTime.new("#{date} #{arrival_time}").utc_time.strftime('%Y-%m-%dT%H:%M:%S.00Z')}
      r = g.new_event(event)
      p r.code
      if r.code == '200'
        true
      else
        p r.body
        false
      end
    end
  end # class Itinary

  class NaturalTime
    attr_reader :natural_time, :year, :month, :day, :hour, :minute


    # @param natural_time [String] "Lundi 3 Octobre 9h30"
    def initialize(natural_time)
      @natural_time = natural_time
      parse_natural_time
      validate_time
    end

    # @return [Time]
    def utc_time
      Time.utc(year, month, day, hour, minute)
    end


    def parse_natural_time
      match_data = @natural_time.match /(\w+) (\d+) (\w+) (\d+)h(\d+)/

      _, day_of_the_week, day, month, hour, minute = match_data.to_a

      @year = Time.now.year
      @month = month_number(month)
      @day = day
      @hour = hour.to_i - 2 # UTC wihout DST FIXME Should use proper timezone mechanism
      @minute = minute.to_i
    end

    def month_number(month)
      months = %w(Janvier Fevrier Mars Avril Mai Juin Juillet Aout Septembre Octobre Novembre Decembre)
      
      if number = months.index(month)
        number + 1
      else
        raise "#{month} does not match any month. Available months: #{months}"
      end
    end

    def validate_time
      raise "Failed to parse time" unless year && month && day && hour && minute
    end
  end
end

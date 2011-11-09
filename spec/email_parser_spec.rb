require 'spec_helper'

describe EmailParser do
  let(:email) { 
    File.read(File.expand_path('email_0.html', File.dirname(__FILE__)))
  }

  let(:parser) { EmailParser.new email }

  describe "First Itinerary" do
    subject { parser.itineraries.first }

    its(:from) { should == "MARSEILLE ST CHARLES" }
    its(:to) { should == "VALENCE CENTRE" }
    its(:departure_time) { should == "07h39" }
    its(:arrival_time) { should == "09h10" }
    its(:date) { should == "Lundi 3 Octobre" }
  end
end

describe Itinerary do
  describe '#to_ical' do
    it "should be tested"
  end
end

describe NaturalTime, :utc_time do
  it "should parse 'Lundi 3 Octobre 9h30'" do
    NaturalTime.new('Lundi 3 Octobre 9h30').utc_time.should ==
      Time.utc(2011, 10, 3, 7, 30) # DST FIXME should not be hard coded
  end

  it "should set the year knowing that events should be in the next three months max"
end

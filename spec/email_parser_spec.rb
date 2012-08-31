require 'spec_helper'

describe EmailParser do
  before(:all) do
    @email = File.read(File.expand_path('email_0.html', File.dirname(__FILE__)))
    @parser = EmailParser.new @email
    @aller = @parser.itineraries.first
    @retour = @parser.itineraries.last
  end


  describe "First Itinerary" do
    subject { @aller }

    its(:from) { should == "VALENCE GARE TGV" }
    its(:to) { should == "MARSEILLE SAINT CHARLES" }
    its(:departure_time) { should == "16h15" }
    its(:arrival_time) { should == "17h20" }
    its(:date) { should == "Samedi 1 Septembre" }
  end

  describe "Second Itinerary" do
    subject { @retour }

    its(:from) { should == "MARSEILLE SAINT CHARLES" }
    its(:to) { should == "VALENCE GARE TGV" }
    its(:departure_time) { should == "18h08" }
    its(:arrival_time) { should == "19h08" }
    its(:date) { should == "Dimanche 2 Septembre" }
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
      Time.utc(2012, 10, 3, 7, 30) # DST FIXME should not be hard coded
  end

  it "should set the year knowing that events should be in the next three months max"
end

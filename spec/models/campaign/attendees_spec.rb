describe Campaign do
  
  describe '#attendees' do
    
    let(:campaign) { FG.create :campaign, :almost_fulfilled }
    
    def the_query
      Attendee.joins(:pledges).where({pledges: {campaign_id: campaign.id}})
    end
    
    it "returns the corresponding attendees" do
      expect(campaign.attendees.pluck(:id).sort).to eq(the_query.pluck(:id).sort)
    end
    
    [true, false].each do |has_stripe_charge_id|
      
      context "pledged with#{"out" unless has_stripe_charge_id} stripe_charge_id set" do
        
        let!(:pledge){
          options = {campaign: campaign}
          options.merge!(stripe_charge_id: nil) unless has_stripe_charge_id
          FG.create :pledge, options
        }
        
        it "is #{"not " unless has_stripe_charge_id}taken into account" do
          
          if has_stripe_charge_id
            expect(campaign.pledges).to include pledge
            expect(campaign.attendees).to include pledge.attendee
          else
            expect(campaign.pledges).to_not include pledge
            expect(campaign.attendees).to_not include pledge.attendee
          end
          
        end

      end
      
    end
    
  end
  
end
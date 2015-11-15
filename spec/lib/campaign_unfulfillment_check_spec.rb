describe CampaignUnfulfillmentCheck do
  
  describe '#run' do
    
    let(:campaign){
      FG.create(:campaign)
    }
    
    before {
      campaign.update_attributes!(ends_at: DateTime.now)
    }
    
    def the_action
      CampaignUnfulfillmentCheck.run
    end
    
    it 'sets the unfulfilled_at column' do
      expect {
        the_action
      }.to change {
        campaign.reload.unfulfilled_at.nil?
      }.from(true).to(false)
    end
    
    it 'sets the unfulfilled_at to the time of when it did run' do
      the_action
      expect(campaign.reload.unfulfilled_at).to be_within(1.second).of DateTime.now
    end
    
  end
  
end
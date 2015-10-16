describe 'Pledge creation' do
  
  let(:campaign){ FG.create :campaign }
  
  after {
    page_ok
  }
  
  def the_selector
    "#pledge-submit"
  end
  
  def the_action
    find(the_selector).click
  end
  
  context 'as an attendee' do
    sign_as :attendee, :feature
    
    before {
      visit campaign_path(campaign)
    }

    it 'is possible to pledge for a campaign' do
      expect {
        the_action
      }.to change {
        campaign.pledges.count
      }.by(1)
    end
    
    it 'is not possible to pledge again' do
    
      the_action
      expect(all(the_selector).size).to be 0
      expect(page).to have_content(t 'pledges.form.contributed', contributed: attendee.attendee.pledged_for(Campaign.last).format)
      
    end
    
  end
  
end
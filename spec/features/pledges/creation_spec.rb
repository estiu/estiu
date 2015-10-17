describe 'Pledge creation' do
  
  let(:campaign){ FG.create :campaign }
  
  after {
    page_ok
  }
  
  context 'as an attendee' do
    sign_as :attendee, :feature
    
    before {
      Pledge.create!(attendee: attendee.attendee, campaign: campaign, amount_cents: campaign.recommended_pledge_amount_cents)
      visit campaign_path(campaign)
    }

    it 'is not possible to pledge again' do
    
      expect(page).to have_content(t 'pledges.form.contributed', contributed: attendee.attendee.pledged_for(Campaign.last).format)
      
    end
    
  end
  
end
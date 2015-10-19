describe 'Pledge creation' do
  
  let(:campaign){ FG.create :campaign }
  
  after {
    page_ok
  }
  
  context 'as an attendee' do
    sign_as :attendee, :feature
    
    context 'if the attendee has already pledged' do
      
      before {
        Pledge.create!(attendee: attendee.attendee, campaign: campaign, amount_cents: campaign.recommended_pledge_cents, stripe_charge_id: SecureRandom.hex)
        visit campaign_path(campaign)
      }

      it 'is not possible to pledge again' do
      
        expect(page).to have_content(t 'pledges.form.contributed', contributed: attendee.attendee.pledged_for(Campaign.last).format)
        
      end
      
    end
    
  end
  
end
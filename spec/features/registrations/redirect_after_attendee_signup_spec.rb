describe "Attendee registration after viewing a particular campaign" do
  
  let(:campaign){ FG.create :campaign }
  let(:user){ FG.build :user, :attendee_role }
  
  let(:expected_final_path){
    campaign_path(campaign)
  }
  
  def the_test
    
    visit campaign_path(campaign)
    
    find('#sign-up-from-campaign').click
    
    fill_attendee_signup_form
    
    expect {
      find("input[type='submit']").click
    }.to change {
      User.count
    }.by(1).and change {
      Attendee.count
    }.by(1)
    
    expect(User.last.attendee.entity_type_shown_at_signup).to eq 'campaign'
    expect(User.last.attendee.entity_id_shown_at_signup).to eq campaign.id
    
    expect(current_path).to eq expected_final_path
  
  end
  
  it 'redirects to the viewed campaign after signup' do
    the_test  
  end
  
  context 'causality' do
    
    let(:expected_final_path){
      root_path
    }
    
    before { allow(Causality).to receive(:checking?).exactly(1).times.with('RegistrationsController#attendee_common_path').and_return(true) }
    
    it 'relates' do
      the_test
    end
    
  end
  
end
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
    
    expect(current_path).to eq expected_final_path
  
  end
  
  it 'redirects to the viewed campaign after signup' do
    the_test  
  end
  
end
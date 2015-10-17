describe "Attendee registration" do
  
  let(:user){ FG.build :user, :attendee_role }
  
  before {
    visit attendees_sign_up_path
  }
  
  it 'works' do
    
    fill_attendee_signup_form
    
    expect {
      find("input[type='submit']").click
    }.to change {
      User.count
    }.by(1).and change {
      Attendee.count
    }.by(1)
    
  end
  
end
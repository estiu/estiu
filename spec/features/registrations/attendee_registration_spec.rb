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
      User.attendees.count
    }.by(1).and change {
      Attendee.count
    }.by(1)
    
  end
  
  context 'facebook signun', js: true do
  
    it 'takes the user to facebook.com' do
    
      find('.btn-facebook').click
      expect(current_host).to include 'facebook.com'
      expect(page).to have_content 'Password'
      
    end
  
  end
  
end
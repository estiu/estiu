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
  
  context 'facebook signup', js: true, skip_js_check: true do
  
    it 'takes the user to facebook.com' do
    
      find('.btn-facebook').click
      expect(current_host).to include 'facebook.com'
      sleep 3
      expect(page).to have_content 'Log into Facebook'
      
    end
  
  end
  
end
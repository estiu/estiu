describe "Attendee registration" do
  
  let(:user){ FG.build :user, :attendee_role }
  
  before {
    visit new_user_registration_path
  }
  
  it 'works' do
    
    %w(first_name last_name).each do |attr|
      find("#user_attendee_attributes_#{attr}").set user.attendee.send(attr)
    end
    
    find("#user_email").set user.email
    find("#user_password").set user.password
    find("#user_password_confirmation").set user.password
    
    expect {
      find("input[type='submit']").click
    }.to change {
      User.count
    }.by(1).and change {
      Attendee.count
    }.by(1)
    
  end
  
end
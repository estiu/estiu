describe "Event promoter registration" do
  
  let(:user){ FG.build :user, :event_promoter_role }
  
  before {
    visit event_promoters_sign_up_path
  }
  
  it 'works' do
    
    %w(name email website).each do |attr|
      find("#user_event_promoter_attributes_#{attr}").set user.event_promoter.send(attr)
    end
    
    find("#user_email").set user.email
    find("#user_password").set user.password
    find("#user_password_confirmation").set user.password
    
    expect {
      find("input[type='submit']").click
    }.to change {
      User.count
    }.by(1).and change {
      EventPromoter.count
    }.by(1)
    
  end
  
end
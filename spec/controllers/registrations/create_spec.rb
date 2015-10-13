describe RegistrationsController do
  
  assign_devise_mapping
  
  after do
    controller_ok 302
  end
  
  describe '#create' do
    
    let(:user){ FG.build :user }
    let(:user_params){
      {
        user: {
          email: user.email,
          password: user.password,
          password_confirmation: user.password,
          attendee_attributes: {
            first_name: "Foo",
            last_name: "Bar"
          }
        }
      }
    }
    
    it 'works' do
      
      expect {
        post :create, user_params
      }.to change{
        User.count
      }.by(1).and change{
        Attendee.count
      }.by(1)
      
    end
    
  end

end
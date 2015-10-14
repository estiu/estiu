describe Registrations::EventPromotersController do
  
  assign_devise_mapping
  
  after do
    controller_ok 302
  end
  
  describe '#create' do
    
    let(:user){ FG.build :user }
    let(:event_promoter){ FG.build :event_promoter }
    
    let(:user_params){
      {
        user: {
          email: user.email,
          password: user.password,
          password_confirmation: user.password,
          event_promoter_attributes: {
            name: event_promoter.name,
            email: event_promoter.email,
            website: event_promoter.website
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
        EventPromoter.count
      }.by(1)
      
    end
    
  end

end
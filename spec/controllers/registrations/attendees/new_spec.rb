describe Registrations::AttendeesController do
  
  assign_devise_mapping
  
  after do
    controller_ok 200
  end
  
  describe '#new' do
      
    it 'renders the correct form' do
      
      get 'new'
      expect(response).to render_template(partial: 'devise/registrations/_attendee')
      
    end
    
  end

end
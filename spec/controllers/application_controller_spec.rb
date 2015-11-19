describe ApplicationController do
  
  describe '/' do
    
    after do
      controller_ok
    end
    
    it 'loads the home page, and without a redirect' do
      
      get :home
      
      expect(response).to render_template('pages/home')
      
    end
    
  end
  
end
describe ApplicationController do
  
  render_views
  
  describe '#index' do
    
    it 'works' do
      
      get :index
      expect(response.body).to be_present
      expect(response.status).to be 200
      
    end
    
  end
  
end
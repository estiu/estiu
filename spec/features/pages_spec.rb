describe 'pages smoke spec' do
  
  after {
    page_ok
  }
  
  HighVoltage.page_ids.each do |page_id|
    
    describe "page: #{page_id}" do
      
      it 'loads correctly' do
        
        visit page_path(page_id)

      end
      
    end
    
  end
  
end
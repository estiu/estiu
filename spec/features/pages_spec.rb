[true, false].each do |js|
  
  describe "Basic correctness (pages are served without errors) (js: #{js})", js: js do
    
    after do
      page_ok 200, js
    end
    
    HighVoltage.page_ids.each do |page_id|
      
      describe "page: #{page_id}" do
        
        it 'loads correctly' do
          
          visit page_path(page_id)

        end
        
      end
      
    end
    
  end
  
end
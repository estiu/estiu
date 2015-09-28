describe 'pages smoke spec' do
  
  HighVoltage.page_ids.each do |page_id|
    
    describe "page: #{page_id}" do
      
      it 'loads correctly' do
        
        visit page_path(page_id)
        expect(page.html).to be_present
        expect(page.status_code).to be 200

      end
      
    end
    
  end
  
end
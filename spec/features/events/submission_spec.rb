describe 'Event submission', js: true do
  
  sign_as :event_promoter, :feature
  
  let(:event){ FG.create :event, event_promoter_id: event_promoter.event_promoter.id }
  
  before {
    expect(event.submitted_at).to be nil
    visit event_path(event)
  }
  
  unless ci?
    
    it 'is possible to submit an event' do
      
      attach_s3_file
      find('#event_documents_confirmation').click
      expect {
        find('.submit_event_button').click
      }.to change {
        event.reload.submitted_at.nil?
      }.from(true).to(false)
      
    end
    
  end
  
end
describe 'Viewing a ticket' do
  
  describe 'As an attendee' do
    
    sign_as :attendee, :feature
    
    context "when I have a ticket for a given event" do
      
      let!(:ticket){ FG.create :ticket, attendee: attendee.attendee }
      
      before {
        visit event_path(ticket.event)
      }
      
      it "is possible to see the ticket information" do
        
        expect(page).to have_content t('events.ticket.instructions', must: t('events.ticket.must'))
        
      end
      
    end
    
  end
  
end
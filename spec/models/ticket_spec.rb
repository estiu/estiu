describe Ticket do
  
  describe 'creation', truncate: true do
    
    let(:ticket) { FG.build :ticket }
    
    before {
      expect(ticket.id).to be nil
    }
    
    it "triggers a Events::Approval::TicketNotificationJob" do
      
      expect(Events::Approval::TicketNotificationJob).to receive(:perform_later).once.and_call_original
      ticket.save!
      
    end
    
  end
  
end
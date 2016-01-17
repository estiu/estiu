describe Events::Approval::TicketCreationJob, truncate: true do
  
  let(:event){ FG.create(:event, :submitted) }
  let(:attendee_count){ event.campaign.attendees.count }
  
  before {
    event.reload
    expect(attendee_count).to be > 0
  }
  
  def the_action
    expect(Events::Approval::TicketCreationJob).to receive(:perform_later).once.with(event.id).and_call_original
    event.approve!
  end
  
  it "creates Ticket records" do
    
    expect {
      the_action
    }.to change {
      Ticket.count
    }.by(attendee_count)
    
  end
  
  context "job firing", truncate: true do
    
    it "causes Events::Approval::TicketNotificationJob to be executed `attendee_count` times" do
      
      expect(Events::Approval::TicketNotificationJob).to receive(:perform_later).at_least(attendee_count).times.and_call_original
      the_action
      
    end
    
  end
  
end
describe Events::Approval::TicketNotificationJob do
  
  let(:ticket){ FG.create(:ticket) }
  
  def the_action
    Events::Approval::TicketNotificationJob.perform_later(ticket.id)
  end
  
  it "runs the corresponding mailer" do
    
    expect(Events::Approval::TicketNotificationMailer).to receive(:perform).once.with(ticket).and_call_original
    the_action
    
  end
  
end
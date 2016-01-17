describe Events::Approval::EventPromoterNotificationJob, truncate: true do
  
  let(:event){ FG.create(:event, :submitted) }
  
  before {
    event.reload
  }
  
  def the_action
    Events::Approval::EventPromoterNotificationJob.perform_later(event.id)
  end
  
  it "runs the corresponding mailer" do
    
    expect(Events::Approval::EventPromoterNotificationMailer).to receive(:perform).once.with(event).and_call_original
    the_action
    
  end
  
end
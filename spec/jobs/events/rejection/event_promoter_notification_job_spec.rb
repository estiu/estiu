describe Events::Rejection::EventPromoterNotificationJob, truncate: true do
  
  let(:event){ FG.create(:event, :submitted) }
  
  before {
    event.reload
  }
  
  def the_action
    Events::Rejection::EventPromoterNotificationJob.perform_later(event.id)
  end
  
  it "runs the corresponding mailer" do
    
    expect(Events::Rejection::EventPromoterNotificationMailer).to receive(:perform).once.with(event).and_call_original
    the_action
    
  end
  
end
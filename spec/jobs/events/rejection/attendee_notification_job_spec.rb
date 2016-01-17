describe Events::Rejection::AttendeeNotificationJob, truncate: true do
  
  let(:event){ FG.create(:event, :submitted) }
  let(:pledge_count){ event.campaign.pledges.count }
  
  before {
    event.reload
  }
  
  def the_action
    expect(pledge_count).to be > 0
    expect(Events::Rejection::AttendeeNotificationJob).to receive(:perform_later).with(event.id).and_call_original
    event.reject!
  end
  
  it "runs the corresponding mailer `pledge_count` times" do
    
    expect(Events::Rejection::AttendeeNotificationMailer).to receive(:perform).at_least(pledge_count).times.and_call_original
    the_action
    
  end
  
end
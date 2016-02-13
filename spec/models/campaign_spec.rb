describe Campaign do

  describe '#send_fulfillment_emails', truncate: true do
    
    subject { FG.create :campaign, :almost_fulfilled }
    
    let(:pledge){
      cents = subject.minimum_pledge_cents
      Pledge.create!(campaign: subject, attendee: FG.create(:attendee), amount_cents: cents, originally_pledged_cents: cents)
    }
    
    def fulfill
      expect {
        pledge.update_attributes! stripe_charge_id: SecureRandom.hex
      }.to change {
        subject.reload.fulfilled?
      }.from(false).to(true)
    end
    
    it 'works' do
      expect(CampaignFulfillmentJob).to receive(:perform_later).with(subject.id).once.and_call_original
      fulfill
    end
    
  end
  
  describe '#check_unfulfilled_at', truncate: true do
    
    subject { FG.create :campaign, :almost_fulfilled }
    
    def unfulfill
      subject.update_attributes! unfulfilled_at: DateTime.now, force_job_running: true
    end
    
    it 'triggers a job' do
      expect(CampaignUnfulfillmentJob).to receive(:perform_later).with(subject.id).once.and_call_original
      unfulfill
    end
    
  end
  
  describe '#schedule_unfulfillment_check', truncate: true do
    
    subject { FG.build :campaign, force_job_running: true }
    
    let(:pipeline_id){ SecureRandom.hex }
    
    before {
      expect(AwsOps::Amis).to receive(:latest_ami).and_return(SecureRandom.hex)
      the_double = double(
        put_pipeline_definition: double(errored: false),
        activate_pipeline: true,
        create_pipeline: double(pipeline_id: pipeline_id))
      expect(AwsOps::Pipeline).to receive(:data_pipeline_client).at_least(3).times.and_return(the_double)
    }
    
    set_aws_ops_test_env
    
    def the_action
      subject.save!
    end
    
    it 'triggers a job' do
      expect(CampaignUnfulfillmentCheckJob).to receive(:perform_later).once.and_call_original
      the_action
    end
    
    it 'updates a column' do
      expect(subject.unfulfillment_check_id).to be nil
      the_action
      subject.reload
      expect(subject.unfulfillment_check_id).to eq pipeline_id
    end
    
  end
  
end
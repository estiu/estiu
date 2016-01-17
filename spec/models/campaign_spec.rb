describe Campaign do

  describe 'date validations' do
    
    subject { FG.build :campaign }
    
    before {
      subject.skip_past_date_validations = false
    }
    
    context 'starts_at > ends_at' do
      before {
        subject.starts_at = 10.hours.from_now
        subject.ends_at = 2.hours.from_now
      }
      it 'is reported' do
        expect(subject.valid?).to be false
        expect(subject.errors[:starts_at]).to include I18n.t('campaigns.errors.starts_at.ends_at')
      end
    end
    
    context 'minimum_active_hours not honored' do
      before {
        subject.starts_at = 1.hour.from_now
        subject.ends_at = 1.hour.from_now.advance minutes: 1
      }
      it 'is reported' do
        expect(subject.valid?).to be false
        expect(subject.errors[:ends_at]).to include I18n.t('campaigns.errors.ends_at.starts_at', hours: Campaign.minimum_active_hours)
      end
    end
    
    context 'past starts_at' do
      before {
        subject.starts_at = Date.yesterday
      }
      it 'is reported' do
        expect(subject.valid?).to be false
        expect(subject.errors[:starts_at]).to include I18n.t('past_date')
      end
    end
    
    context 'past ends_at' do
      before {
        subject.ends_at = Date.yesterday
      }
      it 'is reported' do
        expect(subject.valid?).to be false
        expect(subject.errors[:ends_at]).to include I18n.t('past_date')
      end
    end
    
  end
  
  describe '#send_fulfillment_emails', truncate: true do
    
    subject { FG.create :campaign, :almost_fulfilled }
    
    def fulfill
      expect {
        cents = subject.minimum_pledge_cents
        Pledge.create!(campaign: subject, attendee: FG.create(:attendee), amount_cents: cents, originally_pledged_cents: cents, stripe_charge_id: SecureRandom.hex)
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
      expect(AwsOps::Infrastructure).to receive(:latest_ami).and_return(SecureRandom.hex)
      the_double = double(
        put_pipeline_definition: double(errored: false),
        activate_pipeline: true,
        create_pipeline: double(pipeline_id: pipeline_id))
      expect(AwsOps::Pipeline).to receive(:data_pipeline_client).at_least(3).times.and_return(the_double)
    }
    
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
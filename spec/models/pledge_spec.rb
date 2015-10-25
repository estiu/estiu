describe Pledge do
  
  subject { FG.build :pledge }
  
  describe '#minimum_pledge' do
    
    it 'works' do
      
      expect {
        subject.amount_cents -= 100
      }.to change {
        subject.valid?
      }.from(true).to(false)
      
      expect(subject.errors[:amount_cents]).to include t("pledges.errors.amount_cents.minimum_pledge", amount: subject.campaign.minimum_pledge.format)
      
    end
    
  end
  
  describe '#maybe_mark_campaign_as_fulfilled' do
    
    before {
      expect(campaign).to receive(:maybe_mark_as_fulfilled).and_call_original
    }
    
    def the_test negative=false
      
      expect {
        subject.save
      }.send((negative ? :to_not : :to), change {
        campaign.reload.fulfilled_at
      })
      
      expect(campaign.fulfilled_at.present?).to be !negative
      
    end

    context 'non-fulfilled campaign' do
      
      let(:campaign) { FG.create :campaign }
      
      subject{ FG.build(:pledge, campaign: campaign) }
      
      before {
        expect(campaign.fulfilled?).to be false
      }
      
      it "does not result in capaign.fulfilled_at being set" do
        the_test :negative
      end
      
    end
    
    context 'almost fulfilled campaign' do
      
      let(:campaign) { FG.create :campaign, :almost_fulfilled }
      
      subject{ FG.build(:pledge, campaign: campaign) }
      
      before {
        expect(campaign.fulfilled?).to be false
        threshold = campaign.goal_cents - campaign.minimum_pledge_cents
        expect(campaign.pledged_cents).to be < threshold
        expect(campaign.pledged_cents + subject.amount_cents).to be >= threshold
      }
      
      it "results in capaign.fulfilled_at being set" do
        the_test
      end
      
    end
    
  end
  
  describe '#calculate_discount!' do
    
    let(:campaign) { FG.create :campaign, :almost_fulfilled }
    
    subject{ FG.build :pledge, campaign: campaign, referral_email: email }
    
    before {
      expect(subject.discount_cents).to be 0
    }
    
    def the_test negative=false
      if negative
        expect {
          subject.calculate_discount!
        }.to_not change {
          subject.discount_cents
        }
      else
        expect {
          subject.calculate_discount!
        }.to change {
          subject.discount_cents
        }.from(0).to(Pledge::DISCOUNT_PER_REFERRAL)
      end
    end
    
    context 'related email' do
      
      let(:email){ campaign.attendees.first.user.email }
      
      it 'sets a discount' do
        the_test
      end
      
    end
    
    context 'unrelated email' do
    
      let(:email){ "#{SecureRandom.hex}@#{SecureRandom.hex}.com" }
      
      it 'does not set a discount' do
        the_test :negative
      end
      
    end
    
    context 'non-email string' do
    
      let(:email) { SecureRandom.hex }
      
      it 'does not set a discount' do
        the_test :negative
      end
      
    end
    
    context 'blank email' do
    
      let(:email){ nil }
      
      it 'does not set a discount' do
        the_test :negative
      end
      
    end
    
  end
  
  describe '#calculate_total!' do
    
    before {
      subject.amount_cents = nil
      expect(subject.originally_pledged_cents).to_not be nil
      expect(subject).to receive(:calculate_discount!).and_call_original
    }
    
    it 'sets amount_cents' do
      expect {
        subject.calculate_total!
      }.to change {
        subject.amount_cents
      }.from(nil).to(subject.originally_pledged_cents)
    end
    
  end
  
end
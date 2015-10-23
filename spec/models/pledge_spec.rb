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
  
end
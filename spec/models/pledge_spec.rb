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
  
end
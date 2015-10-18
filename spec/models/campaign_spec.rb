describe Campaign do

  describe '#recommended_pledge (monetized method)' do
    
    subject { FG.build :campaign }
    
    def the_expectation negative=false
      expect(subject.recommended_pledge).send((negative ? :to_not : :to), eq(subject.minimum_pledge))
    end
    
    context "when there is a recommended pledge set" do
      
      before {
        subject.recommended_pledge_cents = subject.minimum_pledge_cents * 2
      }
      
      it 'has that value' do
      
        the_expectation :negative
        
      end
      
    end
  
    context "when there isn't a recommended pledge value set" do
      
      before {
        subject.recommended_pledge_cents = nil
        expect(subject.minimum_pledge_cents).to be_present
      }
      
      it 'has the value of minimum_pledge_cents' do
        
        the_expectation
        
      end
      
    end
    
  end
  
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
  
end
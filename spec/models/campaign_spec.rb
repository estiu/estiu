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
  
end
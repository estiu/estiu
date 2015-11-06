describe Credit do
  
  subject { FG.build :credit }
  
  describe '#notify_attendee', truncate: true do
    
    before {
      expect(CreditCreationJob).to receive(:perform_later)
    }
    
    it 'triggers a CreditCreationJob' do
      
      subject.save
      
    end
    
    context 'existing credit' do
      
      before {
        subject.save!
      }
      
      before {
        expect(CreditCreationJob).to_not receive(:perform_later)
      }
      
      it "doesn't trigger a CreditCreationJob" do
        
        subject.touch
        
      end
      
    end
    
  end
  
end
describe Event do
  
  describe '#on_approval', truncate: true do
    
    subject { FG.create :event, :submitted }
    
    before {
      subject.reload
      expect(subject.must_be_reviewed?).to be true
    }
    
    it "triggers two jobs" do
      
      expect(Events::Approval::TicketCreationJob).to receive(:perform_later).with(subject.id).once.and_call_original
      expect(Events::Approval::EventPromoterNotificationJob).to receive(:perform_later).with(subject.id).once.and_call_original
      expect(subject).to receive(:on_approval).once.and_call_original
      subject.approve!
      
    end
    
  end
  
  describe '#on_rejection', truncate: true do
    
    subject { FG.create :event, :submitted }
    
    before {
      subject.reload
      expect(subject.must_be_reviewed?).to be true
    }
    
    it "triggers two jobs" do
      
      expect(Events::Rejection::EventPromoterNotificationJob).to receive(:perform_later).with(subject.id).once.and_call_original
      expect(Events::Rejection::AttendeeNotificationJob).to receive(:perform_later).with(subject.id).once.and_call_original
      expect(subject).to receive(:on_rejection).once.and_call_original
      subject.reject!
      
    end
    
    it "sets campaign.event_rejected_at" do
      
      expect {
        subject.reject!
        subject.campaign.reload
      }.to change {
        subject.campaign.event_rejected_at.nil?
      }.from(true).to(false)
      
    end
    
  end
  
  describe '#find_ra_paths' do
  
    before {
      expect(subject.id).to be nil
      expect(subject.ra_artists.size).to be > 0
      expect(subject.ra_artists.map(&:id).uniq).to eq [nil]
    }
    
    def assert_saved
      expect(subject.save).to be true
    end
    
    context 'default' do
    
      subject { FG.build :event }
      
      it 'results in a valid record' do
        assert_saved
      end
      
    end
    
    context 'ra_artists with duplicate values' do
      
      let(:existing){ FG.create :ra_artist }
      
      subject {
        FG.build :event, ra_artists: [FG.build(:ra_artist, artist_path: existing.artist_path)]
      }
      
      it 'replaces duplicate ra_artists with existing ones' do
        assert_saved
        expect(subject.ra_artists.size).to be 1
        expect(subject.reload.ra_artists.pluck(:id)).to eq [existing.id]
      end
      
    end
    
  end
  
end
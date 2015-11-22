describe Event do

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
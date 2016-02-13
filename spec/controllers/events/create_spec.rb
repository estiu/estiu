describe EventsController do
  
  describe '#create' do
    
    def event_params n
      sample_event = FG.build :event
      ras = (1..n).map do
        FG.build :ra_artist
      end
      v = {event: {}}
      (Event::CREATE_ATTRS - [:starts_at]).each do |attr|
        v[:event][attr] = sample_event.send attr
      end
      v[:event][:venue_id] = campaign.venue.id
      v[:event][:ra_artists_attributes] = Hash[ras.each_with_index.map {|x, i| [i.to_s, {artist_path: x.artist_path}] }]
      v[:id] = campaign.id
      v
    end
    
    context "event_promoter" do
      
      sign_as :event_promoter
      
      context "related event_promoter for a campaign without event" do
        
        let(:campaign){
          FG.create :campaign, :fulfilled, campaign_draft: FG.create(:campaign_draft, :published, event_promoter_id: event_promoter.event_promoter_id)
        }
        
        [1, 2].each do |n|
          
          context "with #{n} ra_artists" do
            
            it "works" do
              expect {
                post :create, event_params(n)
              }.to change {
                Event.count
              }.by(1).and change {
                RaArtist.count
              }.by(n)
            end
      
          end
          
        end
        
      end
      
    end
    
  end
  
end
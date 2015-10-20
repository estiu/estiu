describe User do
  
  describe 'role scopes' do
  
    let!(:attendee) { FG.create :user, :attendee_role }
    let!(:event_promoter) { FG.create :user, :event_promoter_role }
    let!(:attendee_and_event_promoter) { FG.create :user, roles: [:attendee, :event_promoter] }
    
    it 'works' do
      
      expect(User.attendees).to include attendee
      expect(User.attendees).to include attendee_and_event_promoter
      expect(User.attendees).to_not include event_promoter
      
      expect(User.event_promoters).to_not include attendee
      expect(User.event_promoters).to include attendee_and_event_promoter
      expect(User.event_promoters).to include event_promoter
      
    end
    
  end
  
end
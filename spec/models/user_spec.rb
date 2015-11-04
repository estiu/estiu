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
  
  describe '.find_or_create_from_facebook_assigning_token' do
    
    let(:email){ user.email }
    let(:first_name) { SecureRandom.hex }
    let(:last_name) { SecureRandom.hex }
    let(:fb_attrs){ {facebook_user_id: SecureRandom.hex} }
    let(:result) { User.find_or_create_from_facebook_assigning_token email, first_name, last_name, fb_attrs }
    
    context 'can be found by facebook_user_id and email' do
      
      let(:user){ FG.create :user, :attendee_role, facebook_user_id: fb_attrs[:facebook_user_id], signed_up_via_facebook: signed_up_via_facebook }
      
      after do
        expect(result.id).to eq user.id
      end
    
      context 'signed_up_via_facebook' do
        
        let(:signed_up_via_facebook){ true }
        
        it 'updates first_name/last_name' do
          
          expect {
            result.save
          }.to change {
            user.reload.attendee.first_name
          }.and change {
            user.reload.attendee.last_name
          }
          
        end
        
      end
    
      context '!signed_up_via_facebook' do
        
        let(:signed_up_via_facebook){ false }
        
        it "doesn't update first_name/last_name" do
          
          expect {
            result.save
          }.to_not change {
            [user.reload.attendee.first_name, user.reload.attendee.last_name]
          }
          
        end
        
      end
    
    end
    
    context 'can be found by email' do
    
      let(:user){ FG.create :user, :attendee_role }
      
      it 'finds the correct record' do
        
        expect(result.id).to eq user.id
        
      end
      
      it 'updates signed_up_via_facebook' do
        
        expect {
          result.save
        }.to change {
          user.reload.signed_up_via_facebook
        }.from(nil).to(false)
        
      end
      
      it "doesn't update first_name/last_name" do
        
        expect {
          result.save
        }.to_not change {
          [user.reload.attendee.first_name, user.reload.attendee.last_name]
        }
        
      end
      
    end
    
    context 'can be found by facebook_user_id' do
    
      let(:email){ "#{SecureRandom.hex}@mailinator.com" }
      let(:user){ FG.create :user, :attendee_role, facebook_user_id: fb_attrs[:facebook_user_id], signed_up_via_facebook: true }
      
      it 'finds the record' do
        expect(User).to receive(:where).with(facebook_user_id: user.facebook_user_id, signed_up_via_facebook: true).and_call_original
        expect(result.id).to eq user.id
      end
      
      it 'updates first_name/last_name' do
        
        expect {
          result.save
        }.to change {
          user.reload.attendee.first_name
        }.and change {
          user.reload.attendee.last_name
        }
        
      end
        
    end
    
    context 'creation' do
      
      let(:email){ "#{SecureRandom.hex}@mailinator.com" }
      
      it 'works' do
        
        user = result
        user.save!
        expect(user).to be_confirmed
        
      end
      
    end
    
  end
  
end
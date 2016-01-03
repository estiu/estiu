describe 'Pledge creation' do
  
  let(:campaign){ FG.create :campaign }

  context 'as an attendee' do
    
    sign_as :attendee, :feature
    
    context 'success', js: true do
    
      before {
        visit campaign_path(campaign)
      }
      
      let(:charge){
        double(id: SecureRandom.hex)
      }
      
      def the_action submit_only=false, confirm_dialog=false
        
        find('#do-pledge').click
        
        return if submit_only
        
        accept_dialog if confirm_dialog
        
        fill_stripe_form
        
        sleep 7 # wait for Stripe processing + PledgesController#update processing
        
      end
      
      def charge_expectations negative=false
        if negative
          expect(Stripe::Charge).to_not receive(:create)
          expect(charge).to_not receive(:id)
        else
          expect(Stripe::Charge).to receive(:create).once.with(any_args).and_return(charge)
          expect(charge).to receive(:id).exactly(2).times
        end
      end
      
      context 'no referral_email passed' do
        
        before {
          charge_expectations
        }
        
        it 'is possible to create a charge through the Stripe Checkout form' do
          expect {
            the_action
          }.to change {
            campaign.pledges.count
          }.by(1)
          expect(Pledge.last.referral_email.present?).to be false
        end
        
      end
      
      context 'referral_email' do
        
        let(:campaign){ FG.create :campaign, :almost_fulfilled }
        let(:email){ campaign.attendees.first.user.email }
        
        context 'success' do
          
          before {
            charge_expectations
          }
          
          it 'works' do
            find('#pledge_referral_email').set email
            the_action false, :confirm_dialog
            expect(Pledge.last.referral_email).to eq email
          end
          
        end
        
        context 'unrelated email' do
          
          before {
            charge_expectations :negative
          }
          
          let(:email) { "#{SecureRandom.hex}@#{SecureRandom.hex}.com" }
          
          it 'fails' do
            find('#pledge_referral_email').set email
            expect {
              the_action :submit_only
            }.to_not change {
              campaign.pledges.count
            }
            expect(page).to have_content t('pledges.errors.referral_email.no_user')
          end
          
        end
        
      end
      
    end
    
    context 'if the attendee has already pledged' do
      
      after {
        page_ok
      }
      
      let(:cents){ campaign.minimum_pledge_cents }
      
      let!(:pledge){ Pledge.create!(attendee: attendee.attendee, campaign: campaign, amount_cents: cents, originally_pledged_cents: cents, stripe_charge_id: SecureRandom.hex) }
      
      before {
        visit campaign_path(campaign)
      }

      it 'is not possible to pledge again' do
        discount_info = pledge.discount_cents.zero? ? '' : t('pledges.form.discount_info', amount: pledge.amount.format)
        expect(page).to have_content(t 'pledges.form.contributed', contributed: pledge.originally_pledged.format, discount_info: discount_info)
      end
      
    end
    
  end
  
end
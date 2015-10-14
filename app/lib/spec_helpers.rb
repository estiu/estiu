module SpecHelpers
  
  def controller_ok status=200
    expect(response.status).to be status
    expect(response.body).to be_present
  end

  def assign_devise_mapping
    before {
      @request.env["devise.mapping"] = Devise.mappings[:user]
    }
  end

  def sign_as role_name=nil, js=false
    
    return unless role_name # nil means signed out user
    
    let(role_name) { FG.create(:user, "#{role_name}_role".to_sym) }
    
    before do
      user_object = eval(role_name.to_s)
      user_object.confirm
      if js
        login_as(user_object, scope: :user)
      else
        sign_in :user, user_object
      end
    end
    
  end

  def expect_unauthorized
    expect(subject).to receive(:user_not_authorized).once.with(any_args).and_call_original
    expect(subject).to rescue_from(Pundit::NotAuthorizedError).with :user_not_authorized
  end

  def forbidden_for *role_names

    role_names.each do |role|
      
      context "sign_as #{role || "nil"}" do
        
        it 'is forbidden' do
          
          expect(response.status).to be 302
          expect(flash[:alert]).to include(t('application.forbidden'))
          
        end
        
      end
      
    end
    
  end
  
  def fill_attendee_signup_form
    
    %w(first_name last_name).each do |attr|
      find("#user_attendee_attributes_#{attr}").set user.attendee.send(attr)
    end
    
    find("#user_email").set user.email
    find("#user_password").set user.password
    find("#user_password_confirmation").set user.password

  end
  
end
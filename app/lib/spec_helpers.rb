module SpecHelpers
  
  def controller_ok status=200
    expect(response.status).to be status
    expect(response.body).to be_present
  end

  def page_ok status=200
    expect(page.status_code).to be status
    expect(page.html).to be_present
  end

  def assign_devise_mapping
    before {
      @request.env["devise.mapping"] = Devise.mappings[:user]
    }
  end

  def sign_as role_name_or_user_object=nil, feature=false
    
    return unless role_name_or_user_object # nil means signed out user
    
    if role_name_or_user_object.is_a?(Symbol)
      let(role_name_or_user_object) { FG.create(:user, "#{role_name_or_user_object}_role".to_sym) }
    end
    
    before do
      user_object = role_name_or_user_object.is_a?(Symbol) ? eval(role_name_or_user_object.to_s) : instance_eval(&role_name_or_user_object)
      user_object.confirm
      if feature
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
  
  def sop
    save_and_open_page
  end
  
end
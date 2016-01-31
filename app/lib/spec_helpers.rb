module SpecHelpers
  
  def controller_ok status=200
    expect(response.status).to be status
    expect(response.body).to be_present
  end

  def page_ok status=200, feature=false
    expect(page.status_code).to be status unless feature
    expect(page.html).to be_present
  end

  def assign_devise_mapping
    before {
      @request.env["devise.mapping"] = Devise.mappings[:user]
    }
  end

  def sign_as role_name_or_user_object=nil, feature=false, let_name=nil
    
    return unless role_name_or_user_object # nil means signed out user
    
    if role_name_or_user_object.is_a?(Symbol)
      let(let_name || role_name_or_user_object) { FG.create(:user, "#{role_name_or_user_object}_role".to_sym) }
    elsif let_name
      let(let_name){ instance_eval(&role_name_or_user_object) }
    end
    
    before do
      
      user_object = 
        (if (!role_name_or_user_object.is_a?(Symbol) && !let_name) 
          instance_eval(&role_name_or_user_object)
        elsif let_name
          eval(let_name.to_s)
        else
          eval(role_name_or_user_object.to_s)
        end)
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
  
  def forbidden_expectation
    expect(response.status).to be 302
    expect(flash[:alert]).to include(t('application.forbidden'))
  end
  
  def forbidden_for *role_names

    role_names.each do |role|
      
      context "sign_as #{role || "nil"}" do
        
        it 'is forbidden' do
          forbidden_expectation
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
  
  def assert_js_ok
    errors = evaluate_script("window.errors")
    expect(errors).to be_kind_of(Array)
    errors.reject!{|a, b, c|
      # a == "TypeError: e is undefined" # unrelated jQuery error
    }
    expect(errors).to eq []
    expect(errors.size).to be 0
  end
  
  def accept_dialog expected_text=false
    a = page.driver.browser.switch_to.alert
    expect(a.text).to eq expected_text if expected_text
    a.accept # or a.dismiss
  end
  
  def fill_stripe_form
    
    sleep 3
    
    within_frame 'stripe_checkout_app' do
      4.times { find('#card_number').send_keys "4242" } # In test mode, the 4242 4242 4242 4242 card is always valid for Stripe.
      find('#cc-exp').send_keys "12"
      find('#cc-exp').send_keys "20"
      find('#cc-csc').send_keys "999"
      find('#submitButton').click
    end
    
  end
  
  def any_day
    find('table.ui-datepicker-calendar tbody tr:nth-child(2) td:first-child').click
  end
  
  def next_month
    find('.ui-datepicker-next').click
  end
  
  def attach_s3_file path=Rails.root.join('spec', 'factories', 'empty.pdf')
    page.driver.instance_variable_get('@browser').find_elements(class: 'file-uploader').map{|i| i.send_keys path }
  end
  
end
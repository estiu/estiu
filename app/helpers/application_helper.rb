module ApplicationHelper
  
  def alert_class_for(flash_type)
    {
      success: 'alert-success',
      error: 'alert-danger',
      alert: 'alert-warning',
      notice: 'alert-info'
    }[flash_type.to_sym] || flash_type.to_s
  end
  
  def form_fields(form, prefix, options={})
    the_function = ->(key, locals={}) do
      form_field(form, key, locals.merge(options.merge({prefix: prefix})))
    end
    yield(the_function)
    '' # avoid rendering unintended stuff in corner cases
  end
  
  def progress_bar percent, label, type=nil, id=nil
    render 'layouts/progress_bar', percent: percent, label: label, type: type, id: id
  end
  
  def centered
    "#{centered_wider} col-lg-4 col-lg-offset-4"
  end
  
  def centered_wider
    "col-xs-12 col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3"
  end
  
  def facebook_connect login=false
    render 'layouts/facebook_connect', login: login
  end
  
  private
  
  def form_field form, key, locals={}
    as = locals[:as] || ([:submit, :email, :password].include?(key) ? key : :text)
    l = locals.merge(key: key, form: form, as: as)
    render 'fields/field', l.merge(locals: l)
  end
  
end

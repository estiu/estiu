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
  
  def facebook_send_link link=request.original_url # the generated dialog needs a real host, localhost will cause a 500 from fb.
    "http://www.facebook.com/dialog/send?app_id=#{Rails.application.secrets.facebook_app_id}&link=#{link}&redirect_uri=#{link}"
  end
  
  def partial_to_js_template partial_name, locals
    template = controller.render_to_string(partial: partial_name, locals: locals).gsub("\n", '').gsub("\"", "\\\"")
    ('_.template("' + template + '")').html_safe
  end
  
  def activate_popover
    ".find('label span').popover(DEFAULT_POPOVER_OPTIONS)"
  end
  
  def popover_html key, locals={}
    "#{t((key + '_popover'), locals)} <br> <small> #{t((key + '_popover_2'), locals)} </small>"
  end
  
  def jquery_hidden
    'display: none'
  end
  
  def s3_item_wrapper_class
    's3-upload-item-wrapper'
  end
  
  def text_email_link record, caption=record
    "#{record} (#{url_for(record)})"
  end
  
  def render_per_locale_partial base_path
    candidate = "/#{base_path}/#{I18n.locale}"
    if lookup_context.find_all(candidate, [], true).any?
      render candidate
    else
      render "/#{base_path}/en" # XXX use fallback instead. e.g. :es is the fallback of :cat.
    end
  end
  
  private
  
  def form_field form, key, locals={}
    as = locals[:as] || ([:submit, :email, :password].include?(key) ? key : :text)
    l = locals.merge(key: key, form: form, as: as)
    render 'fields/field', l.merge(locals: l)
  end
  
end

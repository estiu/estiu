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
  
  private
  
  def form_field form, key, locals={}
    l = locals.merge(key: key, form: form, as: (locals[:as] || :text))
    render 'fields/field', l.merge(locals: l)
  end
  
end

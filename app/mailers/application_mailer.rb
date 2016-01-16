class ApplicationMailer < ActionMailer::Base
  
  default from: "vemv@vemv.net"
  layout 'mailer'
  add_template_helper(ApplicationHelper)
  
  def self.inherited(subclass)
    subclass.default template_path: "mailers/#{subclass.name.to_s.underscore}"
  end
  
end
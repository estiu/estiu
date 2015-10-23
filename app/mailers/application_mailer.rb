class ApplicationMailer < ActionMailer::Base
  
  default from: "vemv@vemv.net"
  layout 'mailer'
  
  def self.inherited(subclass)
    subclass.default template_path: "mailers/#{subclass.name.to_s.underscore}"
  end
  
end
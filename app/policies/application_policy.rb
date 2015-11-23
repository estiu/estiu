class ApplicationPolicy
  
  attr_accessor :user, :record

  def initialize(user, record)
    self.user = user || User.new
    self.record = record
  end

  def index?
    false
  end

  def show?
    scope.where(id: record.id).exists?
  end
  
  def new_or_create?
    false
  end
  
  def create?
    new_or_create?
  end

  def new?
    new_or_create?
  end
  
  def edit_or_update?
    false
  end
  
  def update?
    edit_or_update?
  end

  def edit?
    edit_or_update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_accessor :user, :scope

    def initialize(user, scope)
      self.user = user
      self.scope = scope
    end

    def resolve
      scope
    end
  end
  
  protected
  
  def logged_in?
    user.id.present?
  end
  
end

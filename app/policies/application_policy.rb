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

  def create?
    new?
  end

  def new?
    create?
  end

  def update?
    edit?
  end

  def edit?
    update?
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

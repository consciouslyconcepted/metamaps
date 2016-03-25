class MessagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      visible = ['public', 'commons']
      permission = 'maps.permission IN (?)'
      if user
        scope.joins(:maps).where(permission + ' OR maps.user_id = ?', visible, user.id)
      else
        scope.where(permission, visible)
      end 
    end
  end

  def show?
    resource_policy.show?
  end

  def create?
    record.resource.present? && resource_policy.update?
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user || admin_override
  end

  # Helpers

  def resource_policy
    @resource_policy ||= Pundit.policy(user, record.resource)
  end

end
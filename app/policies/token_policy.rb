# frozen_string_literal: true

class TokenPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user
        scope.where('tokens.user_id = ?', user.id)
      else
        scope.where(id: nil).where('id IS NOT ?', nil) # to just return none
      end
    end
  end

  def index?
    user.present?
  end

  def create?
    user.present?
  end

  def destroy?
    user.present? && record.user == user
  end
end

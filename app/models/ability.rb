class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user
    if user.role == "admin"
        can :manage, :all if user.role == "admin"
    else
      can :read, [Search]
      can :manage, User do |tuser|
        tuser == user
      end
    end
  end

end

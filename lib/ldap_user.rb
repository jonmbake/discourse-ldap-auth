class LDAPUser
  attr_reader :name, :email, :username, :user

  def initialize (auth_info)
    @name = auth_info[:name]
    @email = auth_info[:email]
    @username = auth_info[:nickname]
    @user = User.find_by_email(@email)
    create_user_groups(auth_info) unless self.account_exists?
  end

  def auth_result
    result = Auth::Result.new
    result.name = @name
    result.username = @username
    result.email = @email
    result.user = @user
    result.omit_username = true
    result.email_valid = true
    return result
  end

  def account_exists?
    return !@user.nil?
  end

  private
  def create_user_groups(auth_info)
    user_groups = auth_info[:groups]
    return if user_groups.nil?
    #user account must exist in order to create user groups
    @user = User.create!(auth_info.reject { |k, v| k == :groups })
    @user.activate
    user_groups.each do |group_name|
      group = Group.find_by(name: group_name)
      @user.groups << group unless group.nil?
    end
  end
end
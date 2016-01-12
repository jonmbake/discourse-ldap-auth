module Auth
  class Authenticator
    def after_authenticate(auth_options)
      raise NotImplementedError
    end

    def after_create_account(user, auth)
    end

    def register_middleware(omniauth)
      raise NotImplementedError
    end
  end

  class Result
    attr_accessor :user, :name, :username, :email, :user,
                  :email_valid, :extra_data, :awaiting_activation,
                  :awaiting_approval, :authenticated, :authenticator_name,
                  :requires_invite, :not_allowed_from_ip_address,
                  :admin_not_allowed_from_ip_address, :omit_username

    attr_accessor :failed,
                  :failed_reason

    def initialize
      @failed = false
    end

    def failed?
      !!@failed
    end
  end
end

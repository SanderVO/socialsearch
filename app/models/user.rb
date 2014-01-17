class User
  include Mongoid::Document
  include Mongoid::Timestamps
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String
  field :username, type: String
  field :salt, type: String
  field :first_name, type: String
  field :last_name, type: String
  field :active, type: Integer
  field :activationkey, type: String
  field :city, type: String
  field :country, type: String
  field :street, type: String
  field :postal_code, type: String
  field :gender, type: String
  embeds_many :searches
  embeds_many :authorizations

  # Social intergration 
  def fb
    if authorizations.length > 0 
      authorizations.each do |a|
        return a if a.provider == "facebook"
      end
    end 
    return nil
  end

  def twitter
    if authorizations.length > 0 
      authorizations.each do |a|
        return a if a.provider == "twitter"
      end
    end 
    return nil
  end
  
end

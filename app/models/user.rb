class User < ActiveRecord::Base
  
  belongs_to :team, autosave: true
  belongs_to :role, autosave: true
  has_many :events, autosave: true
  has_many :notes
  accepts_nested_attributes_for :events

  def fullname
    name = self.first_name + ' '
    name += self.last_name
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      user = User.find_or_initialize_by_id(row["id"])
      user.update_attributes(row.to_hash)
    end
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |user|
        csv << user.attributes.values_at(*column_names)
      end
    end
  end

  after_save do
    self.events.each do |e|
      unless e.exception == true
        e.role_id = role_id
      end
      e.team_id = team_id 
      e.save
    end
  end

	before_save { self.email = email.downcase }
	before_create :create_remember_token

	validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
  					  uniqueness: { case_sensitive: false }

  	has_secure_password
  	validates :password, length: { minimum: 6 }, on: :create

  	def User.new_remember_token
  		SecureRandom.urlsafe_base64
  	end

  	def User.encrypt(token)
  		Digest::SHA1.hexdigest(token.to_s)
  	end
  	
  	private
  		
  		def create_remember_token
  			self.remember_token = User.encrypt(User.new_remember_token)
  		end
end

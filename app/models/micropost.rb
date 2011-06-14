class Micropost < ActiveRecord::Base
  attr_accessible :content
  
  belongs_to :user
  
  validates :content, :presence => true, :length => { :maximum => 140  } 
  validates :user_id, :presence => true  
  
  default_scope :order => 'microposts.created_at DESC'
  
   
  scope :from_users_followed_by, lambda { |user| followed_by(user) }

  
  before_save :add_reply_to
  
  private
    
    
    def regex
      /\A@(\d+)-/i
    end
    
    def self.followed_by(user)
      followed_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)
      where("user_id IN (#{followed_ids}) OR in_reply_to IN (#{followed_ids}) OR (user_id = :user_id) OR (in_reply_to = :user_id)", { :user_id => user  })
    end
    
  
   
    # checks if the first charcter is @ sign and if it is, it takes the user name and puts it inside the in_reply_to in
    # the database
    def add_reply_to
       if reply_to? 
       
         self.in_reply_to = self.content.scan(regex).join(' ')
       end
                       
    end
    
    def reply_to?
     
      if self.content.match(regex)
        user = User.find(extract_id)
        user.name.downcase == extract_name.downcase
      end
    end
    
    def extract_name
      name_regex = /\A@\d+-([^@\s]+)/i
      reply_name = self.content.scan(name_regex).join(' ')
      reply_name.gsub(/-/i," ")      
    end
    
    def extract_id
      self.content.scan(regex).join(' ')
      
    end
   
end

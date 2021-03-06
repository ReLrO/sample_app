require 'spec_helper'

describe Micropost do
  before(:each) do
    @user = Factory(:user)
    @attr = {:content => "value for content" }
  end
  
  it "should create a new instance given valid attributes" do
    @user.microposts.create!(@attr)    
  end
  
  describe "user associations" do
    
    before(:each) do
      @micropost = @user.microposts.create(@attr)
    end
    
    it "should have a user attrribute" do
      @micropost.should respond_to(:user)
      
    end
    
    it "should have the right associated user" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end
    
  end
  
  describe "validations" do
    
    it "should require a user id" do
      Micropost.new(@attr).should_not be_valid
    end
    
    it "should require nonblank content" do
      @user.microposts.build(:content => "  " ).should_not be_valid
    end
    
    it "should reject long content" do
      @user.microposts.build(:content => "a" * 141 ).should_not be_valid
    end
    
  end
  
  describe "from_users_followed_by" do
    
    before(:each) do
      @other_user = Factory(:user, :email => Factory.next(:email))
      @third_user = Factory(:user, :email => Factory.next(:email))
      
      @user_post = @user.microposts.create!(:content => "foo" )
      @other_post = @other_user.microposts.create(:content => "bar")
      @third_post = @third_user.microposts.create(:content => "baz" )
      
      @user.follow!(@other_user)
    end    
    
    it "should have a from_users_followed_by class method" do
      Micropost.should respond_to(:from_users_followed_by)
    end
    
    it "should include the followed user's microposts" do
      Micropost.from_users_followed_by(@user).should include(@other_post)
    end
    
    it "should include the user's own microposts" do
      Micropost.from_users_followed_by(@user).should include(@user_post)      
    end
    
    it "should not include un unfollowed user's microposts" do
      Micropost.from_users_followed_by(@user).should_not include(@third_post)
    end
    
  end
  
  describe "from users replying" do 
    before(:each) do
      @other_user = Factory(:user, :email => Factory.next(:email))
      @other_post = @other_user.microposts.create(:content => "@1-moshe-rosenthal test" )
      @third_post = @other_user.microposts.create(:content => "@2-moshe-rosenthal test1")
      @forth_post = @other_user.microposts.create(:content => "hello world" )
      @fifth_post = @other_user.microposts.create(:content => "@1-shalom hello" )
    end
    
    it "should be included in user's feed" do
      Micropost.from_users_followed_by(@user).should include(@other_post)      
    end
    
    it "should not be included in user's feed" do
      Micropost.from_users_followed_by(@user).should_not include(@third_post)
      
    end
    
    it "should also not be included in user's feed" do
      Micropost.from_users_followed_by(@user).should_not include(@forth_post)      
    end
    
    it "should not be included in user's feed as well" do
      Micropost.from_users_followed_by(@user).should_not include(@fifth_post)      
    end
    
  end
end

class Comment < ActiveRecord::Base
  acts_as_nested_set :scope => [:commentable_id, :commentable_type]

  validates :body, :presence => true
  validates :user, :presence => true

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  acts_as_votable

  # add a like for the creator of the comment
  after_save 'self.liked_by self.user'

  belongs_to :commentable, :polymorphic => true

  # NOTE: Comments belong to a user
  belongs_to :user

  # Helper class method that allows you to build a comment
  # by passing a commentable object, a user_id, and comment text
  # example in readme
  def self.build_from(obj, user_id, comment)
    new \
      :commentable => obj,
      :body        => comment,
      :user_id     => user_id
  end

  #helper method to check if a comment has children
  def has_children?
    self.children.any?
  end

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  scope :find_comments_by_user, lambda { |user|
    where(:user_id => user.id).order('created_at DESC')
  }

  # Helper class method to look up all comments for
  # commentable class name and commentable id.
  scope :find_comments_for_commentable, lambda { |commentable_str, commentable_id|
    where(:commentable_type => commentable_str.to_s, :commentable_id => commentable_id).order('created_at DESC')
  }

  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  def total_votes
    self.get_upvotes.size - self.get_downvotes.size
  end

  # Upvotes for the current user, or removes vote if already upvoted
  def upvote(current_user)
    if current_user && current_user.voted_up_on?(self)
      self.unliked_by current_user
    else
      self.liked_by current_user
    end
  end

  # Downvotes for the current user, or removes vote if already downvoted
  def downvote(current_user)
    if current_user && current_user.voted_down_on?(self)
      self.undisliked_by current_user
    else
      self.downvote_by current_user
    end
  end

end

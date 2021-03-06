class CommunityUsersController < ApplicationController
  before_action :set_community_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only:  [:destroy, :new, :edit]
  respond_to :html

  def index
    @community_users = CommunityUser.all
    respond_with(@community_users)
  end

  def show
    respond_with(@community_user)
  end

  def new
    @community_user = CommunityUser.new
    respond_with(@community_user)
  end

  def edit
  end

  def create
    community = Community.find_by_name(params[:community_id])
    @community_user = community.community_users.new
    @community_user.user = current_user
    @community_user.save
    redirect_to community_by_name_path(community)
  end

  def update
    community = Community.find_by_name(params[:community_id])
    @community_user.update(community_user_params)
    redirect_to community_by_name_path(community)
  end

  def destroy
    @community_user.destroy
    respond_with(@community_user)
  end

  private
    def set_community_user
      @community_user = CommunityUser.find(params[:id])
    end

    def community_user_params
      params.require(:community_user).permit(:user_id, :community_id, :subscriber)
    end
end

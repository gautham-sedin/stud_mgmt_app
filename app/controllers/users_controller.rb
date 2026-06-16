class UsersController < ApplicationController
  before_action :require_admin!

  def index
    @teachers = User.teacher
  end
end

class Api::SizeGroupsController < ApplicationController

  def index
    @size_lists = Size.where(group_name: params[:group_name])
  end

end

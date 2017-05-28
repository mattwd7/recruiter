class SecureController < ApplicationController
	before_action :verify_admin
	before_action :authenticate_user!

	private
  def verify_admin
  	if current_user && !current_user.admin?
  		sign_out :user
  		redirect_to new_user_session_path
	  end
  end
end
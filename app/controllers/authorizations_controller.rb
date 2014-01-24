class AuthorizationsController < ApplicationController
  before_action :set_authorization, only: [:show, :edit, :update, :destroy]

  # GET /authorizations
  # GET /authorizations.json
  def index
    @authorizations = Authorization.all
  end

  # POST /authentications
  # POST /authentications.json
  def create
    auth = request.env["omniauth.auth"] 
    user_info = auth["info"] ? auth["info"] : auth["user_info"]
    authentication = Authorization.where(:provider => auth['provider'], :uid => auth['uid']).first
    authentication = Authorization.new(:provider => auth['provider'], :uid => auth['uid']) if !authentication
    # if the user exists, but does not have a link with the social service
    if !authentication.user && current_user
      authentication.user = current_user
      authentication.save
    end
    # twitter only (gets no email)
    if !authentication.user && !user_info["email"]
      flash[:notice] = "No user linked to this account. Please sign in or create a new account"
      redirect_to '/users/sign_up/'
    # if user doesnt exists, register user
    elsif !authentication.user
      user = User.where(email: user_info['email']).first
      if user
        authentication.user = user
      else
        new_user = User.new(email: user_info['email'], username: user_info['name'], first_name: user_info['first_name'], last_name: user_info['last_name'], role: "registered")
        new_user.save
        authentication.user = new_user
      end
      authentication.save
    end
    # if user exists, sign in
    if authentication.user
      sign_in authentication.user
      # raise "user signed in? #{user_signed_in?.to_s}".inspect
      flash[:notice] = "Authorization successful." 
      redirect_to root_path
    end
  end

  # DELETE /authentications/1
  # DELETE /authentications/1.json
  def destroy
     @authentication = Authorization.find(params[:id])
     @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to root_path
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_authorization
      @authorization = Authorization.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def authorization_params
      params.require(:authorization).permit(:provider, :token)
    end
end

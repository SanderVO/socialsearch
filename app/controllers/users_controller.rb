class UsersController < ApplicationController
   before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json

  def index
    @users = User.all
    authorize! :show, @users
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    authorize! :show, @user
  end

  # GET /users/new
  def new
    @user = User.new
    authorize! :edit, @users
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
    else
      password_updated = true
    end

    respond_to do |format|
      if @user.update_attributes(user_params)
        sign_in @user if password_updated
        
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        raise @user.errors.inspect
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
    authorize! :destroy, @users
  end

  # TEST ONLY - make admin
  def create_admin
    @user = User.new(email: "admin@socialsearch.com", password: "admin123", username: "Admin", role: "admin")
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :password, :salt, :email, :first_name, :last_name, :active, :activationkey, :city, :country, :street, :postal_code, :gender, :role)
    end
end

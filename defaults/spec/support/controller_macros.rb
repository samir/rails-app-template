module ControllerMacros
  def login_user
    before do
      @current_user = Factory(:user)
      sign_in @current_user
    end
  end
end


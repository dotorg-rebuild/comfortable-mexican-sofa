module AuthenticationHelper
  def login_as_editor
    session[:admin] = true
    allow(controller).to receive(:authenticate).and_return(true)
  end
end

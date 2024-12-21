# class HomeController < ActionController::API
#   include ActionView::Layouts

#   def index
#     if Config::USE_DOCS_AS_HOMEPAGE
#       render file: Rails.root.join('public/docs.html')
#     else
#       head :ok
#     end
#   end
# end

class HomeController < ActionController::API
  include ActionView::Layouts

  def index
    render file: Rails.root.join('public/docs.html')
  end
end
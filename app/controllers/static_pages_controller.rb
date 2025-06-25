class StaticPagesController < ApplicationController
  def about
    @page_title = 'About Us | LocalServiceHub'
    @page_description = 'Learn more about LocalServiceHub and our mission to connect you with trusted local service providers.'
  end
end

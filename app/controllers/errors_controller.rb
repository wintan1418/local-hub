class ErrorsController < ApplicationController
  def not_found
    render status: 404, template: 'errors/not_found', layout: 'application'
  end
end 
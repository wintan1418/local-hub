class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html { render status: 404, template: "errors/not_found", layout: "application" }
      format.json { render json: { error: "Not found" }, status: 404 }
      format.any { render status: 404, template: "errors/not_found", layout: "application" }
    end
  end
end

module Spree
  class Admin::TranslationsController < Admin::BaseController
    before_action :load_parent

    helper 'solidus_i18n/locale'
    helper 'solidus_globalize/locale'

    helper_method :collection_url

    def index
      render resource_name
    end

    private

    def load_parent
      set_resource_ivar(resource)
    end

    def resource_name
      params[:resource].singularize
    end

    def set_resource_ivar(resource)
      instance_variable_set("@#{resource_name}", resource)
    end

    def klass
      @klass ||= "Spree::#{params[:resource].classify}".constantize
    end
    # alias to model_class in order to fallback on the resource for the authorizations
    alias_method :model_class, :klass

    def resource
      @resource ||= if slugged_models.include? klass.class_name
        klass.friendly.find(params[:resource_id])
      else
        klass.find(params[:resource_id])
      end
    end

    def collection_url
      ActionController::Routing::Routes.recognize_path("admin_#{resource_name}_url", @resource)
      send "admin_#{resource_name}_url", @resource
    rescue
      send "edit_admin_#{resource_name}_url", @resource
    end

    def slugged_models
      ["SpreeProduct"]
    end
  end
end

module ApplicationHelper
  def get_alert_class_by_name(name)
    {
      :success => 'alert-success',
      :error => 'alert-danger',
      :alert => 'alert-warning',
      :notice => 'alert-info'
    }[name.to_sym] || name.to_s
  end
end

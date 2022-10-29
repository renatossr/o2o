module BillingHelper
  def kpi_formatted_ratio_html_tag(ratio)
    if ratio > 1
      signal = "+"
      css_class = "text-success"
    elsif ratio < 1
      signal = ""
      css_class = "text-danger"
    else
      signal = ""
      css_class = ""
    end
    result =
      "<h4 class=\"#{css_class} fw-bold\">#{signal}#{((ratio - 1) * 100.0).round(1)}%</h4>"
    result.html_safe
  end
end

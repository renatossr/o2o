module CalendarEventHelper
  def event_color(color)
    amount = 0.45
    hex_color = color.gsub("#", "")
    rgb = hex_color.scan(/../).map { |color| color.hex }
    rgb[0] = [(rgb[0].to_i + 255 * amount).round, 255].min
    rgb[1] = [(rgb[1].to_i + 255 * amount).round, 255].min
    rgb[2] = [(rgb[2].to_i + 255 * amount).round, 255].min
    "#%02x%02x%02x" % rgb
  end
end

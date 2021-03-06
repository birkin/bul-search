module ApplicationHelper
  def html_title_line(title, text)
    return "" if text.blank?
    # This weird concatenation is to make sure Rails
    # HTML encodes title+text but not the <br/>
    "".html_safe + ("#{title}: #{text}") + "<br/>".html_safe
  end

  # We use this to generate a new token every day and embed this
  # value in our forms and prevent spammers from reusing sessions
  # for more than one day. We should eventually track this on a
  # per request basis rather than on a daily basis but this would
  # do for now.
  def daily_token
    if ENV["DAILY_TOKEN"]
      eval(ENV["DAILY_TOKEN"])
    else
      (Math.tan(500-Date.today.yday).abs * 10000000).to_i.to_s[1..-1]
    end
  end

  def request_token
    (Random.new.rand * 10000).to_i.to_s
  end

  def spam_check?
    ENV["SPAM_CHECK"] == "yes"
  end

  def trusted_ips
    (ENV["TRUSTED_IPS"] || "").chomp.split(",")
  end

  def trusted_ip?(ip)
    trusted_ips.each do |trusted_value|
      return true if ip.start_with?(trusted_value)
    end
    false
  end
end

module DateHelpers

  def Time.yesterday
    now - 86400
  end

  def formatter(date)
    date.to_s.split(" ")[0].split("-").rotate.join("-")
  end

end

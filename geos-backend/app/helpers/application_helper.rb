module ApplicationHelper
  def b(value)
    value ? t(:true) : t(:false)
  end

  def score_level_and_name_new(level)
    case level
    when 1 then "Nível #{level}</br>(Emergente)"
    when 2 then "Nível #{level}</br>(Básico)"
    when 3 then "Nível #{level}</br>(Intermediário)"
    when 4 then "Nível #{level}</br>(Avançado)"
    else ''
    end
  end

  def score_level_and_name(level)
    case level
    when 1 then "Nível #{level} (Exploratório)"
    when 2 then "Nível #{level} (Básico)"
    when 3 then "Nível #{level} (Intermediário)"
    when 4 then "Nível #{level} (Avançado)"
    when 5 then "Nível #{level} (Muito Avançado)"
    else ''
    end
  end

  def profile_options
    User::PROFILE.map do |option|
      [human_profile_name(option), option]
    end
  end

  def human_profile_name(profile)
    t(profile, scope: 'profiles')
  end

  def activity_options
    activity = ["school", "teacher"]
    activity.map do |option|
      [human_activity_name(option), option]
    end
  end

  def human_activity_name(activity)
    t(activity, scope: 'activities')
  end

  def process_text(text)

    if text.nil?
      return ''
    end

    # Regular expression to match URLs
    url_regex = %r{
      \b
      (                           # Capture 1: entire matched URL
        (?:
          https?://               # URL protocol and colon
          |                       #   or
          www\d{0,3}[.]           # "www.", "www1.", "www2." ... "www999."
          |                       #   or
          [a-z0-9.\-]+[.][a-z]{2,4}/  # looks like domain name followed by a slash
        )
        (?:                       # One or more:
          [^\s()<>]+              # Run of non-space, non-()<>
          |                       #   or
          \((?:[^\s()<>]+|(?:\([^\s()<>]+\)))*\)  # balanced parens, up to 2 levels
        )+
        (?:                       # End with:
          \((?:[^\s()<>]+|(?:\([^\s()<>]+\)))*\)  # balanced parens, up to 2 levels
          |                       #   or
          [^\s`!()\[\]{};:'".,<>?«»“”‘’]  # not a space or one of these punct chars
        )
      )
    }ix

    # Replace URLs not already wrapped in <a> tags with <a> tags
    text.gsub(url_regex) do |url|
      if text.match?(/<a\s[^>]*href=["']#{Regexp.escape(url)}["']/)
        url
      else
        "<a href='#{url}' target='_blank'>#{url}</a>"
      end
    end.html_safe
  end

end

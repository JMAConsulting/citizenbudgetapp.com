class Notifier < ActionMailer::Base
  def thank_you(response)
    questionnaire = response.questionnaire
    organization = questionnaire.organization

    from = Mail::Address.new 'noreply@citizenbudget.com'
    from.display_name = organization.name

    to = Mail::Address.new response.email
    to.display_name = response.name if response.name?

    headers = {
      from: from.format,
      to: to.format,
      subject: t(:thank_you_subject, organization: organization.name),
    }

    if questionnaire.reply_to?
      headers[:reply_to] = questionnaire.reply_to
    end

    mail(headers) do |format|
      format.text do
        if questionnaire.thank_you_template?
          render text: Mustache.render(questionnaire.thank_you_template, {
            name: response.name,
            url: Bitly.shorten(response_url(response, host: questionnaire.domain || 'citizenbudget.com')),
          })
        end
      end
    end
  end
end

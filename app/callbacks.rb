require 'net/http'
class Callbacks
  include Sidekiq::Worker

  DELIVERED     = 0.9998
  OPENED        = 0.9
  UNIQ_OPENED   = 0.7
  CLICKED       = 0.48
  UNIQ_CLICKED  = 0.3
  COMPLAINED    = 0.001

  def perform(params)
    @recipients = params['to']
    @sample = {'my-var' => params['v:my-var']}
    @links = params['html'].scan(/href=[\'"]?([https?][^\'"]*)[\'"]?/o).flatten.compact

    trigger! delivered do |params|
      params.merge!({'event' => 'delivered'})
    end

    trigger! bounced do |params|
      params.merge!({'event' => 'bounced'})
    end

    trigger! dropped do |params|
      params.merge!({'event' => 'dropped', 'reason' => 'hardfail'})
    end

    trigger! opened do |params|
      params.merge!({'event' => 'opened'})
    end

    trigger! clicked do |params|
      params.merge!({'event' => 'clicked', 'url' => @links.shuffle.first})
    end

    trigger! complained do |params|
      params.merge!({'event' => 'complained'})
    end
  end

  protected
  def trigger!(recipients, &block)
    recipients.each_slice(100) do |recipients_slice|
      recipients_slice.each do |recipient|
        data = @sample.merge({'recipient' => recipient, 'timestamp' => Time.now.to_i})
        yield data
        res = Net::HTTP.post_form(callback_url, data)
      end
      sleep 5
    end
  end

  def callback_url
    @callback_url ||= URI('http://localhost:3000/callback.json')
  end

  def shake(items, p1, p2 = nil)
    if p2.nil?
      amount = (items.size * p1).round(0)
      items.shuffle.take(amount)
    else
      shake(items, p1) + shake(items, (p1 - p2).abs)
    end
  end

  def delivered
    @delivered ||=shake(@recipients, DELIVERED)
  end

  def bounced
    @bounced ||= (@recipients - @delivered).size > 0 ? @recipients - @delivered - @dropped : []
  end

  def dropped
    @dropped ||= (@recipients - @delivered).size > 0 ? [(@recipients - @delivered).shuffle.first] : []
  end

  def opened
    @opened ||= shake(delivered, UNIQ_OPENED, OPENED)
  end

  def clicked
    @clicked ||= shake(opened.compact, UNIQ_CLICKED, CLICKED)
  end

  def complained
    @complained ||= shake(opened.compact, COMPLAINED)
  end

end

module SipgateIo
  
  class Response
    
    attr_writer :answer_url, :hangup_url, :data_url
    
    def initialize(answer_url: nil, hangup_url: nil, data_url: nil)
      @answer_url = answer_url
      @hangup_url = hangup_url
      @data_url = data_url
    end
    
    def dial(number, caller_id: nil, anonymous: false)
      options = if number == :voicemail
                  nil
                elsif anonymous
                  { anonymous: true }
                elsif caller_id.nil?
                  nil
                else
                  { callerId: caller_id }
                end
      
      response do |xml|
        xml.Dial(options) do
          if number == :voicemail
            xml.Voicemail
          else
            xml.Number(number)
          end
        end
      end
    end
    
    def play(url)
      response do |xml|
        xml.Play do
          xml.Url(url)
        end
      end
    end
    
    GATHER_TYPES = [:dtmf]
    
    def gather(type: :dtmf, max_digits: nil, timeout: nil, play: nil)
      raise "Unknown type: #{type}" unless GATHER_TYPES.include?(type)
      
      options = {
        onData: @data_url,
        maxDigits: max_digits,
        timeout: timeout
      }
      
      # Remove unset options
      options.delete_if { |k, v| v.nil? }
      
      response do |xml|
        xml.Gather(options) do
          unless play.nil?
            xml.Play { xml.Url(play) }
          end
        end
      end
    end
    
    REJECT_REASONS = [:rejected, :busy]
    
    def reject(reason = :rejected)
      raise "Unknown reason: #{reason}" unless REJECT_REASONS.include?(reason)
      
      response do |xml|
        if reason == :rejected
          xml.Reject
        else
          xml.Reject(reason: reason)
        end
      end
    end
    
    def hangup
      response { |xml| xml.Hangup }
    end
    
    private
    
    def response
      xml = Builder::XmlMarkup.new
      xml.instruct!
      
      options = {
        onAnswer: @answer_url,
        onHangup: @hangup_url
      }
      
      # Remove unset options
      options.delete_if { |k, v| v.nil? }
      
      xml.Response(options) { |xml| yield xml }
      
      xml.target!
    end
    
  end
  
end
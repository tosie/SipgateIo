require 'test/unit'

class TestResponse < Test::Unit::TestCase
  def setup
    @response = SipgateIo::Response.new
  end

  def test_create
    assert_not_nil @response
  end

  def test_dial_simple
    assert_equal '<?xml version="1.0" encoding="UTF-8"?><Response><Dial><Number>4929923462</Number></Dial></Response>', @response.dial('4929923462')
  end
  
  def test_dial_simple_hangup_event
    @response.hangup_url = 'https://my.callback.io/on_hangup?id=23dn38'
    assert_equal '<?xml version="1.0" encoding="UTF-8"?><Response onHangup="https://my.callback.io/on_hangup?id=23dn38"><Dial><Number>4929923462</Number></Dial></Response>', @response.dial('4929923462')
    @response.hangup_url = nil
  end
  
  def test_dial_simple_answer_and_hangup_event
    @response.answer_url = 'https://my.callback.io/on_answer?id=23dn38'
    @response.hangup_url = 'https://my.callback.io/on_hangup?id=23dn38'
    assert_equal '<?xml version="1.0" encoding="UTF-8"?><Response onAnswer="https://my.callback.io/on_answer?id=23dn38" onHangup="https://my.callback.io/on_hangup?id=23dn38"><Dial><Number>4929923462</Number></Dial></Response>', @response.dial('4929923462')
    @response.answer_url = nil
    @response.hangup_url = nil
  end
  
  def test_dial_callerid
    assert_equal '<?xml version="1.0" encoding="UTF-8"?><Response><Dial callerId="4929921234"><Number>4929923462</Number></Dial></Response>', @response.dial('4929923462', caller_id: '4929921234')
  end
  
  def test_dial_voicemail
    assert_equal '<?xml version="1.0" encoding="UTF-8"?><Response><Dial><Voicemail/></Dial></Response>', @response.dial(:voicemail)
  end
  
  def test_dial_anonymous
    assert_equal '<?xml version="1.0" encoding="UTF-8"?><Response><Dial anonymous="true"><Number>4929923462</Number></Dial></Response>', @response.dial('4929923462', anonymous: true)
  end
  
  def test_play
    assert_equal '<?xml version="1.0" encoding="UTF-8"?><Response><Play><Url>http://my.soundhost.wav/music.wav</Url></Play></Response>', @response.play('http://my.soundhost.wav/music.wav')
  end
  
  def test_gather
    @response.data_url = 'https://my.callback.io/on_data?id=23dn38'
    assert_equal '<?xml version="1.0" encoding="UTF-8"?><Response><Gather onData="https://my.callback.io/on_data?id=23dn38"><Play><Url>http://my.soundhost.wav/music.wav</Url></Play></Gather></Response>', @response.gather(play: 'http://my.soundhost.wav/music.wav')
    @response.data_url = nil
  end
end

# Useful for sending email through Gmail.
#
# Example:
#
#    require "net/smtp"
#    require "smtp_tls"
#
#     username = "joeblow"
#     password = "topsekrit"
#     msg = some_code_that_builds_my_message
#     Net::SMTP.start(
#       "smtp.gmail.com" , 
#       587, 
#       "localhost.localdomain", 
#       username, 
#       password, 
#       "plain"
#     ){ |smtp|
#        smtp.send_message(msg, "joe.blow999@gmail.com", "bono@number2yeahyeahyeah.org")
#    }
#    
# http://d.hatena.ne.jp/zorio/20060416
# http://www.jamesbritt.com/2007/12/18/sending-mail-through-gmail-with-ruby-s-net-smtp

require "openssl"
require "net/smtp"

Net::SMTP.class_eval do

private

  def do_start(helodomain, user, secret, authtype)
    raise IOError, 'SMTP session already started' if @started
    check_auth_args user, secret, authtype if user or secret

    sock = timeout(@open_timeout) { TCPSocket.open(@address, @port) }
    @socket = Net::InternetMessageIO.new(sock)
    @socket.read_timeout = 60 #@read_timeout
    @socket.debug_output = STDERR #@debug_output

    check_response(critical { recv_response() })
    do_helo(helodomain)

    raise 'openssl library not installed' unless defined?(OpenSSL)
    starttls
    ssl = OpenSSL::SSL::SSLSocket.new(sock)
    ssl.sync_close = true
    ssl.connect
    @socket = Net::InternetMessageIO.new(ssl)
    @socket.read_timeout = 60 #@read_timeout
    @socket.debug_output = STDERR #@debug_output
    do_helo(helodomain)

    authenticate user, secret, authtype if user
    @started = true
  ensure
    unless @started
      # authentication failed, cancel connection.
        @socket.close if not @started and @socket and not @socket.closed?
      @socket = nil
    end
  end

  def do_helo(helodomain)
     begin
      if @esmtp
        ehlo helodomain
      else
        helo helodomain
      end
    rescue Net::ProtocolError
      if @esmtp
        @esmtp = false
        @error_occured = false
        retry
      end
      raise
    end
  end

  def starttls
    getok("STARTTLS")
  end
  
end

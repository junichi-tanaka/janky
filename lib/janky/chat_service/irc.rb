require 'chinch'

module Janky
  module ChatService
    class Irc
      def initialize
        @rooms = {}
        @bot = Cinch::Bot.new do
          configure do |c|
            c.server = settings["JANKY_CHAT_IRC_SERVER"]
            c.channels = settings["JANKY_CHAT_IRC_CHANNELS"].split(',')
            c.nick = settings["JANKY_CHAT_IRC_NICK"]
            c.password = settings["JANKY_CHAT_IRC_PASSWORD"] if settings["JANKY_CHAT_IRC_PASSWORD"]
            c.port = settings["JANKY_CHAT_IRC_PORT"]
          end
        end
        @t = Thread.new do
          @bot.start
        end
      end

      attr_writer :rooms

      def speak(room_name, message)
        if !@rooms.values.include?(room_name)
          raise Error, "Unknown room #{room_name.inspect}"
        end
        @bot.channel_list.find_ensured(room_name).msg(message, true)
      end

      def rooms
        acc = []
        @rooms.each do |id, name|
          acc << Room.new(id, name)
        end
        acc
      end
    end
  end

  register_chat_service "irc", ChatService::Irc
end

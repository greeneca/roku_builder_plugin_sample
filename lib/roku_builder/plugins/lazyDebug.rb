# ********** Copyright Viacom, Inc. Apache 2.0 **********

module RokuBuilder

  class LazyDebug < Util
    extend Plugin

    # Hash of commands
    # Each command efines a hash with three optional values
    # Setting device to true will require that there is an avaiable device
    # Setting source to true will require that the user passes a source option
    #   with the command
    # Setting stage to true will require that the user passes a stage option
    #   with the command
    def self.commands
      {
        lazy_debug: {device: true, source: false, stage: false},
      }
    end

    # Hook to add options to the parser
    # The keys set in options for commands must match the keys in the commands
    #   hash
    def self.parse_options(parser:,  options:)
      parser.separator "Commands:"
      parser.on("--lazyDebug", "Example of a sample command") do
        options[:stage] ||= "core"
        options[:lazy_debug] = true
      end
    end

    # Array of plugins the this plugin depends on
    def self.dependencies
      []
    end

    def init
      #Setup
    end

    # Sample command
    # Method name must match the key in the commands hash
    def lazy_debug(options:)
      @logger.unknown "Starting LazyDebug"
      @debug_config = read_config()
      loop do
        begin
          socket = TCPSocket.open(@roku_ip_address, 54333)
          @logger.unknown "Started Connection"
          monitor = Thread.new {
            monitor_socket(socket)
          }
          monitor.abort_on_exception = true
          monitor[:timestamp] = Time.now
          loop do
            sleep 5
            if (Time.now - monitor[:timestamp]) > 4
              raise Errno::ETIMEDOUT
            end
          end
        rescue IOError => e
          @logger.info "IOError #{e.message}"
          monitor.kill if monitor
        rescue Errno::ECONNRESET => e
          @logger.info "Connection Reset #{e.message}"
          monitor.kill if monitor
        rescue Errno::ETIMEDOUT => e
          @logger.info "Connection Reset #{e.message}"
          monitor.kill if monitor
        end
      end
    end

    def monitor_socket(socket)
      loop do
        line = socket.gets
        if line and not line.empty?
          @logger.debug "Recieved Line"
          @logger.debug line
          data = JSON.parse(line, {symbolize_names: true})
          handle_data(data, socket)
        end
      end
    end
    def handle_data(data, socket)
      case data[:command]
      when "stayAwake"
        Thread.current[:timestamp] = Time.now
      when "setBrand"
        @logger.debug "Set brand: #{data[:value]}"
        @brand = data[:value].to_sym
        socket.puts({command: "setBrand", success: true}.to_json)
      when "getData"
        @logger.debug "Retreving Data: #{data[:value]}"
        requested_data = @debug_config[data[:value].to_sym]
        if requested_data
          send_data = requested_data[:data].deep_dup
          counts = requested_data[:counts]
          counts[@brand] ||= 1
          write_config(@debug_config)
          replace_strings(send_data, {brand: @brand, count: counts[@brand]})
          socket.puts({command: "getData", success: true, value: send_data}.to_json)
        else
          socket.puts({command: "getData", success: false}.to_json)
        end
      when "incrementCount"
        requested_data = @debug_config[data[:value].to_sym]
        if requested_data
          counts = requested_data[:counts]
          counts[@brand] ||= 0
          counts[@brand] += 1
          write_config(@debug_config)
        end
      else
        socket.puts({command: data[:command], success: false}.to_json)
      end
    end
    def read_config()
      config = nil
      File.open(config_path) do |io|
        config = JSON.parse(io.read, {symbolize_names: true})
      end
      config
    end
    def write_config(config)
      File.open(config_path, "w") do |io|
        io.write(JSON.pretty_generate(config))
      end
    end
    def config_path()
      file = File.join(@config.project[:directory], ".roku_builder_lazy_debug.json")
      unless File.exist?(file)
        @logger.fatal "Missing Config File"
        exit
      end
      return file
    end

    def replace_strings(config, replacements)
      config.each_key do |key|
        if config[key].class == String
          replacements.each_pair do |replace, value|
            config[key].gsub!("{#{replace}}", value.to_s)
          end
        elsif config[key].class = Hash
          replace_strings(config[key], replacements)
        end
      end
    end
  end

  # Register your plugin
  RokuBuilder.register_plugin(LazyDebug)
end

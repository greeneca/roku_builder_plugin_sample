# ********** Copyright Viacom, Inc. Apache 2.0 **********

module RokuBuilder

  # Sample Plugin
  class Sample < Util
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
        sample: {device: false, source: false, stage: false},
      }
    end

    # Hook to add options to the parser
    # The keys set in options for commands must match the keys in the commands
    #   hash
    def self.parse_options(parser:,  options:)
      parser.separator "Commands:"
      parser.on("--sample", "Example of a sample command") do |o|
        options[:sample] = o
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
    def sample(options:)
      @logger.unknown "Sample Command Execuited"
      #@config
      #@roku_ip_address
      #@dev_username
      #@dev_password
      #@url
      #simple_connection
      #multipart_connection(port: nil)
    end

  end

  # Register your plugin
  RokuBuilder.register_plugin(Sample)
end

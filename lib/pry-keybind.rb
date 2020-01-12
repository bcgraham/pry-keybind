require "pryline"
require "pry_ext"
require "hooks"
class PryKeybind
  class << self
    attr_accessor :registry
    attr_accessor :layers
  end

  attr_accessor :pry_instance

  self.registry ||= {}
  self.layers ||= []

  def self.register(constant, key, options = {}, &block)
    self.registry ||= {}
    self.layers ||= []
    self.registry[constant] = new(key, options, &block)
  end

  def self.register_anonymous(key, options = {}, &block)
    constant = format("BINDING_%09d", Random.random_number(1_000_000_000)).to_sym
    register(constant, key, options, &block)
  end

  def self.bind_all!(pry, source: nil)
    # puts "binding / layer size?: #{layers.size} / source: #{source}"
    layers << [*registry.values].map do |key_binding|
      key_binding.pry_instance = pry
      key_binding.bind!
    end.compact
  end

  def self.unbind_all!(pry_instance, source: nil)
    # puts "unbinding / layer size?: #{layers.size} / source: #{source}"
    return unless layer = layers.pop

    layer.each do |key_binding|
      key_binding.pry_instance = pry_instance
      key_binding.unbind!
    end
  end


  def initialize(key, options = {}, &block)
    raise ArgumentError, "block required" unless block_given?

    @options = options
    @key = KeySequence.new(key)
    @block = block
    @bound = false
  end

  def bind!
    return nil if bound?

    Pryline.public_send(bind_method, key.for_readline, &block_caller)

    @bound = true

    self
  end

  def unbind!
    return self unless bound?

    Pryline.public_send(unbind_method, key.for_readline)

    @bound = false

    self
  end

  attr_reader :key
  private :key

  private

  def bound?
    @bound
  end

  def bind_method
    key.sequence? ? :bind_keyseq : :bind_key
  end

  def unbind_method
    key.sequence? ? :unbind_keyseq : :unbind_key
  end

  def save_input?
    @options[:save_input]
  end

  def no_refresh?
    @options[:no_refresh]
  end

  def refresh_line?
    !no_refresh? || save_input?
  end

  def block_caller
    @block_caller ||= Proc.new do
      # puts "\npry keybind 99 keybindings accepting line\n"
      if save_input?
        Pry.config.input_states << InputState.save!(pry_instance)
      end

      pry_instance.define_singleton_method(:whole_buffer) do
        "#{eval_string}#{Pryline.line_buffer}"
      end

      pry_instance.define_singleton_method(:whole_buffer=) do |input|
        self.eval_string = ""
        Pryline.delete_text
        Pryline.point = 0
        Pryline.insert_text input.chomp
      end

      @block.call(pry_instance)

      Pryline.refresh_line if refresh_line?
    end
  end

  class KeySequence
    attr_reader :key

    def initialize(key)
      @key = key
    end

    def for_readline
      unless String === key
        raise ArgumentError, "can't recognize: key.class == #{key.class} / key.inspect == #{key.inspect}"
      end

      [key.chars.map(&:ord)].flatten.pack("C*")
    end

    def sequence?
      String === key && key.size > 1
    end

    private

    def single?
      String === key && key.size == 1
    end
  end

  class InputState
    attr_reader :pry_instance

    def self.save!(pry_instance)
      new(pry_instance).save!
    end

    def initialize(pry_instance)
      @pry_instance = pry_instance
    end

    def save!(pry_eval: true, readline_buffer: true)
      save_pry_eval_string if pry_eval
      save_readline_line_buffer if readline_buffer

      self
    end

    def restore!(pry_eval: true, readline_buffer: true)
      restore_pry_eval_string if pry_eval
      restore_readline_line_buffer if readline_buffer

      self
    end

    private

    def save_pry_eval_string
      @eval_string = pry_instance.eval_string
      @pry_state_saved = true
    end

    def save_readline_line_buffer
      @line_buffer, @point = Pryline.line_buffer, Pryline.point
      old_hook = Pryline.pre_input_hook
      Pryline.pre_input_hook = Proc.new do
        restore_readline_line_buffer
        Pryline.pre_input_hook = old_hook
      end
      @readline_state_saved = true
    end

    def restore_pry_eval_string
      return false unless @pry_state_saved
      pry_instance.eval_string = @eval_string
      @pry_state_saved = false

      true
    end

    def restore_readline_line_buffer
      return false unless @readline_state_saved

      Pryline.insert_text(@line_buffer)
      Pryline.point = @point

      Pryline.refresh_line
      @readline_state_saved = false

      true
    end
  end
end
require "pry_ext"

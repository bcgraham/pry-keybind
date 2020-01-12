class Pry
  def self.bind_key(key, options = {}, &block)
    PryKeybind.unbind_all!(self)
    PryKeybind.register_anonymous(key, options, &block)
    PryKeybind.bind_all!(self)

    true
  end
end

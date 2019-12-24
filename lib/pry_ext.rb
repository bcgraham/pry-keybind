class Pry
  def bind_key(key, options = {}, &block)
    @anonymous_binding_count ||= 0
    @anonymous_binding_count = @anonymous_binding_count + 1
    PryKeybind.unbind_all!(self)
    PryKeybind.register("BINDING_#{@anonymous_binding_count}", key, options, &block)
    PryKeybind.bind_all!(self)

    true
  end
end

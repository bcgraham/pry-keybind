Pry.hooks.add_hook(:when_started, "initialize input states for keybindings") do |_output, binding, pry_instance|
  Pry.config.input_states ||= []
end

Pry.hooks.add_hook(:before_session, "restore input state & bind keybindings") do |output, binding, pry_instance|
  if (input_state = Pry.config.input_states.pop)
    input_state.restore!(readline_buffer: false)
  end
  PryKeybind.bind_all!(pry_instance, source: :before_session)
end

Pry.hooks.add_hook(:after_session, "unbind keybindings") do |output, _binding, pry_instance|
  PryKeybind.unbind_all!(pry_instance, source: :after_session)
end

Pry.hooks.add_hook(:after_eval, "reset keybindings") do |output, pry_instance|
  PryKeybind.unbind_all!(pry_instance, source: :after_eval)
  PryKeybind.bind_all!(pry_instance, source: :after_eval)
end

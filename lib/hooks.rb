Pry.hooks.add_hook(:when_started, "initialize input states for keybindings") do |_output, binding, pry|
  Pry.config.input_states ||= []
end

Pry.hooks.add_hook(:before_session, "custom_keybindings") do |output, binding, pry|
  if (input_state = Pry.config.input_states.pop)
    input_state.restore!(readline_buffer: false)
  end
  PryKeybind.bind_all!(pry)
end
Pry.hooks.add_hook(:after_session, "custom keybindings") do |output, _binding, pry|
  PryKeybind.unbind_all!(pry)
end

# Terminal emulators are inherently not designed to emit keyup events, but
# we'd really like to be able to respond to them because many cubers are
# accustomed to doing something like this when timing solves:
#   1. scramble the cube
#   2. hit the spacebar to start inspection
#   3. inspect the cube
#   4. hold down the spacebar while taking one last look
#   5. release the spacebar to start the timer

# Listening for keyup in the general case is infeasible without taking drastic
# measures, but thankfully our use case is very specific: we know exactly when
# the user is going to begin holding down the key, and we can make the fairly
# reasonable assumption that they won't be releasing it immediately. This lets
# us just barely get away with the following approach:
#   1. wait for the initial keydown (which we assume is in fact a held key)
#   2. send reads of the held key to a channel
#   3. update the time at which we received the read
#   4. assume the key has been released when we haven't received a key within
#      a given timeframe, determined dynamically based on the key repeat rate
#      we observed while the key was being held

def keyup
  # rolling sample of the time between key reads, initially unrealistically
  # long to account for slow autorepeat; if it's disabled, we're hosed. :/
  gaps = [1.second] * 5

  ch = Channel(Char?).new
  STDIN.raw &.read_char
  last = Time.local

  spawn do
    loop do
      select
      when ch.receive
        now = Time.local
        gaps << now - last.as Time
        gaps.shift
        last = now
      when timeout gaps.max * 1.5
      # super-conservative timeout because we really don't want to break while
      # the user is still holding the key down, since this will cause the timer
      # to start unexpectedly

      # When we get here, there's already a call to #read_char waiting for
      # input. This will all have been for naught if the user has to release
      # the held key only to send another, so we send a device status report
      # to the terminal, which effectively writes "\e[0n" to standard input.
      # The '\e' will then be consumed by the buffered call and sent to the
      # channel we're about to close, triggering the rescue.
        print "\e[5n"
        ch.close
        break
      end
    end
  end

  loop { ch.send STDIN.raw &.read_char }
rescue Channel::ClosedError
  3.times { STDIN.read_byte } # consume "[0n" from the DSR
  # return when the user last "pressed" a key, which isn't *quite* when they
  # released it, but it's very close; maybe add the mean of gaps to correct?
  last
end

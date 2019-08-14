module Ruff
  module Throws
    # `Eff` is internal object.
    #
    # They make effects encapsulate with ID and arguments to be sent to the handler.
    class Eff

      # makes the object unique.
      attr_reader :id

      # passes to a handler which can catch the effect.
      attr_reader :args

      # creates a new object with `id` and `args`.
      def initialize(id, args)
        @id = id; @args = args
      end
    end
  end

  module Throws
    # `Resend` is internal object like `Eff`.
    #
    # It is used when an effect is unable to be handled and should be thrown to the outer handler.
    class Resend

      #is abstracted effect (such as `Eff` or (re)thrown `Resend`).
      attr_reader :eff

      # is a continuation of `eff` thrown context.
      attr_reader :k

      # creates a new object with `eff` and `k`.
      def initialize(eff, k)
        @eff = eff; @k = k
      end
    end
  end
end

module Ruff
  module Throws
    # _Eff_ is internal object.
    #
    # They make effects encapsulate with ID and arguments to be sent to the handler.
    class Eff

      # makes the object unique.
      attr_reader :id

      # passes to a handler which can catch the effect.
      attr_reader :args

      # creates a new object with _id_ and _args_.
      def initialize(id, args)
        @id = id; @args = args
      end
    end
  end

  module Throws
    # _Resend_ is internal object like _Eff_.
    #
    # It is used when an effect is unable to be handled and should be thrown to the outer handler.
    class Resend

      #is abstracted effect (such as _Eff_ or (re)thrown _Resend_).
      attr_reader :eff

      # is a continuation of _eff_ thrown context.
      attr_reader :k

      # creates a new object with _eff_ and _k_.
      def initialize(eff, k)
        @eff = eff; @k = k
      end
    end
  end
end

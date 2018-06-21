defmodule Events do

  # * CreateEvent
  # * BalanceEvent
  # * WithdrawEvent
  # * DepositoEvent

  defmodule CreateEvent do
    defstruct [:name]
    @type t :: %CreateEvent{name: String.t}
  end

  defmodule BalanceEvent do
    defstruct [:name]
    @type t :: %BalanceEvent{name: String.t}
  end

  defmodule WithdrawEvent do
    defstruct [:name, :amount]
    @type t :: %WithdrawEvent{name: String.t, amount: pos_integer()}
  end

  defmodule DepositEvent do
    defstruct [:name, :amount]
    @type t :: %DepositEvent{name: String.t, amount: pos_integer()}
  end

  defmodule RegisterEvent do
    defstruct [:name]
    @type t :: %RegisterEvent{name: String.t}
  end

  @type write_event :: CreateEvent.t | WithdrawEvent.t | DepositEvent.t
  @type read_event :: BalanceEvent.t | RegisterEvent.t

end

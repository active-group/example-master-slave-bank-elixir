defmodule Slave do


  require Logger

  use GenServer

  alias Events.{BalanceEvent, WithdrawEvent, DepositEvent, CreateEvent, RegisterEvent}

  def balance(bank, name), do: GenServer.call(bank, %BalanceEvent{name: name})
  def withdraw(name, amount), do: Master.withdraw(name, amount)
  def deposit(name, amount), do: Master.deposit(name, amount)
  def create(name), do: Master.create(name)

  def start(name), do: GenServer.start(__MODULE__, name, name: name)
  def start_link(name), do: GenServer.start_link(__MODULE__, name, name: name)
  def init(name), do: GenServer.call(Master.master_name(), %RegisterEvent{name: name})

  def handle_cast(%DepositEvent{name: name, amount: amount}, state) do
    previous_amount = Map.get(state, name)
    new_state = if previous_amount do
      Map.put(state, name, previous_amount + amount)
    else
      state
    end
    {:noreply, new_state}
  end

  def handle_cast(%WithdrawEvent{name: name, amount: amount}, state) do
    previous_amount = Map.get(state, name)
    new_state = if previous_amount do
      Map.put(state, name, previous_amount - amount)
    else
      state
    end

    {:noreply, new_state}
  end

  def handle_cast(%CreateEvent{name: name}, state) do
    new_state = if(Map.get(state, name)) do
      state
    else
      Map.put(state, name, 0)
    end
    {:noreply, new_state}
  end

  @spec handle_call(Events.read_event, any(), map()) :: {:reply, any(), map()}

  def handle_call(%BalanceEvent{name: name}, _ , state) do
    balance = Map.get(state, name)
    reply = if(balance) do
      {:ok, balance}
    else
      {:error, :not_found}
    end

    {:reply, reply, state}
  end
end

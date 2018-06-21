defmodule Master do

  use GenServer
  require Logger

  alias Events.{BalanceEvent, CreateEvent, WithdrawEvent, DepositEvent, RegisterEvent}

  defmodule MasterState do
    defstruct [:balances, :slaves]
  end

  def master_name(), do: :master

  def balance(name), do: GenServer.call(master_name(), %BalanceEvent{name: name})
  def withdraw(name, amount), do: GenServer.cast(master_name(), %WithdrawEvent{name: name, amount: amount})
  def deposit(name, amount), do: GenServer.cast(master_name(), %DepositEvent{name: name, amount: amount})
  def create(name), do: GenServer.cast(master_name(), %CreateEvent{name: name})

  def start(), do: start(nil)
  def start(_), do: GenServer.start(__MODULE__, :something, name: master_name())
  def start_link(_), do: GenServer.start_link(__MODULE__, :something, name: master_name())

  def init(_), do: {:ok, %MasterState{balances: %{}, slaves: []}}

  def broadcast(slaves, event), do: slaves |> Enum.each(fn slave -> GenServer.cast(slave, event) end)


  def handle_cast(%DepositEvent{name: name, amount: amount} = event, %MasterState{balances: b, slaves: slaves} = s) do
    broadcast(slaves, event)
    previous_amount = Map.get(b, name)
    new_state = if previous_amount do
      Map.put(b, name, previous_amount + amount)
    else
      b
    end
    {:noreply, %{s | balances: new_state}}
  end

  def handle_cast(%WithdrawEvent{name: name, amount: amount} = event,  %MasterState{balances: b, slaves: slaves} = s) do
    broadcast(slaves, event)
    previous_amount = Map.get(b, name)
    new_state = if previous_amount do
      Map.put(b, name, previous_amount - amount)
    else
      b
    end

    {:noreply, %{s | balances: new_state}}
  end

  def handle_cast(%CreateEvent{name: name} = event,  %MasterState{balances: b, slaves: slaves} = s) do
    broadcast(slaves, event)
    new_state = if(Map.get(b, name)) do
      b
    else
      Map.put(b, name, 0)
    end

    {:noreply, %{s | balances: new_state}}
  end


  def handle_call(%BalanceEvent{name: name}, _ ,  %MasterState{balances: b} = s) do
    balance = Map.get(b, name)
    reply = if(balance) do
      {:ok, balance}
    else
      {:error, :not_found}
    end
    {:reply, reply, s}
  end

  def handle_call(%RegisterEvent{name: name}, _, %MasterState{balances: b, slaves: slaves} = s) do
    Logger.info("Registrating #{inspect name}")
    Process.monitor(name)
    {:reply, {:ok, b}, %{s | slaves: [name | slaves]}}
  end


  def handle_info({:DOWN, ref, _, {name, _}, reason}, %MasterState{slaves: slaves} = state) do
    Logger.info("Removing #{inspect name} due to reason: #{inspect reason}")
    Process.demonitor(ref)
    {:noreply, %{state | slaves: List.delete(slaves, name)}}
  end



end

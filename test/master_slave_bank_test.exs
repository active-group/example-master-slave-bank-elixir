defmodule MasterSlaveBankTest do
  use ExUnit.Case

  test "verifies proper functionality of the master slave concept" do

    Master.start()

    Master.create("Simon")
    Master.deposit("Simon", 100)

    Slave.start(:slave1)
    Slave.start(:slave2)

    assert {:ok, 100} = Slave.balance(:slave1, "Simon")
    assert {:ok, 100} = Slave.balance(:slave2, "Simon")

    Slave.create("Mark")
    Slave.deposit("Mark", 200)
    Slave.deposit("Mark", 300)
    Slave.withdraw("Mark", 400)

    Process.sleep(10)

    assert {:ok, 100} = Slave.balance(:slave1, "Mark")
    assert {:ok, 100} = Slave.balance(:slave2, "Mark")
    assert {:ok, 100} = Master.balance("Mark")

  end
end

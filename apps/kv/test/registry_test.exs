defmodule KV.RegistryTest do
  use ExUnit.Case, async: true
  
  setup context do
    {:ok, _pid} = KV.Registry.start_link(context.test)
    {:ok, registry: context.test}
  end
  
  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "shopping") == :error
    
    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    
    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end
  
  test "removes buckets on exit", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    
    Agent.stop(bucket)
    _ = KV.Registry.create(registry, "bogus")
    assert KV.Registry.lookup(registry, "shopping") == :error
  end
  
  test "removes bucket on crash", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    
    Process.exit(bucket, :shutdown)
    
    ref = Process.monitor(bucket)
    assert_receive {:DOWN, ^ref, _, _, _}

    _ = KV.Registry.create(registry, "bogus")
    assert KV.Registry.lookup(registry, "shopping") == :error
  end
  
  test "mix starts the KV application" do
    assert Process.whereis(KV.Bucket.Supervisor)
    assert List.keyfind(Application.started_applications(), :kv, 0)
  end
  
end

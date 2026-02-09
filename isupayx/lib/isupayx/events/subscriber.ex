defmodule Isupayx.Events.Subscriber do
  use GenServer
  alias Phoenix.PubSub

  @pubsub Isupayx.PubSub
  @max_retries 3
  @critical_events ["authorized", "failed"]

  # Public start
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{
      retry_queue: %{},
      dead_letter: []
    }, name: __MODULE__)
  end

  def init(state) do
    PubSub.subscribe(@pubsub, "txn:transaction:authorized")
    PubSub.subscribe(@pubsub, "txn:transaction:failed")
    {:ok, state}
  end

  # Receive event
  def handle_info({:transaction_event, event}, state) do
    mailbox_size = Process.info(self(), :message_queue_len) |> elem(1)

    cond do
      mailbox_size > 100 and not critical?(event) ->
        IO.puts("Dropping non-critical event due to back-pressure")
        {:noreply, state}

      true ->
        process_event(event, state)
    end
  end

  # Retry handler
  def handle_info({:retry, event, attempt}, state) do
    attempt_process(event, attempt, state)
  end

  # -----------------------------------------
  # INTERNAL LOGIC
  # -----------------------------------------

  defp process_event(event, state) do
    attempt_process(event, 1, state)
  end

  defp attempt_process(event, attempt, state) do
    case simulate_webhook(event) do
      :ok ->
        IO.puts("Webhook delivered successfully")
        {:noreply, state}

      :error ->
        if attempt < @max_retries do
          delay = retry_delay(attempt)
          Process.send_after(self(), {:retry, event, attempt + 1}, delay)
          IO.puts("Retrying in #{delay} ms (attempt #{attempt})")
          {:noreply, state}
        else
          IO.puts("Moved to Dead Letter Queue")
          new_state = %{state | dead_letter: [event | state.dead_letter]}
          {:noreply, new_state}
        end
    end
  end

  # -----------------------------------------
  # Helpers
  # -----------------------------------------

  defp simulate_webhook(event) do
    # 30% failure simulation
    if :rand.uniform(10) <= 3 do
      :error
    else
      IO.inspect(event, label: "Webhook Simulation")
      :ok
    end
  end

  defp retry_delay(1), do: 1000
  defp retry_delay(2), do: 5000
  defp retry_delay(3), do: 30000

  defp critical?(event) do
    event.event_type in @critical_events
  end
end

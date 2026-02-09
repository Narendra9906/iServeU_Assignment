defmodule Isupayx.Events.Publisher do
  alias Phoenix.PubSub

  @pubsub Isupayx.PubSub

  def publish(event_type, txn) do
    topic = "txn:transaction:#{event_type}"

    event = %{
      event_id: Ecto.UUID.generate(),
      event_type: event_type,
      transaction_id: txn.reference_id,
      merchant_id: txn.merchant_id,
      amount: txn.amount,
      timestamp: DateTime.utc_now(),
      data: txn
    }

    PubSub.broadcast(@pubsub, topic, {:transaction_event, event})
  end
end

defmodule Kickbox.VerificationTest do
  use ExUnit.Case
  alias Kickbox.Verification

  test "new_verification only marks deliverable emails valid" do
    verification = Verification.new_verification(result: "deliverable")

    assert verification.valid?
  end


  test "new_verification marks non deliverable emails invalid" do
    not_valid = ["undeliverable", "unknown", "risky"]

    for result <- not_valid do
      verification = Verification.new_verification(result: result)

      refute verification.valid?
    end
  end
end

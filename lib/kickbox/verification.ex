defmodule Kickbox.Verification do
  defstruct  email: nil,
      success?: false,
      role?: false,
      free?: false,
      accept_all?: false,
      disposable?: false,
      did_you_mean: nil,
      success?: false,
      valid?: false,
      domain: nil,
      user: nil,
      result: nil,
      reason: nil,
      message: nil,
      sendex: 0,
      balance: 0

  def new_verification(attrs \\ []) when is_list(attrs) do
    %__MODULE__{} |> struct!(attrs) |> add_validity()
  end

  defp add_validity(verification) do
    valid = verification.result == "deliverable"
    %{verification | valid?: valid}
  end
end

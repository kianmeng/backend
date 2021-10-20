defmodule Cambiatus.Payments.ContributionTest do
  use Cambiatus.DataCase

  alias Cambiatus.Payments.Contribution

  setup do
    community = insert(:community)
    user = insert(:user)

    params = %{
      amount: 10.01,
      payment_method: "paypal",
      currency: "BRL",
      status: "created",
      community_id: community.symbol,
      user_id: user.account
    }

    %{params: params}
  end

  test "valid contribution with correct fields", %{params: params} do
    assert %{valid?: true} = Contribution.changeset(%Contribution{}, params)
  end

  test "invalid contribution with invalid currency", %{params: params} do
    assert %{valid?: false, errors: [currency: _]} =
             Contribution.changeset(%Contribution{}, %{params | currency: "JPY"})
  end

  test "invalid contribution with invalid payment method", %{params: params} do
    assert %{valid?: false, errors: [payment_method: _]} =
             Contribution.changeset(%Contribution{}, %{params | payment_method: "stripe"})
  end

  test "invalid contribution with invalid status", %{params: params} do
    assert %{valid?: false, errors: [status: _]} =
             Contribution.changeset(%Contribution{}, %{params | status: "goodtogo"})
  end

  test "invalid contribution with bad combination of currency and payment_method", %{
    params: params
  } do
    assert %{valid?: false, errors: [payment_method: _]} =
             Contribution.changeset(%Contribution{}, %{
               params
               | currency: "BTC",
                 payment_method: "paypal"
             })
  end
end

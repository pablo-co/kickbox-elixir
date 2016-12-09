# Kickbox

[![CircleCI](https://circleci.com/gh/pablo-co/kickbox-elixir.svg?style=svg)](https://circleci.com/gh/pablo-co/kickbox-elixir)

A [Kickbox] (https://kickbox.io/) API client written in Elixir.

## Installation

The package can be installed as:

  1. Add kickbox to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      # Get from hex
      [{:kickbox, "~> 0.1.0"}]
      # Or use the latest from master
      [{:kickbox, github: "pablo-co/kickbox-elixir"}]
    end
    ```

  2. Ensure kickbox is started before your application:

    ```elixir
    def application do
      [applications: [:kickbox]]
    end
    ```

  3. Add your Kickbox API key to your config

    > You can set the `KICKBOX_API_KEY` environment variable or can set it
    > manually:

    ```elixir
    # In your configuration file:
    #  * General configuration: config/config.exs
    #  * Recommended production only: config/prod.exs

    config :kickbox, :kickbox_api_key, api_key: "my_api_key"
    ```

## Verifying emails

You call `Kickbox.verify/2` with an email and an optional keyword list to query
the kickbox service.
```elixir
# Just verify email
Kickbox.verify("some_email@email.com")

# Verify email specifying a max timeout of 9 seconds
Kickbox.verify("some_email@email.com", timeout: 9000)

# In general
Kickbox.verify(email_string, options)
```

You can then check the `Kickbox.Verification` struct for information regarding
the queried email.

```elixir
verification = Kickbox.verify("some_email@email.com")

verification.valid?
# false

verification.reason
# invalid_domain
```

See [Vertication struct](#verification-struct) for more information.

### Options

The valid `options` are:
 * `api_key`: Your Kickbox API key. It can also be configured using the
   `KICKBOX_API_KEY` environment variable or through a configuration file (see
   step 3).
 * `timeout`: Maximum time, in milliseconds, for the API to complete a
   verification request (default 6000).

> `options` is a keyword list which gets converted to URL params, thus you can
> use any key/value you want (Note: These should be valid API params or they
> might get ignored by Kickbox).

### Verification struct

`Kickbox.verify/2` returns a `Kickbox.Verification` struct which contains
information regarding the verification of the email.

* __result__ string - The verification result: `deliverable`, `undeliverable`,
`risky`, `unknown`.
* __reason__ string - The reason for the result. Possible reasons are:
  * __invalid\_email__ - Specified email is not a valid email address syntax.
  * __invalid\_domain__ - Domain for email does not exist.
  * __rejected\_email__ - Email address was rejected by the SMTP server, email
    address does not exist.
  * __accepted\_email__ - Email address was accepted by the SMTP server.
  * __low\_quality__ - Email address has quality issues that may make it a risky
    or low-value address.
  * __low\_deliverability__ - Email address appears to be deliverable, but
    deliverability cannot be guaranteed.
  * __no\_connect__ - Could not connect to SMTP server.
  * __timeout__ - SMTP session timed out.
  * __invalid\_smtp__ - SMTP server returned an unexpected/invalid response.
  * __unavailable\_smtp__ - SMTP server was unavailable to process our request.
  * __unexpected_error__ - An unexpected error has occurred.
* __role?__ true | false - true if the email address is a role address
  (postmaster@example.com, support@example.com, etc).
* __free?__ true | false - true if the email address uses a free email service
  like gmail.com or yahoo.com.
* __disposable?__ true | false - true if the email address uses a disposable
  domain like trashmail.com or mailinator.com.
* __accept\_all?__ true | false - true if the email was accepted, but the domain
  appears to accept all emails addressed to that domain.
* __did\_you\_mean__ null | string - Returns a suggested email if a possible
  spelling error was detected. (bill.lumbergh@gamil.com ->
  bill.lumbergh@gmail.com)
* __sendex__ float - A quality score of the provided email address ranging
  between 0 (no quality) and 1 (perfect quality). More information on the Sendex
  Score can be found here.
* __email__ string - Returns a normalized version of the provided email address.
  (BoB@example.com -> bob@example.com)
* __user__ string - The user (a.k.a local part) of the provided email address.
  (bob@example.com -> bob)
* __domain__ string - The domain of the provided email address.
  (bob@example.com -> example.com)
* __success?__ true | false - true if the API request was successful (i.e., no
  authentication or unexpected errors occurred)
* __valid?__ true | false - true if the email address is `deliverable` (i.e.,
  `result` key has a value of `deliverable`).

You can see all the latest documentation and a more complete explanation at
Kickbox' [API Documentation](http://docs.kickbox.io/docs/using-the-api).

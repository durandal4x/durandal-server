# Translations
Durandal intends to support translations.

## Improving an existing locale
To improve or extend an existing locale you just need to identify the relevant string(s) you want to improve and update them.

Translation strings live in `.po` files located within `priv/gettext/` and then the folder for the locale. For example the British English translations are in `priv/gettext/en_gb`.

Phoenix should make use of the hot reloading allowing you to see the changes take place live.

## Adding new locale strings
If your change brings in new locale strings (e.g. you used `{gettext "my string here"}`) then you'll want to update the pot files.

```sh
mix gettext.extract --merge
```

## Finding locale related issues
We have some tests written to help find issues with certain locales missing. It's experimental and feedback on the use of the tests is very welcome. To run them use:
```sh
mix test --only translations
```

## Adding a new locale
First edit the `config/config.exs` file and add your new locale code to the `locales` variable:
```elixir
config :durandal, DurandalWeb.Gettext,
  locales: ~w(en_gb your_locale_here)
```

Next add your locale files
```sh
mix gettext.merge priv/gettext --locale your_locale_here
```

Test your locale is appearing, start your application and put this into the interactive terminal:
```elixir
Gettext.known_locales(DurandalWeb.Gettext)
```

### Setting type
`Durandal.System.StartupLib` defines the user selectable locales, you will need to add your new locale to the list of choices.

Now, select the locale of choice from http://localhost:4000/profile/settings and everything will start to use your new locale.

You can now edit the locale files as detailed above under "Improving an existing locale".


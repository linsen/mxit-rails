Mxit Rails
==========

A gem that includes a simple and opinionated templating framework for Rails-based Mxit apps.
This includes a layout framework, support for styles (similar to CSS classes), abstraction of inputs and multi-step forms, and
an elegant way to support Mxit's conversation-based interface.

It also includes a browser-based *emulator* with a lot of functionality to simplify and streamline the development process.

A wrapper for some of Mxit's APIs is included.

See the [ChangeLog](https://github.com/linsen/mxit-rails/blob/master/CHANGELOG.md) for latest changes.


Sample App
----------
A basic to-do app has been set up as an example of the gem in use.  It can be seen at [mxit-to-do](https://github.com/linsen/mxit-to-do).


Installation
------------
To use the gem, just include the gem your rails projects' gemfile:

    gem 'mxit-rails', '~> 0.4.3'

[Heroku](https://devcenter.heroku.com/articles/rails3) provides the simplest way to get a rails app running on the web.

[Showoff.io](https://showoff.io) is a great tool for development, allowing you to access localhost from Mxit.

Look at [Mxit Apps](https://github.com/linsen/mxit-rails/wiki/Mxit-Apps) on the wiki for more information.


Basic usage
-----------
To set up a specific controller to use the gem, you need to include the `MxitRails::Page` module:

    include MxitRails::Page

This creates a few helper methods that can be used within that controller

- `input input_name, input_label` - Define the page's input field with a name (symbol) and text label
- `select select_name, select_label, select_options, options` - Create a single-select input with a name (symbol) and text label
- `multi_select select_name, select_label, select_options, options` - Create a multi-select input with a name (symbol) and text label
- `validate type, [parameter], message` - Set up validations on the input field.
- `validate message, &block` - A custom message with a block providing a `true` (valid) or `false` (invalid) value.  
  Note that the block must not use a `return` statement
- `submit &block` - A code block that will only be executed if the input was submitted and passed all validations.

### Validations
Currently the following validations are available:
- `:not_blank`
- `:numeric`
- `:length, exact_length`
- `:min_length, min`
- `:max_length, max`
- `:min_value, min`
- `:max_value, max`
- `:cellphone_number`
- `:sa_id_number`


Multi-step forms
----------------
The gem allows the easy set up of multi-step forms within a single controller action.  Forms are defined as follows:

    form do
      step :first do
        ...
      end
      step :second do
        ...
      end
    end

The order in which steps are defined will be the order they are presented to users in.  Each step should have its own view file, in
`app/views/controller/action/step`.  Each step has access to the same helper methods as the controller itself.  For steps that don't
have an input field (either `input`, `select` or `multi_select`), a `proceed` helper method is provided

- `proceed message` - Show a proceed link rather than a form input

Users will only proceed to the next step in the form if all validations of the previous step pass.
If the action has a `submit` block (defined outside of the `form`), it will only be executed after the last step is completed.

There are three methods to change flow within a form.  All will create a redirect, but a `return` statement should accompany them in the action
to avoid double rendering.
- `skip_to step_name` - Skip to the specified step
- `reset!` - Reset the whole form
- `submit!` - Submit the form with whatever values have been filled in so far


Styles
------
Mxit-rails has a basic styling engine that functions similarly to CSS classes.  Styles are identified by a symbol, 
and can be declared in any controller with the `mxit_style` macro.  It is recommended to declare them in application controller.

    mxit_style :author, 'background-color:#F8F3EA; color:#000000'

To include a style in a template, use the `mxit_style` helper method.  Any number of styles can be given as parameters to this method.

    <span style="<%= mxit_style :author %>">Lewis Carroll</span>

The following special styles are used in the overall layout, and it is thus recommended that they be defined.  Note that links can only be styled per-page, not per link.

- `:body` - The page body (`body` element in html)
- `:link` - The colour of links in the page
- `:link_hover` - The colour and background colour of highlighted links.

Check the [Style Guide](https://github.com/linsen/mxit-rails/wiki/Style-Guide) for more tips. There is also a list of [Emoticons](https://github.com/linsen/mxit-rails/wiki/Emoticons) that can be used on Mxit.


Layout
------
The gem currently includes a default layout that creates the necessary html headers, and includes the form at the bottom of the page.

There is a `mxit_table_row` helper method (which takes a list of styles) that will create a new table cell.
All cells will be 100% width, and are intended to be used only to create blocks of colour in the app (e.g. title bars).

Calling `mxit_table_row` with no parameters will create a row with the `body` style applied


Emulator
--------
The mxit-rails gem is provided with a feature-rich emulator to aid development.  It can be accessed at `/emulator`.  The url will dynamically update to show
the current URL of the page shown as a suffix, e.g. `emulator/path_to/page`.  Certain parts of the app can similarly be loaded directly by
navigating to their corresponding URL.

To set the root URL of the emulator, add the following line to `config/application.rb`:

    config.mxit_root = 'mxit'


Mxit Headers
------------
The gem automatically parses (some) Mxit headers and makes them available in the `mxit_params` hash.  When using the emulator these values are spoofed with cookies, but in a way transparent to the app itself.  Look at Mxit's [Documentation](http://dev.mxit.com/docs/mobi-portal-api#headers) for more details. Currently the following are available:

- `:mxit_id` - The user's Mxit ID (m-ID). From `X-Mxit-UserId-R`
- `:mxit_login` - The user's Mxit Login name. From `X-Mxit-Login` or `X-Mxit-ID-R`
- `:display_name`, `:nick` - The user's current nickname. From `X-Mxit-Nick`
- `:screen_width` - From 'UA-Pixels'
- `:screen_height` - From 'UA-Pixels'
- `:device_user_agent` - The agent string of the requesting device, e.g. "SonyEricsson?/K800i". From `X-Device-User-Agent`
- `:contact` - The Mxit service name, e.g. "books@mxit.com". From `X-Mxit-Contact`
- `:location` - The user's current location. From `X-Mxit-Location`. Automatically split into components (in `mxit_params`) as well:
    - `:country_code` - ISO 3166-1 alpha-2 Country Code
    - `:country_name`
    - `:principal_subdivision_code`
    - `:principal_subdivision_name`
    - `:city_code`
    - `:city_name`
    - `:network_operator_id`
    - `:client_features_bitset`
    - `:cell_id`
- `:profile` - The user's profile details. From `X-Mxit-Profile`. Automatically split into components (in `mxit_params`) as well:
    - `:language_code` - ISO_639-1 or ISO_639-2 language code
    - `:registered_country_code` - Registered ISO 3166-1 alpha-2 Country Code
    - `:date_of_birth` - A ruby Date object where it can be parsed to a Date, otherwise just the string from the header
    - `:gender` - a symbol (`:male`, `:female` or `:unknown`)
    - `:tariff_plan` - a symbol (`:free`, `:freestyler` or `:unknown`)
- `:user_input` - Any input typed in not matching a link on the page. HTML escaping is undone. From `X-Mxit-User-Input`.
    - Note that spaces are converted to `+` characters, and `+` characters are not escaped, so if the user enters a `+` it will appear as a space in rails.
    - This field wil *only* be set if the user enters text that is not a link on the page (case sensitive match to the link text), and if there isn't a form input on the page.


Mxit API Wrapper
----------------
The Mxit API client can be configured through an initializer, eg.

    MxitApi.configure do |config|
      config.mxit_app_name = "app_name"
      config.mxit_api_client_id = "your_client_id"
      config.mxit_api_client_secret = "your_client_secret"
    end

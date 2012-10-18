0.4.1 (18 Oct 2012)
-------------------
Improvements:
- Exceptions are now caught per batch in `batch_notify_users`
- More API exception message parsing

Features:
- Made the API wrapper configurable through an initializer
- The spooling options are now configurable on the `batch_notify_users` call
- All controllers are now extended with helpers to initiate the `MxitApi::Client` and store auth tokens in a user's session


0.4.0 (17 Oct 2012)
-------------------
Bugfixes:
- get_contact_list's skip and count parameters were not being used

Refactoring:
- Moved API response parsing/handling to a method

Features:
- Implemented the recommend API call
- The spooling options are now configurable on the send_message call

Improvements:
- Properly parsed error messages are now provided with API exceptions

Breaking changes:
- Moved the wrapper to its own module "MxitApi"
- send_message's optional parameters are now in an options hash


0.3.3 (5 Oct 2012)
------------------
Bugfixes:
- Single select was broken when default options weren't given


0.3.2 (4 Oct 2012)
------------------
Features:
- `MxitRails::Styles.add_emoticons` method that will take text and insert html to render emoticons (for use outside the bot proxy)
- Added emoticons to emulator (the generated html is parsed and they are substituted in where appropriate)
- Slight default padding added to emulator
- Added all available Mxit headers to gem (as per Mxit API documentation), with some intelligence added for concatenated fields
- Added all Mxit headers as settings to the emulator
- Updated README.md

Bugfixes:
- Bracket moved into link for numbered_list select and multi_select
- Blank labels for inputs will be ignored, not just falsey labels
- Added emulator assets to precompilation list
- Removed obsolete `mxit_nav_link` calls from dummy app


0.3.1 (4 Oct 2012)
------------------
Features:
- Allow non-string values for single and multi select (cast to symbols internally, and strings in the eventual params array)

Documentation:
- Added changelog.md to git repo


0.3.0 (4 Oct 2012)
------------------
Features:
- Added `multi_select` input (analogous to `select` input).  It has an optional `submit_label` named parameter for the text at the bottom
- Labels on inputs (and selects) can be falsey, in which case they will be ignored
- An optional `selected` named parameter can be sent to `select` and `multi_select` to set default selected options
- An optional `numbered_list` named parameter (`true` or `false`) added to `select` and `multi_select` to format things as a numbered list. Useful for lists where the options are longer
- Enabled emulator in all non-production environments (previously only worked in development)

Refactoring:
- Removed some deprecated methods from `MxitRails::Descriptor` class

Bugfixes:
- Fix to when submit blocks get executed, particularly for single step forms (i.e. those without the `form` command)

Breaking Changes:
- removed `mxit_link` and `mxit_nav_link` methods
- removed `redirect!` method



0.2.9 (27 Sept 2012)
--------------------
Bugfixes:
- Moved the form to below any tables that might be on the page. If the form is inside the table it is not correctly parsed by the BotProxy.



0.2.8 (27 Sept 2012)
--------------------
Features:
- Added a `params[:first_visit]` property (accessible in all controllers) that is true the first time a user navigates to a certain page (action), and false when refreshing that action. This is useful for tracking when a multi-step form is first viewed, while ignoring submissions, validations and later steps.

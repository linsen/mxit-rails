0.3.2 (4 Oct 2012)
------------------
Features:
- `MxitRails::Styles.add_emoticons` method that will take text and insert html to render emoticons (for use outside the bot proxy)
- Added emoticons to emulator (the generated html is parsed and they are substituted in where appropriate)
- Slight default padding added to emulator
- Added all available Mxit headers to gem (as per Mxit API documentation), with some intelligence added for concatenated fields
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

# Action Tests

When creating a new test, name it with a prefix "n_", where n is a
number that will determine the execution partial order of this new
test. THe test rig uses [ava](https://github.com/avajs/ava), and our
package.json sets ava up to execute the tests serially. Ava apparently
uses lexicographic ordering, so kee that in mind when choosing the
numeral prefix.

For example, observe that there are multiple tests with the "2_"
prefix. The implication is that there is no ordering constraint
between these tests, but that these tests must all be executed after
those tests with "0_" and "1_" prefices.
